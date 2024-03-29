<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:er="http://www.entitymodelling.org/ERmodel" 
               xmlns:era="http://www.entitymodelling.org/ERmodel" 
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>
<xsl:strip-space elements="*"/>

<xsl:param name="debug" as="xs:string?"/>

<xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />

<xsl:include href="ER.metaModelLib.module.xslt"/>
<xsl:include href="ER.dataLib.module.xslt"/>
<xsl:include href="ER.instanceData.module.xslt"/>

<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="newERmodel2.xpath_enrichment.module.xslt"/>

<xsl:variable name="instanceValidationLib"
              as="map(xs:string,function(*))"
              select="let
   $startInstance    := function($instance as element())
   {
   },
   $attribute   := function($instance as element(*),
                            $attr as element(er:attribute)
                            ) as xs:string
   {
      let $valueofattribute 
                  := $erDataLib?readAttribute($instance,$attr)
      return
          if (not($attr/er:optional) 
                  and 
              not($valueofattribute)
             )
          then '*********** Mandatory attribute has no value'
          else ''    
   },
   $startComposition := function($comprel as element(er:composition))
   {

   },
   $startMember      := function($comprel as  element(er:composition),
                                 $position as xs:positiveInteger)
   {

   },
   $endMember        := function($comprel as element(er:composition),
                                 $position as xs:positiveInteger)
   {

   },
   $endComposition   := function($comprel as element(er:composition))
   {

   },
   $reference := function($instance as element(*),
                          $refrel as element(er:reference)
                          ) as xs:string
   {
      let $precondition:= $erDataLib?getReferenceRelationshipPrecondition($instance, $refrel),
          $destination := $erDataLib?readReferenceOrDependencyOrConstructedRelationship($instance, $refrel),
          $relationship_is_mandatory := $refrel/cardinality/ExactlyOne
      return
         if ($precondition and not(exists($destination)))
         then 'relationship foreign key does not reference'
         else if ($relationship_is_mandatory and not($destination))
         then 'mandatory relationship is not defined'
        (: else if (count($destination) &gt; 1)
         then 'reference relationship not uniquely defined'
         :)
         else '' 
   },
   $endInstance      := function($instance as element())
   {
   }
   return map{
   'startInstance'   : $startInstance,
   'attribute'       : $attribute,
   'startComposition': $startComposition,
   'startMember'     : $startMember,
   'endMember'       : $endMember,
   'endComposition'  : $endComposition,
   'reference'       : $reference,
   'endInstance'     : $endInstance
   }
"/> <!-- end of instanceValidationLib -->

<!-- generic walk with callback functions passed as parameters -->
<xsl:template match="/">
   <xsl:if test="$debugon">
      <xsl:message>Debug is on </xsl:message>
      <xsl:result-document href="erMetaModelData.xml" method="xml">
          <xsl:sequence select="$erMetaModelData"/>
      </xsl:result-document>
    </xsl:if>

   <xsl:message><xsl:value-of select="map:keys($constructed_stroke_reference_stroke_dependency_evaluation_lib)"/></xsl:message>
   <xsl:message> Schema is described as '<xsl:value-of select="$erMetaModelData/er:description"/>'</xsl:message>
   <xsl:message> Schema (absolute) is named '<xsl:value-of select="$erMetaModelData/er:absolute/er:name"/>'</xsl:message>
   <xsl:message> Root instance element name '<xsl:value-of select="child::element()/name()"/>'</xsl:message>
   <xsl:if test="child::element()/name() ne $erMetaModelData/er:absolute/er:name">
      <xsl:message terminate="yes">Error ********** Root of instance is an element whose name does not match the absolute name specified in the meta data </xsl:message>
   </xsl:if>

   <xsl:variable name="typeTaggedInstanceData"
                 as="document-node()">
         <xsl:call-template name="typeTagInstanceData"/>
   </xsl:variable>

   <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
      <xsl:with-param name="typeTaggedInstanceData" select="$typeTaggedInstanceData"/>
      <xsl:with-param name="instance"         select="$typeTaggedInstanceData/child::element() "/>    
      <xsl:with-param name="startInstance"    select="$instanceValidationLib?startInstance"/>
      <xsl:with-param name="attribute"        select="$instanceValidationLib?attribute"/>
      <xsl:with-param name="startComposition" select="$instanceValidationLib?startComposition"/>
      <xsl:with-param name="startMember"      select="$instanceValidationLib?startMember"/>
      <xsl:with-param name="endMember"        select="$instanceValidationLib?endMember"/>
      <xsl:with-param name="endComposition"   select="$instanceValidationLib?endComposition"/>
      <xsl:with-param name="reference"        select="$instanceValidationLib?reference"/>
      <xsl:with-param name="endInstance"      select="$instanceValidationLib?endInstance"/>
   </xsl:call-template>

</xsl:template>

<xsl:template name="walk_an_instance_subtree__guided_by_schema">
   <xsl:param name="typeTaggedInstanceData" as="document-node()"/>
   <xsl:param name="instance" as="element()"/>
   <xsl:param name="startInstance" as="function(element()) as xs:string?"/>
   <xsl:param name="attribute"     as="function(element(*),element(er:attribute)) as xs:string?"/>
   <xsl:param name="startComposition" as="function(element(er:composition)) as xs:string?"/>
   <xsl:param name="startMember" as="function(element(er:composition),xs:positiveInteger) as xs:string?"/>
   <xsl:param name="endMember"   as="function(element(er:composition),xs:positiveInteger) as xs:string?"/>
   <xsl:param name="endComposition" as="function(element(er:composition)) as xs:string?"/>
   <xsl:param name="reference"      as="function(element(*),element(er:reference)) as xs:string?"/>
   <xsl:param name="endInstance" as="function(element()) as xs:string?"/>

   <!-- <xsl:message>Instance of type '<xsl:value-of select="$instance/name()"/>'' name '<xsl:value-of select="$instance/er:name"/>'  type '<xsl:value-of select="$instance/er:type"/>'</xsl:message> -->
   <xsl:variable name="etlDefn" 
      as="element()?"
      select="$erDataLib?getDefinitionOfInstance($instance)
             "/> 
   <xsl:if test="not($etlDefn)">
      <xsl:message terminate="yes">No entity_type_like found that matches element name of instance <xsl:copy-of select="$instance"/></xsl:message>
   </xsl:if>
   <!--
   <xsl:message> In instance of type '<xsl:value-of select="$etlDefn/er:name"/>'</xsl:message>
   <xsl:message> child of  instance of type '<xsl:value-of select="$etlDefn/../er:name"/>'</xsl:message>
-->
   <xsl:variable name="allValidChildNodes"
                 as="node()*">
      <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/(er:attribute|er:composition|er:reference)">              
         <xsl:choose>    
            <xsl:when test="self::er:attribute">
                  <xsl:sequence select="
                           $erDataLib?getAttribute($instance,self::er:attribute)
                         "/>
            </xsl:when>
            <xsl:when test="self::er:composition ">
               <xsl:sequence select="$erDataLib?getCompositionRelationship($instance,self::er:composition)"/>
            </xsl:when>
            <xsl:when test="self::er:reference">
            </xsl:when>
         </xsl:choose>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="redundantNodes" 
                 as="node()*"
                 select="$instance/(child::node()[not(self::comment())] 
                                    |
                                    attribute::*[not(name()='etname')]
                                    ) 
                         except $allValidChildNodes"/> 
   <xsl:element name="{$instance/name()}">

       <xsl:for-each select="$etlDefn/ancestor-or-self::er:entity_type/er:attribute[er:identifying]">
         <xsl:attribute name="{self::er:attribute/er:name}" select="$erDataLib?readAttribute($instance,self::er:attribute)"/>
       </xsl:for-each> 

      <!-- check uniqueness of identifying features -->
      <!-- <xsl:message>check uniqueness of identifying features</xsl:message> -->
      <xsl:variable name="identifyingFeatures" 
                    as="item()*" 
                    select="$erDataLib?readIdentifyingFeatureSequence($instance)"/>
      <!--<xsl:message>identifying features '<xsl:copy-of select="$identifyingFeatures"/>'</xsl:message>-->
      <xsl:if test="exists($identifyingFeatures)">
         <xsl:for-each select="$typeTaggedInstanceData/descendant-or-self::*
                                [@etname eq $instance/@etname]
                                [not(. is $instance)]
                                [deep-equal($erDataLib?readIdentifyingFeatureSequence(.),$identifyingFeatures)]
                             ">
            <xsl:element name="ERRORnonuniqueidentifer">
               <xsl:sequence select="$identifyingFeatures"/>  <!-- removed [self::attribute] 26/06/2013 -->
            </xsl:element>
         </xsl:for-each>
      </xsl:if>

      <!-- report redundant nodes -->
      <xsl:if test="count($redundantNodes) &gt; 0">
         <xsl:element name="ERR_redundacy">
            <xsl:attribute name="count" select="count($redundantNodes)"/>
            <xsl:for-each select="$redundantNodes">
               <xsl:choose>
                 <xsl:when test="self::text()">
                     <txt> <xsl:value-of select="."/></txt>
                 </xsl:when>
                  <xsl:when test="self::attribute()">
                     <xsl:element name="attribute">
                         <xsl:value-of select="name() || '=' || ."/>
                     </xsl:element>
                 </xsl:when>
                 <xsl:when test="self::element()">
                     <xsl:element name="element">
                        <xsl:value-of select="name()"/>
                     </xsl:element>
                 </xsl:when>
                  <xsl:when test="self::comment()">
                     <xsl:element name="comment">
                        <xsl:value-of select="."/>
                     </xsl:element>
                 </xsl:when>
                 <xsl:when test="self::namespace-node()">
                     <xsl:element name="namespace">
                        <xsl:value-of select="node-name()"/>
                     </xsl:element>
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:value-of select="'other:' || name()"/>
                 </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:element>
      </xsl:if>
      <!-- check attributes and references -->
      <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/(er:attribute|er:reference)"> 
         <xsl:choose>             
            <xsl:when test="self::er:attribute">
               <xsl:value-of select="
                           '@' 
                        || self::er:attribute/er:name
                        || ' '
                         "/>
               <xsl:variable name="attributeerror"
                                as="xs:string"
                                select="$attribute($instance,self::er:attribute)"/>
               <xsl:if test="$attributeerror">
                  <xsl:element name="attributeerror">
                     <xsl:attribute name="attrname" select="self::er:attribute/er:name"/>
                     <xsl:value-of select="$attributeerror"/>
                  </xsl:element>
               </xsl:if>
            </xsl:when>
            <xsl:when test="self::er:reference">
               <!--<xsl:message>Ref rel <xsl:value-of select="er:name"/> 
                     calculated from '<xsl:copy-of select="$instance/er:name"/>'' of '<xsl:copy-of select="$instance/../er:name"/>'</xsl:message>
               -->
               
               <xsl:value-of select="
                           '#' 
                        || self::er:reference/er:name
                        "/>
               <xsl:variable name="refcheckerror" 
                             as="xs:string?"
                             select="$reference($instance,self::er:reference)"/>
               <xsl:if test="$refcheckerror">
                  <xsl:element name="refcheckerror">
                     <xsl:attribute name="relname" select="self::er:reference/er:name"/>
                     <xsl:value-of select="$refcheckerror"/>
                  </xsl:element>
               </xsl:if>
            </xsl:when>
         </xsl:choose>
      </xsl:for-each>
      <!-- descend composition structure -->
      <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/er:composition"> 
         <!--<xsl:message>Composition '<xsl:value-of select="$etlDefn/er:name"/>'.'<xsl:value-of select="er:name"/>':'<xsl:value-of select="er:type"/>' </xsl:message>-->
            <xsl:for-each select="$erDataLib?readCompositionRelationship($instance,self::er:composition)">
               <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
                  <xsl:with-param name="typeTaggedInstanceData" select="$typeTaggedInstanceData"/>
                  <xsl:with-param name="instance" select="."/>
                  <xsl:with-param name="startInstance"    select="$startInstance"/>
                  <xsl:with-param name="attribute"        select="$attribute"/>
                  <xsl:with-param name="startComposition" select="$startComposition"/>
                  <xsl:with-param name="startMember"      select="$startMember"/>
                  <xsl:with-param name="endMember"        select="$endMember"/>
                  <xsl:with-param name="endComposition"   select="$endComposition"/>
                  <xsl:with-param name="reference"        select="$reference"/>
                  <xsl:with-param name="endInstance"      select="$endInstance"/>
               </xsl:call-template>
            </xsl:for-each>
      </xsl:for-each>
   </xsl:element>
   <xsl:value-of select="$endInstance($instance)"/>
</xsl:template>


</xsl:transform>
