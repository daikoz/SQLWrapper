<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:param name="namespace"/>
<xsl:param name="classname"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<xsl:template match="type">
  <xsl:if test="contains(., 'unsigned')">
    <xsl:choose>
      <xsl:when test=". = 'bit(1)'">bool<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'tinyint(')">byte<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'smallint(')">ushort<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'mediumint(')">uint<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'int(')">uint<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'bigint(')">ulong<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/><xsl:if test="@isnull = 1">?</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="not(contains(., 'unsigned'))">
    <xsl:choose>
      <xsl:when test=". = 'bit(1)'">bool<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'char(1)')">char<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>      
      <xsl:when test="starts-with(., 'char(')">string<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>      
      <xsl:when test="starts-with(., 'tinyint(')">sbyte<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'smallint(')">short<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'mediumint(')">int<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'int(')">int<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'bigint(')">long<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'decimal(')">decimal<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:when test="starts-with(., 'varchar(')">string</xsl:when>
      <xsl:when test="starts-with(., 'text')">string</xsl:when>
      <xsl:when test="starts-with(., 'timestamp')">DateTime<xsl:if test="@isnull = 1">?</xsl:if></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/><xsl:if test="@isnull = 1">?</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <xsl:if test="@array = 1">[]</xsl:if>
  <xsl:if test="@array = 1 and starts-with(., 'char(')">ERROR_SQL_INJECTION</xsl:if>
</xsl:template>

<xsl:template match="query" mode="outputassign">
                    <xsl:for-each select="output">
                      <xsl:variable name="returntype">
                        <xsl:apply-templates select="type"/>
                      </xsl:variable>
                      <xsl:choose>
                        <xsl:when test="$returntype = 'bool'">
                          <xsl:value-of select="name"/> = (ulong) reader[<xsl:value-of select="position()-1" />] == 1,
                        </xsl:when>
                        <xsl:when test="$returntype = 'char'">
                          <xsl:value-of select="name"/> = ((string)reader[<xsl:value-of select="position()-1" />])[0],
                        </xsl:when>
                        <xsl:when test="$returntype = 'char?'">
                          <xsl:value-of select="name"/> = reader[<xsl:value-of select="position()-1" />] == DBNull.Value ? (char?) null :((string)reader[<xsl:value-of select="position()-1" />])[0],
                        </xsl:when>
                        <xsl:when test="$returntype = 'string' or contains($returntype, '?')">
                          <xsl:value-of select="name"/> = reader[<xsl:value-of select="position()-1" />] == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />],
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="name"/> = (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />],
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
</xsl:template>

<xsl:template match="output">            public <xsl:apply-templates select="./type"/><xsl:text> </xsl:text><xsl:value-of select="name"/> { get; set; }
</xsl:template>
<xsl:template match="input">, <xsl:apply-templates select="./type"/><xsl:text> </xsl:text><xsl:value-of select="name"/></xsl:template>

<xsl:template match="sql">
<xsl:variable name="nboutput" select="count(query[ignoreoutput='false']/output)"/>
<xsl:variable name="nboutputmultiple" select="count(query[ignoreoutput='false' and multipleoutput='true'])"/>
  
<!-- Non Query Insert Delete Update -->
<xsl:if test="$nboutput = 0">
        public static async Task&lt;int&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("@<xsl:value-of select="../name"/>", String.Join(",", <xsl:value-of select="../name"/>))</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>
            if (conn.State != System.Data.ConnectionState.Open)
                await conn.OpenAsync();
            
            return await sqlCmd.ExecuteNonQueryAsync();
        }
</xsl:if>
  
<!-- Return only one value -->
<xsl:if test="$nboutput = 1 and $nboutputmultiple = 0">
<xsl:variable name="returntype">
  <xsl:apply-templates select="query[ignoreoutput='false']/output/type"/>
</xsl:variable>
        public static async Task&lt;<xsl:value-of select="$returntype"/>&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("@<xsl:value-of select="../name"/>", String.Join(",", <xsl:value-of select="../name"/>))</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>

            if (conn.State != System.Data.ConnectionState.Open)
                await conn.OpenAsync();
            
            Object result = await sqlCmd.ExecuteScalarAsync();
            if (result != null)
                return (<xsl:value-of select="$returntype"/>)result;
            return default;
        }
</xsl:if>

<!-- Return one multiple columns -->
<xsl:if test="$nboutput > 1 and $nboutputmultiple = 0">
        public class <xsl:value-of select="name"/>Result
        {
<xsl:apply-templates select="query/output"/>        }
  
        public static async Task&lt;<xsl:value-of select="name"/>Result&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("@<xsl:value-of select="../name"/>", String.Join(",", <xsl:value-of select="../name"/>))</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>

            if (conn.State != System.Data.ConnectionState.Open)
                await conn.OpenAsync();
                
            using (DbDataReader reader = await sqlCmd.ExecuteReaderAsync())
                if (reader != null &amp;&amp; reader.Read())
                    return new <xsl:value-of select="name"/>Result
                    {
                        <xsl:apply-templates select="query" mode="outputassign"/>
                    };

            return null;
        }
</xsl:if>
  
<!-- Return several row of one column -->
<xsl:if test="$nboutput = 1 and $nboutputmultiple = 1">
Return one multiple columns
</xsl:if>
  
<!-- Return several row multiple columns -->
<xsl:if test="$nboutput > 1 and $nboutputmultiple = 1">
        public class <xsl:value-of select="name"/>Result
        {
<xsl:apply-templates select="query/output"/>        }
  
        public static async Task&lt;List&lt;<xsl:value-of select="name"/>Result&gt;&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("@<xsl:value-of select="../name"/>", String.Join(",", <xsl:value-of select="../name"/>))</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>

            if (conn.State != System.Data.ConnectionState.Open)
                await conn.OpenAsync();
            
            List&lt;<xsl:value-of select="name"/>Result&gt; listResult = new List&lt;<xsl:value-of select="name"/>Result&gt;();
            using (DbDataReader reader = await sqlCmd.ExecuteReaderAsync())
                if (reader != null)
                    while(reader.Read())
                        listResult.Add(new <xsl:value-of select="name"/>Result
                        {
                            <xsl:apply-templates select="query" mode="outputassign"/>
                        });

            return listResult;
        }
</xsl:if>
  
</xsl:template>

<xsl:template match="/">using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Threading.Tasks;

namespace <xsl:value-of select="$namespace"/>
{
    public partial class <xsl:value-of select="$classname"/>
    {
<xsl:apply-templates select="sqlwrapper/sql"/>
    }
  
} 
</xsl:template>

</xsl:stylesheet>
