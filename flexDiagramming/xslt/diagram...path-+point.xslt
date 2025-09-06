<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box 

 -->

	<xsl:output method="xml" indent="yes"/>



    <!-- cardinals (ns, ew, ramp) have points -->
    <!-- for a ns or a ew these are a way of shoving an x or a y from one end to the other -->
	<xsl:template match="path/ns[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point><rule> ns populated with empty point "diagram...path-+point.xslt"</rule></point>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="path/ew[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point><rule> ew populated with empty point "diagram...path-+point.xslt"</rule></point>
		</xsl:copy>
	</xsl:template>

<!-- 
***************
	Removed 02/06/2025 because it doesn't seem to be needed 
***************
   <xsl:template match="path/ramp[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point/>
		</xsl:copy>
	</xsl:template> 
	*************
	-->

	<!--  
    Between two successive cardinals a point should be inserted 
    <ns/><ew/> ==> <ns/><point/><ew/>
    <ew/><ns/> ==> <ew/><point/><ns/>
	
	Happily these rules do not conflict with insertion of startpoint and endpoint into a route/path.
	Presumable because these other rules jump in first.
-->
	<!-- ********* -->
	<!-- path/ns  -->
	<!-- ********* -->
	<xsl:template match="path/ns
	                        [not(startarm)]
	                        [not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54" >
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point><rule> ns (not startarm)followed by empty point "diagram...path-+point.xslt"</rule></point>
	</xsl:template>

		<!-- ********* -->
	<!-- route/path/ns(startarm)  -->
	<!-- ********* -->
	<xsl:template match="route
	                       [source
	                       		[bottom_edge]
	                          [exitContainer]
	                          [sweep_length]
	                       ]
	                       /path/ns
	                        [startarm]
	                        [not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54" >
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<xsl:message> new point/y rule FIRING!!  </xsl:message> 
		<xsl:variable name="container" as="xs:string"
		              select="../../source/(if (sweep_length = 0) then id else exitContainer)"/>
		<xsl:variable name="distance" as="xs:double"
		              select="../../source/(
	                                  let $increment := 0.1,
																		$slotNo := bottom_edge/slotNo,
																		$noOfSlots := bottom_edge/noOfSlots,
																		$noOfIncrements := if ($slotNo &lt; ($noOfSlots div 2))
																		                   then $slotNo
																		                   else $noOfSlots - $slotNo - 1
																		return max((
																			key('line_style',line_style)/minarmlen
																			         + $noOfIncrements * $increment, 
																			key('box',id)/hb
																			))
																				)
		                                   "/>
		<point><rule> ns startarm followed by point and y at expression "diagram...path-+point.xslt"</rule>
			     <y>
			     	<at><bottom/><of><xsl:value-of select="$container"/></of></at>
			     	<delta><xsl:value-of select="$distance"/></delta>
			     </y>
		</point>
	</xsl:template>


	<!-- ********* -->
	<!-- path/ew  -->
	<!-- ********* -->
	<xsl:template match="path/ew[deltax and not(deltax = 0)][not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point><rule> ew with non-zero deltax to be followed by empty point "diagram...path-+point.xslt"</rule></point>
	</xsl:template>

	<!-- ********* -->
	<!-- path/ramp  -->
	<!-- ********* -->
	<xsl:template match="path/ramp[not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point><rule> ramp followed by empty point "diagram...path-+point.xslt"</rule></point>
	</xsl:template>



</xsl:transform>

