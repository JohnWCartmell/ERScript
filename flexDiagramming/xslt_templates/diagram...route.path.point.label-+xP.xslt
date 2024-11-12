<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
	Rewritten in change of 5-Nov-2024.
 -->

<xsl:output method="xml" indent="yes"/>


<!-- ********************************************** -->
<!-- route/path[source/lhs]/point[startpoint|endpoint]/label   +xP  -->
<!-- ********************************************** -->

<!-- source is left_sideP -->
<xsl:template match="route
                   [(source|destination)[label_long_offsetP]/left_sideP]
				   /path/point[startpoint|endpoint]/label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">		  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xP>
		  <place>
		  	<rightP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="- ../../../(source|destination)/label_long_offsetP"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>

<!-- source is right_sideP -->
<xsl:template match="route
                   [(source|destination)[label_long_offsetP]/right_sideP]
				   /path/point[startpoint|endpoint]/label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">		  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xP>
		  <place>
		  	<leftP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="../../../(source|destination)/label_long_offsetP"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>



<!-- ******************************** -->
<!-- path/point[startpoint]   +xP  -->
<!-- ******************************** -->

<!-- annotate_leftQ-->
<xsl:template match="route
                   [(source|destination)[label_lateral_offsetP]/*/annotate_leftQ]
				   /path/point[startpoint|endpoint]/label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">		  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xP>
		  <place>
		  	<rightP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="- ../../../(source|destination)/label_lateral_offsetP"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>

<!--   annotate_rightQ -->
<xsl:template match="route
                   [(source|desination)[label_lateral_offsetP]/*/annotate_rightQ]
				   /path/point[startpoint|endpoint]/label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">		  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xP>
		  <place>
		  	<leftP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="../../../(source|destination)/label_lateral_offsetP"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>


</xsl:transform>

