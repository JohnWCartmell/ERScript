<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

 

<xsl:output method="xml" indent="yes"/>
<!-- ********************************************************** -->
<!--                                                            -->
<!-- See specification and rationale in change note 18 May 2025 -->
<!--                                                            -->
<!-- ********************************************************** -->


<!-- ***************************************************** -->
<!-- route/(source|destination)/top_edge +labelPosition  -->
<!-- ***************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
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

<!-- ***************************************************** -->
<!-- route/(source|destination)/left_side+labelPosition  -->
<!-- ***************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
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

<!-- ***************************************************** -->
<!-- route/(source|destination)/bottom_edge +labelPosition  -->
<!-- ***************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
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

<!-- ***************************************************** -->
<!-- route/(source|destination)/right_side +labelPosition  -->
<!-- ***************************************************** -->

<!-- experiment to see of possible to use bearing -->
<xsl:template match="route
                     /*[self::source[../path/*/startarm/bearing]|self::destination]
                     /right_side
                     [slotNo]
                     [noOfSlots]    
                     [not(labelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <bearing><xsl:value-of select="..[self::source]/../path/*/startarm/bearing"/></bearing>
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

</xsl:transform>

