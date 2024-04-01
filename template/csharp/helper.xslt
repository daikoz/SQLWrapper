<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:param name="namespace"/>
<xsl:param name="database"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<!-- UpdateIfModified -->
<xsl:template match="column" mode="UpdateIfModified_Column"><xsl:if test="position() != 1">, </xsl:if>"<xsl:value-of select="@name" />"</xsl:template>

<xsl:template match="table" mode="UpdateIfModified">
  <xsl:if test="count(column[@key = 'primarykey']) > 0 and count(column[@key != 'primarykey' or not(@key)]) > 0">
    
        public static async Task&lt;int&gt; UpdateIfModified(MySqlConnection conn, MySqlTransaction transaction, object objToUpdate, object data)
        {
            return await Daikoz.SQLWrapper.UpdateIfModified(conn, transaction, objToUpdate, data, "<xsl:value-of select="@name"/>", new string[] { <xsl:apply-templates select="column[@key != 'primarykey' or not(@key)]" mode="UpdateIfModified_Column" /> }, new string[] { <xsl:apply-templates select="column[@key = 'primarykey']" mode="UpdateIfModified_Column" /> });
        }    
  </xsl:if>
</xsl:template>
	
<!-- COLUMN NAME-->
<xsl:template match="column" mode="ColumnName"><xsl:if test="@name = ../@name">_</xsl:if><xsl:value-of select="translate(@name,' ','_')"/></xsl:template>
	
<!-- COLUMN -->
<xsl:template match="column" mode="TypeLength">
        public const uint <xsl:apply-templates select="." mode="ColumnName"/>Length = <xsl:value-of select="@length"/>;</xsl:template>

<!-- PROPERTIES -->
<xsl:template match="column" mode="Properties">
        public <xsl:apply-templates select="." mode="typeonly"/><xsl:text> </xsl:text><xsl:apply-templates select="." mode="ColumnName"/> { get; set; } = default!;</xsl:template>
  
<xsl:template match="column" mode="typeonly">
  <xsl:choose>
    <xsl:when test="@custom">
      <xsl:value-of select="@custom"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(@unsigned = 1)">
        <xsl:choose>
          <xsl:when test="@type = 'bigint'">long</xsl:when>
          <xsl:when test="@type = 'binary'">byte[]</xsl:when>       
          <xsl:when test="@type = 'bit'">ulong</xsl:when>      
          <xsl:when test="@type = 'blob'">byte[]</xsl:when>
          <xsl:when test="@type = 'bool'">bool</xsl:when>
          <xsl:when test="@type = 'char'">string</xsl:when>        
          <xsl:when test="@type = 'date'">DateTime</xsl:when>       
          <xsl:when test="@type = 'datetime'">DateTime</xsl:when>       
          <xsl:when test="@type = 'decimal'">decimal</xsl:when>      
          <xsl:when test="@type = 'double'">double</xsl:when>      
          <xsl:when test="@type = 'enum'">string</xsl:when>   
          <xsl:when test="@type = 'float'">float</xsl:when>      
          <xsl:when test="@type = 'int'">int</xsl:when>
          <xsl:when test="@type = 'longblob'">byte[]</xsl:when>
          <xsl:when test="@type = 'longtext'">string</xsl:when>
          <xsl:when test="@type = 'mediumblob'">byte[]</xsl:when>      
          <xsl:when test="@type = 'mediumint'">int</xsl:when>
          <xsl:when test="@type = 'mediumtext'">string</xsl:when>
          <xsl:when test="@type = 'set'">string</xsl:when>
          <xsl:when test="@type = 'smallint'">short</xsl:when>
          <xsl:when test="@type = 'text'">string</xsl:when>
          <xsl:when test="@type = 'time'">TimeSpan</xsl:when>
          <xsl:when test="@type = 'timestamp'">DateTime</xsl:when>
          <xsl:when test="@type = 'tinyblob'">byte[]</xsl:when>
          <xsl:when test="@type = 'tinyint'">sbyte</xsl:when>
          <xsl:when test="@type = 'tinytext'">string</xsl:when>
          <xsl:when test="@type = 'varbinary'">byte[]</xsl:when>
          <xsl:when test="@type = 'varchar'">string</xsl:when>
		  <xsl:when test="@type = 'year'">int</xsl:when>
          <xsl:otherwise><xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="@unsigned = 1">
        <xsl:choose>
          <xsl:when test="@type = 'bigint'">ulong</xsl:when>      
          <xsl:when test="@type = 'int'">uint</xsl:when>
          <xsl:when test="@type = 'mediumint'">uint</xsl:when>
          <xsl:when test="@type = 'smallint'">ushort</xsl:when>
          <xsl:when test="@type = 'tinyint'">byte</xsl:when>
          <xsl:otherwise><xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@nullable = 1">?</xsl:if>	
</xsl:template>

<!-- TABLE -->
<xsl:template match="table">
    public partial class <xsl:value-of select="@name"/>
    {<xsl:apply-templates select="column[@length]" mode="TypeLength"/>
<xsl:text> 
</xsl:text>
    <xsl:apply-templates select="column" mode="Properties"/>
    <xsl:apply-templates select="." mode="UpdateIfModified"/>
    }
</xsl:template>


<!-- ROOT -->
<xsl:template match="/">
using MySqlConnector;
using System;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Daikoz
{
    static internal class SQLWrapper
    {
        internal static async Task&lt;int&gt; UpdateIfModified(MySqlConnection conn, MySqlTransaction transaction, object objToUpdate, object data, string tableName, string[] listColumnName, string[] listColumnPrimaryName)
        {
            if (objToUpdate == null)
                throw new ArgumentNullException(nameof(objToUpdate));
            if (data == null)
                throw new ArgumentNullException(nameof(data));

            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
            };

            Type typeDate = data.GetType();
            Type typeObjToUpdate = objToUpdate.GetType();

            bool hasValueModified = false;
            StringBuilder strQuery = new StringBuilder("UPDATE " + tableName + " SET");
            foreach (string colName in listColumnName)
            {
                PropertyInfo? propertyInfoData = typeObjToUpdate.GetProperty(colName);
                if (propertyInfoData != null)
                {
                    PropertyInfo? propertyInfoObjToUpdate = typeObjToUpdate.GetProperty(colName);
                    if (propertyInfoObjToUpdate != null)
                    {
                        object? oldValue = propertyInfoObjToUpdate.GetValue(objToUpdate);
                        object? newValue = propertyInfoData.GetValue(data);
                        if ((oldValue == null &amp;&amp; newValue != null) || (oldValue != null &amp;&amp; !oldValue.Equals(newValue)))
                        {
                            if (hasValueModified)
                                strQuery.Append(", " + colName + " = @" + colName);
                            else
                                strQuery.Append(" " + colName + " = @" + colName);
                            sqlCmd.Parameters.AddWithValue(colName, newValue);
                            hasValueModified = true;
                        }
                    }
                }
            }

            if (!hasValueModified)
                return 0;

            bool isFirst = true;
            foreach (string colNamePrimary in listColumnPrimaryName)
            {
                if (isFirst)
                    strQuery.Append(" WHERE " + colNamePrimary + " = @" + colNamePrimary);
                else
                    strQuery.Append(" AND " + colNamePrimary + " = @" + colNamePrimary);
                PropertyInfo? propertyInfo = typeObjToUpdate.GetProperty(colNamePrimary);
                if (propertyInfo == null)
                    throw new ArgumentException("UpdateIfModified: objToUpdate doesn't contain primary key " + colNamePrimary);
                sqlCmd.Parameters.AddWithValue(colNamePrimary, propertyInfo.GetValue(objToUpdate));
                isFirst = false;
            }
            strQuery.Append(';');

            sqlCmd.CommandText = strQuery.ToString();

            return await sqlCmd.ExecuteNonQueryAsync();
        }
    }
}
  
namespace <xsl:value-of select="$namespace"/>
{
<xsl:apply-templates select="sqlwrapper/database[@name = $database or $database = '']/table"/>
}
</xsl:template>
</xsl:stylesheet>
