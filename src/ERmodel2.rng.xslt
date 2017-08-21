<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.rng.xslt 
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

<xsl:transform version="2.0" xmlns="http://relaxng.org/ns/structure/1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >

<!--  MAINTENANCE BOX

CR-17916 JC 29-Jul-16 Modify not to generate an element for each reference relationship. 
CR-19099 JC 06-Jan-17 Add support for include directive - generate a description of include into the grammar.
CR-20100 JC 17-May-17 Support backward compatibility with ER models that 
                      predate logical2Physical including reference_compound_rules, 
                      task_configuration,jobsheets,MerckExperimentalXML.
                      Use 'name' attribute as a fallback from 'identifier'
                      or 'elementName'

-->

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

<xsl:template match="/entity_model">
  <grammar>
    <start>
       <ref>
          <xsl:attribute name="name">
            <xsl:value-of select="if (absolute/identifier) then absolute/identifier else absolute/name"/>
          </xsl:attribute>
       </ref>
    </start>
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
  <xsl:if test="count(.//entity_type/xmlRepresentation[text()='Anonymous']) > 1">
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
                    descendant-or-self::entity_type/xmlRepresentation[text()='Anonymous']) > 1">
        <xsl:message terminate="yes">
          More than one un-named child of entity '<xsl:value-of select="name"/>'
          has xmlRepresentation Anonymous 
        </xsl:message>
      </xsl:if>
     <xsl:if test="ancestor-or-self::entity_type/xmlRepresentation[1][text()='Anonymous'] 
                   and not(ancestor-or-self::entity_type/value/xmlRepresentation[text()='Anonymous'])">
        <xsl:message terminate="yes">
          Entity '<xsl:value-of select="name"/>' has xmlRepresentation Anonymous 
          and must have a single attribute with xmlRepresentation Anonymous
        </xsl:message>
      </xsl:if>
      <xsl:variable name="representation">
         <xsl:choose>
            <xsl:when test="xmlRepresentation">
               <xsl:value-of select="xmlRepresentation"/>
            </xsl:when>
            <xsl:otherwise>Element</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$representation = 'Anonymous'">
          <xsl:call-template name="attrs_and_rels_of_entity_type"/>
        </xsl:when>
        <xsl:otherwise>
          <element>
            <name>
                <xsl:value-of select="$elementName"/>
            </name>
            <xsl:choose>
<!-- CR-17916 
              <xsl:when test="count(ancestor-or-self::entity_type/(value|choice|reference|composition))=0 and count(value|choice|reference|composition)=0"> 
-->
              <xsl:when test="count(ancestor-or-self::entity_type/(value|choice|composition[not(transient)]))=0 and count(value|choice|composition[not(transient)])=0">  <!-- CR-18127 -->
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

        <!-- CR-19099 support include directive -->
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

        <xsl:if test="ancestor-or-self::entity_type/(value|choice)/
                      xmlRepresentation[text()='Anonymous'] and
                      count(ancestor-or-self::entity_type/(value|choice)) > 1">
          <xsl:message terminate="no">
            Entity '<xsl:value-of select="name"/>' has more than one attribute
            which is not allowed when an attribute has xmlRepresentation Anonymous 
          </xsl:message>
        </xsl:if>
        <xsl:for-each select="ancestor-or-self::entity_type/(value|choice)|(value|choice)">
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
    </interleave>
</xsl:template>

<xsl:template name="possibly_optional_comp_rel" match="composition">
  <xsl:choose>
    <xsl:when test="(cardinality = 'ZeroOrOne')or(cardinality = 'ZeroOneOrMore')">
      <optional>
         <xsl:call-template name="possibly_named_comp_rel"/>
      </optional>
    </xsl:when>
    <xsl:when test="(cardinality = 'ExactlyOne')or(cardinality = 'OneOrMore')">
         <xsl:call-template name="possibly_named_comp_rel"/>
    </xsl:when>
    <xsl:otherwise>
       Error in cardinality of composition relationship of entity type: 
          <xsl:value-of select="../name"/>
       of type 
          <xsl:value-of select="type"/>
       cardinality is:
          <xsl:value-of select="cardinality"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="possibly_named_comp_rel" match="composition">
  <xsl:if test="name">
    <element>
      <name>
        <xsl:value-of select="name"/>
      </name>
      <xsl:call-template name="possibly_multiple_comp_rel"/>
    </element>
  </xsl:if>
  <xsl:if test="not(name)">
    <xsl:call-template name="possibly_multiple_comp_rel"/>
  </xsl:if>
</xsl:template>

<xsl:template name="possibly_multiple_comp_rel" match="composition">
    <xsl:variable name="destinationDefinitionName">
          <xsl:value-of select="if (key('EntityTypes',type)/identifier) then key('EntityTypes',type)/identifier else key('EntityTypes',type)/name"/>
    </xsl:variable>
          <xsl:choose>
            <xsl:when test="(cardinality = 'ZeroOrOne') or (cardinality = 'ExactlyOne')">
                <ref>
                  <xsl:attribute name="name">
                    <xsl:value-of select="$destinationDefinitionName"/>
                  </xsl:attribute>
                </ref>
            </xsl:when>
            <xsl:when test="(cardinality = 'ZeroOneOrMore')or(cardinality = 'OneOrMore')">
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

<xsl:template name="mand_attribute" match="value|choice">
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
  <xsl:choose>
    <xsl:when test="name()='value'">
       <data>
         <xsl:attribute name="type">
           <xsl:value-of select="type"/>
         </xsl:attribute>
         <xsl:attribute name="datatypeLibrary">http://www.w3.org/2001/XMLSchema-datatypes</xsl:attribute>
       </data>
    </xsl:when>
    <xsl:when test="name()='choice'">
       <xsl:variable name="enumeration_type_name" select="from" />
       <choice>
          <xsl:for-each select="key('Enumeration',$enumeration_type_name)/enumeration_value">
            <value> <xsl:value-of select="."/> </value>
          </xsl:for-each>
       </choice>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="singular_entity_type" match="entity_type">
    <xsl:for-each select="ancestor-or-self::entity_type/value">
      <data>
        <xsl:attribute name="type">
          <xsl:value-of select="type"/>
        </xsl:attribute>
        <xsl:attribute name="datatypeLibrary">http://www.w3.org/2001/XMLSchema-datatypes</xsl:attribute>
      </data>
    </xsl:for-each>
</xsl:template>

</xsl:transform>

<!-- end of file: ERmodel_v1.2/src/ERmodel2.rng.xslt--> 

