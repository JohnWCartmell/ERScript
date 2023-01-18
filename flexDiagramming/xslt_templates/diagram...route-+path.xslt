<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box ->
Created 16 Jan 2022
 -->

<xsl:output method="xml" indent="yes"/>

<!-- ************* -->
<!-- route  +path -->
<!-- ************* -->

<xsl:template match="route
                     [not(path)]
                    " mode="recursive_diagram_enrichment"
              priority="200">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <path>
      </path>
   </xsl:copy>
</xsl:template>

</xsl:transform>

