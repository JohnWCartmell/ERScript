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
   <xsl:message> generic creating production instance tree'<xsl:value-of select="name()"/>'content'<xsl:value-of select="."/>'</xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="non-terminal" mode="createProductionInstanceTree">
   <xsl:element name="{@name}">
      <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
   </xsl:element>
</xsl:template>

<xsl:template match="scan" mode="createProductionInstanceTree"> 
   <xsl:value-of select="."/>
</xsl:template>


<!-- rethink Mon evening 6 March
<xsl:template match="literal[@type]" mode="createProductionInstanceTree">
      <xsl:element name="{@type}"/>
</xsl:template>

 
<xsl:template match="literal[not(@type)]" mode="createProductionInstanceTree">
    deliberately left blank
</xsl:template>
-->

<xsl:template match="literal[not(@signifier = 'true')]" mode="createProductionInstanceTree">
    <!-- deliberately left blank -->
</xsl:template>

<xsl:template match="literal[@signifier = 'true']" mode="createProductionInstanceTree">
    <xsl:element name="{@type}"/>
</xsl:template>


<xsl:template match="sequence[not(@type)]" mode="createProductionInstanceTree">
   <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
</xsl:template>


<xsl:template match="ZeroOneOrMore[@type]/OneOfZeroOneOrMore" mode="createProductionInstanceTree">
      <xsl:element name="{../@type}">
         <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
      </xsl:element>
</xsl:template>

<xsl:template match="ZeroOneOrMore[@OneOrMore][exists(element())]" mode="createProductionInstanceTree">
      <xsl:element name="{@OneOrMore}">
         <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
      </xsl:element>
</xsl:template>

<xsl:template match="ZeroOneOrMore[@OneOrMore][not(exists(element()))]" mode="createProductionInstanceTree">
     <!-- deliberately left blank -->
</xsl:template>

<xsl:template match="ZeroOrOne" mode="createProductionInstanceTree">
     <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
</xsl:template>


   

</xsl:transform>
