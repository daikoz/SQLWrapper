<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:param name="namespace"/>
<xsl:param name="database"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />


<!-- COLUMN -->
<xsl:template match="column">
        public const int <xsl:value-of select="@name"/>Length = <xsl:value-of select="@length"/>;</xsl:template>


<!-- TABLE -->
<xsl:template match="table">
<xsl:if test="count(column[@length]) > 0">
    public partial class <xsl:value-of select="@name"/>
    {<xsl:apply-templates select="column[@length]"/>
    }
</xsl:if>
</xsl:template>


<!-- ROOT -->
<xsl:template match="/">
namespace <xsl:value-of select="$namespace"/>
{
<xsl:apply-templates select="sqlwrapper/database[@name = $database or $database = '']/table"/>
}
</xsl:template>
</xsl:stylesheet>
