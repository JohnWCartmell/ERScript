<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->
 
 <!-- <xsl:include href="diagram.functions.module.xslt"/> -->

<xsl:output method="xml" indent="yes"/>


<!-- *********** -->
<!-- enclosure/h -->
<!-- *********** -->
<!-- combined below
<xsl:template match="enclosure[not(h)]
                              [not(enclosure|path|stack|label|decoration|point|ns|ew|ramp)]
                              [ancestor-or-self::*/default/hmin[1]]
                    " 
              mode="recursive_diagram_enrichment"
              priority="43">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <h>
        <xsl:value-of select="ancestor-or-self::*/default/hmin[1]"/>
      </h>
   </xsl:copy>
</xsl:template>
-->

<xsl:template match="enclosure[not(h)] 
                              [margin]
                              [ancestor-or-self::*/default/hmin[1]]
                              [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/h  and $e/padding
                               and ( $e/y/relative/*[position()=1][self::offset]
                                     | $e/y/clocal | $e/y/rlocal )
                              ]
                              [every $e in enclosure 
                               satisfies $e/ hb  
                              ]
                              [every $e in enclosure 
                               satisfies not($e/y/clocal) or $e/ ht  
                              ]
                              [every $point in route/path/point
                               satisfies ($point/y/relative/*[position()=1][self::offset]
                                           | $point/y/clocal | $point/y/rlocal) 
								     and ($point/padding)
                              ]
                    "
               mode="recursive_diagram_enrichment"
                             priority="43">

   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	  <!--
	      Note that y/clocal + h = -y/clocal so both 3rd line and 4th term then match each other
	   -->
      <h>
         <xsl:value-of select="max((
		                            ancestor-or-self::*/default/hmin[1],
		                            enclosure/((y/relative/*[position()=1][self::offset])+ h +  hb  + padding),
                                    enclosure/(2 * (y/clocal + h  +  hb  + padding))  + margin,
                                    enclosure/(2 * (-y/clocal  +  ht  + padding)) + margin,
                                    enclosure/(-y/rlocal +  ht  + padding),
                                    *[not(self::enclosure|self::path)]/((y/relative/*[position()=1][self::offset])+ h + padding),
                                    *[not(self::enclosure|self::path)]/(2 * (y/clocal + h  + padding)),
                                    *[not(self::enclosure|self::path)]/((y/rlocal) + h + padding),
                                    route/path/point/(y/relative/*[position()=1][self::offset] + padding)
                                  )) + margin
                               "/> 
      </h>   <!-- replace +w +  hb  for point of path to + hb  for path -->
   </xsl:copy>
</xsl:template>

<!-- ********* -->
<!-- diagram/h -->
<!-- ********* -->
<xsl:template match="diagram[not(h)]
                            [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/h  and $e/padding and $e/y/relative/*[position()=1][self::offset]
                              ]
                              [every $e in enclosure 
                               satisfies $e/ hb  
                              ]
                              [every $point in path/point
                               satisfies $point/y/abs
                              ]
                            
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="43">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <h>
         <xsl:value-of select="max((enclosure/((y/relative/*[position()=1][self::offset])+ h + hb ),
                                    *[not(self::enclosure)]/((y/relative/*[position()=1][self::offset])+ h + padding),
                                    path/point/y/abs
                                  )) 
                               + 2*margin"/>
      </h>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- (point|ns)/h -->
<!-- *********** -->

<xsl:template match="*[self::point|self::ns]
                      [not(h)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="43">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <h>0</h>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- label/h -->
<!-- *********** -->

<xsl:template match="label[not(h)]
                          [text]
                          [text_style]
                    " 
              mode="recursive_diagram_enrichment"
              priority="43">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <h>
	  <!--
	     <xsl:message>Calculating h of <xsl:value-of select="text"/> using <xsl:value-of select="text_style"/></xsl:message>
		 <xsl:message>Font-size is <xsl:value-of select="count(key('text_style',text_style))"/> </xsl:message>
		 -->
        <xsl:value-of select="diagram:stringheight(text, key('text_style',text_style)/font-size div 11) 
                                                        * (if (key('text_style',text_style)/font-weight/*[self::bold|self::bolder])
                                                           then 1.07
                                                            else 1 
                                                          )"/>
      </h>
   </xsl:copy>
</xsl:template>





</xsl:transform>

