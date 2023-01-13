<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			  xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram"
               version="2.0">
   <xsl:output method="xml" indent="yes"/>
   <xsl:include href="ERmodel.functions.module.xslt"/>
   <!-- keys removed as invalid -->
   <xsl:template match="/">
      <xsl:copy>
         <xsl:apply-templates mode="pass_0"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="*" mode="pass_0">
      <xsl:copy>
         <xsl:apply-templates mode="pass_0"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="*">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="include[not(*/self::type)]" mode="pass_0">
      <xsl:apply-templates select="document(filename)/*/*" mode="pass_0"/>
   </xsl:template>
   <xsl:template match="/*/include[*/self::type]" mode="pass_0">
      <xsl:variable name="temp" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=current()/type]"
                           mode="pass_0"/>
   </xsl:template>
   <xsl:template match="/*/*/include[*/self::type]" mode="pass_0">
      <xsl:variable name="temp" select="../../name()"/>
      <xsl:variable name="temp2" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=$temp2]/*[name()=current()/type]"
                           mode="pass_0"/>
   </xsl:template>
</xsl:transform>
