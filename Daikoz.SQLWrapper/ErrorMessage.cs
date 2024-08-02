namespace Daikoz.SQLWrapper
{
    internal class ErrorMessage
    {
        public const string Category = "SQLWrapper";

        public static readonly (string ErrorCode, string Message) MsgGlobalException = ("SW00500", "");
        public static readonly (string ErrorCode, string Message) MsgConfigurationNotExist = ("SW00501", "SQLWrapper configuration doesn't exist. A default sqlwrapper.json is created in root of your project");
        public static readonly (string ErrorCode, string Message) MsgConfigurationWrong = ("SW00502", "Configuration file format is not valid: {0}");
        public static readonly (string ErrorCode, string Message) MsgConfigurationDatabaseNameNotDefined = ("SW00503", "Database name not defined");
        public static readonly (string ErrorCode, string Message) MsgConfigurationDatabaseNameCharacter = ("SW00504", "Database name contain wrong character: a-z A-Z 0-9 - _");
        public static readonly (string ErrorCode, string Message) MsgConfigurationDatabaseConnectionNotDefined = ("SW00505", "Database's connection string is not defined. Cache file cannot be generate.");
        public static readonly (string ErrorCode, string Message) MsgConfigurationSQLWrapperToolNotFound = ("SW00506", "sqlwrapper executable not found in: {0}");
        public static readonly (string ErrorCode, string Message) MsgSQLWrapperExecution = ("SW00507", "Error during execution of sqlwrapper: {0}");
        public static readonly (string ErrorCode, string Message) MsgSQLWrapperHelperOutputFilePathNotDefined = ("SW00508", "Helper output filepath not defined");
        public static readonly (string ErrorCode, string Message) MsgConfigurationDatabaseSectionNotDefined = ("SW00509", "No schema database defined");
        public static readonly (string ErrorCode, string Message) MsgConfigurationDatabaseNotFound = ("SW00510", "Database name is not found: {0}");
        public static readonly (string ErrorCode, string Message) MsgConfigurationHelperXSLTNotFound = ("SW00511", "XSLT helper file not found: {0}");
        public static readonly (string ErrorCode, string Message) MsgSQLWrapperDirectoryNotFound = ("SW00512", "Path to search SQL files not found: {0}");
        public static readonly (string ErrorCode, string Message) MsgSQLWrapperSQLFilesNotFound = ("SW00513", "No SQL files ({0}) not found in directory: {1}");
        public static readonly (string ErrorCode, string Message) MsgConfigurationWrapperXSLTNotFound = ("SW00514", "XSLT wrapper file not found: {0}");
    }

}
