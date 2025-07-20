<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
		xmlns="http://www.entitymodelling.org/diagram"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box 
	See change of 18 May 2025.
 -->

	<xsl:output method="xml" indent="yes"/>

	<!-- ******************************** -->
	<!-- path/point[startpoint]   +label  -->
	<!-- ******************************** -->

	<xsl:template match="route
		[source]
		/path/point[startpoint]
		/label[primary]
		[not(text)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.1">  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<text><xsl:value-of select="../../..[self::route]/source/annotation"/></text>
			<!-- this text may be empty if source doesn't have an annotation -->
			<!-- need this empty label as a flag because  
			     need to know for evaluation of dimensions in
			     	diagram..node-+x_lower_boundP
			     	diagram..node-+x_upper_boundP
			     that all required labels have been created 
			-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="route
		[source]
		/path/point[startpoint]
		/label[secondary]
		[not(text)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.1">  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<text><xsl:value-of select="../../..[self::route]/source/secondaryAnnotation"/></text>
			<!-- see comment regarding empty text above -->
		</xsl:copy>
	</xsl:template>
	
	<!-- ******************************** -->
	<!-- path/point[endpoint]   +label  -->
	<!-- ******************************** -->

	<xsl:template match="route
		[destination]
		/path/point[endpoint]
		/label[primary]
		[not(text)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.1">	  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<text><xsl:value-of select="../../..[self::route]/destination/annotation"/></text>
			<!-- see comment regarding empty text above -->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="route
		[destination]
		/path/point[endpoint]
		/label[secondary]
		[not(text)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.1">	  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<text><xsl:value-of select="../../..[self::route]/destination/secondaryAnnotation"/></text>
			<!-- see comment regarding empty text above -->
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>

