<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:er="http://www.entitymodelling.org/ERmodel"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="../ER.library.module.xslt"/>

<xsl:variable name="xpathPrettyPrint"
              as="map(xs:string,function(*))"
              select="let
   $startInstance    := function($instance as element())
   {
     '[' || $instance/name()

   },
   $attributeValue   := function($attr as element(er:attribute),
                                 $value as xs:anyAtomicType)
   {
      $value cast as xs:string 
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
   $endInstance      := function($instance as element())
   {
     ']'
   }
   return map{
   'startInstance'   : $startInstance,
   'attributeValue'  : $attributeValue,
   'startComposition': $startComposition,
   'startMember'     : $startMember,
   'endMember'       : $endMember,
   'endComposition'  : $endComposition,
   'endInstance'     : $endInstance
   }
"/> <!-- end of xpathPrettyPrint -->




<!-- generic walk with callback functions passed as parameters -->

<xsl:template match="/">
   <xsl:message> Schema is <xsl:value-of select="$erMetaModel/er:absolute/er:name"/> </xsl:message>
   <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
      <xsl:with-param name="instance" select="root/instance/xpath-31/Expr"/>
      <xsl:with-param name="startInstance"    select="$xpathPrettyPrint?startInstance"/>
      <xsl:with-param name="attributeValue"   select="$xpathPrettyPrint?attributeValue"/>
      <xsl:with-param name="startComposition" select="$xpathPrettyPrint?startComposition"/>
      <xsl:with-param name="startMember"      select="$xpathPrettyPrint?startMember"/>
      <xsl:with-param name="endMember"        select="$xpathPrettyPrint?endMember"/>
      <xsl:with-param name="endComposition"   select="$xpathPrettyPrint?endComposition"/>
      <xsl:with-param name="endInstance"      select="$xpathPrettyPrint?endInstance"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="walk_an_instance_subtree__guided_by_schema">
   <xsl:param name="instance" as="element()"/>
   <xsl:param name="startInstance" as="function(element()) as xs:string?"/>
   <xsl:param name="attributeValue" as="function(element(er:attribute),xs:anyAtomicType) as xs:string?"/>
   <xsl:param name="startComposition" as="function(element(er:composition)) as xs:string?"/>
   <xsl:param name="startMember" as="function(element(er:composition),xs:positiveInteger) as xs:string?"/>
   <xsl:param name="endMember"   as="function(element(er:composition),xs:positiveInteger) as xs:string?"/>
   <xsl:param name="endComposition" as="function(element(er:composition)) as xs:string?"/>
   <xsl:param name="endInstance" as="function(element()) as xs:string?"/>
   <xsl:variable name="etlDefn" 
      as="element()?"
      select="$erDataLib?entity_type_like-from-instance($instance)
             "/> 
   <xsl:if test="not($etlDefn)">
      <xsl:message terminate="yes">No entity_type_like found that matches element name of instance <xsl:copy-of select="$instance"/></xsl:message>
   </xsl:if>
   <xsl:message> In instance of type <xsl:value-of select="$etlDefn/er:name"/></xsl:message>
   <xsl:value-of select="$startInstance($instance)"/>
   <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/(er:attribute|er:composition)">                                                           
      <xsl:choose>             
         <xsl:when test="self::er:attribute">
            <xsl:variable name="valueofattribute" 
                           as="xs:anyAtomicType?"
                           select="$erDataLib?value-of-attribute($instance,.)"/>
            <xsl:message>Value of attr '<xsl:value-of select="er:name"/>' = '<xsl:value-of select="$valueofattribute"/>'</xsl:message>
            <xsl:if test="not(self::er:attribute/er:optional) and not($valueofattribute)">
               <xsl:message terminate="yes">*********** Mandatory attribute has no value</xsl:message>
            </xsl:if> 
            <xsl:if test="$valueofattribute">
               <xsl:value-of select="$attributeValue(self::er:attribute, $valueofattribute)"/>
            </xsl:if> 
         </xsl:when>
         <xsl:when test="self::er:composition ">
            <xsl:message>Composition '<xsl:value-of select="$etlDefn/er:name"/>'.'<xsl:value-of select="er:name"/>':'<xsl:value-of select="er:type"/>' </xsl:message>
            <xsl:for-each select="$erDataLib?readCompositionRelationship($instance,self::er:composition)">
               <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
                  <xsl:with-param name="instance" select="."/>
                  <xsl:with-param name="startInstance"    select="$startInstance"/>
                  <xsl:with-param name="attributeValue"   select="$attributeValue"/>
                  <xsl:with-param name="startComposition" select="$startComposition"/>
                  <xsl:with-param name="startMember"      select="$startMember"/>
                  <xsl:with-param name="endMember"        select="$endMember"/>
                  <xsl:with-param name="endComposition"   select="$endComposition"/>
                  <xsl:with-param name="endInstance"      select="$endInstance"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:for-each>
   <xsl:value-of select="$endInstance($instance)"/>
</xsl:template>
-->

</xsl:transform>
