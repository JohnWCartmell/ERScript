

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
	
	<!-- previously keys declared here -->
	<!-- they are now found in ERmodel.flex_pass_two_module -->


	<xsl:template match="*" mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
		</xsl:copy>
	</xsl:template>

	
	<!-- y position of an outermost  enclosure with an incoming top down route -->
	<xsl:template match="enclosure[key('NonRecursiveIncomingTopdownRoute',id)]
	                     [not(y)]" 
						 mode="passtwoPRIORTOCHANGEOF7TH MAY">  <!-- TIDY THIS UP LATER-->
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
			<y> 
				<passtwoA/>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						<xsl:value-of select="key('OutermostEnclosuresFromWhichNonRecursiveIncomingTopDownRoute',id)
							                       [compositionalDepth+1=current()/compositionalDepth]
							                      [1]/id"/>
					   <!-- use compositionalDepth in this way to place beneath one of the enclosures with 
					        the lowest compositional depth -->
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route -->
			</y>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="enclosure[key('EnteringTopdownRoute',id)]
	                     [not(y)]" 
						 mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
			<y> 
				<passtwoA/>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						<xsl:value-of select="key('ExitContainersOfEnteringTopdownRoutes',id)
							                    (: try this   [compositionalDepth+1=current()/compositionalDepth] 
							                    ???????????????????????????????????????????????????????? :)
							                      [1]/id"/>
					   <!-- use compositionalDepth in this way to place beneath one of the enclosures with 
					        the lowest compositional depth -->
					        <!-- BUT HAD TO RE$MOVE DURING TESTING 10 May 2025 -->
					        <!-- IN WHAT FORM TO REINSTATE???????????????????????????????????????????-->
					        <!-- ???????????????????????????????????????????????????????????????????? -->
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route -->
			</y>
		</xsl:copy>
	</xsl:template>
	
	<!-- x position of an enclosure which is neither the outermost enclosure into which arrives a top down route 
	                                         nor has a top down route arriving at it 
											 and which has a preceeding enclosure
					is placed underneath its predecessor and with its left edge aligned.
    -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [not(key('EnteringTopdownRoute',id))]
						 [not(key('ActualIncomingTopdownRoute',id))]
	                     [preceding-sibling::enclosure]
	                    " mode="passtwo">      
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
			<x> 
				<passtwoB/>
				<at>
					<left/>
					<predecessor/>
				</at>
			</x>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*" mode="passthree">
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- next three templates - a non-outermost enclosure with a non local top down route to it is placed at the top of its parent enclosure. --> 
	
	<!-- if it is the first enclosure  within its parent enclosure and is preceeded by a label 
	   it is placed beneath the predecessor label to the left of the containing enclosure-->	              

	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree"> 
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <x> 
         	<passthreeA/>
		    	<at><left/><parent/></at>
		 </x>
         <y>
         <passthreeA/>
		    <place><top/><edge/></place>
            <at>
               <bottom/>
               <predecessor/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
    <!-- if it has a non local incoming top down route if it is the first enclosure  within its parent enclosure and but is not preceeded by a label 
	          then it is placed at the top of its parent enclosure    -->
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]	
						 [not(preceding-sibling::label)]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]		 
	                    " mode="passthree"> 
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <y>
         	<passthreeB/>
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
	
	    <!-- if it has a non local incoming top down route if it is the not the first enclosure  within its parent enclosure  it is laid to the right of its predecessor -->	              
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingNonLocalIncomingTopdownRoute',id)]				 
						 [preceding-sibling::enclosure]
						 [not(y)]
	                    " mode="passthree">  
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <y>
         	<passthreeC/>
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
	
	
	<!-- no incoming non local topdown route, first enclosure within a containing enclosure and preceded by a label -->
	
	<xsl:template match="enclosure/enclosure
						 [not(key('TerminatingNonLocalIncomingTopdownRoute',id))]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree">  
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <x> 
         	<passthreeD/>
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

	
	<xsl:template match="*" mode="passfour">
		<xsl:copy>
			<xsl:apply-templates mode="passfour"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- x position of an outermost  enclosure with a top down route in to it whose outermost source 
	    does not already have a route emanating from it and ariving into a predecessor outermost enclosure -->
    <!-- In this context preceding and preceding-sibling will execute interchangeably - because imprilcation is outermost -->
	
	<!-- why does this have to be pass four ?? -->
	
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
	<!-- the first top down route destination outer aligns at the left.  -->
	<!-- See rule passtwoA. That rule will have placed this enclosure beneath the source
	     of an incoming top down route. This rule lines up this enclosure with lhs of that source.
	-->
		<xsl:copy>
			<xsl:apply-templates mode="passfour"/>
			<x> 
				<passfourA/>
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


	<!-- Question : should preceding below be preceding-sibling ? -->
   <!-- This rule introduced in change of 7th M<ay 2025. -->
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
			<xsl:apply-templates mode="passfour"/>
			<x> 
				<passfourB/>
				<place>
					<left/>
				</place>
				<passfourB-7May25/>
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