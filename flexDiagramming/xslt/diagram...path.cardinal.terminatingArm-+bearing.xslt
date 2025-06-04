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



<!-- ************************************************************ -->
<!-- See change note of 18 May 2025 for rationale for these rules -->
<!-- ************************************************************ -->
<!-- `bearing` is measured in radians and is the clockwise angle from the negative y axis i.e. is the compass bearing measured in radians. -->

<!-- ************************ -->
<!-- ns/startarm: +bearing -->
<!-- ************************ -->
<xsl:template match="path
                    /ns
                    /startarm
                        [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="if (../../../source/top_edge) then 0 else math:pi()"/>
		  </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ns/endarm: +bearing -->
<!-- ************************ -->
<xsl:template match="path
                     /ns
                     /endarm
                     [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
        <bearing>
            <xsl:value-of select="if (../../../destination/top_edge) then 0 else math:pi()"/>
        </bearing>
    </xsl:copy>
</xsl:template>


<!-- ************************ -->
<!-- ew/startarm: +bearing -->
<!-- ************************ -->
<xsl:template match="path
                     /ew
                     /startarm
                     [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="if (../../../source/right_side)
		                            then math:pi() div 2 
		                            else 3* math:pi() div 2"/>
		  </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ew/endarm: +bearing -->
<!-- ************************ -->
<xsl:template match="path
                     /ew
                     /endarm
                     [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
        <bearing>
            <xsl:value-of select="if (../../../destination/right_side)
                                  then math:pi() div 2 
                                  else 3* math:pi() div 2"/>
        </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ramp/startarm: +bearing -->
<!-- ************************ -->
<!-- NEED OTHER VERSION WITH ANGLE -->
<xsl:template match="path/ramp
                        [startx]
                        [endx]
                        [starty]
                        [endy]
                        /startarm
                        [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis
		                             (../endx - ../startx,
		                              ../endy - ../starty
		                             )"/>
		  </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ns/endarm: +bearing -->
<!-- ************************ -->

<xsl:template match="path/ns
                        [starty]
                        [endy]
                        /endarm
                        [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="if (../starty &lt; ../endy) then math:pi() else 0"/>
		  </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ew/endarm: +bearing -->
<!-- ************************ -->

<xsl:template match="path/ew
                        [startx]
                        [endx]
                        /endarm
                        [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="if (../startx &lt; ../endx)
		                            then 3* math:pi() div 2
		                            else math:pi() div 2"/>
		  </bearing>
    </xsl:copy>
</xsl:template>

<!-- ************************ -->
<!-- ramp/endarm: +bearing -->
<!-- ************************ -->

<xsl:template match="path/ramp
                        [startx]
                        [endx]
                        [starty]
                        [endy]
                        /endarm
                        [not(bearing)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40.3">
    <xsl:copy>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <bearing>
		      <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis
		                             (../startx -../endx,
		                              ../starty - ../endy
		                             )"/>
		  </bearing>
    </xsl:copy>
</xsl:template>


</xsl:transform>