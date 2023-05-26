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


<!--ER.metaModelLib.module.xslt -->

<xsl:variable name="erMetaModelData" as="element(er:entity_model)">
    <xsl:message> In 'ER.library.module' 
                    root element is '<xsl:value-of select="child::element()/name()"/>'
    </xsl:message> 

    <xsl:variable name="metaDataFile"
              as="document-node()"
              select="
        if (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        then document (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        else document( '../' 
                        || 
                        (child::element()/@metaDataFilePathWrtERHome) cast as xs:string)
                     "/>

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
:= function ($r as element((:er:Relationship:)) ) as element(er:entity_type)     
{
  $entityType($r/er:type) 
},


$incomingCompositionRelationships
:= function($etDefn as element(er:entity_type))
           as element(er:composition)*
{
    $model//er:composition[some $ancestorEntityType in $etDefn/ancestor-or-self::er:entity_type
                                                     satisfies $ancestorEntityType is $destinationTypeOfRelationship(.)]
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
},
$entityTypeParentEntityTypeElementNamesThroughNamedCompositions
:= function($etDefn as element(er:entity_type))
        as xs:string+
{
    $incomingCompositionRelationships($etDefn) /
        (
         if ($compositionRelationshipRepresentationElementName(.))
         then ../(self::er:absolute | self::er:entity_type/descendant-or-self::er:entity_type[not(er:entity_type)])/er:elementName
         else ()
        )
}

return map {
  'entityType' : $entityType,
  'attributeNamed' : $attributeNamed,
  'relationshipNamed' : $relationshipNamed,
  'destinationTypeOfRelationship' : $destinationTypeOfRelationship,
  'compositionRelationshipRepresentationElementName' : $compositionRelationshipRepresentationElementName,
  'incomingCompositionRelationships' : $incomingCompositionRelationships,
  'entityTypeParentElementNames'     : $entityTypeParentElementNames,
  'entityTypeParentEntityTypeElementNamesThroughNamedCompositions' : $entityTypeParentEntityTypeElementNamesThroughNamedCompositions
  }
"/>
</xsl:variable>

<!--End of ER.metaModelLib.module.xslt -->

</xsl:transform>