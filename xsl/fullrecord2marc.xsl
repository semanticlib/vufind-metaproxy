<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:marc="http://www.loc.gov/MARC21/slim">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="marc:collection/marc:record">
                <xsl:apply-templates select="marc:collection/marc:record"/>
            </xsl:when>
            <xsl:when test="record">
                <xsl:apply-templates select="record"/>
            </xsl:when>
            <xsl:otherwise>
                <record xmlns="http://www.loc.gov/MARC21/slim"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="marc:record">
        <record xmlns="http://www.loc.gov/MARC21/slim">
            <xsl:copy-of select="marc:leader"/>
            <xsl:copy-of select="marc:controlfield"/>
            <xsl:copy-of select="marc:datafield"/>
        </record>
    </xsl:template>

    <xsl:template match="record">
        <record xmlns="http://www.loc.gov/MARC21/slim">
            <xsl:apply-templates select="@*|node()"/>
        </record>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
