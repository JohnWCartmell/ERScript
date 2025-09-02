

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
	                  /y[not(at)]
	                    [not(deferred)]
	                    " mode="tactics_four_enrichment">
   <xsl:variable name="rulename" as="xs:string" select="'d+y-0'"/>    
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
		<!-- <y> -->
	   	<rule>d+y-0</rule>
	   	<at>
	   		<top/>
	   		<parent/>
	   	</at>
   	<!-- </y> -->
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

<xsl:template match="enclosure
                     /enclosure 
	                     [not(yPositionalPointOfReference)]
	                     [$flib?isFirstNotToNeedAccessToTop(.)]     
	                     [not (some $sibling 
	                             in ../enclosure 
	                             satisfies $flib?needsAccessToTop($sibling)
	                          )
	                     ]
	                  /y[not(at)]
	                    [not(deferred)]
	                    " mode="tactics_four_enrichment">
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T-0.pT-'"/>      
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(label)?"
			              select="../preceding-sibling::label[last()]"/>
			<!-- bit dodgy this because I have assumed the first label has an id  -->
			<xsl:if test="not($pointOfReference)">
				<xsl:message>In rule y-.T-0.pT-, enclosure is '<xsl:value-of select="id"/>'</xsl:message>
				<xsl:message>In rule y-.T-0.pT-, the point of reference label does not exist' </xsl:message>
				<xsl:message terminate="yes">In rule y-.T-0.pT-, enclosure is '<xsl:copy-of select="."/>'</xsl:message>
			</xsl:if>
			<xsl:if test="not($pointOfReference/id)">
				<xsl:message>In rule y-.T-0.pT-, enclosure is '<xsl:value-of select="id"/>'</xsl:message>
				<xsl:message terminate="yes">In rule y-.T-0.pT-, the point of reference label does not have an id. Label text is '<xsl:value-of select="$pointOfReference/text"/>' </xsl:message>
			</xsl:if>
			<!-- <y> -->
         	<rule>y-.T-0.pT-</rule>
         	<at>
         		<bottom/>
         		<of>
         			<xsl:value-of select="$pointOfReference/id"/>
         		</of>
         	</at>
         <!-- </y> -->
		</xsl:copy>
	</xsl:template>

	<!--     *************** -->
	<!--       Rule y-.T-0.pT+   -->
	<!--     *************** -->
	<!-- Applies to the first nested enclosure which does not require access to top of parent enclosure
	      in the presence of sibling enclosures which need access to the top.
	 -->
	<xsl:template match="enclosure
	                    /enclosure 
		                     [not(yPositionalPointOfReference)] 
		                     [$flib?isFirstNotToNeedAccessToTop(.)]     
		                     [some $sibling 
		                             in ../enclosure 
		                             satisfies $flib?needsAccessToTop($sibling)
		                     ]
	                  	/y
	                  		[not(at)]
	                    		[not(deferred)]
	                    " mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T-0.pT+'"/>       
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(enclosure)"
			              select="$flib?firstSiblingToNeedAccessToTop(..)"/>
			<!-- <y> -->
         	<rule>y-.T-0.pT+</rule>
         	<at>
         		<bottom/>
         		<of>
         			<xsl:value-of select="$pointOfReference/id"/>
         		</of>
         	</at>
         <!-- </y> -->
		</xsl:copy>
	</xsl:template>

	<!--     *************** -->
	<!--       Rule y-.T-s   -->
	<!--     *************** -->
	<!-- Applies to the an enclosure which does not require access to top of parent enclosure
	     that is not the first among siblings not to require access to top.
	 -->
	<xsl:template match="enclosure
	                    /enclosure
				                [not(yPositionalPointOfReference)]  
									 [not($flib?needsAccessToTop(.))] 
									 [not($flib?isFirstNotToNeedAccessToTop(.))] 
	                  	/y
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
         <!-- <y> -->
            <rule>y-.T-s</rule>
		      <place><top/><edge/></place>
            <at>
               <top/>
               <edge/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
         <!-- </y> -->
		</xsl:copy>
	</xsl:template>


	<!-- a non-outermost enclosure with a non local top down route to it is placed at the top of its parent enclosure. --> 
	              
	<!--     ************* -->
	<!--       Rule y-.T+  -->
	<!--     ************* -->

	<xsl:template match="enclosure
	                    /enclosure
			                [not(yPositionalPointOfReference)]  
								 [$flib?needsAccessToTop(.)]  
	                  /y
		                   [not(at)]
		                   [not(deferred)]
	                    "
	              mode="tactics_four_enrichment"> 
	   <xsl:variable name="rulename" as="xs:string" select="'y-.T+'"/>  
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
         <!-- <y> -->
           <rule>y-.T+</rule>
		     <place><top/><outer/></place>
            <at>
               <top/><parent/>
            </at>
         <!-- </y> -->
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
	                     /y
	                        [not(at)]
	                        [not(deferred)] 
						   " 
						 mode="tactics_four_enrichment">
		<xsl:variable name="rulename" as="xs:string" select="'y+0.wF+.1+'"/>
 		<xsl:variable name="yPositionalPointOfReference"
		                as="element()"
						select="$flib?yPositionalPointOfReference(..)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <y> -->
				<rule><xsl:value-of select="$rulename"/></rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="../yPositionalPointOfReference"/>
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route --> 
			<!-- </y> -->
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
	                  	/y
	                  	   [not(at)]
	                        [not(deferred)]
						   " 
						 mode="tactics_four_enrichment">

      <xsl:variable name="rulename" as="xs:string" select="'y+0.wF+.1-'"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <y> -->
				<rule><xsl:value-of select="$rulename"/></rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="../yPositionalPointOfReference"/>
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route --> 
			<!-- </y> -->
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
	                     /y
	                        [not(at)]
	                        [not(deferred)]
						   " 
						 mode="tactics_four_enrichment">
      <xsl:variable name="rulename" as="xs:string" select="'y+0.wF-'"/>
		<xsl:variable name="yPositionalPointOfReference"
		                as="element()"
						select="$flib?yPositionalPointOfReference(..)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <y> -->
				<rule><xsl:value-of select="$rulename"/></rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="../yPositionalPointOfReference"/>
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route --> 
			<!-- </y> -->
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
	                     /y
	                        [not(at)]
	                        [not(deferred)]
						   " 
						 mode="tactics_four_enrichment">

      <xsl:variable name="rulename" as="xs:string" select="'y+s'"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<!-- <y> -->
				<rule><xsl:value-of select="$rulename"/></rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="../yPositionalPointOfReference"/>
					</of>
				</at>
				<xsl:if test="not(delta)">
					<delta>1</delta>   <!-- make room for incoming top down route -->
				</xsl:if> 
			<!-- </y> -->
		</xsl:copy>
	</xsl:template>

</xsl:transform>