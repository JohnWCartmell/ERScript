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
<!-- route[top_down]/source  +bottom_edge  -->
<!-- ************************************* -->

<xsl:template match="route[top_down]
                     /source
					 [not(bottom_edge)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <bottom_edge>
		  <annotate_left/>
      </bottom_edge>
   </xsl:copy>
</xsl:template>

<!-- ************************************* -->
<!-- route[top_down]/source  +bottom_edge  -->
<!-- ************************************* -->

<xsl:template match="route[top_down]
                     /destination
					 [not(top_edge)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <top_edge>
		  <annotate_right/>
      </top_edge>
   </xsl:copy>
</xsl:template>


<xsl:template match="route[sideways]
                     /source
                [not(left_side)]
                [not(right_side)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>

      <xsl:choose>
         <xsl:when test="//enclosure[id=current()/id] &lt;&lt; //enclosure[id=current()/../destination/id]">
            <right_side>
               <annotate_low/>
            </right_side>
         </xsl:when>
         <xsl:otherwise>
            <left_side>
               <annotate_low/>
            </left_side>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:copy>
</xsl:template>

<xsl:template match="route[sideways]
                     /destination
                [not(left_side)]
                [not(right_side)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:choose>
         <xsl:when test="//enclosure[id=current()/../source/id] &lt;&lt; //enclosure[id=current()/id]">
            <left_side>
               <annotate_low/>
            </left_side>
         </xsl:when>
         <xsl:otherwise>
            <right_side>
               <annotate_low/>
            </right_side>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:copy>
</xsl:template>


</xsl:transform>

