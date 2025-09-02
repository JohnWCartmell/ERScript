

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



	<xsl:template name="plant_x_label" match="enclosure"  mode="explicit">
   	<xsl:param name="rulename" as="xs:string"/>
		<label>
         <padding>0.1</padding>
			<text><xsl:value-of select="$rulename"/></text><text_style>trace</text_style>
			<x><place><right/><outer/></place><at><centre/><edge/><parent/></at></x>
			<y><place><outer/><top/></place><at><bottom/><edge/><parent/></at></y>
		</label>
	</xsl:template>

	<xsl:template name="plant_y_label" match="enclosure"  mode="explicit">
   	<xsl:param name="rulename" as="xs:string"/>
		<label>
         <padding>0.1</padding>
			<text><xsl:value-of select="$rulename"/></text><text_style>trace</text_style>
			<x><place><left/><outer/></place><at><centre/><edge/><parent/></at></x>
			<y><place><outer/><top/></place><at><bottom/><edge/><parent/></at></y>
		</label>
	</xsl:template>



	<xsl:template match="@*|node()" mode="tactics_four_enrichment">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()" mode="tactics_four_enrichment_plant_rule_labels">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment_plant_rule_labels"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="enclosure" mode="tactics_four_enrichment_plant_rule_labels">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="tactics_four_enrichment_plant_rule_labels"/>
			<xsl:if test="x/rule">
				<xsl:call-template name="plant_x_label">
					<xsl:with-param name="rulename" select="x/rule"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="y/rule">
				<xsl:call-template name="plant_y_label">
					<xsl:with-param name="rulename" select="y/rule"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

</xsl:transform>