<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<xsl:template match="node()|@*" mode="parse"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <xsl:message terminate="yes"> Unexpected element in grammar  '<xsl:value-of select="name()"/>'content'<xsl:value-of select="."/>'</xsl:message>
</xsl:template>

<xsl:template match="nt" mode="parse">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:message>non terminal: <xsl:value-of select="."/></xsl:message>-->
   <xsl:variable name="production" 
                 select="/ebnf/grammar/prod[lhs=current()/.]"
                 as="element()?"/>
   <!--<xsl:message> production <xsl:copy-of select="$production"/></xsl:message>-->
   <xsl:if test="not(exists($production))">
      <xsl:message terminate="yes">No such production as '<xsl:value-of select="."/>'</xsl:message>
   </xsl:if>

   <xsl:variable name="result" as="element()">
      <xsl:apply-templates select="$production/rhs" mode="parse">
         <xsl:with-param name="input" select="$input"/>
         <xsl:with-param name="inputPosition" select="$inputPosition" />
         <xsl:with-param name="whitespace" select="$whitespace" />
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
      <xsl:copy-of select="$production/rhs/@mapTo"/>
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

<xsl:template match="token" mode="parse">   <!-- as="xs:positiveInteger?"> -->
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:message>Look for token <xsl:value-of select="../../lhs"/> at position <xsl:value-of select="$inputPosition"/></xsl:message>-->
   <!--<xsl:message>....................................whitespace is '<xsl:value-of select="$whitespace"/>'</xsl:message>-->
   <xsl:variable name="newInputPosition" as="xs:positiveInteger">
      <xsl:choose>
      <xsl:when test="$whitespace='explicit'">
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

<xsl:template match="literal" mode="parse">  
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:variable name="signifier" select="parent::or and (position()=1)" />                      MONDAY -->
   <xsl:variable name="literal" select="." />
   <!--<xsl:message>Look for literal '<xsl:value-of select="$literal"/>'  of length <xsl:value-of select="string-length($literal)"/> at input position <xsl:value-of select="$inputPosition"/></xsl:message>-->
   <xsl:variable name="newInputPosition" as="xs:positiveInteger">
      <xsl:call-template name="consumeWhiteSpace"> 
         <xsl:with-param name="input" select="$input" />
         <xsl:with-param name="inputPosition" select="$inputPosition" />
      </xsl:call-template>  
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="substring($input,$newInputPosition,string-length($literal))=$literal">
           <!--<xsl:message>Found literal</xsl:message>-->
         <xsl:element name="literal">
            <xsl:copy-of select="@*"/>   <!-- to copy attributes from grammar-->
            <xsl:attribute name="text"
                           select="."/>
            <!--<xsl:attribute name="signifier"
                           select="$signifier"/>-->
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="$newInputPosition - $inputPosition"/>
            <xsl:attribute name="endPosition"
                        select="$newInputPosition + string-length($literal) - 1"/>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
         <!-- <xsl:message>I didnt find literal!!!!</xsl:message>-->
         <xsl:element name="notFound">
            <xsl:attribute name="subject"
                           select="'literal'"/>
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
         </xsl:element>        
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="rhs" mode="parse">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:message>rhs of <xsl:value-of select="../lhs"/> @whitespace is '<xsl:value-of select="@whitespace"/>' $whitespace is '<xsl:value-of select="$whitespace"/>'</xsl:message>-->

  <!-- <xsl:message> calculated union is '<xsl:value-of select="if (@whitespace='explicit') then 'explicit' else $whitespace"/>'</xsl:message>-->

   <xsl:variable name="parseResult" as="element()">
      <xsl:apply-templates select="*" mode="parse">
         <xsl:with-param name="input" select="$input"/>
         <xsl:with-param name="inputPosition" select="$inputPosition" />
         <xsl:with-param name="whitespace" select="if (@whitespace='explicit') then 'explicit' else $whitespace" />
      </xsl:apply-templates>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="(@mode='scan') and not($parseResult[self::notFound])">
         <xsl:element name="scan">
            <xsl:attribute name="productionName" select="../lhs"/>  <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
            <xsl:attribute name="startPosition"
                           select="$parseResult/@startPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="$parseResult/@leadingWhitespaceLength"/>
            <xsl:attribute name="endPosition"
                        select="$parseResult/@endPosition"/>
            <xsl:apply-templates select="$parseResult" mode="flatten"/>
         </xsl:element>
      </xsl:when>
      <xsl:otherwise>
             <xsl:sequence select="$parseResult"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="sequence" mode="parse">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!-- call a recursive template to adavnce through each sequential part -->

   <!--<xsl:message> sequence: in production <xsl:value-of select="ancestor-or-self::prod/lhs"/> </xsl:message>
   <xsl:message> sequence has input <xsl:value-of select="$input"/> Position <xsl:value-of select="$inputPosition"/></xsl:message>-->
   <xsl:variable name="result" as="element()*">
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>
      </xsl:call-template>   
   </xsl:variable>

   <xsl:choose>
      <xsl:when test="$result[self::notFound]">
         <!--<xsl:message>Sequence notFound </xsl:message>-->
         <xsl:element name="notFound">
            <xsl:attribute name="subject"
                           select="'sequence'"/>
            <xsl:attribute name="inputPosition"
                           select="$inputPosition"/>
            <xsl:copy-of select="$result"/>
         </xsl:element>        
      </xsl:when>
      <xsl:otherwise>
         <!--<xsl:message>Sequence Found </xsl:message>-->
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


<xsl:template match="or" mode="parse">   
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:message>In or ... $whitespace '<xsl:value-of select="$whitespace"/>'</xsl:message>-->
   <!-- call a recursive template to try adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfOrAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>
      </xsl:call-template>
      <!-- could possibly insert an <or> node around this but apart from the neatness of the ties up with the original grammar it wouldn't achive anythung I think. -->
</xsl:template>

<xsl:template name="processPartsOfOrAdvancingInputPosition" match="rhs|unit" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   <!--<xsl:message>Entering processPartsOfOrAdvancingInputPosition</xsl:message>-->
   <xsl:variable name="result" as="element(*)">
      <xsl:apply-templates select="*[$partNo]" mode="parse"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>
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
               <xsl:with-param name="whitespace" select="$whitespace"/>
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

<xsl:template match="ZeroOneOrMore" mode="parse"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>  
   <xsl:param name="whitespace" as="xs:string?"/>
   
   <xsl:variable name="result" as="element()*">
      <xsl:call-template name="recursiveZeroOneOrMore">
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:element name="ZeroOneOrMore">
      <xsl:copy-of select="@*"/>  <!-- copy attributes of grammar -->
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
   <xsl:param name="whitespace" as="xs:string?"/>
   
   <xsl:variable name="result" as="element()*">
      <!-- call a recursive template to adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>       <!-- FIRST branch below is new -->
      <xsl:when test="$result[self::notFound]">   
           <xsl:sequence select="()"/>    <!-- the zero case is OK -->
      </xsl:when>
      <xsl:otherwise>
         <xsl:element name="OneOfZeroOneOrMore">
            <xsl:attribute name="startPosition"
                           select="$inputPosition"/>
            <xsl:attribute name="leadingWhitespaceLength"
                           select="if (count($result)=0) 
                                   then 0
                                   else $result[1]/@leadingWhitespaceLength
                                   "/>
            <xsl:attribute name="endPosition"
                           select="$result[last()]/@endPosition
                                   "/>
            <xsl:copy-of select="$result"/>
         </xsl:element>  
         <!--<xsl:message> Count of $result is <xsl:value-of select="count($result)"/></xsl:message>-->
         <xsl:if test="$result/(@endPosition+1) &lt;= string-length($input)">
               <xsl:call-template name="recursiveZeroOneOrMore">
                  <xsl:with-param name="input" select="$input" />
                  <xsl:with-param name="inputPosition" select="$result[last()]/(@endPosition+1)cast as xs:positiveInteger" />   
                  <xsl:with-param name="whitespace" select="$whitespace"/>      
               </xsl:call-template>
         </xsl:if>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="ZeroOrOne" mode="parse"> 
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   
   <!--<xsl:message>Looking for ZeroOrOne </xsl:message>-->
   <xsl:variable name="result" as="element()*">
      <xsl:call-template name="scanZeroOrOne">
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>      
      </xsl:call-template>
   </xsl:variable>
   <!--<xsl:message>ZeroOrOne Count of result is <xsl:value-of select="count($result)"/></xsl:message>-->
   <xsl:element name="ZeroOrOne">
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

<xsl:template name="scanZeroOrOne">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   

   <!--<xsl:message> scan zero or one of node type '<xsl:value-of select="*/name()"/>' number of child elements <xsl:value-of select="count(*)"/></xsl:message>-->
   <xsl:variable name="result" as="element()*">
      <!-- call a recursive template to adavnce through each sequential part -->
      <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="1 cast as xs:positiveInteger" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>      
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>      
      <xsl:when test="$result[self::notFound]">   
           <xsl:sequence select="()"/>    <!-- the zero case is OK -->
      </xsl:when>
      <xsl:otherwise>
         <xsl:copy-of select="$result"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="processPartsOfSequenceAdvancingInputPosition" match="rhs|sequence" mode="explicit">
   <xsl:param name="input" as="xs:string"/>
   <xsl:param name="partNo" as="xs:positiveInteger"/>
   <xsl:param name="inputPosition" as="xs:positiveInteger"/>
   <xsl:param name="whitespace" as="xs:string?"/>
   
   <!--
   <xsl:message>pPOSAIP input '<xsl:value-of select="$input"/>'</xsl:message>
   <xsl:message>pPOSAIP sequence part No <xsl:value-of select="$partNo"/></xsl:message>
   <xsl:message>pPOSAIP inputPosition <xsl:value-of select="$inputPosition"/></xsl:message>
   <xsl:message>pPOSAIP name() <xsl:value-of select="name()"/></xsl:message>
   <xsl:message>pPOSAIP first part is <xsl:value-of select="*[1]/name()"/></xsl:message>
   <xsl:message>pPOSAIP second  part is <xsl:value-of select="*[2]/name()"/></xsl:message>
   -->

   <xsl:if test="not(exists(*[$partNo][self::element()]))">
      <xsl:message terminate="yes">part one isnt an element </xsl:message>
   </xsl:if>
   <xsl:variable name="result" as="element()*">
      <xsl:apply-templates select="*[$partNo]" mode="parse"> 
            <xsl:with-param name="input" select="$input" />
            <xsl:with-param name="partNo" select="$partNo" />
            <xsl:with-param name="inputPosition" select="$inputPosition" />
            <xsl:with-param name="whitespace" select="$whitespace"/>      
      </xsl:apply-templates>
   </xsl:variable>
   <!--<xsl:message> pPOSAIP first Result is <xsl:value-of select="$result"/></xsl:message>-->

   <xsl:sequence select="$result"/>
   <!-- CAN RESTRUCTURE THIS CHOOSE WITH AN IF -->
   <xsl:choose>
   <xsl:when test="$result[self::notFound]">
   </xsl:when>
   <xsl:when test="$partNo = count(*)">  <!-- that was the lest part to be matched -->
   </xsl:when>
   <xsl:otherwise>   <!-- NEED FIND MORE PARTS -->
      <!--<xsl:message>Find more parts </xsl:message>-->
            <xsl:call-template name="processPartsOfSequenceAdvancingInputPosition"> 
                  <xsl:with-param name="input" select="$input" />
                  <xsl:with-param name="partNo" select="($partNo+1) cast as xs:positiveInteger" />
                  <xsl:with-param name="inputPosition" select="($result/@endPosition + 1) cast as xs:positiveInteger" />
                  <xsl:with-param name="whitespace" select="$whitespace"/>      
            </xsl:call-template>
   </xsl:otherwise>
   </xsl:choose>
   <!--<xsl:message>Return from pPOSAIP</xsl:message>-->
</xsl:template>

<xsl:template match="node()|@*" mode="flatten"> 
   <xsl:message terminate="yes"> Unexpected element while flattening '<xsl:copy-of select="."/>'</xsl:message>
</xsl:template>

<xsl:template match="token" mode="flatten">
   <!--<xsl:message>Flatten token '<xsl:value-of select="@text"/>'</xsl:message>-->
   <xsl:value-of select="@text"/>
</xsl:template>

<xsl:template match="scan" mode="flatten">
   <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="literal" mode="flatten">
   <xsl:value-of select="@text"/>
</xsl:template>

<xsl:template match="non-terminal|sequence|ZeroOrOne|ZeroOneOrMore|OneOfZeroOneOrMore" mode="flatten">
   <xsl:apply-templates select="*" mode="flatten"/>
</xsl:template>
</xsl:transform>
