<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
		xmlns="http://www.entitymodelling.org/diagram"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box 

	Remanants after restructure.
    
 -->

	<xsl:output method="xml" indent="yes"/>

	<!-- ************************** -->
	<!-- route  +path       -->
	<!-- ************************** -->

	<xsl:template match="route[top_down]
						 [not(path)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<path>
				<ew><source_sweep/></ew>
				<ramp/>
				<ew><destination_sweep/></ew>
			</path>
		</xsl:copy>
	</xsl:template>


	<!-- ************************** -->
	<!-- route  +path       -->
	<!-- ************************** -->
	<xsl:template match="route[sideways]
						[not(path)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<path>
				<ramp/>
			</path>
		</xsl:copy>
	</xsl:template>


	<!-- ***************************** -->
	<!--   source is right_side            -->
	<!--   add deltax to ew startarm   -->
	<!-- ***************************** -->
	<xsl:template match="route
						[source/right_side]
						[source/endline_style]
						[key('box',source/id)/wr]
						/path/ew[startarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">		  
		<xsl:copy>
			<deltax>
				<xsl:value-of select="max((
					key('endline_style',../../source/endline_style)/minarmlen ,
					key('box', ../../source/id)/wr
					))"/>
			</deltax>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<!-- ************************** -->
	<!-- source is left_side        -->
	<!--   add deltax to ew startarm   -->
	<!-- ************************** -->
	<xsl:template match="route
						[source/left_side]
						[source/endline_style]
						[key('box',source/id)/wl]
						/path/ew[startarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">		  
		<xsl:copy>
			<deltax>
				<xsl:value-of select="max((
					key('endline_style',../../source/endline_style)/minarmlen ,
					key('box', ../../source/id)/wl
					))"/>
			</deltax>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>


	<!-- ************************** -->
	<!-- destination is left_side           -->
	<!--   add deltax to ew endarm   -->
	<!-- ************************** -->
	<xsl:template match="route
						[destination/left_side]
						[destination/id]
						[destination/endline_style]
						[key('box',destination/id)/wl]
						/path/ew[endarm] 
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="41">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltax>
				<xsl:value-of select="max((
					key('endline_style',../../destination/endline_style)/minarmlen ,
					key('box',../../destination/id)/wl
					))"/>
			</deltax>
		</xsl:copy>
	</xsl:template>

	<!-- ************************** -->
	<!-- destination is right_side         -->
	<!--   add deltax to ew endarm   -->
	<!-- ************************** -->
	<xsl:template match="route
						[destination/right_side]
						[destination/endline_style]
						[key('box',destination/id)/wr]
						/path/ew[endarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="41">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltax>
				<xsl:value-of select="- max((
					key('endline_style',../destination/endline_style)/minarmlen ,
					key('box',../../destination/id)/wr
					))"/>
			</deltax>
		</xsl:copy>
	</xsl:template>

	<!-- ************************** -->
	<!-- source is bottom_edge         -->
	<!--   add deltay to ns startrarm   -->
	<!-- ************************** -->

	<xsl:template match="route
						[source/bottom_edge]
						[source/endline_style]
						[key('box',source/id)/hb]
						/path/ns[startarm]
						[not(deltay)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltay>
				<xsl:value-of select="max((
					key('endline_style',../../source/endline_style)/minarmlen ,
					key('box',../../source/id)/hb
					))"/>
			</deltay>
		</xsl:copy>
	</xsl:template>
	
	<!-- ************************** -->
	<!-- destination is top_edge         -->
	<!--   add deltay to ns startrarm   -->
	<!-- ************************** -->

	<xsl:template match="route
						[destination/top_edge]
						[destination/endline_style]
						[key('box',destination/id)/ht]
						/path/ns[endarm]
						[not(deltay)]
						" 
			mode="recursive_diagram_enrichment"
			priority="40">
		<xsl:copy>
			<deltay>
				<xsl:value-of select="max((
					key('endline_style',../../destination/endline_style)/minarmlen ,
					key('box',../../destination/id)/ht
					))"/>
			</deltay>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

