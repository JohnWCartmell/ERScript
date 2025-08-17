

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
	
	<!-- enclosure => set of route ... routes down to or into an entry enclosure -->
	<xsl:key name="EnteringTopdownRoute"  match="route[top_down]" use="destination/entryContainer"/>

	<!-- enclosure => set of route  .. routes down to the enclosure --> 
    <xsl:key name="ActualIncomingTopdownRoute" match="route[top_down]" use="destination/id"/>

<xsl:variable name="flib" as="map(xs:string,function(*))">
<xsl:sequence select="
let 
$source
:= function ($route as element(route)) as element(enclosure)
{  
	let $result := root($route)//enclosure[id eq $route/source/id]
	return if (exists($result)) 
	       then $result
	       else fn:error(fn:QName('http://www.entitymodelling.org/SOURCE', 'er:sourcenotdefined'),'xxx')
},
$destination
:= function ($route as element(route)) as element(enclosure)
{  
	let $result :=  root($route)//enclosure[id eq $route/destination/id]
	return if (exists($result)) 
	       then $result
	       else fn:error(fn:QName('http://www.entitymodelling.org/DEST', 
	                     'er:destinationnotdefined'),
	                     'id:'||$route/destination/id)
},
$yPositionalPointOfReference
:= function ($enclosure as element(enclosure)) as element(enclosure)?
{  
	if ($enclosure/yPositionalPointOfReference)
	then 
	     let $result :=  $enclosure/../enclosure[id eq $enclosure/yPositionalPointOfReference]
	     return if (exists($result)) 
	           then $result
	           else fn:error(fn:QName('http://www.entitymodelling.org/yPointOfReference',
	                                  'er:yPositionalPointOfReferencenotdefined'),
	                                  'enclosure: ' || $enclosure/id || ', yPositionalPointOfReference: ' || $enclosure/yPositionalPointOfReference)
	else ()
},
$yPositionalChildren
:= function ($enclosure as element(enclosure)) as element(enclosure)*
{  
	$enclosure/../enclosure[yPositionalPointOfReference eq $enclosure/id]
},
$containsOrEqual
:= function ($container as element(enclosure), 
             $otherEnclosure  as element(enclosure)) as xs:boolean
{
	some $member in $container/descendant-or-self::enclosure satisfies $member is  $otherEnclosure
},
$needsAccessToTop
:= function ($enclosure as element(enclosure)) as xs:boolean
{
	let $needsAccessToTopRecursive :=
	function ($self, $enclosure as element(enclosure)) as xs:boolean
	{  
		if (not($enclosure/parent::enclosure))
		then false()
		else
			let $parentEnclosure := $enclosure/..                
			return
			(some $route in root($enclosure)//route
			 satisfies not($containsOrEqual($parentEnclosure, $source($route)))
			          and $containsOrEqual($enclosure, $destination($route))
			)
			or 
			(some $yPositionalChild in $yPositionalChildren($enclosure)
			   satisfies $self($self,$yPositionalChild)
			)
	}
	return $needsAccessToTopRecursive($needsAccessToTopRecursive,$enclosure)
},
$isFirstToNeedAccessToTop
:= function ($enclosure as element(enclosure)) as xs:boolean
{  
	$needsAccessToTop($enclosure)
	and not( some $previous in $enclosure/preceding-sibling::enclosure satisfies $needsAccessToTop($previous))
},
$firstSiblingToNeedAccessToTop
:= function ($enclosure as element(enclosure)) as element(enclosure)
{  
	$enclosure/../enclosure[$needsAccessToTop(.)][1]
},
$previousToNeedAccessToTop
:= function ($enclosure as element(enclosure)) as element(enclosure)?
{  
	$enclosure/preceding-sibling::enclosure[$needsAccessToTop(.)][last()]
},	
$isFirstNotToNeedAccessToTop
:= function ($enclosure as element(enclosure)) as xs:boolean
{  
	not($needsAccessToTop($enclosure))
	and
	not($enclosure/preceding-sibling::enclosure[not($needsAccessToTop(.))])
},
$previousNotToNeedAccessToTop
:= function ($enclosure as element(enclosure)) as element(enclosure)
{  
	$enclosure/preceding-sibling::enclosure[$needsAccessToTop(.)][1]
}
return map{
	'source':$source,
	'destination':$destination,
	'yPositionalPointOfReference': $yPositionalPointOfReference,
	'yPositionalChildren': $yPositionalChildren,
	'needsAccessToTop':$needsAccessToTop,
	'isFirstToNeedAccessToTop':$isFirstToNeedAccessToTop,
	'firstSiblingToNeedAccessToTop':$firstSiblingToNeedAccessToTop,
	'previousToNeedAccessToTop':$previousToNeedAccessToTop,
	'isFirstNotToNeedAccessToTop':$isFirstNotToNeedAccessToTop,
	'previousNotToNeedAccessToTop':$previousNotToNeedAccessToTop
}"/>
</xsl:variable>

	<xsl:template match="@*|node()" mode="tactics_four_enrichment">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
		</xsl:copy>
	</xsl:template>


	<!--     *************** -->
	<!--       Rule d+y-0    -->
	<!--     *************** -->
	<!-- Applies to the first enclosure which does not require access to top of parent enclosure
	      in the absense of sibling enclosures which need access to the top.
	 -->

<xsl:template match="diagram/enclosure 
	                     [not(x)]
	                     [not(yPositionalPointOfReference)]  
	                     [not (preceding-sibling::enclosure[not(yPositionalPointOfReference)]
	                          )
	                     ]
	                    " mode="tactics_four_enrichment">      
		<xsl:copy>
			<!-- <label><text>rule d+y-0</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<x> 
         	<rule>rule d+y-0</rule>
				<at>
					<left/>
					<parent/>
				</at>
			</x>
			<y>
         	<rule>rule d+y-0</rule>
         	<at>
         		<top/>
         		<parent/>
         	</at>
         </y>
		</xsl:copy>
	</xsl:template>


	<!--     *************** -->
	<!--       Rule y-.T-0.pT-   -->
	<!--     *************** -->
	<!-- Applies to the first enclosure which does not require access to top of parent enclosure
	      in the absense of sibling enclosures which need access to the top.
	 -->

<xsl:template match="enclosure/enclosure 
	                     [not(x)]
	                     [not(yPositionalPointOfReference)]
	                     [$flib?isFirstNotToNeedAccessToTop(.)]     
	                     [not (some $sibling 
	                             in ../enclosure 
	                             satisfies $flib?needsAccessToTop($sibling)
	                          )
	                     ]
	                    " mode="tactics_four_enrichment">      
		<xsl:copy>
			<!-- <label><text>rule y-.T-0.pT-</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(label)?"
			              select="preceding-sibling::label[last()]"/>
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
			<x> 
         	<rule>rule y-.T-0.pT-</rule>
				<at>
					<left/>
					<parent/>
				</at>
			</x>
			<y>
         	<rule>rule y-.T-0.pT-</rule>
         	<at>
         		<bottom/>
         		<of>
         			<xsl:value-of select="$pointOfReference/id"/>
         		</of>
         	</at>
         </y>
		</xsl:copy>
	</xsl:template>

	<!--     *************** -->
	<!--       Rule y-.T-0.pT+   -->
	<!--     *************** -->
	<!-- Applies to the first enclosure which does not require access to top of parent enclosure
	      in the presence of sibling enclosures which need access to the top.
	 -->
	<xsl:template match="enclosure/enclosure 
	                     [not(x)]
	                     [not(yPositionalPointOfReference)]  
						      (: [not($flib?needsAccessToTop(.))]  :)
	                     [$flib?isFirstNotToNeedAccessToTop(.)]     
	                     [some $sibling 
	                             in ../enclosure 
	                             satisfies $flib?needsAccessToTop($sibling)
	                     ]
	                    " mode="tactics_four_enrichment">      
		<xsl:copy>
			<!-- <label><text>rule y-.T-0.pT+</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()"  mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(enclosure)"
			              select="$flib?firstSiblingToNeedAccessToTop(.)"/>
			<x> 
         	<rule>rule y-.T-0.pT+</rule>
				<at>
					<left/>
					<parent/>
				</at>
			</x>
			<y>
         	<rule>rule y-.T-0.pT+</rule>
         	<at>
         		<bottom/>
         		<of>
         			<xsl:value-of select="$pointOfReference/id"/>
         		</of>
         	</at>
         </y>
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
						 [not(y)]
	                    " mode="tactics_four_enrichment">  
		<xsl:copy>
			<!-- <label><text>rule y-.T-s</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(enclosure)"
			              select="preceding-sibling::enclosure
			                            [not($flib?needsAccessToTop(.))]
			                            [1]
			                      "/>
         <x> 
         	<rule>y-.T-s</rule>
		      <at><left/><parent/></at>
		  </x>
         <y>
            <rule>y-.T-s</rule>
		      <place><top/><edge/></place>
            <at>
               <bottom/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
         </y>
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
						 [not(y)]
	                    "
	              mode="tactics_four_enrichment"> 
		<xsl:copy>
			<!-- <label><text>rule y-.T+0.pL+</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element(label)"
			              select="preceding-sibling::label[1]"/>
			<!-- bit dodgy this because I have assumed the first label has an id  -->
         <x> 
         	<rule>y-.T+0.pL+</rule>
		    	<at>
		    		<right/>
	    			<of>
	    				<xsl:value-of select="$pointOfReference/id"/>
	    			</of>
	    		</at>
		  </x>
         <y>
           <rule>y-.T+0.pL+</rule>
		     <place><top/></place>
            <at>
               <top/><parent/>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	
	<!--     *********** -->
	<!--       Rule y-.T+0.pL-   -->
	<!--     *********** -->
	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]   
						 [$flib?isFirstToNeedAccessToTop(.)]  
						 [not(preceding-sibling::label)]
						 [not(y)]		 
	                    " 
	              mode="tactics_four_enrichment"> 
		<xsl:copy>
			<!-- <label><text>rule y-.T+0.pL-</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
         <y>
         	<rule>y-.T+0.pL-</rule>
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
	<!--       Rule y-.T+s   -->
	<!--     *********** -->              
	<xsl:template match="enclosure/enclosure
	                [not(yPositionalPointOfReference)]   
						 [$flib?needsAccessToTop(.)]  
						 [not($flib?isFirstToNeedAccessToTop(.))]  
						 [not(y)]
	                    "
	               mode="tactics_four_enrichment">  
		<xsl:copy>
			<!-- <label><text>rule y-.T+s</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<xsl:variable name="pointOfReference" as="element()"
			              select="$flib?previousNotToNeedAccessToTop(.)"/>
			  <x>
         	<rule>y-.T+s</rule>
            <at>
               <right/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
            <delta>1</delta>
         </x>
         <y>
         	<rule>y-.T+s</rule>
		      <place>
			     <top/>
				 <edge/>
		      </place>
            <at>
               <top/>
               <of>
               	<xsl:value-of select="$pointOfReference/id"/>
               </of>
            </at>
         </y>
		</xsl:copy>
	</xsl:template>
	

	
	<!--     *********** -->
	<!--       Rule y+0   -->
	<!--     *********** -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [yPositionalPointOfReference]  
						      [not(preceding::enclosure
								      [yPositionalPointOfReference eq current()/yPositionalPointOfReference]
							       )
					         ]
						   " 
						 mode="tactics_four_enrichment">
		<xsl:variable name="yPositionalPointOfReference"
		                as="element()"
						select="$flib?yPositionalPointOfReference(.)"/>
		<xsl:variable name="singular_yPositionalChild" as="xs:boolean"
			              select="count($flib?yPositionalChildren(
			                                  $yPositionalPointOfReference)
			                           ) eq 1"/>
		<xsl:variable name="variationA" as="xs:boolean"
			              select="$yPositionalPointOfReference/wFill
			                      and $singular_yPositionalChild"/>
	   <xsl:variable name="variationB" as="xs:boolean"
			              select="$yPositionalPointOfReference/wFill
			                      and not($singular_yPositionalChild)"/>
		<xsl:variable name="variationC" as="xs:boolean"
			              select="not($yPositionalPointOfReference/wFill)"/>

		<xsl:copy>
			<!-- <label><text>rule y+0</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<x> 
            <xsl:if test="$variationA">
	         	<rule>y+0.A</rule>
					<place>
						<centre/>
					</place>
					<at>
						<centre/>
						<parent/>
					</at>
				</xsl:if>
				<xsl:if test="$variationB">
	         	<rule>y+0.B</rule>
					<place>
						  <left/>
					</place>
					<at>
						<left/>  <!-- was <left/>  -->
						<of>
							<xsl:value-of select="yPositionalPointOfReference"/>
						</of>
					</at>
				</xsl:if>
				<xsl:if test="$variationC">
	         	<rule>y+0.C</rule>
					<place>
						<centre/> 
					</place>
					<at>
						<centre/>
						<of>
							<xsl:value-of select="yPositionalPointOfReference"/>
						</of>
					</at>
				</xsl:if>
			</x>
			<y>
				<rule>y+0</rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="yPositionalPointOfReference"/>
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route --> 
			</y>
		</xsl:copy>
	</xsl:template>

	<!--     *********** -->
	<!--       Rule y+s   -->
	<!--     *********** -->
	<xsl:template match="enclosure
	                     [not(x)]
	                     [yPositionalPointOfReference]  
						      [preceding-sibling::enclosure
								      [yPositionalPointOfReference eq current()/yPositionalPointOfReference]
					      	]
						   " 
						 mode="tactics_four_enrichment">
		<xsl:copy>
			<!-- <label><text>rule y+s</text><text_style>trace</text_style></label> -->
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
			<x> 
				<place>
					<left/>
				</place>
         	<rule>y+s</rule>
				<at>
					<right/>
					<outer/>
					<of>
						<xsl:value-of select="preceding-sibling::enclosure
								   [yPositionalPointOfReference eq current()/yPositionalPointOfReference]
								   [1]/id"/>
					</of>
				</at>
				<delta>1</delta>
			</x>
			<y>
				<rule>y+s</rule>
				<place>
					<top/>
				</place>
				<at>
					<bottom/>
					<of>
						 <xsl:value-of select="yPositionalPointOfReference"/>
					</of>
				</at>
				<delta>1</delta>   <!-- make room for incoming top down route --> 
			</y>
		</xsl:copy>
	</xsl:template>

</xsl:transform>