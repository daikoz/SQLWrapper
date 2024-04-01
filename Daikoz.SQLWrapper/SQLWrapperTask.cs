using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System;
using System.IO;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperTask : Task, ITask
    {
        public string? ConfigurationFilePath { get; set; }
        public string RootNamespace { get; set; } = "Daikoz.SQLWrapper";
        public bool IsCleanning { get; set; }

        public override bool Execute()
        {
            // System.Diagnostics.Debugger.Launch();

            try
            {
                FileInfo configFile = new(ConfigurationFilePath);
                if (ConfigurationFilePath == null || !configFile.Exists)
                {
                    using StreamWriter stream = File.CreateText(configFile.FullName);
                    stream.WriteLine(Resource.DefaultConfiguration);
                    stream.Close();

                    Log.LogError(ErrorMessage.Category, ErrorMessage.MsgConfigurationNotExist.ErrorCode, "", "sqlwrapper.json", 0, 0, 0, 0, ErrorMessage.MsgConfigurationNotExist.Message, null);
                    return false;
                }

                Daikoz.SQLWrapper.SQLWrapperLauncher sqlWrapper = new(ConfigurationFilePath, RootNamespace, Log, IsCleanning);
                return sqlWrapper.Execute();
            }
            catch (Daikoz.SQLWrapper.SQLWrapperException ex)
            {
                Log.LogError(ErrorMessage.Category, ex.ErrorCode, "", "", ex.File, 0, 0, 0, 0, ex.ErrorMessage.Trim(), null);
            }
            catch (Exception ex)
            {
                Log.LogError(ErrorMessage.Category, ErrorMessage.MsgGlobalException.ErrorCode, "", "", 0, 0, 0, 0, ex.Message.Trim(), null);
            }

            return false;
        }
    }
}
