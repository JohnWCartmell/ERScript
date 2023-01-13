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


	<!-- ********************************************** -->
	<!-- route/path[lhs]/point[startpoint]/label   +xP  -->
	<!-- ********************************************** -->

	<!-- source is left_sideP -->
	<xsl:template match="route
                       [source/left_sideP]
					   /path/point[startpoint]/label
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="-key('endline_style',../../../source/endline_style)/label_long_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
    <!-- source is right_sideP -->
	<xsl:template match="route
                       [source/right_sideP]
					   /path/point[startpoint]/label
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="key('endline_style',../../../destination/endline_style)/label_long_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
	<!-- ********************************************** -->
	<!-- route/path/point[endpoint]/label   +xP  -->
	<!-- ********************************************** -->

	<!-- destination is left_sideP -->
	<xsl:template match="route
                       [destination/left_sideP]
					   /path/point[endpoint]/label
					   [wP]
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="-wP - key('endline_style',../../../source/endline_style)/label_long_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
    <!-- destination is right_sideP -->
	<xsl:template match="route
                       [destination/right_sideP]
					   /path/point[endpoint]/label
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="key('endline_style',../../../destination/endline_style)/label_long_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
	
	
	<!-- ******************************** -->
	<!-- path/point[startpoint]   +xP  -->
	<!-- ******************************** -->

	<!-- source annotation  is annotate_leftQ-->
	<xsl:template match="route
                       [source/*/annotate_leftQ]
					   /path/point[startpoint]/label[wP]
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="-key('endline_style',../../../source/endline_style)/label_lateral_offset
				                      - wP"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
		<!-- source annotation is  annotate_rightQ -->
	<xsl:template match="route
                       [source/*/annotate_rightQ]
					   /path/point[startpoint]/label
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="key('endline_style',../../../source/endline_style)/label_lateral_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
		<!-- ******************************** -->
	<!-- path/point[endpoint]   +xP  -->
	<!-- ******************************** -->
	
	<!-- destination annotation  is annotate_leftQ-->
	<xsl:template match="route
                       [destination/*/annotate_leftQ]
					   /path/point[endpoint]/label[wP]
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="-key('endline_style',../../../destination/endline_style)/label_lateral_offset
				                      - wP"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	
		<!-- destination annotation is annotate_rightQ-->
	<xsl:template match="route
                       [destination/*/annotate_rightQ]
					   /path/point[endpoint]/label
					   [not(xP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xP>
			  <local>
				<xsl:value-of select="key('endline_style',../../../destination/endline_style)/label_lateral_offset"/>
			  </local>
			</xP>
		</xsl:copy>
	</xsl:template>
	

</xsl:transform>

