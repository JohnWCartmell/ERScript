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
	<!-- route/path    +point/startpoint  -->
	<!-- ******************************** -->

	<!-- source is left_sideP --> <!-- used to include[source/left_sideP/deltayP]-->
	<xsl:template match="route
					   [source[left_sideP]/id]
					   /path
					   [not(point/startpoint)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40P">	

			<xsl:message>Adding startpoint A</xsl:message>	  
		<xsl:copy>
			<point>
				<startpoint/>
				<xP>
					<at>
						<leftP/><edge/>
						<of><xsl:value-of select="../source/id"/></of>
					</at>
				</xP>
				<label><primary/></label> <!-- change of 18 May 2025 -->
				<label><secondary/></label> 
			</point>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<!-- endpoint 1 is rhs --> <!-- used to include  [source/right_sideP/deltayP] -->
	<xsl:template match="route
					   [source[right_sideP]/id]
					   /path
					   [not(point/startpoint)]
					   " 
              mode="recursive_diagram_enrichment"
              priority="40P">	
              		<xsl:message>Adding startpoint B</xsl:message>		  
		<xsl:copy>
			<point>
				<startpoint/>
				<xP>
					<at>
						<rightP/><edge/>
						<of><xsl:value-of select="../source/id"/></of>
					</at>
				</xP>
				<label><primary/></label> <!-- change of 18 May 2025 -->
				<label><secondary/></label>
			</point>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
	</xsl:template>


</xsl:transform>

