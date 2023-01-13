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
	      <!--<deltax>0.75</deltax>-->
		  <annotate_right/>
      </top_edge>
   </xsl:copy>
</xsl:template>


</xsl:transform>

