<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->

<xsl:output method="xml"  indent="yes" cdata-section-elements="sourcecode"/>

<xsl:variable name="maximumdepth" as="xs:integer" select="if ($maxiter) then $maxiter else 100" /> 



<xsl:template match="/" mode="recursive_diagram_prior_enrichment">
      <xsl:message>Max depth is <xsl:value-of select="$maximumdepth"/> </xsl:message>
      <xsl:call-template name="recursive_diagram_prior_enrichment">
         <xsl:with-param name="interim" select="."/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
</xsl:template>


<xsl:template name="recursive_diagram_prior_enrichment">
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in recursive diagram prior enrichment            - depth <xsl:value-of select="$depth"/> </xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
            <xsl:apply-templates mode="recursive_diagram_prior_enrichment"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <!-- <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$maximumdepth"> -->
         <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$maximumdepth">
            <xsl:call-template name="recursive_diagram_prior_enrichment">
               <xsl:with-param name="interim" select="$next"/>
               <xsl:with-param name="depth" select="$depth + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> <xsl:value-of select="if($depth!=$maximumdepth) 
                                                then 'unchanged fixed point diagram enrichment'
                                                else 'TERMINATED EARLY AT max iterations'" />
            </xsl:message>
            <xsl:copy-of select="$next"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable> 
   <xsl:copy-of select="$result"/>
</xsl:template>


<xsl:template match="*" mode="recursive_diagram_prior_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_prior_enrichment"/>
   </xsl:copy>
</xsl:template>

<!-- want to build accumulate yPositionalPriors in every enclosre like this:
      <enclosure>
         ...
         <yPositionalPriors>
            <enclosureId>...</enclosureId>
            <enclosureId>...</enclosureId>
            ...
         </yPositionalPriors>
         ...
      </enclosure>
-->
<xsl:template match="enclosure[not(yPositionalPriors)]" mode="recursive_diagram_prior_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_prior_enrichment"/>
      <yPositionalPriors>
         <xsl:for-each select="key('ExitContainersOfEnteringTopdownRoutes',id)">
            <enclosureId>
               <xsl:value-of select="id"/>
            </enclosureId>
         </xsl:for-each>
      </yPositionalPriors>
   </xsl:copy>
</xsl:template> 

<xsl:template match="enclosure
                     [key('ExitContainersOfEnteringTopdownRoutes',id)]
                     /yPositionalPriors
                     " 
               mode="recursive_diagram_prior_enrichment">
   <xsl:copy>
      <xsl:message> FIRING! at enclosure '<xsl:value-of select="../id"/>'</xsl:message>
      <xsl:apply-templates   mode="recursive_diagram_prior_enrichment"/>
      <xsl:variable name="toBeAdded"
                    as="xs:string*"
                    select="distinct-values(
                    key('ExitContainersOfEnteringTopdownRoutes',../id)
                   /yPositionalPriors/enclosureId
                       [
                         not(
                              some $id 
                              in current()/enclosureId
                              satisfies $id eq .
                            )  
                       ]
                                           )"/>

      <xsl:for-each select="$toBeAdded">
         <enclosureId>
           <xsl:copy-of select="."/>
         </enclosureId>
      </xsl:for-each>
   </xsl:copy>
</xsl:template> 

</xsl:transform>

