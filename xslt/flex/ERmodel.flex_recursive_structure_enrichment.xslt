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
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in recursive structure enrichment        - depth <xsl:value-of select="$depth"/> </xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:message>initiating recursive structure enrichment from <xsl:value-of select="name()"/></xsl:message>
         <xsl:copy>
            <xsl:apply-templates mode="recursive_structure_enrichment"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:if test="$debugon">
      <xsl:result-document href="concat('class_enriched_temp',$depth,'.xml')" method="xml">
        <xsl:sequence select="$next/diagram"/>
      </xsl:result-document>
   </xsl:if>
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
   <xsl:copy>
      <xsl:apply-templates mode="recursive_structure_enrichment"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="enclosure
                     [not(parent::enclosure)]
                     [not(depthOfNesting)]
                    " 
              mode="recursive_structure_enrichment">
   <xsl:copy>
      <depthOfNesting>
         <xsl:value-of select="0"/>
      </depthOfNesting>
      <xsl:apply-templates mode="recursive_structure_enrichment"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="enclosure
                     [parent::enclosure/depthOfNesting]
                     [not(depthOfNesting)]
                    " 
              mode="recursive_structure_enrichment">
   <xsl:copy>
      <depthOfNesting>
         <xsl:value-of select="parent::enclosure/depthOfNesting + 1"/>
      </depthOfNesting>
      <xsl:apply-templates mode="recursive_structure_enrichment"/>
   </xsl:copy>
</xsl:template>

   <!-- compositionalDepth -->
   <!-- Calculate a compositional depth attribute for all outermost enclosures -->
   <!-- From an outermost enclosure index all other outermost enclosures that can be reached 
        by ascending top down routes -->
   <!-- This is therefore a derived relationship -->
   <!-- watch out for recursive relationships  --> 

   <xsl:template match="enclosure
                        [not(parent::enclosure)]
                        [not(compositionalDepth)]
                        [not(key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id))]
                        " 
                   mode="recursive_structure_enrichment">
                   <!--
                         -->
      <xsl:copy>
         <compositionalDepth>
            <xsl:value-of select="0"/>
         </compositionalDepth>
         <xsl:apply-templates mode="recursive_structure_enrichment"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="enclosure
                        [not(parent::enclosure)]
                        [not(compositionalDepth)]
                        [key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id)]
                        [every $e 
                           in key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id)[not(id=current()/id)] 
                           satisfies $e/compositionalDepth 
                        ]
                        " 
                   mode="recursive_structure_enrichment">
      <xsl:copy> 
         <compositionalDepth>
            <xsl:value-of 
               select="max((key('OutermostEnclosuresFromWhichIncomingTopDownRoute',
                                                id)[not(id=current()/id)]/compositionalDepth))+1"/>
         </compositionalDepth>
         <xsl:apply-templates mode="recursive_structure_enrichment"/>
      </xsl:copy>
   </xsl:template>

   <!-- END OF compositionalDepth -->

</xsl:transform>