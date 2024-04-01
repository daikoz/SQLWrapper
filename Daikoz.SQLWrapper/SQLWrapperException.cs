using System;

namespace Daikoz.SQLWrapper
{
    internal class SQLWrapperException(string errorCode, string file, string errorMessage) : Exception
    {
        public string ErrorCode { get; set; } = errorCode;
        public string File { get; set; } = file;
        public string ErrorMessage { get; set; } = errorMessage;
    }
}
