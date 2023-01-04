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
   <xsl:message> In root entity in 2.oldform which is <xsl:value-of select="name()"/></xsl:message>
   <!--
   <xsl:message> Initial pass</xsl:message>
   <xsl:variable name="state" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates select="." mode="initial_pass"/>
      </xsl:copy>
   </xsl:variable>
   -->
   <xsl:message> main pass</xsl:message>
   <xsl:copy>
      <xsl:apply-templates select="entity_model" mode="oldform"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()" mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="oldform"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@name" mode="oldform">
   <xsl:element name="name"> 
      <xsl:value-of select="."/>
   </xsl:element>
</xsl:template>  

<xsl:template match="@type" mode="oldform">
   <!-- intentially left blank -->
</xsl:template>  

<xsl:template  match="group" mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
   </xsl:copy>
</xsl:template>

<xsl:template  match="entity_type/identifying" mode="oldform">
      <!-- just flatten the structure i.e. remove the <identifying> element 
           TBD: need also to consolidate (need an example that needs this second step)
      -->
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
</xsl:template>

<xsl:template  match="entity_type" 
                    mode="oldform">
   <xsl:copy>  
      <xsl:apply-templates select="@*|node()" mode="oldform"/> 
   </xsl:copy>
</xsl:template>

<xsl:template  match="*[ self::reference
                        |self::composition
                       ]" 
                    mode="oldform">
   <xsl:copy>
      <xsl:apply-templates select="@*" mode="oldform"/> <!-- process attributes first -->
      <xsl:if test="@type">
         <xsl:element name="cardinality">
            <xsl:element name="{if (substring(type,string-length(@type))='?')
                                then 'ZeroOrOne'
                                else if (substring(type,string-length(@type))='*')
                                then 'ZeroOneOrMore'
                                else if (substring(type,string-length(@type))='+')
                                then 'OneOrMore'
                                else 'ExactlyOne'
                               }"/>

         </xsl:element>
         <xsl:element name="type">
            <xsl:value-of select="if ((substring(@type,string-length(@type))='?')
                                    or (substring(@type,string-length(@type))='*')
                                    or (substring(@type,string-length(@type))='+'))
                                   then substring(@type,1,string-length(@type)-1)
                                   else @type
                                  "/>

         </xsl:element>
      </xsl:if>
      <xsl:if test="parent::identifying">    <!-- TBD probably need a bit more than this -->
                                             <!-- Hmmmm ... not sure -->
         <xsl:element name="identifying"/>
      </xsl:if>
      <xsl:apply-templates select="*" mode="oldform"/> <!-- now processing non-attributes -->
   </xsl:copy>
</xsl:template>

<xsl:template  match="attribute" 
                    mode="oldform">
   <xsl:copy>
      <xsl:if test="@name">
         <xsl:element name="name"> 
            <xsl:value-of select="@name"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="@type">
         <xsl:element name="type">
            <xsl:value-of select="if (substring(type,string-length(@type))='?')
                                  then substring(type,1,string-length(@type)-1)
                                  else @type
                                  "/>
         </xsl:element>
      </xsl:if>
            <xsl:if test="parent::identifying">    <!-- TBD probably need a bit more than this -->
                                             <!-- Hmmmm ... not sure -->
         <xsl:element name="identifying"/>
      </xsl:if>
      <!-- <xsl:apply-templates select="@*|node()" 
                           mode="oldform"/>    -->
   </xsl:copy>
</xsl:template>

</xsl:transform>
