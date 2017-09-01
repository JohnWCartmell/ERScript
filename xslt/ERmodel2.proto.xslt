<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.proto.xslt 
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

<xsl:transform version="2.0" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

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
  
  <xsl:template match="/entity_model">
    <xsl:call-template name="newline"/>
    <xsl:call-template name="newline"/>
    <xsl:for-each select="enumeration_type">
      <xsl:call-template name="enumeration_type"/>
    </xsl:for-each>
    <xsl:for-each select="absolute|//entity_type">
      <xsl:call-template name="entity_type"/>
      <xsl:call-template name="newline"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="enumeration_type">
    <xsl:text>enum </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text> {</xsl:text>
    <xsl:for-each select="enumeration_value">
      <xsl:call-template name="newlineindent2"/>
      <xsl:value-of select="literal"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="position()-1"/>
      <xsl:text>;</xsl:text>
    </xsl:for-each>
    <xsl:call-template name="newline"/>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>
  
  <xsl:template name="entity_type">
    <xsl:text>message </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text> {</xsl:text>
    <xsl:choose>
      <xsl:when test="entity_type">
        <xsl:call-template name="sum_type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ancestor-or-self::*/(value|choice|composition)">
          <xsl:choose>
            <xsl:when test="self::composition">
              <xsl:call-template name="message_relationship">
                <xsl:with-param name="field_number" select="position()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="self::value">
              <xsl:call-template name="message_attribute">
                <xsl:with-param name="field_number" select="position()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="self::choice">
              <xsl:call-template name="message_enumeration">
                <xsl:with-param name="field_number" select="position()"/>
              </xsl:call-template>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="newline"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template name="sum_type">
    <xsl:call-template name="newlineindent2"/>
    <xsl:text>required sint32 _SUM_TYPE_ = 1;</xsl:text>
    <xsl:for-each select=".//entity_type[not(entity_type)]">
      <xsl:call-template name="newlineindent2"/>
      <xsl:text>optional </xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="position()+1"/>
      <xsl:text>;</xsl:text>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="message_attribute">
    <xsl:param name="field_number"/>
    <xsl:call-template name="newlineindent2"/>
    <xsl:choose>
      <xsl:when test="optional"><xsl:text>optional </xsl:text></xsl:when>
      <xsl:otherwise>required </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="field_line">
      <xsl:with-param name="type" select="type"/>
      <xsl:with-param name="name" select="name"/>
      <xsl:with-param name="field_number" select="$field_number"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="message_enumeration">
    <xsl:param name="field_number"/>
    <xsl:call-template name="newlineindent2"/>
    <xsl:choose>
      <xsl:when test="optional"><xsl:text>optional </xsl:text></xsl:when>
      <xsl:otherwise>required </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="field_line">
      <xsl:with-param name="type" select="from"/>
      <xsl:with-param name="name" select="name"/>
      <xsl:with-param name="field_number" select="$field_number"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="field_line">
    <xsl:param name="type"/>
    <xsl:param name="name"/>
    <xsl:param name="field_number"/>
    <xsl:call-template name="attribute_type">
      <xsl:with-param name="type_name" select="$type"/>
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text> = </xsl:text>
    <xsl:value-of select="$field_number"/>
    <xsl:text>;</xsl:text>
  </xsl:template>
  
  <xsl:template name="attribute_type">
    <xsl:param name="type_name"/>
    <xsl:choose>
      <xsl:when test="$type_name = 'integer'">
        <xsl:text>sint32</xsl:text>
      </xsl:when>
      <xsl:when test="$type_name = 'boolean'">
        <xsl:text>bool</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$type_name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="message_relationship">
    <xsl:param name="field_number"/>
    <xsl:call-template name="newlineindent2"/>
    <xsl:choose>
      <xsl:when test="(cardinality = 'OneOrMore') or (cardinality= 'ZeroOneOrMore')"><xsl:text>repeated </xsl:text></xsl:when>
      <xsl:when test="cardinality = 'ZeroOrOne'">optional </xsl:when>
      <xsl:otherwise>required </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="type"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="name">
        <xsl:value-of select="name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="type"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> = </xsl:text>
    <xsl:value-of select="$field_number"/>
    <xsl:text>;</xsl:text>
  </xsl:template>
</xsl:transform>


<!-- end of file: ERmodel_v1.2/src/ERmodel2.proto.xslt--> 

