<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
	Change of 18 May2005.
 -->

<xsl:output method="xml" indent="yes"/>


<!-- ********************************************************** -->
<!-- route/path/point[startpoint|endpoint]/label[primary]   +x  -->
<!-- ********************************************************** -->

<xsl:template match="route
				     /path/point
				     [.[startpoint]
				            [../../source
							           		[label_long_offset]
							           		[label_lateral_offset]
							           		[*/labelPosition]
				            ]
				      | 
				      .[endpoint]
				            [../../destination
				            				[label_long_offset]
				            				[label_lateral_offset]
							            	[*/labelPosition]
				            ]
				     ]
				     [../*/startarm/bearing]
				     [../*/endarm/bearing]
				    /label[primary]
				   [not(x)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140">	 
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
		<xsl:variable name="label_long_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_long_offset
		                      else ../../../destination/label_long_offset
		              "/>
		<xsl:variable name="label_lateral_offset" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../../source/label_lateral_offset
		                      else ../../../destination/label_lateral_offset
		              "/>
		<xsl:variable name="orientation" as="element()"
		              select="if (../startpoint) 
		                      then ../../../source/*/labelPosition/*
		                      else ../../../destination/*/labelPosition/*
		              "/>
		<xsl:variable name="endarmBearing" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../*/startarm/bearing
		                      else ../../*/endarm/bearing
		              "/>
    <xsl:variable name="directionSign" 
                  as="xs:integer"
                  select="if ($orientation/name()='clockwise')
                          then 1  
                          else -1"/>
                  <!-- this will be 
                                 1 for clockwise, 
                                 -1 for anti-clockwise -->

    <xsl:variable name="alphaAdjustedBearing" as="xs:double"
                  select="$endarmBearing +
                            $directionSign *
                            (: angle alpha :) 
                            math:atan($label_lateral_offset div $label_long_offset)
              "/>

		<x>
		  <place>
		  	<xsl:choose>
		  		<xsl:when test="$directionSign = number(1)">
				  	<xsl:choose>
						  <xsl:when test="($endarmBearing &lt;= (math:pi() div 2 ))
				                 or
				                 ($endarmBearing &gt; (3 * math:pi() div 2 ) )">
				  			<left/>   
				  		</xsl:when>
				  		<xsl:otherwise>
				  			<right/>
				  		</xsl:otherwise>
				  	</xsl:choose>
		   		</xsl:when>
		   		<xsl:otherwise> <!-- anti clockwise -->
				  	<xsl:choose>
						  <xsl:when test="($endarmBearing &lt; (math:pi() div 2 ))
				                 or
				                 ($endarmBearing &gt;= (3 * math:pi() div 2) )">
				  			<right/>   
				  		</xsl:when>
				  		<xsl:otherwise>
				  			<left/>
				  		</xsl:otherwise>
				  	</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
		  	<edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of 
		  		   select="diagram:xOffsetFromBearingAndDistance(
		  		                         $alphaAdjustedBearing,
		  		                         diagram:hypoteneuse($label_lateral_offset,
		  		                                             $label_long_offset)
		  		                                                 )"/>
		  	</offset>
			</at>
		</x>
	</xsl:copy>
</xsl:template>

</xsl:transform>

