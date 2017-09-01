<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.py.xslt 
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

<?xml version="1.0" encoding="UTF-8"?>

<!--
     CR-17018 Modify so that support for protocol buffers is optional and doesn't occur by default.
     CR-17022 Support different xml representations of attributes.
              Add to name mangling so that covers attributes whoose names are python keywords (reimplment as initial_pass).
-->

<xsl:transform version="2.0" 
      xmlns="http://www.entitymodelling.org/ERmodel"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:era="http://www.entitymodelling.org/ERmodel"
      xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:key name="Enumeration" match="enumeration_type" use="name"/>

<xsl:key name="EntityTypes" match="entity_type" use="name"/>

<xsl:param name="protocolbuffer"/>


<xsl:output method="text" indent="no"/>
<xsl:template name="newline">
  <xsl:text>&#xA;</xsl:text>
</xsl:template>
<xsl:template name="newlineindent2">
  <xsl:text>&#xA;  </xsl:text>
</xsl:template>
<xsl:template name="newlineindent4">
  <xsl:text>&#xA;    </xsl:text>
</xsl:template>
<xsl:template name="newlineindent6">
  <xsl:text>&#xA;      </xsl:text>
</xsl:template>
<xsl:template name="indent4">
  <xsl:text>    </xsl:text>
</xsl:template>
<xsl:template name="indent2">
  <xsl:text>  </xsl:text>
</xsl:template>


<xsl:template match="/">
   <xsl:variable name="name_mangled">
      <xsl:copy>
         <xsl:apply-templates mode="initial_pass"/>
      </xsl:copy>
   </xsl:variable>
   <xsl:for-each select="$name_mangled/entity_model">
      <xsl:call-template name="entity_model"/>
   </xsl:for-each>
</xsl:template>


<!-- 
     The initial pass copies the entire entity model whilst adding python names
     This includes name mangling and choosing member names for composition relationships.
-->

<xsl:template match="*" mode="initial_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_type|value|choice" mode="initial_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
    <python_name>
       <xsl:call-template name="mangle_name">
           <xsl:with-param name="name" select="name"/>
       </xsl:call-template>
    </python_name>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition" mode="initial_pass">
  <xsl:copy>
      <xsl:apply-templates mode="initial_pass"/>
      <python_name>
         <xsl:choose>
            <xsl:when test="name">
               <xsl:call-template name="mangle_name">
                  <xsl:with-param name="name" select="name"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="mangle_name">
                  <xsl:with-param name="name" select="type"/>
               </xsl:call-template>
            </xsl:otherwise>
         </xsl:choose>
      </python_name>
   </xsl:copy>
</xsl:template>

<xsl:variable name="python_keywords" as="xs:string *">
   <xsl:sequence select="
          'and', 'del', 'from', 'not', 'while', 'as', 'elif', 'global', 'or', 'with',
          'assert', 'else', 'if', 'pass', 'yield', 'break', 'except', 'import', 'print', 'class',
          'exec', 'in', 'raise', 'continue', 'finally', 'is', 'return', 'def',
          'for', 'lambda', 'try' "/>
</xsl:variable>

<xsl:template name="mangle_name">
  <xsl:param name="name"/>
  <xsl:variable name="name1">
        <xsl:value-of select="replace($name,'\((\d)\)','_$1')"/>
  </xsl:variable>
  <xsl:value-of select="if (count(index-of($python_keywords,$name1))=0) then $name1 else concat($name1,'_')"/>
</xsl:template>

<!-- end of initial pass -->

<!-- python generation begins here -->

<xsl:template name="entity_model" match="entity_model">
  <xsl:text>from xml.dom import minidom</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:if test="$protocolbuffer='yes'">
     <xsl:text>import </xsl:text><xsl:value-of select="absolute/name"/><xsl:text>_pb2</xsl:text>
     <xsl:call-template name="newline"/>
  </xsl:if>
  <xsl:value-of select="unparsed-text('../src/translation.py')"/>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>

  <xsl:for-each select="absolute">
    <xsl:call-template name="absolute"/>
    <xsl:call-template name="newline"/>
  </xsl:for-each>
  <xsl:for-each select="//entity_type">
    <xsl:call-template name="entityType"/>
    <xsl:call-template name="newline"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="absolute">
  <xsl:text>class </xsl:text>
  <xsl:value-of select="name"/>
  <xsl:text>(object):</xsl:text>
  <xsl:call-template name="attribute_slots"/>
  <xsl:call-template name="init_function"/>
  <xsl:call-template name="add_child_functions"/>
  <xsl:call-template name="to_xml_function"/>
  <xsl:call-template name="from_xml_function"/>
  <xsl:if test="$protocolbuffer='yes'">
     <xsl:call-template name="to_protobuf_function"/>
     <xsl:call-template name="from_protobuf_function"/>
  </xsl:if>
  <xsl:call-template name="marshal_function"/>
  <xsl:call-template name="unmarshal_function"/>
</xsl:template>

<xsl:template name="entityType">
  <xsl:variable name="parentname">
    <xsl:choose>
      <xsl:when test="parent::entity_type">
        <xsl:value-of select="../python_name"/>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>object</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:text>class </xsl:text><xsl:value-of select="concat(python_name,'(',$parentname,'):')"/>
  <xsl:call-template name="attribute_slots"/>
  <xsl:call-template name="init_function"/>
  <xsl:call-template name="add_child_functions"/>
  <xsl:if test="not(entity_type)">
    <xsl:call-template name="marshal_function"/>
  </xsl:if>
  <xsl:call-template name="unmarshal_function"/>
</xsl:template>

<xsl:template name="attribute_slots">
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>__slots__ = (</xsl:text>
  <xsl:if test="not(self::absolute)">
    <xsl:text>"parent", </xsl:text>
  </xsl:if>
  <xsl:for-each select="value|choice|composition">
    <xsl:text>"</xsl:text>
    <xsl:choose>
      <xsl:when test="self::composition and not(name)">
         <xsl:value-of select="//entity_type[name=current()/type]/python_name"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="python_name"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>", </xsl:text>
  </xsl:for-each>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template name="from_xml_function" match="absolute">
  <xsl:call-template name="indent2"/>
  <xsl:text>@classmethod</xsl:text>
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>def from_xml_string(cls, xml):</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>document = minidom.parseString(xml)</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>node = TranslationNode(XMLData(document), document.documentElement)</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>return cls._unmarshal(node)</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>@classmethod</xsl:text>
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>def from_xml_file(cls, filename):</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>with open(filename, "r") as f:</xsl:text>
  <xsl:call-template name="newlineindent6"/>
  <xsl:text>return cls.from_xml_string(f.read())</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="to_xml_function" match="absolute">
   <xsl:call-template name="indent2"/>
   <xsl:text>def to_xml_string(self):</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>document = minidom.getDOMImplementation().createDocument(None, '</xsl:text>
   <xsl:value-of select="name"/><xsl:text>', None)</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>self._marshal(lambda union_case, cfg: TranslationNode(XMLData(document), document.documentElement))</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>return document.toprettyxml(indent='  ')</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newlineindent2"/>
   <xsl:text>def to_xml_file(self, filename):</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>with open(filename, "w") as f:</xsl:text>
   <xsl:call-template name="newlineindent6"/>
   <xsl:text>f.write(self.to_xml_string().encode("utf-8"))</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="from_protobuf_function" match="absolute">
  <xsl:call-template name="indent2"/>
  <xsl:text>@classmethod</xsl:text>
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>def from_protocol_buffer(cls, buffer):</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>result = </xsl:text><xsl:value-of select="name"/><xsl:text>_pb2.</xsl:text><xsl:value-of select="name"/><xsl:text>()</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>result.ParseFromString(buffer.read())</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>node = TranslationNode(ProtobufData(), result)</xsl:text>
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>return cls._unmarshal(node)</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="to_protobuf_function" match="absolute">
   <xsl:call-template name="indent2"/>
   <xsl:text>def to_protocol_buffer(self):</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>result = </xsl:text><xsl:value-of select="name"/><xsl:text>_pb2.</xsl:text><xsl:value-of select="name"/><xsl:text>()</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>self._marshal(lambda union_case: TranslationNode(ProtobufData(), result))</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>return result</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="unmarshal_function">
  <xsl:call-template name="indent2"/>
  <xsl:text>@classmethod</xsl:text>
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>def _unmarshal(cls, </xsl:text>
  <xsl:if test="not(self::absolute)">
    <xsl:text>parent, </xsl:text>
  </xsl:if>
  <xsl:text>node):</xsl:text>
  <xsl:choose>
    <xsl:when test="entity_type">
      <xsl:call-template name="select_entity_type"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="newlineindent4"/>
      <xsl:text>self = cls(</xsl:text>
      <xsl:if test="not(self::absolute)">
        <xsl:text>parent, </xsl:text>
      </xsl:if>
      <xsl:call-template name="extract_attributes"/>
      <xsl:call-template name="newlineindent4"/>
      <xsl:text>)</xsl:text>
      <xsl:call-template name="extract_components"/>
      <xsl:call-template name="newlineindent4"/>
      <xsl:text>return self</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="select_entity_type">
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>tag, node = node.get_union_case()</xsl:text>
  <xsl:for-each select=".//entity_type[not(entity_type)]">
    <xsl:call-template name="newlineindent4"/>
    <xsl:choose>
      <xsl:when test="xmlRepresentation[text()='Anonymous']">
        <xsl:text>if tag is None:</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>if tag == "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>":</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="newlineindent6"/>
    <xsl:text>return </xsl:text>
    <xsl:value-of select="python_name"/>
    <xsl:text>._unmarshal(parent, node)</xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template name="extract_components">
  <xsl:for-each select="ancestor-or-self::entity_type/composition|composition">
    <xsl:call-template name="extract_composition"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="extract_composition" match="composition">
  <xsl:call-template name="newlineindent4"/>
  <xsl:choose>
    <xsl:when test="(cardinality = 'ExactlyOne')">
      <xsl:text>self.</xsl:text>
      <xsl:value-of select="python_name"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="//entity_type[name=current()/type]/python_name"/>
      <xsl:text>._unmarshal(self, node.get_child(</xsl:text>
      <xsl:call-template name="composition_arguments"/>
      <xsl:text>))</xsl:text>
    </xsl:when>
    <xsl:when test="(cardinality = 'ZeroOrOne')">
      <xsl:text>child = node.get_child(</xsl:text>
      <xsl:call-template name="composition_arguments"/>
      <xsl:text>)</xsl:text>
      <xsl:call-template name="newlineindent4"/>
      <xsl:text>if child:</xsl:text>
      <xsl:call-template name="newlineindent6"/>
      <xsl:text>self.</xsl:text>
      <xsl:value-of select="python_name"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="replace(type,'\((\d)\)','_$1')"/>
      <xsl:text>._unmarshal(self, child)</xsl:text>
    </xsl:when>
    <xsl:when test="(cardinality = 'ZeroOneOrMore') or (cardinality = 'OneOrMore')">
      <xsl:text>self.</xsl:text>
      <xsl:value-of select="python_name"/>
      <xsl:text> = </xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="replace(type,'\((\d)\)','_$1')"/>
      <xsl:text>._unmarshal(self, child) for child in node.get_children(</xsl:text>
      <xsl:call-template name="composition_arguments"/>
      <xsl:text>)]</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="composition_arguments">
  <xsl:choose>
    <xsl:when test="name">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text>"</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>None</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>, "</xsl:text>
  <xsl:value-of select="//entity_type[name=current()/type]/python_name"/>
  <xsl:text>", (</xsl:text>
  <xsl:for-each select="//entity_type[name=current()/type]/descendant-or-self::entity_type[not(entity_type)]">
    <xsl:text>("</xsl:text>
    <xsl:value-of select="python_name"/>
    <xsl:text>",</xsl:text>
    <xsl:call-template name="entity_cfg"/>
    <xsl:text>),</xsl:text>
  </xsl:for-each>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template name="entity_cfg">
  <xsl:text>("</xsl:text>
  <xsl:value-of select="if (xmlRepresentation)
                        then xmlRepresentation
                        else 'Element'"/>
  <xsl:text>",)</xsl:text>
</xsl:template>

<xsl:template name="extract_attributes" match="entity_type">
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))">
    <xsl:call-template name="newlineindent6"/>
    <xsl:value-of select="python_name"/>
    <xsl:text> = </xsl:text>
    <xsl:choose>
      <xsl:when test="type='float'">
        <xsl:text>float</xsl:text>
      </xsl:when>
      <xsl:when test="type='integer'">
        <xsl:text>int</xsl:text>
      </xsl:when>
      <xsl:when test="type='boolean'">
        <xsl:text>"true" == </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>(node.get_attribute("</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>", </xsl:text>
    <xsl:call-template name="attribute_configuration"/>
    <xsl:text>))</xsl:text>
    <xsl:if test="optional">
      <xsl:text> if node.has_attribute("</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>", </xsl:text>
        <xsl:call-template name="attribute_configuration"/>
        <xsl:text>) else </xsl:text>
        <xsl:call-template name="default_value"/>
    </xsl:if>
    <xsl:text>,</xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template name="attribute_configuration" match="value|choice">
  <xsl:text>('</xsl:text>
  <xsl:value-of select="if (xmlRepresentation)
                        then xmlRepresentation
                        else if (/xmlRepresentation)
                        then /xmlRepresentation
                        else 'Element'"/>
  <xsl:text>', </xsl:text>
  <xsl:choose>
    <xsl:when test="optional"><xsl:text>True</xsl:text></xsl:when>
    <xsl:otherwise><xsl:text>False</xsl:text></xsl:otherwise>
  </xsl:choose>
  <xsl:text>, (</xsl:text>
  <xsl:if test="self::choice">
    <xsl:variable name="enum_type" select="from"/>
    <xsl:for-each select="//enumeration_type[name=$enum_type]/enumeration_value">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="literal"/>
      <xsl:text>", </xsl:text>
    </xsl:for-each>
  </xsl:if>
  <xsl:text>))</xsl:text>
</xsl:template>

<xsl:template name="init_function">
  <xsl:call-template name="newlineindent2"/>
  <xsl:text>def __init__(self,</xsl:text>
  <xsl:if test="local-name(.) = 'entity_type'">
     <xsl:text>parent,</xsl:text>
  </xsl:if>
  <xsl:call-template name="init_formal_arguments"/>
  <xsl:text>):</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:if test="local-name(.) = 'entity_type'">
     <xsl:call-template name="indent4"/>
     <xsl:text>self.parent=parent</xsl:text>
     <xsl:call-template name="newline"/>
  </xsl:if>
  <xsl:for-each select="ancestor-or-self::entity_type/composition|composition">
    <xsl:call-template name="init_member"/>
  </xsl:for-each>
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))">
    <xsl:call-template name="indent4"/>
    <xsl:text>self.</xsl:text><xsl:value-of select="python_name"/><xsl:text> = </xsl:text><xsl:value-of select="python_name"/>
    <xsl:call-template name="newline"/>
  </xsl:for-each>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="init_member" match="composition">
    <xsl:call-template name="indent4"/>
    <xsl:text>self.</xsl:text>
    <xsl:value-of select="python_name"/>
    <xsl:text>=</xsl:text>
    <xsl:choose>
        <xsl:when test="(cardinality = 'ZeroOrOne') or (cardinality = 'ExactlyOne')">
          <xsl:text>None</xsl:text>
        </xsl:when>
        <xsl:when test="(cardinality = 'ZeroOneOrMore')or(cardinality = 'OneOrMore')">
          <xsl:text>[]</xsl:text>
        </xsl:when>
    </xsl:choose>
    <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="marshal_function">
  <xsl:call-template name="indent2"/>
  <xsl:text>def _marshal(self, node_factory):</xsl:text>
  <xsl:call-template name="create_node"/>
  <xsl:call-template name="serialise_attributes"/>
  <xsl:call-template name="serialise_components"/>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="create_node">
  <xsl:call-template name="newlineindent4"/>
  <xsl:text>node = node_factory(</xsl:text>
  <xsl:choose>
    <xsl:when test="ancestor::entity_type">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="python_name"/>
      <xsl:text>"</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>None</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>, </xsl:text>
  <xsl:call-template name="entity_cfg"/>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template name="serialise_components">
  <xsl:for-each select="ancestor-or-self::entity_type/composition|composition">
    <xsl:call-template name="serialise_member"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="serialise_member" match="composition">
  <xsl:variable name="membername">
      <xsl:value-of select="python_name"/>
  </xsl:variable>
  <xsl:variable name="relationship_name">
    <xsl:choose>
      <xsl:when test="name">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>None</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="newlineindent4"/>
  <xsl:choose>
    <xsl:when test="(cardinality = 'ZeroOrOne') or (cardinality = 'ExactlyOne')">
      <xsl:text>if self.</xsl:text><xsl:value-of select="$membername"/><xsl:text> is not None:</xsl:text>
      <xsl:call-template name="newlineindent6"/>
      <xsl:text>self.</xsl:text><xsl:value-of select="$membername"/><xsl:text>._marshal(node.factory(</xsl:text>
      <xsl:value-of select="$relationship_name"/>
      <xsl:text>, </xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="type"/>
      <xsl:text>"</xsl:text>
      <xsl:text>, False))</xsl:text>
    </xsl:when>
    <xsl:when test="(cardinality = 'ZeroOneOrMore') or (cardinality = 'OneOrMore')">
      <xsl:text>factory = node.factory(</xsl:text>
      <xsl:value-of select="$relationship_name"/>
      <xsl:text>, </xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="type"/>
      <xsl:text>"</xsl:text>
      <xsl:text>, True)</xsl:text>
      <xsl:call-template name="newlineindent4"/>
      <xsl:text>for child in self.</xsl:text><xsl:value-of select="$membername"/><xsl:text>:</xsl:text>
      <xsl:call-template name="newlineindent6"/>
      <xsl:text>child._marshal(factory)</xsl:text>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="serialise_attributes">
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))">
    <xsl:call-template name="newlineindent4"/>
    <xsl:text>if self.</xsl:text><xsl:value-of select="python_name"/><xsl:text> is not None:</xsl:text>
    <xsl:call-template name="newlineindent6"/>
    <xsl:text>node.set_attribute("</xsl:text><xsl:value-of select="name"/><xsl:text>", </xsl:text>
    <xsl:text>self.</xsl:text><xsl:value-of select="python_name"/>
    <xsl:text>, </xsl:text>
    <xsl:call-template name="attribute_configuration"/>
    <xsl:text>)</xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template name="add_child_functions">
   <xsl:for-each select="composition">
      <xsl:variable name="cardinality">
         <xsl:value-of select="cardinality"/>
      </xsl:variable>
      <xsl:for-each select="key('EntityTypes',type)">
        <xsl:for-each select="descendant-or-self::entity_type[not(entity_type)]">
          <xsl:call-template name="create_function">
             <xsl:with-param name="membername" select="python_name"/>
             <xsl:with-param name="cardinality" select="$cardinality"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:for-each>
   </xsl:for-each>
</xsl:template>

<xsl:template name="create_function" match="entity_type">
   <xsl:param name="membername"/>
   <xsl:param name="cardinality"/>
   <xsl:variable name="classname">
      <xsl:value-of select="name"/>
   </xsl:variable>
   <xsl:variable name="create_fn_name">
       <xsl:value-of  select="concat('create_',name)"/>
   </xsl:variable>
   <xsl:call-template name="indent2"/>
   <xsl:text>def </xsl:text><xsl:value-of select="$create_fn_name"/><xsl:text>(self</xsl:text>
   <xsl:if test="(ancestor-or-self::entity_type/(value|choice)|(value|choice))">
       <xsl:text>,</xsl:text>
   </xsl:if>
   <xsl:call-template name="init_formal_arguments"/> 
   <xsl:text>):</xsl:text>
   <xsl:call-template name="newlineindent4"/>
   <xsl:choose>
      <xsl:when test="($cardinality = 'ZeroOrOne') or ($cardinality = 'ExactlyOne')">
         <xsl:text>self.</xsl:text><xsl:value-of select="$membername"/>
         <xsl:text>=</xsl:text>
      </xsl:when>
        <xsl:when test="($cardinality = 'ZeroOneOrMore')or($cardinality = 'OneOrMore')">
          <xsl:text>self.</xsl:text><xsl:value-of select="$membername"/><xsl:text>.append(</xsl:text>
      </xsl:when>
   </xsl:choose>
   <xsl:value-of select="$classname"/><xsl:text>(self</xsl:text>
   <xsl:if test="(ancestor-or-self::entity_type/(value|choice)|(value|choice))">
      <xsl:text>,</xsl:text>
   </xsl:if>
   <xsl:call-template name="init_actual_arguments"/>
   <xsl:text>)</xsl:text>
   <xsl:if test="($cardinality = 'ZeroOneOrMore')or($cardinality = 'OneOrMore')">
        <xsl:text>)</xsl:text>
   </xsl:if>
   <xsl:call-template name="newlineindent4"/>
   <xsl:text>return self.</xsl:text>
   <xsl:value-of select="$membername"/>
   <xsl:if test="($cardinality = 'ZeroOneOrMore')or($cardinality = 'OneOrMore')">
      <xsl:text>[-1]</xsl:text>
   </xsl:if>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="init_formal_arguments">
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[not(exists(optional))]">
      <xsl:if test="position() > 1">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:call-template name="formal_argument_to_init"/>
  </xsl:for-each>
  <xsl:if test="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[optional] and (ancestor-or-self::entity_type/(value|choice)|(value|choice))[not(exists(optional))]">
      <xsl:text>,</xsl:text>
  </xsl:if>
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[optional]">
      <xsl:if test="position() > 1">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:call-template name="formal_argument_to_init"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="formal_argument_to_init">
    <xsl:value-of select="python_name"/>
    <xsl:if test="optional">
        <xsl:text>=</xsl:text>
        <xsl:call-template name="default_value"/>
    </xsl:if>
</xsl:template>

<xsl:template name="default_value">
    <xsl:variable name="defaultvalue">
       <xsl:value-of select="optional"/>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$defaultvalue=''">
          <xsl:text>None</xsl:text>
       </xsl:when>
       <xsl:when test="type='boolean'">
          <xsl:value-of select="concat(upper-case(substring($defaultvalue,1,1)),substring($defaultvalue,2))"/>
       </xsl:when>
       <xsl:when test="type='string'">
          <xsl:text>"</xsl:text><xsl:value-of select="optional/value"/><xsl:text>"</xsl:text>
       </xsl:when>
       <xsl:otherwise> 
          <xsl:value-of select="optional/value"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="init_actual_arguments">
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[not(exists(optional))]">
      <xsl:if test="position() > 1">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:value-of select="python_name"/>
  </xsl:for-each>
  <xsl:if test="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[optional] and (ancestor-or-self::entity_type/(value|choice)|(value|choice))[not(exists(optional))]">
      <xsl:text>,</xsl:text>
  </xsl:if>
  <xsl:for-each select="(ancestor-or-self::entity_type/(value|choice)|(value|choice))[optional]">
      <xsl:if test="position() > 1">
        <xsl:text>,</xsl:text>
      </xsl:if>
     <xsl:value-of select="python_name"/>
  </xsl:for-each>
</xsl:template>

</xsl:transform>

<!-- end of file: ERmodel_v1.2/src/ERmodel2.py.xslt--> 

