<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			  xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram"
               version="2.0">
   <xsl:output method="xml" indent="yes"/>
   <!--<xsl:include href="ERmodel.functions.module.xslt"/>-->
   <!-- keys removed as invalid -->
   <xsl:template match="*" mode="elaborate">
      <xsl:copy>
         <xsl:apply-templates mode="elaborate"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="*">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="include[not(*/self::type)]" mode="elaborate">
      <xsl:message>filename <xsl:value-of select="filename"/> </xsl:message>
      <xsl:apply-templates select="document(filename)/*/*" mode="elaborate"/>
   </xsl:template>
   <xsl:template match="/*/include[*/self::type]" mode="elaborate">
      <xsl:variable name="temp" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=current()/type]"
                           mode="elaborate"/>
   </xsl:template>
   <xsl:template match="/*/*/include[*/self::type]" mode="elaborate">
      <xsl:variable name="temp" select="../../name()"/>
      <xsl:variable name="temp2" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=$temp2]/*[name()=current()/type]"
                           mode="elaborate"/>
   </xsl:template>
</xsl:transform>
