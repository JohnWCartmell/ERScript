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
<!--                                                            -->
<!-- See specification and rationale in change note 18 May 2025 -->
<!--                                                            -->
<!-- ********************************************************** -->

<xsl:template match="*[self::left_side|self::top_edge|self::right_side|self::bottom_edge]  
					      [labelPosition]
                     [not(secondaryLabelPosition)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="44.5">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <secondaryLabelPosition>
         <xsl:choose>
            <xsl:when test="labelPosition/clockwise">
                <anti-clockwise/>
            </xsl:when>
            <xsl:otherwise>
                  <clockwise/>
            </xsl:otherwise>
         </xsl:choose>
      </secondaryLabelPosition>
   </xsl:copy>
</xsl:template>

     

</xsl:transform>

