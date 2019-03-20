<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<xsl:template match="type">
  <xsl:choose>
    <xsl:when test="@isnull = 0 and . = 'bit(1)'">bool</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'tinyint(')">byte</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'smallint(')">short</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'smallint(')">int</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'bigint(')">long</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'decimal(')">double</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'varchar(')">string</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'text')">string</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'timestamp')">DateTime</xsl:when>

    <xsl:when test="@isnull = 1 and . = 'bit(1)'">bool?</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'tinyint(')">byte?</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'smallint(')">short?</xsl:when>
    <xsl:when test="@isnull = 0 and starts-with(., 'smallint(')">int?</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'bigint(')">long?</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'decimal(')">double?</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'varchar(')">string</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'text')">string</xsl:when>
    <xsl:when test="@isnull = 1 and starts-with(., 'timestamp')">DateTime?</xsl:when>

    <xsl:otherwise>TYPE_UNKNOWN_<xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="output">            public <xsl:apply-templates select="./type"/>&#160;<xsl:value-of select="name"/> { get; set; }
</xsl:template>
<xsl:template match="input">, <xsl:apply-templates select="./type"/>&#160;<xsl:value-of select="name"/></xsl:template>
<xsl:template match="sqlwrapper/input" mode="dapperparam">
  <xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="name"/>
</xsl:template>

<xsl:template match="/">using Dapper;
using System.Data;
using System.Threading.Tasks;

namespace <xsl:value-of select="sqlwrapper/config/namespace"/>
{
    public partial class <xsl:value-of select="sqlwrapper/config/class"/>
    {

        public class <xsl:value-of select="sqlwrapper/config/class"/>Result
        {
<xsl:apply-templates select="sqlwrapper/output"/>        }

<xsl:if test="sqlwrapper/config/ismultipleresult = 'false'">
        public static Task&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt; <xsl:value-of select="sqlwrapper/config/method"/>(IDbConnection conn, IDbTransaction transaction<xsl:apply-templates select="sqlwrapper/input"/>)
        {
            return conn.QuerySingleOrDefaultAsync&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt;(@"<xsl:value-of select="sqlwrapper/config/sql"/>"<xsl:if test="sqlwrapper/input">, new { <xsl:apply-templates select="sqlwrapper/input" mode="dapperparam"/> }</xsl:if>, transaction: transaction);
        }
</xsl:if>    
    }
  
} 

</xsl:template>

</xsl:stylesheet>
