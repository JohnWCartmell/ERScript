<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<!-- 23-Mar-2023 Modified to generate a single file of xml suitable for the xpath31 logical ER model -->

<xsl:include href="EBNF.assembly.module.xslt"/>
<xsl:include href="EBNF.annotate.module.xslt"/>
<xsl:include href="EBNF.parse.module.xslt"/>
<xsl:include href="EBNF.2productionInstanceTree.module.xslt"/>
<xsl:include href="EBNF.testCoverageAnalysis.module.xslt"/>
<xsl:include href="EBNF.2intermediateCodeTree.module.xslt"/>

<xsl:variable name="outputAnotatedGrammar" as="xs:boolean" select="false()"/>
<xsl:variable name="outputParseTree" as="xs:boolean" select="false()"/>
<xsl:variable name="outputProductionInstanceTree" as="xs:boolean" select="false()"/>
<xsl:variable name="testCoverageAnalysis" as="xs:boolean" select="false()"/>
<xsl:variable name="outputIntermediateCodeTree" as="xs:boolean" select="true()"/>

<xsl:variable name="annotatedGrammar">
   <xsl:message> In global variable going into assembly mode.</xsl:message>
   <xsl:variable    name="docstate" as="document-node()">
         <xsl:apply-templates select="." mode="EBNF.assembly"/>
   </xsl:variable>
   <xsl:message> Back from assembly.</xsl:message>

   <xsl:variable name="notrequired">
      <xsl:apply-templates select="$docstate/ebnf/grammar" mode="validateGrammar"/>
   </xsl:variable>
   <xsl:message>Grammar validated.</xsl:message>

   <xsl:apply-templates select="$docstate" mode="annotate_grammar"/>
</xsl:variable>

<xsl:template match="/">

    <xsl:message>  Testing </xsl:message>
   
   <xsl:message>  Generating xml </xsl:message>

   <xsl:variable name="docstate" as="document-node()" select="$annotatedGrammar"/>

   <xsl:if test="$outputAnotatedGrammar">
      <xsl:message>Outputing Annotated Grammar</xsl:message>
      <xsl:copy-of select="$docstate/ebnf/grammar"/>
   </xsl:if>
   <!-- <xsl:copy-of select="$docstate/ebnf/mapping"/> --> 
   <!-- next check that all non-alpha literals that require names have them supplied in a mapping -->
   <!-- if they don't create a skeleton of the mapping      (see annotate.module.xslt)               -->
   <xsl:apply-templates select="$docstate/ebnf/grammar" mode="createMappingSkeleton"/>

   <xsl:copy>
      <xsl:apply-templates  select="$docstate/ebnf/*[self::test]" mode="test"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="element()" mode="test">
   <xsl:message> name() is <xsl:value-of select="name()"/></xsl:message>
   <xsl:message terminate="yes">I don't need this do I?</xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="parse"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="text()|@*" mode="test">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="parse"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="grammar" mode="test">  <!-- wont need ythis once grammar moved out-->
   <!--deliberately left blank -->
</xsl:template>

<xsl:template match="test" mode="test">
   <xsl:message>***************** Testing <xsl:value-of select="rhs"/></xsl:message>

      <xsl:variable name="parseResult" as="element()">
         <xsl:apply-templates select="rhs" mode="parse">
            <xsl:with-param name="input" select="xpath"/>
            <xsl:with-param name="inputPosition" select="1 cast as xs:positiveInteger" />
         </xsl:apply-templates>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="$parseResult[self::notFound]">
            <xsl:text>************************* cannot be parsed **** </xsl:text>
            <xsl:message>************************* cannot be parsed **** </xsl:message>
            <xsl:copy-of select="$parseResult"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$outputParseTree">
              <xsl:copy-of select="$parseResult"/>
            </xsl:if>

            <!-- Test Coverage Analysis -->
            <xsl:if test="$testCoverageAnalysis">
               <xsl:element name="testCoverageAnalysis">
                  <xsl:apply-templates select="$annotatedGrammar/ebnf/grammar" mode="testCoverageAnalysis">
                     <xsl:with-param name="parseTree" select="$parseResult"/>
                  </xsl:apply-templates>
               </xsl:element>
             </xsl:if>

            <!-- create the production Instance Tree -->
            <xsl:if test="$outputProductionInstanceTree or $outputIntermediateCodeTree">
               <xsl:variable name="productionInstanceTree" as="element()">
                  <xsl:element name="productionInstanceTree">
                     <xsl:apply-templates select="$parseResult" mode="createProductionInstanceTree"/>
                  </xsl:element>
               </xsl:variable>

               <xsl:if test="$outputProductionInstanceTree">
                  <xsl:copy-of select="$productionInstanceTree"/>
               </xsl:if>

               <xsl:if test="$outputIntermediateCodeTree">
                  <xsl:element name="xpath-31">
                     <xsl:apply-templates select="$productionInstanceTree/Expr" mode="createIntermediateCodeTree"/>
                  </xsl:element>
               </xsl:if>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
</xsl:template>

<xsl:template match="/|node()|@*" mode="validateGrammar">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="validateGrammar"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="rhs" mode="validateGrammar">
   <xsl:if test="not(count(*)=1)">
      <xsl:message terminate="yes">rhs of production ill-formed  production as '<xsl:copy-of select=".."/>'</xsl:message>
   </xsl:if>
   <xsl:apply-templates mode="validateGrammar"/>
</xsl:template>

<xsl:template match="nt" mode="validateGrammar">
   <!--<xsl:message>non terminal: <xsl:value-of select="."/></xsl:message>-->
   <xsl:variable name="production" 
                 select="/ebnf/grammar/prod[lhs=current()/.]"
                 as="element()?"/>
              <!--   <xsl:message> production <xsl:copy-of select="$production"/></xsl:message>-->
   <xsl:if test="not(exists($production))">
      <xsl:message terminate="no">No such production as '<xsl:value-of select="."/>'</xsl:message>
   </xsl:if>
   <xsl:copy>
      <xsl:apply-templates mode="validateGrammar"/>
   </xsl:copy>
</xsl:template>



</xsl:transform>
