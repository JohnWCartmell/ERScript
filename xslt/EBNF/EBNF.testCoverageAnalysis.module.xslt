<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>


<!-- ********************************************************************** -->
<!-- testCoverageAnalysis of a  grammar in an instance of a production tree -->
<!-- ********************************************************************** -->


<xsl:template match="/|node()" mode="testCoverageAnalysis">
   <xsl:param name="parseTree" as="element(non-terminal)"/>
   <xsl:copy>
      <xsl:apply-templates select="node()" mode="testCoverageAnalysis">
         <xsl:with-param name="parseTree" select="$parseTree"/>
      </xsl:apply-templates>
   </xsl:copy>
</xsl:template>


<xsl:template match="prod" mode="testCoverageAnalysis">
   <xsl:param name="parseTree" as="element(non-terminal)"/>
   <xsl:copy>
      <xsl:attribute name="testInstanceCount" select="count($parseTree//non-terminal[@name=current()/lhs])"/>
      <xsl:apply-templates select="node()" mode="testCoverageAnalysis">
         <xsl:with-param name="parseTree" select="$parseTree"/>
      </xsl:apply-templates>
   </xsl:copy>
</xsl:template>

<xsl:template match="nt" mode="testCoverageAnalysis">
   <xsl:param name="parseTree" as="element(non-terminal)"/>
   <xsl:copy>
      <xsl:attribute name="testInstanceCount" select="count($parseTree//non-terminal[@id=current()/@id])"/>
      <xsl:apply-templates select="node()" mode="testCoverageAnalysis">
         <xsl:with-param name="parseTree" select="$parseTree"/>
      </xsl:apply-templates>
   </xsl:copy>
</xsl:template>


</xsl:transform>
