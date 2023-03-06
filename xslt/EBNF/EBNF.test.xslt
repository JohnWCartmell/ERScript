<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="EBNF.assembly.module.xslt"/>
<xsl:include href="EBNF.parse.module.xslt"/>
<xsl:include href="EBNF.2productionInstanceTree.module.xslt"/>
<xsl:include href="EBNF.2intermediateCodeTree.module.xslt"/>

<xsl:variable name="outputParseTree" as="xs:boolean" select="false()"/>
<xsl:variable name="outputProductionInstanceTree" as="xs:boolean" select="false()"/>
<xsl:variable name="outputIntermediateCodeTree" as="xs:boolean" select="true()"/>

<xsl:template match="/">
   <xsl:message> In root entity of test going into assembly mode.</xsl:message>
   <xsl:variable    name="docstate" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates mode="EBNF.assembly"/>
      </xsl:copy>
   </xsl:variable>
   <xsl:message> Back from assembly.</xsl:message>
   <xsl:message><xsl:copy-of select="$docstate"/></xsl:message>
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
   <xsl:copy>
      <xsl:apply-templates select="*[self::testcase|self::errorcase]" mode="test"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="testcase|errorcase" mode="test">
   <xsl:message>test <xsl:value-of select="concat(name(),'---',@text)"/></xsl:message>
   <xsl:copy>   
      <xsl:apply-templates select="@*" mode="test" /> <!-- copy attributes to identify test -->

      <xsl:variable name="parseResult" as="element()">
         <xsl:apply-templates select="../rhs" mode="parse">
            <xsl:with-param name="input" select="@text"/>
            <xsl:with-param name="inputPosition" select="1 cast as xs:positiveInteger" />
         </xsl:apply-templates>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="self::errorcase">
            <xsl:if test="not($parseResult[self::notFound])">
               <xsl:text>************************* Errorcase  results in valid parse **** </xsl:text>
               <xsl:message>************************* Errorcase  results in valid parse **** </xsl:message>
            </xsl:if>
            <xsl:copy-of select="$parseResult"/>
         </xsl:when>
         <xsl:when test="self::testcase and $parseResult[self::notFound]">
            <xsl:text>************************* Valid testcase cannot be parsed **** </xsl:text>
            <xsl:message>************************* Valid testcase cannot be parsed **** </xsl:message>
            <xsl:copy-of select="$parseResult"/>
         </xsl:when>
         <xsl:when test="self::testcase and not(parseResult[self::notFound])">
            <xsl:if test="$outputParseTree">
              <xsl:copy-of select="$parseResult"/>
            </xsl:if>
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
                     <xsl:apply-templates select="$productionInstanceTree" mode="createIntermediateCodeTree"/>
               </xsl:if>
            </xsl:if>
         </xsl:when>
      </xsl:choose>
   </xsl:copy>
</xsl:template>


</xsl:transform>
