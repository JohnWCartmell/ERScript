<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" indent="yes"/>

 <xsl:include href="ERmodel.assembly.module.xslt"/>
 <xsl:include href="ERmodel.consolidate.module.xslt"/>

   <xsl:template match="/">
      <xsl:message>ERmodel.consolidate.xslt</xsl:message>
      <xsl:variable name="state">
         <xsl:apply-templates select="*" mode="assembly"/>
      </xsl:variable>
      <xsl:apply-templates select="$state" mode="consolidate"/>
   </xsl:template>

</xsl:transform>
