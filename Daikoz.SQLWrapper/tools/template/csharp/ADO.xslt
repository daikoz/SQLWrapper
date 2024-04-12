<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:param name="namespace"/>
<xsl:param name="classname"/>
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:preserve-space elements="*" />

<xsl:template match="type" mode="typeonly">
  <xsl:choose>
    <xsl:when test="@custom">
      <xsl:value-of select="@custom"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(@unsigned = 1)">
        <xsl:choose>
          <xsl:when test=". = 'bigint'">long</xsl:when>
          <xsl:when test=". = 'binary'">byte[]</xsl:when>
          <xsl:when test=". = 'bit'">ulong</xsl:when>
          <xsl:when test=". = 'blob'">byte[]</xsl:when>
          <xsl:when test=". = 'bool'">bool</xsl:when>
          <xsl:when test=". = 'char'">string</xsl:when>
          <xsl:when test=". = 'date'">DateTime</xsl:when>
          <xsl:when test=". = 'datetime'">DateTime</xsl:when>
          <xsl:when test=". = 'decimal'">decimal</xsl:when>
          <xsl:when test=". = 'double'">double</xsl:when>
          <xsl:when test=". = 'enum'">string</xsl:when>
          <xsl:when test=". = 'float'">float</xsl:when>
          <xsl:when test=". = 'int'">int</xsl:when>
          <xsl:when test=". = 'longblob'">byte[]</xsl:when>
          <xsl:when test=". = 'longtext'">string</xsl:when>
          <xsl:when test=". = 'mediumblob'">byte[]</xsl:when>
          <xsl:when test=". = 'mediumint'">int</xsl:when>
          <xsl:when test=". = 'mediumtext'">string</xsl:when>
          <xsl:when test=". = 'set'">string</xsl:when>
          <xsl:when test=". = 'smallint'">short</xsl:when>
          <xsl:when test=". = 'text'">string</xsl:when>
          <xsl:when test=". = 'time'">TimeSpan</xsl:when>
          <xsl:when test=". = 'timestamp'">DateTime</xsl:when>
          <xsl:when test=". = 'tinyblob'">byte[]</xsl:when>
          <xsl:when test=". = 'tinyint'">sbyte</xsl:when>
          <xsl:when test=". = 'tinytext'">string</xsl:when>
          <xsl:when test=". = 'varbinary'">byte[]</xsl:when>
          <xsl:when test=". = 'varchar'">string</xsl:when>
          <xsl:when test=". = 'year'">int</xsl:when>
          <xsl:otherwise><xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="@unsigned = 1">
        <xsl:choose>
          <xsl:when test=". = 'bigint'">ulong</xsl:when>
          <xsl:when test=". = 'int'">uint</xsl:when>
          <xsl:when test=". = 'mediumint'">uint</xsl:when>
          <xsl:when test=". = 'smallint'">ushort</xsl:when>
          <xsl:when test=". = 'tinyint'">byte</xsl:when>
          <xsl:otherwise><xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@isnull = 1">?</xsl:if>
</xsl:template>
  
<xsl:template match="type" mode="input">
  <xsl:if test="@array = 1">IEnumerable&lt;</xsl:if>
  <xsl:apply-templates select="." mode="typeonly"/>
  <xsl:if test="@array = 1">&gt;</xsl:if>
  <xsl:if test="@array = 1 and . = 'char'">ERROR_SQL_INJECTION</xsl:if>
</xsl:template>

<xsl:template match="type">
  <xsl:apply-templates select="." mode="typeonly"/>
  <xsl:if test="@array = 1">[]</xsl:if>
  <xsl:if test="@array = 1 and . = 'char'">ERROR_SQL_INJECTION</xsl:if>
</xsl:template>

<xsl:template match="query" mode="outputassign">
  <xsl:for-each select="output">
    <xsl:variable name="returntype">
      <xsl:apply-templates select="type"/>  
    </xsl:variable>
<xsl:choose>
<xsl:when test="type[@isnull = 1]">
<xsl:if test="not(type[@custom])">  
  <xsl:text>                            </xsl:text><xsl:value-of select="name"/> = reader[<xsl:value-of select="position()-1" />] == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />],
</xsl:if>
<xsl:if test="type[@custom]">
  <xsl:text>                            </xsl:text><xsl:value-of select="name"/> = reader[<xsl:value-of select="position()-1" />] == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)(typeof(<xsl:value-of select="type/@custom"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="type/@custom"/>), reader[<xsl:value-of select="position()-1" />]) : Convert.ChangeType(reader[<xsl:value-of select="position()-1" />], typeof(<xsl:value-of select="type/@custom"/>), System.Globalization.CultureInfo.InvariantCulture)),
</xsl:if>  
</xsl:when>
<xsl:otherwise>
<xsl:if test="not(type[@custom])">
  <xsl:text>                            </xsl:text><xsl:value-of select="name"/> = (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />],
</xsl:if>
<xsl:if test="type[@custom]">
  <xsl:text>                            </xsl:text><xsl:value-of select="name"/> = (<xsl:apply-templates select="type"/>)(typeof(<xsl:value-of select="type/@custom"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="type/@custom"/>), reader[<xsl:value-of select="position()-1" />]) : Convert.ChangeType(reader[<xsl:value-of select="position()-1" />], typeof(<xsl:value-of select="type/@custom"/>), System.Globalization.CultureInfo.InvariantCulture)),
</xsl:if>
</xsl:otherwise>
</xsl:choose>
  </xsl:for-each>
</xsl:template>
  
<xsl:template match="query" mode="outputconvert">
  <xsl:for-each select="output">
    <xsl:variable name="returntype">
      <xsl:apply-templates select="type"/>  
    </xsl:variable>
<xsl:choose>
<xsl:when test="type[@isnull = 1]">reader[<xsl:value-of select="position()-1" />] == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />]</xsl:when>
<xsl:otherwise>(<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />]</xsl:otherwise>
</xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="output">            public <xsl:apply-templates select="./type"/><xsl:text> </xsl:text><xsl:value-of select="name"/> { get; set; } = default!;
</xsl:template>

<xsl:template match="input">, <xsl:apply-templates select="./type" mode="input"/><xsl:text> </xsl:text><xsl:value-of select="name"/></xsl:template>

<xsl:template match="query" mode="returntype">
  <xsl:variable name="name" select="../name"/>
  <xsl:variable name="nboutput" select="count(output)"/>
  <xsl:variable name="nboutputmultiple" select="@multiplerows = 1"/>
  <xsl:if test="position() != 1">, </xsl:if>
  <xsl:if test="$nboutput = 1 and $nboutputmultiple = 0"><xsl:apply-templates select="output/type"/></xsl:if>
  <xsl:if test="$nboutput > 1 and $nboutputmultiple = 0"><xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /></xsl:if>
  <xsl:if test="$nboutputmultiple = 1">List&lt;<xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />&gt;</xsl:if>
</xsl:template>

<xsl:template match="query" mode="initresult">
            <xsl:variable name="name" select="../name"/>
            <xsl:variable name="nboutput" select="count(output)"/>
            <xsl:variable name="nboutputmultiple" select="@multiplerows = 1"/>
            <xsl:if test="$nboutput = 1 and $nboutputmultiple = 0"><xsl:apply-templates select="output/type"/> result<xsl:value-of select="position()" /> = default;
            </xsl:if>
            <xsl:if test="$nboutput > 1 and $nboutputmultiple = 0"><xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /> result<xsl:value-of select="position()" /> = new <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />();
            </xsl:if>
            <xsl:if test="$nboutputmultiple = 1">List&lt;<xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />&gt; result<xsl:value-of select="position()" /> = new List&lt;<xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />&gt;();
            </xsl:if>
</xsl:template>

<xsl:template match="query" mode="getresult">
    <xsl:variable name="nboutput" select="count(output)"/>
    <xsl:variable name="returntype">
      <xsl:apply-templates select="output/type"/>
    </xsl:variable> 
                    // <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />
    <xsl:if test="position() != 1">
                    if(!await reader.NextResultAsync())
                        throw new InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> invalid number of result");
    </xsl:if>
   <!-- Return only one value -->
   <xsl:if test="$nboutput = 1 and @multiplerows = 0">
                    if(!await reader.ReadAsync())
                        throw new InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> return no row");
      <xsl:if test="output/type[@isnull = 0]">
          <xsl:if test="not(output/type[@custom])">
                    result<xsl:value-of select="position()" /> = (<xsl:value-of select="$returntype"/>)reader[0];
          </xsl:if>
          <xsl:if test="output/type[@custom]">
                    result<xsl:value-of select="position()" /> = (<xsl:value-of select="$returntype"/>)Convert.ChangeType(reader[0], typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);
          </xsl:if>
      </xsl:if>
      <xsl:if test="output/type[@isnull = 1]">
          <xsl:if test="not(output/type[@custom])">
                    result<xsl:value-of select="position()" /> = reader[0] == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)reader[0];
          </xsl:if>
          <xsl:if test="output/type[@custom]">
                    result<xsl:value-of select="position()" /> = reader[0] == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)Convert.ChangeType(reader[0], typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);
          </xsl:if>
      </xsl:if>
    </xsl:if>

    <!-- Return one multiple columns -->
    <xsl:if test="$nboutput > 1 and @multiplerows = 0">
                    if(!await reader.ReadAsync())
                        throw new InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> return no row");

                    result<xsl:value-of select="position()" /> = new <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />
                    {
<xsl:apply-templates select="." mode="outputassign"/>
                    };
    </xsl:if>

    <!-- Return several row of one column -->
    <xsl:if test="$nboutput = 1 and @multiplerows = 1">
                    while (reader.Read())
                        result<xsl:value-of select="position()" />.Add(<xsl:apply-templates select="." mode="outputconvert"/>);
    </xsl:if>

    <!-- Return several row multiple columns -->
    <xsl:if test="$nboutput > 1 and @multiplerows = 1">
                    while (reader.Read())
                        result<xsl:value-of select="position()" />.Add(new <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />
                        {
<xsl:apply-templates select="." mode="outputassign"/>
                        });
    </xsl:if>    

</xsl:template>

<xsl:template match="sql">
<xsl:variable name="nboutput" select="count(query[@ignore = 0]/output)"/>
<xsl:variable name="nboutputmultiple" select="count(query[@ignore = 0 and @multiplerows = 1])"/>
<xsl:variable name="nbquery" select="count(query[@ignore = 0])"/>

<!-- Non Query Insert Delete Update -->
<xsl:if test="$nboutput = 0">
        public static async Task&lt;int&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>
            return await sqlCmd.ExecuteNonQueryAsync();
        }
</xsl:if>
  
<!-- Return only one value -->
<xsl:if test="$nboutput = 1 and $nboutputmultiple = 0">
<xsl:variable name="returntype">
  <xsl:apply-templates select="query[@ignore = 0]/output/type"/>
</xsl:variable>
        public static async Task&lt;<xsl:value-of select="$returntype"/>&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>, bool returnDefault = false)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
<xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">            sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
</xsl:if></xsl:for-each>
            object? result = await sqlCmd.ExecuteScalarAsync();
            if (result != null)
                <xsl:if test="query[@ignore = 0]/output/type[@isnull = 0]">
                    <xsl:if test="not(query[@ignore = 0]/output/type[@custom]) and not(query[@ignore = 0]/output/type[@lastinsertid = 1])">return (<xsl:value-of select="$returntype"/>)result;</xsl:if>
                    <xsl:if test="query[@ignore = 0]/output/type[@custom]">return (<xsl:value-of select="$returntype"/>)(typeof(<xsl:value-of select="$returntype"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="$returntype"/>), result) : Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture));</xsl:if>
                    <xsl:if test="query[@ignore = 0]/output/type[@lastinsertid = 1]">return (<xsl:value-of select="$returntype"/>)Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);</xsl:if>
                </xsl:if>
                <xsl:if test="query[@ignore = 0]/output/type[@isnull = 1]">
                    <xsl:if test="not(query[@ignore = 0]/output/type[@custom])">return result == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)result;</xsl:if>
                    <xsl:if test="query[@ignore = 0]/output/type[@custom]">return result == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)(typeof(<xsl:value-of select="$returntype"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="$returntype"/>), result) : Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture));</xsl:if>
                </xsl:if>
            if (!returnDefault)
                throw new InvalidOperationException("<xsl:value-of select="name"/> return no row");
            return default!;
        }
</xsl:if>

<!-- Return one multiple columns -->
<xsl:if test="$nboutput > 1 and $nboutputmultiple = 0 and $nbquery = 1">
        public class <xsl:value-of select="name"/>Result
        {
<xsl:apply-templates select="query/output"/>        }
  
        public static async Task&lt;<xsl:value-of select="name"/>Result?&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>

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
  <xsl:variable name="returntype">
    <xsl:apply-templates select="query[@ignore = 0]/output/type"/>
  </xsl:variable>
        public static async Task&lt;List&lt;<xsl:value-of select="$returntype"/>&gt;&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>
            List&lt;<xsl:value-of select="$returntype"/>&gt; listResult = new List&lt;<xsl:value-of select="$returntype"/>&gt;();
            using (DbDataReader reader = await sqlCmd.ExecuteReaderAsync())
                if (reader != null)
                    while (reader.Read())
                        listResult.Add(<xsl:apply-templates select="query" mode="outputconvert"/>);

            return listResult;
        }
</xsl:if>
  
<!-- Return several row multiple columns -->
<xsl:if test="$nboutput > 1 and $nboutputmultiple = 1 and $nbquery = 1">
        public class <xsl:value-of select="name"/>Result
        {
<xsl:apply-templates select="query/output"/>        }
  
        public static async Task&lt;List&lt;<xsl:value-of select="name"/>Result&gt;&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>

            List&lt;<xsl:value-of select="name"/>Result&gt; listResult = new List&lt;<xsl:value-of select="name"/>Result&gt;();
            using (DbDataReader reader = await sqlCmd.ExecuteReaderAsync())
                if (reader != null)
                    while (reader.Read())
                        listResult.Add(new <xsl:value-of select="name"/>Result
                        {
<xsl:apply-templates select="query" mode="outputassign"/>
                        });

            return listResult;
        }
</xsl:if>

<!-- Return several queries -->
<xsl:if test="$nboutput > 1 and $nbquery > 1">
<xsl:variable name="name" select="name"/>
<xsl:for-each select="query[@ignore = 0]">
  <xsl:if test="count(output) > 1">
        public class <xsl:value-of select="$name"/>ResultQuery<xsl:value-of select="position()" />
        {
<xsl:apply-templates select="output"/>        }
  </xsl:if>
</xsl:for-each>
        public static async Task&lt;(<xsl:apply-templates select="query[@ignore = 0]" mode="returntype"/>)&gt; <xsl:value-of select="name"/>(MySqlConnection conn, MySqlTransaction transaction<xsl:apply-templates select="query/input"/>)
        {
            using MySqlCommand sqlCmd = new MySqlCommand
            {
                Connection = conn,
                Transaction = transaction,
                CommandText = @"<xsl:value-of select="text"/>"<xsl:for-each select="query/input/type[@array = 1]">.Replace("(@<xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/>)) : "(NULL)", StringComparison.Ordinal)</xsl:for-each>
            };
            <xsl:for-each select="query/input"><xsl:if test="type[@array != 1]">sqlCmd.Parameters.AddWithValue("@<xsl:value-of select="name"/>", <xsl:value-of select="name"/>);
            </xsl:if></xsl:for-each>
            <xsl:text>
            </xsl:text>
            <xsl:apply-templates select="query[@ignore = 0]" mode="initresult"/>
            using (DbDataReader reader = await sqlCmd.ExecuteReaderAsync())
                if (reader != null)
                {
                    <xsl:apply-templates select="query[@ignore = 0]" mode="getresult"/>
                }

            return (<xsl:for-each select="query[@ignore = 0]"><xsl:if test="position() != 1">, </xsl:if>result<xsl:value-of select="position()" /></xsl:for-each>);
        }
  
</xsl:if>
  
</xsl:template>

<xsl:template match="/">using MySqlConnector;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
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
