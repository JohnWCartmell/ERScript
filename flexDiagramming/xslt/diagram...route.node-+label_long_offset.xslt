<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box
		Created for Change 5-Nov-2024. 
	-->

	<xsl:output method="xml" indent="yes"/>

	<!-- ************************************************************** -->
	<!-- route/(source|destination) +label_lateral_offset  -->
	<!-- ************************************************************** -->
                                 
	<xsl:template match="route/*[self::source|self::destination]
                         [line_style]
					     [not(label_lateral_offset)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="260">		

		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<!-- <xsl:message>linestyle <xsl:value-of select="line_style"/></xsl:message> -->
			<!-- TBD max out with endline/style -->
			<xsl:variable name="linestyle" 
			              as="element()"
			              select="key('line_style',line_style)"/>
			<!-- TBD max out with endline/style -->
			<label_lateral_offset>
				<xsl:value-of select="$linestyle/label_lateral_offset"/>
			</label_lateral_offset>
		</xsl:copy>
	</xsl:template>

	<!-- ************************************************************** -->
	<!-- route/(source|destination)  +label_long_offset  -->
	<!-- ************************************************************** -->                             

	<xsl:template match="route/*[self::source|self::destination]
                         [line_style]
					     [not(label_long_offset)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="261">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<!-- <xsl:message>linestyle <xsl:value-of select="line_style"/></xsl:message> -->
			<xsl:variable name="linestyle" 
			              as="element()"
			              select="key('line_style',line_style)"/>
			<!-- TBD max out with endline/style -->
			<label_long_offset>
				<xsl:value-of select="$linestyle/label_long_offset"/>
			</label_long_offset>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

