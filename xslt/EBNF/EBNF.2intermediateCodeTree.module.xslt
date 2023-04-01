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

<!-- separatedListTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='separatedListTransform'])]" 
             mode="createIntermediateCodeTree">
   <xsl:variable name="rhs" 
                       as="element(rhs)"
                       select="$annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()]/rhs"/> 
   <xsl:variable name="requirednodename" 
                 as="xs:string"
                 select="if($rhs/@nameAfterTransform)then $rhs/@nameAfterTransform else name()"/>
   <!--<xsl:message>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX<xsl:value-of select="$requirednodename"/></xsl:message>-->
   <xsl:element name="{$requirednodename}">
      <xsl:apply-templates select="*[not(self::ZeroOneOrMore)][not(preceding-sibling::ZeroOneOrMore)]" mode="createIntermediateCodeTree"/>
      <xsl:apply-templates select="ZeroOneOrMore/OneOfZeroOneOrMore/*" mode="createIntermediateCodeTree"/>
   </xsl:element>
</xsl:template>

<!-- separatedListTransform_and_abstract_unconditional -->  <!-- PROBABLY NOT USED -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='eparatedListTransform_and_abstract_unconditional'])]" 
             mode="createIntermediateCodeTree">
   <xsl:apply-templates select="*[not(self::ZeroOneOrMore)][not(preceding-sibling::ZeroOneOrMore)]" mode="createIntermediateCodeTree"/>
   <xsl:apply-templates select="ZeroOneOrMore/OneOfZeroOneOrMore/*" mode="createIntermediateCodeTree"/>
</xsl:template>


<!-- separatedListTransform_and_abstract_when_singular -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod
                                    [lhs eq current()/name()][rhs/@transform='separatedListTransform_and_abstract_when_singular'])]
                                    [exists(ZeroOneOrMore/child::*)]" 
             mode="createIntermediateCodeTree">
   <xsl:copy>
      <xsl:apply-templates select="*[not(self::ZeroOneOrMore)][not(preceding-sibling::ZeroOneOrMore)]" mode="createIntermediateCodeTree"/>
      <xsl:apply-templates select="ZeroOneOrMore/OneOfZeroOneOrMore/*" mode="createIntermediateCodeTree"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod
                                    [lhs eq current()/name()][rhs/@transform='separatedListTransform_and_abstract_when_singular'])]
                                    [not(exists(ZeroOneOrMore/child::*))]" 
             mode="createIntermediateCodeTree"> 
      <xsl:apply-templates select="*[not(self::ZeroOneOrMore)]" mode="createIntermediateCodeTree"/>
</xsl:template>

<!-- infixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='infixTransform'])][count(*) = 3]" 
             mode="createIntermediateCodeTree">
   <xsl:variable name="firstOperand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="operator" as="element()">
      <xsl:apply-templates select="*[2]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="secondOperand" as="element()*">
      <xsl:apply-templates select="*[3]" mode="createIntermediateCodeTree"/>  
   </xsl:variable>
   <xsl:copy-of select="myfn:infixTransform($firstOperand,$operator,$secondOperand)"/>
</xsl:template>

<!-- postfixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='postfixTransform'])][count(*) = 2]" 
             mode="createIntermediateCodeTree">
   <xsl:variable name="operand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="operator" as="element()">
      <xsl:apply-templates select="*[2]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
     <xsl:element name="{$operator/name()}">  
      <xsl:copy-of select="$operand"/>                             
   </xsl:element> 
</xsl:template>

<!-- associativeInfixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='associativeInfixTransform'])][count(*) &gt;= 2]" 
              mode="createIntermediateCodeTree">
   <xsl:variable name="firstOperand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="termSequence" as="element()*">
      <xsl:apply-templates select="*[2]/*" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:associativeInfixTransform($firstOperand,$termSequence)"/>
</xsl:template>



<!-- associativeAnonymousInfixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='associativeAnonymousInfixTransform'])][count(*) &gt;= 2]" 
              mode="createIntermediateCodeTree">
   <!--<xsl:message> associateAnonymousInfixTransform as <xsl:copy-of select="."/></xsl:message>-->
   <xsl:variable name="firstOperand" as="element()">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:variable name="termSequence" as="element()*">
      <xsl:apply-templates select="*[2]/*" mode="createIntermediateCodeTree"/> 
   </xsl:variable>
   <xsl:copy-of select="myfn:associativeAnonymousInfixTransform($firstOperand,$termSequence)"/>
</xsl:template>


<!-- prefixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='prefixTransform'])]
                     [count(*) &gt;= 2]" 
               mode="createIntermediateCodeTree">

   <!-- If count is 1 then maybe the prefix op is optionally a constant so that it is nullary or unary 
         Hence of count gt 2 above -->            
   <!--<xsl:message>made it into prefixTransform <xsl:copy-of select="."/></xsl:message>-->
   <xsl:variable name="operator" as="element()*">
      <xsl:apply-templates select="*[1]" mode="createIntermediateCodeTree"/> <!-- was *[1] but I might need abstract to prune this tree-->
   </xsl:variable>
   <xsl:variable name="operand" as="element()*">                       <!-- changed to sequence because of case of xpath quantified expressions-->
      <xsl:copy-of select="$operator/*"/>                                <!-- bit weird but required for AbreviatedForwardStep -->
      <xsl:apply-templates select="tail(*)" mode="createIntermediateCodeTree"/>   <!-- was *[2] -->
   </xsl:variable>
   <xsl:copy-of select="myfn:prefixTransform($operator,$operand)"/>
</xsl:template>

<!-- multiPrefixTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='multiPrefixTransform'])]" 
               mode="createIntermediateCodeTree">
   <!--<xsl:message>made it into multiPrefixTransform!!!!!!!!!!</xsl:message>-->
   <xsl:variable name="operatorSequence" as="element()*">
      <xsl:copy-of select="*[1]/*" />
   </xsl:variable>
   <xsl:variable name="operand" as="element()">
      <xsl:apply-templates select="*[2]" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy-of select="myfn:multiPrefixTransform($operatorSequence,$operand)"/>
</xsl:template>

<!-- makeLeafNodeTransform -->
<xsl:template match="*[exists($annotatedGrammar/ebnf/grammar/prod[lhs eq current()/name()][rhs/@transform='makeLeafNodeTransform'])]" 
               mode="createIntermediateCodeTree">
   <!--<xsl:message>made it into makeLeafNodeTransform!!!!!!!!!!</xsl:message>-->
   <xsl:variable name="content" as="element()*">
      <xsl:apply-templates select="*" mode="createIntermediateCodeTree"/>
   </xsl:variable>
   <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="$content//@*"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="*[exists(ancestor-or-self::ebnf/grammar)]" mode="createIntermediateCodeTree">
<xsl:message>Found grammar</xsl:message> 
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="createIntermediateCodeTree"/>
   </xsl:copy>
</xsl:template> 

<!-- abstract="unconditional" -->
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
   <xsl:param name="operator" as="element()"/>
   <xsl:param name="secondOperand" as="element()"/>
   <!--<xsl:message>infixTransform called with operator <xsl:copy-of select="$operator"/></xsl:message>-->
   <xsl:element name="{$operator/name()}">  
      <xsl:copy-of select="$firstOperand"/>   
      <xsl:copy-of select="$secondOperand"/>                            
   </xsl:element>        
</xsl:function>


<xsl:function name="myfn:associativeInfixTransform" as="element()">
   <xsl:param name="firstOperand" as="element()"/>
   <xsl:param name="termSequence" as="element()*"/>
<!--
   <xsl:message>associativeInfixTransform called with termSequence of length <xsl:value-of select="count($termSequence)"/></xsl:message>
   <xsl:if test="count($termSequence) &gt; 0">
      <xsl:message>associativeInfixTransform firstOperand <xsl:copy-of select="$firstOperand"/></xsl:message>
      <xsl:message>associativeInfixTransform termSequence <xsl:copy-of select="$termSequence"/></xsl:message>
   </xsl:if>
-->
   <xsl:choose>
      <xsl:when test="empty($termSequence)">
         <xsl:sequence select="$firstOperand"/>
      </xsl:when>
      <xsl:otherwise>
         <!--<xsl:message> count of children of head of term sequence is <xsl:value-of select="count(head($termSequence)/*)"/></xsl:message>-->
         <xsl:variable name="headBinary" as="element()">
            <xsl:element name="{head($termSequence)/*[1]/name()}">  <!-- the operation      --> <!-- CHANGE TO head(head( ))for consistency with line below-->
               <xsl:copy-of select="$firstOperand"/>                <!-- the first operand  -->
               <xsl:copy-of select="tail(head($termSequence)/*)"/>     <!-- the second operand -->
            </xsl:element>
         </xsl:variable>
         <xsl:sequence select="myfn:associativeInfixTransform($headBinary,tail($termSequence))"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:function>


<xsl:function name="myfn:associativeAnonymousInfixTransform" as="element()">
   <xsl:param name="firstOperand" as="element()"/>
   <xsl:param name="termSequence" as="element()*"/>
   
   <!--
   <xsl:message>associativeAnonymousInfixTransform called with termSequence of length <xsl:value-of select="count($termSequence)"/></xsl:message>
   <xsl:message>associativeAnonymousInfixTransform firstOperand <xsl:copy-of select="$firstOperand"/></xsl:message>
   <xsl:if test="count($termSequence) &gt; 0">
      <xsl:message>associativeAnonymousInfixTransform termSequence <xsl:copy-of select="$termSequence"/></xsl:message>
   </xsl:if>
-->
   
   <xsl:choose>
      <xsl:when test="empty($termSequence)">
         <xsl:sequence select="$firstOperand"/>
      </xsl:when>
      <xsl:otherwise>
         <!--<xsl:message> count of children of head of term sequence is <xsl:value-of select="count(head($termSequence)/*)"/></xsl:message>-->
         <xsl:variable name="operandTypeName" select="head($termSequence)/*[1]/name()"/>
         <!--<xsl:message>operand type name is <xsl:value-of select="$operandTypeName"/></xsl:message>-->
         <xsl:variable name="rhs" 
                       as="element(rhs)"
                       select="$annotatedGrammar/ebnf/grammar/prod
                                      [lhs eq $operandTypeName
                                          or rhs/@nameAfterTransform eq $operandTypeName
                                      ]/rhs
                       "/> 
         <xsl:variable name="operatorName" as="xs:string"
                       select="$rhs/@nameWhenAnonymousOperator"/>
                     <!--<xsl:message>operator name is <xsl:value-of select="$operatorName"/></xsl:message>    -->         
         <xsl:variable name="decapitateHeadOfTermSequence" 
                        as="xs:boolean"  
                        select="$rhs/@abstract='afterwards'"/>
                        <!-- <xsl:message>decapitate is <xsl:value-of select="$decapitateHeadOfTermSequence"/></xsl:message> -->
         <xsl:variable name="headBinary" as="element()">
            <xsl:element name="{$operatorName}">                    <!-- the operation    (derived from second operand)  --> 
               <xsl:if test="$decapitateHeadOfTermSequence">
                  <xsl:copy-of select="head($termSequence)/*[1]/@*"/> <!-- as sometimes its an attribute that has content not substructure-->
               </xsl:if>
               <xsl:copy-of select="$firstOperand"/>                <!-- the first operand  -->
               <xsl:copy-of select="if ($decapitateHeadOfTermSequence)then head($termSequence)/*[1]/* else  head($termSequence)/*[1]"/>       <!-- the second operand -->
            </xsl:element>
         </xsl:variable>
         <xsl:sequence select="myfn:associativeAnonymousInfixTransform($headBinary,tail($termSequence))"/>
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
   <xsl:param name="operand" as="element()+"/>                <!--changed to be a sequence because of case of xpath quantified expressions -->

   <!-- <xsl:message>prefixTransform called with operator <xsl:value-of select="$operator"/></xsl:message> -->
      <xsl:element name="{$operator/name()}">                   <!-- the operation -->
         <xsl:copy-of select="$operand"/>                       <!-- the operand   -->
      </xsl:element> 
</xsl:function>


</xsl:transform>
