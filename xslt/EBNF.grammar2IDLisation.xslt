<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>



<xsl:template match="/">
   <xsl:message> In root entity transforming grammar/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates  mode="toIDL"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="grammar" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates  mode="toIDL"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="prod" mode="toIDL">
   <xsl:copy>
      <!-- add usecount just for interest's sake -->
      <xsl:attribute name="usecount" 
                     select="count(
                                    //nt[.=current()/lhs]
                                    )
                               "/>
      <xsl:apply-templates mode="toIDL"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="nt" mode="toIDL">
   <xsl:copy>
      <!-- add usecount just for interest's sake -->
      <xsl:attribute name="usecount" 
                     select="count(
                                    //nt[.=current()/.]
                                    )
                               "/>
      <xsl:apply-templates select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[following-sibling::*[1][self::ZeroOneOrMore]]" mode="toIDL">
   <xsl:message>blank <xsl:value-of select="name()"/></xsl:message>
     <!--deliberately left blank -->
</xsl:template>


<xsl:template match="ZeroOneOrMore" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates  select="preceding-sibling::*[1]" mode="toIDLkeepme"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="toIDLkeepme">  
   <xsl:copy>
      <xsl:apply-templates  select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="unit" mode="toIDLkeepme">  
      <xsl:apply-templates  select="node()|@*" mode="toIDL"/>
</xsl:template>

<xsl:template match="node()|@*" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>




</xsl:transform>
