using Microsoft.Build.Utilities;
using System;
using System.IO;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperBuild : Task
    {
        public string FileName { get; set; }

        public bool IsCleanning { get; set; }

        public override bool Execute()
        {
            //System.Diagnostics.Debugger.Launch();

            try
            {
                FileInfo configFile = new FileInfo(FileName);
                if (FileName == null || !configFile.Exists)
                {
                    Log.LogError("SQLWrapper", "SW000002", "", "sqlwrapperconfig.json", 0, 0, 0, 0, "SQLWrapper configuration does not exist. A default sqlwrapperconfig.json is created in root of our project.", null);
                    using (StreamWriter stream = File.CreateText(configFile.FullName))
                    {
                        stream.WriteLine(Properties.Resources.DefaultConfiguration);
                        stream.Close();
                    }
                    return false;
                }

                SQLWrapperExecute sqlWrapper = new SQLWrapperExecute(FileName, Log, IsCleanning);
                return sqlWrapper.Execute();
            }
            catch (Exception ex)
            {
                Log.LogError("SQLWrapper", "SW000001", "", "", 0, 0, 0, 0, ex.Message, null);
            }
            return false;
        }
    }
}

