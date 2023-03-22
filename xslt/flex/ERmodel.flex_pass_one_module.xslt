

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
	<xsl:key name="IncomingTopdownRoute"  match="route[top_down]" use="destination/abstract"/> 

	<!-- enclosure => set of route ... routes down from or from within  an outermost enclosure -->
	<xsl:key name="OutgoingTopdownRoute" match="route[top_down]" use="source/abstract"/>
	
	<!-- enclosure => set of route  .. routes down to the enclosure --> 
	<xsl:key name="TerminatingIncomingTopdownRoute" match="route[top_down]" use="destination/id"/>

		<!-- enclosure => set of route  .. routes down to the enclosure for which the source is external to the parent enclosure--> 
	<xsl:key name="TerminatingNonLocalIncomingTopdownRoute" match="route[top_down]
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
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="destination" mode="passone">
		<xsl:copy>
			<xsl:apply-templates mode="passone"/>
			 <abstract>
			   <xsl:value-of select="(key('Enclosure',id)/ancestor-or-self::enclosure) 
			                          [1]/id"/>
			 </abstract>
		</xsl:copy>
	</xsl:template>


<!-- I (wrongly) moved these from the recursive_structure pass
Subsequenlty I dont think that depthOfNesting is required 
	<xsl:template match="enclosure
                     [not(parent::enclosure)]
                     [not(depthOfNesting)]
                    " 
              mode="passone">
   <xsl:copy>
      <depthOfNesting>
         <xsl:value-of select="0"/>
      </depthOfNesting>
      <xsl:apply-templates mode="passone"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="enclosure
                     [parent::enclosure/depthOfNesting]
                     [not(depthOfNesting)]
                    " 
              mode="passone">
   <xsl:copy>
      <depthOfNesting>
         <xsl:value-of select="parent::enclosure/depthOfNesting + 1"/>
      </depthOfNesting>
      <xsl:apply-templates mode="passone"/>
   </xsl:copy>
</xsl:template>

-->


</xsl:transform>