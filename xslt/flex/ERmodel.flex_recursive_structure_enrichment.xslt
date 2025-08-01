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

<!--
<xsl:template match="/">
      <xsl:message>Max depth is <xsl:value-of select="$maxdepth"/> </xsl:message>
      <xsl:call-template name="recursive_diagram_enrichment">
         <xsl:with-param name="interim" select="."/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
</xsl:template>

<xsl:template match="*">
<xsl:message>super generic rule <xsl:value-of select="name()"/></xsl:message>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>
-->

<xsl:template name="recursive_structure_enrichment">
   <!-- a little different from the recursive logic I ususally employ in that
     depth is passed through and on each such sweep encolosures of that depth marked
-->
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in recursive structure enrichment        - depth <xsl:value-of select="$depth"/>  interim child node name <xsl:value-of select="$interim/*/name()"/></xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:message>initiating recursive structure enrichment from <xsl:value-of select="name()"/></xsl:message>
         <xsl:copy>
            <xsl:apply-templates mode="recursive_structure_enrichment">
               <xsl:with-param name="depth" select="$depth"/>
            </xsl:apply-templates>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$maxdepth">
            <xsl:call-template name="recursive_structure_enrichment">
               <xsl:with-param name="interim" select="$next"/>
               <xsl:with-param name="depth" select="$depth + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> <xsl:value-of select="if($depth!=$maxdepth) 
                                                then 'unchanged fixed point diagram enrichment'
                                                else 'TERMINATED EARLY AT max iterations'" />
            </xsl:message>
            <xsl:copy-of select="$next"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable> 
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_structure_enrichment">
   <xsl:param name="depth"/>
   <xsl:copy>
      <xsl:apply-templates mode="recursive_structure_enrichment">
         <xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
   </xsl:copy>
</xsl:template>

   <!-- yPositionalDepthShort -->
   <!-- Calculate a compositional depth attribute for all outermost enclosures -->
   <!-- From an outermost enclosure index all other outermost enclosures that can be reached 
        by ascending top down routes --> 

<!-- a little tricky to decide on what the root is !! -->
<!-- was prior to 29 July 2025
   <xsl:template match="enclosure
                        [not(parent::enclosure)]
                        [not(yPositionalDepthShort)]
                        [not(key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id)
                                         [not(id=current()/id)])
                        ]
                        " 
                   mode="recursive_structure_enrichment"
                   priority="100">

-->
<!--    <xsl:template match="enclosure
                        [not(parent::enclosure)]
                        [not(yPositionalDepthShort)]
                        [not(key('ExitContainersOfEnteringTopdownRoutes',id)
                                         [not(id=current()/id)])
                         (: i.e. there are no top down routes enter this enclosure except 
                                those that also exit from it (i.e are recursive aka 'pigs ears')
                         :)
                        ]
                        " 
                   mode="recursive_structure_enrichment"
                   priority="100"> -->
<!-- there are standalone recursive systems of relationships such that the above test 
     fails to tag any enclosures as compositionaldepth zero enclosures 
       (though the [not(id=current()/id)] that you see above deals with the simplest
       possible case of such - those tht are length 1 and on 'one the nose').
     There are a number of possiblities for programming support these recursive structures but for now
     let us make sure that we flag them up and terminate with an error in circumstances as 
     the current algorithm fall short of establishing compositional depth.
     One work around for the the gap that we currently leave open (rather than actually plugging it)
     is to exlicitly tag one or more of the problematic enclosures in the incoming
     source file as <yPositionalDepthShort>0</yPositionalDepthShort>.
-->
    <xsl:template match="enclosure
                        [not(yPositionalDepthShort)]
                        [
                           not(key('ExitContainersOfEnteringTopdownRoutes',id)
                                         [not(id=current()/id)]
                                         [.. is current()/..]
                              )
                        ]
                        " 
                   mode="recursive_structure_enrichment"
                   priority="100">
      <xsl:param name="depth"/>  
      <xsl:copy>
         <xsl:message> In enclosure id '<xsl:value-of select="id"/>'</xsl:message>
         <xsl:assert test="$depth=0">I expected to be here at depth zero</xsl:assert>
         <yPositionalDepthShort>
            <xsl:value-of select="0"/>
         </yPositionalDepthShort>
         <xsl:apply-templates mode="recursive_structure_enrichment">
            <xsl:with-param name="depth" select="$depth"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="enclosure
                        [not(yPositionalDepthShort)]
                        " 
                   mode="recursive_structure_enrichment">
      <xsl:param name="depth"/>
      <xsl:copy> 
         <xsl:if test="some $cparent in key('ExitContainersOfEnteringTopdownRoutes',id)
                        satisfies $cparent/yPositionalDepthShort = ($depth - 1)">
            <yPositionalDepthShort>
               <xsl:value-of select="$depth"/>
            </yPositionalDepthShort>
         </xsl:if>
         <xsl:apply-templates mode="recursive_structure_enrichment">
            <xsl:with-param name="depth" select="$depth"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

   <!-- END OF yPositionalDepthShort -->
</xsl:transform>