<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
		xmlns="http://www.entitymodelling.org/diagram"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box 

    22/01/2022  What are these rules about - are they used ?

    Not to be comfused with diagram...route-+path. Some rules moved from here into there.

    22/03/2023 Added logic to increment the start arm lengths of top down relationsships.
               I haven't touched sideways relationships at this point because quite a bit of work needed to 
               calculate slotNos and deltays for sideways relationships. The logic for topdown angles from
               whence slotNos follow is described in daybook September 19th 2021.
               In the absence of this right_side/deltay and left_side deltay are planted with value 0.5 by ERmodel2flex.
 -->

	<xsl:output method="xml" indent="yes"/>


	<!-- ***************************** -->
	<!--   source is right_side            -->
	<!--   add deltax to ew startarm   -->
	<!-- ***************************** -->
	<xsl:template match="route
						[source/right_side]
						[source/line_style]
						[key('box',source/id)/wr]
						/path/ew[startarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="250">		  
		<xsl:copy>
			<deltax>
				<xsl:value-of select="max((
					key('line_style',../../source/line_style)/minarmlen ,
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
						[source/line_style]
						[key('box',source/id)/wl]
						/path/ew[startarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="250">		  
		<xsl:copy>
			<deltax>
				<xsl:value-of select="max((
					key('line_style',../../source/line_style)/minarmlen ,
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
						[destination/line_style]
						[key('box',destination/id)/wl]
						/path/ew[endarm] 
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="251">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltax>
				<xsl:value-of select="max((
					key('line_style',../../destination/line_style)/minarmlen ,
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
						[destination/line_style]
						[key('box',destination/id)/wr]
						/path/ew[endarm]
						[not(deltax)]
						" 
			mode="recursive_diagram_enrichment"
			priority="241">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltax>
				<xsl:value-of select="- max((
					key('line_style',../destination/line_style)/minarmlen ,
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
						[source/bottom_edge/noOfSlots]
						[source/slotNo]
						[source/line_style]
						[key('box',source/id)/hb]
						/path/ns[startarm]
						[not(deltay)]
						" 
			mode="recursive_diagram_enrichment"
			priority="240">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<deltay>
				<xsl:value-of select="max((
					key('line_style',../../source/line_style)/minarmlen
					         + ../../source/((bottom_edge/noOfSlots div 2 - abs(bottom_edge/noOfSlots div 2 - slotNo)) * 0.1), 
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
						[destination/top_edge/noOfSlots]
						[destination/slotNo]
						[destination/line_style]
						[key('box',destination/id)/ht]
						/path/ns[endarm]
						[not(deltay)]
						" 
			mode="recursive_diagram_enrichment"
			priority="240">
		<xsl:copy>
			<deltay>
				<xsl:value-of select="max((
					key('line_style',../../destination/line_style)/minarmlen 
					           + ../../destination/((top_edge/noOfSlots div 2 - abs(top_edge/noOfSlots div 2 - slotNo)) * 0.1),
					key('box',../../destination/id)/ht
					))"/>
			</deltay>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

