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
		[not(label)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label><primary/></label>
		</xsl:copy>
	</xsl:template>
	
	<!-- ******************************** -->
	<!-- path/point[endpoint]   +label  -->
	<!-- ******************************** -->

	<xsl:template match="route
		[destination/annotation]
		/path/point[endpoint]
		[not(label)]
		" 
			mode="recursive_diagram_enrichment"
			priority="40.2">	  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<label><primary/></label>
		</xsl:copy>
	</xsl:template>
	
</xsl:transform>

