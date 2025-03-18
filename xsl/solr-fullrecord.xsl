<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:template match="doc">
        <xsl:apply-templates select="str[@name='fullrecord']"/>
    </xsl:template>

    <!-- Match the str element with name='fullrecord' and output its content as raw string -->
    <xsl:template match="str[@name='fullrecord']">
        <xsl:value-of select="." disable-output-escaping="yes"/>
    </xsl:template>

</xsl:stylesheet>
