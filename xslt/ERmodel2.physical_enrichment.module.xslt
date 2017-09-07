<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.physical_enrichment.module.xslt 
****************************************************************

Copyright 2016, 2107 Cyprotex Discovery Ltd.

This file is part of the the ERmodel suite of models and transforms.

The ERmodel suite is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ERmodel suite is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
****************************************************************
-->

<!--

****************************************
ERmodel2.physical_enrichment.module.xslt
****************************************


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
      If the incoming relationship have the identifying indicator then
      the implied seqNo atribute is identifying.
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
      uncertainty of namespace for 'value' elements in a number of
      places and would need not propogate name space when foreign
      keys are created.

  (4) KE001 NOT YET IMPLEMENTED: Support for reference 
      relationships whose scope is absolute and for which 
      destination entity type has an identifying 
      incoming composition relationship. Example of such 
      is in catalogue A1fA2B1gB2unconstrained.hierarchical.svg. 
      To implement support for these need to resursively walk 
      up the composition structure that is implied by "theabsolute". 
      The thought process of implmenting support for these absolute 
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

-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:variable name="compound_name_separator">
   <xsl:value-of select="'_'"/>
</xsl:variable>


<xsl:template name="physical_enrichment">
   <xsl:param name="document"/>
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
      <xsl:for-each select="$state">
         <xsl:call-template name="recursive_physical_pass">
            <xsl:with-param name="interim">
               <xsl:copy>
                  <xsl:apply-templates/>
               </xsl:copy>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
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

            

<xsl:template match="*" mode="first_physical_pass">
  <xsl:copy>
     <xsl:apply-templates mode="first_physical_pass"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="first_physical_pass">
  <xsl:copy>
     <xsl:apply-templates mode="first_physical_pass"/>
     <xsl:variable name="has_identifiers" as="xs:boolean">
       <xsl:value-of select="boolean((reference|value|choice)/identifying)" />  
     </xsl:variable>
     <xsl:for-each select="key('IncomingCompositionRelationships',name)">
       <xsl:if test="sequence">
          <xsl:if test="not(value[name='seqNo'])">
             <value>
                <name>seqNo</name>
                <type>integer</type>
                <for_sequence/>
                <xsl:if test="identifying and not($has_identifiers)">
                     <identifying/>
                </xsl:if>
             </value>
          </xsl:if>
       </xsl:if>
     </xsl:for-each>
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

<xsl:template match="*" mode="recursive_physical_enrichment">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_physical_enrichment"/>
    </xsl:copy>
</xsl:template>

<xsl:function name="era:et_is_implemented" as="xs:boolean">
  <xsl:param name="root" as="node()"/>
  <xsl:param name="et_name"/>
      <!-- need set some context -->
  
  <!-- no unimplemented outgoing identifying reference relationships 
       and has no unimplemented incoming identifying 
           composition relationships 
  -->
  <!-- <xsl:message>Entering <xsl:value-of select="$et_name"/> </xsl:message>
       <xsl:message>tring-length of $et_name is '<xsl:value-of select="string-length($et_name)"/></xsl:message>
  -->
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
     <xsl:value-of select="
        not(reference[identifying
                      and not(key('whereImplemented',
                                  era:packArray(($nonempty_et_name,name))
                                 )
                             )
                     ]
           )
        and 
          (((($style='h' or $style='hs') and (not(boolean(dependency)) or
                               era:et_is_implemented($root, dependency/type) 
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
                            "/>         <!-- CR-18469  and not (../name='ansolute') -->
   </xsl:for-each>
   </xsl:for-each>
<xsl:message>Leaving <xsl:value-of select="$et_name"/> </xsl:message>
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
                <xsl:variable name="is_identifying" select="identifying/name()"/>
                <xsl:for-each select="..">  
                   <!-- @ source entity type of the composition relationship -->
                   <xsl:call-template name="get_identifying_attributes">
                        <xsl:with-param name="attr_nameprefix" 
                                        select="name"/>
                        <xsl:with-param name="implemented_rel_name" 
                                        select="$dependencyname"/>
                        <xsl:with-param name="is_identifying" 
                                        select="$is_identifying"/>   
                   </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
          </xsl:if>
       </xsl:for-each>
    </xsl:if>
    <!-- copy identifying attributes --> 
    <xsl:apply-templates select="value[identifying]"/>

    <!-- add implementing attributes for reference relationships which are single valued-->
    <!-- though could be single valued on each side (noted as issue as at 18-Oct-2016 (JC)) -->
    <xsl:for-each select="reference[ (cardinality = 'ZeroOrOne' or cardinality='ExactlyOne')
                                    and not(key('whereImplemented',
                                            era:packArray((../name,name))))
                                    and not(key)             
                                    ]">     <!-- simplifying assumption that key covers missing identifiers subject to future generalisation -->
                <!-- @ reference relationship that is not already implemented-->
      <xsl:if test="era:et_is_implemented(root(),type)">
         <!--
         <xsl:message>Imp. R'<xsl:value-of select="name"/>'</xsl:message>
          -->
         <xsl:variable name="relationship" 
                       as="element()" select="."/> 
         <xsl:variable name="implementing_attributes" 
                       as="element(value)*" >
           <xsl:for-each select="key('EntityTypes',type)">
             <xsl:call-template name="attributes_reqd_to_identify_from_ancestor">
               <xsl:with-param name="navigation" select="$relationship/riser/*"/>
               <xsl:with-param name="reentry" select="false()"/>
             </xsl:call-template>
           </xsl:for-each>
         </xsl:variable>
         <xsl:for-each select="$implementing_attributes"> 
            <xsl:call-template name="reinstantiate_attribute">
               <xsl:with-param name="relationship" select="$relationship"/>
            </xsl:call-template>
         </xsl:for-each>
         <!--<xsl:message>END Imp. R'<xsl:value-of select="name"/>'</xsl:message>-->
      </xsl:if>
    </xsl:for-each>
   
    <!-- copy remaining substructure --> 
    <xsl:apply-templates 
               select="*[not(self::value[identifying]) 
                         and not(self::name) 
                         and not (self::presentation)]"
                mode="recursive_physical_enrichment"/>
  </xsl:copy>
  <!-- <xsl:message> END ENTITY TYPE <xsl:value-of select="name"/> </xsl:message> -->
</xsl:template>

<xsl:template name="attributes_reqd_to_identify_from_ancestor" 
              match="entity_type" 
              mode="explicit">
   <xsl:param name="navigation" as="element()?"/>
   <xsl:param name="reentry" as="xs:boolean"/>

   <!--all natural identifying attributes 
       and all referential identifying attributes 
             that implement reference relationships
   -->
   <!-- 10/05/2016
   <xsl:copy-of select="value[identifying and 
   -->
   <!--
   <xsl:sequence select="value[identifying and 
                               (not(implementationOf) or
                               key('RelationshipBySrcTypeAndName',
                                   concat(../name ,':',implementationOf/rel)
                                  )[self::reference]
                               )
                              ]"/>
    -->
    <xsl:for-each select="ancestor-or-self::entity_type/value[identifying and 
                               (not(implementationOf) or
                               key('RelationshipBySrcTypeAndName',
                                   era:packArray((../name ,implementationOf/rel))
                                  )[self::reference]
                               )
                              ]">   <!--CR-18059 -->
         <xsl:copy>
            <xsl:element name="typeOfOrigin">
                  <xsl:value-of select="../name"/>
            </xsl:element>
            <xsl:element name="attrOfOrigin">
                  <xsl:value-of select="name"/>
            </xsl:element>
            <xsl:apply-templates select="*[not(self::typeOfOrigin|self::attrOfOrigin)]"/>   <!-- maybe name of these attrs wrong since only local origin -->
         </xsl:copy>
    </xsl:for-each>

   <!-- all attributes of destination of navigationHead 
          local to navigationTail 
    -->
   <xsl:variable name="navigationHead" as="node()?">
      <xsl:call-template name="navigationHead">
          <xsl:with-param name="navigation"  select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="navigationTail" as="element()?">
      <xsl:call-template name="navigationTail">
          <xsl:with-param name="navigation" select="$navigation"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:if test="$navigationHead/identifying
                 and 
                 $navigationTail">  
      <!--
      <xsl:message>NavigationHead type '<xsl:value-of select="$navigationHead/type"/>'</xsl:message>
      -->
      <xsl:variable name="identifying_attributes" as="element(value)*">
         <xsl:for-each select="key('EntityTypes',$navigationHead/type)">
            <xsl:call-template name="attributes_reqd_to_identify_from_ancestor">
               <xsl:with-param name="navigation" select="$navigationTail"/>
               <xsl:with-param name="reentry" select="true()"/>   <!-- this isn't what is was needed - take it out -->
            </xsl:call-template>
         </xsl:for-each>
      </xsl:variable>
     <xsl:for-each select="$identifying_attributes">
          <xsl:copy>
              <xsl:apply-templates/>
               <cascaded/>
          </xsl:copy>
     </xsl:for-each>
   </xsl:if>
</xsl:template>

<!-- Return the head relationship of a navigation or nothing if a navigation 
     to absolute.  In the case of the head being a dependency includes in 
     addition the identifying attribute of the inverse composition relationship   GET RID OF THIS CR-19159
-->
<xsl:template name="navigationHead" match ="entity_type" mode="explicit">
   <xsl:param name="navigation" as="element()?"/>  
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
   
   <xsl:if test="not($navigationHeadRelName = '')">
      <xsl:if test="not(key('AllRelationshipBySrcTypeAndName',
                        era:packArray((  name ,$navigationHeadRelName)),root(current()))
                       )">   <!-- CR-18059 -->
         <xsl:message> 
                 ***********************************************
                 ERROR: no relationship named 
                   '<xsl:value-of select="$navigationHeadRelName"/>' 
                   from entity type 
                   '<xsl:value-of select="name"/>'
                 ***********************************************
         </xsl:message>
      </xsl:if>
      <xsl:for-each select="key('AllRelationshipBySrcTypeAndName',
                                   era:packArray((  name ,$navigationHeadRelName)))">
                                                                <!-- CR-18059 -->
         <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="name()='dependency'">
               <!--<xsl:message>Found dependency <xsl:value-of select="concat(  ../name ,':',$navigationHeadRelName)"/></xsl:message>-->
               <xsl:if test="not(key('CompRelsByDestTypeAndInverseName',
                                     era:packArray((  ../name ,$navigationHeadRelName)))
                            )">
                     <xsl:message>
                 ***********************************************
                 ERROR: no inverse found for dependency relationship named 
                   '<xsl:value-of select="$navigationHeadRelName"/>' 
                   from entity type 
                   '<xsl:value-of select="name"/>'
                 ***********************************************
                     </xsl:message>
               </xsl:if>
                   
               <!-- 25 October 2016 get rid of this as part of CR-18159 -->
               <xsl:copy-of select="key('CompRelsByDestTypeAndInverseName',
                     era:packArray((  ../name ,$navigationHeadRelName)))/identifying"/>
            </xsl:if>
         </xsl:copy>
      </xsl:for-each>
   </xsl:if>
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
         <xsl:when test="name()='theabsolute'">
         </xsl:when>
         <xsl:when test="name()='join'">
             <xsl:value-of select="component[1]/rel"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unexpected: node type <xsl:copy-of select="name()"/>
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
            <xsl:for-each select="value[implementationOf/rel=$headRel/name]">
                 <where_component>
                    <srcattr><xsl:value-of select="name"/></srcattr>
                    <destattr><xsl:value-of select="implementationOf/destattr"/></destattr>
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
                                   else concat($prefixstem,$compound_name_separator)" />
             <xsl:for-each select="$implementing_attributes/rdb_navigation">
                 <xsl:copy-of select="destattr"/>
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
   <xsl:param name="is_identifying"/>
   <!--
<xsl:message> ############################## get_identifying_attributes #### at entity type <xsl:value-of select="name"/> </xsl:message>
<xsl:message>implemented_rel_name: '<xsl:value-of select="$implemented_rel_name"/>'</xsl:message>
   -->
   <xsl:for-each select="ancestor-or-self::entity_type/value[identifying]">   <!-- CR-18059 -->
      <xsl:copy>
         <xsl:variable name="prefix" select="if(implementationOf) then '' 
                                           else concat($attr_nameprefix,$compound_name_separator)"/>
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
            <xsl:element name= "origin">
                 <xsl:choose>
                   <xsl:when test="implementationOf">
                      <xsl:value-of select="implementationOf/origin"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="name"/>
                   </xsl:otherwise>
                 </xsl:choose>
            </xsl:element>
            <xsl:element name="destattr">
               <xsl:value-of select="name"/>
            </xsl:element>
          </xsl:element>
      </xsl:copy>
   </xsl:for-each>
</xsl:template>

<xsl:template name="reinstantiate_attribute" match="value" mode="explicit">
   <xsl:param name="relationship" as="node()"/>

   <xsl:variable name="prefixstem"
                 select="if (boolean($relationship/physical_prefix))
                         then $relationship/physical_prefix
                         else $relationship/name"/>
   <xsl:variable name="relprefix"
                 select="if($prefixstem='')
                         then ''
                         else concat($prefixstem,$compound_name_separator)" />
   <xsl:variable name="prefix"
                 select="if (cascaded) 
                         then concat($relprefix,typeOfOrigin,$compound_name_separator)
                         else $relprefix"/>
   <xsl:variable name="relname" select="$relationship/name"/>
   <xsl:variable name="is_identifying" select="$relationship/identifying/name()"/>
   <xsl:variable as="xs:boolean" name="is_optional" select="$relationship/cardinality='ZeroOrOne' or $relationship/cardinality='ZeroOneOrMore'"/>

   <xsl:element name="value">
      <xsl:element name="name">
         <xsl:value-of select="if ($style='hs') then $relname else concat($prefix,name)"/>
      </xsl:element>
      <xsl:choose>
         <xsl:when test="$is_identifying='identifying'">
            <xsl:apply-templates 
                       select="*[not(self::name|self::implementationOf|self::description|self::cascaded|self::xmlRepresentation)]" 
                       mode="with_identifier"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates 
                       select="*[not(self::name|self::implementationOf|self::description|self::cascaded|self::xmlRepresentation)]" 
                       mode="without_identifier"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$is_optional">
         <xsl:element name="optional"/>
      </xsl:if>
      <xsl:element name="implementationOf">
         <!-- CR-18497: consider including relid here -->
         <xsl:element name="rel">
            <xsl:value-of select="$relname"/>
         </xsl:element>
         <xsl:element name="destattr">
             <xsl:value-of select="name"/>
         </xsl:element>
         <xsl:element name="typeOfOrigin">
             <xsl:value-of select="typeOfOrigin"/>
         </xsl:element>
         <xsl:element name="attrOfOrigin">
             <xsl:value-of select="attrOfOrigin"/>
         </xsl:element>
      </xsl:element>
      <xsl:element name="description">
           This is the '<xsl:value-of select="name"/>' attribute
              of the related `<xsl:value-of select="$relname"/> 
                    <xsl:text> </xsl:text>  <xsl:value-of select="$relationship/type"/>' (a foreign key
           to relationship 
           `<xsl:value-of select="$relname"/>' : 
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


<xsl:template match="*[ not(self::value) ]" 
              mode="final_physical_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="final_physical_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="value" mode="final_physical_pass">
   <xsl:if test="$style='r'
                 or not (name='seqNo')
                 or implementationOf
                ">    <!-- fixed this test in CR-18469 -->
     <xsl:copy>
       <xsl:apply-templates mode="final_physical_pass"/>
     </xsl:copy>
   </xsl:if>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.physical_enrichment.module.xslt--> 

