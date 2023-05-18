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

<xsl:variable name="metaDataFilePathWrtERHome"
                  as="xs:string?"
                  select="child::element()/@metaDataFilePathWrtERHome"/>

<xsl:variable name="metaDataFilePathWrtThisInstanceDocument"
                  as="xs:string?"
                  select="child::element()/@metaDataFilePathWrtThisInstanceDocument"/>

<xsl:variable name="metaDataFile"
              as="document-node()"
              select="
        if (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        then document (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        else document( '../' 
                        || 
                        (child::element()/@metaDataFilePathWrtERHome) cast as xs:string)
                     "/>

<xsl:variable name="namespace_uri" 
              as="xs:string?"
              select="$metaDataFile/er:entity_model/er:xml/er:namespace_uri"/> 

<xsl:variable name="erMetaModelData" as="element(er:entity_model)">
    <xsl:message> In 'ER.library.module' 
                    root element is '<xsl:value-of select="child::element()/name()"/>'
    </xsl:message> 

   <xsl:variable name="state" 
                 as="element(er:entity_model)" 
                 select="$metaDataFile/er:entity_model"/>
   <xsl:variable name="enrichment" as="document-node()">
        <xsl:call-template name="recursive_xpath_enrichment">
          <xsl:with-param name="interim" select="$state"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="$enrichment/er:entity_model"/>
</xsl:variable>


<xsl:template name="register_derived_relationship_evalulation_functions">
    <!--TBD -->
</xsl:template>


<xsl:variable name="erMetaModelHelper" as="map(xs:string,function(*))">
    <xsl:variable name="model" as="element(er:entity_model)" select="$erMetaModelData"/>
    <xsl:sequence select="
let 
$relationshipReadId 
:= function ( $relationship as element(* (:er:reference | er:derived_relationship | er:dependency :) )
            ) as xs:string  
{
  $relationship/(parent::er:entity_type/er:name || '::' || er:name || '::' || er:type || 'read')
},

$relationshipPreconditionId
:= function ( $relationship as element(* (:er:reference | er:derived_relationship | er:dependency :) )
            ) as xs:string  
{
  $relationship/(parent::er:entity_type/er:name || '::' || er:name || '::' || er:type || 'precondition')
}

return map {
  'relationshipReadId'         : $relationshipReadId,
  'relationshipPreconditionId' : $relationshipPreconditionId
  }
"/>
</xsl:variable>


<xsl:variable name="erMetaModelLib" as="map(xs:string,function(*))">
    <xsl:variable name="model" as="element(er:entity_model)" select="$erMetaModelData"/>
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
},

$incomingCompositionRelationships
:= function($etDefn as element(er:entity_type))
           as element(er:composition)*
{
    $model//er:composition[$etDefn/ancestor-or-self::er:entity_type is $destinationTypeOfRelationship(.)]
},
$compositionRelationshipRepresentationElementName
:= function($compRelDefn as element(er:composition))
        as xs:string?
{
   if ($compRelDefn/er:xmlRepresentation/er:Anonymous)
   then ()
   else $compRelDefn/er:name
},
$compositionRelationshipSrcEntityTypes  
:= function($compRelDefn as element(er:composition))
        as element((:entity_type|absolute:))*
{
  $compRelDefn
          /..[self::er:entity_type|self::er:absolute]
          /(self::er:absolute | descendant-or-self::er:entity_type[not(er:entity_type)]) 
},
$entityTypeParentElementNames
:= function($etDefn as element(er:entity_type))
        as xs:string+
{
    $incomingCompositionRelationships($etDefn) /
        (
         if ($compositionRelationshipRepresentationElementName(.))
         then $compositionRelationshipRepresentationElementName(.)
         else $compositionRelationshipSrcEntityTypes(.)/er:elementName
        )
}

return map {
  'entityType' : $entityType,
  'attributeNamed' : $attributeNamed,
  'relationshipNamed' : $relationshipNamed,
  'destinationTypeOfRelationship' : $destinationTypeOfRelationship,
  'incomingCompositionRelationships' : $incomingCompositionRelationships,
  'entityTypeParentElementNames'     : $entityTypeParentElementNames
  }
"/>
</xsl:variable>

<xsl:variable name="erDataLib" as="map(xs:string,function(*))">
<!-- the following didn't work
    <xsl:evaluate xpath="unparsed-text('ER..model.xpath')">
      <xsl:with-param name="model" as="element(er:entity_model)" select="$erMetaModelData"/>
   </xsl:evaluate>
   Didn't work in Saxon 11.5. I strongly suspect a bug in Saxon. On one occasion trying variations on the theme I got a bale out from Java. Array violation. 
-->
<!-- so this instead -->
<xsl:variable name="model" as="element(er:entity_model)" select="$erMetaModelData"/>
<xsl:sequence select="
let 

$getDefinitionOfInstance
(: find  er:entity_type_like from its name :)
(: where er:entity_type_like ::= er:entity_type | er:absolute:)
:= function (
             $instance as element()
            )
            as element((:entity_type_like:))?
{  let $etDefs
       := $model//(self::er:absolute|self::er:entity_type)
                       [er:elementName eq $instance/name()]              (:  XXXX not er:name XXXX :) 
   return 
       if (count($etDefs) &lt;= 1)
       then $etDefs
       else   $etDefs[
                        some $elementName in $erMetaModelLib?entityTypeParentElementNames(.)
                                        satisfies $elementName eq  $instance/../name()
                     ]        
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
         then exists($etDefnOfInstance/ancestor-or-self::er:entity_type[er:name eq $name])   (:  XXXX elementName  NO PROBABLY NOT XXXX :) 
         else false()
},

$getAttribute   (: child element, attribute or text node representing an attribute :)
:= function ($instance as element(), 
             $attr as element(er:attribute)
            )  as node()?
{
      if ($attr/er:xmlRepresentation/er:Anonymous or (not($attr/er:xmlRepresentation) and $model/er:attributeDefault/er:Anonymous)) 
      then $instance/text()
      else if ($attr/er:xmlRepresentation/er:Attribute or (not($attr/er:xmlRepresentation) and $model/er:xml/er:attributeDefault/er:Attribute) ) 
      then   $instance/attribute::*[name()=$attr/er:name]         
      else (: in all other cases must be represented as an Element :)                
             $instance/child::element()[name()=$attr/er:name]  
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
           else () (:
                let $message := 'mandatory attribute '|| $attr/er:name ||' of instance of type '|| $instance/name() || ' is lacking a value'
                return fn:error(  
                          fn:QName('http://www.entitymodelling.org', 'er:missingvalue'),
                          $message,
                          ($instance,$attr) 
                        )
                :)

}  (: could probably rewrite the above using a higher order function :),

$readAttributeNamed
:= function ($instance as element(), 
             $name as xs:string
            )  as xs:anyAtomicType?
{
   let $attrDefn := $erMetaModelLib?attributeNamed($instance, $name)
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
  $erMetaModelLib?destinationTypeOfRelationship($r)/descendant-or-self::er:entity_type[not(child::er:entity_type)]
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
                  else $instance/child::*[name()=$compRelDefn/er:name]         (: er:elementName? XXXXXXXXXXXXXXXXXXX
                                                                                 XXXXXXXXXXX not in meta model 
                                                                                 but Anonymous used below -- so what is meta model?
                                                                                 Please investigate - check schema ermodel2rng.
                                                                                :)
return $container/*[$type-check-relationship-instance($compRelDefn,.)]
},

$readAnonymousCompositionRelationship  (: private for now at least :)
:=
let $all_overlapping_composition_relationships
:= function($compRelDefn as element(er:composition)) 
      as element(er:composition)+
{
$erMetaModelData//er:composition
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

$getCompositionRelationship  (: child element or elements representing a composition relationship :)
:=
function($instance as element(),
         $compRelDefn as element(er:composition)
         ) as element()*
{
if  ($compRelDefn/er:xmlRepresentation/er:Anonymous)
then $readAnonymousCompositionRelationship($instance, $compRelDefn)
else if (not($compRelDefn/er:name))
then $instance/*[$type-check-relationship-instance($compRelDefn,.)]
else $instance/child::*[name()=$compRelDefn/er:name]                              (: er:elementName? XXXXXXXXXXXXXXXXXXX 
                                                                                         XXXXXXXXXXXXXX see comment above :)
},

$getReferenceRelationshipPrecondition
:=
function((: $dataLib as map(*), :)
         $instance as element(),
         $refRelDefn as element(er:reference)
         ) as xs:boolean
{
  let 
      $refrelpreconfunid := $erMetaModelHelper?relationshipPreconditionId($refRelDefn),
      $preconFn := $reference_stroke_dependency_evaluation_lib($refrelpreconfunid)
  return $preconFn((: $dataLib, :) $instance)
},

$readReferenceOrDependencyRelationship
:=
function(
         $instance as element(),
         $relDefn as element()
         ) as element()*
{
  let 
      $relid := $erMetaModelHelper?relationshipReadId($relDefn),
      $readFn := $reference_stroke_dependency_evaluation_lib($relid)
                      treat as function(element()) as element()*
  return $readFn($instance)
},

$readRelationshipNamed
:=
function($instance as element(),
         $name as xs:string
         ) as element()*
{
let 
    $etDefnOfInstance := $getDefinitionOfInstance($instance),
    $relDefn := $erMetaModelLib?relationshipNamed($etDefnOfInstance, $name,())
    return 
    if ($relDefn/self::er:composition)
    then $readCompositionRelationship($instance,$relDefn)
    else $readReferenceOrDependencyRelationship ($instance, $relDefn)
}

return map {
  'getDefinitionOfInstance'              : $getDefinitionOfInstance,
  'instanceClassifiedByEntityType'       : $instanceClassifiedByEntityType,
  'instanceClassifiedByEntityTypeNamed'  : $instanceClassifiedByEntityTypeNamed,
  'getAttribute'                         : $getAttribute,   (:used to account for child nodes in instance validation :)
  'readAttribute'                        : $readAttribute,
  'readAttributeNamed'                   : $readAttributeNamed,
  'getCompositionRelationship'           : $getCompositionRelationship,   (: used to account for child nodes in instance validation:)
  'readCompositionRelationship'          : $readCompositionRelationship,
  'getReferenceRelationshipPrecondition' : $getReferenceRelationshipPrecondition,
  'readReferenceOrDependencyRelationship': $readReferenceOrDependencyRelationship,
  'readRelationshipNamed'                : $readRelationshipNamed
  }
"/>
</xsl:variable>  <!-- end of erDataLib -->


<!--
<xsl:variable name="erDataLibTwo" 
     as="map(xs:QName,function(*))"
  select="map{fn:QName('','readReferenceRelationshipNamed'): $erDataLib?readReferenceRelationshipNamed}"/>
  -->  

<xsl:variable name="reference_stroke_dependency_evaluation_lib" 
                as="map(xs:string, function((: map(*), :) element(*)) as item()?)">
    <xsl:message>About to register reference rel read functions</xsl:message>
    <xsl:call-template name="register_reference_stroke_dependency_relationship_evalulation_functions"/>
</xsl:variable>

<xsl:variable name="derived_relationship_evaluation_lib" 
              as="map(xs:string, function(element(*)) as element(*)?)">
    <xsl:call-template name="register_derived_relationship_evalulation_functions"/>
</xsl:variable>

<!-- work around saxon issue 6003 -->
<xsl:variable name="workaround" 
              select="'let $erDataLib := $erDataLib return '"
              />

<xsl:variable name="relationship_read_header_text"
              select="
               $workaround ||
                'function(
                $instance as element(*)) as element(*)?'"/>
<xsl:variable name="relationship_precondition_header_text"
              select="
              $workaround ||
              'function(
              $instance as element(*)) as xs:boolean'"/>

<xsl:template name="register_reference_stroke_dependency_relationship_evalulation_functions">
    <xsl:message>Registering ref rel and dependency  read functions</xsl:message>
    <xsl:variable name="mapset" as="map(xs:string, function(  element(*)) as item()?)*">  
        <xsl:for-each select="$erMetaModelData//*[self::er:reference | self::er:dependency] ">
            <xsl:if test="not(er:xpath_evaluate)">
                <xsl:message terminate="yes">Relationship '<xsl:copy-of select="."/>' has no xpath_evaluate </xsl:message>
            </xsl:if>
            <!--<xsl:message>Relationship '<xsl:copy-of select="."/>' </xsl:message>-->
            <xsl:variable name="eval_function_defn" as="xs:string"
                          select="$relationship_read_header_text || '{$instance/(' || ./er:xpath_evaluate || ')}' ">
            </xsl:variable>
            <xsl:variable name="read_function" 
                             as="function( element(*)) as element(*)?">
                      <xsl:evaluate  xpath="$eval_function_defn" >
                             <!--  with-params="$erDataLibTwo"/> -->
                           <xsl:with-param name="erDataLib" select="$erDataLib"/>
                       </xsl:evaluate>
            </xsl:variable>
            <xsl:sequence select="
                    map{
                         $erMetaModelHelper?relationshipReadId(.) : $read_function
                       }
                     "/>
            <xsl:if test="self::er:reference">
                <xsl:variable name="precondition_function_defn" as="xs:string"
                              select="$relationship_precondition_header_text || '{$instance/(' || ./er:xpath_local_key_defined || ')}' ">
                </xsl:variable>
                <xsl:message>precondition fn text <xsl:value-of select="$precondition_function_defn"/></xsl:message>
                <xsl:variable name="precondition_function" 
                                 as="function( (: map(*), :) element(*)) as xs:boolean">
                    <xsl:evaluate  xpath="$precondition_function_defn">
                               <xsl:with-param name="erDataLib" select="$erDataLib"/>
                    </xsl:evaluate>
                </xsl:variable>
                <xsl:sequence select="
                    map{
                         $erMetaModelHelper?relationshipPreconditionId(.) : $precondition_function
                       }
                     "/>
             </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="map:merge($mapset)"/>
</xsl:template>

</xsl:transform>