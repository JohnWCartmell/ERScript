

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


   <xsl:template name="plant_x_label" match="enclosure"  mode="explicit">
   	<xsl:param name="rulename" as="xs:string"/>
		<label>
         <padding>0.1</padding>
			<text><xsl:value-of select="'rule ' || $rulename"/></text><text_style>trace</text_style>
			<!-- <x> --><place><right/><edge/></place><at><right/><edge/><parent/></at><!-- </x> -->
			<y><place><outer/><top/></place><at><bottom/><edge/><parent/></at></y>
		</label>
	</xsl:template>




	<!--     *************** -->
	<!--       Rule d+y-0    -->
	<!--     *************** -->
	<!-- Applies to first top-level enclosures in the diagram  to not have a yPositionalPontOfReference.
	     Position at top left of the diagram.
	 -->

<xsl:template match="diagram
							/enclosure 
	                     [not(yPositionalPointOfReference)]  
	                     [not (preceding-sibling::enclosure[not(yPositionalPointOfReference)]
	                          )
	                     ]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    " mode="tactics_four_enrichment">
	   <xsl:variable name="rulename" as="xs:string" select="'d+y-0'"/>    
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<!-- <x> --> 
         	<rule>rule d+y-0</rule>
				<at>
					<left/>
					<parent/>
				</at>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>


	<!--     *************** -->
	<!--       Rule y-.T-0.pT-   -->
	<!--     *************** -->
	<!-- Within the context of a parent enclosure applies to the first nested enclosure 
	     which does not require access to the top of the parent.
	     In the absence of sibling enclosures which do need access to the top.
	     Use as a point of reference the previous-sibling label (error if there isn't one).
	     Rule: Position to the left of the parent enclosure underneath the point of reference.
	 -->

<xsl:template match="enclosure/enclosure 
	                     [not(yPositionalPointOfReference)]
	                     [$flib?isFirstNotToNeedAccessToTop(.)]     
	                     [not (some $sibling 
	                             in ../enclosure 
	                             satisfies $flib?needsAccessToTop($sibling)
	                          )
	                     ]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    " mode="tactics_four_enrichment">
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T-0.pT-'"/>      
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<!-- <x> --> 
         	<rule>rule y-.T-0.pT-</rule>
				<deferred/>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>

	<!--     *************** -->
	<!--       Rule y-.T-0.pT+   -->
	<!--     *************** -->
	<!-- Applies to the first nested enclosure which does not require access to top of parent enclosure
	      in the presence of sibling enclosures which need access to the top.
	 -->
	<xsl:template match="enclosure/enclosure
	                     [not(yPositionalPointOfReference)] 
	                     [$flib?isFirstNotToNeedAccessToTop(.)]     
	                     [some $sibling 
	                             in ../enclosure 
	                             satisfies $flib?needsAccessToTop($sibling)
	                     ]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    " mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T-0.pT+'"/>       
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<!-- <x> --> 
         	<rule>rule y-.T-0.pT+</rule>
				<!-- <at>
					<left/>
					<parent/>
				</at> -->
				<deferred/>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>

	<!--     *************** -->
	<!--       Rule y-.T-s   -->
	<!--     *************** -->
	<!-- Applies to the an enclosure which does not require access to top of parent enclosure
	     that is not the first among siblings not to require access to top.
	 -->
	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]  
						 [not($flib?needsAccessToTop(.))] 
						 [not($flib?isFirstNotToNeedAccessToTop(.))] 
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    " mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T-s'"/>   
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(enclosure)"
			              select="../preceding-sibling::enclosure
			                            [not($flib?needsAccessToTop(.))]
			                            [1]
			                      "/>
         <!-- <x> --> 
         	<rule>y-.T-s</rule>
            <at>
               <right/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
		  <!-- </x> -->
		</xsl:copy>
	</xsl:template>


	<!-- next three templates - a non-outermost enclosure with a non local top down route to it is placed at the top of its parent enclosure. --> 
	              
	<!--     ************ -->
	<!--       Rule y-.T+0.pL+    -->
	<!--     ************ -->

	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]  
						 [$flib?needsAccessToTop(.)]  
						 [$flib?isFirstToNeedAccessToTop(.)]  
						 [preceding-sibling::label]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    "
	              mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T+0.pL+'"/>  
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(label)"
			              select="../preceding-sibling::label[1]"/>
			<!-- bit dodgy this because I have assumed the first label has an id  -->
         <!-- <x> --> 
         	<rule>y-.T+0.pL+</rule>
		    	<at>
		    		<right/>
	    			<of>
	    				<xsl:value-of select="$pointOfReference/id"/>
	    			</of>
	    		</at>
		  <!-- </x> -->
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule y-.T+0.pL-   -->
	<!--     *********** -->
	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]   
						 [$flib?isFirstToNeedAccessToTop(.)]  
						 [not(preceding-sibling::label)]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                    " 
	              mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T+0.pL-'"/> 
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>

			<!-- <x> -->
         	<rule><xsl:value-of select="$rulename"/></rule>
				<deferred/> 
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule y-.T+s   -->
	<!--     *********** -->              
	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]   
						 [$flib?needsAccessToTop(.)]  
						 [not($flib?isFirstToNeedAccessToTop(.))]
	                  /x 
	                     [not(at)]
	                     [not(deferred)] 
	                    "
	               mode="tactics_four_enrichment">  
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T+s'"/> 
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element()"
			              select="$flib?previousNotToNeedAccessToTop(..)"/>
			  <!-- <x> -->
         	<rule>y-.T+s</rule>
            <at>
               <right/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
            <xsl:if test="not(delta)">
            	<delta>1</delta>
         	</xsl:if>
         <!-- </x> -->
		</xsl:copy>
	</xsl:template>
	

	
	<!--     ************************ -->
	<!--       Rule y+0 A y+0.wF+.1+  -->
	<!--     ************************ -->
	<xsl:template match="enclosure
	                     [yPositionalPointOfReference]
	                     [let $yplus := $flib?yPositionalPointOfReference(.)
	                        return ($yplus/wFill 
	                                  and (count($flib?yPositionalChildren($yplus))
			                                  eq 1
			                                )
			                          )
	                     ]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]  
						   " 
						 mode="tactics_four_enrichment">
		<xsl:variable name="rulename" as="xs:string" select="'y+0.wF+.1+'"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <x> --> 
	         	<rule><xsl:value-of select="$rulename"/></rule>
					<place>
						<centre/>
					</place>
					<at>
						<centre/>
						<parent/>
					</at>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>
	
	<!--     ******************** -->
	<!--       Rule y+0.wF+.1-    -->
	<!--     ******************** -->
	<xsl:template match="enclosure
	                     [yPositionalPointOfReference]  
						      [let $yplus := $flib?yPositionalPointOfReference(.)
	                        return ($yplus/wFill 
	                                  and (count($flib?yPositionalChildren(
			                                                          $yplus))
			                                  gt 1)
			                          )
	                     ]
	                  /x 
	                     [not(at)]
	                     [not(deferred)] 
						   " 
						 mode="tactics_four_enrichment">

      <xsl:variable name="rulename" as="xs:string" select="'y+0.wF+.1-'"/>
		<xsl:variable name="yPositionalPointOfReference"
		                as="element()"
						select="$flib?yPositionalPointOfReference(..)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <x> --> 
	         	<rule><xsl:value-of select="$rulename"/></rule>
					<place>
						  <left/>
					</place>
					<at>
						<left/>  
						<of>
							<xsl:value-of select="../yPositionalPointOfReference"/>
						</of>
					</at>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>
	
	<!--     ****************** -->
	<!--       Rule y+0.wF-     -->
	<!--     ****************** -->
	<xsl:template match="enclosure
	                     [yPositionalPointOfReference]  
						      [not($flib?yPositionalPointOfReference(.)/wFill)]
						      [not(some $sibling 
						           in preceding-sibling::enclosure
								     satisfies ($sibling/yPositionalPointOfReference eq yPositionalPointOfReference)
								    )
					      	]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
	                     [not(some $sibling 
						           in ../preceding-sibling::enclosure
								     satisfies ($sibling/yPositionalPointOfReference eq ../yPositionalPointOfReference)
								    )
					      	]


						   " 
						 mode="tactics_four_enrichment">
      <xsl:variable name="rulename" as="xs:string" select="'XXX y+0.wF-'"/>

		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <x> --> 
	         	<rule><xsl:value-of select="$rulename"/></rule>
					<place>
						<centre/> 
					</place>
					<at>
						<centre/>
						<of>
							<xsl:value-of select="../yPositionalPointOfReference"/>
						</of>
					</at>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>

	<!--     *********** -->
	<!--       Rule y+s   -->
	<!--     *********** -->
	<xsl:template match="enclosure
	                     [yPositionalPointOfReference]  
						      [some $sibling 
						        in preceding-sibling::enclosure
								  satisfies $sibling/yPositionalPointOfReference eq yPositionalPointOfReference
					      	]
	                  /x 
	                     [not(at)]
	                     [not(deferred)]
						   " 
						 mode="tactics_four_enrichment">

      <xsl:variable name="rulename" as="xs:string" select="'y+s'"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <x> --> 
				<place>
					<left/>
				</place>
         	<rule><xsl:value-of select="$rulename"/></rule>
				<at>
					<right/>
					<outer/>
					<of>
						<xsl:value-of select="../preceding-sibling::enclosure
								   [yPositionalPointOfReference eq current()/../yPositionalPointOfReference]
								   [1]/id"/>
					</of>
				</at>
				<xsl:if test="not(delta)">
            	<delta>1</delta>
         	</xsl:if>
			<!-- </x> -->
		</xsl:copy>
	</xsl:template>

</xsl:transform>