<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

	<xsl:param name="namespace" select="'DAIKOZ'" />
	<xsl:param name="classname" select="'ClassDaikoz'" />
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
	<xsl:variable name="ind6">
		<xsl:value-of select="$ind5"/>
		<xsl:value-of select="$ind"/>
	</xsl:variable>
	<xsl:variable name="ind7">
		<xsl:value-of select="$ind6"/>
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

	<!-- Convert database type to C# type -->
	<xsl:template match="type" mode="typeonly">
		<xsl:choose>
			<xsl:when test="@custom">
				<xsl:value-of select="@custom"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(@unsigned = 1)">
					<xsl:choose>
						<xsl:when test=". = 'bigint'">Long</xsl:when>
						<xsl:when test=". = 'binary'">Byte()</xsl:when>
						<xsl:when test=". = 'bit'">ULong</xsl:when>
						<xsl:when test=". = 'blob'">Byte()</xsl:when>
						<xsl:when test=". = 'bool'">Boolean</xsl:when>
						<xsl:when test=". = 'char'">String</xsl:when>
						<xsl:when test=". = 'date'">Date</xsl:when>
						<xsl:when test=". = 'datetime'">Date</xsl:when>
						<xsl:when test=". = 'decimal'">Decimal</xsl:when>
						<xsl:when test=". = 'double'">Double</xsl:when>
						<xsl:when test=". = 'enum'">String</xsl:when>
						<xsl:when test=". = 'float'">Single</xsl:when>
						<xsl:when test=". = 'int'">Integer</xsl:when>
						<xsl:when test=". = 'longblob'">Byte()</xsl:when>
						<xsl:when test=". = 'longtext'">String</xsl:when>
						<xsl:when test=". = 'mediumblob'">Byte()</xsl:when>
						<xsl:when test=". = 'mediumint'">Integer</xsl:when>
						<xsl:when test=". = 'mediumtext'">String</xsl:when>
						<xsl:when test=". = 'set'">String</xsl:when>
						<xsl:when test=". = 'smallint'">Short</xsl:when>
						<xsl:when test=". = 'text'">String</xsl:when>
						<xsl:when test=". = 'time'">TimeSpan</xsl:when>
						<xsl:when test=". = 'timestamp'">Date</xsl:when>
						<xsl:when test=". = 'tinyblob'">Byte()</xsl:when>
						<xsl:when test=". = 'tinyint'">Boolean</xsl:when>
						<xsl:when test=". = 'tinytext'">String</xsl:when>
						<xsl:when test=". = 'varbinary'">Byte()</xsl:when>
						<xsl:when test=". = 'varchar'">String</xsl:when>
						<xsl:when test=". = 'year'">Integer</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="@unsigned = 1">
					<xsl:choose>
						<xsl:when test=". = 'bigint'">ULong</xsl:when>
						<xsl:when test=". = 'int'">UInteger</xsl:when>
						<xsl:when test=". = 'mediumint'">UInteger</xsl:when>
						<xsl:when test=". = 'smallint'">UShort</xsl:when>
						<xsl:when test=". = 'tinyint'">Byte</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@nullable = 1 and (. = 'bigint' or . = 'bit' or . = 'bool' or . = 'date' or . = 'datetime' or . = 'decimal' or . = 'double' or . = 'float' or . = 'int' or . = 'mediumint' or . = 'smallint' or . = 'time' or . = 'timestamp' or . = 'tinyint' or . = 'year')">?</xsl:if>
	</xsl:template>

	<!-- output type -->
	<xsl:template match="type">
		<xsl:apply-templates select="." mode="typeonly"/>
		<xsl:if test="@array = 1">[]</xsl:if>
		<xsl:if test="@array = 1 and . = 'char'">ERROR_SQL_INJECTION</xsl:if>
	</xsl:template>

	<!-- Assign query output to return -->
	<xsl:template match="query" mode="outputassign">

		<xsl:param name="indentation" />

		<xsl:for-each select="output">
			<xsl:variable name="returntype">
				<xsl:apply-templates select="type"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="type[@nullable = 1]">
					<xsl:if test="not(type[@custom])">
						<xsl:value-of select="$ind7" /><xsl:value-of select="$indentation" />.<xsl:value-of select="name"/> = If(IsDBNull(reader(<xsl:value-of select="position()-1" />)), Nothing, CType(reader(<xsl:value-of select="position()-1" />), <xsl:apply-templates select="type"/><xsl:text>))</xsl:text>
					</xsl:if>
					<xsl:if test="type[@custom]">
						<xsl:value-of select="$ind7" /><xsl:value-of select="$indentation" />.<xsl:value-of select="name"/> = reader(<xsl:value-of select="position()-1" />) == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)(typeof(<xsl:value-of select="type/@custom"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="type/@custom"/>), reader(<xsl:value-of select="position()-1" />)) : Convert.ChangeType(reader(<xsl:value-of select="position()-1" />), typeof(<xsl:value-of select="type/@custom"/><xsl:text>), System.Globalization.CultureInfo.InvariantCulture))</xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not(type[@custom])">
						<xsl:value-of select="$ind7" /><xsl:value-of select="$indentation" />.<xsl:value-of select="name"/> = CType(reader(<xsl:value-of select="position()-1" />), <xsl:apply-templates select="type"/><xsl:text>)</xsl:text>
					</xsl:if>
					<xsl:if test="type[@custom]">
						<xsl:value-of select="$ind7" /><xsl:value-of select="$indentation" />.<xsl:value-of select="name"/> = (<xsl:apply-templates select="type"/>)(typeof(<xsl:value-of select="type/@custom"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="type/@custom"/>), reader(<xsl:value-of select="position()-1" />)) : Convert.ChangeType(reader(<xsl:value-of select="position()-1" />), typeof(<xsl:value-of select="type/@custom"/><xsl:text>), System.Globalization.CultureInfo.InvariantCulture))</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position() != last()">,</xsl:if>
			<xsl:value-of select="$LB" />
		</xsl:for-each>
	</xsl:template>

	<!-- Assign query output to return object -->
	<xsl:template match="query" mode="outputconvert">
		<xsl:for-each select="output">
			<xsl:variable name="returntype">
				<xsl:apply-templates select="type"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="type[@nullable = 1]">
					reader(<xsl:value-of select="position()-1" />) == DBNull.Value ? null : (<xsl:apply-templates select="type"/>)reader[<xsl:value-of select="position()-1" />]
				</xsl:when>
				<xsl:otherwise>
					reader(<xsl:value-of select="position()-1" />)
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Assign query output to return object -->
	<xsl:template match="output">
		<xsl:value-of select="$ind3" />Public Property [<xsl:value-of select="name"/>] As <xsl:apply-templates select="./type"/><xsl:value-of select="$LB" />
	</xsl:template>

	<!-- Query return object -->
	<xsl:template match="query" mode="returntype">

		<xsl:variable name="name" select="../name"/>
		<xsl:variable name="nboutput" select="count(output)"/>
		<xsl:variable name="nboutputmultiple" select="@multiplerows = 1"/>

		<xsl:if test="position() != 1">, </xsl:if>
		<xsl:if test="$nboutput = 1 and $nboutputmultiple = 0">
			<xsl:apply-templates select="output/type"/>
		</xsl:if>
		<xsl:if test="$nboutput > 1 and $nboutputmultiple = 0">
			<xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" />
		</xsl:if>
		<xsl:if test="$nboutputmultiple = 1">
			<xsl:text>List(Of </xsl:text><xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /><xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Query return multi-object -->
	<xsl:template match="query" mode="initresult">

		<xsl:variable name="name" select="../name"/>
		<xsl:variable name="nboutput" select="count(output)"/>
		<xsl:variable name="nboutputmultiple" select="@multiplerows = 1"/>

		<xsl:if test="$nboutput = 1 and $nboutputmultiple = 0">
			<xsl:value-of select="$ind4" />Dim result<xsl:value-of select="position()" /> As <xsl:apply-templates select="output/type"/><xsl:text> = Nothing</xsl:text>
		</xsl:if>
		<xsl:if test="$nboutput > 1 and $nboutputmultiple = 0">
			<xsl:value-of select="$ind4" />Dim result<xsl:value-of select="position()" /> As New <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /><xsl:text>()</xsl:text>
		</xsl:if>
		<xsl:if test="$nboutputmultiple = 1">
			<xsl:value-of select="$ind4" />Dim result<xsl:value-of select="position()" /> As New List(Of <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /><xsl:text>)()</xsl:text>
		</xsl:if>

		<xsl:value-of select="$LB" />
	</xsl:template>

	<!-- Query return ouput -->
	<xsl:template match="query" mode="getresult">

		<xsl:variable name="nboutput" select="count(output)"/>
		<xsl:variable name="returntype">
			<xsl:apply-templates select="output/type"/>
		</xsl:variable>

		<xsl:value-of select="$ind6" />' <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /><xsl:value-of select="$LB" />
		<xsl:if test="position() != 1">
			<xsl:value-of select="$ind6" />If Not Await reader.NextResultAsync() Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />Throw New InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> invalid number of result")<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return only one value -->
		<xsl:if test="$nboutput = 1 and @multiplerows = 0">
			<xsl:value-of select="$ind6" />If Not Await reader.ReadAsync() Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />Throw New InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> return no row")<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:if test="output/type[@nullable = 0]">
				<xsl:if test="not(output/type[@custom])">
					<xsl:value-of select="$ind6" />result<xsl:value-of select="position()" /> = reader(0)<xsl:value-of select="$LB" />
				</xsl:if>
				<xsl:if test="output/type[@custom]">
					<xsl:value-of select="$ind6" />result<xsl:value-of select="position()" /> = (<xsl:value-of select="$returntype"/>)Convert.ChangeType(reader[0], typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);<xsl:value-of select="$LB" />
				</xsl:if>
			</xsl:if>
			<xsl:if test="output/type[@nullable = 1]">
				<xsl:if test="not(output/type[@custom])">
					<xsl:value-of select="$ind6" />result<xsl:value-of select="position()" /> = If(reader.IsDBNull(0), Nothing, reader[0])<xsl:value-of select="$LB" />
				</xsl:if>
				<xsl:if test="output/type[@custom]">
					<xsl:value-of select="$ind6" />result<xsl:value-of select="position()" /> = reader[0] == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)Convert.ChangeType(reader[0], typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);<xsl:value-of select="$LB" />
				</xsl:if>
			</xsl:if>
			<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return one multiple columns -->
		<xsl:if test="$nboutput > 1 and @multiplerows = 0">
			<xsl:value-of select="$ind6" />If Not Await reader.ReadAsync() Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />Throw New InvalidOperationException("<xsl:value-of select="../name"/>Result query <xsl:value-of select="position()" /> return no row")<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />result<xsl:value-of select="position()" /> = new <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /> With {<xsl:value-of select="$LB" />
			<xsl:apply-templates select="." mode="outputassign"/>
			<xsl:value-of select="$ind6" />}<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return several row of one column -->
		<xsl:if test="$nboutput = 1 and @multiplerows = 1">
			<xsl:value-of select="$ind6" />While Await reader.ReadAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />result<xsl:value-of select="position()" />.Add(<xsl:apply-templates select="." mode="outputconvert"/>)<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End While<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return several row multiple columns -->
		<xsl:if test="$nboutput > 1 and @multiplerows = 1">
			<xsl:value-of select="$ind6" />While Await reader.ReadAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />result<xsl:value-of select="position()" />.Add(New <xsl:value-of select="../name"/>ResultQuery<xsl:value-of select="position()" /> With {<xsl:value-of select="$LB" />
			<xsl:apply-templates select="." mode="outputassign">
				<xsl:with-param name="indentation" select="$ind" />
			</xsl:apply-templates>
			<xsl:value-of select="$ind7" />})<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End While<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
		</xsl:if>

	</xsl:template>

	<!-- Input Parameters of method -->
	<xsl:template match="type" mode="input">
		<xsl:if test="@array = 1">IEnumerable&lt;</xsl:if>
		<xsl:apply-templates select="." mode="typeonly"/>
		<xsl:if test="@array = 1">&gt;</xsl:if>
		<xsl:if test="@array = 1 and . = 'char'">ERROR_SQL_INJECTION</xsl:if>
	</xsl:template>

	<!-- Input Parameters of method -->
	<xsl:template match="input">
		<xsl:text>, </xsl:text><xsl:value-of select="name"/> As <xsl:apply-templates select="./type" mode="input"/>
	</xsl:template>

	<!-- Create DbCommand and DbParameter -->
	<xsl:template match="sql" mode="DbCommand">
		<xsl:value-of select="$ind3" />Using sqlCmd As DbCommand = conn.CreateCommand()<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.Connection = conn<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.Transaction = transaction<xsl:value-of select="$LB" />
		<xsl:value-of select="$ind4" />sqlCmd.CommandText = "<xsl:call-template name="escape-string">
			<xsl:with-param name="input" select="text" />
		</xsl:call-template><xsl:text>"</xsl:text>
		<xsl:for-each select="query/input/type[@array = 1]">
			<xsl:text>.Replace("(@</xsl:text><xsl:value-of select="../name"/>)", (<xsl:value-of select="../name"/> != null &amp;&amp; <xsl:value-of select="../name"/>.Any()) ? string.Format("({0})", string.Join(",", <xsl:value-of select="../name"/><xsl:text>)) : "(NULL)", StringComparison.Ordinal)</xsl:text>
		</xsl:for-each><xsl:value-of select="$LB" />
		<xsl:value-of select="$LB" />
		<xsl:for-each select="query/input">
			<xsl:if test="type[@array != 1]">
				<xsl:value-of select="$ind4" />Dim param<xsl:value-of select="position()" /> As DbParameter = sqlCmd.CreateParameter()<xsl:value-of select="$LB" />
				<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.ParameterName = "@<xsl:value-of select="name"/>"<xsl:value-of select="$LB" />
				<xsl:value-of select="$ind4" />param<xsl:value-of select="position()" />.Value = <xsl:value-of select="name"/><xsl:value-of select="$LB" />
				<xsl:value-of select="$ind4" />sqlCmd.Parameters.Add(param<xsl:value-of select="position()" />)<xsl:value-of select="$LB" />
				<xsl:value-of select="$LB" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- SQL Query method -->
	<xsl:template match="sql">

		<xsl:variable name="nboutput" select="count(query[@ignore = 0]/output)"/>
		<xsl:variable name="nboutputmultiple" select="count(query[@ignore = 0 and @multiplerows = 1])"/>
		<xsl:variable name="nbquery" select="count(query[@ignore = 0])"/>

		<!-- Non Query Insert Delete Update -->
		<xsl:if test="$nboutput = 0">
			<xsl:value-of select="$ind2" />Public Shared Async Function <xsl:value-of select="name"/>(conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>) As Task(Of Integer)<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:value-of select="$ind4" />Return Await sqlCmd.ExecuteNonQueryAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return only one value -->
		<xsl:if test="$nboutput = 1 and $nboutputmultiple = 0">

			<xsl:variable name="returntype">
				<xsl:apply-templates select="query[@ignore = 0]/output/type"/>
			</xsl:variable>

			<xsl:value-of select="$ind2" />Public Shared Async Function <xsl:value-of select="name"/>(conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>, Optional returnDefault As Boolean = False) As Task(Of <xsl:value-of select="$returntype"/>)<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:value-of select="$ind4" />Dim result As Object = Await sqlCmd.ExecuteScalarAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />If result IsNot Nothing Then<xsl:value-of select="$LB" />

			<xsl:if test="query[@ignore = 0]/output/type[@nullable = 0]">
				<xsl:if test="not(query[@ignore = 0]/output/type[@custom]) and not(query[@ignore = 0]/output/type[@lastinsertid = 1])">
					<xsl:value-of select="$ind5" />Return result<xsl:value-of select="$LB" />
				</xsl:if>
				<xsl:if test="query[@ignore = 0]/output/type[@custom]">
					<xsl:value-of select="$ind5" />Return (<xsl:value-of select="$returntype"/>)(typeof(<xsl:value-of select="$returntype"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="$returntype"/>), result) : Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture));<xsl:value-of select="$LB" />
				</xsl:if>
				<xsl:if test="query[@ignore = 0]/output/type[@lastinsertid = 1]">
					<xsl:value-of select="$ind5" />Return (<xsl:value-of select="$returntype"/>)Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture);<xsl:value-of select="$LB" />
				</xsl:if>
			</xsl:if>

			<xsl:if test="query[@ignore = 0]/output/type[@nullable = 1]">
				<xsl:if test="not(query[@ignore = 0]/output/type[@custom])">
					<xsl:value-of select="$ind5" />return result == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)result;<xsl:value-of select="$LB" />
				</xsl:if>
				<xsl:if test="query[@ignore = 0]/output/type[@custom]">
					<xsl:value-of select="$ind5" />return result == DBNull.Value ? null : (<xsl:value-of select="$returntype"/>)(typeof(<xsl:value-of select="$returntype"/>).IsEnum ? Enum.ToObject(typeof(<xsl:value-of select="$returntype"/>), result) : Convert.ChangeType(result, typeof(<xsl:value-of select="$returntype"/>), System.Globalization.CultureInfo.InvariantCulture));<xsl:value-of select="$LB" />
				</xsl:if>
			</xsl:if>
			<xsl:value-of select="$ind4" />End If<xsl:value-of select="$LB" />

			<xsl:value-of select="$ind4" />If Not returnDefault Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />Throw New InvalidOperationException("<xsl:value-of select="name"/> return no row")<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Return Nothing<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return one multiple columns -->
		<xsl:if test="$nboutput > 1 and $nboutputmultiple = 0 and $nbquery = 1">
			<xsl:value-of select="$ind2" />Public Class <xsl:value-of select="name"/>Result<xsl:value-of select="$LB" />
			<xsl:apply-templates select="query/output"/>
			<xsl:value-of select="$ind2" />End Class<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />

			<xsl:value-of select="$ind2" />Public Shared Async Function [<xsl:value-of select="name"/>](conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>) As Task(Of <xsl:value-of select="name"/>Result)<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:value-of select="$ind4" />Using reader As DbDataReader = Await sqlCmd.ExecuteReaderAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />If reader IsNot Nothing AndAlso reader.Read() Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />Return New <xsl:value-of select="name"/>Result With {<xsl:value-of select="$LB" />
			<xsl:apply-templates select="query" mode="outputassign" />
			<xsl:value-of select="$ind6" />}<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />Return Nothing<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return several row of one column -->
		<xsl:if test="$nboutput = 1 and $nboutputmultiple = 1">
			<xsl:variable name="returntype">
				<xsl:apply-templates select="query[@ignore = 0]/output/type"/>
			</xsl:variable>

			<xsl:value-of select="$ind2" />Public Shared Async Function [<xsl:value-of select="name"/>](conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>) As Task(Of List(Of <xsl:value-of select="$returntype"/>))<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:value-of select="$ind4" />Dim listResult As New List(Of <xsl:value-of select="$returntype"/>)()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Using reader As DbDataReader = Await sqlCmd.ExecuteReaderAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />If reader IsNot Nothing Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />While Await reader.ReadAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />listResult.Add(<xsl:apply-templates select="query" mode="outputconvert"/>)<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End While<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Return listResult<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return several row multiple columns -->
		<xsl:if test="$nboutput > 1 and $nboutputmultiple = 1 and $nbquery = 1">
			<xsl:value-of select="$ind2" />Public Class <xsl:value-of select="name"/>Result<xsl:value-of select="$LB" />
			<xsl:apply-templates select="query/output"/>
			<xsl:value-of select="$ind2" />End Class<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />Public Shared Async Function [<xsl:value-of select="name"/>](conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>) As Task(Of List(Of <xsl:value-of select="name"/>Result))<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:value-of select="$ind4" />Dim listResult As New List(Of <xsl:value-of select="name"/>Result)()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Using reader As DbDataReader = Await sqlCmd.ExecuteReaderAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />If reader IsNot Nothing Then<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />While Await reader.ReadAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind7" />listResult.Add(New <xsl:value-of select="name"/>Result() with {<xsl:value-of select="$LB" />
			<xsl:apply-templates select="query" mode="outputassign">
				<xsl:with-param name="indentation" select="$ind" />
			</xsl:apply-templates>
			<xsl:value-of select="$ind7" />})<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind6" />End While<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Return listResult<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<!-- Return several queries -->
		<xsl:if test="$nboutput > 1 and $nbquery > 1">

			<xsl:variable name="name" select="name"/>

			<xsl:for-each select="query[@ignore = 0]">
				<xsl:if test="count(output) > 1">
					<xsl:value-of select="$ind2" />Public Class <xsl:value-of select="$name"/>ResultQuery<xsl:value-of select="position()" /><xsl:value-of select="$LB" />
					<xsl:apply-templates select="output"/>
					<xsl:value-of select="$ind2" />End Class<xsl:value-of select="$LB" />
					<xsl:value-of select="$LB" />
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$ind2" />Public Shared Async Function [<xsl:value-of select="name"/>](conn As DbConnection, transaction As DbTransaction<xsl:apply-templates select="query/input"/>) As Task(Of (<xsl:apply-templates select="query[@ignore = 0]" mode="returntype"/>))<xsl:value-of select="$LB" />

			<xsl:apply-templates select="." mode="DbCommand"/>

			<xsl:apply-templates select="query[@ignore = 0]" mode="initresult"/>
			<xsl:value-of select="$LB" />

			<xsl:value-of select="$ind4" />Using reader As DbDataReader = Await sqlCmd.ExecuteReaderAsync()<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind5" />If reader IsNot Nothing Then<xsl:value-of select="$LB" />
			<xsl:apply-templates select="query[@ignore = 0]" mode="getresult"/>
			<xsl:value-of select="$ind5" />End If<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind4" />Return (<xsl:for-each select="query[@ignore = 0]">
				<xsl:if test="position() != 1">, </xsl:if>result<xsl:value-of select="position()" />
			</xsl:for-each>)<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind3" />End Using<xsl:value-of select="$LB" />
			<xsl:value-of select="$ind2" />End Function<xsl:value-of select="$LB" />
		</xsl:if>

		<xsl:value-of select="$LB" />

	</xsl:template>

	<!-- Main class -->
	<xsl:template match="/">
		<xsl:text>Imports System
Imports System.Collections.Generic
Imports System.Data.Common
Imports System.Linq
Imports System.Threading.Tasks

Namespace </xsl:text><xsl:value-of select="$namespace"/><xsl:value-of select="$LB" />
		<xsl:value-of select="$ind" />Partial Public Class <xsl:value-of select="$classname"/><xsl:value-of select="$LB" />
		<xsl:value-of select="$LB" />
		<xsl:apply-templates select="sqlwrapper/sql"/>
		<xsl:value-of select="$ind" />End Class<xsl:value-of select="$LB" />
		<xsl:value-of select="$LB" />
		<xsl:text>End Namespace</xsl:text>
	</xsl:template>
</xsl:stylesheet>