<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" indent="yes"/>

   <xsl:template match="/">
      <xsl:message>ERmodel2.core.xslt: root entity  <xsl:value-of select="name()"/></xsl:message>
      <xsl:copy>
         <xsl:apply-templates select="*" mode="omitpresentation"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@*|node()" mode="omitpresentation">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="omitpresentation"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[self::defaults|self::presentation|self::diagram]" mode="omitpresentation"/>

</xsl:transform>
