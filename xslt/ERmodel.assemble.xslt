<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:output method="xml" indent="yes"/>

   <xsl:template match="entity_model">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="pass_0"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@*|node()" mode="pass_0">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="pass_0"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="include" mode="pass_0">
       <xsl:apply-templates select="document(@filename)/*" mode="pass_0"/>
   </xsl:template>

   <xsl:template match="extend" mode="pass_0">
      <xsl:variable name="content">
           <xsl:apply-templates select="content/*" mode="pass_0"/>
      </xsl:variable>
      <xsl:variable name="xwith">
           <xsl:apply-templates select="with" mode="pass_0"/>
      </xsl:variable>
      <xsl:message>xwith name <xsl:value-of select="$xwith/name()"/></xsl:message>
      <xsl:message>xwith  child <xsl:value-of select="$xwith/*/name()"/></xsl:message>
      <xsl:message>xwith grand child <xsl:value-of select="$xwith/*/*/name()"/></xsl:message>
      <xsl:message>xwith great grand child <xsl:value-of select="$xwith/*/*/*/name()"/></xsl:message>
      <xsl:apply-templates select="$content/*/*" mode="refine">
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

   <xsl:template match="entity_type" mode="refine">
      <xsl:param name="with" as="element(with)"/>
       <xsl:message>with name <xsl:value-of select="$with/name()"/></xsl:message>
      <xsl:message>with  child <xsl:value-of select="$with/*/name()"/></xsl:message>
      <xsl:message>with grand child <xsl:value-of select="$with/*/*/name()"/></xsl:message>
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="refine">
            <xsl:with-param name="with" select="$with"/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$with/refinement/entity_type[name=current()/name]/*"
                              mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="refinement/entity_type/name" mode="copy_refinement">
          <!-- dont copy this -->
   </xsl:template>

   <xsl:template match="@*|node()" mode="copy_refinement">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="copy_refinement"/>
      </xsl:copy>
   </xsl:template>

</xsl:transform>
