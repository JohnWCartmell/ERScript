

<xsl:transform version="2.0" 
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:math="http://www.w3.org/2005/xpath-functions/math"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
		xmlns:xlink="http://www.w3.org/TR/xlink" 
		xmlns:svg="http://www.w3.org/2000/svg" 
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/diagram"
		xmlns="http://www.entitymodelling.org/diagram"
		>

	<xsl:output method="xml" indent="yes" />
    <xsl:key name="Enclosure" match="enclosure" use="id"/>

    <!-- enclosure => set of route ... routes down to or into an outermost enclosure -->
	<!-- <xsl:key name="IncomingTopdownRoute"  match="route[top_down]" use="destination/abstract"/>  -->

	<!-- enclosure => set of route ... routes down to or into an entry enclosure -->
	<!-- see change of 7th May2025 -->
	<xsl:key name="EnteringTopdownRoute"  match="route[top_down]" use="destination/entryContainer"/>

	<!-- enclosure => set of route ... non-recursive routes down to or into an outermost enclosure -->
	<!-- Introduced for change of 7th 	May 2025 -->
	<!-- <xsl:key name="NonRecursiveIncomingTopdownRoute"  
								match="route[top_down][source/abstract != destination/abstract]" 
	                        	use="destination/abstract"/> -->

	<!-- enclosure => set of route ... routes down from or from within  an outermost enclosure -->
	<xsl:key name="OutgoingTopdownRoute" match="route[top_down]" use="source/abstract"/>
    <!-- move the above to recursive diagram enrichment -->


	<!-- enclosure => set of route ... routes down from or from within  an entry enclosure -->
	<xsl:key name="ExitingTopdownRoute" match="route[top_down]" use="source/exitContainer"/>
	
	<!-- enclosure => set of route  .. routes down to the enclosure --> 
	<!-- See change of 7th 	May 2025 -->

    <xsl:key name="ActualIncomingTopdownRoute" match="route[top_down]" use="destination/id"/>
    
		<!-- enclosure => set of route  .. routes down to the enclosure for which the source is external to the parent enclosure--> 
    <xsl:key name="TerminatingNonLocalIncomingTopdownRoute" 
             match="route[top_down]
                        [let $destination := key('Enclosure',destination/id),
                             $source := key('Enclosure',source/id)
                         return  $destination treat as element(enclosure)
                                    and $source treat  as element(enclosure)
                                    and not($source/ancestor-or-self::enclosure = $destination/parent::enclosure)
                        ] 
                        "
                        use="destination/id"/>


	<!-- enclosure => set of enclosure ... enclosures from which or from within which there is a route down to or into this outermost enclosure -->
   <xsl:key name="OutermostEnclosuresFromWhichIncomingTopDownRoute"
		      match="enclosure"
		      use="key('OutgoingTopdownRoute',id)/destination/abstract"/> 
    <!-- MOVE THE ABOVE TO recursive diagram enrichment where it is used /-->


	<!-- 7th May 2025 -->	       
   <xsl:key name="ExitContainersOfEnteringTopdownRoutes"
            match="enclosure"
            use="key('ExitingTopdownRoute',id)/destination/entryContainer"/> 

	<xsl:template match="*" mode="passone">
		<xsl:copy>
			<xsl:apply-templates mode="passone"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="source" mode="passone">
		<xsl:copy>
			<xsl:apply-templates mode="passone"/>
			 <abstract>
			   <xsl:value-of select="(key('Enclosure',id)/ancestor-or-self::enclosure)
			                          [1]/id"/>
			 </abstract>
             <!-- change of 7th May 2025 -->
<!--              <exitContainer>
             	<xsl:value-of select="
             	    let $source := //enclosure[id = current()/id],
    					$dest   := //enclosure[id = current()/../destination/id]
    				return $source/ancestor-or-self::enclosure
          				[not(./descendant::enclosure = $dest)
          				  and 
          				  not(./self::enclosure  = $dest)
          				][1]/id
          				"/>
             </exitContainer> -->

             <xsl:variable name="exitContainer"
          	              as="element(enclosure)?"
          	              select="
             	    let $source := //enclosure[id = current()/id],
    					$dest   := //enclosure[id = current()/../destination/id]
    				return $source/ancestor-or-self::enclosure
          				[not(./descendant::enclosure = $dest)
          				  and 
          				  not(./self::enclosure  = $dest)
          				][1]
          				"
          	              />
          	<xsl:choose>
	            <xsl:when test="$exitContainer">
		             <exitContainer>
		             	<xsl:value-of select="$exitContainer/id"/>
		             </exitContainer>
	            </xsl:when>
	            <xsl:otherwise>
	             	<recursive/>
	            </xsl:otherwise>
         	</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="destination" mode="passone">
		<xsl:copy>
			<xsl:apply-templates mode="passone"/>
			 <abstract>
			   <xsl:value-of select="(key('Enclosure',id)/ancestor-or-self::enclosure) 
			                          [1]/id"/>
			 </abstract>             
			 <!-- change of 7th May 2025 -->
			 <trace>
			 	<xsl:copy-of select="
             	    let $source := //enclosure[id = current()/../source/id],
    					$dest   := //enclosure[id = current()/id]
    				return $dest/ancestor-or-self::enclosure
          				[not(./descendant-or-self::enclosure = $source)]/id"/>
          	</trace>
          	<xsl:variable name="entryContainer"
          	              as="element(enclosure)?"
          	              select="
             	    let $source := //enclosure[id = current()/../source/id],
    					$dest   := //enclosure[id = current()/id]
    				return $dest/ancestor-or-self::enclosure
          				[not(./descendant-or-self::enclosure = $source)]
          				[last()]"
          	              />
          	<xsl:choose>
	            <xsl:when test="$entryContainer">
		             <entryContainer>
		             	<xsl:value-of select="$entryContainer/id"/>
		             </entryContainer>
	            </xsl:when>
	            <xsl:otherwise>
	             	<recursive/>
	            </xsl:otherwise>
         	</xsl:choose>
		</xsl:copy>
	</xsl:template>

</xsl:transform>