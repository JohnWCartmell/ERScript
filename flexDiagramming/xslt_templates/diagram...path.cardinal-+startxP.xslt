<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

  <!--  Maintenance Box 

 -->

  <xsl:output method="xml" indent="yes"/>

  

  <!-- path/ramp
          startxP => midxP - deltaxP div 2
  -->
  <xsl:template match="path/ramp[not(startxP)]
                               [deltaxP]
                               [point/xP/relative/*[1][self::offset]]
                    "
                                  mode="recursive_diagram_enrichment"

                                  priority="59">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <startxP>
        <xsl:value-of select="point/xP/relative/*[1][self::offset] - (deltaxP div 2)"/>
      </startxP>
    </xsl:copy>
  </xsl:template>
  
    <!-- path/ewQ
          startxP => endxP - deltaxP
  -->
  <xsl:template match="path/ewQ
                               [not(startxP)]
                               [deltaxP]
                               [endxP]
                    "
                                  mode="recursive_diagram_enrichment"
                                  priority="59">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <startxP>
        <xsl:value-of select="number(endxP) - number(deltaxP)"/>
      </startxP>
    </xsl:copy>
  </xsl:template>
  

   <!-- path/(ewQ | ramp) 
          startxP => previous point/xP
    -->
  <xsl:template match="path/*[self::ewQ|self::ramp]
                               [not(startxP)]
                               [preceding-sibling::*[1][self::point]/xP/relative/*[1][self::offset]]
                    "
                                  mode="recursive_diagram_enrichment"

                                  priority="60P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <startxP>
        <xsl:value-of select="preceding-sibling::*[1][self::point]/xP/relative/*[1][self::offset]"/>
      </startxP>
    </xsl:copy>
  </xsl:template>

</xsl:transform>

