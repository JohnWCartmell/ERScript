

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:include href="ERmodel2.documentation_enrichment.module.xslt"/>

  <xsl:template match="/" >
     <xsl:call-template name="documentation_enrichment">
      <xsl:with-param name="document">
        <xsl:copy-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>


