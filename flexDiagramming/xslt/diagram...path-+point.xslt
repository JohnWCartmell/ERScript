<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<!--  Maintenance Box 

 -->

	<xsl:output method="xml" indent="yes"/>


    <!-- cardinals (ns, ew, ramp) have points -->
	<xsl:template match="path/ns[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="path/ew[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="path/ramp[not(point)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
			<point/>
		</xsl:copy>
	</xsl:template>

	<!--  
    Between two successive cardinals a point should be inserted 
    <ns/><ew/> ==> <ns/><point/><ew/>
    <ew/><ns/> ==> <ew/><point/><ns/>
	
	Happily these rules do not conflict with insertion of startpoint and endpoint into a route/path.
	Presumable because these other rules jump in first.
-->
	<!-- ********* -->
	<!-- path/ns  -->
	<!-- ********* -->
	<xsl:template match="path/ns[not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54" >
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point/>
	</xsl:template>

	<!-- ********* -->
	<!-- path/ew  -->
	<!-- ********* -->
	<xsl:template match="path/ew[not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point/>
	</xsl:template>
	<!-- ********* -->
	<!-- path/ramp  -->
	<!-- ********* -->
	<xsl:template match="path/ramp[not(following-sibling::*[1][self::point])]"
                                  mode="recursive_diagram_enrichment"
                                  priority="54">
		<xsl:copy>
			<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		</xsl:copy>
		<point/>
	</xsl:template>





</xsl:transform>

