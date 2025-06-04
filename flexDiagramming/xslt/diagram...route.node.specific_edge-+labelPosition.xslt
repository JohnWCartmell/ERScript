<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

 

<xsl:output method="xml" indent="yes"/>


<!-- ***************************************************** -->
<!-- route/source/(left_side|top_edge) +labelPosition  -->
<!-- ***************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
                     /*[self::left_side|self::top_edge]
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
            <xsl:when test="slotNo &lt;= (noOfSlots div 2)">
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
<!-- route/source/(right_side|bottom_edge) +labelPosition  -->
<!-- ***************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
                     /*[self::right_side|self::bottom_edge]
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
            <xsl:when test="slotNo &lt;= (noOfSlots div 2)">
                <clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <anti-clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </labelPosition>
   </xsl:copy>
</xsl:template>



</xsl:transform>

