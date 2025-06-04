<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<xsl:output method="xml" indent="yes"/>

	<!-- change of 2 June 2025 -->

	<!-- **************************** -->
	<!-- route/path    +ewQ.andarm  -->
	<!-- **************************** -->
	<xsl:template match="route
					   [destination/*[self::left_sideP|self::right_sideP]]
					   /path
					   [not(*/endarm)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40.6P">		  
		<xsl:copy>
			<xsl:message>Adding endarm </xsl:message>
			<xsl:apply-templates select="*[not(self::point[endpoint])]" 
			                     mode="recursive_diagram_enrichment"/>
			<ewQ><endarm/></ewQ>
			<xsl:apply-templates select="point[endpoint]" 
			                     mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

