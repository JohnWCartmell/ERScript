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
          endxP => midxP + deltaxP div 2
   -->
  <xsl:template match="path/ramp
                               [not(endxP)]
                               [deltaxP]
                               [point/xP/relative/*[1][self::offset]]
                    "
                                  mode="recursive_diagram_enrichment"

                                  priority="61">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <endxP>
        <xsl:value-of select="point/xP/relative/*[1] + (deltaxP div 2)"/>
      </endxP>
    </xsl:copy>
  </xsl:template>
  
    <!-- path/ew
          endx => startx + deltax 
   -->
  <xsl:template match="path/ewQ
                               [not(endxP)]
                               [deltaxP]
                               [startxP]
                    "
                                  mode="recursive_diagram_enrichment"
                                  priority="61">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <endxP>
        <xsl:value-of select="startxP + deltaxP"/>  
      </endxP>
    </xsl:copy>
  </xsl:template>


    <!-- path/(ewP | ramp) 
          endxP => following point/xP
    -->
  <xsl:template match="path/*[self::ewQ|self::ramp]
                               [not(endxP)]
                               [following-sibling::*[1][self::point]/xP/relative/*[1][self::offset]]
                    "
                                  mode="recursive_diagram_enrichment"

                                  priority="62">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <endxP>
        <xsl:value-of select="following-sibling::*[1][self::point]/xP/relative/*[1][self::offset]"/>
      </endxP>
    </xsl:copy>
  </xsl:template>

</xsl:transform>

