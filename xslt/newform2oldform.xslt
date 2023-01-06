<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
               xmlns="http://www.entitymodelling.org/ERmodel">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="ERmodelv1.6.parser.module.xslt"/>

<xsl:template match="/">
   <xsl:message> In root entity parsing v1.6 convert 2.oldform/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="entity_model" mode="parse__conditional"/>
   </xsl:copy>
</xsl:template>


</xsl:transform>
