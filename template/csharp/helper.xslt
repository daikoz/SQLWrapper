<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

	<xsl:param name="namespace"/>
	<xsl:param name="database"/>
	<xsl:param name="ind" select="'    '" />
	<xsl:param name="LB" select="'&#xD;&#xA;'" />

	<xsl:output method="text" omit-xml-declaration="yes" encoding="utf-8" />

	<!-- Identation Template -->
	<xsl:variable name="ind2">
		<xsl:value-of select="$ind"/>
		<xsl:value-of select="$ind"/>
	</xsl:variable>
	<xsl:variable name="ind3">
		<xsl:value-of select="$ind2"/>
		<xsl:value-of select="$ind"/>
	</xsl:variable>
	<xsl:variable name="ind4">
		<xsl:value-of select="$ind3"/>
		<xsl:value-of select="$ind"/>
	</xsl:variable>
	<xsl:variable name="ind5">
		<xsl:value-of select="$ind4"/>
		<xsl:value-of select="$ind"/>
	</xsl:variable>

	<!-- UpdateIfModified -->
	<xsl:template match="column" mode="UpdateIfModified_Column">
		<xsl:if test="position() != 1">, </xsl:if>"<xsl:value-of select="@name" /><xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="table" mode="UpdateIfModified">
		<xsl:if test="count(column[@key = 'primarykey']) > 0 and count(column[@key != 'primarykey' or not(@key)]) > 0">
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />public static async Task&lt;int&gt; UpdateIfModified(DbConnection conn, DbTransaction transaction, object objToUpdate, object data)<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />{<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />return await <xsl:value-of select="$database" />Helper.UpdateIfModified(conn, transaction, objToUpdate, data, "<xsl:value-of select="@name"/>", [<xsl:apply-templates select="column[@key != 'primarykey' or not(@key)]" mode="UpdateIfModified_Column" />], [<xsl:apply-templates select="column[@key = 'primarykey']" mode="UpdateIfModified_Column" />]);<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />}<xsl:value-of select="$LB" />
		</xsl:if>
	</xsl:template>

	<!-- ID NAME-->
	<xsl:template match="database | table | column | routine" mode="IdName">
		<xsl:if test="@name = ../@name">_</xsl:if>
		<xsl:value-of select="translate(substring(@name, 1, 1), 'abcdefghijklmnopqrstuvwxyz ', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_')"/>
		<xsl:value-of select="translate(substring(@name, 2),' ','_')"/>
	</xsl:template>

	<!-- COLUMN -->
	<xsl:template match="column" mode="TypeLength">
		<xsl:value-of select="$ind2" />public const <xsl:choose>
			<xsl:when test="@length &lt;= 2147483647">int </xsl:when>
			<xsl:otherwise>long </xsl:otherwise>
		</xsl:choose> <xsl:apply-templates select="." mode="IdName"/>Length = <xsl:value-of select="@length"/>;<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PROPERTIES -->
	<xsl:template match="column" mode="Properties">
		<xsl:value-of select="$ind2" />public <xsl:apply-templates select="." mode="typeonly"/><xsl:text> </xsl:text><xsl:apply-templates select="." mode="IdName"/> { get; set; } = default!;<xsl:value-of select="$LB" />
	</xsl:template>

	<xsl:template match="column | parameter" mode="typeonly">
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
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
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
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@nullable = 1">?</xsl:if>
	</xsl:template>

	<!-- TABLE -->
	<xsl:template match="table">
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />public partial class <xsl:apply-templates select="." mode="IdName"/><xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />{<xsl:value-of select="$LB" />
		<xsl:apply-templates select="column[@length]" mode="TypeLength"/>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="column" mode="Properties"/>
		<xsl:apply-templates select="." mode="UpdateIfModified"/>
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />}<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PARAMETER CALL -->
	<xsl:template match="parameter" mode="call">
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />DbParameter param<xsl:value-of select="position()" /> = sqlCmd.CreateParameter();<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />param<xsl:value-of select="position()" />.ParameterName = "@<xsl:value-of select="@name"/>";<xsl:value-of select="$LB" />
		<xsl:if test="@mode != 'out' and @mode != 'return'">
			<xsl:value-of select="$ind3" />param<xsl:value-of select="position()" />.Value = <xsl:value-of select="@name"/>;<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'out'">
			<xsl:value-of select="$ind3" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.Output;<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'inout'">
			<xsl:value-of select="$ind3" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.InputOutput;<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'return'">
			<xsl:value-of select="$ind3" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.ReturnValue;<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:value-of select="$ind3" />sqlCmd.Parameters.Add(param<xsl:value-of select="position()" />);<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PARAMETER RESULT -->
	<xsl:template match="parameter" mode="result">
		<xsl:if test="@mode != 'in'">
			<xsl:value-of select="$ind3" /><xsl:value-of select="@name"/> = param<xsl:value-of select="position()" />.Value == DBNull.Value ? null : (<xsl:apply-templates select="." mode="typeonly"/>)param<xsl:value-of select="position()" />.Value;<xsl:value-of select="$LB" />
		</xsl:if>
	</xsl:template>

	<!-- PARAMETER FUNCTION -->
	<xsl:template match="parameter" mode="function">
		<xsl:text>, </xsl:text>
		<xsl:if test="@mode = 'out'">out </xsl:if>
		<xsl:if test="@mode = 'inout'">ref </xsl:if>
		<xsl:apply-templates select="." mode="typeonly"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>

	<!-- ROUTINE -->
	<xsl:template match="routine">
		<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
			<xsl:value-of select="$ind2" />
			<xsl:text>public static void</xsl:text>
		</xsl:if>
		<xsl:if test="not (parameter[@mode='out'] or parameter[@mode='ref'])">
			<xsl:value-of select="$ind2" />public static async <xsl:if test="not(parameter[@mode='return'])">Task</xsl:if>
		</xsl:if>
		<xsl:if test="parameter[@mode='return']">
			<xsl:text>Task&lt;</xsl:text>
			<xsl:apply-templates select="parameter[@mode='return']" mode="typeonly"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:if>
		<xsl:text> </xsl:text><xsl:apply-templates select="." mode="IdName"/>(DbConnection conn, DbTransaction transaction<xsl:apply-templates select="parameter[@mode!='return']" mode="function"/>)<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind2" />{<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />using DbCommand sqlCmd = conn.CreateCommand();<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />sqlCmd.Connection = conn;<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />sqlCmd.Transaction = transaction;<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />sqlCmd.CommandText = @"<xsl:value-of select="@name"/>";<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />sqlCmd.CommandType = System.Data.CommandType.StoredProcedure;<xsl:value-of select="$LB" />
		<xsl:apply-templates select="parameter" mode="call"/>
		<xsl:value-of select="$LB" />
		<xsl:if test="parameter[@mode = 'return']">
			<xsl:if test="not(parameter[@mode='out'] or parameter[@mode='ref'])">
				<xsl:value-of select="$ind3" />return (<xsl:apply-templates select="parameter[@mode = 'return']" mode="typeonly"/>)await sqlCmd.ExecuteScalarAsync();<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
				<xsl:value-of select="$ind3" />return (<xsl:apply-templates select="parameter[@mode = 'return']" mode="typeonly"/>)sqlCmd.ExecuteScalar();<xsl:value-of select="$LB" />
			</xsl:if>
		</xsl:if>
		<xsl:if test="not(parameter[@mode = 'return'])">
			<xsl:if test="not(parameter[@mode='out'] or parameter[@mode='ref'])">
				<xsl:value-of select="$ind3" />await sqlCmd.ExecuteNonQueryAsync();<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
				<xsl:value-of select="$ind3" />sqlCmd.ExecuteNonQuery();<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:value-of select="$LB" />
			<xsl:apply-templates select="parameter[@mode != 'return']" mode="result"/>
		</xsl:if>
		<xsl:value-of select="$ind2" />}<xsl:value-of select="$LB" />
		<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- DATABASE -->
	<xsl:template match="database">
		<xsl:text>using System;
using System.Data.Common;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace </xsl:text>
		<xsl:value-of select="$namespace"/>
		<xsl:text>
{
    static partial class </xsl:text>
		<xsl:apply-templates select="." mode="IdName"/>
		<xsl:text>Helper
    {
        internal static async Task&lt;int&gt; UpdateIfModified(DbConnection conn, DbTransaction transaction, object objToUpdate, object data, string tableName, string[] listColumnName, string[] listColumnPrimaryName)
        {
            ArgumentNullException.ThrowIfNull(objToUpdate);
            ArgumentNullException.ThrowIfNull(data);

            using DbCommand sqlCmd = conn.CreateCommand();
            sqlCmd.Connection = conn;
            sqlCmd.Transaction = transaction;

            Type typeDate = data.GetType();
            Type typeObjToUpdate = objToUpdate.GetType();

            bool hasValueModified = false;
            StringBuilder strQuery = new("UPDATE " + tableName + " SET");
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

                            DbParameter param = sqlCmd.CreateParameter();
                            param.ParameterName = colName;
                            param.Value = newValue;
                            sqlCmd.Parameters.Add(param);

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
                PropertyInfo propertyInfo = typeObjToUpdate.GetProperty(colNamePrimary) ?? throw new ArgumentException("UpdateIfModified: objToUpdate doesn't contain primary key " + colNamePrimary);

                DbParameter param = sqlCmd.CreateParameter();
                param.ParameterName = colNamePrimary;
                param.Value = propertyInfo.GetValue(objToUpdate);
                sqlCmd.Parameters.Add(param);

                isFirst = false;
            }
            strQuery.Append(';');

            sqlCmd.CommandText = strQuery.ToString();

            return await sqlCmd.ExecuteNonQueryAsync();
        }
</xsl:text>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="routine"/>
		<xsl:value-of select="$ind" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="table"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- ROOT -->
	<xsl:template match="/">
		<xsl:apply-templates select="sqlwrapper/database[@name = $database or $database = '']"/>
	</xsl:template>

</xsl:stylesheet>
