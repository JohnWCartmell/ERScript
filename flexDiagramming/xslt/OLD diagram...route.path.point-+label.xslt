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

	<!-- ******************************** -->
	<!-- path/point[startpoint]   +label  -->
	<!-- ******************************** -->

	<xsl:template match="route
		[source/annotation]
		/path/point[startpoint]
		[not(label[primary])]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label>
				<primary/>
				<text><xsl:value-of select="../../..[self::route]/source/annotation"/></text>
			</label>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="route
		[source/secondaryAnnotation]
		/path/point[startpoint]
		[not(label[secondary])]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label>
				<secondary/>
				<text><xsl:value-of select="../../..[self::route]/source/secondaryAnnotation"/></text>
			</label>
		</xsl:copy>
	</xsl:template>

	
	<!-- ******************************** -->
	<!-- path/point[endpoint]   +label  -->
	<!-- ******************************** -->

	<xsl:template match="route
		[destination/annotation]
		/path/point[endpoint]
		[not(label[primary])]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">	  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label>
				   <primary/>
				   <text><xsl:value-of select="../../..[self::route]/destination/annotation"/></text>
			</label>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="route
		[destination/seconadryAnnotation]
		/path/point[endpoint]
		[not(label[secondary])]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">	  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label>
				<secondary/>
				<text><xsl:value-of select="../../..[self::route]/destination/secondaryAnnotation"/></text>
			</label>
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>

