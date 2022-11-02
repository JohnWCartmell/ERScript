<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:output method="xml" indent="yes"/>

   <xsl:template match="/">
      <xsl:message> In root entity in 2.core which is <xsl:value-of select="name()"/></xsl:message>
      <xsl:copy>
         <xsl:apply-templates select="*" mode="omitpresentation"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@*|node()" mode="omitpresentation">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="omitpresentation"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[self::presentation|self::diagram]" mode="omitpresentation"/>

</xsl:transform>
