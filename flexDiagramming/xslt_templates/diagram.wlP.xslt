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

<!-- *************** -->
<!-- enclosure + wl -->
<!-- *************** -->
<!-- used to use the key 'is_endpoint_of' but changed to break a circularity - see notes of 20/21 September 2021 -->
  <xsl:template match="enclosure
                        [not(wlP)]
						[every $edge in key('left_sideP_is_endpoint_of',id)[annotation]
                               satisfies $edge/x_lower_boundP
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wlP>
	     <xsl:value-of select="- min((key('left_sideP_is_endpoint_of',id)[annotation]/x_lower_boundP ,
		                              0
		                             ))"/>
	  </wlP>
    </xsl:copy>
  </xsl:template>
  
<!-- *************** -->
<!-- point + wlP     -->
<!-- *************** -->
<!-- padding of labels taken account of in change of 11-Nov-2024 -->
  <xsl:template match="point
                        [not(wlP)]
						[every $label in label
                               satisfies $label/xP/relative/*[1][self::offset]
                                         and $label/padding
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:if test="some $label in label satisfies not( $label/xP/relative/offset[1] castable as xs:double)">
        <xsl:for-each select="label">
        <xsl:message>about to bomb win wlP  offset is not numeric all label xP's 
                          <xsl:value-of select="xP/relative/offset[1]"/>
                          count of offsets <xsl:value-of select="count(xP/relative/offset)"/>
                          copy of label <xsl:copy-of select="."/>
                         </xsl:message>
        </xsl:for-each>

        <xsl:message terminate="yes">in wlP  offset is not numeric all label x's 
                         </xsl:message>
      </xsl:if>
      <wlP>
	     <xsl:value-of select="- min((label/(xP/relative/offset[1]-padding) ,
		                            0
		                          ))"/>
	  </wlP>
    </xsl:copy>
  </xsl:template>
  
<!-- *************** -->
<!-- TEMPORARY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 23 September 2021     -->
<!-- *************** -->

  <xsl:template match="label
                        [not(wlP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wlP>
	     <xsl:value-of select="0"/>
	  </wlP>
    </xsl:copy>
  </xsl:template>
  

</xsl:transform>

