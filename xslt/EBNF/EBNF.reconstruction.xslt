<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:er="http://www.entitymodelling.org/ERmodel"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="../ER.library.module.xslt"/>

<xsl:template match="/">
   <xsl:copy>
      <xsl:apply-templates mode="generate_xpath"/>
   </xsl:copy> 
</xsl:template>

<xsl:template match="@*|node()" mode="generate_xpath">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="generate_xpath"/>
   </xsl:copy> 
</xsl:template>

<xsl:template match="AbbrevForwardStep" mode="generate_xpath">
      <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="ParentNode" mode="generate_xpath">
      <xsl:text>..</xsl:text>
</xsl:template>

<xsl:template match="AnyPrincipalNode" mode="generate_xpath">
   <xsl:text>*</xsl:text>
</xsl:template>
<xsl:template match="AnyOrNoNamespace" mode="generate_xpath">
   <xsl:text>*:</xsl:text>
   <xsl:value-of select="@LocalName"/>
</xsl:template>

<xsl:template match="AnyLocalName" mode="generate_xpath">
   <xsl:value-of select="@Prefix"/>
   <xsl:text>:*</xsl:text>
</xsl:template>

<xsl:template match="AnyKindTest" mode="generate_xpath">
   <xsl:text>node()</xsl:text>
</xsl:template>

<xsl:template match="AllMapOrArrayData" mode="generate_xpath">
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>?*</xsl:text>
</xsl:template>

<xsl:template match="AnyArrayTest" mode="generate_xpath">
     <xsl:text>array(*)</xsl:text>
</xsl:template>

<xsl:template match="AnyFunctionTest" mode="generate_xpath">
     <xsl:text>function(*)</xsl:text>
</xsl:template>

<xsl:template match="AnyMapTest" mode="generate_xpath">
     <xsl:text>map(*)</xsl:text>
</xsl:template>

<xsl:template match="AnyURIQualifiedNode" mode="generate_xpath">
   <xsl:text>Q{</xsl:text>
   <xsl:value-of select="@URI"/>
   <xsl:text>}*</xsl:text>
</xsl:template>

<xsl:template match="ArgumentPlaceholder" mode="generate_xpath">
     <xsl:text>?</xsl:text>
</xsl:template>

<xsl:template match="ArrayLookup|MapOrArrayFilter" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text>?</xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>


<xsl:template match="ArrowExpr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:for-each select="child::element()[position() &gt; 1]">
      <xsl:text>=> </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
</xsl:template>



<xsl:template match="AtomicOrUnionType" mode="generate_xpath">
      <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="AttributeName" mode="generate_xpath">
      <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
      <xsl:if test="@Typename">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="@Typename" mode="generate_xpath"/>
   </xsl:if>
</xsl:template>

<xsl:template match="AttributeNameWildcard" mode="generate_xpath">
     <xsl:text>*</xsl:text>
</xsl:template>

<xsl:template match="AttributeTest" mode="generate_xpath">
   <xsl:text>attribute(</xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
      <xsl:if test="child::element()[2]">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   </xsl:if>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="CastExpr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> cast as </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   <xsl:if test="child::Optional">
      <xsl:text>?</xsl:text>
   </xsl:if>
</xsl:template>

<xsl:template match="CastableExpr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> castable as </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   <xsl:if test="child::Optional">
      <xsl:text>?</xsl:text>
   </xsl:if>
</xsl:template>

<xsl:template match="CommentTest" mode="generate_xpath">
   <xsl:text>comment()</xsl:text>
</xsl:template>

<xsl:template match="Compose" mode="generate_xpath">
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'path')" mode="generate_xpath"/>
      <xsl:text>/</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'step')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="ContextItemExpr" mode="generate_xpath">
   <xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="CurlyArrayConstructor" mode="generate_xpath">
   <xsl:text>array{</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="DecimalLiteral" mode="generate_xpath">
   <xsl:value-of select="@DecimalDigits"/>
</xsl:template>

<xsl:template match="DocumentTest" mode="generate_xpath">
   <xsl:text>document-node(</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="DoubleQuotedString" mode="generate_xpath">
   <xsl:text>"</xsl:text>
   <xsl:value-of select="@DoubleQuotedStringContent"/>
   <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="DoubleLiteral" mode="generate_xpath">
   <xsl:value-of select="@Mantissa"/>
   <xsl:value-of select="@ExponentSymbol"/>
   <xsl:value-of select="@Exponent"/>
</xsl:template>

<xsl:template match="DynamicFunctionCall" mode="generate_xpath">
   <xsl:apply-templates select="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'ExprSingle')]" mode="generate_xpath"/>
   <xsl:text>(</xsl:text>
   <xsl:apply-templates select="args/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="args/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="ElementName" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:if test="@typename">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="@typename" mode="generate_xpath"/>
      <xsl:if test="@optional">
         <xsl:text>?</xsl:text>
      </xsl:if>
   </xsl:if>
</xsl:template>

<xsl:template match="ElementNameWildcard" mode="generate_xpath">
     <xsl:text>*</xsl:text>
</xsl:template>

<xsl:template match="ElementTest" mode="generate_xpath">
   <xsl:text>element(</xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
      <xsl:if test="child::element()[2]">
      <xsl:text>,</xsl:text>
      <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   </xsl:if>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="EnclosedExpression" mode="generate_xpath">
   <xsl:text>{</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="EmptySequence" mode="generate_xpath">
   <xsl:text>empty-sequence()</xsl:text>
</xsl:template>

<xsl:template match="Expr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:for-each select="child::element()[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
</xsl:template>

<xsl:template match="Every" mode="generate_xpath">
   <xsl:text>every </xsl:text>
   <xsl:apply-templates select="binding/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="binding/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text> satisfies </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'return_or_satisfies')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="ForExpr" mode="generate_xpath">
   <xsl:text>for </xsl:text>
   <xsl:apply-templates select="binding/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="binding/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text> return </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'return_or_satisfies')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="FunctionCall" mode="generate_xpath">
   <xsl:apply-templates select="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'EQName')]" mode="generate_xpath"/>
   <xsl:text>(</xsl:text>
   <xsl:apply-templates select="args/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="args/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="IfExpr" mode="generate_xpath">
   <xsl:text>if (</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'condition')" mode="generate_xpath"/>
   <xsl:text>) then </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'then')" mode="generate_xpath"/>
   <xsl:text> else </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'else')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="InlineFunctionExpr" mode="generate_xpath">
   <xsl:text>function (</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'params')[1]" mode="generate_xpath"/>
   <xsl:for-each select="$erDataLib?readCompositionRelationshipNamed(.,'params')[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>)</xsl:text>
   <xsl:if test="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'SequenceType')]">
         <xsl:text>as </xsl:text>
         <xsl:apply-templates select="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'SequenceType')]"
                                                               mode="generate_xpath"/>
                             <!-- should maybe do this differently either name this comp relationship 
                                   or give more prominence to truly anonymous comp rels -->
   </xsl:if>
   <xsl:text>{</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'body')" mode="generate_xpath"/>
   <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="InstanceofExpr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> instance of </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="IntegerLiteral" mode="generate_xpath">
   <xsl:value-of select="@Digits"/>
</xsl:template>

<xsl:template match="Item" mode="generate_xpath">
   <xsl:text>item()</xsl:text>
</xsl:template>

<xsl:template match="LetExpr" mode="generate_xpath">
   <xsl:text>let </xsl:text>
   <xsl:apply-templates select="binding/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="binding/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text> return </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'return_or_satisfies')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="NamedFunctionRef" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text>#</xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="NamespaceNodeTest" mode="generate_xpath">
   <xsl:text>namespace-node()</xsl:text>
</xsl:template>

<xsl:template match="MapConstructorEntry" mode="generate_xpath">
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'key')" mode="generate_xpath"/>
      <xsl:text> : </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'value')" mode="generate_xpath"/>
</xsl:template>


<xsl:template match="MapConstructor" mode="generate_xpath">
   <xsl:text>map(</xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:for-each select="child::element()[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="MapLookup" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text>?</xsl:text>
   <xsl:value-of select="@NCName"/>
</xsl:template>

<xsl:template match="OccursZeroOneOrMore" mode="generate_xpath">
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>*</xsl:text>
</xsl:template>

<xsl:template match="OccursZeroOrOne" mode="generate_xpath">
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>?</xsl:text>
</xsl:template>

<xsl:template match="OccursOneOrMore" mode="generate_xpath">
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>+</xsl:text>
</xsl:template>

<xsl:template match="Param" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:if test="child::element()[2]">
      <xsl:text> as </xsl:text>
      <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   </xsl:if>
</xsl:template>

<xsl:template match="ParenthesizedExpr | ParenthesizedItemType" mode="generate_xpath">
   <xsl:text>(</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="PITest" mode="generate_xpath">
   <xsl:text>processing-instruction(</xsl:text>
   <xsl:value-of select="@NCName"/>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="PredicatedExpr | PredicatedStep" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text>[</xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
   <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="QName" mode="generate_xpath">
      <xsl:if test="@Prefix">
         <xsl:value-of select="@Prefix"/>
         <xsl:text>:</xsl:text>
      </xsl:if>
      <xsl:value-of select="@LocalName"/>
</xsl:template>

<xsl:template match="ReachingCompose" mode="generate_xpath">
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'path')" mode="generate_xpath"/>
      <xsl:text>//</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'step')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="Root" mode="generate_xpath">
      <xsl:text>/</xsl:text>
      <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="RootAndReach" mode="generate_xpath">
      <xsl:text>//</xsl:text>
      <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="SchemaAttributeTest" mode="generate_xpath">
   <xsl:text>schema-attribute(</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="SchemaElementTest" mode="generate_xpath">
   <xsl:text>schema-element(</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="SimpleForBinding" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> in </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="SimpleLetBinding" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> := </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="SingleQuotedString" mode="generate_xpath">
   <xsl:text>'</xsl:text>
   <xsl:value-of select="@SingleQuotedStringContent"/>
   <xsl:text>'</xsl:text>
</xsl:template>

<xsl:template match="Some" mode="generate_xpath">
   <xsl:text>some </xsl:text>
   <xsl:apply-templates select="binding/*[1]" mode="generate_xpath"/>
   <xsl:for-each select="binding/*[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text> satisfies </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'return_or_satisfies')" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="SquareArrayConstructor" mode="generate_xpath">
   <xsl:text>[</xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:for-each select="child::element()[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="StaticArrowTransform|DynamicArrowTransform" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text>(</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'args')[1]" mode="generate_xpath"/>
   <xsl:for-each select="$erDataLib?readCompositionRelationshipNamed(.,'args')[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="TextTest" mode="generate_xpath">
   <xsl:text>text()</xsl:text>
</xsl:template>

<xsl:template match="TreatExpr" mode="generate_xpath">
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
   <xsl:text> treat as </xsl:text>
   <xsl:apply-templates select="child::element()[2]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="TypedArrayTest" mode="generate_xpath">
   <xsl:text>array(</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="TypedMapTest" mode="generate_xpath">
   <xsl:text>map(</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'keytype')" mode="generate_xpath"/>
   <xsl:text>, </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'valuetype')" mode="generate_xpath"/>
   <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="TypeName" mode="generate_xpath">
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="TypedFunctionTest" mode="generate_xpath">
   <xsl:text> function (</xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'argTypes')[1]" mode="generate_xpath"/>
   <xsl:for-each select="$erDataLib?readCompositionRelationshipNamed(.,'argTypes')[position() &gt; 1]">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="." mode="generate_xpath"/>
   </xsl:for-each>
   <xsl:text>) as </xsl:text>
   <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'returnType')[1]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="UnaryMinus" mode="generate_xpath">
   <xsl:text>- </xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="UnaryPlus" mode="generate_xpath">
   <xsl:text>+ </xsl:text>
   <xsl:apply-templates select="child::element()[1]" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="URIQualifiedName" mode="generate_xpath">
      <xsl:text>Q{</xsl:text>
      <xsl:value-of select="@URI"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="@LocalName"/>
</xsl:template>

<xsl:template match="VarRef" mode="generate_xpath">
      <xsl:text>$</xsl:text>
      <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'BinaryOperation')]" mode="generate_xpath" priority="1">
     <xsl:text>(</xsl:text>
     <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'arg1')" mode="generate_xpath"/>
     <xsl:text>)</xsl:text>
     <xsl:apply-templates select="." mode="xpath_deferred"/>
     <xsl:text>(</xsl:text>
     <xsl:apply-templates select="$erDataLib?readCompositionRelationshipNamed(.,'arg2')" mode="generate_xpath"/>
     <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="Or"            mode="xpath_deferred"> <xsl:text> or </xsl:text></xsl:template>
<xsl:template match="And"           mode="xpath_deferred"> <xsl:text> and </xsl:text></xsl:template>
<xsl:template match="Add"           mode="xpath_deferred"> <xsl:text>+</xsl:text></xsl:template>
<xsl:template match="Subtract"      mode="xpath_deferred"> <xsl:text>-</xsl:text></xsl:template>
<xsl:template match="Multiply"      mode="xpath_deferred"> <xsl:text>*</xsl:text></xsl:template>
<xsl:template match="Div"           mode="xpath_deferred"> <xsl:text> div </xsl:text></xsl:template>
<xsl:template match="IntegerDivide" mode="xpath_deferred"> <xsl:text> idiv </xsl:text></xsl:template>
<xsl:template match="Mod"           mode="xpath_deferred"> <xsl:text> imod </xsl:text> </xsl:template>
<xsl:template match="Union"         mode="xpath_deferred"> <xsl:text>|</xsl:text></xsl:template>
<xsl:template match="Intersect"     mode="xpath_deferred"> <xsl:text> intersect </xsl:text></xsl:template>
<xsl:template match="Except"        mode="xpath_deferred"> <xsl:text> except </xsl:text></xsl:template>
<xsl:template match="SimpleMap"     mode="xpath_deferred"> <xsl:text>!</xsl:text></xsl:template>
<xsl:template match="RangeExpr"     mode="xpath_deferred"> <xsl:text> to </xsl:text></xsl:template>
<xsl:template match="StringConcat"  mode="xpath_deferred"> <xsl:text>||</xsl:text></xsl:template>
<xsl:template match="Eq"            mode="xpath_deferred"> <xsl:text>eq</xsl:text></xsl:template>
<xsl:template match="Ne"            mode="xpath_deferred"> <xsl:text>ne</xsl:text></xsl:template>
<xsl:template match="Lt"            mode="xpath_deferred"> <xsl:text>lt</xsl:text></xsl:template>
<xsl:template match="Le"            mode="xpath_deferred"> <xsl:text>le</xsl:text></xsl:template>
<xsl:template match="Gt"            mode="xpath_deferred"> <xsl:text>gt</xsl:text></xsl:template>
<xsl:template match="Ge"            mode="xpath_deferred"> <xsl:text>ge</xsl:text></xsl:template>
<xsl:template match="somewhat_eq"   mode="xpath_deferred"> <xsl:text>=</xsl:text></xsl:template>
<xsl:template match="Somewhat_ne"   mode="xpath_deferred"> <xsl:text>!=</xsl:text></xsl:template>
<xsl:template match="Somewhat_lt"   mode="xpath_deferred"> <xsl:text>&lt;</xsl:text></xsl:template>
<xsl:template match="Somewhat_le"   mode="xpath_deferred"> <xsl:text>&lt;=</xsl:text></xsl:template>
<xsl:template match="Somewhat_gt"   mode="xpath_deferred"> <xsl:text>&gt;</xsl:text></xsl:template>
<xsl:template match="Somewhat_ge"   mode="xpath_deferred"> <xsl:text>&gt;=</xsl:text></xsl:template>
<xsl:template match="Is"            mode="xpath_deferred"> <xsl:text> is </xsl:text></xsl:template>
<xsl:template match="Precedes"      mode="xpath_deferred"> <xsl:text>&lt;&lt;</xsl:text></xsl:template>
<xsl:template match="IsPrecededBy"  mode="xpath_deferred"> <xsl:text>&gt;&gt;</xsl:text></xsl:template>

<xsl:template match="*[$erDataLib?instanceClassifiedByEntityTypeNamed(.,'ReverseStep')
                        or
                       $erDataLib?instanceClassifiedByEntityTypeNamed(.,'ForwardStep')
                       and not(self::AbbrevForwardStep)
                      ]" mode="generate_xpath" priority="1">
   <xsl:apply-templates select="." mode="xpath_deferred"/>
   <xsl:text>::</xsl:text>
   <xsl:apply-templates select="child::element()" mode="generate_xpath"/>
</xsl:template>

<xsl:template match="Parent"  mode="xpath_deferred"> <xsl:text>parent</xsl:text></xsl:template>
<xsl:template match="Ancestor"  mode="xpath_deferred"> <xsl:text>ancestor</xsl:text></xsl:template>
<xsl:template match="Preceding-sibling"  mode="xpath_deferred"> <xsl:text>preceding-sibling</xsl:text></xsl:template>
<xsl:template match="Preceding"  mode="xpath_deferred"> <xsl:text>preceding</xsl:text></xsl:template>
<xsl:template match="Ancestor-or-self"  mode="xpath_deferred"> <xsl:text>ancestor-or-self</xsl:text></xsl:template>
<xsl:template match="Child"  mode="xpath_deferred"> <xsl:text>child</xsl:text></xsl:template>
<xsl:template match="Descendant"  mode="xpath_deferred"> <xsl:text>descendant</xsl:text></xsl:template>
<xsl:template match="Attribute"  mode="xpath_deferred"> <xsl:text>attribute</xsl:text></xsl:template>
<xsl:template match="Self"  mode="xpath_deferred"> <xsl:text>self</xsl:text></xsl:template>
<xsl:template match="Descendant-or-self"  mode="xpath_deferred"> <xsl:text>descendant-or-self</xsl:text></xsl:template>
<xsl:template match="Following-sibling"  mode="xpath_deferred"> <xsl:text>following-sibling</xsl:text></xsl:template>
<xsl:template match="Following"  mode="xpath_deferred"> <xsl:text>following</xsl:text></xsl:template>
<xsl:template match="Namespace"  mode="xpath_deferred"> <xsl:text>namespace</xsl:text></xsl:template>


</xsl:transform>
