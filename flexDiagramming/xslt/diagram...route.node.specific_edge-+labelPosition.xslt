<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

 

<xsl:output method="xml" indent="yes"/>
<!-- ********************************************************** -->
<!-- ********************************************************** -->
<!--                                                            -->
<!-- See specification and rationale in change note 18 May 2025 -->
<!--                                                            -->
<!-- ********************************************************** -->
<!-- ********************************************************** -->


<!--********************************************************** -->
<!--    FOUR rules for non-ramps i.e. for cardinal ns and ew   -->
<!--********************************************************** -->

<!-- ******************************************************** -->
<!-- 1. route/(source|destination)/top_edge +labelPosition    -->
<!-- ******************************************************** -->

<xsl:template match="route
                     /*[  self::source[not(../path/ramp/startarm)]
                        | self::destination[not(../path/ramp/endarm)]
                       ]
                     /top_edge
                     [slotNo]
                     [noOfSlots]    
					      [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:choose>
            <xsl:when test="slotNo = ((noOfSlots - 1) div 2)">
                <!-- centre slot of an odd number -->
                <clockwise/>
            </xsl:when>
            <xsl:when test="(slotNo + 1) &lt;= (noOfSlots div 2)">
		          <anti-clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </labelPosition>
   </xsl:copy>
</xsl:template>

<!-- ****************************************************** -->
<!-- 2. route/(source|destination)/left_side+labelPosition  -->
<!-- ****************************************************** -->
<xsl:template match="route
                     /*[  self::source[not(../path/ramp/startarm)]
                        | self::destination[not(../path/ramp/endarm)]
                       ]
                     /left_side
                     [slotNo]
                     [noOfSlots]    
                     [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:choose>
            <xsl:when test="slotNo = ((noOfSlots - 1) div 2)">
                <!-- middle slot of an odd number -->
                <anti-clockwise/>
            </xsl:when>
            <xsl:when test="(slotNo + 1) &lt;= (noOfSlots div 2)">
                <clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <anti-clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </labelPosition>
   </xsl:copy>
</xsl:template>

<!-- ********************************************************* -->
<!-- 3. route/(source|destination)/bottom_edge +labelPosition  -->
<!-- ********************************************************* -->
<xsl:template match="route
                     /*[  self::source[not(../path/ramp/startarm)]
                        | self::destination[not(../path/ramp/endarm)]
                       ]
                     /bottom_edge
                     [slotNo]
                     [noOfSlots]    
                     [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:choose>
            <xsl:when test="slotNo = ((noOfSlots - 1) div 2)">
                <!-- centre slot of an odd number -->
                <clockwise/>
            </xsl:when>
            <xsl:when test="(slotNo + 1) &lt;= (noOfSlots div 2)">
                <clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <anti-clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </labelPosition>
   </xsl:copy>
</xsl:template>

<!-- ******************************************************** -->
<!-- 4. route/(source|destination)/right_side +labelPosition  -->
<!-- ******************************************************** -->


<xsl:template match="route
                     /*[  self::source[not(../path/ramp/startarm)]
                        | self::destination[not(../path/ramp/endarm)]
                       ]
                     /right_side
                     [slotNo]
                     [noOfSlots]    
                     [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:choose>
            <xsl:when test="slotNo = ((noOfSlots - 1) div 2)">
                <!-- middle slot of an odd number -->
                <anti-clockwise/>
            </xsl:when>
            <xsl:when test="(slotNo + 1) &lt;= (noOfSlots div 2)">
                <anti-clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </labelPosition>
   </xsl:copy>
</xsl:template>

<!--********************************************* -->
<!--              FOUR rules for ramps            -->
<!--********************************************* -->

<xsl:template match="route
                     /*[  self::source[../path/ramp/startarm/bearing]
                        | self::destination[../path/ramp/endarm/bearing]
                       ]
                     /top_edge   
                          [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:variable name="defaultLabelPosition" as="xs:string" select="
              let $bearing := if (..[self::source])
                              then ../../path/ramp/startarm/bearing
                              else ../../path/ramp/endarm/bearing
              return if ($bearing &gt; (3 * math:pi() div 2))
                     then 'clockwise'
                     else 'anti-clockwise'
                              "/>
        <xsl:element name="{$defaultLabelPosition}"/>        
      </labelPosition>
   </xsl:copy>
</xsl:template>

<xsl:template match="route
                     /*[  self::source[../path/ramp/startarm/bearing]
                        | self::destination[../path/ramp/endarm/bearing]
                       ]
                     /left_side   
                          [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:variable name="defaultLabelPosition" as="xs:string" select="
              let $bearing := if (..[self::source])
                              then ../../path/ramp/startarm/bearing
                              else ../../path/ramp/endarm/bearing
              return if ($bearing &lt; (3 * math:pi() div 2))
                     then 'clockwise'
                     else 'anti-clockwise'
                              "/>
        <xsl:element name="{$defaultLabelPosition}"/> 
      </labelPosition>
   </xsl:copy>
</xsl:template>
<xsl:template match="route
                     /*[  self::source[../path/ramp/startarm/bearing]
                        | self::destination[../path/ramp/endarm/bearing]
                       ]
                     /bottom_edge   
                          [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:variable name="defaultLabelPosition" as="xs:string" select="
              let $bearing := if (..[self::source])
                              then ../../path/ramp/startarm/bearing
                              else ../../path/ramp/endarm/bearing
              return if ($bearing &lt; math:pi()) 
                     then 'clockwise'
                     else 'anti-clockwise'
                              "/>
        <xsl:element name="{$defaultLabelPosition}"/> 
      </labelPosition>
   </xsl:copy>
</xsl:template>
<xsl:template match="route
                     /*[  self::source[../path/ramp/startarm/bearing]
                        | self::destination[../path/ramp/endarm/bearing]
                       ]
                     /right_side   
                          [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <labelPosition>
         <xsl:variable name="defaultLabelPosition" as="xs:string" select="
              let $bearing := if (..[self::source])
                              then ../../path/ramp/startarm/bearing
                              else ../../path/ramp/endarm/bearing
              return if ($bearing &lt; (math:pi() div 2))
                     then 'clockwise'
                     else 'anti-clockwise'
                              "/>
        <xsl:element name="{$defaultLabelPosition}"/> 
      </labelPosition>
   </xsl:copy>
</xsl:template>

</xsl:transform>

