<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
	change of 18 May2005.
 -->

<xsl:output method="xml" indent="yes"/>



<!-- This source should be single sourced with its x equivalent as an xy template.-->

<!-- ********************************************** -->
<!-- route/path/point[startpoint|endpoint]/label   +y  -->
<!-- ********************************************** -->

<xsl:template match="route
				     /path/point
				     [.[startpoint]
				            [../../source
				                  [label_long_offset]
				                  [label_lateral_offset]
							           	[*/labelPosition]
							           	[*/secondaryLabelPosition] (: could be less specific :)
				            ]
				      | 
				      .[endpoint]
				            [../../destination
				                   [label_long_offset]
				                   [label_lateral_offset]
							           	 [*/labelPosition] 
							           	 [*/secondaryLabelPosition] (: could be less specific :)
							      ]
				     ]
				     [../*/startarm/bearing]
				     [../*/endarm/bearing]
				    /label[h]
				   [not(y)]
				   " 
          mode="recursive_diagram_enrichment"
          priority="140.001">	 
	<xsl:copy>
		<xsl:apply-templates mode="recursive_diagram_enrichment"/>
<!-- 		<xsl:variable name="label_long_offset" as="xs:double"
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
		              select="if (primary) 
		                      then
			                      if (../startpoint) 
			                       then ../../../source/*/labelPosition/*
			                       else ../../../destination/*/labelPosition/*	                      
		                      else 
			                       if (../startpoint) 
			                       then ../../../source/*/secondaryLabelPosition/*
			                       else ../../../destination/*/secondaryLabelPosition/*                 
		              "/>

		<xsl:variable name="endarmBearing" as="xs:double"
		              select="if (../startpoint) 
		                      then ../../*/startarm/bearing
		                      else ../../*/endarm/bearing
		              "/> -->

		<xsl:variable name="terminalNode" as="element(*(:source|destination:))"
		              select="if (../startpoint) 
		                      then ../../../source
		                      else ../../../destination"/>
		                      <!-- why didn't I call the node(2) entity type 'terminalNode'!!!-->

   <!--  <xsl:variable name="terminalArm" as="element((:ns|ew|ramp:))"
		              select="if (../startpoint) 
		                      then ../../*[startarm]
		                      else ../../*[endarm]"/> -->

		<xsl:variable name="label_long_offset" as="xs:double"
		              select="$terminalNode/label_long_offset"/>
		<xsl:variable name="label_lateral_offset" as="xs:double"
		              select="$terminalNode/label_lateral_offset"/>

<!-- 		<xsl:message>terminalNode is <xsl:copy-of select="$terminalNode"/></xsl:message> -->
		<xsl:variable name="orientation" as="element(*)"
		              select="if (primary) 
		                      then $terminalNode/*/labelPosition/*	                      
		                      else $terminalNode/*/secondaryLabelPosition/*                  
		                     "/>
<!-- 		<xsl:message>orientation has name <xsl:value-of select="$orientation/name()"/></xsl:message> -->
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
		              <!-- Test it anticlockwise 5 May 2025 -->
    <xsl:variable name="alphaAdjustedBearing" as="xs:double"
                  select="diagram:bearingFromAngleToNegativeYaxis(
                                (: call this function to normalise negative angle
                                      into range 0 to 2*pi :)
                                 $endarmBearing +
                                       $directionSign *
                                        (: angle alpha :) 
                                       math:atan($label_lateral_offset div $label_long_offset)
                                                                 )
              "/> 
    <xsl:variable name="yAnchor" as="element()">
		  	<xsl:choose>
      		<xsl:when test="($endarmBearing &gt; (7 * math:pi() div 4 ))
		                 or
		                      ($endarmBearing &lt;= (math:pi() div 4 ) )">
		  			<bottom/>   
		  		</xsl:when>
      		<xsl:when test="$endarmBearing &lt;= (3 * math:pi() div 4 )">
      			<!--     and ($endarmBearing &gt; math:pi() div 4 ) --> 
      			<xsl:choose>
			  			<xsl:when test="$directionSign = number(1)"> <!-- clockwise -->
							  	<top/>
							</xsl:when>
		          <xsl:otherwise> <!-- anti clockwise -->   
		          	  <bottom/>
		          </xsl:otherwise>
		        </xsl:choose>
		  		</xsl:when>
      		<xsl:when test="($endarmBearing &lt;= (5 * math:pi() div 4 ))">
      			<!--      and ($endarmBearing &gt; 3 * math:pi() div 4 ) --> 
		  			<top/>   
		  		</xsl:when>
      		<xsl:when test="$endarmBearing &lt;= (7 * math:pi() div 4 )">
      			<!--     and ($endarmBearing &gt; 5 * math:pi() div 4 ) --> 
      			<xsl:choose>
			  			<xsl:when test="$directionSign = number(1)"> <!-- clockwise -->
							  	<bottom/>
							</xsl:when>
		          <xsl:otherwise> <!-- anti clockwise -->   
		          	  <top/>
		          </xsl:otherwise>
		        </xsl:choose>
		  		</xsl:when>
		  	</xsl:choose>
		</xsl:variable>

<!--     <xsl:variable name="y_increment_for_outer_label" as="xs:double"
                  select="if ($terminalNode/top_edge and $orientation/out)
                          then -h  (: assumption that primary and 
                                       secondary label of the same height!:)
                          else if ($terminalNode/bottom_edge and $orientation/out)
                          then h
                          else 0  
                         "/> -->

    <xsl:variable name="y_increment_for_outer_label" as="xs:double"
                  select="if (not($orientation/out))
                          then 0
                          else if ($yAnchor[self::bottom])
                          then -h  (: assumption that primary and 
                                       secondary label of the same height!:)
                          else  h
                         "/>

		<y>
			<label_lateral_offset>
				<xsl:value-of select="$label_lateral_offset"/>
			</label_lateral_offset>
			<label_long_offset>
				<xsl:value-of select="$label_long_offset"/>
			</label_long_offset>
			<alphaAdjustedBearing>
				<xsl:value-of select="$alphaAdjustedBearing"/>
			</alphaAdjustedBearing>
		  <place>
		  	<xsl:copy-of select="$yAnchor"/>
		  	<edge/>
		  </place>
		  <at>
		  	<parent/>
		  	<offset>
		  		<xsl:value-of 
		  		   select="diagram:yOffsetFromBearingAndDistance(
		  		                         $alphaAdjustedBearing,
		  		                         diagram:hypoteneuse($label_lateral_offset,
		  		                                             $label_long_offset)
		  		                                                 )
		  		             +  $y_increment_for_outer_label 
		  		                                                 "/>
		  	</offset>
			</at>
		</y>
	</xsl:copy>
</xsl:template>

</xsl:transform>

