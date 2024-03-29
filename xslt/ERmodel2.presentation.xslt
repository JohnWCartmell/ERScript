<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:output method="xml" indent="yes"/>

   <xsl:template match="/">
      <xsl:message> In root entity in 2.presentation which is <xsl:value-of select="name()"/></xsl:message>
         <xsl:apply-templates select="*" mode="reachpresentation"/>
   </xsl:template>

   <xsl:template match="entity_model" mode="reachpresentation">
      <xsl:message> In root entity in entity_model</xsl:message>
         <xsl:copy>
            <xsl:apply-templates select="presentation" mode="copypresentation"/>
            <xsl:apply-templates select="defaults" mode="copypresentation"/>
            <xsl:apply-templates select="*" mode="reachpresentation"/>
         </xsl:copy>       
   </xsl:template>

   <xsl:template match="@*|node()" mode="reachpresentation">
         <xsl:apply-templates select="@*|node()" mode="reachpresentation"/>
   </xsl:template>

   <xsl:template match="*[not(self::entity_model|self::dependency_group)]/presentation" mode="reachpresentation">
      <xsl:variable name="containerelementname" select="../name()"/>
      <xsl:element name="{$containerelementname}" namespace="http://www.entitymodelling.org/ERmodel">
         <xsl:element name="name" namespace="http://www.entitymodelling.org/ERmodel">
            <xsl:value-of select="../name"/> <!-- name of the parent entity type or group -->
               <!-- need add something for dependency groups -->
         </xsl:element>
         <xsl:copy>
               <xsl:apply-templates select="@*|node()" mode="copypresentation"/>
         </xsl:copy>
      </xsl:element>
   </xsl:template>

   <xsl:template match="dependency_group/presentation" mode="reachpresentation">
      <xsl:element name="entity_type" namespace="http://www.entitymodelling.org/ERmodel">
         <xsl:element name="name" namespace="http://www.entitymodelling.org/ERmodel">
            <xsl:value-of select="../../name"/><!-- name of source entity type -->
         </xsl:element>
         <xsl:element name="dependency_group" namespace="http://www.entitymodelling.org/ERmodel">  
                                    <!-- maybe should be reference or composition? -->
            <xsl:copy>
               <xsl:apply-templates select="@*|node()" mode="copypresentation"/>
            </xsl:copy>
         </xsl:element>
      </xsl:element>
   </xsl:template>

   <xsl:template match="*[self::reference|self::composition]/diagram" mode="reachpresentation">
      <xsl:variable name="relationship_type" select="../name()"/>
      <xsl:element name="entity_type" namespace="http://www.entitymodelling.org/ERmodel">
         <xsl:element name="name" namespace="http://www.entitymodelling.org/ERmodel">
            <xsl:value-of select="../../name"/><!-- name of source entity type -->
         </xsl:element>
         <xsl:element name="{$relationship_type}" namespace="http://www.entitymodelling.org/ERmodel">  
                                    <!-- maybe should be reference or composition? -->
            <xsl:choose>
               <xsl:when test="exists(../name)">
               <xsl:element name="name" namespace="http://www.entitymodelling.org/ERmodel">
                  <xsl:value-of select="../name"/> <!-- name of parent relationship -->
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:element name="type" namespace="http://www.entitymodelling.org/ERmodel">
                  <xsl:value-of select="../type"/> <!-- type of parent relationship -->
               </xsl:element>
            </xsl:otherwise>
         </xsl:choose>
            <xsl:copy>
               <xsl:apply-templates select="@*|node()" mode="copypresentation"/>
            </xsl:copy>
         </xsl:element>
      </xsl:element>
   </xsl:template>
         
   <xsl:template match="@*|node()" mode="copypresentation">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="copypresentation"/>
      </xsl:copy>
   </xsl:template>
</xsl:transform>
