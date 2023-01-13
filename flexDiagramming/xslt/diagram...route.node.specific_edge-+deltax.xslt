<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->
 
 <!-- <xsl:include href="diagram.functions.module.xslt"/> -->

<xsl:output method="xml" indent="yes"/>


<!-- ************************************* -->
<!-- route/source/bottom_edge  +deltax  -->
<!-- ************************************* -->
<xsl:template match="route
                     /source[slotNo][key('Enclosure',id)/w]/bottom_edge    
					 [not(deltax)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('bottom_edge_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
      <deltax>
		  <xsl:value-of select="(key('Enclosure',../id)/w)  *  (../slotNo + 1) div ($noOfSlots + 1)"/>
      </deltax>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/destination/top_edge  +deltax  -->
<!-- ************************************* -->
<xsl:template match="route
                     /destination[slotNo][key('Enclosure',id)/w]/top_edge    
					 [not(deltax)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('top_edge_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
      <deltax>
        <xsl:value-of select="(key('Enclosure',../id)/w)  *  (../slotNo + 1) div ($noOfSlots + 1)"/>
      </deltax>
   </xsl:copy>
</xsl:template>


</xsl:transform>

