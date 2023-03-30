<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>


<!-- *******************************************************  -->
<!-- annotate a grammar includes inserting skeleton mappings  -->
<!-- ******************************************************** -->


<xsl:template match="/|node()|@*" mode="annotate_grammar">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="annotate_grammar"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="ZeroOneOrMore" mode="annotate_grammar">
   <xsl:copy>
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="node()|@*" mode="annotate_grammar"/>
   </xsl:copy>
</xsl:template>

<!--<xsl:template match="or/literal" mode="annotate_grammar">-->
<xsl:template match="literal[parent::or
                             or
                             ((parent::sequence[parent::or]) and (not(exists(preceding-sibling::literal))))
                             or 
                             ancestor-or-self::ebnf/mapping/literalMapping[production=current()/ancestor-or-self::prod/lhs/. and literal=current()/.]
                             ]" 
             mode="annotate_grammar">
   <!--<xsl:message>annotate significant literal  '<xsl:value-of select="."/>' </xsl:message>-->
   <xsl:variable name="name_representing_literal"
                 as="xs:string">
      <xsl:call-template name="get_literal"/>
   </xsl:variable>
   <xsl:copy>
      <xsl:attribute name="signifier" select="'true'"/>
      <xsl:attribute name="type" select="$name_representing_literal"/>
      <xsl:apply-templates select="node()|@*" mode="annotate_grammar"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="prod[exists(ancestor-or-self::ebnf/mapping/non-terminals/non-terminal[@name=current()/../lhs])]/rhs" mode="annotate_grammar">
   <xsl:copy>
      <!--
      <xsl:attribute name="transform" select="ancestor-or-self::ebnf/mapping/non-terminals/non-terminal[@name=current()/../lhs]/@transform"/>
      <xsl:attribute name="abstract"  select="ancestor-or-self::ebnf/mapping/non-terminals/non-terminal[@name=current()/../lhs]/@abstract"/>
   -->
      <xsl:copy-of select="ancestor-or-self::ebnf/mapping/non-terminals/non-terminal[@name=current()/../lhs]/@*"/>
      <xsl:apply-templates select="node()|@*" mode="annotate_grammar"/>
   </xsl:copy>
</xsl:template>

<xsl:function name="myfn:leadingUpper" as="xs:string">
   <xsl:param name="input"/>
   <xsl:value-of select="concat(upper-case(substring($input,1,1)), substring($input,2,string-length($input)-1) )"/>
</xsl:function>

<xsl:template match="/|node()|@*" mode="createMappingSkeleton">
      <xsl:apply-templates select="node()|@*" mode="createMappingSkeleton"/>
</xsl:template>

<xsl:template match="literal[@signifier='true'][@type='unmappedNonAlphaLiteral']" mode="createMappingSkeleton">
   <xsl:message>create mapping skeleton  !!!!!!!!!!!  </xsl:message>
      <xsl:element name="literalMapping">
         <xsl:element name="production">
            <xsl:value-of select="ancestor-or-self::prod/lhs"/>
         </xsl:element>
         <xsl:element name="literal">
            <xsl:value-of select="."/>
         </xsl:element>
         <xsl:element name="mapping"> ... </xsl:element>
      </xsl:element>
</xsl:template>

<xsl:template name="get_literal" match="literal" mode="explicit">
   <xsl:variable name="parentProductionName" as="xs:string" 
                 select="ancestor-or-self::prod/lhs/."/>
   <xsl:variable name="literalmapping" as="element(literalMapping)?"
                 select="ancestor-or-self::ebnf/mapping/literalMapping[production=$parentProductionName and literal=current()/.]"/>
   <xsl:choose>
   <xsl:when test="exists($literalmapping)">
      <xsl:value-of select="$literalmapping/mapping"/>
   </xsl:when>
   <xsl:when test="myfn:check-literal(.)">
      <xsl:value-of select="myfn:leadingUpper(.)"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="'unmappedNonAlphaLiteral'"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:function name="myfn:check-literal" as="xs:boolean">
   <xsl:param name="literal" as="xs:string"/>
   <xsl:sequence select="matches($literal,'[a-z]|[A-Z]')"/>
</xsl:function>

</xsl:transform>
