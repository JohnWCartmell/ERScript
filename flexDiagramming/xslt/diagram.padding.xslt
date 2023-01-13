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
<!-- box/padding -->
<!-- **************** -->
<xsl:template match="*[self::enclosure|self::label|self::point|self::ns|self::ew|self::ramp]
                      [not(padding)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="77">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <padding><xsl:value-of select="(ancestor-or-self::*/default/padding)[last()]"/></padding>
   </xsl:copy>
</xsl:template>



</xsl:transform>

