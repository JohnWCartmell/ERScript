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

<!-- <xsl:key name="SourcedAtBottomEdgeOf" match="source[bottom_edge]" use="id"/> -->

<!-- the angle in radians between the negative y-axis (i.e. the rising vertical)
 		and the direction in question. 
     	+ angles in the right half of the plane are to be positive
 	   + angles in the left half of the plane are to be negative
 -->

 <!-- the direction in question is either source-to-destination or destination-to-source -->



<!-- ************************ -->
<!-- source: +angleToOtherEnd -->
<!-- ************************ -->

<!-- at some point I may need to use relative offset and src_rise and dest_rise attributes instead of abs  address. -->

   <xsl:template match="source
                        [not(angleToOtherEnd)]
						[key('Enclosure',id)/x/abs]
						[key('Enclosure',id)/y/abs]
						[../destination/key('Enclosure',id)/x/abs]
						[key('Enclosure',id)/y/abs]
						[../destination/key('Enclosure',id)/y/abs]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <thisEndx>
		       <xsl:value-of select="key('Enclosure',id)/x/abs"/>
		  </thisEndx>
		  <thisEndy>
		       <xsl:value-of select="key('Enclosure',id)/y/abs"/>
		  </thisEndy>

	      <otherEndx> 
		       <xsl:value-of select="../destination/key('Enclosure',id)/x/abs"/>
		  </otherEndx>
		  <otherEndy> 
		       <xsl:value-of select="../destination/key('Enclosure',id)/y/abs"/>
		  </otherEndy>
		  <xsl:variable name="xdiff" as="xs:double" 
		                select="../destination/key('Enclosure',id)/x/abs - key('Enclosure',id)/x/abs"/>
		  <xsl:variable name="ydiff" as="xs:double" 
		                select="../destination/key('Enclosure',id)/y/abs - key('Enclosure',id)/y/abs"/>

		  <!-- I am going to add a small amount to the angle so that routes that would otherwsie have identical angles no longer do -->
        <!-- if i don't do this (or have a morerefined algorithm) then routes with identical source and destination overlap -->
        <xsl:variable name="jiggleno" 
        	             as="xs:integer"
        	             select="parent::route/count(preceding-sibling::route)" /> 
		  <xsl:variable name="jiggleFactor" 
		  	             select="$jiggleno * 0.0001" 
		  	             as="xs:float"/>

		  <angleToOtherEnd>
		  	        <xsl:choose>
		  	        	<xsl:when test="top_edge">  
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="right_side">  
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromNegativeXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="left_side">  <!--anticlockwise-->
		  	             <xsl:value-of select="2 * math:pi() - diagram:NoughtToTwoPiClockwiseAngleFromXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="bottom_edge"> <!--anticlockwise-->
		  	             <xsl:value-of select="2 * math:pi() - diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
                  <xsl:otherwise>
		  	        		<xsl:value-of select="'OUT OF SPEC'"/>
                  </xsl:otherwise>
               </xsl:choose>
		  </angleToOtherEnd>
       </xsl:copy>
  </xsl:template>
  
  <xsl:template match="destination
                        [not(angleToOtherEnd)]
						[key('Enclosure',id)/x/abs]
						[key('Enclosure',id)/y/abs]
						[../source/key('Enclosure',id)/x/abs]
						[key('Enclosure',id)/y/abs]
						[../source/key('Enclosure',id)/y/abs]
                    " 
              mode="recursive_diagram_enrichment"
              priority="40">
       <xsl:copy>
          <xsl:apply-templates mode="recursive_diagram_enrichment"/>
		  <thisEndx>
		       <xsl:value-of select="key('Enclosure',id)/x/abs"/>
		  </thisEndx>
		  <thisEndy>
		       <xsl:value-of select="key('Enclosure',id)/y/abs"/>
		  </thisEndy>

	      <otherEndx> 
		       <xsl:value-of select="../source/key('Enclosure',id)/x/abs"/>
		  </otherEndx>
		  <otherEndy> 
		       <xsl:value-of select="../source/key('Enclosure',id)/y/abs"/>
		  </otherEndy>
		  <xsl:variable name="xdiff" as="xs:double" 
		                select="../source/key('Enclosure',id)/x/abs - key('Enclosure',id)/x/abs"/>
		  <xsl:variable name="ydiff" as="xs:double" 
		                select="../source/key('Enclosure',id)/y/abs - key('Enclosure',id)/y/abs"/>
		  <!-- in this case I want the angle to be to the negative of the y-axis i.e. to the verical. -->
		  <!-- I want angles in the right half of the plave to be positive and angles in the left half to be negative -->

        <!-- I am going to add a small amount to the angle so that routes that would otherwsie have identical angles no longer do -->
        <!-- if i don't do this (or have a morerefined algorithm) then routes with identical source and destination overlap -->
        <xsl:variable name="jiggleno" 
        	             as="xs:integer"
        	             select="parent::route/count(preceding-sibling::route)" /> 
		  <xsl:variable name="jiggleFactor" 
		  	             select="$jiggleno * 0.0001" 
		  	             as="xs:float"/>
		  <angleToOtherEnd>
		  	        <xsl:choose>
		  	        	<xsl:when test="top_edge">  
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="right_side">  
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromNegativeXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="left_side">   <!--anticlockwise-->
		  	             <xsl:value-of select="2 * math:pi() - diagram:NoughtToTwoPiClockwiseAngleFromXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="bottom_edge">  <!--anticlockwise-->
		  	             <xsl:value-of select="2 * math:pi() - diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
                  <xsl:otherwise>
		  	        		<xsl:value-of select="'OUT OF SPEC'"/>
                  </xsl:otherwise>
               </xsl:choose>
		  </angleToOtherEnd>
       </xsl:copy>
  </xsl:template>
  
</xsl:transform>