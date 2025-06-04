<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

 

<xsl:output method="xml" indent="yes"/>


<!-- ********************************************************** -->
<!-- route/(source|destination)/(right_side|left_side) +deltay  -->
<!-- ********************************************************** -->
<xsl:template match="route
                     /*[self::source|self::destination]
                     [key('Enclosure',id)/h]
                     /*[self::left_side|self::right_side]
                     [slotNo]
                     [noOfSlots]    
					      [not(deltay)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltay>
		  <xsl:value-of select="(key('Enclosure',../id)/h)  *  (slotNo + 1) div (noOfSlots + 1)"/>
      </deltay>
   </xsl:copy>
</xsl:template>


</xsl:transform>

