

<!--


DESCRIPTION
 This xslt module provides the algorithm that generates a physical
 ER model from a logical ERmodel.

 The algorithm is recursive and uses the recursive enrichment technique.
 There is a also a final pass which completes the job.

DISCUSSION
  (1) This xslt maybe further simplfied in future by moving some of the
      logic into an earlier recursive enrichment phase. 
      JC 21 Oct 2016.
  (2) seqNo attributes are generated for entity types
      with incoming composition relationships having the sequence indicator.
      If the entity type does not have any identifying attributes or relationships and 
      provided the incoming composition relationship has the identifying indicator 
      then the implied seqNo atribute is identifying. 
      TBD:
      If there are multiple incoming sequence composition relationships the
      seqNo attribute may need to be prefixed with the name of the composition 
      relationship or, if not named, the name of the source entity type.
      END TBD.

  (3) The final pass cleans up any temporary seqNo attributes
      and is only needed in the hierarchical case. It could be changed
      to be more generic by putting temporary attributes in a 'temp'
      namespace and removing all elements having this namespace in
      the final pass. The main algorithm would need deal with
      uncertainty of namespace for 'attribute' elements in a number of   (16 August 2022 - UPGRADED to latest metamodel  value >>> attribute)
      places and would need not propogate name space when foreign
      keys are created.

  (4) KE001 NOT YET IMPLEMENTED: Support for reference 
      relationships whose scope is absolute and for which 
      destination entity type has an identifying 
      incoming composition relationship. Example of such 
      is in catalogue A1fA2B1gB2unconstrained.hierarchical.svg. 
      To implement support for these need to resursively walk 
      up the composition structure that is implied by "theabsolute". 
      The thought process of implementing support for these absolute 
      scopes relationships is  added in comments tagged as KE001.
      JC 24 May 2016.
     
  (5) BUG. IN /src/dataModels/AX1X2BCD.hierarchical.svg 
      reference second occurrence of g_X2_name(R9) of entity type B 
      should have had X1 in its name somewhere.  Also C is missing 
      keys X1_name and X2_name.
      JC 24 May 2016.

CHANGE HISTORY
CR18032 JC 17-Aug-2016 Support inheritance of relationships in join navigations 
                       by introduction and use of keys 
                       AllRelationshipBySrcTypeAndName and AllIncomingCompositionRelationships.

CR18059 JC 19-Aug-2016 Support inheritance of identifying attributes  and relationships.

CR18037 JC 22-Aug-2016 Support referential integrity check by, optionally 
                       as indicated by identifying/inherited directive, 
                       generating primary key using technique coded in 
                       CR18032 using descendent-or-self.

CR18159 JC 30-Aug-2016 In generation of xpath_foreign_key implement support 
                       for the key directive of a reference relationship.

CR18397 JC 03-Oct-2016 Specify seqNo attributes as integer.

CR18469 JC 11-Oct-2016 Fix bugs found in development of 
                       study_round_requirement model regarding carrying 
                       forward of SeqNo attributes in relational case and 
                       references to compositions from absolute flagged as 
                       identifying.

CR18497 JC 14-Oct-2016 Move the generation of IDs for relationships into 
                       the initial pass. This opens us up to including 
                       these IDs elsewhere in the model.

CR18159 JC  18-Oct-2016 In the generation of xpath_foreign_key do not 
                       include the primary key of the destination entity type
                       of the riser unless all the rising relationships are 
                       identifying. Modified xpath-evaluate so that 
                       call of key function receives diagonal as a third
                       parameter.

CR18553 JC  21-Oct-2016 Created this xslt as a module by extraction
                       of a part of ERmodel2.physical.xslt. 
                       Added a mode="recursive_physical_enrichment" to the
                       templates implementing the recusive enrichment
                       and doing the main work.
CR18720 JC  16-Nov-2016 Use packArray function from ERmodel.functions.module.xslt

CR19407 JC  20-Feb-2017 Implement a new pass (first_physical_pass) to create seqNo attributes

CR20616 BA  18-Jul-2017 Do not copy xmlRepresentation in implementing attributes.

18-Sept-2017 JC         Correct comment regarding when seqNo attribute is identifying.

2-Apr-2019   JC         or condition added to ensure that foreign keys are generated for
                        reflexive relationships. Tested on molecularGeometry example.

16-Aug-2022 J.Cartmell UPGRADED to latest metamodel  regarding cardinality and attribute 

-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>




<xsl:template name="physical_enrichment">
   <xsl:param name="document"/>
   <xsl:message>In ERmodel2.physical_enrichment.module.xslt </xsl:message>
   <!-- first pass creates seqNo attributes -->
   <xsl:variable name="state">
      <xsl:for-each select="$document">
         <xsl:copy>
             <xsl:apply-templates mode="first_physical_pass"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <!--followed by the main recursive algorithm -->
   <xsl:variable name="state">
         <xsl:call-template name="recursive_physical_pass">
            <xsl:with-param name="interim" select="$state"/>
         </xsl:call-template>
   </xsl:variable>
   <!-- followed by a single pass that
        applies templates with mode of "final_physical_pass"
        to remove unnecessary seqNo attributes
   -->
      <xsl:for-each select="$state">
         <xsl:copy>
             <xsl:apply-templates mode="final_physical_pass"/>
         </xsl:copy>
      </xsl:for-each>
</xsl:template>

            

<xsl:template match="@*|node()" mode="first_physical_pass">
    <xsl:if test="self::Anonymous">
        <xsl:message>Copy Anon first physical pass <xsl:value-of select="@*"/></xsl:message>
    </xsl:if>
    <xsl:if test="self::attribute()">
        <xsl:message>Copy attribute in  first physical pass name <xsl:value-of select="name()"/></xsl:message>
    </xsl:if>
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="first_physical_pass"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="include_model" mode="first_physical_pass">
    <xsl:copy>
        <xsl:message>*************  first_physical_pass ***in include_model filename is '<xsl:value-of select="@filename"/>'</xsl:message>
      <xsl:apply-templates select="@*|node()" mode="first_physical_pass"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="first_physical_pass">
  <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="first_physical_pass"/>
     <xsl:variable name="has_identifiers" as="xs:boolean">
       <xsl:value-of select="boolean((reference|attribute)/identifying)" />  
     </xsl:variable>
     <!-- 31 October 2022 if brought outside of for-each if as must be intended -->
    <xsl:if test="not(attribute[name='seqNo'])">                             
         <xsl:for-each select="key('IncomingCompositionRelationships',name)">
           <xsl:if test="sequence">
            <xsl:message> Adding Sequence attribute </xsl:message>
             <attribute>                                               
                <name>seqNo</name>
                <type><integer/></type>           
                <for_sequence/>
                <xsl:if test="identifying and not($has_identifiers)">
                     <identifying/>
                </xsl:if>
             </attribute>    
           </xsl:if>
         </xsl:for-each>
     </xsl:if>
 </xsl:copy>
</xsl:template>

<xsl:template name="recursive_physical_pass">
   <xsl:param name="interim"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
        <xsl:copy>
          <xsl:apply-templates mode="recursive_physical_enrichment"/>
        </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next))">
            <xsl:message> changed in physical enrichment</xsl:message>
            <xsl:call-template name="recursive_physical_pass">
                <xsl:with-param name="interim" select="$next"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
             <xsl:message> unchanged fixed point of physical enrichment</xsl:message>
             <xsl:copy-of select="$interim"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>  
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="@*|node()" mode="recursive_physical_enrichment">
 <xsl:if test="self::Anonymous">
        <xsl:message>Copy Anon recursive_physical_enrichment<xsl:value-of select="@*"/></xsl:message>
    </xsl:if>
    <xsl:if test=".[self::attribute()]">
        <xsl:message>Copy attribute in  recursive_physical_enrichment<xsl:value-of select="name()"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="recursive_physical_enrichment"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="include_model" mode="recursive_physical_enrichment">
    <xsl:copy>
        <xsl:message>*************  recursive_physical_enrichment **** in include_model filename is '<xsl:value-of select="@filename"/>'</xsl:message>
      <xsl:apply-templates select="@*|node()" mode="recursive_physical_enrichment"/>
    </xsl:copy>
</xsl:template>

<xsl:function name="era:et_is_implemented" as="xs:boolean">
  <xsl:param name="root" as="node()"/>
  <xsl:param name="et_name" as="xs:string"/>
  <!-- need set some context -->
  
  <!-- no unimplemented outgoing identifying reference relationships 
       and has no unimplemented incoming identifying 
           composition relationships 
  -->
 <xsl:message>Entering <xsl:value-of select="$et_name"/> </xsl:message>
 <xsl:message>string-length of $et_name is '<xsl:value-of select="string-length($et_name)"/></xsl:message>

  <xsl:variable name="nonempty_et_name" select="if(string-length($et_name)=0) then 'EMPTYVALUEREPLACED' else $et_name"/>
  <xsl:for-each select="$root">
  <xsl:if test = "not(key('EntityTypes',$nonempty_et_name))">
      <xsl:message> 
           era:et_is_implemented out of spec bad et_name : 
            '<xsl:value-of select="$et_name"/>' 
      </xsl:message>
      <xsl:value-of select="false()"/>
  </xsl:if>
  <xsl:for-each select="key('EntityTypes',$nonempty_et_name)">

    <!-- fix bug in preparation change log 2nd June 2023 fix bug-->

    <xsl:variable name="parentImplemented"
                  as="xs:boolean"
                  select="if (parent::entity_type)
                          then era:et_is_implemented($root,parent::entity_type/name)
                          else true()  
                  "/>

     <xsl:value-of select="
        $parentImplemented and 
        not(reference[identifying
                      and not(key('whereImplemented',
                                  era:packArray(($nonempty_et_name,name))
                                 )
                             )
                     ]
           )
        and 
          (
           (  (
               ($style='h' or $style='hs') 
                    and ( every $dep in dependency[identifying (:added 25/06/2023:)] satisfies era:et_is_implemented($root, $dep/type) 
                         )
               )
           )
           or
           not (key('IncomingCompositionRelationships',$nonempty_et_name)
                               [identifying 
                                and not(key('whereImplemented',
                                            era:packArray(($nonempty_et_name,inverse))
                                            ))
                                and not(../name()='absolute')
                               ]  
                )  
           )
                            "/>        
   </xsl:for-each>
   </xsl:for-each>
</xsl:function>

<!-- MAIN WORK DONE HERE -->
<xsl:template match="entity_type" mode="recursive_physical_enrichment">
  <xsl:copy>
    <!-- copy name and presentation -->
    <xsl:apply-templates select="name"/>
    <xsl:apply-templates select="presentation"/>
    <xsl:if test="$style='r'">
       <!-- add referential attributes for incoming composition relationships-->
       <xsl:for-each select="key('IncomingCompositionRelationships',name)">
          <xsl:if test="not(key('whereImplemented',era:packArray((type,inverse))))"> 
                   <!--  @ incoming composition relationship 
                         that is is not yet implemented 
                   -->
            <xsl:if test="../name()='absolute' 
                          or 
                          era:et_is_implemented(root(),../name)
                         ">
                      <!-- the source entity type of the composition 
                           relationship is implemented 
                            (all its identifying attributes are already defined)
                      -->
                <!--
                <xsl:message>
                    implementing incoming composition relationship '<xsl:value-of select="name"/>'
                </xsl:message>
                -->
                <!-- implementing foreign key attributes --> 
                <xsl:variable name="dependencyname" select="inverse"/>
                <xsl:variable name="dependencytypename" select="../name"/>  <!-- ???? -->
                <xsl:variable name="is_identifying" select="identifying/name()"/>
                <xsl:for-each select="..">  
                   <!-- @ source entity type of the composition relationship -->
                   <xsl:call-template name="get_identifying_attributes">
                        <xsl:with-param name="attr_nameprefix" 
                                        select="name"/>
                        <xsl:with-param name="implemented_rel_name" 
                                        select="$dependencyname"/>
                        <xsl:with-param name="implemented_rel_type" 
                                        select="$dependencytypename"/>
                        <xsl:with-param name="is_identifying" 
                                        select="$is_identifying"/>   
                   </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
          </xsl:if>
       </xsl:for-each>
    </xsl:if>
    <!-- copy identifying attributes --> 
    <xsl:apply-templates select="attribute[identifying]"/>  

    <!-- add implementing attributes for reference relationships which are single valued-->
    <!-- though could be single valued on each side (noted as issue as at 18-Oct-2016 (JC)) -->
    <xsl:for-each select="reference[ (cardinality/ZeroOrOne or cardinality/ExactlyOne)
                                    and not(key('whereImplemented',
                                            era:packArray((../name,name))))
                                    and not(key)             
                                    ]">         
                                    <!-- simplifying assumption that key covers missing identifiers subject to future generalisation -->
                <!-- @ reference relationship that is not already implemented-->
				
				<!-- or condition added as support  for reflexive relationships 2 April 2019 -->
        <xsl:message>CONSIDER Relationship R'<xsl:value-of select="../name || '.' || name || ':' || type"/>'</xsl:message>
         <xsl:if test="name = inverse">
                  <xsl:message>which meets test for reflexivity</xsl:message>
         </xsl:if> 
         <xsl:if test="era:et_is_implemented(root(),type)
	                or
	                (   name=inverse         (: should I check that nane and inverse not both empty ? 26/06/2023 :) 
						  and  
				        era:et_is_implemented(root(),
                                                ancestor-or-self::entity_type/dependency[identifying]/type
                                                                                         (: modified 26/06/2023 :)
                                            )
				     )
						">
         <xsl:message>BEGIN Implementation of R'<xsl:value-of select="../name || '.' || name || ':' || type"/>'</xsl:message>
         
         <xsl:variable name="relationship" 
                       as="element()" select="."/> 
         <xsl:variable name="implementing_attributes" 
                       as="element(attribute)*" >   
           <xsl:for-each select="key('EntityTypes',type)">
             <xsl:call-template name="attributes_reqd_to_identify_from_ancestor">
               <xsl:with-param name="navigation" select="$relationship/riser/*"/>
               <xsl:with-param name="exclude_rel_name" select="$relationship/auxiliary_scope_constraint/identifying_relationship"/>
             </xsl:call-template>
           </xsl:for-each>
         </xsl:variable>

         <xsl:for-each select="$implementing_attributes"> 
            <xsl:message>IMPLEMENTING ATTRIBUTE '<xsl:value-of select="name"/>'</xsl:message>
            <xsl:call-template name="reinstantiate_attribute">
               <xsl:with-param name="relationship" select="$relationship"/>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:message>END Imp. R'<xsl:value-of select="name"/>'</xsl:message>
      </xsl:if>
    </xsl:for-each>
   
    <!-- copy remaining substructure --> 
    <xsl:apply-templates 
               select="*[not(self::attribute[identifying])       
                         and not(self::name) 
                         and not (self::presentation)]"
                mode="recursive_physical_enrichment"/>           
  </xsl:copy>
  <!-- <xsl:message> END ENTITY TYPE <xsl:value-of select="name"/> </xsl:message> -->
</xsl:template>


<!-- The idea of the next function is to collect from the destination entity of a relationship
    all the attributes required to identify an entity of the type relative from a starting point
    which will be identified by the riser of the same relationship.
    The riser is passed as a navigation whose source is the destination entity type
-->
<xsl:template name="attributes_reqd_to_identify_from_ancestor" 
              match="entity_type" 
              mode="explicit">
   <xsl:param name="navigation" as="element()?"/>
   <xsl:param name="exclude_rel_name" as="xs:string?"/>

   <!--all natural identifying attributes 
       and all referential identifying attributes 
             that implement reference relationships
   -->
    <xsl:message>exclude rel is '<xsl:value-of select="$exclude_rel_name"/>'</xsl:message>
    <xsl:for-each select="ancestor-or-self::entity_type/attribute
                                [identifying and                 
                               (not(implementationOf) or
                               key('RelationshipBySrcTypeAndName',
                                   era:packArray((../name ,implementationOf/rel))
                                  )[self::reference]
                               )
                          ]"> 
                          <!-- the complication here is to omit attributes that implement dependencies
                                    because I only want these if they are not so global as to be
                                    already known from the context of the riser
                              -->
         <xsl:if test="not($exclude_rel_name) or not(name eq $exclude_rel_name)">
             <xsl:copy>
                <xsl:element name="destAttrHostEt">
                      <xsl:value-of select="../name"/>
                </xsl:element>
                <xsl:apply-templates select="*[not(self::destAttrHostEt)]"/>   
             </xsl:copy>
         </xsl:if>
    </xsl:for-each>

   <!-- all attributes of destination of navigationHead 
          local to navigationTail 
    -->
   <xsl:variable name="navigationHead" as="element()?">
      <xsl:call-template name="navigationHead">
          <xsl:with-param name="navigation"  select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="navigationTail" as="element()?">
      <xsl:call-template name="navigationTail">
          <xsl:with-param name="navigation" select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:message>navigationHead name '<xsl:value-of select="$navigationHead/name"/>'</xsl:message>
   <xsl:message>navigationHead type '<xsl:value-of select="$navigationHead/type"/>'</xsl:message>
   <xsl:if test="$navigationHead/identifying
                 and 
                 $navigationTail">  
      <xsl:variable name="etname" select="self::entity_type/name"/>
      <xsl:variable name="identifying_attributes" as="element(attribute)*">  
         <xsl:for-each select="key('EntityTypes',$navigationHead/type)">
            <xsl:call-template name="attributes_reqd_to_identify_from_ancestor">
               <xsl:with-param name="navigation" select="$navigationTail"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:variable>
     <xsl:for-each select="$identifying_attributes">
          <xsl:copy>
                <reached_by>
                    <join>
                       <component>
                            <src>
                                <xsl:value-of select="$etname"/>
                            </src>
                            <relSrc>
                                <xsl:value-of select="$navigationHead/parent::entity_type/name"/>
                            </relSrc>
                           <rel>
                              <xsl:value-of select="$navigationHead/name"/>
                           </rel>
                           <dest>
                              <xsl:value-of select="$navigationHead/type"/>
                          </dest>
                       </component>
                       <xsl:copy-of select="reached_by/join/*"/>
                    </join>
                </reached_by>
              <xsl:apply-templates select="*[not(self::reached_by)]"/>
          </xsl:copy>
     </xsl:for-each>
   </xsl:if>
</xsl:template>

<!-- Return the head relationship of a navigation or xxxxxx absolute.  
    In the case of the head being a dependency includes in 
     addition the identifying attribute of the inverse composition relationship   GET RID OF THIS CR-19159
-->
<xsl:template name="navigationHead" match ="entity_type" mode="explicit">
   <xsl:param name="navigation" as="element()?"/>  
    <xsl:choose>
    <xsl:when test="$navigation[self::theabsolute]">
        <xsl:sequence select="ancestor-or-self::entity_type/dependency[identifying]">  
              <!-- not sure what to do if more than one but select [idenntifying] cos only those relevant -->
        </xsl:sequence>
    </xsl:when>
    <xsl:otherwise>
       <xsl:variable name="navigationHeadRelName" >
          <xsl:call-template name="navigationHeadRelName">
              <xsl:with-param name="navigation"  select="$navigation"/>
          </xsl:call-template>
       </xsl:variable>
       <!--
       <xsl:message>in NavigationHead for rel '<xsl:value-of select="$navigationHeadRelName"/>' 
                           of entity type '<xsl:value-of select="name"/>' </xsl:message>
       -->
       <xsl:if test="not(root(current()))">
           <xsl:message terminate="yes"> current has no document root </xsl:message>
       </xsl:if>
        <!-- Much simplified  2nd June 2023 -->
        <xsl:sequence select="key('AllRelationshipBySrcTypeAndName',
                                       era:packArray((  name ,$navigationHeadRelName)))"/>
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="navigationHeadRelName" match="component|theabsolute|join" mode="explicit">
   <xsl:param name="navigation" as="element()?"/>  
      <!--<xsl:message>In navigationHeadRelName</xsl:message>-->
   <xsl:for-each select="$navigation">  <!-- remove training /* 04/05/2016 -->
      <!--<xsl:message>In navigationHeadRelName active</xsl:message>-->
      <xsl:choose>
         <xsl:when test="name()='component'">
             <xsl:value-of select="rel"/>
         </xsl:when>
         <xsl:when test="name()='join'">
             <xsl:value-of select="component[1]/rel"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes"> unexpected: node type <xsl:copy-of select="name()"/>
                          in <xsl:copy-of select="."/> 
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:for-each>
</xsl:template>

<xsl:template name="navigationTail" match="component|theabsolute|join" mode="explicit">
   <xsl:param name="navigation" as="element()?"/>
      <!--
      <xsl:message>In navigationTail '<xsl:copy-of select="$navigation"/>'</xsl:message>
      -->
   <xsl:for-each select="$navigation">
      <!--
      <xsl:message>In navigationTail active</xsl:message>
      -->
      <xsl:choose>
         <xsl:when test="name()='component'">
         </xsl:when>
         <xsl:when test="name()='theabsolute'">
            <xsl:sequence select="$navigation"/>       
         </xsl:when>
         <xsl:when test="name()='join'">
             <xsl:if test="count(component) &gt; 1">
                <xsl:copy>
                   <xsl:copy-of select="component[position() &gt; 1]"/>
                </xsl:copy>
             </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unexpected: node type <xsl:copy-of select="name()"/>
                          in <xsl:copy-of select="."/> 
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:for-each>
</xsl:template>

<xsl:template name="path_implementation" match="entity_type" mode="explicit">
   <xsl:param name="navigation" as="node()"/>
   
   <xsl:variable name="headRel" as="node()">    
      <xsl:call-template name="navigationHead">
          <xsl:with-param name="navigation" select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="navigationTail" as="element()?">
      <xsl:call-template name="navigationTail">
          <xsl:with-param name="navigation" select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="headRelNavigationTail" as="element()?">
     <xsl:for-each select="key('EntityTypes',$headRel/type)">
        <xsl:call-template name="navigationHead">
          <xsl:with-param name="navigation" select="$navigationTail"/>
       </xsl:call-template>
      </xsl:for-each>   
   </xsl:variable>
          <rdb_navigation>
<!-- earmark delete 
                <reltype><xsl:value-of select="$headRel/name()"/></reltype>
                <name><xsl:value-of select="$headRel/name"/> </name>
                <desttype><xsl:value-of select="$headRel/type"/></desttype> 
 end earmark -->
   <xsl:choose>
      <xsl:when test="not($headRelNavigationTail/identifying)">  
                <desttype><xsl:value-of select="$headRel/type"/></desttype>
            <xsl:for-each select="attribute[implementationOf/rel=$headRel/name]">
                 <where_component>
                    <srcattr><xsl:value-of select="name"/></srcattr>
                    <destAttr><xsl:value-of select="implementationOf/destAttr"/></destAttr>
                 </where_component>
            </xsl:for-each>
            <continues/>
      </xsl:when>
      <xsl:otherwise>
          <xsl:for-each select="key('EntityTypes',$headRel/type)">
             <xsl:variable name="implementing_attributes" as="element()*">
	         <xsl:call-template name="path_implementation">
                    <xsl:with-param name="navigation" select="$navigationTail"/>
                 </xsl:call-template>
             </xsl:variable>
             <xsl:variable name="prefixstem"
                           select="if($headRel[self::dependency]) 
                                   then ''
                                   else if (boolean($headRel/physical_prefix))
                                        then $headRel/physical_prefix
                                        else $headRel/name"/>
             <xsl:variable name="prefix"
                           select="if($prefixstem='')
                                   then ''
                                   else concat($prefixstem,$longSeparator)" />
             <xsl:for-each select="$implementing_attributes/rdb_navigation">
                 <xsl:copy-of select="destAttr"/>
                 <xsl:for-each select="where_component">
                      <where_component>
                          <srcattr><xsl:value-of select="concat($prefix,srcname)"/></srcattr>
                          <xsl:copy-of select="desttype"/>
                      </where_component>
                 </xsl:for-each>
             </xsl:for-each>   
          </xsl:for-each>   
      </xsl:otherwise>
   </xsl:choose>
          </rdb_navigation>
</xsl:template>

 
<xsl:template name="get_identifying_attributes" match="entity_type" mode="explicit">
   <xsl:param name="attr_nameprefix"/>
   <xsl:param name="implemented_rel_name"/>
   <xsl:param name="implemented_rel_type"/>
   <xsl:param name="is_identifying"/>
   <!--
<xsl:message> ############################## get_identifying_attributes #### at entity type <xsl:value-of select="name"/> </xsl:message>
<xsl:message>implemented_rel_name: '<xsl:value-of select="$implemented_rel_name"/>'</xsl:message>
   -->
   <xsl:for-each select="ancestor-or-self::entity_type/attribute[identifying]"> 
      <xsl:copy>
         <xsl:variable name="prefix" select="if(implementationOf) then '' 
                                           else concat($attr_nameprefix,$shortSeparator)"/>
         <xsl:element name="name">
            <xsl:value-of select="concat($prefix,name)"/>
         </xsl:element>
         <xsl:choose>
            <xsl:when test="$is_identifying='identifying'">
               <xsl:apply-templates 
                           select="*[not(self::name|self::implementationOf)]" 
                           mode="with_identifier"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates 
                           select="*[not(self::name|self::implementationOf)]" 
                           mode="without_identifier"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:element name="implementationOf">
            <xsl:element name="rel">
               <xsl:value-of select="$implemented_rel_name"/>
            </xsl:element>
            <xsl:element name="rel_type">
               <xsl:value-of select="$implemented_rel_type"/>
            </xsl:element>
        <!-- change  log ... 26 May 2023 -->
            <xsl:element name= "destAttrHostEt">
                <xsl:value-of select="../name"/>  <!-- 2 Jun 2023 -->
            </xsl:element>
         <!-- end 26 May 23-->
            <xsl:element name="destAttr">
               <xsl:value-of select="name"/>
            </xsl:element>
          </xsl:element>
      </xsl:copy>
   </xsl:for-each>
</xsl:template>

<xsl:template name="reinstantiate_attribute" match="attribute" mode="explicit"> 
   <xsl:param name="relationship" as="node()"/>

   <xsl:variable name="prefixstem"
                 select="if (boolean($relationship/physical_prefix))
                         then $relationship/physical_prefix
                         else $relationship/name"/>
   <xsl:variable name="relprefix"
                 select="if($prefixstem='')
                         then ''
                         else concat($prefixstem,$longSeparator)" />
   <xsl:variable name="prefix"
                 select="if (reached_by (:was cascaded:)) 
                         then let $reachedET := (reached_by/join/component)[last()]/dest
                              return
                              concat($relprefix, 
                                     $reachedET, 
                                     $shortSeparator 
                                    )
                         else $relprefix"/> 
   <xsl:variable name="is_identifying" select="$relationship/identifying/name()"/>
   <xsl:variable name="is_optional"
                 as="xs:boolean" 
                 select="$relationship/cardinality/ZeroOrOne or $relationship/cardinality/ZeroOneOrMore"/>
   <xsl:element name="attribute">           
      <xsl:element name="name">
   <!--      <xsl:value-of select="if ($style='hs') then $relationship/name else concat($prefix,name)"/> -->
             <xsl:value-of select="if (
                                        $style='hs' 
                                         and 
                                        not(implementationOf or reached_by (:was cascaded:) (: 26/06/2023 :) )
                                      ) 
                                   then $relationship/name 
                                   else concat($prefix,name)"/>
      </xsl:element>
      <xsl:choose>
         <xsl:when test="$is_identifying='identifying'">
            <xsl:apply-templates 
                       select="*[not(self::name|self::implementationOf|self::description
                                  | self::reached_by 
                                  | self::xmlRepresentation                      
                                  | self::destAttrHostEt | self::optional)]"
                       mode="with_identifier"/> 
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates 
                       select="*[not(self::name|self::implementationOf|self::description
                                  | self::reached_by
                                  | self::xmlRepresentation
                                  | self::destAttrHostEt |  self::optional)]" 
                       mode="without_identifier"/>  
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$is_optional">
         <xsl:element name="optional"/>
      </xsl:if>
      <xsl:element name="implementationOf">
         <xsl:element name="rel">
            <xsl:value-of select="$relationship/name"/>
         </xsl:element>
         <xsl:element name="rel_type">
            <xsl:value-of select="$relationship/type"/>
         </xsl:element>
         <xsl:element name="destAttr">
             <xsl:value-of select="name"/>
         </xsl:element>
         <!--   SEE CHANGELOG 26-May-2023  2-June-2023-->   
         <xsl:element name="destAttrHostEt">
             <xsl:value-of select="destAttrHostEt"/>
         </xsl:element>
         <xsl:copy-of select="reached_by"/>
      </xsl:element>
      <xsl:element name="description">
           This is the '<xsl:value-of select="name"/>' attribute
              of the related `<xsl:value-of select="$relationship/name"/> 
                    <xsl:text> </xsl:text>  <xsl:value-of select="$relationship/type"/>' (a foreign key
           to relationship 
           `<xsl:value-of select="$relationship/name"/>' : 
           <xsl:value-of select="../name"/> ----> <xsl:value-of select="$relationship/type"/>).
      </xsl:element>
   </xsl:element>
</xsl:template>


<xsl:template match="*[not(self::identifying)]" mode="without_identifier">
  <xsl:copy>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="identifying" mode="without_identifier">
</xsl:template>


<xsl:template match="*" mode="with_identifier">
  <xsl:copy>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- in the final physical pass:
     if style is hierarchical we remove the seqNo attributes 
     introduced in pass one.
-->


<xsl:template match="@*|*[ not(self::attribute) ]" 
              mode="final_physical_pass">                                        <!-- 16 August 2022 - UPGRADED to latest metamodel : value >>>  attribute -->
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="final_physical_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute" mode="final_physical_pass">                           <!-- 16 August 2022 - UPGRADED to latest metamodel : value >>>  attribute -->
   <xsl:if test="$style='r'
                 or not (name='seqNo')
                 or implementationOf
                ">    <!-- fixed this test in CR-18469 -->
     <xsl:copy>
       <xsl:apply-templates select="@*|node()" mode="final_physical_pass"/>
     </xsl:copy>
   </xsl:if>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.physical_enrichment.module.xslt--> 

