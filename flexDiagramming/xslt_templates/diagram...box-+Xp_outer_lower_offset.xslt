<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box ->
23 September 2021 Introduce calculated attributes x_outer_lower_offset and y_outer_lower_offset and then use                 
                  to then simplify other rules.  Thereby fix a bug in the rule for xP.at.offset
				  erroneously uses non-existent attribute wr of label. 
 -->

<xsl:output method="xml" indent="yes"/>

<!-- ********************************* -->
<!-- enclosure  +xP_outer_lower_offset -->
<!-- ********************************* -->
<xsl:template match="enclosure
                     [not(xP_outer_lower_offset)]
					 [wlP]
					 [padding]
                    " mode="recursive_diagram_enrichment"
              priority="50.2P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xP_outer_lower_offset>
	     <xsl:value-of select="- wlP  - padding"/>
      </xP_outer_lower_offset>
   </xsl:copy>
</xsl:template>

<!-- *********************************** -->
<!-- point|label  +xP_outer_lower_offset -->
<!-- *********************************** -->
<xsl:template match="*[self::point|self::label]
                     [not(xP_outer_lower_offset)]
					 [padding]
                    " mode="recursive_diagram_enrichment"
              priority="50.2P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xP_outer_lower_offset>
	     <xsl:value-of select="- padding"/>
      </xP_outer_lower_offset>
   </xsl:copy>
</xsl:template>



</xsl:transform>

