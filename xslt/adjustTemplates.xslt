<?xml version="1.0" encoding="UTF-8"?>

<!-- Written for me  by chatGPT -->
<!-- A use-once template to tidy up my xslt. -->
<!-- Make sure that templates don't lose attributes --> 

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Output formatting -->
  <xsl:output method="xml" indent="yes"/>

  <!-- Identity transform -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Match the root <xsl:stylesheet> element and inject a comment -->
  <xsl:template match="xsl:stylesheet">
    <xsl:copy>
      <xsl:comment>Transformed by meta-XSLT</xsl:comment>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Special case for xsl:apply-templates with no select attribute -->
  <xsl:template match="xsl:apply-templates[not(@select)]">
    <xsl:copy>
      <xsl:attribute name="select">@*|node()</xsl:attribute>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
