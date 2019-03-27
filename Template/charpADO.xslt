<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<xsl:template match="type">
  <xsl:if test="contains(., 'unsigned')">u</xsl:if>
  <xsl:choose>
    <xsl:when test=". = 'bit(1)'">bool<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'tinyint(')">byte<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'smallint(')">short<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'mediumint(')">int<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'int(')">int<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'bigint(')">long<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'decimal(')">double<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
    <xsl:when test="starts-with(., 'varchar(')">string</xsl:when>
    <xsl:when test="starts-with(., 'text')">string</xsl:when>
    <xsl:when test="starts-with(., 'timestamp')">DateTime<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>

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
using System;
using System.Data;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace <xsl:value-of select="sqlwrapper/config/namespace"/>
{
    public partial class <xsl:value-of select="sqlwrapper/config/class"/>
    {
<!-- Return only one value -->
<xsl:if test="count(sqlwrapper/output) = 1 and sqlwrapper/config/ismultipleresult = 'false'">
        public static Task&lt;<xsl:apply-templates select="sqlwrapper/output/type"/>&gt; <xsl:value-of select="sqlwrapper/config/method"/>(IDbConnection conn, IDbTransaction transaction<xsl:apply-templates select="sqlwrapper/input"/>)
        {
            return conn.ExecuteScalarAsync&lt;<xsl:apply-templates select="sqlwrapper/output/type"/>&gt;(@"<xsl:value-of select="sqlwrapper/config/sql"/>"<xsl:if test="sqlwrapper/input">, new { <xsl:apply-templates select="sqlwrapper/input" mode="dapperparam"/> }</xsl:if>, transaction: transaction);
        }
</xsl:if>
  
<!-- Return multiple columns -->  
<xsl:if test="count(sqlwrapper/output) > 1">
        public class <xsl:value-of select="sqlwrapper/config/method"/>Result
        {
<xsl:apply-templates select="sqlwrapper/output"/>        }

<!-- Return multiple columns and one row -->
<xsl:if test="sqlwrapper/config/ismultipleresult = 'false'">
        public static Task&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt; <xsl:value-of select="sqlwrapper/config/method"/>(IDbConnection conn, IDbTransaction transaction<xsl:apply-templates select="sqlwrapper/input"/>)
        {
            return conn.QuerySingleOrDefaultAsync&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt;(@"<xsl:value-of select="sqlwrapper/config/sql"/>"<xsl:if test="sqlwrapper/input">, new { <xsl:apply-templates select="sqlwrapper/input" mode="dapperparam"/> }</xsl:if>, transaction: transaction);
        }
</xsl:if>
  <!-- Return multiple columns and multiple rows -->
<xsl:if test="sqlwrapper/config/ismultipleresult = 'true'">
        public static Task&lt;IEnumerable&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt;&gt; <xsl:value-of select="sqlwrapper/config/method"/>(IDbConnection conn, IDbTransaction transaction<xsl:apply-templates select="sqlwrapper/input"/>)
        {
            return conn.QueryAsync&lt;<xsl:value-of select="sqlwrapper/config/method"/>Result&gt;(@"<xsl:value-of select="sqlwrapper/config/sql"/>"<xsl:if test="sqlwrapper/input">, new { <xsl:apply-templates select="sqlwrapper/input" mode="dapperparam"/> }</xsl:if>, transaction: transaction);
        }
</xsl:if>
</xsl:if>
    }
  
} 

</xsl:template>

</xsl:stylesheet>
