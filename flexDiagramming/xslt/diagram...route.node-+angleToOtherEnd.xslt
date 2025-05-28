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

<!-- ************************************************************ -->
<!-- See change note of 28 May 2025 for rationale for these rules -->
<!-- ************************************************************ -->


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

		  <xsl:call-template name="plant_angleToOtherEnd">
		  		<xsl:with-param name="xdiff" 
		  		                 select="../destination/key('Enclosure',id)/x/abs - key('Enclosure',id)/x/abs"/>
		  		<xsl:with-param name="ydiff" 
		  		                select="../destination/key('Enclosure',id)/y/abs - key('Enclosure',id)/y/abs"/>
		  </xsl:call-template>
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

		  <xsl:call-template name="plant_angleToOtherEnd">
		  		<xsl:with-param name="xdiff" 
		  		                select="../source/key('Enclosure',id)/x/abs - key('Enclosure',id)/x/abs"/>
		  		<xsl:with-param name="ydiff" 
		  		                select="../source/key('Enclosure',id)/y/abs - key('Enclosure',id)/y/abs"/>
		  </xsl:call-template>
       </xsl:copy>
  </xsl:template>

  <xsl:template name="plant_angleToOtherEnd" match="source|destination" mode="explicit">
  	  	<xsl:param name="xdiff" as="xs:double"/>
    	<xsl:param name="ydiff" as="xs:double"/>
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
		  	        	<xsl:when test="top_edge">  <!-- clockwise -->
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="right_side">  <!-- clockwise -->
		  	             <xsl:value-of select="diagram:NoughtToTwoPiClockwiseAngleFromNegativeXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="left_side">  <!--anticlockwise-->
		  	             <xsl:value-of select="diagram:NoughtToTwoPiAntiClockwiseAngleFromXaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
		  	        	<xsl:when test="bottom_edge"> <!--anticlockwise-->
		  	             <xsl:value-of select="diagram:NoughtToTwoPiAntiClockwiseAngleFromNegativeYaxis($xdiff,$ydiff)
		  	        	                              + $jiggleFactor"/>
                  </xsl:when>
                  <xsl:otherwise>
		  	        		<xsl:value-of select="'OUT OF SPEC'"/>
                  </xsl:otherwise>
               </xsl:choose>
		  </angleToOtherEnd>
  </xsl:template>
  
</xsl:transform>