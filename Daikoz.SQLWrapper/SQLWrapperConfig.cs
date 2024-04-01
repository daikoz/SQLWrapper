using System.Collections.Generic;
using System.Runtime.Serialization;

namespace Daikoz.SQLWrapper
{
    [DataContract]
    internal class Database
    {
        [DataMember]
        public string? Name { get; set; }

        [DataMember]
        public string? ConnectionString { get; set; }

        [DataMember]
        public string? FilePath { get; set; }

        [DataMember]
        public string[]? CustomType { get; set; }
    }

    [DataContract]
    internal class Helper
    {
        [DataMember]
        public string? Database { get; set; }

        [DataMember]
        public string? Namespace { get; set; }

        [DataMember]
        public string? XLST { get; set; }

        [DataMember]
        public string? OutputFilePath { get; set; }
    }

    [DataContract]
    internal class Wrapper
    {
        [DataMember]
        public string? Database { get; set; }

        [DataMember]
        public string? Namespace { get; set; }

        [DataMember]
        public string? XLST { get; set; }

        [DataMember]
        public string? Path { get; set; }

        [DataMember]
        public string? FilePattern { get; set; }

    }

    [DataContract]
    internal class SQLWrapperConfig
    {
        [DataMember]
        public bool Verbose { get; set; } = false;

        [DataMember]
        public List<Database>? Database { get; set; }

        [DataMember]
        public List<Helper>? Helper { get; set; }

        [DataMember]
        public List<Wrapper>? Wrapper { get; set; }

    }
}
