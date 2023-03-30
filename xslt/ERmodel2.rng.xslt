<!-- 
****************************************************************
ERmodel2.rng.xslt 
****************************************************************
-->

<xsl:transform version="2.0" xmlns="http://relaxng.org/ns/structure/1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >

<!--  MAINTENANCE BOX

23-Mar-2023 Upgrade to support v1.6 modelling langauge.
24-Mar-2023 Upgraded to support composition relationships with anonymous representation in xml and
             which are therefore positional. Motiivating example want to model a binary operation as having two 
            expressions as substructure. If I call tham arg1 and arg2 then my ASN then has arg1 and arg2 to 
            distinguish the two arguments. But i don't want to do this. It turns out that because of
            Loguical2physical if i model two idetical compsotion realionships then one gets lost coming through 
            to the physical model and to the generated rng. If I manually reinsert the missing compsotion
            relationships then the generated rng is invaid because all substructure currently specified embedded withuin interleave.
            I have added a bit of logic to spot and compsotion relationship with an xmlRepresentation of anonymous
            and in thsi case to plant the defintion anonymised (even though comp rel is named) and to group substructure so
            that not interleaved. This doesn't feel like the end of this story but I will see how i progress from here.
            I am probably going to have conflicts between order of composition rels and attributes arriving from inheritance and the
            order produced in the intermediate tree from the parser (and the language syntax). Maybe the answer will
            be to enable the position of each attribute and or compsotion relationship to be specified and to use this orer in generation of
            rng. Again inheritance may mean that it is not possible to assign the position on the definition on an abstrcat type.
            If this is so will need be more like a priority or a precedence that is to be ordered by. PHEW. 
  25-Mar-2023 Need upgrade to support entity types having xmlRepresentation 'Anononymous' and singleton compsotion relationship.
             This enables me to support multiple inheritance in xml by having something like:
                  X ::= T(1) 'Anonymous' | other
                  Y ::= T(2) 'Anonymous' | other 

                  T(1) => :T
                  T(2) => :T

                  T ::= A | B | | C or whatever 
                  and/or 
                  T => a,b,c or whatever

              to represent type T inheriting from both X and Y.

              Need this for type KindTest in the xpath grammar/ er model. 
  18-Mar-2023 Just notice that meta model shows subtypes <Aninymous> and <Element> as value of a composition xmLRepresentation.
              And that this code here has xmlRepresentation as a string valued attribute. Since in my xpath model I followed the metamodel and coded xmlREpresentation as a composition relationship I have modifed the code here to support both formats for the xmlRepresenation
              of an entity type. I was going to add that not clear with 1.6 what the best version is but thinking about the big picture with parsing and intermediate code then it is clear that the composition relationship version is decent way to go.
-->

<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="ERmodelv1.6.parser.module.xslt"/>

<xsl:key name="Enumeration" match="enumeration_type" use="name"/>
<xsl:key name="EntityTypes" 
         match="entity_type|group" 
         use="name"/>
<xsl:key name="whereImplemented" 
         match="implementationOf"
         use="concat(../../name,':',rel)"/>


<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes"/>

<xsl:variable name="defaultAttributeRepresentation">
  <xsl:choose>
     <xsl:when test="/entity_model/xml/attributeDefault">
        <xsl:value-of select="/entity_model/xml/attributeDefault"/>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="'Element'"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="/">
   <xsl:variable name="state" as="document-node()">
       <xsl:choose>
         <xsl:when test="entity_model/@ERScriptVersion='1.6'">
            <xsl:copy>
               <xsl:apply-templates select="." mode="parse__conditional"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
               <xsl:copy-of select="."/> 
          </xsl:otherwise>
       </xsl:choose>
   </xsl:variable>
   <!-- debug <xsl:copy-of select="$state"/> -->
   <xsl:apply-templates select="$state/entity_model"/>
 </xsl:template>


<xsl:template match="/entity_model">
  <grammar>
    <start>
       <ref>
          <xsl:attribute name="name">
            <xsl:value-of select="if (absolute/identifier) then absolute/identifier else absolute/name"/>
          </xsl:attribute>
       </ref>
    </start>
    <!--  support include directive -->
    <define name="optionalIncludes">
        <optional>
           <oneOrMore>
              <element>
                 <name>include</name>
                    <element>
                       <name>filename</name>
                       <data type="string"
                          datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes"/>
                    </element>
                    <optional>
                       <element>
                          <name>type</name>
                          <data type="string"
                             datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes"/>
                       </element>
                    </optional>
              </element>
           </oneOrMore>
        </optional>
    </define>
    <xsl:for-each select="absolute">
       <xsl:call-template name="absolute"/>
    </xsl:for-each>
    <xsl:for-each select="//entity_type">
       <xsl:call-template name="entityType"/>
    </xsl:for-each>
  </grammar>
</xsl:template>

<xsl:template name="absolute" match="absolute">
  <xsl:variable name="elementName">
     <xsl:value-of select="if (elementName) then elementName else name"/>
  </xsl:variable>
  <define>
    <xsl:attribute name="name">
      <xsl:value-of select="$elementName"/>
    </xsl:attribute>
    <xsl:if test= "name='entity_model'">
       <xsl:attribute name="ns">
         <xsl:value-of select="'http://www.entitymodelling.org/ERmodel'"/>
       </xsl:attribute>
    </xsl:if>
    <element>
      <name>
        <xsl:value-of select="$elementName"/>
      </name>
      <xsl:call-template name="attrs_and_rels_of_entity_type"/>
    </element>
  </define>
</xsl:template>


<xsl:template name="entityType" match="entity_type">
  <xsl:variable name="definitionName">
     <xsl:value-of select="if (identifier) then identifier else name"/>
  </xsl:variable>
  <xsl:variable name="elementName">
     <xsl:value-of select="if (elementName) then elementName else name"/>
  </xsl:variable>
  <xsl:if test="count(.//entity_type/xmlRepresentation[text()='Anonymous'
                                                        or child::Anonymous]) > 1">
    <xsl:message terminate="yes">
      More than one subtype of entity '<xsl:value-of select="name"/>'
      has xmlRepresentation Anonymous
    </xsl:message>
  </xsl:if>
  <define>
    <xsl:attribute name="name">
      <xsl:value-of select="$definitionName"/>
    </xsl:attribute>
    <xsl:if test= "/entity_model/absolute/name='entity_model'">
       <xsl:attribute name="ns">
         <xsl:value-of select="'http://www.entitymodelling.org/ERmodel'"/>
       </xsl:attribute>
    </xsl:if>
    <xsl:if test="entity_type|group/entity_type">
      <choice>
        <xsl:for-each select="entity_type|group/entity_type">
          <ref>
            <xsl:attribute name="name">
              <xsl:value-of select="if (identifier) then identifier else name"/>
            </xsl:attribute>
          </ref>
        </xsl:for-each>
      </choice>
    </xsl:if>
    <xsl:if test="not(entity_type)">
      <xsl:if test="count(key('EntityTypes', composition[not(name)]/type)/
                    descendant-or-self::entity_type/xmlRepresentation[text()='Anonymous'
                                                                          or child::Anonymous]) > 1">
        <xsl:message terminate="yes">
          More than one un-named child of entity '<xsl:value-of select="name"/>'
          has xmlRepresentation Anonymous 
        </xsl:message>
      </xsl:if>
      <!-- This test is too stringent. Comment out.  25-March-2023 (See maintainance notes top of file). 
     <xsl:if test="ancestor-or-self::entity_type/xmlRepresentation[1][text()='Anonymous'] 
                   and not(ancestor-or-self::entity_type/attribute/xmlRepresentation[text()='Anonymous'])">
        <xsl:message terminate="yes">
          Entity '<xsl:value-of select="name"/>' has xmlRepresentation Anonymous 
          and must have a single attribute with xmlRepresentation Anonymous
        </xsl:message>
      </xsl:if>
    -->
      <xsl:variable name="representation">
         <xsl:choose>
            <xsl:when test="xmlRepresentation">
               <xsl:value-of select="xmlRepresentation"/>
            </xsl:when>
            <xsl:otherwise>Element</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$representation = 'Anonymous' or xmlRepresentation[child::Anonymous]">
          <xsl:call-template name="attrs_and_rels_of_entity_type"/>
        </xsl:when>
        <xsl:otherwise>
          <element>
            <name>
                <xsl:value-of select="$elementName"/>
            </name>
            <xsl:choose>
<!-- CR-17916 
              <xsl:when test="count(ancestor-or-self::entity_type/(attribute|reference|composition))=0 and count(attribute|reference|composition)=0"> 
-->
              <xsl:when test="count(ancestor-or-self::entity_type/(attribute|composition[not(transient)]))=0 and count(attribute|composition[not(transient)])=0">  <!-- CR-18127 -->
                 <empty/>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:call-template name="attrs_and_rels_of_entity_type"/>
              </xsl:otherwise>
            </xsl:choose>
          </element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </define>
</xsl:template>

<xsl:template name="attrs_and_rels_of_entity_type" match="entity_type|absolute">
    <interleave>
      <xsl:if test="not(xmlRepresentation='Anonymous' or child::Anonymous)">
        <ref name="optionalIncludes"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="exists(ancestor-or-self::entity_type/composition[xmlRepresentation='Anonymous'])">
          <group>
            <xsl:call-template name="attrs_and_rels_of_entity_type_core_definitions"/>
          </group>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="attrs_and_rels_of_entity_type_core_definitions"/>
        </xsl:otherwise>
      </xsl:choose>
    </interleave>
</xsl:template>

<xsl:template name="attrs_and_rels_of_entity_type_core_definitions" match="entity_type|absolute">
        <xsl:if test="ancestor-or-self::entity_type/attribute/
                      xmlRepresentation[text()='Anonymous' or child::Anonymous] and
                      count(ancestor-or-self::entity_type/attribute) > 1">
          <xsl:message terminate="no">
            Entity '<xsl:value-of select="name"/>' has more than one attribute
            which is not allowed when an attribute has xmlRepresentation Anonymous 
          </xsl:message>
        </xsl:if>
        <xsl:for-each select="ancestor-or-self::entity_type/attribute|attribute">
          <xsl:if test="optional">
            <optional>
              <xsl:call-template name="mand_attribute"/>
            </optional>
          </xsl:if>
          <xsl:if test="not(optional)">
            <xsl:call-template name="mand_attribute"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="ancestor-or-self::entity_type/composition[not(transient)]|composition[not(transient)]">   <!-- CR-18127 -->
            <xsl:call-template name="possibly_optional_comp_rel"/>
        </xsl:for-each>
</xsl:template>

<xsl:template name="possibly_optional_comp_rel" match="composition">
  <xsl:choose>
    <xsl:when test=" cardinality/ZeroOrOne or cardinality/ZeroOneOrMore ">
      <optional>
         <xsl:call-template name="possibly_named_comp_rel"/>
      </optional>
    </xsl:when>
    <xsl:when test=" cardinality/ExactlyOne or cardinality/OneOrMore ">
         <xsl:call-template name="possibly_named_comp_rel"/>
    </xsl:when>
    <xsl:otherwise>
       Error in cardinality of composition relationship of entity type: 
          <xsl:value-of select="../name"/>
       of type 
          <xsl:value-of select="type"/>
       cardinality is:
          <xsl:value-of select="cardinality/name()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="possibly_named_comp_rel" match="composition">
  <xsl:choose>
  <xsl:when test="exists(name) and not(xmlRepresentation ='Anonymous')">
    <element>
      <name>
        <xsl:value-of select="name"/>
      </name>
      <xsl:call-template name="possibly_multiple_comp_rel"/>
    </element>
  </xsl:when>
  <xsl:otherwise> 
    <xsl:call-template name="possibly_multiple_comp_rel"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="possibly_multiple_comp_rel" match="composition">
    <xsl:variable name="destinationDefinitionName">
          <xsl:value-of select="if (key('EntityTypes',type)/identifier) then key('EntityTypes',type)/identifier else key('EntityTypes',type)/name"/>
    </xsl:variable>
          <xsl:choose>
            <xsl:when test=" cardinality/ZeroOrOne  or  cardinality/ExactlyOne ">
                <ref>
                  <xsl:attribute name="name">
                    <xsl:value-of select="$destinationDefinitionName"/>
                  </xsl:attribute>
                </ref>
            </xsl:when>
            <xsl:when test=" cardinality/ZeroOneOrMore or cardinality/OneOrMore ">
                <oneOrMore>
                  <ref>
                    <xsl:attribute name="name">
                      <xsl:value-of select="$destinationDefinitionName"/>
                    </xsl:attribute>
                  </ref>
                </oneOrMore>
            </xsl:when>
          </xsl:choose>
</xsl:template>

<xsl:template name="mand_attribute" match="attribute">
  <xsl:variable name="representation">
     <xsl:choose>
        <xsl:when test="xmlRepresentation">
           <xsl:value-of select="xmlRepresentation"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:value-of select="$defaultAttributeRepresentation"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$representation='Anonymous'">
      <!-- We'd like to use the following but Relax-NG can't handle
           data definitions in interleave so we are forced to use <text/>.
        <xsl:call-template name="attribute_body"/> -->  
      <text/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="element_name" select="if ($representation='Element') then 'element' 
                                                else if ($representation='Attribute') then 'attribute' 
                                                else 'ERROR'"/>
      <xsl:element name="{$element_name}">
        <name>
          <xsl:value-of select="name"/>
        </name>
        <xsl:call-template name="attribute_body"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="attribute_body">
       <data>
         <xsl:attribute name="type">
           <xsl:value-of select="type/*/name()"/>
         </xsl:attribute>
         <xsl:attribute name="datatypeLibrary">http://www.w3.org/2001/XMLSchema-datatypes</xsl:attribute>
       </data>
</xsl:template>

<xsl:template name="singular_entity_type" match="entity_type">
    <xsl:for-each select="ancestor-or-self::entity_type/attribute">
      <data>
        <xsl:attribute name="type">
          <xsl:value-of select="type/*/name()"/>
        </xsl:attribute>
        <xsl:attribute name="datatypeLibrary">http://www.w3.org/2001/XMLSchema-datatypes</xsl:attribute>
      </data>
    </xsl:for-each>
</xsl:template>

</xsl:transform>



