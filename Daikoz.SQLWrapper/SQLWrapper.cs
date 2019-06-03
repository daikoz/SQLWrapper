using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization.Json;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapper
    {
        private readonly SQLWrapperConfig[] _config;
        private readonly TaskLoggingHelper _log;
        private readonly bool _isCleanning;

        public SQLWrapper(string fileConfigFile, TaskLoggingHelper log, bool isCleanning)
        {
            _log = log;
            _isCleanning = isCleanning;
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

            uint configIdx = 1;
            foreach (SQLWrapperConfig config in _config)
            {
                string cacheDBPath = Path.Combine(System.Environment.CurrentDirectory, "obj", "sqlwrapper" + configIdx + ".db");
                if (!_isCleanning)
                    CacheDatabase(cacheDBPath, config.ConnectionStrings, config.SQLWrapperPath);
                else
                    File.Delete(cacheDBPath);

                string filePattern = config.FilePattern;
                if (string.IsNullOrWhiteSpace(filePattern))
                    filePattern = "*.sql";

                if (config.RelativePath == null || config.RelativePath.Length == 0)
                    Execute("", filePattern, config.Namespace, config.SQLWrapperPath, cacheDBPath, config.CustomTypes);
                else
                {
                    foreach (string relativePath in config.RelativePath)
                        Execute(relativePath, filePattern, config.Namespace, config.SQLWrapperPath, cacheDBPath, config.CustomTypes);
                }

                if (config.HelperRelativePath != null)
                {
                    using (Process sqlwrapperProcess = new Process())
                    {
                        string outputPath = Path.Combine(System.Environment.CurrentDirectory, config.HelperRelativePath);
                        string sqlWrapperPath = config.SQLWrapperPath;
                        string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapper)).Location);
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
                        sqlwrapperProcess.StartInfo.Arguments = "helper -o " + outputPath + " -p namespace=" + config.Namespace + " -x " + Path.Combine("tools", "Template", "CSharp", "Helper.xslt") + " -d " + cacheDBPath;
                        sqlwrapperProcess.Start();

                        // Synchronously read the standard output of the spawned process. 
                        StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
                        _log.LogWarning(readerOutput.ReadToEnd());

                        StreamReader readerError = sqlwrapperProcess.StandardError;
                        string error = readerError.ReadToEnd();
                        if (!string.IsNullOrWhiteSpace(error))
                            _log.LogError(error);


                        sqlwrapperProcess.WaitForExit();
                    }
                }

                ++configIdx;
            }

            _log.LogMessage(MessageImportance.Normal, "SQLWrapper: End");
            return true;
        }

        private void CacheDatabase(string cacheDBPath, string[] connectionStrings, string sqlWrapperPath)
        {
            if (File.Exists(cacheDBPath)) return;

            using (Process sqlwrapperProcess = new Process())
            {
                string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapper)).Location);
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

                sqlwrapperProcess.StartInfo.Arguments = "database -t mariadb -c ";
                foreach (string connectionString in connectionStrings)
                    sqlwrapperProcess.StartInfo.Arguments += " \"" + connectionString.Replace("\"", "\"\"") + "\" ";
                sqlwrapperProcess.StartInfo.Arguments += "-o " + cacheDBPath;

                sqlwrapperProcess.Start();

                // Synchronously read the standard output of the spawned process. 
                StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
                _log.LogWarning(readerOutput.ReadToEnd());

                StreamReader readerError = sqlwrapperProcess.StandardError;
                string error = readerError.ReadToEnd();
                if (!string.IsNullOrWhiteSpace(error))
                    _log.LogError(error);

            }
        }

        private void Execute(string relativePath, string filePattern, string namespaceName, string sqlWrapperPath, string cacheDBPath, string[] customTypes)
        {
            string directory = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            if (!Directory.Exists(directory))
                _log.LogError("SQLWrapper: " + directory + "doesn't exist");
            else
            {
                _log.LogMessage(MessageImportance.Low, "SQLWrapper: Find in directory " + directory + ": " + filePattern);
                List<string> listDirectories = new List<string>(Directory.GetDirectories(directory, "*", SearchOption.AllDirectories))
                {
                    directory
                };
                foreach (string subdirectory in listDirectories)
                {
                    List<string> listFiles = new List<string>(Directory.EnumerateFiles(subdirectory, filePattern, SearchOption.TopDirectoryOnly));
                    if (listFiles.Count > 0)
                    {
                        _log.LogMessage(MessageImportance.Low, "SQLWrapper: " + subdirectory);
                        string outputFile = Path.Combine(subdirectory, Path.GetFileName(subdirectory) + ".cs");

                        if (File.Exists(outputFile))
                            File.Delete(outputFile);

                        if (!_isCleanning)
                        {
                            string assemblyDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetAssembly(typeof(SQLWrapper)).Location);
                            if (!Directory.Exists(Path.Combine(assemblyDirectory, "tools")))
                            {
                                // nuget
                                assemblyDirectory = Path.Combine(assemblyDirectory, "..", "..");
                            }
                            if (string.IsNullOrWhiteSpace(sqlWrapperPath))
                                sqlWrapperPath = Path.Combine(assemblyDirectory, "tools", "SQLWrapper.exe");

                            bool isFileUpdated = false;
                            foreach (string file in listFiles)
                                isFileUpdated &= new FileInfo(outputFile).LastWriteTimeUtc <= new FileInfo(file).LastWriteTimeUtc;

                            if (!File.Exists(outputFile) || new FileInfo(outputFile).LastWriteTimeUtc <= new FileInfo(sqlWrapperPath).LastWriteTimeUtc || isFileUpdated)
                            {
                                using (Process sqlwrapperProcess = new Process())
                                {
                                    string newNameSpace = namespaceName;
                                    string[] directoriesName = Path.GetDirectoryName(listFiles[0]).Remove(0, Directory.GetCurrentDirectory().Length).Split('\\');
                                    for (uint idx = 0; idx < directoriesName.Length - 1; ++idx)
                                        if (!string.IsNullOrWhiteSpace(directoriesName[idx]))
                                            newNameSpace += '.' + directoriesName[idx];

                                    string className = directoriesName.Length >= 1 ? directoriesName[directoriesName.Length - 1] : "SQLWrapper";

                                    sqlwrapperProcess.StartInfo.WorkingDirectory = assemblyDirectory;
                                    sqlwrapperProcess.StartInfo.FileName = sqlWrapperPath;
                                    sqlwrapperProcess.StartInfo.UseShellExecute = false;
                                    sqlwrapperProcess.StartInfo.CreateNoWindow = true;
                                    sqlwrapperProcess.StartInfo.RedirectStandardOutput = true;
                                    sqlwrapperProcess.StartInfo.RedirectStandardError = true;

                                    sqlwrapperProcess.StartInfo.Arguments = "wrapper -i";
                                    foreach (string file in listFiles)
                                        sqlwrapperProcess.StartInfo.Arguments += " \"" + file.Replace("\"", "\"\"") + "\" ";
                                    sqlwrapperProcess.StartInfo.Arguments += " -o " + outputFile + " -p namespace=" + newNameSpace + " classname=" + className + " -x " + Path.Combine("tools", "Template", "CSharp", "ADO.xslt") + " -d " + cacheDBPath;
                                    if (customTypes != null && customTypes.Length > 0)
                                    {
                                        sqlwrapperProcess.StartInfo.Arguments += " -t ";
                                        foreach (string type in customTypes)
                                            sqlwrapperProcess.StartInfo.Arguments += " \"" + type.Replace("\"", "\"\"") + "\" ";
                                    }
                                    sqlwrapperProcess.Start();

                                    // Synchronously read the standard output of the spawned process. 
                                    StreamReader readerOutput = sqlwrapperProcess.StandardOutput;
                                    _log.LogWarning(readerOutput.ReadToEnd());

                                    StreamReader readerError = sqlwrapperProcess.StandardError;
                                    string error = readerError.ReadToEnd();
                                    if (!string.IsNullOrWhiteSpace(error))
                                        _log.LogError(error);


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
}
