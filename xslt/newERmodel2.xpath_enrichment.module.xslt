

<!--
*************************************
ERmodel2.xpath_enrichment.module.xslt
*************************************

DESCRIPTION
  This xslt enriches a physical ER model by the attributes described below.
  It is implemented as a recursive enrichment.

      absolute =>
         xpath_qualified_type_classifier : string

      entity_type =>
         xpath_type_qualifier :string,  # for a concrete type this is the 
                                        # element name
                                        # for an abstract type it is
                                        # the pattern A|B|C ...
                                        # where A, B, C are the 
                                        # concrete (leaf) descendant types
         xpath_qualified_element_name : string,
                                        # this is only defined for concrete types.
                                        # it is the same as elementName if
                                        # elementName is unique
                                        # it is a path of elementNames from
                                        # root of the document otherwise
                                        # Implication is that entity type names
                                        # must be unique in presence of
                                        # recursion
         xpath_qualified_type_classifier : string,
                                        # similar to xpath_type_classifier
                                        # but with A'|B'|C'..
                                        # where A',B'C' are qualified 
                                        # elementNames, see 
                                        # xpath_qualified_element_name
                                        # to make element name unique
         xpath_parent_entity : string ,
         xpath_primary_key : string,
         xpath_type_check : string




      composition/pullback =>
         xpath_iterate: string, # xpath expression relative to the context
                                # of the parent entity of the composition. 
                                # Used in validating or elaborating the 
                                # pullback. When evaluated for a host
                                # entity navigates the composition by
                                # going around the other three sides of
                                # the square. If any candidate entity not 
                                # represented in the pullback returns it
                                # instead of the pullback.
         xpath_resolve_candidate : string
                                # an xpath (sub)expression relative to the context
                                # of a pullback candidate and a current node
                                # which is the pullback host entity.
                                # used only in generation of xpath_iterate
         pbe_passno : nonNegativeNumber
                                # pullback elaboration pass no
                                # if non-zero then the pullback pass no during 
                                # which this pullback will be elaborated
                                
      
      reference =>
        xpath_is_defined : string,
        xpath_type_check : string,
        xpath_local_key :  string, # that part of the foreign key that is 
                                   # constructed from attributes local to the 
                                   # host entity  plus the <key> constraint
        xpath_foreign_key : string,
        xpath_evaluate : string,
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      dependency =>
        xpath_evaluate : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      theabsolute =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      join =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      identity =>
        xpath_evaluate : string
        xpath_evaluate_inverse : string
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
      
      component =>
        xpath_evaluate : string,
        xpath_evaluate_inverse : string
        xpath_delta_key : optional string  
                         # This is a temporary used only in the
                         # generation of 
                         # reference/projection/xpath_delta_key
                         # only defined for components of risers.
                         # It is empty except in the case
                         # of components that navigate an  identifying
                         # dependency in  which case it is an xpath to 
                         # be evaluated within the context of the src 
                         # entity of  the component. For this entity it
                         # evaluates to that part of the  primary key 
                         # of the src required to identify with respect 
                         # to the destination of the riser that is 
                         # contributed by navigating the dependency.  
        pbe_passno : nonNegativeNumber
                                # used as an intermediate in the
                                # calculation of pbe_passno for a pullback
                                
FINALLY 29/11/2022 MOVED FRPM initial_enrichment

join | component => identification_status : ('Identifying', 'NotIdentifying')

-->

<!-- entity type `projection' removed in change of 8-Jul-2023 -->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        exclude-result-prefixes="xs era"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


<xsl:function name="era:brace">
  <xsl:param name="elementName" as="xs:string"/>
  <xsl:param name="namespace_uri" as="xs:string?"/>
 
  <xsl:value-of select="
    if ($namespace_uri)
    then
          'Q{'
        || $namespace_uri
        ||  '}'
        ||  $elementName
    else $elementName
    "/>
</xsl:function>

<xsl:function name="era:braceIfDefined">
  <xsl:param name="elementName" as="xs:string?"/>
  <xsl:param name="namespace_uri" as="xs:string?"/>
  <xsl:value-of select="
      if ($elementName)
      then era:brace($elementName,$namespace_uri)
      else () 

    "/>
</xsl:function>


<xsl:key name="entity_type" 
       match="entity_type|group" 
       use="name"/>
<xsl:key name="inverse_implementationOf" 
       match="implementationOf"
       use="era:packArray((../../name,rel))"/>

<xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/era:packArray((name,current()/name))" />
  <xsl:key name="EntityTypes" 
         match="absolute|entity_type|group" 
         use="if(string-length(name)=0 and self::absolute) then 'EMPTYVALUEREPLACED' else name"/>
  <!--CR19229 added absolute -->
  <xsl:key name="IncomingCompositionRelationships" 
         match="composition" 
         use="type"/>
  <!-- CR-18032 -->
  <xsl:key name="AllIncomingCompositionRelationships" 
         match="composition" 
         use="key('EntityTypes',type)/descendant-or-self::entity_type/name"/>    
  <!-- was "descendant-or-self::entity_type/type" until 23-Aug-2016 and therefore primary key for "reference" in meta-model wrong-->
  <!-- end CR-18032 -->
  <xsl:key name="AllMasterEntityTypes" 
         match="entity_type" 
         use="composition/key('EntityTypes',type)/descendant-or-self::entity_type/name"/>
  <xsl:key name="CompRelsByDestTypeAndInverseName" 
         match="composition" 
         use="era:packArray((type,inverse))"/>
  <xsl:key name="ConstructedRelationshipsByQualifiedName" 
         match="constructed_relationship" 
         use="era:packArray((../name,name))"/>
  <xsl:key name="CoreRelationshipsByQualifiedName" 
         match="reference|composition|dependency" 
         use="era:packArray((../name,name))"/>
  <xsl:key name="RelationshipBySrcTypeAndName" 
         match="reference|composition|dependency|constructed_relationship" 
         use="era:packArray((../name,name))"/>
  <!-- CR-18032 -->
  <xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/era:packArray((name,current()/name))" />
  <!-- end CR-18032 -->
  <xsl:key name="whereImplemented" 
         match="implementationOf"
         use="era:packArray((../../name,rel))"/>

<!-- MOVED FROM initial_enrichment -->
       <!-- Two templates for
             composite => identification_status
    This is pretty ugly because we have remodelled  the idea of an
    optional identifying flag just because we wanted
    to implement using recurive incremental enrichment.
-->
<xsl:template match="join
                     [not(identification_status)]
                     [every $component in component satisfies $component/identification_status]" 
              priority="19"
              mode="recursive_xpath_enrichment">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="recursive_xpath_enrichment"/>
      <identification_status>
            <xsl:value-of select="if (every $component in component 
                                      satisfies ($component/identification_status = 'Identifying')
                                     )
                                  then 'Identifying'
                                  else 'NotIdentifying'
                                 "/>
      </identification_status>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(identification_status)]
                     [src]
                     " 
                     priority="23"
                     mode="recursive_xpath_enrichment">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="recursive_xpath_enrichment"/>
      <identification_status>   
         <xsl:value-of select="if(key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))
                                       /identifying)
                                    then 'Identifying'
                                    else 'NotIdentifying'
                                   "/>  
      </identification_status>
   </xsl:copy>
</xsl:template>


<xsl:template name="recursive_xpath_enrichment">
 <!-- <xsl:param name="mode" />-->
  <xsl:param name="interim"/>
  <xsl:variable name ="next">
    <xsl:for-each select="$interim">
      <xsl:copy>
        <xsl:apply-templates mode="recursive_xpath_enrichment"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="result">
    <xsl:choose>
      <xsl:when test="not(deep-equal($interim,$next))">
        <xsl:message> changed in xpath enrichment</xsl:message>
        <xsl:call-template name="recursive_xpath_enrichment">
          <xsl:with-param name="interim" select="$next"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> unchanged fixed point of xpath enrichment</xsl:message>
        <xsl:copy-of select="$interim"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>  
  <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_xpath_enrichment">
  <xsl:copy inherit-namespaces="no">
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="absolute" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:if test="not(xpath_qualified_type_classifier)">
      <xpath_qualified_type_classifier>
        <xsl:value-of select="elementName"/>
      </xpath_qualified_type_classifier>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:if test="not(xpath_type_classifier)">
      <xpath_type_classifier>
        <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/elementName,'|')"/>
      </xpath_type_classifier>
    </xsl:if>
    <xsl:if test="not(xpath_qualified_element_name)">
      <xsl:if test="not(entity_type)">
        <xsl:choose>
          <xsl:when test="count(//entity_type[elementName=current()/elementName]) = 1">
            <xpath_qualified_element_name>
              <xsl:value-of select="elementName"/>
            </xpath_qualified_element_name>
          </xsl:when>
          <xsl:otherwise>
            <!-- 22-Sept-2017 Fix this test using every 
            <xsl:if test="key('entity_type',parentType)/xpath_qualified_type_classifier">
            -->      
            <xsl:if test="every $parent_type 
                          in key('AllIncomingCompositionRelationships',name)/..
                          satisfies boolean($parent_type/xpath_qualified_type_classifier)">  
              <xpath_qualified_element_name>
                <xsl:variable name="contexts" as="xs:string*">
                  <xsl:for-each select="key('AllIncomingCompositionRelationships',name)">
                    <xsl:variable name="postfix">
                      <xsl:if test="name">
                        <xsl:text>/*</xsl:text>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:for-each select="tokenize(../xpath_qualified_type_classifier,
                                                              '\|')">
                      <xsl:value-of select="concat(.,$postfix)"/>
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="concat(string-join($contexts,concat('/', elementName,'|')),'/',elementName)"/>
              </xpath_qualified_element_name>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
    <xsl:if test="not(xpath_qualified_type_classifier)">
      <xsl:if test="not(entity_type) and xpath_qualified_element_name">
        <xpath_qualified_type_classifier>
          <xsl:value-of select="xpath_qualified_element_name"/>
        </xpath_qualified_type_classifier>
      </xsl:if>
      <xsl:if test="entity_type and (
                     every $et in descendant-or-self::entity_type[not(entity_type)]
                     satisfies boolean($et/xpath_qualified_element_name))" >

        <xpath_qualified_type_classifier>
          <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/
                                                     xpath_qualified_element_name,
                                                   '|')"/>
        </xpath_qualified_type_classifier>
      </xsl:if>
    </xsl:if>
    <xsl:if test="not(xpath_parent_entity)">
      <xpath_parent_entity>    <!-- This could be improved to work in more circumstances 
                                           - this implementation assumes all incoming compositions require the same navigation -->
        <xsl:text>..</xsl:text>     <!-- 31 Aug 2016 WAS ../ -->
        <xsl:if test="key('AllIncomingCompositionRelationships',name)/name">
          <xsl:text>/..</xsl:text>   <!-- 31 Aug 2016 WAS .. -->
        </xsl:if>
      </xpath_parent_entity>
    </xsl:if>
    <xsl:if test="not(xpath_local_key)">
      <xpath_local_key>
            <xsl:value-of select="string-join(ancestor-or-self::entity_type/attribute[identifying]/name 
                                                       ! era:braceIfDefined(.,ancestor-or-self::entity_model/xml/namespace_uri)
                                              ,',')"/>
      </xpath_local_key>
    </xsl:if>
    <xsl:if test="not(xpath_primary_key) and xpath_local_key and xpath_parent_entity">
      <xsl:choose>
        <xsl:when test="../name()='absolute' or not(exists(key('AllIncomingCompositionRelationships',name)[identifying]))">
          <xpath_primary_key>
            <xsl:value-of select="xpath_local_key"/>
          </xpath_primary_key>
        </xsl:when>
        <xsl:when test="every $entity 
                             in  key('AllIncomingCompositionRelationships',name)/.. 
                             satisfies boolean($entity/xpath_primary_key)">
          <xpath_primary_key>
            <xsl:choose>
              <xsl:when test="key('AllIncomingCompositionRelationships',name)[identifying/inherited]">  
                   <xsl:message terminate="yes">Shouldn't ever travel this leg -- see Change of 9th July 2023 </xsl:message>
      <!--
                <xsl:value-of select="concat(xpath_parent_entity,'/')"/>
                <xsl:text>descendant-or-self::entity_type/</xsl:text>   
                <xsl:if test="exists(ancestor-or-self::entity_type/attribute[identifying])">
                  <xsl:text>(</xsl:text>
                </xsl:if>
                <xsl:value-of select="key('AllIncomingCompositionRelationships',name)/../xpath_primary_key"/>
                <xsl:if test="exists(ancestor-or-self::entity_type/attribute[identifying])">
                  <xsl:text>,current()/</xsl:text>
                  <xsl:value-of select="era:brace(ancestor-or-self::entity_type/attribute[identifying]/name,
                                                  ancestor-or-self::entity_model/xml/namespace_uri)"/>
                  <xsl:text>)</xsl:text>
                </xsl:if>
      -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="parent_primary_key" as="xs:string"
                              select="let $pk := key('AllIncomingCompositionRelationships',name)/../xpath_primary_key
                                           return if (contains($pk,',')) then '(' || $pk || ')' else $pk"/>
                <xsl:choose>
                  <xsl:when test="xpath_local_key=''">
                    <xsl:value-of select="xpath_parent_entity"/>
                    <xsl:text>/</xsl:text>
                    <!-- parent primary key -->
                    <xsl:value-of select="$parent_primary_key"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!--<xsl:text>(</xsl:text>-->
                    <xsl:value-of select="xpath_parent_entity"/>
                    <xsl:text>/</xsl:text>
                    <!-- parent primary key -->
                    <xsl:value-of select="$parent_primary_key"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="xpath_local_key"/>
                    <!--<xsl:text>)</xsl:text>-->
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xpath_primary_key>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="not(xpath_typecheck)">
      <xsl:choose>
        <xsl:when test="not(entity_type)">  <!-- is a concrete type -->
          <xsl:if test="elementName">
            <xpath_typecheck>
              <xsl:value-of select="concat('self::',era:brace(elementName,ancestor-or-self::entity_model/xml/namespace_uri))"/>
            </xpath_typecheck>
          </xsl:if>
        </xsl:when>  
        <xsl:otherwise>     <!-- abstract entity type -->
          <xsl:if test="every $child_et in descendant-or-self::entity_type[not(entity_type)] satisfies boolean($child_et/xpath_typecheck)">
            <xpath_typecheck>
              <xsl:value-of select="string-join(descendant-or-self::entity_type[not(entity_type)]/xpath_typecheck,'|')"/>  
            </xpath_typecheck>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition" mode="recursive_xpath_enrichment">
  <xsl:copy>
     <xsl:apply-templates mode="recursive_xpath_enrichment"/>
     <!-- pbe_passno -->
     <xsl:if test="not(pbe_passno)">
        <xsl:choose>
           <xsl:when test="pullback">
               <xsl:if test="pullback/pbe_passno">
                    <pbe_passno>
                        <xsl:value-of select="pullback/pbe_passno"/>
                    </pbe_passno>
               </xsl:if>
           </xsl:when>
           <xsl:otherwise>
               <pbe_passno>
                  <xsl:value-of select="0"/>
               </pbe_passno>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition/pullback" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <xsl:variable name="projection_relationship"
                  as="element(reference)"
                  select="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))"/>
    <xsl:variable name="projection_rel_type"
                  as="element(entity_type)"
                  select="key('EntityTypes',$projection_relationship/type)"/>
    <xsl:variable name="host_type"
                  as="xs:string"
                  select="parent::composition/parent::*/(if (self::absolute) then '' else name)"/>

    <xsl:if test="not(xpath_resolve_candidate)
                    and $projection_relationship/riser/*/xpath_delta_key 
                    and $projection_rel_type/xpath_local_key
                    and 
                    ($host_type=''
                         or
                         key('EntityTypes',$host_type)/xpath_primary_key
                    )
                  ">              


      <xsl:variable name="xpath_inverse_fragment"
                    as="xs:string">

        <xsl:variable name="xpath_delta_key" 
                      as="xs:string"
                      select="era:combineKey(
                                         $projection_relationship/riser/*/xpath_delta_key,
                                         $projection_rel_type/xpath_local_key
                                                )
                                 "/>
        <xsl:value-of select="if ($host_type='') 
                              then $xpath_delta_key
                              else
                                 era:combineKey(   
                                         concat('current()/',
                                                key('EntityTypes',$host_type)/xpath_primary_key
                                               ),
                                         $xpath_delta_key
                                                )
                                 "/>
      </xsl:variable>

      <xpath_resolve_candidate>
        <xsl:text>key('</xsl:text>
        <xsl:value-of select="key('EntityTypes',../type)/identifier"/>
        <xsl:text>',</xsl:text>
        <xsl:value-of select="$xpath_inverse_fragment"/>
        <xsl:text>)</xsl:text>
      </xpath_resolve_candidate>
    </xsl:if>

    <!-- xpath_iterate -->
    <xsl:if test="not(xpath_iterate)
                    and along/*/xpath_evaluate
                    and key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/xpath_evaluate_inverse
                    and xpath_resolve_candidate
                   ">
      <xpath_iterate>
        <xsl:value-of select="along/*/xpath_evaluate"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/xpath_evaluate_inverse"/>
        <xsl:text>/ (if (boolean(</xsl:text>
        <xsl:value-of select="xpath_resolve_candidate"/>
        <xsl:text>))then </xsl:text>
        <xsl:value-of select="xpath_resolve_candidate"/>
        <xsl:text> else .)</xsl:text>
      </xpath_iterate>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno">
          <xsl:if test="along/identity">
               <pbe_passno>
                 <xsl:value-of select="max((
                    key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno
                   )) + 1 "/>
               </pbe_passno>
          </xsl:if>
          <xsl:if test="along/*/pbe_passno">
             <pbe_passno>
              <xsl:value-of select="max((
                    key('AllRelationshipBySrcTypeAndName',era:packArray((../type,projection_rel)))/riser/*/pbe_passno,
                    along/*/pbe_passno
                   )) + 1 "/>
             </pbe_passno>
          </xsl:if>
       </xsl:if>
    </xsl:if>
  </xsl:copy>
</xsl:template>


<xsl:template match="reference" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:variable 
            name="is_implemented_by_fk" as="xs:boolean"
            select="(cardinality/ZeroOrOne or cardinality/ExactlyOne)
                    and  (if (not(inverse)) 
                          then true()
                          else boolean(riser)
                         )
                   "/>
    <xsl:variable name="inverse_relationship"
                  as="element(reference)?"
                  select="let $host_entity_type_name := parent::entity_type/name,
                              $myname := name
                              return //reference[type=$host_entity_type_name and inverse=$myname]
                          "    />


    <xsl:variable name="can_be_implemented_as_inverse_of_relationship"
                  as="xs:boolean"
                  select="if (inverse)
                          then $inverse_relationship/(
                             (cardinality/ZeroOrOne or cardinality/ExactlyOne)
                             and  (if (not(inverse)) 
                                   then true()
                                   else boolean(riser)
                                  )
                                                    )
                          else false()"/>
    <xsl:if test="not($is_implemented_by_fk) and $can_be_implemented_as_inverse_of_relationship">
      <xsl:if test="not(xpath_evaluate)
                    and key('EntityTypes',type)/xpath_typecheck
                    and $inverse_relationship/xpath_evaluate">
        <xpath_evaluate>
        <xsl:value-of select="
           let $dest_type_check := key('EntityTypes',type)/xpath_typecheck
           return     ' let $this := . return ancestor-or-self::document-node()//*['
                  ||  $dest_type_check
                  ||  '][('
                  ||  $inverse_relationship/xpath_evaluate
                  || ') is $this]'
           "/>
        </xpath_evaluate>
      </xsl:if>
    </xsl:if>


    <!-- xpath_is_defined -->  
    <xsl:if test="not(xpath_is_defined) and $is_implemented_by_fk">
      <xpath_is_defined>
        <xsl:value-of select="string-join(key('inverse_implementationOf',concat(../name,':',name))/../name,' and ')"/>
        <!-- NOTE: This will be empty (which is not correct) when a reference has a key constraint (c.f. CR_18159) but no foreign_keys  -->
        <!-- for now change ERmodel2.referential_integrity.xslt not to plant a ref integrity check for a reference with a key constraint -->
      </xpath_is_defined>
    </xsl:if>

    <!-- xpath_typecheck -->
    <xsl:if test="not(xpath_typecheck) and $is_implemented_by_fk">
      <xsl:if test="key('EntityTypes',type)/xpath_typecheck">
        <xpath_typecheck>
          <xsl:value-of select="key('EntityTypes',type)/xpath_typecheck"/>
        </xpath_typecheck>
      </xsl:if>
    </xsl:if>

    <!-- xpath_local_key -->
    <xsl:if test="not(xpath_local_key) 
                    and (not(key) 
                        or ( key/*/xpath_evaluate 
                             and key('EntityTypes',key/*/dest)/xpath_primary_key
                           )
                        )
                    and (every $asc in auxiliary_scope_constraint 
                                satisfies (  $asc/equivalent_path/*/xpath_evaluate
                                           and 
                                             $asc/xpath_primary_key_of_auxiliary_identified_entity
                                           )
                        )
                   ">
      <xpath_local_key>
        <xsl:for-each select="key('inverse_implementationOf',concat(../name,':',name))">
          <xsl:if test="position() &gt; 1">
            <xsl:text>,</xsl:text>
          </xsl:if>
          <xsl:value-of select="era:brace(../name,ancestor-or-self::entity_model/xml/namespace_uri)"/>
        </xsl:for-each>
        <!-- Change log 2nd June 2023 -->
        <!-- assume that auxiliary scopes are for trailing primary keys
              SHOULD IMPROVE ON THIS I THINK
        -->
        <xsl:for-each select="auxiliary_scope_constraint">
             <xsl:text>,</xsl:text>                 <!-- will it always be auxiliary ? -->
             <xsl:value-of select="equivalent_path/*/xpath_evaluate"/>
             <xsl:text>/</xsl:text>
             <xsl:value-of select="xpath_primary_key_of_auxiliary_identified_entity"/>
        </xsl:for-each>
      </xpath_local_key>
          <!-- xpath_local_key_defined  -->
      <xpath_local_key_defined>
          <xsl:for-each select="key('inverse_implementationOf',concat(../name,':',name))">
            <xsl:if test="position() &gt; 1">
              <xsl:text> and </xsl:text>
            </xsl:if>
            <xsl:value-of select="'exists(' ||  era:brace(../name, ancestor-or-self::entity_model/xml/namespace_uri ) || ')'"/>   <!-- TBD 2nd June 2023 Check that auxiliary key is defined ??? -->
          </xsl:for-each>
      </xpath_local_key_defined>
    </xsl:if>

    <!-- xpath_foreign_key -->
    <xsl:if test="not(xpath_foreign_key) and $is_implemented_by_fk 
                                           and xpath_local_key
                                           and ( not(diagonal) or diagonal/theabsolute or riser/*/identification_status)" >
      <xsl:choose>
        <xsl:when test="not(diagonal) or diagonal/theabsolute or riser/*/identification_status='NotIdentifying'">
          <xpath_foreign_key>
            <xsl:value-of select="xpath_local_key"/>
          </xpath_foreign_key>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="diagonal/*/xpath_evaluate and riser/*/dest and key('entity_type',riser/*/dest)/xpath_primary_key">    
            <xpath_foreign_key>
              <xsl:value-of select="diagonal/*/xpath_evaluate"/>  
              <xsl:text>/(</xsl:text>
              <xsl:value-of select="key('EntityTypes',riser/*/dest)/xpath_primary_key"/>
              <xsl:text>),</xsl:text>
              <xsl:value-of select="xpath_local_key"/>
            </xpath_foreign_key>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>


    <!-- xpath_evaluate -->

    <xsl:if test="not(xpath_evaluate) and $is_implemented_by_fk ">
        <xsl:variable name="implementingAttributes"
                      as="element(attribute)*"
                      select="parent::entity_type/attribute[implementationOf/rel eq current()/self::reference/name]"/>

        <xsl:if test="(not(diagonal)
                        or diagonal/theabsolute
                        or diagonal/*/xpath_evaluate and riser/*/xpath_evaluate
                      )
                      and key('EntityTypes',type)/xpath_typecheck
                      and (every $asc in auxiliary_scope_constraint
                              satisfies $asc/equivalent_path/*/xpath_evaluate
                          )
                      and ( every $impattr in $implementingAttributes
                                 satisfies (not ($impattr/implementationOf/reached_by)
                                              or $impattr/implementationOf/reached_by/*/xpath_evaluate
                                            )
                          )
                      ">
            <xpath_evaluate> <!-- see part D of change logged 2nd June 2023 -->
                <xsl:value-of select="
let $primarySubcondition := (:$riser is $instance/diagonal:)
      if (diagonal and not (diagonal/theabsolute))
      then self::reference/riser/*/xpath_evaluate
           || ' is $instance/'
           || self::reference/diagonal/*/xpath_evaluate
      else '',
    $secondarySubcondition := 
      string-join($implementingAttributes ! 
                             (    (if (implementationOf/reached_by)
                                    then implementationOf/reached_by/*/xpath_evaluate || '/'
                                    else ''
                                  )
                               || era:brace(implementationOf/destAttr, ancestor-or-self::entity_model/xml/namespace_uri) 
                               || ' eq $instance/' 
                               || era:brace(name, ancestor-or-self::entity_model/xml/namespace_uri) 
                             ) ,
                  ' and ' 
                  ),
    $tertiarySubcondition :=
      let $destination_type := (:$erMetaModelLib?destinationTypeOfRelationship(self::reference),:)
                                key('EntityTypes',type),   
          $tertiary_clause_constructor
               := function ($asc as element(auxiliary_scope_constraint)) as xs:string
                  {
                      let $implementingAttributes := (: CHECK THE LOGIC OF THE FOLLOWING :)
                          $destination_type/ancestor-or-self::entity_type/attribute
                                           [implementationOf/rel eq $asc/identifying_relationship]
                      return string-join($implementingAttributes ! 
                                           (  
                                             era:brace(self::attribute/name, ancestor-or-self::entity_model/xml/namespace_uri) 
                                            || ' eq $instance/'
                                            ||  $asc/equivalent_path/*/xpath_evaluate
                                            || '/' 
                                            || era:brace(implementationOf/destAttr, ancestor-or-self::entity_model/xml/namespace_uri)
                                           ) ,
                                         ' and ' 
                                         )

                  }
      return string-join( auxiliary_scope_constraint ! ( . => $tertiary_clause_constructor() ) ,
                    ' and '
                  )
return
  'let $instance := . return //*['
  ||  key('EntityTypes',type)/xpath_typecheck
  || ']['
  || $secondarySubcondition
  || (if ($secondarySubcondition ne '' and $tertiarySubcondition ne '') then ' and ' else '')
  || $tertiarySubcondition
  || ']'
  || (if ($primarySubcondition ne '') then '[' else '')
  || $primarySubcondition 
  || (if ($primarySubcondition ne '') then ']' else '')
                  "/>
            </xpath_evaluate>
        </xsl:if>
    </xsl:if>


    <!-- prior to partD of chenge logged 2nd June 2013 implmented 16 June 2023 
    <xsl:if test="not(xpath_evaluate) and $is_implemented_by_fk and xpath_foreign_key">
        <xsl:if test="(not(diagonal)
                        or diagonal/theabsolute
                        or diagonal/*/xpath_evaluate and riser/*/identification_status
                      )
                       and key('EntityTypes',type)/xpath_typecheck">

            <xsl:variable name="topscoping" 
                          as="xs:string"
                          select="
                              if (riser/*/identification_status='NotIdentifying')
                              then '[ancestor-or-self::* is ' || diagonal/*/xpath_evaluate || ']'
                              else ''
                                  "/>
            <xpath_evaluate>
                <xsl:value-of select="
                    'let $fk := data(('
                  || xpath_foreign_key
                  || ')) return (ancestor-or-self::document-node()//*['
                  ||  key('EntityTypes',type)/xpath_typecheck
                  ||  '][fn:deep-equal(data(('
                  ||   key('EntityTypes',type)/xpath_primary_key
                  ||  ')), $fk)]'  
                  ||  $topscoping
                  ||  ')'
                  "/>
            </xpath_evaluate>
        </xsl:if>
    </xsl:if>
  -->

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:choose>
          <xsl:when test="projection">
              <xsl:if test="key('IncomingCompositionRelationships', ../name)/pbe_passno">
                 <pbe_passno>
                      <xsl:value-of select="key('IncomingCompositionRelationships', ../name)/pbe_passno"/>
                 </pbe_passno>
              </xsl:if>
          </xsl:when>
          <xsl:when test="not($is_implemented_by_fk) and inverse">
              <xsl:if test="key('RelationshipBySrcTypeAndName', era:packArray((type,inverse)))/pbe_passno">
                 <pbe_passno>
                      <xsl:value-of select="key('RelationshipBySrcTypeAndName', era:packArray((type,inverse)))/pbe_passno"/>
                 </pbe_passno>
              </xsl:if>
          </xsl:when>
          <xsl:otherwise>
              <pbe_passno>
                 <xsl:value-of select="0"/>
              </pbe_passno>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
     
  </xsl:copy>
</xsl:template>


<xsl:template match="reference/auxiliary_scope_constraint" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <!-- xpath_primary_key_of_auxiliary_identified_entity -->

  <!-- <xsl:message> expect 'type' for  parent reference parant entity type '<xsl:value-of select="parent::reference/parent::entity_type/name"/>'</xsl:message> -->
    <xsl:variable name="identifying_relationship"
                               as="element(reference)"
                               select="key('AllRelationshipBySrcTypeAndName',
                                           era:packArray((parent::reference/type,
                                                          identifying_relationship)))"/>

    <xsl:variable name="destination_type_of_identifying_relationship"
                               as="element(entity_type)"
                               select="key('EntityTypes',$identifying_relationship/type)"/>


    <xsl:if test="not(xpath_primary_key_of_auxiliary_identified_entity)
                     and $destination_type_of_identifying_relationship/xpath_primary_key">

      <xpath_primary_key_of_auxiliary_identified_entity>
        <xsl:value-of select="$destination_type_of_identifying_relationship/xpath_primary_key"/>
      </xpath_primary_key_of_auxiliary_identified_entity>
    </xsl:if>
  </xsl:copy>
</xsl:template>


<xsl:template match="dependency" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:choose>
          <xsl:when test="key('IncomingCompositionRelationships',../name)/name">
            <xsl:text>../..</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>..</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse) 
                    and ../xpath_type_classifier
                   ">
      <xpath_evaluate_inverse>
        <xsl:for-each select="key('IncomingCompositionRelationships',../name)">
          <xsl:if test="name">
            <xsl:value-of select="name"/>
            <xsl:text>/</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="../xpath_type_classifier"/>
        <xsl:text>)</xsl:text>
      </xpath_evaluate_inverse>
    </xsl:if>
    
    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:choose>
           <xsl:when test="key('IncomingCompositionRelationships',../name)/pullback">
               <xsl:if test="key('IncomingCompositionRelationships',../name)/pbe_passno">
                    <pbe_passno>
                         <xsl:value-of select="key('IncomingCompositionRelationships',../name)/pbe_passno"/>
                    </pbe_passno>
               </xsl:if>
          </xsl:when>
          <xsl:otherwise>
              <pbe_passno>
                 <xsl:value-of select="0"/>
              </pbe_passno>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:text>/</xsl:text><xsl:value-of select="/entity_model/absolute/name"/>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse)">
      <xpath_evaluate_inverse>
        <xsl:text>//</xsl:text><xsl:value-of select="src"/>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="fix">
          <pbe_passno>
                  <xsl:value-of select="0"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template match="join" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate) and (every $component in component satisfies boolean($component/xpath_evaluate))">
      <xpath_evaluate>
        <xsl:value-of select="string-join(component/xpath_evaluate,'/')"/>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse) and (every $component in component satisfies boolean($component/xpath_evaluate_inverse))">
      <xpath_evaluate_inverse>
        <xsl:value-of select="string-join(reverse(component/xpath_evaluate_inverse),'/')"/>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- xpath_delta_key -->
    <xsl:if test="not(xpath_delta_key) and component[1]/xpath_delta_key">
      <xpath_delta_key>
        <xsl:value-of select="component[1]/xpath_delta_key"/>
      </xpath_delta_key>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="every $component in component
                        satisfies boolean($component/pbe_passno)">
          <pbe_passno>
              <xsl:value-of select="max(component/pbe_passno)"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template match="identity" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>

    <!-- xpath_evaluate -->
    <xsl:if test="not(xpath_evaluate)">
      <xpath_evaluate>
        <xsl:text>.</xsl:text>
      </xpath_evaluate>
    </xsl:if>

    <!-- xpath_evaluate_inverse -->
    <xsl:if test="not(xpath_evaluate_inverse)">
      <xpath_evaluate_inverse>
        <xsl:text>.</xsl:text>
      </xpath_evaluate_inverse>
    </xsl:if>

    <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="fix">
          <pbe_passno>
                  <xsl:value-of select="0"/>
          </pbe_passno>
       </xsl:if>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<xsl:template name="component" match="component" mode="explicit">
  <!-- xpath_evaluate -->
  <xsl:if test="not(xpath_evaluate)"> 
    <xsl:variable name="subject" as="xs:string" select="'.'"/>
    <xpath_evaluate>
      <xsl:value-of select="    '$erDataLib?readRelationshipNamed('
                             || $subject
                             || ','''
                             || rel
                             || ''')'
                            "/>
    </xpath_evaluate>
  
  </xsl:if>

  <!-- xpath_evaluate_inverse -->
  <xsl:if test="not(xpath_evaluate_inverse)
                    and key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate_inverse">
    <xpath_evaluate_inverse>
        <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/xpath_evaluate_inverse"/> 
    </xpath_evaluate_inverse>
  </xsl:if>

  <!-- pbe_passno -->
    <xsl:if test="not(pbe_passno)">
       <xsl:if test="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/pbe_passno">  
         <pbe_passno>
             <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',era:packArray((src,rel)))/pbe_passno"/> 
         </pbe_passno>
       </xsl:if>
    </xsl:if>

</xsl:template>

<xsl:template match="component" mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:call-template name="component"/>
  </xsl:copy>
</xsl:template>

<xsl:function name="era:combineKey">
  <xsl:param name="element1" as="xs:string"/>
  <xsl:param name="element2" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$element1 != '' and $element2 != ''">
      <xsl:text>era:packArray((</xsl:text>
      <xsl:value-of select="$element1"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$element2"/>
      <xsl:text>))</xsl:text>
    </xsl:when>
    <xsl:when test="$element1 != ''">
      <xsl:value-of select="$element1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$element2"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="riser/component|riser/*/component
                           [not(following-sibling::component) or following-sibling::component/identification_status]
                    " mode="recursive_xpath_enrichment">
  <xsl:copy>
    <xsl:apply-templates mode="recursive_xpath_enrichment"/>
    <xsl:call-template name="component"/>
    <!-- xpath_delta_key -->
    <xsl:if test="not(xpath_delta_key)">
      <xsl:choose>
        <xsl:when test="not(following-sibling::component)">
          <xpath_delta_key>
          </xpath_delta_key>
        </xsl:when>
        <xsl:when test="following-sibling::component/identification_status='NotIdentifying'">
          <xpath_delta_key>
          </xpath_delta_key>
        </xsl:when>
        <xsl:when test="following-sibling::component[1]/xpath_delta_key">
          <xsl:if test="key('EntityTypes',dest)/xpath_local_key
                              and xpath_evaluate
                            ">
            <xpath_delta_key>
              <xsl:message>On the money</xsl:message>
              <xsl:value-of select="concat(xpath_evaluate,
                                                   '/',
                                                   era:combineKey(
                                                     following-sibling::component[1]/xpath_delta_key,
                                                     key('EntityTypes',dest)/xpath_local_key
                                                                  )
                                                   )
                                           "/>
            </xpath_delta_key>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Fallen through the cracks rel 
                      '<xsl:value-of select="concat(src,'.',rel)"/>'</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:copy>
</xsl:template>


</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/newERmodel2.xpath_enrichment.module.xslt--> 

