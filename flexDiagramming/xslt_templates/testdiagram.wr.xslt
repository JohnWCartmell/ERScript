<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
 -->

<xsl:output method="xml" indent="yes"/>

<!-- ************** -->
<!-- encosure  +wr -->
<!-- ************** -->

  <xsl:template match="enclosure
                        [not(wr)]
						[w]
						[every $edge in key('right_side_is_endpoint_of',id)[annotation]
                               satisfies $edge/x_upper_bound
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wr>
	     <xsl:value-of select="max((key('right_side_is_endpoint_of',id)[annotation]/x_upper_bound,
		                            w
		                           )) - w"/>
	  </wr>
    </xsl:copy>
  </xsl:template>
  
<!-- ************** -->
<!-- point  +wr    -->
<!-- ************** -->

  <xsl:template match="point
                        [not(wr)]
						[every $label in label
                               satisfies $label/w  and $label/x/relative/*[1][self::offset]
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wr>
	     <xsl:value-of select="max((label/(w + x/relative/offset[1]) ,
		                            0
		                          ))"/>
	  </wr>
    </xsl:copy>
  </xsl:template>
  
  <!-- 23 September 2021 -->
  <!-- TEMPORARYiLY define wrp of label to be 0-->
    <xsl:template match="label
                        [not(wr)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wr>
	       <xsl:value-of select="0"/>
	     </wr>
    </xsl:copy>
  </xsl:template>

</xsl:transform>

