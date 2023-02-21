<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>


<xsl:template match="/">
   <xsl:message> In root entity parsing/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates  mode="parse"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="parse">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="parse"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="lexis" mode="parse">
   <!--deliberately left blank -->
</xsl:template>

<xsl:template match="testtoken" mode="parse">
   <xsl:message>testing token <xsl:value-of select="@name"/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="parse"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="testcase" mode="parse">
   <xsl:message>testcase <xsl:value-of select="@text"/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="@*" mode="parse" />
      <xsl:variable name="newInputPosition" as="xs:positiveInteger?">
         <xsl:call-template name="getTokenNewInputPosition">
            <xsl:with-param name="tokenName" select="../@name"/>
            <xsl:with-param name="input" select="@text"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:message>new input position <xsl:value-of select="$newInputPosition"/></xsl:message>
      <xsl:attribute name="found" select="$newInputPosition != 1"/>
      <xsl:if test="$newInputPosition != 1">
         <xsl:attribute name="token" select="substring(@text,1,$newInputPosition - 1)"/>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template name="getTokenNewInputPosition"> <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="tokenName" as="xs:string"/>
   <xsl:param name="input" as="xs:string"/>

   <xsl:variable name="tokenDefinition" 
                 select="/testdata/lexis/*[self::tokenAsRegexp|self::tokenAsProduction][@name=$tokenName]"
                 as="element()"/>
   <xsl:apply-templates select="$tokenDefinition" mode="scan">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="inputPosition" select="1 cast as xs:positiveInteger" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="node()|@*" mode="scan"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:message> In generic scan rule <xsl:value-of select="name()"/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="scan">
         <xsl:with-param name="input" select="$input"/>
         <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:copy>
</xsl:template>

<xsl:template match="nt" mode="scan"><!-- as="xs:positiveInteger?"> -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:message>non terminal: <xsl:value-of select="."/></xsl:message>
   <xsl:variable name="tokenDefinition" 
                 select="/testdata/lexis/*[self::tokenAsRegexp|self::tokenAsProduction][@name=current()/.]"
                 as="element()"/>
   <xsl:apply-templates select="$tokenDefinition" mode="scan">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="inputPosition" select="$inputPosition" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="tokenAsRegexp" mode="scan">   <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:variable name="result" as="element()" select = "fn:analyze-string(substring($input,$inputPosition),@regexp)"/>
   <xsl:value-of  select="$inputPosition + string-length($result/fn:match)"/>
</xsl:template>

<xsl:template match="rhs|unit" mode="scan">   <!-- rhs|unit represents sequence -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!-- call a recursive template to adavnce through each sequential part -->
   <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
         <xsl:with-param name="input" select="$input" />
         <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
         <xsl:with-param name="inputPosition" select="$inputPosition" />
   </xsl:call-template>
</xsl:template>

<xsl:template match="ZeroOneOrMore" mode="scan">   <!-- rhs|unit represents sequence -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:call-template name="recursiveZeroOneOrMore">
         <xsl:with-param name="input" select="$input" />
         <xsl:with-param name="inputPosition" select="$inputPosition" />
   </xsl:call-template>
</xsl:template>

<xsl:template match="or" mode="scan">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!-- call a recursive template to try adavnce through each sequential part -->
   <xsl:call-template name="processPartsOfOrAdvancingInputPosition"> 
         <xsl:with-param name="input" select="$input" />
         <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
         <xsl:with-param name="inputPosition" select="$inputPosition" />
   </xsl:call-template>
</xsl:template>

<xsl:template name="processPartsOfOrAdvancingInputPosition" match="rhs|unit" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:message>Entering processPartsOfOrAdvancingInputPosition</xsl:message>
   <xsl:variable name="newInputPosition" as="xs:positiveInteger?">
      <xsl:apply-templates select="*[$partNo]" mode="scan"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
   <xsl:when test="$newInputPosition != $inputPosition">
      <xsl:value-of select="$newInputPosition"/>
   </xsl:when>
   <xsl:when test="$partNo &lt; count(*)">
      <xsl:message>Heading for next part</xsl:message>
         <xsl:call-template name="processPartsOfOrAdvancingInputPosition"> 
               <xsl:with-param name="input" select="$input" />
               <xsl:with-param name="partNo" select="($partNo+1) cast as xs:positiveInteger" />
               <xsl:with-param name="inputPosition" select="$inputPosition" />
         </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="$inputPosition"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="recursiveZeroOneOrMore">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:variable name="newInputPosition" as="xs:positiveInteger?">
      <!-- call a recursive template to adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:message> reczoormore new imput position <xsl:value-of select="$newInputPosition"/></xsl:message>
   <xsl:choose>
      <xsl:when test="($newInputPosition != $inputPosition)
                      and
                      ($newInputPosition &lt;= string-length($input))">
            <xsl:call-template name="recursiveZeroOneOrMore">
               <xsl:with-param name="input" select="$input" />
               <xsl:with-param name="inputPosition" select="$newInputPosition" />
            </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$newInputPosition"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="processPartsOfSequenceAdvancingInputPosition" match="rhs|unit" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:message>pPOSAIP part No <xsl:value-of select="$partNo"/></xsl:message>
   <xsl:message>pPOSAIP inputPosition <xsl:value-of select="$inputPosition"/></xsl:message>
   <xsl:message>pPOSAIP name() <xsl:value-of select="name()"/></xsl:message>
   <xsl:variable name="newInputPosition" as="xs:positiveInteger?">
      <xsl:apply-templates select="*[$partNo]" mode="scan"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
   <xsl:when test="$partNo &lt; count(*)">
      <xsl:if test="$newInputPosition &lt;= string-length($input)">
         <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
               <xsl:with-param name="input" select="$input" />
               <xsl:with-param name="partNo" select="($partNo+1) cast as xs:positiveInteger" />
               <xsl:with-param name="inputPosition" select="$newInputPosition" />
         </xsl:call-template>
      </xsl:if>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="$newInputPosition"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:transform>
