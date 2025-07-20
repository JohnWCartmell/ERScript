<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
24-Oct-2024  No longer create of noOfSlots here. See change note 24-Oct-2024. 
 -->
 
 <!-- <xsl:include href="diagram.functions.module.xslt"/> -->

<xsl:output method="xml" indent="yes"/>



<!-- *********************************************************** -->
<!-- route/(source|destination)/(top_edge|bottom_edge)  +deltax  -->
<!-- *********************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
                     [key('Enclosure',id)/w]
                     /*[self::top_edge|self::bottom_edge]
                     [slotNo]
                     [noOfSlots]    
                     [not(deltax)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax>
        <!--Modified in change of 18th May 2025 -->
        <xsl:value-of select="
          let $w := key('Enclosure',../id)/w
          return if (noOfSlots &gt; 2)
                then (($w div noOfSlots) div 2) + (($w*slotNo) div (noOfSlots))
                else $w  *  (slotNo + 1) div (noOfSlots + 1)
                            "/>
        </deltax>
   </xsl:copy>
</xsl:template>

</xsl:transform>

