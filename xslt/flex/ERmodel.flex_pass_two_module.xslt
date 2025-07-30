

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
	

	 <!-- Major changes to this file ...change of 7th May 2025 -->

   <xsl:variable name="sourcefileName" select="'EREmodel.flex_pass_two_module.xslt'"/>


	<xsl:template match="@*|node()" mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="passtwo"/>
		</xsl:copy>
	</xsl:template>

	<!--     *********** -->
	<!--       Rule x1   -->
	<!--     *********** -->
	<!-- x position of an enclosure which has a preceeding enclosure
	     and is neither the entry container of a top down route 
	     nor has a top down route arriving at it 
		 is placed underneath its predecessor and with its left edge aligned.
    -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [not(key('EnteringTopdownRoute',id))]
						 [not(key('ActualIncomingTopdownRoute',id))]
	                     [preceding-sibling::enclosure]
	                    " mode="passtwo">      
		<xsl:copy>
			<label><text>rule x1</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()"  mode="passtwo"/>
			<x> 
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule x1'"/>
         	<rule>x1</rule>
				<at>
					<left/>
					<predecessor/>
				</at>
			</x>
		</xsl:copy>
	</xsl:template>
	

	<!--     *********** -->
	<!--       Rule y1   -->
	<!--     *********** -->
   <!-- y position of an  enclosure which is the entryContainer 
        for a top down route -->
	<xsl:template match="enclosure[key('EnteringTopdownRoute',id)]
	                     [not(y)]" 
						 mode="passtwo">
		<xsl:copy>
			<label><text>rule y1</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passtwo"/>
			<y>
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule y1'"/>
				<rule>y1</rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						<xsl:value-of select="key('ExitContainersOfEnteringTopdownRoutes',id)
							                    [compositionalDepth+1=current()/compositionalDepth] 
							                    [1]/id"/>
					   <!-- use compositionalDepth in this way to place beneath one of the enclosures with 
					        the lowest compositional depth -->
					        <!-- BUT HAD TO RE$MOVE DURING TESTING 10 May 2025 -->
					        <!-- IN WHAT FORM TO REINSTATE???????????????????????????????????????????-->
					        <!-- ???????????????????????????????????????????????????????????????????? -->
					        <!-- Hmmm the reason this wouldn't work is that compositionalDepth is only defined for outermost enclosures. 
					        ancestor-or-self::enclosure[1]/compositionalDepth???
					        I wonder what would compositional depth of an inner enclosure correspond to?

					        I have changed it 12.07 29/072025 but not at all sure this is right
					        Might work for quadrant test because no nested types.

					        Hmmm. Nothing has a compsotionl depth except the enclosing diagram level enclosure
					        -->
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route -->
			</y>
		</xsl:copy>
	</xsl:template>
	


	<xsl:template match="@*|node()" mode="passthree">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="passthree"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- next three templates - a non-outermost enclosure with a non local top down route to it is placed at the top of its parent enclosure. --> 
	              
	<!--     ************ -->
	<!--       Rule xy3A    -->
	<!--     ************ -->
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree"> 
		<xsl:copy>
			<xsl:attribute name="test" select="'3A'"/>
			<label><text>rule xy3A</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passthree"/>
         <x> 
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule 3A'"/>
         	<rule>xy3A</rule>
		    	<at><left/><parent/></at>
		  </x>
         <y>
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule 3A'"/>
         
         	<rule>xy3A</rule>
		     <place><top/><edge/></place>
            <at>
               <bottom/>
               <predecessor/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule 3B   -->
	<!--     *********** -->
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]	
						 [not(preceding-sibling::label)]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]		 
	                    " mode="passthree"> 
		<xsl:copy>
			<label><text>rule y3B</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passthree"/>
         <y>
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule 3B'"/>
         	<rule>y3B</rule>
		    <place>
			    <top/>
				<edge/>
		    </place>
            <at>
               <top/>
               <parent/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule 3C   -->
	<!--     *********** -->              
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]				 
						 [preceding-sibling::enclosure]
						 [not(y)]
	                    " mode="passthree">  
		<xsl:copy>
			<label><text>rule y3C</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passthree"/>
         <y>
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule 3C'"/>
         	<rule>y3C</rule>
		    <place>
			    <top/>
				<edge/>
		    </place>
            <at>
               <top/>
               <predecessor/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule x5   -->
	<!--     *********** -->
	<!-- nested enclosure with no incoming non local topdown route, first enclosure within a containing enclosure and preceded by a label -->
	
	<xsl:template match="enclosure/enclosure
						 [not(key('TerminatingNonLocalIncomingTopdownRoute',id))]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree">  
		<xsl:copy>
			<label><text>rule x5</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passthree"/>
         <x> 
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule x5'"/>
         	<rule>x5</rule>
		    <at><left/><parent/></at>
		 </x>
         <y>
         	
         	<passthreeD/>
		    <place><top/><edge/></place>
            <at>
               <bottom/>
               <predecessor/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>

	
	<xsl:template match="@*|node()" mode="passfour">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="passfour"/>
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule x6A   -->
	<!--     *********** -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [key('EnteringTopdownRoute',id)]
						 [not(preceding::enclosure
						         [(key('EnteringTopdownRoute',id)[1]/source/exitContainer)
								   =
								   (key('EnteringTopdownRoute',current()/id)[1]/source/exitContainer)
								 ]
							  )
					      ]
						   " 
						 mode="passfour">
		<xsl:copy>
			<label><text>rule x6A</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passfour"/>
			<x> 
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule x6A'"/>
         	<rule>x6A</rule>
				<place>
					<left/>
				</place>
				<at>
					<left/>
					<of>
						<xsl:value-of select="key('EnteringTopdownRoute',id)[1]/source/exitContainer"/>
					</of>
				</at>
			</x>
		</xsl:copy>
	</xsl:template>

	<!--     *********** -->
	<!--       Rule x6B   -->
	<!--     *********** -->
   <!-- This rule introduced in change of 7th May 2025. -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [key('EnteringTopdownRoute',id)]
						      [preceding::enclosure
						         [key('EnteringTopdownRoute',id)[1]/source/exitContainer
								    =
								    key('EnteringTopdownRoute',current()/id)[1]/source/exitContainer
								   ]
					      	]
						   " 
						 mode="passfour">
		<xsl:copy>
			<label><text>rule x6B</text><text_style>trace</text_style></label>
			<xsl:apply-templates select="@*|node()" mode="passfour"/>
			<x> 
				<xsl:attribute name="source" select="$sourcefileName"/>
				<xsl:attribute name="rule" select="'Rule x6B'"/>
				<passfourB/>
				<place>
					<left/>
				</place>
         	<rule>x6B</rule>
				<at>
					<right/>
					<outer/>
					<of>
						<xsl:value-of select="preceding::enclosure
						         [key('EnteringTopdownRoute',id)[1]/source/exitContainer
								    =
								    key('EnteringTopdownRoute',current()/id)[1]/source/exitContainer
								   ][1]/id"/>
					</of>
				</at>
			</x>
		</xsl:copy>
	</xsl:template>

</xsl:transform>