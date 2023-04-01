<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>


<!-- **********************  -->
<!-- ProductionInstanceTree  -->
<!-- **********************  -->

<xsl:template match="grammar" mode="createProductionInstanceTree">
<xsl:message>grammar in createProductionTreeInstance</xsl:message>
</xsl:template> 

<xsl:template match="node()|@*" mode="createProductionInstanceTree"> 
   <!--<xsl:message> generic creating production instance tree'<xsl:value-of select="name()"/>'content'<xsl:value-of select="."/>'</xsl:message>-->
   <xsl:copy>
      <xsl:apply-templates select="*[@mapTo='attribute']" mode="createProductionInstanceTree"/>
      <xsl:apply-templates select="*[not(@mapTo='attribute')]" mode="createProductionInstanceTree"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="non-terminal[@mapTo='attribute']" mode="createProductionInstanceTree">
   <!-- <xsl:message> mappping to attribute</xsl:message> -->
   <xsl:attribute name="{@name}">
      <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
   </xsl:attribute>
</xsl:template>

<xsl:template match="non-terminal" mode="createProductionInstanceTree">
   <xsl:element name="{@name}">
      <xsl:apply-templates select="*[@mapTo='attribute']" mode="createProductionInstanceTree"/>
      <xsl:apply-templates select="*[not(@mapTo='attribute')]" mode="createProductionInstanceTree"/>
   </xsl:element>
</xsl:template>

<xsl:template match="non-terminal[@name='Whitespace']" mode="createProductionInstanceTree">
      <!-- deliberately left blank -->
</xsl:template>

<!-- could create element or attr here OR later in creation of intermedioate code --> 

<xsl:template match="scan" mode="createProductionInstanceTree"> 
      <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="literal[not(@signifier = 'true')]" mode="createProductionInstanceTree">
    <!-- deliberately left blank -->
</xsl:template>

<xsl:template match="literal[@signifier = 'true']" mode="createProductionInstanceTree">
    <xsl:element name="{@type}"/>
</xsl:template>

<xsl:template match="sequence[not(@type)]" mode="createProductionInstanceTree">
      <xsl:apply-templates select="*[@mapTo='attribute']" mode="createProductionInstanceTree"/>
      <xsl:apply-templates select="*[not(@mapTo='attribute')]" mode="createProductionInstanceTree"/>
</xsl:template>


<xsl:template match="ZeroOrOne" mode="createProductionInstanceTree">
      <xsl:apply-templates select="*[@mapTo='attribute']" mode="createProductionInstanceTree"/>
      <xsl:apply-templates select="*[not(@mapTo='attribute')]" mode="createProductionInstanceTree"/>
</xsl:template>


<!-- GOING TO HAVE TO prune I THINK -->
<xsl:template match="node()|@*" mode="pruneProductionInstanceTree"> 
   <xsl:copy>
      <xsl:apply-templates select="*" mode="pruneProductionInstanceTree"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="ZeroOneOrMore/OneOfZeroOneOrMore[count(*)=1]" mode="pruneProductionInstanceTree">
      <xsl:apply-templates select="*" mode="pruneProductionInstanceTree"/>
</xsl:template>



</xsl:transform>
