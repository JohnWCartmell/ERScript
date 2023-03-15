<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0">
   <xsl:strip-space elements="*"/>

   <xsl:template match="/" mode="EBNF.assembly">
      <xsl:message>In assembly at doc root</xsl:message>
      <xsl:variable name="assembled_document" as="document-node()">
         <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="EBNF.assembly"/>
         </xsl:copy>
      </xsl:variable>
      <xsl:copy>
         <xsl:apply-templates select="$assembled_document" mode="EBNF.patch"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="@*|node()" mode="EBNF.patch">
      <!--<xsl:message>In assembly generic node name() '<xsl:value-of select="name()"/>'</xsl:message>-->
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="EBNF.patch"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="prod[exists(//ebnf/mapping/replace[@production=current()/lhs/.])]" mode="EBNF.patch">
      <xsl:copy-of select="//ebnf/mapping/replace[@production=current()/lhs/.]/by/*"/>
   </xsl:template>


   <xsl:template match="@*|node()" mode="EBNF.assembly">
      <!--<xsl:message>In assembly generic node name() '<xsl:value-of select="name()"/>'</xsl:message>-->
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="EBNF.assembly"/>
      </xsl:copy>
   </xsl:template>


   <xsl:template match="testcase" mode="EBNF.assembly">
      <!--<xsl:message>In testcase</xsl:message>-->
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="EBNF.assembly"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="include_grammar" mode="EBNF.assembly">
      <!-- Note that this implementation supports recursive includes -->
      <xsl:message>In include_grammar ... filename '<xsl:value-of select="@filename"/>'</xsl:message>
      <xsl:variable name="included_ebnf" 
                     as="element(ebnf)"
                     select="document(@filename)/ebnf"/>
      <xsl:variable name="assembled_ebnf" 
                     as="element(ebnf)">
         <xsl:apply-templates select="$included_ebnf" mode="EBNF.assembly"/>
      </xsl:variable>
      <xsl:copy-of select="$assembled_ebnf/grammar"/>
   </xsl:template>

   <xsl:template match="include_mapping" mode="EBNF.assembly">
      <!-- Note that this implementation supports recursive includes -->
      <xsl:message>In include_mapping ... filename '<xsl:value-of select="@filename"/>'</xsl:message>
      <xsl:variable name="included_ebnf" 
                     as="element(ebnf)"
                     select="document(@filename)/ebnf"/>
      <xsl:variable name="assembled_ebnf" 
                     as="element(ebnf)">
         <xsl:apply-templates select="$included_ebnf" mode="EBNF.assembly"/>
      </xsl:variable>
      <xsl:copy-of select="$included_ebnf/mapping"/>
   </xsl:template>

</xsl:transform>
