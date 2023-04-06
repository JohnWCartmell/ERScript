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

<xsl:variable name="er-entity_model" as="element(er:entity_model)">
   <xsl:message> In 'ERSchema' loading schema  '<xsl:value-of select="root/schema/@filename"/>'</xsl:message>
   <xsl:copy-of select="document(root/schema/@filename)/er:entity_model"/>
</xsl:variable>

<xsl:variable name="erlib" as="map(xs:string,function(*))">
<!-- the following didn't work
    <xsl:evaluate xpath="unparsed-text('ER..model.xpath')">
      <xsl:with-param name="model" as="element(er:entity_model)" select="$er-entity_model"/>
   </xsl:evaluate>
-->
<!-- so this instead -->
<xsl:variable name="model" as="element(er:entity_model)" select="$er-entity_model"/>
<xsl:sequence select="
let 

$entity_type_like-from-instance
(: find  er:entity_type_like from its name :)
(: where er:entity_type_like ::= er:entity_type | er:absolute)
:= function ($name as xs:string) as element((:entity_type_like:))?
{
   $model//(self::er:absolute|self::er:entity_type)
                       [@name()=$instance/name()]    (:  are should I make this $instance or $name XXXXXXXXXXXXXXXXXXXXXXXXXXXXX :)
},

$value-of-attribute
:= function ($instance as element(), $attr as element(er:attribute))  as element(er:attribute)
{
   if ($attr/xmlRepresentation/Anonymous or (not($attr/xmlRepresentation) and $model/attributeDefaults/Anonymous)) 
   then $instance/text()
   if ($attr/xmlRepresentation/Attribute or (not($attr/xmlRepresentation) and $model/attributeDefaults/Attribute) ) 
   then   $instance/attribute::*[name()=$attr/name]         
   else (: in all othwer cases must be represented as an Element :)                
          $instance/child::*[name()=$attr/name]           
}  (: could probably rewrite the above using a higher order function :)

$destination-type     
(: navigate the model from an er:Relationship to an er:entity_type                         :)
(: ultimately this could be following the 'type' reference relationship of the meta-schema :)
:= function ($r ) as element(er:entity_type)     (: as element( (:er:Relationship:) ) :)
{
  $model//er:entity_type[@name=$r/@type] 
},

$concrete-destination-type-sequence 
(: navigate the model from an er:Relationship to a sequence of all                         :)
(:                       er:entity_type which are valid types of destination entitites  :)
:= function( $r as element((:er:Relationship:))) as element(er:entity_type)*
{ 
  $destination-type($r)/descendant-or-self::er:entity_type[not(child::er:entity_type)]
}

return map {
  'entity_type_like-from-instance'  : $entity_type_like-from-instance,
  'value-of-attribute'              : $value-of-attribute,
  'destination-type'                : $destination-type,
  'concrete-destination-type-sequence' : $concrete-destination-type-sequence
  }
"/>
</xsl:variable>

<xsl:template match="/">
   <xsl:message> Schema is <xsl:value-of select="$er-entity_model/er:absolute/er:name"/> </xsl:message>
    <xsl:variable name="ifdef" as="element(er:entity_type)" select="$er-entity_model//er:entity_type[@name = 'IfExpr']"/> 
    <xsl:variable name="condef" as="element(er:composition)" select="$ifdef/er:composition[@name='condition']"/>
    <xsl:variable name="expr" as="element(er:entity_type)" select="$er-entity_model//er:entity_type[@name eq $condef/@type]"/> 
    <xsl:message>condef type is '<xsl:value-of select="$condef/@type"/>'</xsl:message>
    <xsl:message> Now list off candidate entity types for condition<xsl:copy-of select="$erlib?concrete-destination-type-sequence($condef)"/></xsl:message>
   <xsl:variable name="thendef" as="element(er:composition)" select="$ifdef/er:composition[@name='then']"/>
   <xsl:message> Now list off candidate entity type names for then
   <xsl:value-of select="$erlib?concrete-destination-type-sequence($thendef)/@name"/></xsl:message>
</xsl:template>

<!-- ?? make the following generic with callback functions passed as parameters ?? -->
<xsl:template name="walk_an_instance_subtree__guided_by_schema">
   <xsl:param name="model" as="element(er:entity_model)"/>
   <xsl:param name="instance" as="element()"/>
   <xsl:param name="errorList" as="array(xs:string)"/>
   <xsl:variable name="etlDefn" 
      as="element()?"
      select="$erlib?entity_type_like-from-instance($instance)
             "/> <!-- use the name to remember that what we have is entity_type_like and therefore includes the absolute -->
   <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/(er:attribute|er:composition)"/>
                                                               <!-- meta derived  rel 'allContent', say  -->
      <xsl:choose>               <!-- ?? instead use apply-templates ?? -->
         <xsl:when test="self::er:attribute">
            <xsl:variable name="valueofattribute" 
                           as="xs:untypedAtomicType?"
                           select="$erlib?value-of-attribute($instance,.)"/>
            <xsl:message>Value of attr '<xsl:value-of select="@name"/>' is '<xsl:value-of select="$valueofAttribute"/>'</xsl:message>  
         </xsl:when>
         <xsl:when test="self::er:composition">
            <xsl:variable name="container" 
                          as="element(er:*)"
                          select="if (xmlRepresentation = 'anonymous' then . else instance/child::*[name()=@name]" />
            <xsl:for-each select="$container/*[name() is in destinationTypeList(.)]">
               <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
                  <xsl:with-param name="model" select="$model"/>
                  <xsl:with-param name="instance" select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:for-each>
</xsl:template>



<!--
<xsl:template match="instance" mode="reconstruction">
   <xsl:message>instance <xsl:value-of select="@name"/> </xsl:message>

   <xsl:variable name = "instance" select="*"/>
   <xsl:if test="$instance/name()!=$er-entity_model/er:absolute/er:name">
      <xsl:message terminate="yes"> root of instance doesn't match name of entity model </xsl:message>
   </xsl:if>

   <xsl:apply-templates  select="*" mode="reconstruction"/>
</xsl:template>


<xsl:template match="/|node()|@*" mode="reconstruction">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="reconstruction"/>
   </xsl:copy>
</xsl:template>

-->

<!--
<xsl:variable name="ERSchemaMachineAttributes" 
   \
              as="map(*)" 
              select="
let $entity_type_attribute_map_constructor  := 
    let $attribute_map_constructor  := function($attr as element(er:attribute)) 
                                                     as function(element()) as xs:untypedAtomic
                                       { 
                                         function($e as element()) as xs:untypedAtomic
                                         {$e/xpath-evaluate($attr/xpath_evaluate)}
                                       }

      return function ($et as element(er:entity_type)) as map(*)
         {
           map:merge($et/child::attribute => $attribute_map_constructor())
         }
  return map:merge($ERSchema//entity_type => $entity_type_attribute_constructor())
              "/>

           -->

</xsl:transform>
