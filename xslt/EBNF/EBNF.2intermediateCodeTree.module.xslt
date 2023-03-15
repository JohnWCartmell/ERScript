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


<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='infixTransform'])][count(*) &gt;= 2]" mode="createIntermediateCodeTree">
   <xsl:variable name="firstOperand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="termSequence" as="element()*">
      <xsl:apply-templates select="*[2]/*" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:infixTransform($firstOperand,$termSequence)"/>
</xsl:template>


<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='prefixTransform'])]" 
               mode="createIntermediateCodeTree">
   <!--<xsl:message>made it into prefix transform!!!!!!!!!!</xsl:message>-->
   <xsl:variable name="operator" as="element()*">
      <xsl:copy-of select="*[1]" />
   </xsl:variable>
   <xsl:variable name="operand" as="element()">
      <xsl:apply-templates select="*[2]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:prefixTransform($operator,$operand)"/>
</xsl:template>

<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='multiPrefixTransform'])]" 
               mode="createIntermediateCodeTree">
   <!--<xsl:message>made it into multi prefix transform!!!!!!!!!!</xsl:message>-->
   <xsl:variable name="operatorSequence" as="element()*">
      <xsl:copy-of select="*[1]/*" />
   </xsl:variable>
   <xsl:variable name="operand" as="element()">
      <xsl:apply-templates select="*[2]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:multiPrefixTransform($operatorSequence,$operand)"/>
</xsl:template>


<xsl:template match="*[exists(ancestor-or-self::ebnf/grammar)]" mode="createIntermediateCodeTree">
<xsl:message>Found grammar</xsl:message> 
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="createIntermediateCodeTree"/>
   </xsl:copy>
</xsl:template> 


<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@abstract='unconditional'])]" mode="createIntermediateCodeTree">
   <!--<xsl:message>Culling unconditionally <xsl:value-of select="name()"/></xsl:message>-->
   <xsl:apply-templates mode="createIntermediateCodeTree"/>
</xsl:template>

<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@abstract='when_singular'])][count(*)=1]" mode="createIntermediateCodeTree">
   <!--<xsl:message>Culling on condition of being singular <xsl:value-of select="name()"/></xsl:message>-->
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
            <xsl:element name="{head($termSequence)/*[1]/name()}">  <!-- the operation      --> <!-- CHANGE TO head(head( ))for consistency with line below-->
               <xsl:copy-of select="$firstOperand"/>                <!-- the first operand  -->
               <xsl:copy-of select="tail(head($termSequence)/*)"/>     <!-- the second operand -->
               <xsl:message> count of children of head of term sequence is <xsl:value-of select="count(head($termSequence)/*)"/></xsl:message>
            </xsl:element>
         </xsl:variable>
         <xsl:sequence select="myfn:infixTransform($headBinary,tail($termSequence))"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>

<xsl:function name="myfn:multiPrefixTransform" as="element()">
   <xsl:param name="operatorSequence" as="element()*"/>
   <xsl:param name="operand" as="element()"/>

   <!--<xsl:message>multiPrefixTransform called with operatorSequence of length <xsl:value-of select="count($operatorSequence)"/></xsl:message>-->

   <xsl:choose>
      <xsl:when test="empty($operatorSequence)">
         <xsl:sequence select="$operand"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:variable name="body" as="element()">
            <xsl:sequence select="myfn:multiPrefixTransform(tail($operatorSequence),$operand)"/>
         </xsl:variable>
         <xsl:element name="{head($operatorSequence)/*[1]/name()}">  <!-- the operation      -->
            <xsl:copy-of select="$body"/>                            <!-- the operand  -->
         </xsl:element>        
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>

<xsl:function name="myfn:prefixTransform" as="element()">
   <xsl:param name="operator" as="element()"/>
   <xsl:param name="operand" as="element()"/>

   <xsl:message>prefixTransform called with operator <xsl:value-of select="$operator"/></xsl:message>
         <xsl:element name="{$operator/name()}">                   <!-- the operation -->
            <xsl:copy-of select="$operand"/>                       <!-- the operand   -->
         </xsl:element> 
</xsl:function>


</xsl:transform>
