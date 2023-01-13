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
<!-- enclosure/debug-whitespace -->
<!-- **************** -->
<xsl:template match="*[self::enclosure|self::point]
                      [not(debug-whitespace)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="55">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <debug-whitespace><xsl:value-of select="(ancestor-or-self::*/default/debug-whitespace)[last()]"/></debug-whitespace>
   </xsl:copy>
</xsl:template>



</xsl:transform>

