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
	<!-- route/path    +point/endpoint  -->
	<!-- ******************************** -->


	<!-- destination is left_side_P --> <!-- used to include [destination/left_sideP/deltayP] -->
	<xsl:template match="route
					   [destination[left_sideP]/id]
					   /path
					   [not(point/endpoint)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40.1P">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<xsl:message>Adding endpoint A</xsl:message>
			<point>
				<endpoint/>
				<xP>
					<at>
						<leftP/><edge/>
						<of><xsl:value-of select="../destination/id"/></of>
					</at>
				</xP>
				<label><primary/></label> <!-- change of 18 May 2025 -->
				                          <!-- create stub here so width not calculated too early -->
				<label><secondary/></label> <!-- create here but too many at the mo -->
			</point>
		</xsl:copy>
	</xsl:template>

	<!-- destination is right_sideP --> <!-- used to include [destination/right_sideP/deltayP] -->
	<xsl:template match="route
					   [destination[right_sideP]/id]
					   /path
					   [not(point/endpoint)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40.1P">		  
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>

			<xsl:message>Adding endpoint B</xsl:message>
			<point>
				<endpoint/>
				<xP>
					<at>
						<rightP/><edge/>
						<of><xsl:value-of select="../destination/id"/></of>
					</at>
				</xP>				
				<label><primary/></label> <!-- change of 18 May 2025 -->
				                          <!-- create stub here so width not calculated too early -->
				<label><secondary/></label> 
			</point>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

