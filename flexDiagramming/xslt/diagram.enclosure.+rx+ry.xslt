<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->

<xsl:output method="xml" indent="yes"/>



<xsl:template match="enclosure
                        [framearc]
                        [w]
                        [h]
	                     [not(rx)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="80.11" >
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <rx>
         <xsl:value-of select="fn:min((h,w))*framearc div 2"/>
      </rx>
   </xsl:copy>
</xsl:template>

<xsl:template match="enclosure
                        [framearc]
                        [w]
                        [h]
                        [not(ry)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="80.12" >
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <ry>
         <xsl:value-of select="fn:min((h,w))*framearc div 2"/>
      </ry>
   </xsl:copy>
</xsl:template>



</xsl:transform>

