<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:myfn="http://www.testing123/functions"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>



<xsl:template match="/">
   <xsl:message> In root entity transforming grammar/></xsl:message>
   <xsl:variable name="state" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates mode="toIDL"/>
      </xsl:copy>
   </xsl:variable>
   <xsl:variable name="state" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates select="$state" mode="infixorelimination"/>
      </xsl:copy>
   </xsl:variable>
   <!--<xsl:apply-templates select="$state" mode="markupseparators"/>-->
   <xsl:variable name="state" as="document-node()">
      <xsl:apply-templates select="$state" mode="sequenceIntroduction"/>
   </xsl:variable>
   <xsl:apply-templates select="$state" mode="tagIntroduction"/>
</xsl:template>

<xsl:template match="grammar" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates  mode="toIDL"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="prod" mode="toIDL">
   <xsl:copy>
      <!-- add usecount just for interest's sake
      <xsl:attribute name="usecount" 
                     select="count(
                                    //nt[.=current()/lhs]
                                    )
                               "/>
                            -->
      <xsl:apply-templates mode="toIDL"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="nt" mode="toIDL">
   <xsl:copy>
      <!-- add usecount just for interest's sake 
      <xsl:attribute name="usecount" 
                     select="count(
                                    //nt[.=current()/.]
                                    )
                               "/>
                            -->
      <xsl:apply-templates select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[following-sibling::*[1][self::ZeroOneOrMore|self::ZeroOrOne]]" mode="toIDL">
     <!--deliberately left blank -->
</xsl:template>


<xsl:template match="ZeroOrOne|ZeroOneOrMore" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates  select="preceding-sibling::*[1]" mode="toIDLkeepme"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="toIDLkeepme">  
   <xsl:copy>
      <xsl:apply-templates  select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="unit" mode="toIDLkeepme">  
      <xsl:apply-templates  select="node()|@*" mode="toIDL"/>
</xsl:template>


<xsl:template match="node()|@*" mode="toIDL">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="toIDL"/>
   </xsl:copy>
</xsl:template>


<!-- INFIX <or/> elimination -->
<!-- the following replaces infix or with or operator with sequence of children-->
<!-- we are assuming a nicely structured rhs or unit in which the <or>s interleave with other elements -->
<!-- and therefore check that this is the case -->
<xsl:template match="*[self::rhs|self::unit|self::ZeroOrOne|self::ZeroOneOrMore][or]" mode="infixorelimination">
   <xsl:variable name="orcount" select="count(*[self::or])"/>
   <xsl:variable name="notorcount" select="count(*[not(self::or)])"/>
   <xsl:if test="not($notorcount=$orcount+1)">
      <xsl:message terminate="yes"> or's not nicely structured </xsl:message>
   </xsl:if>
   <xsl:copy>
      <xsl:element name="or">
         <xsl:apply-templates select="*[not(self::or)]" mode="infixorelimination"/>
      </xsl:element>
   </xsl:copy>
</xsl:template>



<xsl:template match="node()|@*" mode="infixorelimination">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="infixorelimination"/>
   </xsl:copy>
</xsl:template>


<!-- markupseparators -->
<xsl:template match="ZeroOneOrMore[count(*)=2]" mode="markupseparators">
   <xsl:copy>
      <xsl:attribute name="implementsequencewithseparator" 
                     select="(count(*)=2)
                             and  
                             (*[1][self::literal])
                             and
                             (*[2][self::nt])
                             and (preceding-sibling::*[1][self::nt])
                             and 
                             (*[2] = preceding-sibling::*[1])
                            "/>
      <xsl:attribute name="count" select="count(*)"/>
      <xsl:apply-templates select="node()|@*" mode="markupseparators"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="ZeroOneOrMore[count(*) &gt; 2]" mode="markupseparators">
   <xsl:copy>
      <xsl:attribute name="implementsequencewithseparatorseq" 
                     select="for $i in (2 to count(*)) 
                                  return let $j := count(*) + 1 - $i 
                                          return  
                                            (*[$i]/name() =preceding-sibling::*[$j]/name())
                                            and 
                                            (*[$i]/text() = preceding-sibling::*[$j]/text())
                            "/>
      <xsl:attribute name="implementsequencewithseparator" 
                     select="(*[1][self::literal])
                             and
                             ( every $b in 
                                for $i in (2 to count(*)) 
                                  return let $j := count(*) + 1 - $i 
                                          return  
                                            (*[$i]/name() =preceding-sibling::*[$j]/name())
                                            and 
                                            (*[$i]/text() = preceding-sibling::*[$j]/text())
                                 satisfies $b
                             )
                            "/>
      <xsl:attribute name="count" select="count(*)"/>
      <xsl:apply-templates select="node()|@*" mode="markupseparators"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="node()|@*" mode="markupseparators">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="markupseparators"/>
   </xsl:copy>
</xsl:template>

<!-- sequence introduction -->
<xsl:template match="/|node()|@*" mode="sequenceIntroduction">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="sequenceIntroduction"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="rhs[count(*) &gt; 1]" mode="sequenceIntroduction">
   <xsl:copy>
      <xsl:element name="sequence">
         <xsl:apply-templates select="node()|@*" mode="sequenceIntroduction"/>
      </xsl:element>
   </xsl:copy>
</xsl:template>

<!-- mapping tag introduction -->
<xsl:template match="node()|@*" mode="tagIntroduction">
   <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="tagIntroduction"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="or/literal" mode="tagIntroduction">
   <xsl:copy>
      <xsl:attribute name="type" select="myfn:convertLiteralToText(.)"/>
      <xsl:apply-templates select="node()|@*" mode="tagIntroduction"/>
   </xsl:copy>
</xsl:template>

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

</xsl:transform>
