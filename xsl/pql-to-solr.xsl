<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>


	<!-- Copy nodes and attributes. -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<!--
		Match @attr 1= and its Z39.50 index numbers by the corresponding Solr Index names.
		Completely remove the @attr=1 for index 1016 to use Solr’s default index.
	-->
	<xsl:template match="attr[@type='1']">
		<xsl:if test="@value != '1016'">
			<attr type="1">
				<xsl:attribute name="value">
					<xsl:choose>
						<xsl:when test="@value = '4'">
							<xsl:text>title</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1003'">
							<xsl:text>author-letter</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '12'">
							<xsl:text>id</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '7'">
							<xsl:text>isbn</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '8'">
							<xsl:text>issn</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1007'">
							<xsl:text>ctrlnum</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '21'">
							<xsl:text>topic_facet</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '5'">
							<xsl:text>series</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '20'">
							<xsl:text>callnumber</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '54'">
							<xsl:text>language</xsl:text>
						</xsl:when>
						<xsl:when test="@value = '1018'">
							<xsl:text>publisher</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</attr>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
