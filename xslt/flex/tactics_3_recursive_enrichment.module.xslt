<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">



<xsl:output method="xml"  indent="yes" cdata-section-elements="sourcecode"/>

<xsl:variable name="tactics_three_recursive__maxDepth" 
               as="xs:integer" 
               select="if ($maxiter) then $maxiter else 100" /> 

<!-- Definitions of
         yPositionalDepthLong      : enclosure -> nonNegativeNumber
         yPositionalPointOfReference : enclosure -> enclosure

-->

<xsl:template match="/" mode="tactics_three_recursive">
      <xsl:message>Max depth is <xsl:value-of select="$tactics_three_recursive__maxDepth"/> </xsl:message>
      <xsl:call-template name="tactics_three_recursive">
         <xsl:with-param name="interim" select="."/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
</xsl:template>


<xsl:template name="tactics_three_recursive">
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in  tactics three  recursive          - depth <xsl:value-of select="$depth"/> </xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
            <xsl:apply-templates mode="tactics_three_recursive"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <!-- <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$tactics_three_recursive__maxDepth"> -->
         <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$tactics_three_recursive__maxDepth">
            <xsl:call-template name="tactics_three_recursive">
               <xsl:with-param name="interim" select="$next"/>
               <xsl:with-param name="depth" select="$depth + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> <xsl:value-of select="if($depth!=$tactics_three_recursive__maxDepth) 
                                                then 'unchanged fixed point diagram enrichment'
                                                else 'TERMINATED EARLY AT max iterations'" />
            </xsl:message>
            <xsl:copy-of select="$next"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable> 
   <xsl:copy-of select="$result"/>
</xsl:template>


<xsl:template match="*" mode="tactics_three_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="tactics_three_recursive"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="enclosure
                     [not(yPositionalDepthLong)]
                     [every $candidate
                            in key('ExitContainersOfEnteringTopdownRoutes',id)
                            satisfies ($candidate/yPositionalDepthLong
                                          or (some $prior
                                                in $candidate/yPositionalPriors/enclosureId
                                               satisfies ($prior eq id)
                                             )
                                       )
                     ]
                     "
               mode="tactics_three_recursive"
               >
   <xsl:copy>
      <xsl:variable name="appropriateParents" as="element()*"
                    select="key('ExitContainersOfEnteringTopdownRoutes',id)
                    [. &lt;&lt; current()]   (: to give some control only take use docvument order as well :) 
                                           [not(some $prior
                                                  in yPositionalPriors/enclosureId
                                                satisfies ($prior eq current()/id)
                                                )
                                             or (
                                                  yPositionalDepthShort + 1
                                                  eq current()/yPositionalDepthShort cast as xs:nonNegativeInteger
                                                )
                                           ]  
                                           [ 
                                             not(some $containingEnclosure 
                                                 in current()/ancestor::enclosure 
                                                 satisfies $containingEnclosure is  .)
                                           ]
                                           "/>
      <xsl:if test="every $appropriate in $appropriateParents satisfies $appropriate/yPositionalDepthLong">
         <xsl:variable name="maxParentPositionalDepthLong"
                       as="xs:double"
                       select="max(($appropriateParents/(yPositionalDepthLong + 1) ,0))"/>
         <!-- depth is zero if all incoming are recursive -->
         <yPositionalDepthLong>
            <xsl:value-of select="$maxParentPositionalDepthLong"/>
         </yPositionalDepthLong>
         <xsl:if test="$maxParentPositionalDepthLong &gt; 0">
            <yPositionalPointOfReference>
               <xsl:value-of select="$appropriateParents
                                  [yPositionalDepthLong + 1 =$maxParentPositionalDepthLong]  
                                  [1]/id
                            "/>
            </yPositionalPointOfReference>
         </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="tactics_three_recursive"/>
   </xsl:copy>
</xsl:template> 
 

</xsl:transform>

