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

	<!-- Template Escapte String -->
	<xsl:template name="escape-string">
		<xsl:param name="input"/>
		<xsl:choose>
			<xsl:when test="contains($input, '&quot;')">
				<xsl:value-of select="substring-before($input, '&quot;')" />
				<xsl:text>""</xsl:text>
				<xsl:call-template name="escape-string">
					<xsl:with-param name="input" select="substring-after($input, '&quot;')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($input, '\')">
				<xsl:value-of select="substring-before($input, '\')" />
				<xsl:text>\\</xsl:text>
				<xsl:call-template name="escape-string">
					<xsl:with-param name="input" select="substring-after($input, '\')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- UpdateIfModified -->
	<xsl:template match="column" mode="UpdateIfModified_Column">
		<xsl:if test="position() != 1">, </xsl:if>"<xsl:value-of select="@name" /><xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="table" mode="UpdateIfModified">
		<xsl:if test="count(column[@key = 'primarykey']) > 0 and count(column[@key != 'primarykey' or not(@key)]) > 0">
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />Public Shared Async Function UpdateIfModified(conn As DbConnection, transaction As DbTransaction, objToUpdate As Object, data As Object) As Task(Of Integer)<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />Return Await <xsl:value-of select="$database" />Helper.UpdateIfModified(conn, transaction, objToUpdate, data, "<xsl:value-of select="@name"/>", {<xsl:apply-templates select="column[@key != 'primarykey' or not(@key)]" mode="UpdateIfModified_Column" />}, {<xsl:apply-templates select="column[@key = 'primarykey']" mode="UpdateIfModified_Column" />})<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
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
		<xsl:value-of select="$ind2" />Public Const <xsl:apply-templates select="." mode="IdName"/>Length As <xsl:choose>
			<xsl:when test="@length &lt;= 2147483647">Integer</xsl:when>
			<xsl:otherwise>Long</xsl:otherwise>
		</xsl:choose> = <xsl:value-of select="@length"/><xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PROPERTIES -->
	<xsl:template match="column" mode="Properties">
		<xsl:value-of select="$ind2" />Public Property [<xsl:apply-templates select="." mode="IdName"/>]() As <xsl:apply-templates select="." mode="typeonly"/><xsl:value-of select="$LB" />
	</xsl:template>

	<xsl:template match="column | parameter" mode="typeonly">
		<xsl:choose>
			<xsl:when test="@custom">
				<xsl:value-of select="@custom"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(@unsigned = 1)">
					<xsl:choose>
						<xsl:when test="@type = 'bigint'">Long</xsl:when>
						<xsl:when test="@type = 'binary'">Byte()</xsl:when>
						<xsl:when test="@type = 'bit'">ULong</xsl:when>
						<xsl:when test="@type = 'blob'">Byte()</xsl:when>
						<xsl:when test="@type = 'bool'">Boolean</xsl:when>
						<xsl:when test="@type = 'char'">String</xsl:when>
						<xsl:when test="@type = 'date'">Date</xsl:when>
						<xsl:when test="@type = 'datetime'">Date</xsl:when>
						<xsl:when test="@type = 'decimal'">Decimal</xsl:when>
						<xsl:when test="@type = 'double'">Double</xsl:when>
						<xsl:when test="@type = 'enum'">String</xsl:when>
						<xsl:when test="@type = 'float'">Single</xsl:when>
						<xsl:when test="@type = 'int'">Integer</xsl:when>
						<xsl:when test="@type = 'longblob'">Byte()</xsl:when>
						<xsl:when test="@type = 'longtext'">String</xsl:when>
						<xsl:when test="@type = 'mediumblob'">Byte()</xsl:when>
						<xsl:when test="@type = 'mediumint'">Integer</xsl:when>
						<xsl:when test="@type = 'mediumtext'">String</xsl:when>
						<xsl:when test="@type = 'set'">String</xsl:when>
						<xsl:when test="@type = 'smallint'">Short</xsl:when>
						<xsl:when test="@type = 'text'">string</xsl:when>
						<xsl:when test="@type = 'time'">TimeSpan</xsl:when>
						<xsl:when test="@type = 'timestamp'">Date</xsl:when>
						<xsl:when test="@type = 'tinyblob'">Byte()</xsl:when>
						<xsl:when test="@type = 'tinyint'">Boolean</xsl:when>
						<xsl:when test="@type = 'tinytext'">String</xsl:when>
						<xsl:when test="@type = 'varbinary'">Byte()</xsl:when>
						<xsl:when test="@type = 'varchar'">String</xsl:when>
						<xsl:when test="@type = 'year'">Integer</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="@unsigned = 1">
					<xsl:choose>
						<xsl:when test="@type = 'bigint'">ULong</xsl:when>
						<xsl:when test="@type = 'int'">UInteger</xsl:when>
						<xsl:when test="@type = 'mediumint'">UInteger</xsl:when>
						<xsl:when test="@type = 'smallint'">UShort</xsl:when>
						<xsl:when test="@type = 'tinyint'">Byte</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@nullable = 1 and (@type = 'bigint' or @type = 'bit' or @type = 'bool' or @type = 'date' or @type = 'datetime' or @type = 'decimal' or @type = 'double' or @type = 'float' or @type = 'int' or @type = 'mediumint' or @type = 'smallint' or @type = 'time' or @type = 'timestamp' or @type = 'tinyint' or @type = 'year')">?</xsl:if>
	</xsl:template>

	<!-- TABLE -->
	<xsl:template match="table">
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />Partial Public Class <xsl:apply-templates select="." mode="IdName"/><xsl:value-of select="$LB" />
		<xsl:apply-templates select="column[@length]" mode="TypeLength"/>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="column" mode="Properties"/>
		<xsl:apply-templates select="." mode="UpdateIfModified"/>
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />End Class<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PARAMETER CALL -->
	<xsl:template match="parameter" mode="call">
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />Dim param<xsl:value-of select="position()" /> As DbParameter = sqlCmd.CreateParameter()<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.ParameterName = "@<xsl:value-of select="@name"/>"<xsl:value-of select="$LB" />
		<xsl:if test="@mode != 'out' and @mode != 'return'">
			<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.Value = <xsl:value-of select="@name"/><xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'out'">
			<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.Output<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'inout'">
			<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.InputOutput<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="@mode = 'return'">
			<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.Direction = System.Data.ParameterDirection.ReturnValue<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:value-of select="$ind4" />sqlCmd.Parameters.Add(param<xsl:value-of select="position()" />)<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- PARAMETER RESULT -->
	<xsl:template match="parameter" mode="result">
		<xsl:if test="@mode != 'in'">
			<xsl:value-of select="$ind4" /><xsl:value-of select="@name"/> = If(param<xsl:value-of select="position()" />.Value Is DBNull.Value, Nothing, CType(param<xsl:value-of select="position()" />.Value, <xsl:apply-templates select="." mode="typeonly"/>))<xsl:value-of select="$LB" />
		</xsl:if>
	</xsl:template>

	<!-- PARAMETER FUNCTION -->
	<xsl:template match="parameter" mode="function">
		<xsl:text>, </xsl:text>
		<xsl:if test="@mode = 'out'">ByRef </xsl:if>
		<xsl:if test="@mode = 'inout'">ByRef </xsl:if>
		<xsl:value-of select="@name"/> As <xsl:apply-templates select="." mode="typeonly"/>
	</xsl:template>

	<!-- ROUTINE -->
	<xsl:template match="routine">
		<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
			<xsl:value-of select="$ind2" />
			<xsl:text>Public Shared Sub</xsl:text>
		</xsl:if>
		<xsl:if test="not (parameter[@mode='out'] or parameter[@mode='ref'])">
			<xsl:value-of select="$ind2" />
			<xsl:text>Public Shared Async Function</xsl:text>
		</xsl:if>
		<xsl:text> </xsl:text><xsl:apply-templates select="." mode="IdName"/>(conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="parameter[@mode!='return']" mode="function"/><xsl:text>)</xsl:text>
		<xsl:if test="not (parameter[@mode='out'] or parameter[@mode='ref'] or parameter[@mode='return'])">
			<xsl:text>As Task</xsl:text>
		</xsl:if>
		<xsl:if test="parameter[@mode='return']">
			<xsl:text> As Task(Of </xsl:text>
			<xsl:apply-templates select="parameter[@mode='return']" mode="typeonly"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind3" />Using sqlCmd As DbCommand = conn.CreateCommand()<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.Connection = conn<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.Transaction = transaction<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.CommandText = "<xsl:call-template name="escape-string">
			<xsl:with-param name="input" select="@name" />
		</xsl:call-template>"<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.CommandType = System.Data.CommandType.StoredProcedure<xsl:value-of select="$LB" />
		<xsl:apply-templates select="parameter" mode="call"/>
		<xsl:value-of select="$LB" />
		<xsl:if test="parameter[@mode = 'return']">
			<xsl:if test="not(parameter[@mode='out'] or parameter[@mode='ref'])">
				<xsl:value-of select="$ind4" />Return Await sqlCmd.ExecuteScalarAsync()<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
				<xsl:value-of select="$ind4" />Return sqlCmd.ExecuteScalar()<xsl:value-of select="$LB" />
			</xsl:if>
		</xsl:if>
		<xsl:if test="not(parameter[@mode = 'return'])">
			<xsl:if test="not(parameter[@mode='out'] or parameter[@mode='ref'])">
				<xsl:value-of select="$ind4" />Await sqlCmd.ExecuteNonQueryAsync()<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
				<xsl:value-of select="$ind4" />sqlCmd.ExecuteNonQuery()<xsl:value-of select="$LB" />
			</xsl:if>
			<xsl:value-of select="$LB" />
			<xsl:apply-templates select="parameter[@mode != 'return']" mode="result"/>
		</xsl:if>
		<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
		<xsl:if test="parameter[@mode='out'] or parameter[@mode='ref']">
			<xsl:value-of select="$ind2" />End Sub<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:if test="not (parameter[@mode='out'] or parameter[@mode='ref'])">
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>
		<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- DATABASE -->
	<xsl:template match="database">
		<xsl:text>Imports System
Imports System.Data.Common
Imports System.Reflection
Imports System.Text
Imports System.Threading.Tasks

Namespace </xsl:text>
		<xsl:value-of select="$namespace"/>
		<xsl:text>
    Partial Friend NotInheritable Class </xsl:text>
		<xsl:apply-templates select="." mode="IdName"/>
		<xsl:text>Helper
        Friend Shared Async Function UpdateIfModified(conn As DbConnection, transaction As DbTransaction, objToUpdate As Object, data As Object, tableName As String, listColumnName() As String, listColumnPrimaryName() As String) As Task(Of Integer)
            If objToUpdate Is Nothing Then
                Throw New ArgumentNullException(NameOf(objToUpdate))
            End If

            If data Is Nothing Then
                Throw New ArgumentNullException(NameOf(data))
            End If

            Using sqlCmd As DbCommand = conn.CreateCommand()
                sqlCmd.Connection = conn
                sqlCmd.Transaction = transaction

                Dim typeDate = data.GetType()
                Dim typeObjToUpdate = objToUpdate.GetType()

                Dim hasValueModified = False
                Dim strQuery = New StringBuilder("UPDATE " &amp; tableName &amp; " SET")
                For Each colName In listColumnName
                    Dim propertyInfoData = typeObjToUpdate.GetProperty(colName)
                    If propertyInfoData IsNot Nothing Then
                        Dim propertyInfoObjToUpdate = typeObjToUpdate.GetProperty(colName)
                        If propertyInfoObjToUpdate IsNot Nothing Then
                            Dim oldValue = propertyInfoObjToUpdate.GetValue(objToUpdate)
                            Dim newValue = propertyInfoData.GetValue(data)
                            If (oldValue Is Nothing AndAlso newValue IsNot Nothing) OrElse (oldValue IsNot Nothing AndAlso Not oldValue.Equals(newValue)) Then
                                If hasValueModified Then
                                    strQuery.Append(", " &amp; colName &amp; " = @" &amp; colName)
                                Else
                                    strQuery.Append(" " &amp; colName &amp; " = @" &amp; colName)
                                End If

                                Dim param = sqlCmd.CreateParameter()
                                param.ParameterName = colName
                                param.Value = newValue
                                sqlCmd.Parameters.Add(param)

                                hasValueModified = True
                            End If
                        End If
                    End If
                Next

                If Not hasValueModified Then
                    Return 0
                End If

                Dim isFirst = True
                For Each colNamePrimary In listColumnPrimaryName
                    If isFirst Then
                        strQuery.Append(" WHERE " &amp; colNamePrimary &amp; " = @" &amp; colNamePrimary)
                    Else
                        strQuery.Append(" AND " &amp; colNamePrimary &amp; " = @" &amp; colNamePrimary)
                    End If
                    Dim propertyInfo = typeObjToUpdate.GetProperty(colNamePrimary)
                    If propertyInfo Is Nothing Then
                        Throw New ArgumentException("UpdateIfModified: objToUpdate doesn't contain primary key " &amp; colNamePrimary)
                    End If

                    Dim param = sqlCmd.CreateParameter()
                    param.ParameterName = colNamePrimary
                    param.Value = propertyInfo.GetValue(objToUpdate)
                    sqlCmd.Parameters.Add(param)

                    isFirst = False
                Next
                strQuery.Append(";")

                sqlCmd.CommandText = strQuery.ToString()

                Return Await sqlCmd.ExecuteNonQueryAsync()
            End Using
        End Function
</xsl:text>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="routine"/>
		<xsl:value-of select="$ind" />
		<xsl:text>End Class</xsl:text>
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="table"/>
		<xsl:text>End Namespace</xsl:text>
	</xsl:template>

	<!-- ROOT -->
	<xsl:template match="/">
		<xsl:apply-templates select="sqlwrapper/database[@name = $database or $database = '']"/>
	</xsl:template>

</xsl:stylesheet>
