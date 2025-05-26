<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
24-Oct-2024  Created. See change note 24-Oct-2024. 
 -->
 
 <!-- <xsl:include href="diagram.functions.module.xslt"/> -->

<xsl:output method="xml" indent="yes"/>


<!-- ************************************* -->
<!-- route/source/bottom_edge  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /source[key('Enclosure',id)/w]/bottom_edge    
					 [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('bottom_edge_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/destination/top_edge  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /destination[key('Enclosure',id)/w]/top_edge    
					 [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('top_edge_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/source/right_side  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /source[key('Enclosure',id)/w]/right_side    
                [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('right_side_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/source/left_side  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /source[key('Enclosure',id)/w]/left_side    
                [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('left_side_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route/destination/left_side  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /destination[key('Enclosure',id)/w]/left_side    
                [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('left_side_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>
<!-- ************************************* -->
<!-- route/destination/right_side  +noOfSlots  -->
<!-- ************************************* -->
<xsl:template match="route
                     /destination[key('Enclosure',id)/w]/right_side    
                [not(noOfSlots)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="noOfSlots" as="xs:integer" select="count((key('right_side_is_endpoint_of',../id)))"/>
      <noOfSlots><xsl:value-of select="$noOfSlots"/></noOfSlots>
   </xsl:copy>
</xsl:template>



</xsl:transform>

