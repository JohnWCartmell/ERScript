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

<!-- ************************ -->
<!-- route: +src_rise         -->
<!-- route: +dest_rise        -->
<!-- ************************ -->

  <xsl:template match="route[not(src_rise)]
                           [key('Enclosure',source/id)/depth]
                           [key('Enclosure',destination/id)/depth]
                    " 
              mode="recursive_diagram_enrichment"
              priority="169"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <src_rise>
        <xsl:value-of select="key('Enclosure',source/id)/depth - 
                                (  ancestor::*
                                      intersect
                                   (key('Enclosure',destination/id)/ancestor::*)
                                )[last()]/depth
                                      "/>
      </src_rise>
      <dest_rise>
                <xsl:value-of select="key('Enclosure',destination/id)/depth - 
                                (  ancestor::*
                                      intersect
                                   (key('Enclosure',destination/id)/ancestor::*)
                                )[last()]/depth
                                      "/>
      </dest_rise>
    </xsl:copy>
  </xsl:template>

</xsl:transform>