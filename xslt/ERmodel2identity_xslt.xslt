<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2identity_xslt.xslt 
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

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >
<xsl:output method="xml" indent="yes"/>

<xsl:key name="EntityTypes" match="entity_type" use="name"/>

<xsl:template match="/">
  <xsl:variable name="ETNAME">
    <xsl:value-of select="entity_model/absolute/name"/>
    <!--<xsl:value-of select="'absolute'"/>-->
  </xsl:variable>
  <xsl:element name="transform">
    <xsl:attribute name="version">1.0</xsl:attribute>
    <xsl:element name ="output">
        <xsl:attribute name="method">xml</xsl:attribute>
        <xsl:attribute name="indent">yes</xsl:attribute>
    </xsl:element>
    <xsl:element name="template">
      <xsl:attribute name="match">/<xsl:value-of select="$ETNAME"/></xsl:attribute>
      <xsl:element name="call-template">
        <xsl:attribute name="name">
          <xsl:value-of select="$ETNAME"/> 
          <!--<xsl:value-of select="'absolute'"/>  -->
        </xsl:attribute>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="entity_model/absolute">
      <xsl:call-template name="absolute"/>
    </xsl:for-each>
    <xsl:for-each select="//entity_type">
      <xsl:call-template name="entity_type"/>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="concrete_child_entity_types" match="entity_type">
  <xsl:for-each select="descendant-or-self::entity_type[not(entity_type)]">
    <xsl:if test="position()!=1"><xsl:text>|</xsl:text></xsl:if><xsl:value-of select="name"/>
  </xsl:for-each>
</xsl:template>


<xsl:template name="entity_type" match="entity_type">
  <xsl:element name="template" >
      <xsl:attribute name="name">
        <xsl:value-of select="name"/>
      </xsl:attribute>
    <xsl:choose>
      <xsl:when test="entity_type">
         <xsl:call-template name = "abstract_entity_type"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name = "concrete_entity_type"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template name="abstract_entity_type" match="entity_type">
  <xsl:element name="choose">
    <xsl:for-each select="descendant-or-self::entity_type[not(entity_type)]">
      <xsl:element name="when">
        <xsl:attribute name="test">name()='<xsl:value-of select="name"/>'</xsl:attribute>
        <xsl:element name="call-template">
           <xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute> 
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>
      

<xsl:template name="concrete_entity_type" match="entity_type">
<!--
  <xsl:choose>
    <xsl:when test="not(ancestor-or-self::entity_type/composition) and count(ancestor-or-self::entity_type/(attribute|reference))=1 and not(ancestor-or-self::entity_type/attribute/optional)">
      <xsl:call-template name="singular_entity_type"/>
    </xsl:when>
    <xsl:otherwise>
-->
        <call-template name ="non_singular_entity_type"/>
<!--    </xsl:otherwise>
  </xsl:choose>
-->
</xsl:template>

<xsl:template name="absolute" match="absolute">
  <xsl:element name="template" >
      <xsl:attribute name="name">
        <xsl:value-of select="name"/>
      </xsl:attribute>
  <xsl:element name="element">
    <xsl:attribute name="name">
       <xsl:value-of select="name"/>
    </xsl:attribute>
    <xsl:for-each select="attribute">
       <xsl:call-template name="named_attribute"/>
    </xsl:for-each>
    <xsl:for-each select="composition">
      <xsl:choose>
      <xsl:when test="name">
            <xsl:element name="for-each">
              <xsl:attribute name="select"><xsl:value-of select="name"/></xsl:attribute>
              <xsl:call-template name="relationship_destination_type"/>  
            </xsl:element>
      </xsl:when>
      <xsl:otherwise>
          <xsl:call-template name="relationship_destination_type"/> 
      </xsl:otherwise>
      </xsl:choose>  
    </xsl:for-each>
    <xsl:for-each select="reference">
      <xsl:choose>
      <xsl:when test="name">
            <xsl:element name="value-of">
              <xsl:attribute name="select"><xsl:value-of select="name"/></xsl:attribute>
            </xsl:element>
      </xsl:when>
      <xsl:otherwise>
            <xsl:comment>***IN ER MODEL REFERENCE RELATIONSHIP HAS NO NAME***</xsl:comment>
      </xsl:otherwise>
      </xsl:choose>  
    </xsl:for-each>
  </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template name="non_singular_entity_type" match="entity_type">
  <xsl:element name="element">
    <xsl:attribute name="name">
       <xsl:value-of select="name"/>
    </xsl:attribute>
    <xsl:for-each select="ancestor-or-self::entity_type/attribute">
       <xsl:call-template name="named_attribute"/>
    </xsl:for-each>
    <xsl:for-each select="ancestor-or-self::entity_type/composition">
      <xsl:choose>
      <xsl:when test="name">
            <xsl:element name="for-each">
              <xsl:attribute name="select"><xsl:value-of select="name"/></xsl:attribute>
              <xsl:call-template name="relationship_destination_type"/>  
            </xsl:element>
      </xsl:when>
      <xsl:otherwise>
          <xsl:call-template name="relationship_destination_type"/> 
      </xsl:otherwise>
      </xsl:choose>  
    </xsl:for-each>
    <xsl:for-each select="ancestor-or-self::entity_type/reference">
      <xsl:choose>
      <xsl:when test="name">
            <xsl:element name="value-of">
              <xsl:attribute name="select"><xsl:value-of select="name"/></xsl:attribute>
            </xsl:element>
      </xsl:when>
      <xsl:otherwise>
            <xsl:comment>***IN ER MODEL REFERENCE RELATIONSHIP HAS NO NAME***</xsl:comment>
      </xsl:otherwise>
      </xsl:choose>  
    </xsl:for-each>
  </xsl:element>
</xsl:template>
<xsl:template name="named_attribute" match="attribute">
  <xsl:element name="element">
    <xsl:attribute name="name">
      <xsl:value-of select="name"/>
    </xsl:attribute>
    <xsl:element name="value-of">
      <xsl:attribute name="select">
        <xsl:value-of select="name"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:element>
</xsl:template>    

<xsl:template name="singular_entity_type" match="entity_type">
  <xsl:element name="element">
    <xsl:attribute name="name">
       <xsl:value-of select="name"/>
    </xsl:attribute>
    <xsl:element name="value-of">
       <xsl:attribute name="select">.</xsl:attribute>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template name="relationship_destination_type" match="composition">
  <xsl:element name="for-each">
    <xsl:attribute name="select">
      <xsl:for-each select="key('EntityTypes',type)">
         <xsl:call-template name="concrete_child_entity_types"/>
      </xsl:for-each>
    </xsl:attribute>
    <xsl:element name="call-template">
      <xsl:attribute name="name"><xsl:value-of select="type"/></xsl:attribute>
    </xsl:element>
  </xsl:element>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2identity_xslt.xslt--> 

