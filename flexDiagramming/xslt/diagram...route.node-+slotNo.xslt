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

<xsl:key name="SourcedAtBottomEdgeOf" match="source[bottom_edge]" use="id"/>

<!-- ************************ -->
<!-- source: +slotNo          -->
<!-- ************************ -->

   <xsl:template match="source
   	                  [bottom_edge]
                        [not(slotNo)]
						[angleToOtherEnd]
						[every $s in //source[bottom_edge][id = current()/id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  
	      <slotNo> 
		       <!-- sequentially numbering of the sources leaving the bottom edge
			        of an enclosure. 
			    -->
		       <xsl:value-of select="count(
											//source[bottom_edge][id = current()/id]
													[number(angleToOtherEnd) &lt; number(current()/angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>
  
 <!-- ************************ -->
<!-- destination: +slotNo          -->
<!-- ************************ -->

   <xsl:template match="destination
   							[top_edge]
                        [not(slotNo)]
						[angleToOtherEnd]
						[every $s in //destination[top_edge][id = current()/id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  
	      <slotNo> 
		       <!-- sequentially numbering of the routes with destination arriving at top_edge 
			        of an enclosure. 
			    -->
			    <!-- one problem is that  relationships with identical source and dest drawn on top of one another! -->
			    <!-- try fix this problem by adding a jiggle factor into the calculation angleToOtherEnd -->
			    <!-- see diagram...route.node-+angleToOtherEnd.xslt -->
		       <xsl:value-of select="count(
											//destination[top_edge][id = current()/id]
													[number(angleToOtherEnd) &lt; number(current()/angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>
  
</xsl:transform>