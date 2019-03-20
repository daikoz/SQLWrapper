using Microsoft.Build.Evaluation;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization.Json;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapper
    {
        private SQLWrapperConfig[] _config;
        private TaskLoggingHelper _log;
        private bool _isCleanning;
        private DateTime _buildTime;
        private string _csprojPath;

        public SQLWrapper(string fileConfigFile, TaskLoggingHelper log, bool isCleanning, DateTime buildTime, string csprojPath)
        {
            _log = log;
            _isCleanning = isCleanning;
            _buildTime = buildTime;
            _csprojPath = csprojPath;
            try
            {
                DataContractJsonSerializer ser = new DataContractJsonSerializer(typeof(SQLWrapperConfig[]));
                using (FileStream fileConfig = File.OpenRead(fileConfigFile))
                    _config = ser.ReadObject(fileConfig) as SQLWrapperConfig[];
            }
            catch
            {
                log.LogError("SQLWrapper: format of configuration is not valid", new { fileConfigFile });
                throw;
            }
        }

        public bool Execute()
        {
            _log.LogMessage(MessageImportance.Normal, "SQLWrapper: Start");

            foreach (SQLWrapperConfig config in _config)
            {
                string filePattern = config.FilePattern;
                if (string.IsNullOrWhiteSpace(filePattern))
                    filePattern = "*.sql";

                if (config.RelativePath == null || config.RelativePath.Length == 0)
                    Execute("", filePattern, config.Namespace, config.ConnectionStrings);
                else
                {
                    foreach (string relativePath in config.RelativePath)
                        Execute(relativePath, filePattern, config.Namespace, config.ConnectionStrings);
                }
            }

            _log.LogMessage(MessageImportance.Normal, "SQLWrapper: End");
            return true;
        }

        private void Execute(string relativePath, string filePattern, string namespaceName, string[] connectionString)
        {
            string directory = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            if (!Directory.Exists(directory))
                _log.LogError("SQLWrapper: " + directory + "doesn't exist");
            else
            {
                _log.LogMessage(MessageImportance.Low, "SQLWrapper: Find in directory " + directory + ": " + filePattern);
                foreach (string file in Directory.EnumerateFiles(directory, filePattern, SearchOption.AllDirectories))
                {
                    _log.LogMessage(MessageImportance.Low, "SQLWrapper: " + file);
                    string outputFile = /* Path.Combine(Path.GetDirectoryName(file), Path.GetFileNameWithoutExtension(file)*/ file + ".cs";

                    if (_isCleanning)
                    {
                        if (File.Exists(outputFile))
                            File.Delete(outputFile);
                    }
                    else
                    {
                        if (!File.Exists(outputFile) || new FileInfo(outputFile).LastWriteTimeUtc <= _buildTime || new FileInfo(outputFile).LastWriteTimeUtc <= new FileInfo(file).LastWriteTimeUtc)
                        {
                            using (Process sqlwrapperProcess = new Process())
                            {
                                string newNameSpace = namespaceName;
                                string[] directoriesName = Path.GetDirectoryName(file).Remove(0, Directory.GetCurrentDirectory().Length).Split('\\');
                                for (uint idx = 0; idx < directoriesName.Length - 1; ++idx)
                                    if (!string.IsNullOrWhiteSpace(directoriesName[idx]))
                                        newNameSpace += '.' + directoriesName[idx];

                                string className = directoriesName.Length >= 1 ? directoriesName[directoriesName.Length - 1] : "SQLWrapper";

                                string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapper)).Location);
                                if (Directory.Exists(Path.Combine(assemblyDirectory, "tools")))
                                {
                                    // Debug
                                    sqlwrapperProcess.StartInfo.WorkingDirectory = assemblyDirectory;
                                }
                                else
                                {
                                    // nuget
                                    sqlwrapperProcess.StartInfo.WorkingDirectory = Path.Combine(assemblyDirectory, "..", "..");
                                }

                                sqlwrapperProcess.StartInfo.FileName = Path.Combine(sqlwrapperProcess.StartInfo.WorkingDirectory, "tools", "SQLWrapper.exe");
                                sqlwrapperProcess.StartInfo.UseShellExecute = false;
                                sqlwrapperProcess.StartInfo.CreateNoWindow = true;
                                sqlwrapperProcess.StartInfo.RedirectStandardOutput = true;
                                sqlwrapperProcess.StartInfo.RedirectStandardError = true;
                                sqlwrapperProcess.StartInfo.Arguments = " -i " + file + " -o " + outputFile + " -n " + newNameSpace + " -c " + className + " -m " + Path.GetFileNameWithoutExtension(file) + " -x " + Path.Combine("tools", "Template", "charpADO.xslt") + " -d ";
                                foreach (string connString in connectionString)
                                    sqlwrapperProcess.StartInfo.Arguments += " \"" + connString.Replace("\"", "\"\"") + "\" ";
                                sqlwrapperProcess.Start();

                                // Synchronously read the standard output of the spawned process. 
                                StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
                                _log.LogWarning(readerOutput.ReadToEnd());

                                StreamReader readerError = sqlwrapperProcess.StandardError;
                                string totot = readerError.ReadToEnd();
                                _log.LogError(totot);


                                sqlwrapperProcess.WaitForExit();


                                //////  <Compile Update="DB\AdsMessage\SelectToSend.sql.cs">
                                //////<DependentUpon>SelectToSend.sql</DependentUpon>
                                //////  </Compile>
                                //var csproj = new Microsoft.Build.Evaluation.Project(@"D:\Jobs\src\Lib\Daikoz.ToutVendre\Daikoz.ToutVendre.csproj", null, null, new ProjectCollection());
                                //var metadata = new List<KeyValuePair<string, string>>();
                                //metadata.Add(new KeyValuePair<string, string>("DependentUpon", file));
                                //csproj.AddItem("Compile", outputFile, metadata);
                                //csproj.ReevaluateIfNecessary();
                                //csproj.Save();
                                //Microsoft.Build.Evaluation.ProjectCollection.GlobalProjectCollection.UnloadAllProjects();
                            }
                        }
                    }
                }
            }


        }
    }
}
