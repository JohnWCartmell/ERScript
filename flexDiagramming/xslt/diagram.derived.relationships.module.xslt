<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">


<xsl:output method="xml"  indent="yes" cdata-section-elements="sourcecode"/>

<xsl:variable name="flexLib" as="map(xs:string,function(*))">
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
$containsOrEqual
:= function ($container as element(enclosure), 
             $otherEnclosure  as element(enclosure)) as xs:boolean
{
   some $member in $container/descendant-or-self::enclosure satisfies $member is  $otherEnclosure
},
$routeNodesEndingOnLeftSideOf
:= function ($enclosure as element(enclosure)) as element(*(:source|destination:))*
{  
 root($enclosure)//route/*[self::source|self::destination][left_side][id eq $enclosure/id]
},
$routeNodesEndingOnRightSideOf
:= function ($enclosure as element(enclosure)) as element(*(:source|destination:))*
{  
 root($enclosure)//route/*[self::source|self::destination][right_side][id eq $enclosure/id]
},
$routeNodesEndingOnTopEdgeOf
:= function ($enclosure as element(enclosure)) as element(*(:source|destination:))*
{  
 root($enclosure)//route/*[self::source|self::destination][top_edge][id eq $enclosure/id]
},
$routeNodesEndingOnBottomEdgeOf
:= function ($enclosure as element(enclosure)) as element(*(:source|destination:))*
{  
 root($enclosure)//route/*[self::source|self::destination][bottom_edge][id eq $enclosure/id]
},
$endpointForSpecificRouteNode
:= function ($node as element(*(:source|destination:))) as element(point)
{  
if ($node[self::source]) 
then $node/../path/point[startpoint]
else if ($node[self::destination])
then $node/../path/point[endpoint]
else fn:error(fn:QName('http://www.entitymodelling.org/endpointForSpecificEdge', 
                        'er:wrong type for parameter'),'type:'|| $node/name())
},
$routeEndpointsOnLeftSide
:= function ($enclosure as element(enclosure)) as element(point)*
{  
(: use ! operator map a function through the sequence of results of a function call :)
   $routeNodesEndingOnLeftSideOf($enclosure) ! $endpointForSpecificRouteNode(.)
},
$routeEndpointsOnRightSide
:= function ($enclosure as element(enclosure)) as element(point)*
{  
   $routeNodesEndingOnRightSideOf($enclosure) ! $endpointForSpecificRouteNode(.)
},
$routeEndpointsOnTopEdge
:= function ($enclosure as element(enclosure)) as element(point)*
{  
   $routeNodesEndingOnTopEdgeOf($enclosure) ! $endpointForSpecificRouteNode(.)
},
$routeEndpointsOnBottomEdge
:= function ($enclosure as element(enclosure)) as element(point)*
{  
   $routeNodesEndingOnBottomEdgeOf($enclosure) ! $endpointForSpecificRouteNode(.)
}
return map{
   'source':$source,
   'destination':$destination,
   'routeEndpointsOnLeftSide':$routeEndpointsOnLeftSide,
   'routeEndpointsOnRightSide':$routeEndpointsOnRightSide,
   'routeEndpointsOnTopEdge':$routeEndpointsOnTopEdge,
   'routeEndpointsOnBottomEdge':$routeEndpointsOnBottomEdge,
   'containsOrEqual': $containsOrEqual
}"/>
</xsl:variable>

</xsl:transform>

