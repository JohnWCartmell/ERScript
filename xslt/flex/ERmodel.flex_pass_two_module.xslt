

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


	<xsl:template match="*" mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
		</xsl:copy>
	</xsl:template>


	
	<!-- y position of an outermost  enclosure with an incoming top down route>-->
	<xsl:template match="enclosure[key('IncomingTopdownRoute',id)]
	                     [not(y)]" 
						 mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
			<y> 
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						<xsl:value-of select="key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id)
							                       [compositionalDepth+1=current()/compositionalDepth]
							                      [1]/id"/>
							                      <!-- -->
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
	                     [not(key('IncomingTopdownRoute',id))]
						 [not(key('TerminatingIncomingTopdownRoute',id))]
	                     [preceding-sibling::enclosure]
	                    " mode="passtwo">
		<xsl:copy>
			<xsl:apply-templates mode="passtwo"/>
			<x> 
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
	
	
	<!-- next three templates - a non-outermost enclosure with a top down route to it is placed at the top of its parent enclosure. --> 
	
	<!-- if it is the first enclosure  within its parent enclosure and is preceeded by a label 
	   it is placed beneath the predecessor label to the left of the containing enclosure-->	              

	<xsl:template match="enclosure/enclosure
						 [key('TerminatingIncomingTopdownRoute',id)]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree">
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <x> 
		    <at><left/><parent/></at>
		 </x>
         <y>
		    <place><top/><edge/></place>
            <at>
               <bottom/>
               <predecessor/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
    <!-- if it is the first enclosure  within its parent enclosure and but is not preceeded by a label 
	          then it is placed at the top of its parent enclosure    -->
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingIncomingTopdownRoute',id)]	
						 [not(preceding-sibling::label)]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]		 
	                    " mode="passthree">
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <y>
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
	
	    <!-- if it is the not the first enclosure  within its parent enclosure  it is laid to the right of its predecessor -->	              
	<xsl:template match="enclosure/enclosure
						 [key('TerminatingIncomingTopdownRoute',id)]				 
						 [preceding-sibling::enclosure]
						 [not(y)]
	                    " mode="passthree">
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <y>
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
	
	
	<!-- first enclosure within a containing enclosure and preceded by a label -->
	
	<xsl:template match="enclosure/enclosure
						 [not(key('TerminatingIncomingTopdownRoute',id))]
						 [preceding-sibling::label]
						 [not(preceding-sibling::enclosure)]
						 [not(y)]
	                    " mode="passthree">
		<xsl:copy>
			<xsl:apply-templates mode="passthree"/>
         <x> 
		    <at><left/><parent/></at>
		 </x>
         <y>
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
	
	<!-- x position of an outermost  enclosure with a top down route in to it whose outermost source does not already
	                                          have a route emanating from it and ariving into a predecessor outermost enclosure -->
    <!-- In this context preceding and preceding-sibling will execute interchangeably - bacause imprilcation is outermost -->
	
	<!-- why does this have to be pass four ?? -->
	
	<xsl:template match="enclosure
	                     [not(x)]
	                     [key('IncomingTopdownRoute',id)]
						 [not(preceding::enclosure
						         [(key('IncomingTopdownRoute',id)[1]/source/abstract)
								   =
								   (key('IncomingTopdownRoute',current()/id)[1]/source/abstract)
								 ]
							  )
					      ]
						   " 
						 mode="passfour">
	<!-- the first top down route destination outer aligns at the left. What about subsequent? --> 	
    <!-- what probably happens is that because of  default smarts they are laid out  horizontally.  -->	
		<xsl:copy>
			<xsl:apply-templates mode="passfour"/>
			<x> 
				<place>
					<left/>
				</place>
				<at>
					<left/>
					<of>
						<xsl:value-of select="key('IncomingTopdownRoute',id)[1]/source/abstract"/>
					</of>
				</at>
			</x>
		</xsl:copy>
	</xsl:template>


</xsl:transform>