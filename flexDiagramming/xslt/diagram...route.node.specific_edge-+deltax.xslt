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


<!-- ************************************* -->
<!-- route/source/bottom_edge  +deltax  -->
<!-- ************************************* -->
<xsl:template match="route
                     /source[key('Enclosure',id)/w]
                     /bottom_edge[slotNo]
                     [noOfSlots]    
					      [not(deltax)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax>
		  <xsl:value-of select="(key('Enclosure',../id)/w)  *  (slotNo + 1) div (noOfSlots + 1)"/>
      </deltax>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/destination/top_edge  +deltax  -->
<!-- ************************************* -->
<xsl:template match="route
                     /destination[key('Enclosure',id)/w]
                     /top_edge[slotNo]
                     [noOfSlots]        
					      [not(deltax)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax>
        <xsl:value-of select="(key('Enclosure',../id)/w)  *  (slotNo + 1) div (noOfSlots + 1)"/>
      </deltax>
   </xsl:copy>
</xsl:template>


</xsl:transform>

