using System.Runtime.Serialization;

namespace Daikoz.SQLWrapper
{
    [DataContract]
    internal struct SQLWrapperConfig
    {
        [DataMember]
        public string[] RelativePath { get; set; }

        [DataMember]
        public string FilePattern { get; set; }

        [DataMember]
        public string Namespace { get; set; }

        [DataMember]
        public string[] ConnectionStrings { get; set; }

        [DataMember]
        public string SQLWrapperPath { get; set; }

        [DataMember]
        public string[] CustomTypes { get; set; }

        [DataMember]
        public string HelperRelativePath { get; set; }
    }
}
