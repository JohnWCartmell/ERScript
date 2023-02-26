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

<xsl:template match="grammar" mode="parse">
   <!--deliberately left blank -->
</xsl:template>


<xsl:template match="testNonTerminal" mode="parse">
   <xsl:message>***************** Testing non-terminal <xsl:value-of select="@name"/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="parse"/>
   </xsl:copy>
</xsl:template>



<xsl:template match="testcase|errorcase" mode="parse">
   <xsl:message>test <xsl:value-of select="concat(name(),'---',@text)"/></xsl:message>
   <xsl:copy>   
      <xsl:apply-templates select="@*" mode="parse" />
      <xsl:variable name="parseResult" as="element()">
            <xsl:call-template name="parseNonTerminal">
               <xsl:with-param name="nonTerminalName" select="../@name"/>
               <xsl:with-param name="input" select="@text"/>
            </xsl:call-template>
      </xsl:variable>
      <xsl:if test="self::errorcase and not($parseResult[self::notFound])">
         <xsl:text>************************* Errorcase  results in valid parse **** </xsl:text>
         <xsl:message>************************* Errorcase  results in valid parse **** </xsl:message>
      </xsl:if>
      <xsl:if test="self::testcase and $parseResult[self::notFound]">
         <xsl:text>************************* Valid testcase cannot be parsed **** </xsl:text>
         <xsl:message>************************* Valid testcase cannot be parsed **** </xsl:message>
      </xsl:if>
      <xsl:copy-of select="$parseResult"/>
   </xsl:copy>
</xsl:template>

<xsl:template name="parseNonTerminal"> <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="nonTerminalName" as="xs:string"/>
   <xsl:param name="input" as="xs:string"/>

   <xsl:variable name="NonTerminalDefinition" 
                 select="/ebnf/grammar/prod[lhs=$nonTerminalName]"
                 as="element()"/>
   <xsl:apply-templates select="$NonTerminalDefinition/rhs" mode="scan">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="inputPosition" select="1 cast as xs:positiveInteger" />
   </xsl:apply-templates>
</xsl:template>

<xsl:template match="node()|@*" mode="scan"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:message terminate="yes"> Unexpected element in grammar  '<xsl:value-of select="name()"/>'content'<xsl:value-of select="."/>'</xsl:message>
</xsl:template>

<xsl:template match="nt" mode="scan">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!--<xsl:message>non terminal: <xsl:value-of select="."/></xsl:message>-->
   <xsl:variable name="production" 
                 select="/ebnf/grammar/prod[lhs=current()/.]"
                 as="element()"/>
   <xsl:variable name="result" as="element()">
      <xsl:apply-templates select="$production/rhs" mode="scan">
         <xsl:with-param name="input" select="$input"/>
         <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="$result[self::notFound]">
         <xsl:element name="notFound">
            <xsl:attribute name="subject" select="concat('nt:',.)"/> 
            <xsl:attribute name="startPosition" select="inputPosition"/>
            <xsl:copy-of select="$result"/>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
   <xsl:element name="non-terminal">
      <xsl:attribute name="name"
                     select="."/>
      <xsl:attribute name="startPosition"
                     select="$result/@startPosition"/>
      <xsl:attribute name="leadingWhitespaceLength"
                     select="$result/@leadingWhitespaceLength"/>
      <xsl:attribute name="endPosition"
                     select="$result/@endPosition"/>
      <xsl:copy-of select="$result"/>
   </xsl:element>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:variable name="leadingWhitespaceRegexp" select="'^\s+'"/>

<xsl:template name="consumeWhiteSpace">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!--
   <xsl:message> string length leadingWhitespaceRegexp is <xsl:value-of select="string-length($leadingWhitespaceRegexp)"/></xsl:message>
   <xsl:message> WhitespaceRegexp is <xsl:value-of select="$leadingWhitespaceRegexp"/></xsl:message>
   -->
   <xsl:variable name="whiteSpaceScan" select="fn:analyze-string(substring($input,$inputPosition),$leadingWhitespaceRegexp)"/>
   <xsl:choose>
      <xsl:when test="$whiteSpaceScan/fn:match">
         <xsl:sequence  select="($inputPosition + string-length($whiteSpaceScan/fn:match))
                                 cast as xs:positiveInteger
                                "/>   
      </xsl:when>
      <xsl:otherwise>
         <xsl:sequence select="$inputPosition"/>                             
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- as a performance improvement I could perhaps consume white space after a literal or a taken as well 
this will help if followed by an OR which would then repreatedly remove whitespace in each branch or OR -->

<xsl:template match="token" mode="scan">   <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:variable name="newInputPosition" as="xs:positiveInteger">
      <xsl:choose>
      <xsl:when test="(ancestor-or-self::rhs/@whitespace)='explicit'">
         <xsl:sequence select="$inputPosition"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="consumeWhiteSpace"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
         </xsl:call-template>
      </xsl:otherwise>
      </xsl:choose>  
   </xsl:variable>

   <!--<xsl:message>after consuming whitespace newInputPosition is  <xsl:value-of select="$newInputPosition"/></xsl:message>-->
   <xsl:variable name="result" as="element(fn:analyze-string-result)" select = "fn:analyze-string(substring($input,$newInputPosition),@regexp)"/>
   <xsl:choose>
      <xsl:when test="$result/fn:match">
         <xsl:element name="token">
            <xsl:attribute name="text" select="substring($input,$newInputPosition,string-length($result/fn:match))"/>
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="$newInputPosition - $inputPosition"/>
            <xsl:attribute name="endPosition"
                           select="$newInputPosition + string-length($result/fn:match)-1"/>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
         <xsl:element name="notFound">
            <xsl:attribute name="subject" select="token"/>
            <xsl:attribute name="startPosition" select="$inputPosition"/>
         </xsl:element>                       
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="literal" mode="scan">   <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:variable name="literal" select="."/>
   <!--<xsl:message>Look for literal <xsl:value-of select="$literal"/> 
              of length <xsl:value-of select="string-length($literal)"/> at input position <xsl:value-of select="$inputPosition"/></xsl:message>-->
   <xsl:variable name="newInputPosition" as="xs:positiveInteger">
      <xsl:call-template name="consumeWhiteSpace"> 
         <xsl:with-param name="input" select="$input" />
         <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>  
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="substring($input,$newInputPosition,string-length($literal))=$literal">
           <!--<xsl:message>Found</xsl:message>-->
         <xsl:element name="literal">
            <xsl:attribute name="text"
                           select="."/>
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="$newInputPosition - $inputPosition"/>
            <xsl:attribute name="endPosition"
                        select="$newInputPosition + string-length($literal) - 1"/>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
      <!--<xsl:message>I didnt find it!!!!</xsl:message>-->
         <xsl:element name="notFound">
            <xsl:attribute name="subject"
                           select="'literal'"/>
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
         </xsl:element>        
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="rhs" mode="scan">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:apply-templates select="*" mode="scan">
      <xsl:with-param name="input" select="$input"/>
      <xsl:with-param name="inputPosition" select="$inputPosition" />
   </xsl:apply-templates>
</xsl:template>


<xsl:template match="sequence" mode="scan">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!-- call a recursive template to adavnce through each sequential part -->
   <xsl:variable name="result" as="element()*">
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>   
   </xsl:variable>

   <xsl:choose>
      <xsl:when test="$result[self::notFound]">
         <xsl:element name="notFound">
            <xsl:attribute name="subject"
                           select="'sequence'"/>
            <xsl:attribute name="inputPosition"
                           select="$inputPosition"/>
            <xsl:copy-of select="$result"/>
         </xsl:element>        
      </xsl:when>
      <xsl:otherwise>
         <xsl:element name="sequence">
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="$result[1]/@leadingWhitespaceLength"/>
            <xsl:attribute name="endPosition"
                           select="$result[last()]/@endPosition"/>
            <xsl:copy-of select="$result"/>
         </xsl:element>  
      </xsl:otherwise>
      </xsl:choose>
</xsl:template>
<!-- duplicate I think 
<xsl:template match="ZeroOneOrMore" mode="scan"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>

   <xsl:variable name="result" as="element()">
      <xsl:call-template name="recursiveZeroOneOrMore">
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:element name="ZeroOneOreMore">
      <xsl:attribute name="startPosition"
                     select="$inputPosition"/>
      <xsl:attribute name="leadingWhitespaceLength"
                     select="if (count($result)=0) 
                             then 0
                             else $result[1]/@leadingWhitespaceLength
                             "/>
      <xsl:attribute name="endPosition"
                     select="if (count($result)=0) 
                             then $inputPosition
                             else $result[last()]/@endPosition
                             "/>
      <xsl:copy-of select="$result"/>
   </xsl:element>  
</xsl:template>
-->

<xsl:template match="or" mode="scan">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!-- call a recursive template to try adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfOrAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>
      <!-- could possibly insert an <or> node around this but apart from the neatness of the ties up with the original grammar it wouldn't achive anythung I think. -->
</xsl:template>

<xsl:template name="processPartsOfOrAdvancingInputPosition" match="rhs|unit" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!--<xsl:message>Entering processPartsOfOrAdvancingInputPosition</xsl:message>-->
   <xsl:variable name="result" as="element(*)">
      <xsl:apply-templates select="*[$partNo]" mode="scan"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:variable>
  
   <xsl:choose>
   <xsl:when test="not($result[self::notFound])">       
      <xsl:sequence select="$result"/>     <!-- found, in other words -->
   </xsl:when>
   <xsl:when test="$partNo &lt; count(*)">  <!-- not yet found -->
      <!--<xsl:message>Heading for next 'or' part </xsl:message>-->
         <xsl:call-template name="processPartsOfOrAdvancingInputPosition"> 
               <xsl:with-param name="input" select="$input" />
               <xsl:with-param name="partNo" select="($partNo+1) cast as xs:positiveInteger" />
               <xsl:with-param name="inputPosition" select="$inputPosition" />
         </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>         <!-- not found and nowhere else to look -->
         <xsl:element name="notFound">
            <xsl:attribute name="subject"
                           select="'or'"/>
            <xsl:attribute name="inputPosition"
                           select="$inputPosition"/>
         </xsl:element>        
   </xsl:otherwise>  
   </xsl:choose>
</xsl:template>

<xsl:template match="ZeroOneOrMore" mode="scan"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>

   <xsl:variable name="result" as="element()*">
      <xsl:call-template name="recursiveZeroOneOrMore">
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:element name="ZeroOneOrMOre">
      <xsl:attribute name="startPosition"
                     select="$inputPosition"/>
      <xsl:attribute name="leadingWhitespaceLength"
                     select="if (count($result)=0) 
                             then 0
                             else $result[1]/@leadingWhitespaceLength
                             "/>
      <xsl:attribute name="endPosition"
                     select="if (count($result)=0) 
                             then $inputPosition - 1
                             else $result[last()]/@endPosition
                             "/>
      <xsl:copy-of select="$result"/>
   </xsl:element>  
</xsl:template>

<xsl:template name="recursiveZeroOneOrMore">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:variable name="result" as="element()*">
      <!-- call a recursive template to adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>       <!-- FIRST branch below is new -->
      <xsl:when test="$result[self::notFound]">   
           <xsl:sequence select="()"/>    <!-- the zero case is OK -->
      </xsl:when>
      <xsl:otherwise>
         <xsl:copy-of select="$result"/>
         <xsl:if test="$result/(@endPosition+1) &lt;= string-length($input)">
               <xsl:call-template name="recursiveZeroOneOrMore">
                  <xsl:with-param name="input" select="$input" />
                  <xsl:with-param name="inputPosition" select="$result/(@endPosition+1)cast as xs:positiveInteger" />
               </xsl:call-template>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="processPartsOfSequenceAdvancingInputPosition" match="rhs|unit" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <!--
   <xsl:message>pPOSAIP sequence part No <xsl:value-of select="$partNo"/></xsl:message>
   <xsl:message>pPOSAIP inputPosition <xsl:value-of select="$inputPosition"/></xsl:message>
   <xsl:message>pPOSAIP name() <xsl:value-of select="name()"/></xsl:message>
   <xsl:message>pPOSAIP first part is <xsl:value-of select="*[1]/name()"/></xsl:message>
   <xsl:message>pPOSAIP second  part is <xsl:value-of select="*[2]/name()"/></xsl:message>
-->
   <xsl:variable name="result" as="element()*">
      <xsl:apply-templates select="*[$partNo]" mode="scan"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:sequence select="$result"/>
   <!-- CAN RESTRUCTURE THIS CHOOSE WITH AN IF -->
   <xsl:choose>
   <xsl:when test="$result[self::notFound]">
   </xsl:when>
   <xsl:when test="$partNo = count(*)">  <!-- that was the lest part to be matched -->
   </xsl:when>
   <xsl:otherwise>   <!-- NEED FIND MORE PARTS -->
            <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
                  <xsl:with-param name="input" select="$input" />
                  <xsl:with-param name="partNo" select="($partNo+1) cast as xs:positiveInteger" />
                  <xsl:with-param name="inputPosition" select="($result/@endPosition + 1) cast as xs:positiveInteger" />
            </xsl:call-template>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:transform>
