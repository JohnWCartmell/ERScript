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


	<!-- ******************************************* -->
	<!-- route/path/point[endpoint] +yP  -->
	<!-- ******************************************* -->

	<!-- destination is left_sideP -->
	<xsl:template match="route
                       [destination/left_sideP/deltayP]  
					   /path/point[endpoint]
					   [not(yP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
				<yP> 
					<at>
						<offset><xsl:value-of select="../../destination/left_sideP/deltayP"/></offset>
						<of><xsl:value-of select="../../destination/id"/></of>					
					</at>
				</yP>
			 <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<!-- destination is right_sideP -->
	<xsl:template match="route
                       [destination/right_sideP/deltayP] 
					   /path/point[startpoint]
					   [not(yP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
				<yP> 
					<at>
						<offset><xsl:value-of select="../../destination/right_sideP/deltayP"/></offset>
						<of><xsl:value-of select="../../destination/id"/></of>					
					</at>
				</yP>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

