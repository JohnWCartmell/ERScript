<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<!-- **********************  -->
<!-- IntermediateCodeTree  -->
<!-- **********************  -->

<xsl:template match="productionInstanceTree" mode="createIntermediateCodeTree"> 
   <xsl:element name="intermediateCodeTree">
      <xsl:apply-templates select="node()|@*" mode="createIntermediateCodeTree"/>
  </xsl:element>
</xsl:template>

<xsl:template match="node()|@*" mode="createIntermediateCodeTree"> 
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="createIntermediateCodeTree"/>
   </xsl:copy>
</xsl:template> 
<!--                            
<xsl:template match="*[self::AdditiveExpr|self::MultiplicativeExpr|self::UnionExpr][count(*) &gt;= 2]" mode="createIntermediateCodeTree"> 
-->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='infixTransform'])][count(*) &gt;= 2]" mode="createIntermediateCodeTree">
   <xsl:message>made into infix transform!!!!!!!!!!</xsl:message>
   <xsl:variable name="firstOperand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="termSequence" as="element()*">
      <xsl:apply-templates select="*[2]/*" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:infixTransform($firstOperand,$termSequence)"/>
</xsl:template>

<xsl:template match="*[exists(ancestor-or-self::ebnf/grammar)]" mode="createIntermediateCodeTree">
<xsl:message>Found grammar</xsl:message> 
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="createIntermediateCodeTree"/>
   </xsl:copy>
</xsl:template> 


<xsl:template match="PrimaryExpr|ParenthesizedExpr|Expr" mode="createIntermediateCodeTree"> 
   <xsl:apply-templates mode="createIntermediateCodeTree"/>
</xsl:template>

<xsl:function name="myfn:infixTransform" as="element()">
   <xsl:param name="firstOperand" as="element()"/>
   <xsl:param name="termSequence" as="element()*"/>

   <xsl:message>InfixTransform called with termSequence of length <xsl:value-of select="count($termSequence)"/></xsl:message>
   <xsl:choose>
      <xsl:when test="empty($termSequence)">
         <xsl:sequence select="$firstOperand"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="headBinary" as="element()">
            <xsl:element name="Binary">
               <xsl:copy-of select="$firstOperand"/>             <!-- the first operand -->
               <xsl:copy-of select="head($termSequence)/*[1]"/>  <!-- the operation -->
               <xsl:copy-of select="head($termSequence)/*[2]"/>  <!-- the second operand -->
            </xsl:element>
         </xsl:variable>
         <xsl:sequence select="myfn:infixTransform($headBinary,tail($termSequence))"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>

</xsl:transform>
