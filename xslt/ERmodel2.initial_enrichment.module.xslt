<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.initial_enrichment.module.xslt 
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
13-Oct-2017 J.Cartmell Refine scope display text. If subject reference 
                       relationship is mandatory display as equality (=) if not
                       display as less than or equal.
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
            identifier : string,   # see entity_type.identifier
            elementName : string   # xml element name - not necessarily unique

     entity_type => 
            identifier : string,  # based on name but syntactically 
                                  # an identifier whilst still being unique
            elementName : string, # xml element name - not necessarily unique
            parentType : string   # the pipe ('|') separated types 
                                  # from which there are incoming 
                                  # composition relationships

     composition|reference => 
            id:string             # a short id of form R<n> for some n

     reference =>
        scope_display_text : string r,;
                                 # text presentation of the scope constraint
                                 # using ~/<riser text>=<diag text>
        optional projection : entity ;
                                 # if the reference is specified as the 
                                 # projection_rel by a pullback. 
     projection => 
         host_type : string      # the source entity type of the pullback
                                 # composition relationship 
                                 # this is '' if absolute is the source
          

     dependency => optional identifying : ()
 

      navigation ::= identity | theabsolute | join | aggregate | component
      
      navigation =>
        src : string,           # the name of the source entity type
        dest : string,          # the name of the destination entity type
        display_text : string   # text presentation of the navigation using
                                #       / for join
                                #       . for the identity
                                #       ^ for the absolute

      join | component => identification_status : ('Identifying', 'NotIdentifying')

            
 DISCUSSION POINTS 
 (1) In future this first enrichment of a 
     logical entity model should complete missing detail inferred by 
     the model. Examples might be creating inverses to relationships,
     adding default cardinalities, creating composition relationships 
     from depndency relationships.
 (2) In future much of this can be generated from defintions of
     derived attributes in the meta-model ERmoidelERmodel.
    
CHANGE HISTORY
CR-18553 JC  19-Oct-2016 Created
CR-18123 JC  25-Oct-2016 Generalise the 'dest' enrichment to entity
                        type navigation. Remove mangleName attribute.
                        Add identifier attribute.
CR-18657 JC  7-Nov-2016 Add scope_display_text and display_text attributes
                        and guard first_pass attributes to make 
                        this enrichment idempotent.
CR18720 JC  16-Nov-2016 Use packArray function from ERmodel.functions.module.xslt
CR18708 JC  18-Nov-2016 Add projection entity for a reference relationship
                        that is specified as a projection_rel for a pullback.
                        This was previously implemented in ERmodel2.ts.xslt.
CR-19407 JC 20-Feb-2017 Creation of seqNo attributews moved out into physical entrichment pass.
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:template name="initial_enrichment">
   <xsl:param name="document"/>
   <xsl:variable name="current_state">
      <xsl:for-each select="$document">
         <xsl:copy>
             <xsl:apply-templates mode="initial_enrichment_first_pass"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
   </xsl:call-template>
</xsl:template>


<xsl:template name="initial_enrichment_recursive">
   <xsl:param name="interim"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
           <xsl:apply-templates mode="initial_enrichment_recursive"/>
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


<xsl:template match="*"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_model"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <!-- add prefixes for namespaces -->
    <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
    <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
    <xsl:namespace name="er-js" select="'http://www.entitymodelling.org/ERmodel/javascript'"/>  
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="absolute" mode="initial_enrichment_first_pass">
  <xsl:copy>
    <xsl:if test="not(identifier)">
       <identifier>
           <xsl:value-of select="replace(name,'\((\d)\)','_$1')"/>
       </identifier>
    </xsl:if>
    <xsl:if test="not(elementName)">
       <elementName>
          <xsl:value-of select="replace(name,'\(\d\)','')"/>
       </elementName>
    </xsl:if>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template name="compositionid" match="composition" mode="explicit">
    <xsl:if test="not(id)">
       <id>
          <xsl:text>D</xsl:text>  <!-- D for dependency -->
          <xsl:number count="composition" level="any" />
       </id>
    </xsl:if>
</xsl:template>

<xsl:template name="referenceid" match="reference" mode="explicit">
    <xsl:if test="not(id)">
       <id>
          <xsl:text>R</xsl:text>
          <xsl:number count="reference" level="any" />
       </id>
    </xsl:if>
</xsl:template>

<xsl:template match="composition" mode="initial_enrichment_first_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    <xsl:call-template name="compositionid"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="reference" mode="initial_enrichment_first_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    <xsl:call-template name="referenceid"/>
    <xsl:if test="not(projection) and key('IncomingCompositionRelationships', ../name)/pullback/projection_rel = name">
        <projection/>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:variable name="keywords" as="xs:string *">
   <xsl:sequence select="
          '', 'do', 'if', 'in', 'for', 'let', 'new', 'try', 'var', 'case',
          'else', 'enum', 'eval', 'null', 'this', 'true', 'void', 'with',
          'break', 'catch', 'class', 'const', 'false', 'super', 'throw',
          'while', 'yield', 'delete', 'export', 'import', 'public', 'return',
          'static', 'switch', 'typeof', 'default', 'extends', 'finally',
          'package', 'private', 'continue', 'debugger', 'function', 'arguments',
          'interface', 'protected', 'implements', 'instanceof'   "/>
</xsl:variable>

<xsl:template match="entity_type" mode="initial_enrichment_first_pass">
  <xsl:copy>
    <xsl:if test="not(identifier)">
       <identifier>
          <xsl:value-of select="translate(replace(name,'\((\d)\)','_$1'),
                                          ' ',
                                          '_'
                                         )
                               "/>
       </identifier>
    </xsl:if>
    <xsl:if test="not(elementName)">
       <elementName>
          <xsl:value-of select="translate(replace(name,'\(\d\)',''),
                                          ' ',
                                          '_'
                                         )
                               "/>
       </elementName>
    </xsl:if>
    <xsl:if test="not(parentType)">
<parentType> 
 <xsl:choose>
  <xsl:when test="boolean(ancestor-or-self::entity_type/dependency/type)">
   <xsl:value-of select="string-join(ancestor-or-self::entity_type/dependency/type,
                                     ' | ')"/>
   </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="string-join(key('IncomingCompositionRelationships',
                                       ancestor-or-self::entity_type/name)/../name,
                                     ' | ')"/>
  </xsl:otherwise>
 </xsl:choose>
</parentType>
    </xsl:if>
  <xsl:apply-templates mode="initial_enrichment_first_pass"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="dependency"
              mode="initial_enrichment_first_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    <xsl:if test="key('CompRelsByDestTypeAndInverseName',                   
                      era:packArray((../name,name)))/identifying">  
       <xsl:if test="not(identifier)">
          <identifying/>
       </xsl:if>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<!-- recursive step -->

<xsl:template match="*"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
  </xsl:copy>

</xsl:template>

<xsl:template match="entity_type"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="reference"
              mode="initial_enrichment_recursive"> 
  <xsl:copy>
     <xsl:apply-templates mode="initial_enrichment_recursive"/>
     <xsl:if test="not(scope_display_text) and riser/*/display_text and diagonal/*/display_text">
          <xsl:variable name="operator" select="if (cardinality/ZeroOrOne or cardinality=ZeroOneOrMore) then '=' else 'LTEQ'"/> 
                   <!-- 13-Oct-2017  'LTEQ' code will be translated by ERmodel2.svg.xslt -->
          <scope_display_text>
             <xsl:value-of select="concat('~/',riser/*/display_text,'=',diagonal/*/display_text)"/>
          </scope_display_text>
     </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="reference/projection" mode="initial_enrichment_recursive">
  <xsl:copy>
    <xsl:apply-templates mode="initial_enrichment_recursive"/>
    <xsl:if test="not(host_type)">
        <host_type>
            <xsl:for-each select="key('IncomingCompositionRelationships', ../../name)/..">
               <xsl:value-of select="if (self::absolute) then '' else name"/>
            </xsl:for-each>
        </host_type>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="identity" mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <xsl:if test="not(display_text)">
          <display_text>
             <xsl:value-of select="'.'"/>
          </display_text>
      </xsl:if>
      <xsl:if test="not(src)">
               <!-- copied from component  and simplified slightly-->
               <xsl:choose>
                  <xsl:when test="parent::along">
                     <src>
                        <xsl:value-of select="ancestor::entity_type/name"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="parent::riser2">
                     <src>
                        <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="parent::riser">
                     <src>
                        <xsl:value-of select="ancestor::reference[1]/type"/>
                     </src>
                  </xsl:when>
                  <xsl:otherwise>  <!-- diagonal or constructed relationship -->
                     <src>
                        <xsl:value-of select="ancestor::entity_type[1]/name"/>
                     </src>
                  </xsl:otherwise>
               </xsl:choose>
      </xsl:if>
      <xsl:if test="not(dest) and src">
           <dest>
              <xsl:value-of select="src"/>
           </dest>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute" mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <xsl:if test="not(display_text)">
          <display_text>
             <xsl:value-of select="'^'"/>
          </display_text>
      </xsl:if>
      <xsl:if test="not(src)">
               <!-- copied from identity  -->
               <xsl:choose>
                  <xsl:when test="parent::along">
                     <src>
                        <xsl:value-of select="ancestor::entity_type/name"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="parent::riser2">
                     <src>
                        <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="parent::riser">
                     <src>
                        <xsl:value-of select="ancestor::reference[1]/type"/>
                     </src>
                  </xsl:when>
                  <xsl:otherwise>  <!-- diagonal or constructed relationship -->
                     <src>
                        <xsl:value-of select="ancestor::entity_type[1]/name"/>
                     </src>
                  </xsl:otherwise>
               </xsl:choose>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="join" mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <xsl:if test="not(display_text) and (every $component in component satisfies boolean($component/display_text))">
         <display_text>
            <xsl:value-of select="string-join(component/display_text,'/')"/>
         </display_text>
      </xsl:if>
      <xsl:if test="not(src) and component[1]/src">
           <src>
                <xsl:value-of select="component[1]/src"/>
           </src>
      </xsl:if>
      <xsl:if test="not(dest)">
          <xsl:if test="component[last()]/dest">
             <dest>
                <xsl:value-of select="component[last()]/dest"/>
             </dest>
          </xsl:if>
      </xsl:if>
      <xsl:if test="not(identification_status) and (every $component in component satisfies boolean($component/identification_status))">
         <identification_status>
            <xsl:value-of select="if (every $component in component 
                                      satisfies ($component/identification_status = 'Identifying')
                                     )
                                  then 'Identifying'
                                  else 'NotIdentifying'
                                 "/>
         </identification_status>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="component" mode="initial_enrichment_recursive">
   <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
      <xsl:if test="not(display_text)">
          <display_text>
             <xsl:value-of select="rel"/>
          </display_text>
      </xsl:if>
      <xsl:if test="not(src)">
         <xsl:choose>
            <xsl:when test="not(preceding-sibling::component)">
               <xsl:choose>
                  <xsl:when test="ancestor::along">
                     <src>
                        <xsl:value-of select="ancestor::entity_type/name"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="ancestor::riser2">
                     <src>
                        <xsl:value-of select="(ancestor::pullback|ancestor::copy)/type"/>
                     </src>
                  </xsl:when>
                  <xsl:when test="ancestor::riser">
                     <src>
                        <xsl:value-of select="ancestor::reference[1]/type"/>
                     </src>
                  </xsl:when>
                  <xsl:otherwise>  <!-- diagonal or constructed relationship -->
                     <src>
                        <xsl:value-of select="ancestor::entity_type[1]/name"/>
                     </src>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="preceding-sibling::component[1]/dest">
               <src>
                  <xsl:value-of select="preceding-sibling::component[1]/dest"/>
               </src>
            </xsl:when>
         </xsl:choose>
      </xsl:if>
      <xsl:if test="not(dest) and src">
         <dest>
            <xsl:value-of select="key('AllRelationshipBySrcTypeAndName',
                                      era:packArray((src,rel)))
                                  /type"/>
         </dest>
      </xsl:if>
      <xsl:if test="not(identification_status) and src">
          <identification_status>   
              <xsl:value-of select="if(key('AllRelationshipBySrcTypeAndName',
                                            era:packArray((src,rel)))
                                       /identifying)
                                    then 'Identifying'
                                    else 'NotIdentifying'
                                   "/>  
          </identification_status>
      </xsl:if>
   </xsl:copy>
</xsl:template>


</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.initial_enrichment.module.xslt--> 

