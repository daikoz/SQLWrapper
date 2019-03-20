using Microsoft.Build.Utilities;
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperBuild : Task
    {
        public string FileName { get; set; }

        public bool IsCleanning { get; set; }

        public override bool Execute()
        {
            // Debugger.Launch();

            if (FileName == null)
            {
                Log.LogError("sqlwrapper configuration does not exist. Create sqlwrapperconfig.json in root of our project.");
                return false;
            }

            FileInfo configFile = new FileInfo(FileName);

            if (!configFile.Exists)
            {
                Log.LogError(configFile.FullName + " does not exist. A default is created.");
                using (StreamWriter stream = File.CreateText(configFile.FullName))
                {
                    stream.WriteLine(Properties.Resources.DefaultConfiguration);
                    stream.Close();
                }
                return false;
            }

            SQLWrapper sqlWrapper = new SQLWrapper(FileName, Log, IsCleanning, GetLinkerTimestampUtc(Assembly.GetExecutingAssembly()), this.BuildEngine5.ProjectFileOfTaskNode);
            return sqlWrapper.Execute();
        }

        private static DateTime GetLinkerTimestampUtc(Assembly assembly)
        {
            string location = assembly.Location;
            FileInfo fileInfo = new FileInfo(location);
            return fileInfo.LastWriteTimeUtc;
        }

    }
}

