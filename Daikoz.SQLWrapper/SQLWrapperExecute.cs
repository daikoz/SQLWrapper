using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Text.RegularExpressions;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperExecute
    {
        private readonly SQLWrapperConfig[] _config;
        private readonly TaskLoggingHelper _log;
        private readonly bool _isCleanning;
        private readonly DateTime _fileConfigFileModifiedDate;
        private DateTime _cacheDBModifiedDate;

        public SQLWrapperExecute(string fileConfigFile, TaskLoggingHelper log, bool isCleanning)
        {
            _log = log ?? throw new ArgumentNullException(nameof(log));
            _isCleanning = isCleanning;
            try
            {
                // Load configuration file
                DataContractJsonSerializer ser = new DataContractJsonSerializer(typeof(SQLWrapperConfig[]));
                using (FileStream fileConfig = File.OpenRead(fileConfigFile))
                    _config = ser.ReadObject(fileConfig) as SQLWrapperConfig[];
                _fileConfigFileModifiedDate = new FileInfo(fileConfigFile).LastWriteTimeUtc;
            }
            catch
            {
                _log.LogError("SQLWrapper", "SW000003", "", fileConfigFile, 0, 0, 0, 0, "Format of configuration is not valid", null);
                throw;
            }
        }

        public bool Execute()
        {
            _log.LogMessage(MessageImportance.High, "SQLWrapper: Start", null);

            uint configIdx = 1;
            foreach (SQLWrapperConfig config in _config)
            {
                // Database
                string cacheDBPath = Path.Combine(System.Environment.CurrentDirectory, "obj", "sqlwrapper" + configIdx + ".db");
                if (_isCleanning)
                    File.Delete(cacheDBPath);
                else
                    CacheDatabase(cacheDBPath, config.ConnectionStrings, config.SQLWrapperPath);

                // Wrapper
                string filePattern = config.FilePattern;
                if (string.IsNullOrWhiteSpace(filePattern))
                    filePattern = "*.sql";

                if (config.RelativePath != null)
                {
                    if (config.RelativePath.Length == 0)
                        Execute("", filePattern, config.Namespace, config.SQLWrapperPath, cacheDBPath, config.CustomTypes);
                    else
                    {
                        foreach (string relativePath in config.RelativePath)
                            Execute(relativePath, filePattern, config.Namespace, config.SQLWrapperPath, cacheDBPath, config.CustomTypes);
                    }
                }

                // Helper
                if (_isCleanning)
                {
                    if (config.HelperRelativePath != null && File.Exists(config.HelperRelativePath))
                        File.Delete(config.HelperRelativePath);
                }
                else if (config.HelperRelativePath != null && (!File.Exists(config.HelperRelativePath) || new FileInfo(config.HelperRelativePath).LastWriteTimeUtc <= _fileConfigFileModifiedDate))
                {
                    string helperPath = Path.Combine("tools", "Template", "CSharp", "Helper.xslt");

                    StringBuilder argument = new StringBuilder();
                    argument.Append("helper");
                    argument.Append(" -d " + cacheDBPath);
                    argument.Append(" -o " + Path.Combine(System.Environment.CurrentDirectory, config.HelperRelativePath));
                    argument.Append(" -p namespace=" + config.Namespace);
                    if (config.CustomTypes != null && config.CustomTypes.Length > 0)
                    {
                        argument.Append(" -t");
                        foreach (string type in config.CustomTypes)
                            argument.Append(" \"" + type.Replace("\"", "\"\"") + "\" ");
                    }
                    argument.Append(" -x " + helperPath);

                    StartProcess(config.SQLWrapperPath, argument.ToString(), "SQLWrapper Helper", helperPath);
                }

                ++configIdx;
            }

            _log.LogMessage(MessageImportance.High, "SQLWrapper: End", null);
            return true;
        }

        private void StartProcess(string sqlWrapperPath, string arguments, string logCategory, string logFile)
        {
            using Process sqlwrapperProcess = new Process();

            string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapperExecute)).Location);
            if (!Directory.Exists(Path.Combine(assemblyDirectory, "tools")))
            {
                // nuget
                assemblyDirectory = Path.Combine(assemblyDirectory, "..", "..");
            }
            if (string.IsNullOrWhiteSpace(sqlWrapperPath))
                sqlWrapperPath = Path.Combine(assemblyDirectory, "tools", "SQLWrapper.exe");

            sqlwrapperProcess.StartInfo.WorkingDirectory = assemblyDirectory;
            sqlwrapperProcess.StartInfo.FileName = sqlWrapperPath;
            sqlwrapperProcess.StartInfo.UseShellExecute = false;
            sqlwrapperProcess.StartInfo.CreateNoWindow = true;
            sqlwrapperProcess.StartInfo.RedirectStandardOutput = true;
            sqlwrapperProcess.StartInfo.RedirectStandardError = true;
            sqlwrapperProcess.StartInfo.Arguments = arguments;

            sqlwrapperProcess.Start();

            // Synchronously read the standard output of the spawned process. 
            StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
            string error = readerOutput.ReadToEnd();
            if (!string.IsNullOrWhiteSpace(error))
                _log.LogWarning(logCategory, "", "", logFile, 0, 0, 0, 0, error, null);

            StreamReader readerError = sqlwrapperProcess.StandardError;
            error = readerError.ReadToEnd();
            if (!string.IsNullOrWhiteSpace(error))
            {
                int lineNumber = 0;
                int columnNumber = 0;
                string code = "";
                Match match = Regex.Match(error, @"(?<filepath>.*):\((?<line>.*),(?<position>\d+)\):(?<code>[^:]*):(?<message>.*)");
                if (match.Success)
                {
                    logFile = match.Groups["filepath"].Value;
                    lineNumber = int.Parse(match.Groups["line"].Value, CultureInfo.InvariantCulture);
                    columnNumber = int.Parse(match.Groups["position"].Value, CultureInfo.InvariantCulture);
                    code = match.Groups["code"].Value.TrimStart();
                    error = match.Groups["message"].Value.TrimStart();
                }

                _log.LogError(logCategory, code, "", logFile, lineNumber, columnNumber, 0, 0, error, null);
            }

            sqlwrapperProcess.WaitForExit();
        }

        private void CacheDatabase(string cacheDBPath, string[] connectionStrings, string sqlWrapperPath)
        {
            if (File.Exists(cacheDBPath))
            {
                _cacheDBModifiedDate = new FileInfo(cacheDBPath).LastWriteTimeUtc;
                if (_cacheDBModifiedDate > _fileConfigFileModifiedDate) return;
            }

            StringBuilder argument = new StringBuilder();
            argument.Append("database");
            argument.Append(" -t mariadb");
            argument.Append(" -c");
            foreach (string connectionString in connectionStrings)
                argument.Append(" \"" + connectionString.Replace("\"", "\"\"") + "\" ");
            argument.Append(" -o " + cacheDBPath);

            StartProcess(sqlWrapperPath, argument.ToString(), "SQLWrapper Database", cacheDBPath);

            _cacheDBModifiedDate = DateTime.UtcNow;
        }

        private void Execute(string relativePath, string filePattern, string namespaceName, string sqlWrapperPath, string cacheDBPath, string[] customTypes)
        {
            string directory = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            if (!Directory.Exists(directory))
                _log.LogError("SQLWrapper Wrapper", "SW000008", "", directory, 0, 0, 0, 0, "SQLWrapper: " + directory + " doesn't exist", null);
            else
            {
                _log.LogMessage(MessageImportance.High, "SQLWrapper: Find in directory " + directory + ": " + filePattern, null);
                List<string> listDirectories = new List<string>(Directory.GetDirectories(directory, "*", SearchOption.AllDirectories))
                {
                    directory
                };
                foreach (string subdirectory in listDirectories)
                {
                    List<string> listFiles = new List<string>(Directory.EnumerateFiles(subdirectory, filePattern, SearchOption.TopDirectoryOnly));
                    if (listFiles.Count > 0)
                    {
                        _log.LogMessage(MessageImportance.High, "SQLWrapper: " + subdirectory, null);
                        string outputFile = Path.Combine(subdirectory, Path.GetFileName(subdirectory) + ".cs");

                        if (_isCleanning)
                            File.Delete(outputFile);
                        else
                        {
                            bool isFileUpdated = false;
                            foreach (string file in listFiles)
                                isFileUpdated |= new FileInfo(outputFile).LastWriteTimeUtc <= new FileInfo(file).LastWriteTimeUtc;

                            if (!File.Exists(outputFile) || new FileInfo(outputFile).LastWriteTimeUtc <= _cacheDBModifiedDate || isFileUpdated)
                            {
                                File.Delete(outputFile);

                                string newNameSpace = namespaceName;
                                string[] directoriesName = Path.GetDirectoryName(listFiles[0]).Remove(0, Directory.GetCurrentDirectory().Length).Split('\\');
                                for (uint idx = 0; idx < directoriesName.Length - 1; ++idx)
                                    if (!string.IsNullOrWhiteSpace(directoriesName[idx]))
                                        newNameSpace += '.' + directoriesName[idx];
                                string className = directoriesName.Length >= 1 ? directoriesName[directoriesName.Length - 1] : "SQLWrapper";

                                StringBuilder argument = new StringBuilder();
                                argument.Append("wrapper");
                                argument.Append(" -d " + cacheDBPath);
                                argument.Append(" -i");
                                foreach (string file in listFiles)
                                    argument.Append(" \"" + file.Replace("\"", "\"\"") + "\" ");
                                argument.Append(" -o " + outputFile);
                                argument.Append(" -p namespace=" + newNameSpace + " classname=" + className);
                                if (customTypes != null && customTypes.Length > 0)
                                {
                                    argument.Append(" -t");
                                    foreach (string type in customTypes)
                                        argument.Append(" \"" + type.Replace("\"", "\"\"") + "\" ");
                                }
                                argument.Append(" -x " + Path.Combine("tools", "Template", "CSharp", "ADO.xslt"));

                                StartProcess(sqlWrapperPath, argument.ToString(), "SQLWrapper Wrapper", subdirectory);
                            }
                        }
                    }
                }
            }
        }
    }
}
