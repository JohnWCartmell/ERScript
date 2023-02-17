<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>



<xsl:template match="/">
   <xsl:message> In root entity simplifying grammar/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates  mode="report"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="grammar" mode="report">
   <xsl:copy>
      <xsl:element name="summary">
         <xsl:apply-templates mode="summary"/>
      </xsl:element>
      <xsl:apply-templates  mode="report"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="prod" mode="summary">
   <xsl:if test="count(
                        //nt[.=current()/lhs]
                      )!= 1">
      <xsl:copy>
         <xsl:apply-templates select="lhs" mode="summary"/>
      </xsl:copy>
   </xsl:if>
</xsl:template>

<xsl:template match="lhs" mode="summary">
   <xsl:element name="nonterminal">
      <xsl:element name="nonterminal">
         <xsl:value-of select="."/>
      </xsl:element>
      <xsl:element name="numberOfUses">
         <xsl:value-of select="count(
                                    //nt[.=current()/.]
                                    )
                               "/>
      </xsl:element>
   </xsl:element>
</xsl:template>


<xsl:template match="prod" mode="report">
   <xsl:if test="count(
                        //nt[.=current()/lhs]
                      )!= 1">
      <xsl:copy>
         <xsl:apply-templates mode="report"/>
      </xsl:copy>
   </xsl:if>
</xsl:template>

THIS GETS RID OF UNWANTED PRODUCTION BUT DOESNT EXPAND THEM INLINE AS IT NEEDS TO DO

<xsl:template match="nt" mode="report">
   <xsl:copy>
      <xsl:attribute name="usecount" 
                     select="count(
                                    //nt[.=current()/.]
                                    )
                               "/>
      <xsl:apply-templates select="node()|@*" mode="report"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="node()|@*" mode="report">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="report"/>
   </xsl:copy>
</xsl:template>



</xsl:transform>
