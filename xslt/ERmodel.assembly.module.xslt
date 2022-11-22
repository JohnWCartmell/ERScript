<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:strip-space elements="*"/>

   <xsl:template match="@*|node()" mode="assembly">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="assembly"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="include_model" mode="assembly">
      <xsl:message>In include_model</xsl:message>
       <xsl:apply-templates select="document(@filename)/entity_model/*" mode="assembly"/>
   </xsl:template>

</xsl:transform>
