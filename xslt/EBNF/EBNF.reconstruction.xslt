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
   Didn't work in Saxon 11.5. I strongly suspect a bug. On one occasion trying variations on the theme I got a bale out from Java. Array violation. 
-->
<!-- so this instead -->
<xsl:variable name="model" as="element(er:entity_model)" select="$er-entity_model"/>
<xsl:sequence select="
let 

$entity_type_like-from-instance
(: find  er:entity_type_like from its name :)
(: where er:entity_type_like ::= er:entity_type | er:absolute:)
:= function ($instance as element()) as element((:entity_type_like:))?
{
   $model//(self::er:absolute|self::er:entity_type)
                       [er:elementName=$instance/name()]              
},

$value-of-attribute
:= function ($instance as element(), $attr as element(er:attribute))  as xs:anyAtomicType
{
   if ($attr/er:xmlRepresentation/er:Anonymous or (not($attr/er:xmlRepresentation) and $model/er:attributeDefault/er:Anonymous)) 
   then $instance/text()
   else if ($attr/er:xmlRepresentation/er:Attribute or (not($attr/er:xmlRepresentation) and $model/er:xml/er:attributeDefault/er:Attribute) ) 
   then   $instance/attribute::*[name()=$attr/er:name]         
   else (: in all other cases must be represented as an Element :)                
          $instance/child::*[name()=$attr/er:name]           
}  (: could probably rewrite the above using a higher order function :),

$destination-type     
(: navigate the model from an er:Relationship to an er:entity_type                         :)
(: ultimately this could be following the 'type' reference relationship of the meta-schema :)
:= function ($r ) as element(er:entity_type)     (: as element( (:er:Relationship:) ) :)
{
  $model//er:entity_type[er:name=$r/er:type] 
},

$concrete-destination-type-sequence 
(: navigate the model from an er:Relationship to a sequence of all                         :)
(:                       er:entity_type which are valid types of destination entitites  :)
:= function( $r as element((:er:Relationship:))) as element(er:entity_type)*
{ 
  $destination-type($r)/descendant-or-self::er:entity_type[not(child::er:entity_type)]
},

$type-check-relationship-instance
:= function( $r as element((:er:Relationship:)), $instance as element() ) as xs:boolean
{  let $instance_etlDefn := $entity_type_like-from-instance($instance),
       $relDestination_erlDefn := $destination-type($r)
   return some $et in $relDestination_erlDefn/descendant-or-self::er:entity_type 
              satisfies $et is $instance_etlDefn
}  

return map {
  'entity_type_like-from-instance'  : $entity_type_like-from-instance,
  'value-of-attribute'              : $value-of-attribute,
  'destination-type'                : $destination-type,
  'concrete-destination-type-sequence' : $concrete-destination-type-sequence,
  'type-check-relationship-instance' : $type-check-relationship-instance 
  }
"/>
</xsl:variable>

<xsl:template match="/">
   <xsl:message> Schema is <xsl:value-of select="$er-entity_model/er:absolute/er:name"/> </xsl:message>
   <!--
    <xsl:variable name="ifdef" as="element(er:entity_type)" select="$er-entity_model//er:entity_type[er:name = 'IfExpr']"/> 
    <xsl:variable name="condef" as="element(er:composition)" select="$ifdef/er:composition[er:name='condition']"/>
    <xsl:variable name="expr" as="element(er:entity_type)" select="$er-entity_model//er:entity_type[er:name eq $condef/er:type]"/> 
    <xsl:message>condef type is '<xsl:value-of select="$condef/er:type"/>'</xsl:message>
    <xsl:message> Now list off candidate entity types for condition<xsl:copy-of select="$erlib?concrete-destination-type-sequence($condef)"/></xsl:message>
   <xsl:variable name="thendef" as="element(er:composition)" select="$ifdef/er:composition[er:name='then']"/>
   <xsl:message>And show I can reach the thendef  <xsl:copy-of select="$thendef"/></xsl:message>
   -->
   <xsl:call-template name="walk_an_instance_subtree__guided_by_schema">
      <xsl:with-param name="model" select="$er-entity_model"/>
      <xsl:with-param name="instance" select="root/instance/xpath-31/Expr"/>
   </xsl:call-template>

</xsl:template>

<!-- ?? make the following generic with callback functions passed as parameters ?? -->
<xsl:template name="walk_an_instance_subtree__guided_by_schema">
   <xsl:param name="model" as="element(er:entity_model)"/>
   <xsl:param name="instance" as="element()"/>
  <!-- <xsl:param name="errorList" as="array(xs:string)"/>-->
   <xsl:variable name="etlDefn" 
      as="element()?"
      select="$erlib?entity_type_like-from-instance($instance)
             "/> <!-- use the name to remember that what we have is entity_type_like and therefore includes the absolute -->

   <xsl:if test="not($etlDefn)">
      <xsl:message terminate="yes">No entity_type_like found that matches element name of instance <xsl:copy-of select="$instance"/></xsl:message>
   </xsl:if>
   <xsl:message> In instance of type <xsl:value-of select="$etlDefn/er:name"/></xsl:message>
   <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/(er:attribute|er:composition)">
                                                               <!-- meta derived  rel 'allContent', say  -->
      <xsl:choose>               <!-- ?? instead use apply-templates ?? -->
         <xsl:when test="self::er:attribute">
            <xsl:message>In attribute  name'<xsl:value-of select="er:name"/>'</xsl:message>
            <xsl:message>Instance '<xsl:copy-of select="$instance"/>'</xsl:message>

            <xsl:variable name="valueofattribute" 
                           as="xs:anyAtomicType?"
                           select="$erlib?value-of-attribute($instance,.)"/>
            <xsl:message>Value of attr '<xsl:value-of select="name"/>' is '<xsl:value-of select="$valueofattribute"/>'</xsl:message>  
         </xsl:when>
         <xsl:when test="self::er:composition">
            <xsl:message>Composition hosted at '<xsl:value-of select="$etlDefn/er:name"/>' named '<xsl:value-of select="er:name"/>' destination type  '<xsl:value-of select="er:type"/>' </xsl:message>
            <xsl:variable name="container" 
                          as="element()"
                          select="if (er:xmlRepresentation/er:Anonymous or not(er:name)) 
                                 then $instance 
                                 else $instance/child::*[name()=current()/er:name]" >
                                 <!-- encapsulate this in erlib ... ?name change from 'container' to 'site' ??-->
            </xsl:variable>
            <xsl:message> container <xsl:copy-of select="$container"/></xsl:message>
            <xsl:for-each select="$container/*[$erlib?type-check-relationship-instance(current(),.)]">
               <!-- There is more to it than this if I want support positional which i do (binary operations)-->
               <xsl:message>In for each</xsl:message>
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
