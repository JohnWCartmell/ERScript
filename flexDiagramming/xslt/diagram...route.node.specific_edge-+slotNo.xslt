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

<!-- *************************** -->
<!-- source/bottom_edge: +slotNo -->
<!-- *************************** -->

   <xsl:template match="source
                        [angleToOtherEnd]
                        /bottom_edge
                        [not(slotNo)]
						
						[every $s in //(source|destination)[bottom_edge][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>	  
	      <slotNo> 
		       <xsl:value-of select="count(
											//(source|destination)[bottom_edge][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>

 <!-- ************************ -->
<!-- source/top_edge: +slotNo  -->
<!-- ************************* -->

   <xsl:template match="source
                        [angleToOtherEnd]
                        /top_edge
                        [not(slotNo)]
						[every $s in //(source|destination)[top_edge][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>	  
	      <slotNo> 
		       <xsl:value-of select="count(
											//(source|destination)[top_edge][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>

<!-- ************************** -->
<!-- source:right_side +slotNo  -->
<!-- ************************** -->

   <xsl:template match="source
                        [angleToOtherEnd]
                        /right_side
                        [not(slotNo)]
						[every $s in //(source|destination)[right_side][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	      <slotNo> 
		       <xsl:value-of select="count(
											//route/(source|destination)[right_side][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>

  <!-- ************************ -->
<!-- source:left_side +slotNo          -->
<!-- ************************ -->

   <xsl:template match="source
                        [angleToOtherEnd]
                        /left_side
                        [not(slotNo)]
						[every $s in //(source|destination)[left_side][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>  
	      <slotNo> 
		       <xsl:value-of select="count(
											//(source|destination)[left_side][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>
  
 <!-- **************************** -->
<!-- destination/top_edge: +slotNo -->
<!-- ***************************** -->

   <xsl:template match="destination
                        [angleToOtherEnd]
                        /top_edge
                        [not(slotNo)]
						[every $s in //(source|destination)[top_edge][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
         <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	      <slotNo> 
		       <xsl:value-of select="count(
											//(source|destination)[top_edge][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		   </slotNo>
       </xsl:copy>
  </xsl:template>
  

 <!-- ******************************* -->
<!-- destination/bottom_edge: +slotNo -->
<!-- ******************************** -->

   <xsl:template match="destination
                        [angleToOtherEnd]
                        /bottom_edge
                        [not(slotNo)]					
						[every $s in //(source|destination)[bottom_edge][id = current()/../id]
                               satisfies $s/angleToOtherEnd
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	      <slotNo> 
		       <xsl:value-of select="count(
											//(source|destination)[bottom_edge][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>

 <!-- ************************ -->
<!-- destination/left_side: +slotNo          -->
<!-- ************************ -->

   <xsl:template match="destination
                        [angleToOtherEnd]
                        /left_side
                        [not(slotNo)]
						
						[every $s in //(source|destination)[left_side][id = current()/../id]
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
											//(source|destination)[left_side][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>


 <!-- ************************ -->
<!-- destination/right_side: +slotNo          -->
<!-- ************************ -->

   <xsl:template match="destination
                        [angleToOtherEnd]
                        /right_side
                        [not(slotNo)]
						
						[every $s in //(source|destination)[right_side][id = current()/../id]
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
											//(source|destination)[right_side][id = current()/../id]
													[number(angleToOtherEnd) &lt; number(current()/../angleToOtherEnd) ]
										  )"/>
		  </slotNo>
       </xsl:copy>
  </xsl:template>


</xsl:transform>