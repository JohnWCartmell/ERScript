<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
               xmlns="http://www.entitymodelling.org/ERmodel">
<xsl:output method="xml" indent="yes"/>

<xsl:include href="ERmodel.functions.module.xslt"/>


<xsl:template match="/">
   <xsl:message> In root entity in 2.newform which is <xsl:value-of select="name()"/></xsl:message>
      <!-- further enrichment (see ERmodel2.documentation_enrichment.module.xslt)        -->
   <xsl:apply-templates select="." mode="newform"/>
</xsl:template>

<xsl:template match="@*|node()" mode="newform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="newform"/>
   </xsl:copy>
</xsl:template>



<xsl:template  match="*[ self::entity_type
                        |self::group
                       ]" 
                    mode="newform">
   <xsl:copy>
      <xsl:if test="name">
         <xsl:attribute name="name" select="name"/>
      </xsl:if>
      <xsl:element name="identifyingSet">
         <xsl:for-each select="//composition[type=current()/name][identifying]">
            <xsl:element name="context">
               <xsl:value-of select="inverseOf"/> 
               <xsl:text>:</xsl:text>
               <xsl:value-of select="../name"/> 
                       <!-- source entity type name of incoming identifying composition-->
               <xsl:text>; </xsl:text>
            </xsl:element>
         </xsl:for-each>
         <xsl:for-each select="reference[identifying]">
            <xsl:element name="reference">
               <xsl:value-of select="name"/> 
               <xsl:text>:</xsl:text>
               <xsl:value-of select="type"/>
               <xsl:text>; </xsl:text>
            </xsl:element>
         </xsl:for-each>
         <xsl:for-each select="attribute[identifying]">
            <xsl:element name="attribute">
               <xsl:value-of select="name"/> 
               <xsl:text>:</xsl:text>
               <xsl:value-of select="type/*/name()"/>
               <xsl:text>; </xsl:text>
            </xsl:element>
         </xsl:for-each>
      </xsl:element>
      <xsl:apply-templates select="@*|node()" 
                           mode="newform"/>
   </xsl:copy>
</xsl:template>

<xsl:template  match="*[ self::reference
                        |self::composition
                       ]" 
                    mode="newform">
   <xsl:copy>
      <xsl:if test="name">
         <xsl:attribute name="name" select="name"/>
      </xsl:if>
      <xsl:if test="type">
         <xsl:variable name="cardinality" as="xs:string">
            <xsl:choose>
               <xsl:when test="cardinality/ExactlyOne">
                  <xsl:text></xsl:text>
               </xsl:when>
               <xsl:when test="cardinality/ZeroOrOne">                
                  <xsl:text>?</xsl:text>
               </xsl:when>
               <xsl:when test="cardinality/ZeroOneOrMore">
                  <xsl:text>*</xsl:text>
               </xsl:when>
               <xsl:when test="cardinality/OneOrMore">                
                  <xsl:text>*</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:attribute name="type" select="concat(type,$cardinality)"/>
      </xsl:if>
      <!--<xsl:apply-templates select="@*|node()" 
                           mode="newform"/> DO I NEED THIS? IF SO BE SELECTIVE SO AS NOT TOP COPY empty text nodes-->
   </xsl:copy>
</xsl:template>

<xsl:template  match="attribute" 
                    mode="newform">
   <xsl:copy>
      <xsl:if test="name">
         <xsl:attribute name="name" select="name"/>
      </xsl:if>
      <xsl:if test="type">
         <xsl:attribute name="type" select="type/*/name()"/>
      </xsl:if>
      <!-- <xsl:apply-templates select="@*|node()" 
                           mode="newform"/>  DO I NEED THIS BE MORE SELECTIVE ?  -->
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::name|self::type|self::cardinality|self::identifying]" mode="newform">
   <!-- intentionally left blank -->
</xsl:template>

<xsl:template  match="*[self::diagonal|self::riser]" 
                    mode="newform">
   <xsl:variable as="xs:string*" name="path">
         <xsl:apply-templates select="@*|node()" mode="newform"/>
   </xsl:variable>
   <xsl:copy>
      <!--normalize-space(-->
      <xsl:attribute name="path" select="normalize-space(string-join($path))"/>
   </xsl:copy>
</xsl:template>

<xsl:template  match="component" 
                    mode="newform">
   <xsl:value-of select="rel"/>
</xsl:template>

<xsl:template  match="join" 
                    mode="newform">
   <xsl:for-each select="component">
      <xsl:if test="position()!=1">
         <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="newform"/>
   </xsl:for-each>
</xsl:template>


</xsl:transform>
