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


<!-- *********** -->
<!-- enclosure/wP -->
<!-- *********** -->
<!-- combined below
<xsl:template match="enclosure[not(wP)]
                              [not(enclosure|path|stack|label|decoration|point|ns|ew|ramp)]
                              [ancestor-or-self::*/default/wminP[1]]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wP>
        <xsl:value-of select="ancestor-or-self::*/default/wminP[1]"/>
      </wP>
   </xsl:copy>
</xsl:template>
-->

<xsl:template match="enclosure[not(wP)] 
                              [margin]
                              [ancestor-or-self::*/default/wminP[1]]
                              [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/wP  and $e/padding
                               and ( $e/xP/relative/*[position()=1][self::offset]
                                     | $e/xP/clocal | $e/xP/rlocal )
                              ]
                              [every $e in enclosure 
                               satisfies $e/wrP  
                              ]
                              [every $e in enclosure 
                               satisfies not($e/xP/clocal) or $e/ wlP  
                              ]
                              [every $point in route/path/point
                               satisfies ($point/xP/relative/*[position()=1][self::offset]
                                           | $point/xP/clocal | $point/xP/rlocal) 
								     and ($point/padding)
                              ]
                    "
               mode="recursive_diagram_enrichment"
                             priority="42.1P">

   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	  <!--
	      Note that xP/clocal + wP = -xP/clocal so both 3rd line and 4th term then match each other
	   -->
      <xsl:variable name="wP" as="xs:double"
            select="max((
                         (ancestor-or-self::*/default/wminP)[last()],
                         enclosure/((xP/relative/*[position()=1][self::offset])+ wP +  wrP  + padding),
                           enclosure/(2 * (xP/clocal + wP  +  wrP  + padding))  + margin,
                           enclosure/(2 * (-xP/clocal  +  wlP  + padding)) + margin,
                           enclosure/(-xP/rlocal +  wlP  + padding),
                           *[not(self::enclosure|self::path)]/((xP/relative/*[position()=1][self::offset])+ wP + padding),
                           *[not(self::enclosure|self::path)]/(2 * (xP/clocal + wP  + padding)),
                           *[not(self::enclosure|self::path)]/((xP/rlocal) + wP + padding),
                           route/path/point/(xP/relative/*[position()=1][self::offset] + padding)
                         )) + margin
                     "/> 
      <!--
      <xsl:message> id <xsl:value-of select="id"/> wminP <xsl:value-of select="(ancestor-or-self::*/default/wminP)[last()]"/> </xsl:message>
   -->
      <wP>
          <xsl:value-of select="$wP"/> 
      </wP>   <!-- replace +w +  wrP  for point of path to + wrP  for path -->
      <trace>wr2</trace> 
   </xsl:copy>
</xsl:template>

<!-- ********* -->
<!-- diagram/wP -->
<!-- ********* -->
<xsl:template match="diagram[not(wP)]
                            [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/wP  and $e/padding and $e/xP/relative/*[position()=1][self::offset]
                              ]
                              [every $e in enclosure 
                               satisfies $e/ wrP  
                              ]
                              [every $point in path/point
                               satisfies $point/xP/abs
                              ]
                            
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="42.1P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wP>
         <xsl:value-of select="max((enclosure/((xP/relative/*[position()=1][self::offset])+ wP + wrP ),
                                    *[not(self::enclosure)]/((xP/relative/*[position()=1][self::offset])+ wP + padding),
                                    path/point/xP/abs
                                  )) 
                               + 2*margin"/>
      </wP>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- (point|ns)/wP -->
<!-- *********** -->

<xsl:template match="*[self::point|self::ns]
                      [not(wP)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="42.1P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <wP>0</wP>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- label/wP -->
<!-- *********** -->

<xsl:template match="label[not(wP)]
                          [text]
                          [text_style]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42.1P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:variable name="textstyle" as="element()"
                    select="key('text_style',text_style)"/>
      <wP>
         <xsl:value-of select="diagram:stringwidth_from_text_styleP(text,$textstyle)"/>
      </wP>
   </xsl:copy>
</xsl:template>


</xsl:transform>

