<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:param name="namespace"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<xsl:template match="column">
        public const int <xsl:value-of select="@name"/>Length = <xsl:value-of select="substring(@type, 9, string-length(@type)-9)"/>;</xsl:template>

<xsl:template match="table">
<xsl:if test="count(column[starts-with(@type, 'varchar')]) > 0">  
    public partial class <xsl:value-of select="@name"/>
    {<xsl:apply-templates select="column[starts-with(@type, 'varchar')]"/>
    }
</xsl:if>
</xsl:template>
  
<xsl:template match="/">
namespace <xsl:value-of select="$namespace"/>
{
<xsl:apply-templates select="sqlwrapper/database/table"/>
} 
</xsl:template>
</xsl:stylesheet>
