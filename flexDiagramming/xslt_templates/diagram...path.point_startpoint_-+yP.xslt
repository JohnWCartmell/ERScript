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
	<!-- route/path/point[startpoint] +yP  -->
	<!-- ******************************************* -->

	<!-- source is left_sideP -->
	<xsl:template match="route
                       [source/left_sideP/deltayP]  
					   /path/point[startpoint]
					   [not(yP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
				<yP> 
					<at>
						<offset><xsl:value-of select="../../source/left_sideP/deltayP"/></offset>
						<of><xsl:value-of select="../../source/id"/></of>					
					</at>
				</yP>
			 <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<!-- source is right_sideP -->
	<xsl:template match="route
                       [source/right_sideP/deltayP] 
					   /path/point[startpoint]
					   [not(yP)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40">		  
		<xsl:copy>
				<yP> 
					<at>
						<offset><xsl:value-of select="../../source/right_sideP/deltayP"/></offset>
						<of><xsl:value-of select="../../source/id"/></of>					
					</at>
				</yP>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

