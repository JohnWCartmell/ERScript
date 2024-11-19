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
				     /path/point
				     [.[startpoint]
				            [../../source[label_long_offsetP]/left_sideP]
				      | 
				      .[endpoint]
				            [../../destination[label_long_offsetP]/left_sideP]
				     ]
				    /label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">	
         <!--  <xsl:message>Firing at left_sideP to plant xP</xsl:message> -->	  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xsl:variable name="label_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_long_offsetP
		                      else ../../../destination/label_long_offsetP
		              "/>
        <!-- <xsl:message>label offset <xsl:value-of select="$label_offset"/></xsl:message> -->
		<xP>
		  <place>
		  	<rightP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="- $label_offset"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>

<!-- source is right_sideP -->
<xsl:template match="route
				     /path/point
				     [.[startpoint]
				            [../../source[label_long_offsetP]/right_sideP]
				      | 
				      .[endpoint]
				            [../../destination[label_long_offsetP]/right_sideP]
				     ]
				    /label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">		

          <!-- <xsl:message>Firing at right_sideP to plant xP</xsl:message> -->	  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xsl:variable name="label_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_long_offsetP
		                      else ../../../destination/label_long_offsetP
		              "/>
	<!-- <xsl:message>label offset <xsl:value-of select="$label_offset"/></xsl:message> -->
		<xP>
		  <place>
		  	<leftP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:attribute name="trace" select="'5-Nov-2024'"/>
		  		<xsl:value-of select="$label_offset"/>
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
				     /path/point
				     [.[startpoint]
				        [../../source[label_long_offsetP]/*/annotate_leftQ]
				      | 
				      .[endpoint]
				        [../../destination[label_long_offsetP]/*/annotate_leftQ]
				     ]
				    /label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">	
<!-- <xsl:message>firing at annotate_leftQ to plant xP</xsl:message> -->
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
	    <xsl:variable name="label_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_long_offsetP
		                      else ../../../destination/label_long_offsetP
		              "/>
		<xP>
		  <place>
		  	<rightP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="- $label_offset"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>

<!--   annotate_rightQ -->
<xsl:template match="route/path/point
				     [.[startpoint]
				        [../../source[label_long_offsetP]/*/annotate_rightQ]
				      | 
				      .[endpoint]
				        [../../destination[label_long_offsetP]/*/annotate_rightQ]
				     ]
				     /label
				   [not(xP)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140P">	
          <!-- <xsl:message>firing at annotate_rightQ to plant xP</xsl:message> -->	  
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
	    <xsl:variable name="label_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_long_offsetP
		                      else ../../../destination/label_long_offsetP
		              "/>
		<xP>
		  <place>
		  	<leftP/><edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of select="$label_offset"/>
		  	</offset>
			</at>
		</xP>
	</xsl:copy>
</xsl:template>


</xsl:transform>

