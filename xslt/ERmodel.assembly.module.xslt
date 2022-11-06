<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" indent="yes"/>

   <!-- Supports 1. <include @filename @rootless>
                 2. <exclude @condition>
                 3. <extend><from/><with/></extend>
   Constructions 1. and 3. have been implemented to support separation of semantic description of a model from the description of 
      layout of its ER diagram. In fact it supports multiple alternative diagrams of the entire model and
      of subsets of the model.
   Construction 2. has been implemented so that along with construction 1. there is support for semantic models to include 
      other models. One area where this might be used is in modelling universals such as colour, shape, font and so on.
      The goal is that if one semantic model includes another then the diagram description of the one is able to include 
      the diagram description of the other.

   NOTE of CAUTION
          These above constructions can be nested but they have not been tested in all combinations.
          For example, nested includes that are themselves nested within excludes have not been tested 
          and the behaviour isn't defined.
          Likewise what is the behaviour of nest excludes? What should the behaviour be?
   -->

   <xsl:template match="@*|node()" mode="assembly">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="assembly"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="include" mode="assembly">
      <xsl:message>In include</xsl:message>
       <xsl:apply-templates select="document(@filename)/*" mode="assembly"/>
   </xsl:template>

   <xsl:template match="extend" mode="assembly">
      <xsl:message>In ERmodule.assembly.module extend</xsl:message>
      <xsl:variable name="content">
           <xsl:apply-templates select="content/*" mode="assembly"/>
      </xsl:variable>
      <xsl:variable name="xwith">
           <xsl:apply-templates select="with" mode="assembly"/>
      </xsl:variable>
      <xsl:apply-templates select="$content/*" mode="refine">
         <xsl:with-param name="with" select="$xwith/with"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="@*|node()" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="entity_model" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <xsl:apply-templates select="$with/refinement/entity_model/*"
                              mode="copy_refinement"/>                       
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="entity_type" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$with/refinement/entity_type[name=current()/name]/*[not(self::relationship|self::dependency_group)]"
                              mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="group" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$with/refinement/group[name=current()/name]/*[not(self::relationship|self::dependency_group)]"
                              mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[self::reference|self::composition]" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$with/refinement/entity_type[name=current()/../name]/relationship[name=current()/name]/*"
                              mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="dependency_group" mode="refine">
      <xsl:param name="with" as="element(with)"/>
      <xsl:copy>
         <!-- dont need to descend - because there isnt anything there! - depedency_group has no outgoing composition relationships
              except to presentation 
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
      -->
         <xsl:apply-templates select="$with/refinement/entity_type[name=../current()/name]/dependency_group/*"
                              mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="refinement/entity_type/name" mode="copy_refinement">
          <!-- dont copy this (its only there to identify the relationship whose detail is to be copied) -->
   </xsl:template>

      <xsl:template match="refinement/group/name" mode="copy_refinement">
          <!-- dont copy this (its only there to identify the group whose detail is to be copied) -->
   </xsl:template>

      <xsl:template match="refinement/entity_type/relationship/name" mode="copy_refinement">
          <!-- dont copy this (its only there to identify the relationship whose detail is to be copied) -->
   </xsl:template>

   <xsl:template match="@*|node()" mode="copy_refinement">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

      <xsl:template match="exclude" mode="assembly">
      <!-- atribute @type  -->
      <!--<xsl:variable name="exclusion_xpath" select="concat('exists(self::',@type,')')"/>-->
      <xsl:variable name="exclusion_xpath" select="@type"/>
      <xsl:message>In exclude exclusion xpath <xsl:value-of select="$exclusion_xpath"/></xsl:message>
         <xsl:apply-templates select="from/*" mode="conditional_copy">
            <xsl:with-param name="exclusion_xpath" select="$exclusion_xpath"/>
         </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="include" mode="conditional_copy">
      <xsl:param name="exclusion_xpath"/>
      <xsl:choose>
         <xsl:when test="xs:boolean(@rootless)">                     <!-- Note that xs:boolean casts to a boolean and is different to fn:boolean -->
            <xsl:message>In include mode conditional copy: rootless</xsl:message>
            <xsl:apply-templates select="document(@filename)/*/*" mode="conditional_copy">
               <xsl:with-param name="exclusion_xpath" select="$exclusion_xpath"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message>In include mode conditional copy: rooted</xsl:message>
            <xsl:apply-templates select="document(@filename)/*" mode="conditional_copy">
               <xsl:with-param name="exclusion_xpath" select="$exclusion_xpath"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="@*|node()" mode="conditional_copy">
      <xsl:param name="exclusion_xpath"/>
      <xsl:variable name="to_be_excluded" as="xs:boolean">
            <xsl:evaluate xpath="$exclusion_xpath"  context-item="."/>
      </xsl:variable>
      <xsl:if test="not($to_be_excluded)">
         <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="conditional_copy">
               <xsl:with-param name="exclusion_xpath" select="$exclusion_xpath"/>
            </xsl:apply-templates>
         </xsl:copy>
      </xsl:if>
   </xsl:template>

</xsl:transform>
