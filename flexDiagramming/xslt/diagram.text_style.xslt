<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->

<xsl:output method="xml" indent="yes"/>


<!-- **************** -->
<!-- label/text_style -->
<!-- **************** -->
<xsl:template match="*[self::label]
                      [not(text_style)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="78">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <text_style><xsl:value-of select="(ancestor-or-self::*/default/text_style)[last()]"/></text_style>
   </xsl:copy>
</xsl:template>



</xsl:transform>

