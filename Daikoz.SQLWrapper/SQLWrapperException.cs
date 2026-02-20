using System;

namespace Daikoz.SQLWrapper
{
    public class SQLWrapperException : Exception
    {
        public string ErrorCode { get; set; } = "";
        public string File { get; set; } = "";
        public string ErrorMessage { get; set; } = "";

        public SQLWrapperException()
        {
        }

        public SQLWrapperException(string message) : base(message)
        {
        }

        public SQLWrapperException(string message, Exception innerException) : base(message, innerException)
        {
        }

        public SQLWrapperException(string errorCode, string file, string errorMessage)
        {
            ErrorCode = errorCode;
            File = file;
            ErrorMessage = errorMessage;
        }

    }
}
