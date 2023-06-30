<!-- 

****************************************************************
13-Oct-2017 J.Cartmell Refine scope display text. If subject reference 
                       relationship is mandatory display as equality (=) if not
                       display as less than or equal.
15-Mar-2019 J.Cartmell Modify display text of scope. 
                       Change from ~p=q to D:p=S:q 
                       where D is Destination and S is Source
16-Aug-2022 J.Cartmell UPGRADED to latest metamodel  regarding cardinality and attribute 
16-Aug-2022 J Cartmell Recode into a pure style - one attribute per template.
                       Mostly merge initial pass and recursive pass into a single recursive path.
                       What remains in first pass is just the  addition of namespace definitions
                       (do we want to move this logic into recursive pass also?)
                       With the intention of supporting debugging modify to enable an xml attribute 
                       named trace to be generated and preserved.
-->
<!--
 DISCUSSION POINTS 
 (1) In future this first enrichment of a 
     logical entity model should complete missing detail inferred by 
     the model. Examples might be creating inverses to relationships,
     adding default cardinalities, creating composition relationships 
     from depndency relationships.
 (2) In future much of this can be generated from defintions of
     derived attributes in the meta-model ERmodelERmodel.
     Some of these derived attributes have been marked up in comments below.
     The idea of a macro language for use in ther metamodel emerges.
-->

<!-- 
Description
 This is an  initial enrichment that applies to a logical ER model.
 It is implmented as an initial pass followed by a recusrive enrichment.
     
 (1) It adds namespaces to the root entity_model element.
     Currently these are xs, era and era-js.
     (TBD are these all necessary? Are they used? Need document.)

 (2) It creates the following derived attributes:
     
      absolute => 
            identifier : string,  #see entity_type.identifier
            elementName : string  # xml element name - not necessarily unique

     entity_type => 
            identifier : string,  # based on name but syntactically 
                                  # an identifier whilst still being unique
                                  # USED in generation of rng hence i.e. mapping to xml 
                                  # also used in generation of xslt for ref integrity check
            elementName : string, # xml element name - not necessarily unique
            parentType : string   # the pipe ('|') separated types 
                                  # from which there are incoming 
                                  # composition relationships

     reference =>
        optional projection : entity ;
                                 # if the reference is specified as the 
                                 # projection_rel by a pullback. 

    auxiliary_scope-constraint =>
             identifying_relationship...type : string

    dependency => optional identifying : ()
 

    navigation ::= identity | theabsolute | join | aggregate | component
      
    navigation =>
        src : string,           # the name of the source entity type
        dest : string,          # the name of the destination entity type

     component => rel...ENTITY_TYPE.name : string  # the source entity type of relationship `rel'.
                                   # See changeLog 1-Jun-2023, 2-June-2023


    composition/xmlRepresentation/Anonymous =>
               overlap_group_id : string
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:map="http://www.w3.org/2005/xpath-functions/map"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
        exclude-result-prefixes="xs fn era map">


<xsl:template name="initial_enrichment">
   <xsl:param name="document"/>
   <!-- REINSTATED FOR NEW PURPOSE: -->
   <xsl:message>Initial entichment</xsl:message>
   <xsl:variable name="current_state">
      <xsl:for-each select="$document">
         <xsl:copy>
             <xsl:apply-templates mode="initial_enrichment_first_pass"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:call-template name="initial_enrichment_recursive">
    <xsl:with-param name="interim" select="$current_state"/>
    <!-- <xsl:with-param name="interim" select="$document"/> -->
   </xsl:call-template>
</xsl:template>


<!-- initial enrichment_first_pass -->
<!-- REINSTATE first pass to calculate grouping of anonymous compostion relationships -->
<!-- This group attribute is a helper for when it comes to reading (disambiguating) the values 
      of anonymous composition relationships with overlapping destination types.
      This grouping is also used in ERmodel2rng  --> 

<xsl:template match="@*|node()"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="entity_type[composition/xmlRepresentation/Anonymous]
                    "
              mode="initial_enrichment_first_pass"> 

  <xsl:message>entity type initial enrichment first pass</xsl:message>
  <!-- if we get ehre then we know that no super types have compositions which are Anonymous -->
  <xsl:variable name="group_mapping" 
              select="era:group_overlapping_relationships
                         (
                          descendant-or-self::entity_type/composition[xmlRepresentation/Anonymous]
                          )"/>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_sub_pass">
      <xsl:with-param name="group_mapping" select="$group_mapping"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()"
              mode="initial_enrichment_sub_pass"> 
  <xsl:param name="group_mapping"
             as="map(xs:string,xs:string)"/>
             <xsl:message>generic sub pass</xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_sub_pass">
      <xsl:with-param name="group_mapping"
                      select="$group_mapping"/>
      </xsl:apply-templates>
  </xsl:copy>
</xsl:template>


<!-- for diagnostics -->
<xsl:template match="composition"
              mode="initial_enrichment_sub_pass"> 
  <xsl:param name="group_mapping"
             as="map(xs:string,xs:string)"/>
             <xsl:message>generic sub pass</xsl:message>
  <xsl:copy>
    <xsl:attribute name="myid" select="generate-id()" />
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_sub_pass">
      <xsl:with-param name="group_mapping"
                      select="$group_mapping"/>
      </xsl:apply-templates>
  </xsl:copy>
</xsl:template>


<xsl:template match="composition/xmlRepresentation/Anonymous"
              mode="initial_enrichment_sub_pass"> 
  <xsl:param name="group_mapping"
             as="map(xs:string,xs:string)"/>
              <xsl:message>anonymous sub pass</xsl:message>
  <xsl:copy>
    <xsl:attribute name="overlap_group_id"
                   select="$group_mapping(../../generate-id())"/>
  </xsl:copy>
</xsl:template>



<!-- END OF initial enrichment_first_pass -->

<!-- BEGIN initial_enrichment_recursive -->

<xsl:template name="initial_enrichment_recursive">
   <xsl:param name="interim"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
           <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next))">     <!-- CR-18553 -->
            <xsl:message> changed in initial enrichment recursive</xsl:message>
            <xsl:call-template name="initial_enrichment_recursive">
               <xsl:with-param name="interim" select="$next"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unchanged fixed point of initial enrichment recursive </xsl:message>
            <xsl:copy-of select="$interim"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>  
   <xsl:copy-of select="$result"/>
</xsl:template>


<!-- recursive enrichment starts here -->


<!-- FOLLOWING HAS BEEN RECODED IN meta model -->
<!-- added somewhat later (Oct 2022) What I guess I mean by the above comment is that
     elementName has been added as a derived attribute in the file EntityLogicMetaModel.xml
-->


<!-- KEEP THE FOLLOWING IN SOME COMPLETION XSLT -->
<!-- Adding identifier to ERA..logical -->
<xsl:template match="*[self::absolute|self::entity_type]
                     [not(identifier)]
                     "
              mode="initial_enrichment_recursive" priority="2">
  <xsl:copy>
      <identifier >
          <xsl:value-of select="translate(replace(name,'\((\d)\)','_$1'),
                                          ' ',
                                          '_'
                                         )
                               "/>
      </identifier>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<!-- elementName already in ERA..logical -->

<xsl:template match="*[self::absolute|self::entity_type]
                      [not(elementName)]
                      " mode="initial_enrichment_recursive"
              priority="3">
  <xsl:copy> 
       <elementName>
          <xsl:value-of select="translate(replace(name,'\(\d\)',''),
                                          ' ',
                                          '_'
                                         )
                               "/>
       </elementName>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>





<!-- in the logic below there were two cases prior to 16 Aug 2022
      one case used outgoing dependency and its type and other incoming composition
       we cannot rely on dependency/type because this isnt present for compositions from absolute
                  so why not just rely on incoming compositions?
-->
   <!--  GOT a bug in car example so then modified on 31 Oct 2022 ... see below -->
     <!-- add this to ERA logical XXXXXXXXXXXXXXXXXXX-->
<xsl:template match="entity_type
                     [not(parentType)]
                     " 
              mode="initial_enrichment_recursive"
              priority="6">
   <xsl:copy> 
      <parentType>                              
         <xsl:value-of select="string-join(key('AllIncomingCompositionRelationships',
                                               descendant-or-self::entity_type/name
                                               )/../name,
                                     ' | ')"/>               <!-- used key 'IncomingCompositionRelationships' from 16 Aug until 31 Oct 
                                                                  this fixes immediate problem but needs further testing -->
      </parentType>
      <!-- 
        In future define
        all_incoming_composition_relationships 
        = (ancestor_or_self::entity_type)/incoming_composition_relationships

        and

        source_types_of_all_incoming_composition_relationships
        = all_incoming_composition_relationships/..

        parentType is then the macro
        string-join(#source_types_of_all_incoming_composition_relationships/$$name,' | ')
        -->
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>

<!-- following might be considered unnecesarily inefficient because of recursion -->
<!-- BTW: I feel like this is a pullback -->
<xsl:template match="dependency
                     [key('CompRelsByDestTypeAndInverseName',                   
                         era:packArray((../name,name)))/identifying]
                     [not(identifying)]
                     "
              mode="initial_enrichment_recursive"
              priority="7">
  <!-- The above follows the 'inverse' reference relationship. -->
  <!-- Thinking about abstracting this I am struck by the fact that I
       have removed enumeration attributes from the model and replaced them
       by very simple compositional structure (universals). With respect of the
       old meta-model this template could be represented as the derivation of 
       a derived attribute. In the new meta-model it needs to be represented as
       a derived compositional structure. How do we meta-model this?
       Should start by documenting the difference between pullback and copy.
       Initial guess but now need to read the code.

       a copy is a pullback plus copy of all attributes, reference relationships 
       and compositional structure. [CHECK that copy is implemented in xslt
       ...it was introduced for use in js in chromatographic analysis record (car)].
       If this is the difference between the two then for a composition such as 
       this, i.e. that represents one of a set of enumerated values 
       (actually a flag in this very case) then pullback is the same as copy.
       The pullback diagram is this:
                               inverse
                  dependency :::::::::::::> composition
                     |                           |
                     |                           |
                     |                           |
                     =                           =
                     .                           .
                identifying  :::::::::::>  identifying
                              sourced_at
       The projection rel which I have named 'source_at' isn't currently modelled. 
       And this rel doesn't have anything you could point to and say that it has 
       a foreign key. It does have a diagonal and a riser.
       With it being so sketchy might use a different indictor beside either pullback
       or copy to represent it this construction and not to mandate an explicit 
       representation of this projection relationship. Though actually isn't this
       vital to how the pullback is modelled. Not a bad idea to test that logical
       to physical allright with keyless relationships like this one.
       Also we are going to have to split the identifying entity type in two. 
       One on left underneath dependency and one on right beneath composition.
       See also identification_status below.
       One possibility is not to actualise(store)(cache?) but simply to evaluate 
       as and when required. 
      
  -->  
  <xsl:copy>
      <identifying/>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>

<!-- as before, this feels like a pullback to me -->
<xsl:template match="reference
              [key('IncomingCompositionRelationships', ../name)/pullback/projection_rel = name]
              [not(projection)]" 
              mode="initial_enrichment_recursive" 
              priority="6">
   <!-- The above tests are 
              [inverse(projection_rel) defined]
              [not(projection)] 
        There is an assumption here that inverse(projection_rel) is single valued
        but in the meta-model it is shown as many-valued.
        Is it the case that its inverse should be explicitly defined in order to specify
        single-valuedness? I think so.
        Lower down the projection has a host_type calculated.
   -->
   <xsl:copy>
       <projection/>
       <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="auxiliary_scope_constraint
                     [not(identifying_relationship...type)]
                     "
              mode="initial_enrichment_recursive"
              priority="7">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
    <xsl:variable name="identifying_relationship"
                           as="element(reference)*"
                           select="key('AllRelationshipBySrcTypeAndName',
                                       era:packArray((parent::reference/type,
                                                      identifying_relationship)))"/>

    <xsl:if test="not($identifying_relationship)">
        <xsl:message terminate="yes">Auxiliary scope constraint identifying_relationship '<xsl:value-of select="parent::reference/type || '.' || identifying_relationship"/>' not found</xsl:message>
    </xsl:if>

    <xsl:if test="count($identifying_relationship) &gt; 1">
        <xsl:message terminate="yes">Auxiliary scope constraint identifying_relationship '<xsl:value-of select="parent::reference/type || '.' || identifying_relationship"/>' ambiguous  (count is <xsl:value-of select="count($identifying_relationship)"/>)</xsl:message>
    </xsl:if>

     <identifying_relationship...ENTITY_TYPE.name>
         <xsl:value-of select="$identifying_relationship/parent::entity_type/name"/>
     </identifying_relationship...ENTITY_TYPE.name>

    <identifying_relationship...type>
         <xsl:value-of select="$identifying_relationship/type"/>
     </identifying_relationship...type>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>


<!-- There follows 4 templates to define src for identity and the absolute --> 
<!-- BUT I don't see how it is defined in the case that the incoming composition
     relationship is the 'key' relationship from 'reference' 
     a BUG?
-->
<!-- I need a way of modelling these rules. -->
<!-- it feels strange but I need to identify the incoming composition relationship 
     this I can do using inverse. Made harder because the composition
     from constructed relationship is undefined so how can I test its inverse.
     Cases are
     inverse(along)                  +> inverse(along)/type
     inverse(riser2)                 +> inverse(riser2)/type
     ../[constructed_relationship]   +> ..[constructed_relationship]/src
     inverse(diagonal)               +> inverse(diagonal)/src
     inverse(riser)                  +> inverse(riser)/type
     inverse(reached_by)             +> THIS WILL NOT HAPPEN
     inverse(key)                         ... this case is missing (key specifies 
                                                   relationship targets pullback and 
                                                   value implied by key relationship into
                                                          object that is pulled back)
                                                        /key seems to be used as part of building
                                                        xpath_local_key in xpath_enichment.
     -->  
<xsl:template match="along/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="12"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::entity_type/name"/>
      </src>
      <!-- no need to # this -->
      <!-- we are setting the value of a reference relationship
           here by setting the foreign key attribute 
           <attribute>
                <name>src</name>
                <optional>
                    <default>
                       <macro>ancestor::entity_type/name</macro>
                    </default>
                </optional> 
            </attribute>
            better would be to specify the reference relationship value directly
            <reference>
                <name>src</name>
                ...
                <default>
                     ancestor::entity_type
                </default>
            </reference>
            From the latter rule the former rule can be auto generated during logical2physical.
            Excellent. 
        -->
   </xsl:copy>
</xsl:template>

<xsl:template match="riser2/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="13"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
      </src>
   </xsl:copy>
</xsl:template>

<xsl:template match="riser/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="14"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::reference[1]/type"/> 
      </src>
   </xsl:copy>
</xsl:template>

<!-- match below doesn't look right ... this is because one composition (diagonal) is
      named and one is not but leads straight from constructed relationship -->
<xsl:template match="*[self::diagonal|self::constructed_relationship]/*[self::identity|self::theabsolute]
                     [not(src)]
                     " 
              priority="15"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="ancestor::entity_type[1]/name"/>
      </src>
   </xsl:copy>
</xsl:template>

<!-- end of 4 templates to define src for identity and the absolute --> 

<!-- Now there are a further 3 templates defining src.
      1 defines src for join
      2 define src for component -->      


<xsl:template match="join
                     [not(src)]
                     [component[1]/src]
                     " 
              priority="17"
              mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>     
      <src>
         <xsl:value-of select="component[1]/src"/>
      </src>
      <!-- This is setting the value of a foreign key but ought to be specified
           relationally as
           <reference>
               <name>src</name>
               <case><test>[component]</test> <default>src</default></case>
               ...
           </reference>
           or some thing like is I nest the cases within the major definition
           What bugs me is whether to organise the language organising the
           defaults for subtypes with the definition of the relationship or
           attribute or whether to add to the logic of the attribute within 
           auxiliary defintions of implicit subtypes. The latter is more object oriented.
           Some aspects of the major definition being deferred to subtypes.
           I guess could support both. 
           For this discussion:
           theabsolute, join, identity, component are _explicit subtypes_ of navigation
           [inverse(riser)], say, is an _implicit subtype_
           In the debate whether to represent the logic in subtype aor in case statement 
           on a superior type the balance is probable toward putting in the logic in
           explicit sub types but not implicit subtypes. 

      -->
   </xsl:copy>
</xsl:template>

<!-- not sure that I benefit from spliting the following and further-->
<xsl:template match="component
                     [not(src)]
                     [not(preceding-sibling::component)]
                     " 
                     priority="20"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>    
      <xsl:choose>
         <xsl:when test="ancestor::along">
            <src>
               <xsl:value-of select="ancestor::entity_type/name"/>
            </src>
            <!-- represents the src entity type of the composition relationship is
                 designated as  pullback.
                 It would be easier to read as
                 <default>#inverse(along)/parent/src#</default>
                 which if I might intersperse with type information so:
                 <default>#inverse(along)%[initialiser]%/parent%[composition]%/src%entity_type%#</default>
            -->
         </xsl:when>
         <xsl:when test="ancestor::riser2">
            <src>
               <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
            </src>
            <!-- <default># inverse(riser2)/type #</default> -->
         </xsl:when>
         <xsl:when test="ancestor::riser">
            <src>
               <xsl:value-of select="ancestor::reference[1]/type"/>
            </src>
            <!-- <default># inverse(riser)/type #</default> -->
         </xsl:when>
         <xsl:when test="ancestor::reached_by">
            <src>
               <!-- tricky - see if I can fill it in earlier -->
            </src>
            <!-- <default># inverse(riser)/type #</default> -->
         </xsl:when>
         <xsl:otherwise>  <!-- diagonal or constructed relationship -->
            <src>
               <xsl:value-of select="ancestor::entity_type[1]/name"/>
            </src>
             <!-- <default># (inverse(diagonal)|..[constructed_relationship])/src #</default> -->
         </xsl:otherwise>
      </xsl:choose>
   </xsl:copy>
</xsl:template>

<xsl:template match="component
                     [not(src)]
                     [preceding-sibling::component[1]/dest]
                     " 
                     priority="21"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <src>
         <xsl:value-of select="preceding-sibling::component[1]/dest"/>
      </src>
   </xsl:copy>
</xsl:template>

<!-- end of two templates defining src for component. -->
<!-- summarise thus: 
<entity_type>
    <name>component</name>
    ...
    <deferred>
         <reference>
             <name>src</name>
             <default>
                <case><test>preceding-sibling::component[1]</test>           
                      <value>#preceding-sibling::component[1]/dest#</value>
                </case>
                <case>
                    <test>not(preceding-sibling::component)</test>         
                    <case>
                        <test>inverse(along)</test>
                        <value>#inverse(along)/parent%composition%/src#</value>
                    </case>
                    <case>
                        <test>inverse(riser2)</test>
                        <value>#inverse(riser2)/type#</value>
                    </case>
                    <case>
                        <test>inverse(riser)</test>
                        <value>#inverse(riser)/type#</value>
                    </case>
                    <case>
                        <test>inverse(diagonal)|parent[constructed_relationship]</test>
                        <value>#(inverse(diagonal)|parent[constructed_relationship])/src#</value>
                        BTW can aggregate these because 
                        (inverse(diagonal)|parent[constructed_relationship]) : Relationship
                        and src is inherited from entity type Relationship
                    </case>
                </case>
             </default>
        </reference>
    </deferred>
-->

<!-- End of templates defining src -->

<!-- now so many for <dest> -->

 <xsl:template match="identity
                      [not(dest)]
                      [src]
                      " 
               priority="16"
               mode="initial_enrichment_recursive">
   <xsl:copy> 
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <dest>
         <xsl:value-of select="src"/>
      </dest>
      <!--  
        <entity_type>
           <name>identity</name>
           <reference>
               <name>dest</name>
               <deferredFrom>navigation</deferredFrom>
               <value>#src#</value>
            </reference>
        </entity_type>
      -->
   </xsl:copy>
</xsl:template>

 <xsl:template match="join
                      [not(dest)]
                      [component[last()]/dest]
                      " 
               priority="18"
               mode="initial_enrichment_recursive">
   <xsl:copy> 
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
      <dest>
         <xsl:value-of select="component[last()]/dest"/>
      </dest>
       <!--  
        <entity_type>
           <name>join</name>
           <reference>
               <name>dest</name>
               <deferredFrom>navigation</deferredFrom>
               <value>#component[last()]/dest#</value> ... must need add last() 
                                                       ... to navigation model 
            </reference>
        </entity_type>
        -->
   </xsl:copy>
</xsl:template>


<xsl:template match="component
                     [not(dest)]
                     [src]
                     " 
                     priority="22"
                     mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_enrichment_recursive"/>
        <!-- ChangeLog 1-Jun-2023 Add `relSrc' -->
        <!-- ChangeLog 2-Jun change name to `rel...ENTITY_TYPE.name' -->
        <xsl:variable name="relationship"
                      as="element((:reference_or_dependency:))"
                      select="key('AllRelationshipBySrcTypeAndName',
                                      era:packArray((src,rel)))
                             "/>

         <dest>
            <xsl:value-of select="$relationship/type"/>
         </dest>
         <rel...ENTITY_TYPE.name>
            <xsl:value-of select="$relationship/parent::entity_type/name"/>
        </rel...ENTITY_TYPE.name>
        <!--  
        <entity_type>
           <name>component</name>
           <reference>
               <name>dest</name>
               <deferredFrom>navigation</deferredFrom>
               <value>#rel/type#</value> 
            </reference>
        </entity_type>
        -->

   </xsl:copy>
</xsl:template>

<xsl:variable name="are_comparable"
              as="function(element(entity_type),
                           element(entity_type)) as xs:boolean"
              select="function($et1 as element(entity_type),
                               $et2 as element(entity_type))
                      {
                        ( some $parent in $et1/ancestor-or-self::entity_type satisfies $parent is $et2)
                        or
                        (some $parent in $et2/ancestor-or-self::entity_type satisfies $parent is $et1)
                      }
                      "/>

<xsl:variable name="are_overlapping"
              as="function(element(composition),
                           element(composition)) as xs:boolean"
              select="function($arg1 as element(composition),
                               $arg2 as element(composition))
                                             as xs:boolean
                      {   let $entity_model := $arg1/ancestor-or-self::entity_model
                          return $are_comparable($entity_model//entity_type[name=$arg1/type],
                                                 $entity_model//entity_type[name=$arg2/type])
                      }
                    "/>

<xsl:function name="era:group_overlapping_relationships"
              as="map(xs:string, xs:string)">
    <xsl:param name="composition_relationships"
               as="element(composition)*"/>
    <!-- This function groups the given relationships so that those with overlapping 
         types are in the same group. Returns a map in which entries correspond to 
         the given relationships. Each entry maps the id of a given relationship (given by generate-id)
         to a group id.
    -->
    <!-- This function is implemented recursively (building up the map ... entry by entry). 
         In this implementation the id of the first relationship in a group
          is used as the group id -->
          <xsl:message>group overlapping </xsl:message>
   <xsl:sequence select="era:construct_overlap_map
                ($composition_relationships,map{})"/>
</xsl:function>

<xsl:function name="era:construct_overlap_map"
                as="map(xs:string,xs:string)">
    <xsl:param name="composition_relationships"
               as="element(composition)*"/>
    <xsl:param name="overlap_map_so_far"
               as="map(xs:string,xs:string)
                   (: maps ids of composition relationships 
                      to the ids of first composition in a 
                      group of are_overlapping compostions:) 
              "/>

    <xsl:message>construct overlapping 
                  <xsl:value-of select="map:size($overlap_map_so_far), 
                                        'eq ? ', 
                                        count($composition_relationships) 
                                       "/>
    </xsl:message>
    <xsl:choose>
        <xsl:when test="map:size($overlap_map_so_far) 
                         eq count($composition_relationships)">
            <xsl:sequence select="$overlap_map_so_far"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="Rnext"
                  as="element(composition)"
                  select="$composition_relationships
                             [map:size($overlap_map_so_far) + 1]">
                  <!-- next relationship for which map will be established -->
            </xsl:variable>
            <xsl:variable name="preceeding_composition_relationships"
                          as="element(composition)*"
                  select="$composition_relationships
                            [fn:position() = 1 to map:size($overlap_map_so_far)]"/>

            <xsl:variable name="preceding_overlapping_composition_relationship"
                    as="element(composition)?"
                select="let $overlaping_relationships
                              := $preceeding_composition_relationships
                                         [$are_overlapping(.,$Rnext)]
                            return fn:head(fn:reverse($overlaping_relationships))
                        "/>
                  <xsl:message>Overlap keys <xsl:copy-of select="map:keys($overlap_map_so_far)"/></xsl:message>
                  <xsl:message>preceeding comp id <xsl:value-of select="$preceding_overlapping_composition_relationship/generate-id()"/></xsl:message>
            <xsl:variable name="required_mapping"
                          as="xs:string"
                  select="if ($preceding_overlapping_composition_relationship)
                          then $overlap_map_so_far
                                 ($preceding_overlapping_composition_relationship/generate-id())
                          else $Rnext/generate-id() 
                          "/>
                           <xsl:message>required_mapping <xsl:copy-of select="$required_mapping"/></xsl:message>
            <xsl:variable name="mapping_of_Rnext_relationship"
                          as="map(xs:string,xs:string)"
                  select="map{$Rnext/generate-id() : $required_mapping}
                         ">
                  <!-- Note that a Rnext maps to itself if it has no overlap 
                       with preceding relationships in the given sequence -->
            </xsl:variable>
            <xsl:message>mapping_of_Rnext_relationship </xsl:message>
            <xsl:variable name="extended_overlap_map"
                          as="map(xs:string,xs:string)"
                  select="map:merge(($overlap_map_so_far,
                                    $mapping_of_Rnext_relationship))
                         "/>

            <xsl:message>extended_overlap_map </xsl:message>             
            <!-- call recursivley to complete the job -->
            <xsl:sequence select="era:construct_overlap_map
                                    ($composition_relationships,$extended_overlap_map)
                                 "/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:function> 




</xsl:transform>
