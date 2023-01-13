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
<!-- enclosure/w -->
<!-- *********** -->
<!-- combined below
<xsl:template match="enclosure[not(w)]
                              [not(enclosure|path|stack|label|decoration|point|ns|ew|ramp)]
                              [ancestor-or-self::*/default/wmin[1]]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <w>
        <xsl:value-of select="ancestor-or-self::*/default/wmin[1]"/>
      </w>
   </xsl:copy>
</xsl:template>
-->

<xsl:template match="enclosure[not(w)] 
                              [margin]
                              [ancestor-or-self::*/default/wmin[1]]
                              [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/w  and $e/padding
                               and ( $e/x/relative/*[position()=1][self::offset]
                                     | $e/x/clocal | $e/x/rlocal )
                              ]
                              [every $e in enclosure 
                               satisfies $e/ wr  
                              ]
                              [every $e in enclosure 
                               satisfies not($e/x/clocal) or $e/ wl  
                              ]
                              [every $point in route/path/point
                               satisfies ($point/x/relative/*[position()=1][self::offset]
                                           | $point/x/clocal | $point/x/rlocal) 
								     and ($point/padding)
                              ]
                    "
               mode="recursive_diagram_enrichment"
                             priority="42">

   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	  <!--
	      Note that x/clocal + w = -x/clocal so both 3rd line and 4th term then match each other
	   -->
      <w>
         <xsl:value-of select="max((
		                            ancestor-or-self::*/default/wmin[1],
		                            enclosure/((x/relative/*[position()=1][self::offset])+ w +  wr  + padding),
                                    enclosure/(2 * (x/clocal + w  +  wr  + padding))  + margin,
                                    enclosure/(2 * (-x/clocal  +  wl  + padding)) + margin,
                                    enclosure/(-x/rlocal +  wl  + padding),
                                    *[not(self::enclosure|self::path)]/((x/relative/*[position()=1][self::offset])+ w + padding),
                                    *[not(self::enclosure|self::path)]/(2 * (x/clocal + w  + padding)),
                                    *[not(self::enclosure|self::path)]/((x/rlocal) + w + padding),
                                    route/path/point/(x/relative/*[position()=1][self::offset] + padding)
                                  )) + margin
                               "/> 
      </w>   <!-- replace +w +  wr  for point of path to + wr  for path -->
   </xsl:copy>
</xsl:template>

<!-- ********* -->
<!-- diagram/w -->
<!-- ********* -->
<xsl:template match="diagram[not(w)]
                            [every $e in enclosure|label|point|ns|ew|ramp
                               satisfies $e/w  and $e/padding and $e/x/relative/*[position()=1][self::offset]
                              ]
                              [every $e in enclosure 
                               satisfies $e/ wr  
                              ]
                              [every $point in path/point
                               satisfies $point/x/abs
                              ]
                            
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <w>
         <xsl:value-of select="max((enclosure/((x/relative/*[position()=1][self::offset])+ w + wr ),
                                    *[not(self::enclosure)]/((x/relative/*[position()=1][self::offset])+ w + padding),
                                    path/point/x/abs
                                  )) 
                               + 2*margin"/>
      </w>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- (point|ns)/w -->
<!-- *********** -->

<xsl:template match="*[self::point|self::ns]
                      [not(w)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <w>0</w>
   </xsl:copy>
</xsl:template>

<!-- *********** -->
<!-- label/w -->
<!-- *********** -->

<xsl:template match="label[not(w)]
                          [text]
                          [text_style]
                    " 
              mode="recursive_diagram_enrichment"
              priority="42">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <w>
	  <!--
	     <xsl:message>Calculating w of <xsl:value-of select="text"/> using <xsl:value-of select="text_style"/></xsl:message>
		 <xsl:message>Font-size is <xsl:value-of select="count(key('text_style',text_style))"/> </xsl:message>
		 -->
        <xsl:value-of select="diagram:stringwidth(text, key('text_style',text_style)/font-size div 11) 
                                                        * (if (key('text_style',text_style)/font-weight/*[self::bold|self::bolder])
                                                           then 1.07
                                                            else 1 
                                                          )"/>
      </w>
   </xsl:copy>
</xsl:template>





</xsl:transform>

