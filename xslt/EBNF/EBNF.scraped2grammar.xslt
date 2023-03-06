<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>



<xsl:template match="/">
   <xsl:message> In root entity cleaning scraped grammar/></xsl:message>
   <xsl:copy>
      <xsl:apply-templates  mode="clean_scraped_grammar"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="scrap" mode="clean_scraped_grammar">
   <xsl:element name="grammar">
      <xsl:apply-templates  mode="clean_scraped_grammar"/>
   </xsl:element>
</xsl:template>

<xsl:template match="nt" mode="clean_scraped_grammar">
   <xsl:element name="nt">
      <xsl:apply-templates  mode="clean_scraped_grammar"/>
   </xsl:element>
</xsl:template>

<xsl:template match="head|br" mode="clean_scraped_grammar">
    <!-- deliberately left empty -->
</xsl:template>


<xsl:template match="rhs" mode="clean_scraped_grammar">
   <xsl:variable name="state" as="element(rhs)">
      <xsl:element name="rhs">
         <xsl:apply-templates  mode="clean_scraped_grammar"/>
      </xsl:element>
   </xsl:variable>

<!--
<xsl:apply-templates select="$state" mode="markupRHS"/>
   -->
   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="markupRHS"/>
   </xsl:variable>
   
   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:variable name="state" as="element(rhs)">
      <xsl:apply-templates select="$state" mode="restructureRHS"/>
   </xsl:variable>

   <xsl:apply-templates select="$state" mode="restructureRHS"/>

   <!-- a bit crap this but we have called restructure EIGHT times .... might we need more ? -->
</xsl:template>


<xsl:template match="rhs/text()" mode="clean_scraped_grammar">
   <xsl:analyze-string select="." regex='"(.*?)"'>
      <xsl:matching-substring>
         <xsl:element name="literal">
            <xsl:value-of select="regex-group(1)"/>
         </xsl:element>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
         <xsl:variable name="text" select="normalize-space(.)"/>
         <xsl:if test="$text != ''">
     <!--       <xsl:element name="text">-->
               <xsl:analyze-string select="$text" regex="(.)">
                  <xsl:matching-substring>
                     <xsl:variable name="char" select="regex-group(1)"/>
                     <xsl:choose>
                     <xsl:when test="$char = ' '">
                     </xsl:when>
                     <xsl:when test="$char = '('">
                        <xsl:element name="open"/>
                     </xsl:when>
                     <xsl:when test="$char = ')'">
                        <xsl:element name="close"/>
                     </xsl:when>
                     <xsl:when test="$char = '|'">
                        <xsl:element name="or"/>
                     </xsl:when>
                     <xsl:when test="$char = '?'">
                        <xsl:element name="ZeroOrOne"/>
                     </xsl:when>
                     <xsl:when test="$char = '*'">
                        <xsl:element name="ZeroOneOrMore"/>
                     </xsl:when>
                     <xsl:when test="$char = '+'">
                        <xsl:element name="OneOrMore"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:element name="EXCEPTIONXXXXXXXXXX">
                           <xsl:value-of select="$char"/>
                        </xsl:element>
                     </xsl:otherwise>
                     </xsl:choose>
                  </xsl:matching-substring>
               </xsl:analyze-string>
         <!--   </xsl:element> -->
         </xsl:if>
      </xsl:non-matching-substring>
   </xsl:analyze-string>
</xsl:template>

<xsl:template match="*" mode="clean_scraped_grammar">
   <xsl:copy>
      <xsl:apply-templates  mode="clean_scraped_grammar"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="markupRHS">
   <xsl:copy>
      <xsl:apply-templates mode="markupRHS"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="open" mode="markupRHS">
   <xsl:copy>
      <xsl:attribute name="depth" select="1 + count(preceding-sibling::open)-count(preceding-sibling::close)"/>
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates  mode="markupRHS"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="close" mode="markupRHS">
   <xsl:copy>
      <xsl:attribute name="depth" select="count(preceding-sibling::open)-count(preceding-sibling::close)"/>
      <xsl:attribute name="matchingopenid" select="head(reverse(
                                                       preceding-sibling::open[./(1 + count(preceding-sibling::open)-count(preceding-sibling::close))
                                                                               =current()/(count(preceding-sibling::open)-count(preceding-sibling::close))
                                                                              ]
                                                    ))/generate-id()
                                                    "/>
      <xsl:apply-templates  mode="markupRHS"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="rhs[not(open)]" mode="restructureRHS">
   <xsl:copy>
      <xsl:apply-templates  select="node()|@*" mode="restructureRHS"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="restructureRHS">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="restructureRHS"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="(rhs|unit)[open]" mode="restructureRHS">
   <xsl:variable name="firstopenid" select="*[self::open][1]/@id"/>
   <xsl:copy>
      <xsl:apply-templates  select="*[not(preceding-sibling::open)][not(self::open)]" mode="copyRHS"/>
      <xsl:element name="unit">
         <xsl:apply-templates  select="*
                                       [preceding-sibling::open[not(preceding-sibling::open)]]
                                       [following-sibling::close[@matchingopenid=$firstopenid]]
                                       "      mode="copyRHS"/>
      </xsl:element>
      <xsl:apply-templates  select="*[preceding-sibling::close[@matchingopenid=$firstopenid]]" mode="copyRHS"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="node()|@*" mode="copyRHS">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="copyRHS"/>
   </xsl:copy>
</xsl:template>



</xsl:transform>
