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

<xsl:variable name="er-entity_model" as="element(er:entity_model)">
   <xsl:message> In 'ER.library.module' loading schema  '<xsl:value-of select="root/schema/@filename"/>'</xsl:message>
   <xsl:copy-of select="document(root/schema/@filename)/er:entity_model"/>
</xsl:variable>

<xsl:variable name="erSchema" as="map(xs:string,function(*))">
    <xsl:variable name="model" as="element(er:entity_model)" select="$er-entity_model"/>
    <xsl:sequence select="
let 
$entityType 
:= function ($name as xs:string ) as element(er:entity_type)  
{
  $model//er:entity_type[er:name=$name] 
},

$attributeNamed 
:= function($etDefn as element(er:entity_type),
            $name as xs:string
           ) 
            as element((:er:Relationship:))
{
    $etDefn/ancestor-or-self::er:entity_type
            /child::er:attribute
            [er:name eq $name]
},

$relationshipNamed 
:= function($etDefn as element(er:entity_type),
            $name as xs:string?,
            $type as xs:string?
           ) 
            as element((:er:Relationship:))
{
    if (not ($name or $type))
    then fn:error(fn:QName('www.entitymodelling.org','relationshipNamedError'),
                  'function ''relationshipNamed'' called with neither name nor type parameter'
                  )
    else
        $etDefn/ancestor-or-self::er:entity_type
            /*[self::er:composition|self::er:reference|self::er:dependency|self::er:constructed_relationship]
            [if ($name) then er:name eq $name else true()][if ($type) then er:type eq $type else true()]
},

$destinationTypeOfRelationship     
(: navigate the model from an er:Relationship to an er:entity_type                         :)
(: ultimately this could be following the 'type' reference relationship of the meta-schema :)
:= function ($r as element() ) as element(er:entity_type)     (: as element( (:er:Relationship:) ) :)
{
  $entityType($r/er:type) 
}
return map {
  'entityType' : $entityType,
  'attributeNamed' : $attributeNamed,
  'relationshipNamed' : $relationshipNamed,
  'destinationTypeOfRelationship' : $destinationTypeOfRelationship
  }
"/>
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

$getDefinitionOfInstance
(: find  er:entity_type_like from its name :)
(: where er:entity_type_like ::= er:entity_type | er:absolute:)
:= function (
             $instance as element()
            )
            as element((:entity_type_like:))?
{
   $model//(self::er:absolute|self::er:entity_type)
                       [er:name eq $instance/name()]              (:  XXXX elementName XXXX :)           
},

$instanceClassifiedByEntityType
:= function($instance as element(),
            $etDefn as element(entity_type)
           )
           as xs:boolean
{ 
  let $etDefnOfInstance := $getDefinitionOfInstance($instance)
  return if ($etDefnOfInstance)
         then exists($etDefnOfInstance/ancestor-or-self::er:entity_type[. is $etDefn])
         else false()
},
           
$instanceClassifiedByEntityTypeNamed
:= function($instance as element(),
            $name as xs:string
           )
           as xs:boolean
{  
  let $etDefnOfInstance := $getDefinitionOfInstance($instance)
  return if ($etDefnOfInstance)
         then exists($etDefnOfInstance/ancestor-or-self::er:entity_type[er:name eq $name])   (:  XXXX elementName XXXX :) 
         else false()
},


$readAttribute
:= function ($instance as element(), 
             $attr as element(er:attribute)
            )  as xs:anyAtomicType?
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

$readAttributeNamed
:= function ($instance as element(), 
             $name as xs:string
            )  as xs:anyAtomicType?
{
   let $attrDefn := $erSchema?attributeNamed($instance, $name)
   return  $readAttribute($instance,$attrDefn)        
},

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
  $erSchema?destinationTypeOfRelationship($r)/descendant-or-self::er:entity_type[not(child::er:entity_type)]
},

$type-check-relationship-instance
:= function( $r as element((:er:Relationship:)), $instance as element() ) as xs:boolean
{  let $instance_etlDefn := $getDefinitionOfInstance($instance),
       $relDestination_erlDefn := $destination-type($r)
   return some $et in $relDestination_erlDefn/descendant-or-self::er:entity_type 
              satisfies $et is $instance_etlDefn
},

$type-check-relationshipset-instance
:= function( $rset as element((:er:Relationship:))+, $instance as element() ) as xs:boolean
{  some $r in $rset 
   satisfies $type-check-relationship-instance($r,$instance)
},    

$readNonAnonymousCompositionRelationship  (: private for now at least :)
:= function($instance as element(),
         $compRelDefn as element(er:composition)
         ) as element()*
{
let $container := if (not($compRelDefn/er:name)) 
                  then $instance 
                  else $instance/child::*[name()=$compRelDefn/er:name]
return $container/*[$type-check-relationship-instance($compRelDefn,.)]
},

$readAnonymousCompositionRelationship  (: private for now at least :)
:=
let $all_overlapping_composition_relationships
:= function($compRelDefn as element(er:composition)) 
      as element(er:composition)+
{
$er-entity_model//er:composition
         [ er:xmlRepresentation/er:Anonymous/@overlap_group_id
           eq
           $compRelDefn/er:xmlRepresentation/er:Anonymous/@overlap_group_id
         ]
},
$position_within_overlap_group
:= function($compRelDefn as element(er:composition))
         as xs:positiveInteger
{
         (count ($all_overlapping_composition_relationships($compRelDefn) 
           [ . &lt;&lt; $compRelDefn]
         ) + 1)
        cast as xs:positiveInteger
}
return 
function($instance as element(),
         $compRelDefn as element(er:composition)
         ) as element()*
{
$instance/*[count(preceding-sibling ::*
                    [$type-check-relationshipset-instance(
                             $all_overlapping_composition_relationships($compRelDefn),.
                                                               )
                    ]
                 )
                 = ($position_within_overlap_group($compRelDefn) - 1)
           ] 
           [$type-check-relationship-instance($compRelDefn,.)]    
},

$readCompositionRelationship
:=
function($instance as element(),
         $compRelDefn as element(er:composition)
         ) as element()*
{
if ($compRelDefn/er:xmlRepresentation/er:Anonymous)
then $readAnonymousCompositionRelationship($instance, $compRelDefn)
else $readNonAnonymousCompositionRelationship($instance, $compRelDefn)
},

$readCompositionRelationshipNamed
:=
function($instance as element(),
         $name as xs:string
         ) as element()*
{
let 
    $etDefnOfInstance := $getDefinitionOfInstance($instance),
    $compRelDefn := $erSchema?relationshipNamed($etDefnOfInstance, $name,())
return $readCompositionRelationship($instance,$compRelDefn)
}

return map {
  'getDefinitionOfInstance'             : $getDefinitionOfInstance,
  'instanceClassifiedByEntityType'      : $instanceClassifiedByEntityType,
  'instanceClassifiedByEntityTypeNamed' : $instanceClassifiedByEntityTypeNamed,
  'readAttribute'                       : $readAttribute,
  'readAttributeNamed'                  : $readAttributeNamed,
  'readCompositionRelationship'         : $readCompositionRelationship,
  'readCompositionRelationshipNamed'    : $readCompositionRelationshipNamed
  }
"/>

</xsl:variable>

</xsl:transform>