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
<!-- ProductionInstanceTree  -->
<!-- **********************  -->

<xsl:template match="grammar" mode="createProductionInstanceTree">
<xsl:message>grammar in createProductionTreeInstance</xsl:message>
</xsl:template> 

<xsl:template match="node()|@*" mode="createProductionInstanceTree"> 
   <xsl:message> generic creating production instance tree'<xsl:value-of select="name()"/>'content'<xsl:value-of select="."/>'</xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="non-terminal" mode="createProductionInstanceTree">
   <xsl:element name="{@name}">
      <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
   </xsl:element>
</xsl:template>

<xsl:template match="scan" mode="createProductionInstanceTree"> 
   <xsl:value-of select="."/>
</xsl:template>


<!-- rethink Mon evening 6 March
<xsl:template match="literal[@type]" mode="createProductionInstanceTree">
      <xsl:element name="{@type}"/>
</xsl:template>

 
<xsl:template match="literal[not(@type)]" mode="createProductionInstanceTree">
    deliberately left blank
</xsl:template>
-->

<xsl:template match="literal[not(@signifier = 'true')]" mode="createProductionInstanceTree">
    <!-- deliberately left blank -->
</xsl:template>

<xsl:template match="literal[@signifier = 'true']" mode="createProductionInstanceTree">
    <xsl:element name="{@type}"/>
</xsl:template>


<xsl:template match="sequence[not(@type)]" mode="createProductionInstanceTree">
   <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
</xsl:template>


<xsl:template match="ZeroOneOrMore[@type]/OneOfZeroOneOrMore" mode="createProductionInstanceTree">
      <xsl:element name="{../@type}">
         <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
      </xsl:element>
</xsl:template>

<xsl:template match="ZeroOneOrMore[@OneOrMore][exists(element())]" mode="createProductionInstanceTree">
      <xsl:element name="{@OneOrMore}">
         <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
      </xsl:element>
</xsl:template>

<xsl:template match="ZeroOneOrMore[@OneOrMore][not(exists(element()))]" mode="createProductionInstanceTree">
     <!-- deliberately left blank -->
</xsl:template>

<xsl:template match="ZeroOrOne" mode="createProductionInstanceTree">
     <xsl:apply-templates select="*" mode="createProductionInstanceTree"/>
</xsl:template>




<!-- 
<xsl:function name= "myfn:convertLiteralToText" as="xs:string">
   <xsl:param name="input"/>
   <xsl:value-of select="
      if ($input='+')             then 'Add'
      else if ($input='-')        then 'Substract'
      else if ($input='*')        then 'Multiply'
      else if ($input='|')        then 'Union'
      else if ($input='=')        then 'GeneralEquals'
      else if ($input='!=')       then 'GeneralNotEqual'
      else if ($input='&lt;')     then 'GeneralLessThan'
      else if ($input='&lt;=')    then 'GeneralLessThanOrEqual'
      else if ($input='&gt;')     then 'GeneralGreaterThan'
      else if ($input='&gt;=')    then 'GeneralGreaterThanOrEqual'
      else if ($input='eq')       then 'ValueEquals'
      else if ($input='ne')       then 'ValueNotEqual'
      else if ($input='lt')       then 'ValueLessThan'
      else if ($input='le')       then 'ValueLessThanOrEqual'
      else if ($input='gt')        then 'ValueGreaterThan'
      else if ($input='ge')       then 'ValueGreaterThanOrEqual'
      else if ($input='&lt;&lt;') then 'Precedes'
      else if ($input='&gt;&gt;') then 'IsPrecededBy'
      else if ($input='/')        then 'Step'
      else if ($input='//')       then 'ZeroOneOrMoreStep'
      else if ($input='@')        then 'Attribute'
      else myfn:leadingUpper($input)
      "/>
</xsl:function>

<xsl:function name="myfn:leadingUpper" as="xs:string">
   <xsl:param name="input"/>
   <xsl:value-of select="concat(upper-case(substring($input,1,1)), substring($input,2,string-length($input)-1) )"/>
</xsl:function>


<xsl:template match="/|node()|@*" mode="createMappingSkeleton">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="createMappingSkeleton"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="or/literal[position()=1]" mode="createMappingSkeleton">
   <xsl:message>mapping skeleton significant !!!!!!!!!!!  </xsl:message>
   <xsl:variable name="name_representing_literal"
                 as="xs:string?">
      <xsl:call-template name="translate_literal"/>
   </xsl:variable>
   <xsl:message>name representing literal <xsl:value-of select="$name_representing_literal"/></xsl:message>
   <xsl:if test="not(exists($name_representing_literal))">
      <xsl:message>Creating entry in Skeleton mappping</xsl:message>
      <xsl:element name="literalMapping">
         <xsl:element name="literal">
            <xsl:value-of select="@text"/>
         </xsl:element>
         <xsl:element name="mapping"/>
      </xsl:element>
   </xsl:if>
</xsl:template>

<xsl:template name="get_literal" match="literal" mode="explicit">
      <xsl:variable name="translated_literal"
                    as="xs:string?">
      <xsl:call-template name="translate_literal"/>
   </xsl:variable>
   <xsl:choose>
   <xsl:when test="exists($translated_literal)">
      <xsl:value-of select="$translated_literal"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="'unmappedNonAlphaLiteral'"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="translate_literal" match="literal" mode="explicit">
   <xsl:choose>
   <xsl:when test="myfn:check-literal(@text)">
      <xsl:value-of select="myfn:leadingUpper(@text)"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:sequence select="ancestor-or-self::grammar//literalMapping[literal=@text]"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:function name="myfn:check-literal" as="xs:boolean">
   <xsl:param name="literal" as="xs:string"/>
   <xsl:sequence select="matches($literal,'[a-z]|[A-Z]')"/>
</xsl:function>
-->
</xsl:transform>
