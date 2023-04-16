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
<!--<xsl:output method="xml" indent="yes"/>-->

<xsl:variable name="er-entity_model" as="element(er:entity_model)">
   <xsl:message> In 'ERSchema' loading schema  '<xsl:value-of select="root/schema/@filename"/>'</xsl:message>
   <xsl:copy-of select="document(root/schema/@filename)/er:entity_model"/>
</xsl:variable>

<xsl:variable name="erlib" as="map(xs:string,function(*))">
<!-- the following didn't work
    <xsl:evaluate xpath="unparsed-text('ER..model.xpath')">
      <xsl:with-param name="model" as="element(er:entity_model)" select="$er-entity_model"/>
   </xsl:evaluate>
   Didn't work in Saxon 11.5. I strongly suspect a bug in Saxon. On one occasion trying variations on the theme I got a bale out from Java. Array violation. 
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
:= function ($instance as element(), $attr as element(er:attribute))  as xs:anyAtomicType?
{
   let $value :=
      if ($attr/er:xmlRepresentation/er:Anonymous or (not($attr/er:xmlRepresentation) and $model/er:attributeDefault/er:Anonymous)) 
      then $instance/text()
      else if ($attr/er:xmlRepresentation/er:Attribute or (not($attr/er:xmlRepresentation) and $model/er:xml/er:attributeDefault/er:Attribute) ) 
      then   $instance/attribute::*[name()=$attr/er:name]         
      else (: in all other cases must be represented as an Element :)                
             $instance/child::*[name()=$attr/er:name]  
   return  if ($value or $attr/er:optional ) 
           then $value
           else let $message := 'mandatory attribute '|| $attr/er:name ||' of instance of type '|| $instance/name() || ' is lacking a value'
                return fn:error(  
                          fn:QName('http://www.entitymodelling.org', 'er:missingvalue'),
                          $message,
                          ($instance,$attr) 
                        )        
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
},

$type-check-relationshipset-instance
:= function( $rset as element((:er:Relationship:))+, $instance as element() ) as xs:boolean
{  some $r in $rset 
   satisfies $type-check-relationship-instance($r,$instance)
}    

return map {
  'entity_type_like-from-instance'  : $entity_type_like-from-instance,
  'value-of-attribute'              : $value-of-attribute,
  'destination-type'                : $destination-type,
  'concrete-destination-type-sequence' : $concrete-destination-type-sequence,
  'type-check-relationship-instance' : $type-check-relationship-instance ,
  'type-check-relationshipset-instance' : $type-check-relationshipset-instance 
  }
"/>
</xsl:variable>

</xsl:transform>