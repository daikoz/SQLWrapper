using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Text.RegularExpressions;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperLauncher
    {
        public List<string> GeneratedSources { get; set; } = [];

        private readonly string _ConfigurationFilePath;
        private readonly string _RootNamespace;
        private readonly DateTime _ConfigurationModifiedDate;
        private readonly SQLWrapperConfig _Config;
        private readonly TaskLoggingHelper _Log;
        private readonly bool _IsCleanning;

        private readonly Regex _RegexDatabaseName = new("^[a-zA-Z0-9-_]+$", RegexOptions.Compiled | RegexOptions.IgnoreCase);
        private readonly Regex _RegexSQLWrapperErrorLog = new(@"(?<code>SW[0-9]{5}):(?<message>.*)", RegexOptions.Compiled);
        private readonly Regex _RegexSQLWrapperErrorSQL = new(@"(?<filepath>.*):\((?<line>.*),(?<position>\d+)\):(?<code>[^:]*):(?<message>.*)", RegexOptions.Compiled);

        public SQLWrapperLauncher(string configurationFilePath, string rootNamespace, TaskLoggingHelper log, bool isCleanning)
        {
            _ConfigurationFilePath = configurationFilePath;
            _RootNamespace = rootNamespace;
            _Log = log ?? throw new ArgumentNullException(nameof(log));
            _IsCleanning = isCleanning;

            try
            {
                // Load configuration file
                DataContractJsonSerializer jsonSerializer = new(typeof(SQLWrapperConfig));
                using (FileStream fileConfig = File.OpenRead(configurationFilePath))
                {
                    object config = jsonSerializer.ReadObject(fileConfig);
                    if (config is SQLWrapperConfig sqlConfig)
                        _Config = sqlConfig;
                    else
                        throw new Exception();
                }

                _ConfigurationModifiedDate = new FileInfo(configurationFilePath).LastWriteTimeUtc;
            }
            catch (Exception ex)
            {
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationWrong.ErrorCode, configurationFilePath, String.Format(ErrorMessage.MsgConfigurationWrong.Message, ex.Message));
            }
        }

        private void LogMessage(string message)
        {
            if (_Config.Verbose)
                _Log.LogMessage(MessageImportance.High, "SQLWrapper: " + message, null);
        }

        private static string DefaultDatabaseFilePath(string databaseName)
        {
            return Path.Combine(System.Environment.CurrentDirectory, "obj", databaseName + ".sqlwrapper.db");
        }

        private string GetDatabaseFilePath(string? databaseName)
        {
            if (databaseName == null || string.IsNullOrWhiteSpace(databaseName))
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNameNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseNameNotDefined.Message);

            if (_Config.Database != null)
                foreach (Database database in _Config.Database)
                {
                    if (database.Name == databaseName)
                    {
                        if (database.FilePath == null || string.IsNullOrWhiteSpace(database.FilePath))
                            return DefaultDatabaseFilePath(databaseName);
                        return database.FilePath;
                    }
                }

            throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNotFound.ErrorCode, _ConfigurationFilePath, string.Format(ErrorMessage.MsgConfigurationDatabaseNotFound.Message, databaseName));
        }

        private static string GetAssemblyDirectory()
        {
            string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapperLauncher)).Location);
            if (!Directory.Exists(Path.Combine(assemblyDirectory, "tools")))
            {
                // nuget
                assemblyDirectory = Path.Combine(assemblyDirectory, "..", "..");
            }
            return assemblyDirectory;
        }

        private string[] GetDatabaseCustomType(string databaseName)
        {
            if (_Config.Database != null)
                foreach (Database database in _Config.Database)
                    if (database.Name == databaseName && database.CustomType != null)
                        return database.CustomType;
            return [];
        }

        public bool Execute()
        {
            LogMessage("Start");

            // database
            if (_Config.Database == null || _Config.Database.Count == 0)
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseSectionNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseSectionNotDefined.Message);
            else
                foreach (Database database in _Config.Database)
                    CacheDatabase(database);

            // Helper
            if (_Config.Helper != null)
                foreach (Helper helper in _Config.Helper)
                    GenerateHelper(helper);

            // Wrapper
            if (_Config.Wrapper != null)
                foreach (Wrapper wrapper in _Config.Wrapper)
                    GenerateWrapper(wrapper);

            LogMessage("End");
            return true;
        }

        private void StartProcess(string arguments, string logCategory, string logFile)
        {
            // Find sqlwrapper executable path
            string assemblyDirectory = GetAssemblyDirectory();
            string sqlWrapperPath = Path.Combine(assemblyDirectory, "tools", "SQLWrapper.exe");
            if (!File.Exists(sqlWrapperPath))
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationSQLWrapperToolNotFound.ErrorCode, logFile, String.Format(ErrorMessage.MsgConfigurationSQLWrapperToolNotFound.Message, sqlWrapperPath));

            LogMessage(string.Format("Launch sqlwrapper: '{0} {1}'", sqlWrapperPath, arguments));

            using Process sqlwrapperProcess = new();
            sqlwrapperProcess.StartInfo.WorkingDirectory = assemblyDirectory;
            sqlwrapperProcess.StartInfo.FileName = sqlWrapperPath;
            sqlwrapperProcess.StartInfo.UseShellExecute = false;
            sqlwrapperProcess.StartInfo.CreateNoWindow = true;
            sqlwrapperProcess.StartInfo.RedirectStandardOutput = true;
            sqlwrapperProcess.StartInfo.RedirectStandardError = true;
            sqlwrapperProcess.StartInfo.Arguments = arguments;

            sqlwrapperProcess.Start();
            sqlwrapperProcess.WaitForExit();

            // Synchronously read the standard output of the spawned process. 
            StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
            string standartOutput = readerOutput.ReadToEnd();
            if (!string.IsNullOrWhiteSpace(standartOutput))
            {
                LogMessage("Output [" + Environment.NewLine + standartOutput + ']');
                int lineNumber = 0;
                int columnNumber = 0;
                string code = string.Empty;
                string error = string.Empty;
                string errorLogFile = logFile;

                Match match = _RegexSQLWrapperErrorSQL.Match(standartOutput);
                if (match.Success)
                {
                    errorLogFile = match.Groups["filepath"].Value;
                    lineNumber = int.Parse(match.Groups["line"].Value, CultureInfo.InvariantCulture);
                    columnNumber = int.Parse(match.Groups["position"].Value, CultureInfo.InvariantCulture);
                    code = match.Groups["code"].Value.TrimStart();
                    error = match.Groups["message"].Value.TrimStart();

                    _Log.LogWarning(logCategory, code, "", errorLogFile, lineNumber, columnNumber, 0, 0, error.Trim(), null);
                }
                else
                {
                    match = _RegexSQLWrapperErrorLog.Match(standartOutput);
                    if (match.Success)
                    {
                        code = match.Groups["code"].Value.TrimStart();
                        error = match.Groups["message"].Value.TrimStart();

                        _Log.LogWarning(logCategory, code, "", logFile, 0, 0, 0, 0, error.Trim(), null);
                    }
                    else
                        _Log.LogWarning(logCategory, "", "", logFile, 0, 0, 0, 0, standartOutput, null);
                }
            }

            // Read error
            StreamReader readerError = sqlwrapperProcess.StandardError;
            string standartError = readerError.ReadToEnd();
            if (!string.IsNullOrWhiteSpace(standartError))
            {
                LogMessage("Error [" + Environment.NewLine + standartError + ']');

                int lineNumber = 0;
                int columnNumber = 0;
                string code = string.Empty;
                string error = string.Empty;
                string errorLogFile = logFile;

                Match match = _RegexSQLWrapperErrorSQL.Match(standartError);
                if (match.Success)
                {
                    errorLogFile = match.Groups["filepath"].Value;
                    lineNumber = int.Parse(match.Groups["line"].Value, CultureInfo.InvariantCulture);
                    columnNumber = int.Parse(match.Groups["position"].Value, CultureInfo.InvariantCulture);
                    code = match.Groups["code"].Value.TrimStart();
                    error = match.Groups["message"].Value.TrimStart();

                    _Log.LogError(logCategory, code, "", errorLogFile, lineNumber, columnNumber, 0, 0, error.Trim(), null);
                }
                else
                {
                    match = _RegexSQLWrapperErrorLog.Match(standartError);
                    if (match.Success)
                    {
                        code = match.Groups["code"].Value.TrimStart();
                        error = match.Groups["message"].Value.TrimStart();

                        throw new SQLWrapperException(code, logFile, error.Trim());
                    }
                    else
                        throw new SQLWrapperException(ErrorMessage.MsgSQLWrapperExecution.ErrorCode, logFile, String.Format(ErrorMessage.MsgSQLWrapperExecution.Message, standartError));
                }

            }

            sqlwrapperProcess.Close();
        }

        private void CacheDatabase(Database database)
        {
            if (database.Name == null || string.IsNullOrWhiteSpace(database.Name))
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNameNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseNameNotDefined.Message);
            if (!_RegexDatabaseName.IsMatch(database.Name))
                throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNameCharacter.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseNameCharacter.Message);

            string cacheFilePath = database.FilePath ?? "";
            if (string.IsNullOrWhiteSpace(cacheFilePath))
                cacheFilePath = DefaultDatabaseFilePath(database.Name);

            if (!Path.IsPathRooted(cacheFilePath))
                cacheFilePath = Path.Combine(System.Environment.CurrentDirectory, cacheFilePath);

            LogMessage("Cache Database in '" + cacheFilePath + "'");
            if (_IsCleanning)
            {
                LogMessage("Remove database: " + cacheFilePath);
                if (File.Exists(cacheFilePath))
                {
                    if (string.IsNullOrWhiteSpace(database.ConnectionString))
                        LogMessage("No connection string defined. Keep file cache: " + cacheFilePath);
                    else
                        File.Delete(cacheFilePath);
                }
            }
            else
            {
                if (File.Exists(cacheFilePath))
                {
                    // Update db cache only if configuration cache is modified
                    DateTime cacheDBModifiedDate = new FileInfo(cacheFilePath).LastWriteTimeUtc;
                    if (cacheDBModifiedDate > _ConfigurationModifiedDate)
                    {
                        LogMessage("Cache is uptodate. Nothing to do.");
                        return;
                    }

                    // Do nothing if connection string is not defined
                    if (string.IsNullOrWhiteSpace(database.ConnectionString))
                    {
                        LogMessage("Configuration is more recent than cache. It should be updated but connection string is not defined.");
                        return;
                    }

                    File.Delete(cacheFilePath);
                }

                if (database.ConnectionString == null || string.IsNullOrWhiteSpace(database.ConnectionString))
                    throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseConnectionNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseConnectionNotDefined.Message);

                StringBuilder argument = new();
                argument.Append("database");
                argument.Append(" -t mariadb");
                argument.Append(" -c");
                argument.Append(" \"" + database.ConnectionString.Replace("\"", "\"\"") + "\"");
                argument.Append(" -o " + cacheFilePath);

                StartProcess(argument.ToString(), ErrorMessage.Category, _ConfigurationFilePath);

                LogMessage("Cache created in " + cacheFilePath);
            }
        }


        private void GenerateHelper(Helper helper)
        {
            // Check OutputFilePath
            if (helper.OutputFilePath == null || string.IsNullOrWhiteSpace(helper.OutputFilePath))
                throw new SQLWrapperException(ErrorMessage.MsgSQLWrapperHelperOutputFilePathNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgSQLWrapperHelperOutputFilePathNotDefined.Message);

            string outputFilePath = helper.OutputFilePath;
            if (!Path.IsPathRooted(outputFilePath))
                outputFilePath = Path.Combine(System.Environment.CurrentDirectory, outputFilePath);

            // Cleaning
            if (_IsCleanning)
            {
                LogMessage("Remove helper: " + outputFilePath);
                File.Delete(helper.OutputFilePath);
            }
            else
            {
                // Check Database name
                if (helper.Database == null || string.IsNullOrWhiteSpace(helper.Database))
                    throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNameNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseNameNotDefined.Message);

                string databaseFilePath = GetDatabaseFilePath(helper.Database);

                // XSLT
                string assemblyDirectory = GetAssemblyDirectory();
                string xlstFilePath = Path.Combine(assemblyDirectory, "tools", "template", "csharp", "helper.xslt");
                if (helper.XLST != null && !string.IsNullOrWhiteSpace(helper.XLST))
                    xlstFilePath = helper.XLST;
                if (!Path.IsPathRooted(xlstFilePath))
                    xlstFilePath = Path.Combine(assemblyDirectory, xlstFilePath);
                if (!File.Exists(xlstFilePath))
                    throw new SQLWrapperException(ErrorMessage.MsgConfigurationHelperXSLTNotFound.ErrorCode, _ConfigurationFilePath, string.Format(ErrorMessage.MsgConfigurationHelperXSLTNotFound.Message, xlstFilePath));

                // Namespace
                string rootNamespace = _RootNamespace;
                if (helper.Namespace != null && !string.IsNullOrWhiteSpace(helper.Namespace))
                    rootNamespace = helper.Namespace;

                // Custom Type
                string[] customType = GetDatabaseCustomType(helper.Database);

                // Check uptodate
                if (File.Exists(outputFilePath))
                {
                    DateTime modificationOutFilePath = new FileInfo(outputFilePath).LastWriteTimeUtc;
                    DateTime modificationDatabase = new FileInfo(databaseFilePath).LastWriteTimeUtc;
                    DateTime modificationXSLT = new FileInfo(xlstFilePath).LastWriteTimeUtc;

                    if (modificationOutFilePath > modificationDatabase && modificationOutFilePath > modificationXSLT)
                    {
                        LogMessage("cache is uptodate. Nothing to do.");
                        return;
                    }
                }
                else
                    GeneratedSources.Add(outputFilePath);

                // Generate
                LogMessage(string.Format("Generate Helper for database {0} ('{1}') with XSLT '{2}': '{3}'", helper.Database, databaseFilePath, xlstFilePath, outputFilePath));

                StringBuilder argument = new();
                argument.Append("helper");
                argument.Append(" -d " + databaseFilePath);
                argument.Append(" -o " + outputFilePath);
                argument.Append(" -p namespace=" + rootNamespace);
                if (customType.Length > 0)
                {
                    argument.Append(" -t ");
                    foreach (string type in customType)
                        argument.Append(" \"" + type.Replace("\"", "\"\"") + "\"");
                }
                argument.Append(" -x " + xlstFilePath);

                StartProcess(argument.ToString(), ErrorMessage.Category, _ConfigurationFilePath);
            }
        }

        private void GenerateWrapper(Wrapper wrapper)
        {
            // FilePath
            string directoryPath = Path.GetDirectoryName(_ConfigurationFilePath);
            if (wrapper.Path != null && !string.IsNullOrWhiteSpace(wrapper.Path))
                if (Path.IsPathRooted(wrapper.Path))
                    directoryPath = wrapper.Path;
                else
                    directoryPath = Path.Combine(directoryPath, wrapper.Path);
            if (!Directory.Exists(directoryPath))
                throw new SQLWrapperException(ErrorMessage.MsgSQLWrapperDirectoryNotFound.ErrorCode, _ConfigurationFilePath, string.Format(ErrorMessage.MsgSQLWrapperDirectoryNotFound.Message, directoryPath));

            // File Pattern
            string filePattern = wrapper.FilePattern ?? "*.sql";

            // List SQL files
            LogMessage(string.Format("Search '{0}' in '{1}'", filePattern, directoryPath));
            string[] listSQLFiles = Directory.EnumerateFiles(directoryPath, filePattern, SearchOption.AllDirectories).ToArray();
            if (listSQLFiles.Length == 0)
                throw new SQLWrapperException(ErrorMessage.MsgSQLWrapperSQLFilesNotFound.ErrorCode, _ConfigurationFilePath, string.Format(ErrorMessage.MsgSQLWrapperSQLFilesNotFound.Message, filePattern, directoryPath));

            // Cleaning
            if (_IsCleanning)
            {
                foreach (string sqlFilePath in listSQLFiles)
                {
                    string codeFilePath = sqlFilePath + ".cs";
                    LogMessage("Remove wrapper: " + codeFilePath);
                    File.Delete(codeFilePath);
                }
            }
            else
            {
                // Check Database name
                if (wrapper.Database == null || string.IsNullOrWhiteSpace(wrapper.Database))
                    throw new SQLWrapperException(ErrorMessage.MsgConfigurationDatabaseNameNotDefined.ErrorCode, _ConfigurationFilePath, ErrorMessage.MsgConfigurationDatabaseNameNotDefined.Message);

                string databaseFilePath = GetDatabaseFilePath(wrapper.Database);

                // Namespace
                string rootNamespace = _RootNamespace;
                if (wrapper.Namespace != null && !string.IsNullOrWhiteSpace(wrapper.Namespace))
                    rootNamespace = wrapper.Namespace;

                // XSLT
                string assemblyDirectory = GetAssemblyDirectory();
                string xlstFilePath = Path.Combine(assemblyDirectory, "tools", "template", "csharp", "ADO.xslt");
                if (wrapper.XLST != null && !string.IsNullOrWhiteSpace(wrapper.XLST))
                    xlstFilePath = wrapper.XLST;
                if (!Path.IsPathRooted(xlstFilePath))
                    xlstFilePath = Path.Combine(assemblyDirectory, xlstFilePath);
                if (!File.Exists(xlstFilePath))
                    throw new SQLWrapperException(ErrorMessage.MsgConfigurationWrapperXSLTNotFound.ErrorCode, _ConfigurationFilePath, string.Format(ErrorMessage.MsgConfigurationWrapperXSLTNotFound.Message, xlstFilePath));

                // Custom Type
                string[] customType = GetDatabaseCustomType(wrapper.Database);

                // Generate wrapper
                LogMessage(string.Format("Generate wrapper for database {0} with XSLT '{1}':", databaseFilePath, xlstFilePath));

                DateTime modificationDatabase = new FileInfo(databaseFilePath).LastWriteTimeUtc;
                DateTime modificationXSLT = new FileInfo(xlstFilePath).LastWriteTimeUtc;

                foreach (string sqlFilePath in listSQLFiles)
                {
                    string outputFilePath = sqlFilePath + ".cs";

                    // Check uptodate
                    if (File.Exists(outputFilePath))
                    {
                        DateTime modificationSQLFile = new FileInfo(sqlFilePath).LastWriteTimeUtc;
                        DateTime modificationOutputFile = new FileInfo(outputFilePath).LastWriteTimeUtc;
                        if (modificationOutputFile > modificationDatabase && modificationOutputFile > modificationXSLT && modificationOutputFile > modificationSQLFile)
                        {
                            LogMessage(string.Format("'{0} wrapper is uptodate. Nothing to do.", sqlFilePath));
                            continue;
                        }
                    }
                    else
                        GeneratedSources.Add(outputFilePath);

                    // Generate
                    LogMessage(string.Format("Generate wrapper: '{0}'", sqlFilePath));

                    string newNameSpace = rootNamespace ?? string.Empty;
                    string[] directoriesName = Path.GetDirectoryName(sqlFilePath).Remove(0, Directory.GetCurrentDirectory().Length).Split('\\');
                    for (uint idx = 0; idx < directoriesName.Length - 1; ++idx)
                        if (!string.IsNullOrWhiteSpace(directoriesName[idx]))
                            newNameSpace += '.' + directoriesName[idx];
                    string className = directoriesName.Length >= 1 ? directoriesName[directoriesName.Length - 1] : "SQLWrapper";

                    StringBuilder argument = new();
                    argument.Append("wrapper");
                    argument.Append(" -d " + databaseFilePath);
                    argument.Append(" -i " + sqlFilePath);
                    argument.Append(" -o " + outputFilePath);
                    argument.Append(" -p namespace=" + newNameSpace + " classname=" + className);
                    if (customType.Length > 0)
                    {
                        argument.Append(" -t ");
                        foreach (string type in customType)
                            argument.Append(" \"" + type.Replace("\"", "\"\"") + "\"");
                    }
                    argument.Append(" -x " + xlstFilePath);

                    StartProcess(argument.ToString(), ErrorMessage.Category, _ConfigurationFilePath);
                }
            }
        }
    }
}

