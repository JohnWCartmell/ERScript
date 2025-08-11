

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




	<!-- enclosure => set of route ... routes down from or from within  an outermost enclosure -->
	<xsl:key name="OutgoingTopdownRoute" match="route[top_down]" use="source/abstract"/>
    <!-- move the above to recursive diagram enrichment -->


	<!-- enclosure => set of route ... routes down from or from within  an entry enclosure -->
	<xsl:key name="ExitingTopdownRoute" match="route[top_down]" use="source/exitContainer"/>
	
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

	<!-- 7th May 2025 -->
	<!-- enclosure => set of enclosure  .. where entering top down routes exit from  --> 	       
   <xsl:key name="ExitContainersOfEnteringTopdownRoutes"
            match="enclosure"
            use="key('ExitingTopdownRoute',id)/destination/entryContainer"/> 

	<xsl:template match="*" mode="tactics_zero_enrichment">
		<xsl:copy>
			<xsl:apply-templates mode="tactics_zero_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="source" mode="tactics_zero_enrichment">
		<xsl:copy>
			<xsl:apply-templates mode="tactics_zero_enrichment"/>

             <xsl:variable name="exitContainer"
          	              as="element(enclosure)?"
          	              select="
             	    let $source := //enclosure[id = current()/id],
    					     $dest   := //enclosure[id = current()/../destination/id]
    				    return if (some $nestedEnclosure
    				                      in $source/descendant-or-self::enclosure 
    				                      satisfies $nestedEnclosure is $dest)
    				            then $source
    				            else $source/ancestor-or-self::enclosure
          				[not(some $nestedEnclosure 
          				     in descendant::enclosure 
          				     satisfies $nestedEnclosure is $dest)
          				]
          				[last()]
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
	
	<xsl:template match="destination" mode="tactics_zero_enrichment">
		<xsl:copy>
			<xsl:apply-templates mode="tactics_zero_enrichment"/>

          	<xsl:variable name="entryContainer"
          	              as="element(enclosure)?"
          	              select="
             	    let $source := //enclosure[id = current()/../source/id],
    					     $dest   := //enclosure[id = current()/id]
    				        return  if (some $nestedEnclosure
    				                      in $dest/descendant-or-self::enclosure 
    				                      satisfies $nestedEnclosure is $source)
    				                then $dest
    				                else
    				                 $dest/ancestor-or-self::enclosure
    				                         [ 
    				                         not(some $nestedEnclosure in descendant::enclosure 
          				                        satisfies $nestedEnclosure is $source)
          				                   ]
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