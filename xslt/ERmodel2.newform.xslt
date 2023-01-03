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
   <xsl:message> Initial pass</xsl:message>
   <xsl:variable name="state" as="document-node()">
      <xsl:copy>
         <xsl:apply-templates select="." mode="initial_pass"/>
      </xsl:copy>
   </xsl:variable>
   <!-- I have to structure the above like so otherwise cannot use "//" in the main pass 
        since can only use // if the root of the context used is a document.
   -->
   <xsl:message> main pass</xsl:message>
   <xsl:apply-templates select="$state" mode="newform"/>
</xsl:template>

<xsl:template match="@*|node()" mode="initial_pass">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="initial_pass"/>
   </xsl:copy>
</xsl:template>

<xsl:template  match="entity_type" 
                    mode="initial_pass">
   <xsl:copy>
      <xsl:if test="    (//composition[type=current()/name][identifying])
                     | reference[identifying] 
                     | attribute[identifying]
                    ">
            <has_identifying_feature/>
      </xsl:if>
      <xsl:apply-templates select="@*|node()" 
                           mode="initial_pass"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()" mode="newform">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="newform"/>
   </xsl:copy>
</xsl:template>

<!-- Documentation of difference -->
<!-- The newform has identifying sets of relationships and attributes. --> 
<!-- In the new form if A ::= C|D|E ; then either A has an identifying set or each of C, D and E have identifying sets. This explains the transform from old form defined below. -->
<!-- In the newform if there is a single valued relationship f: A -> B (specified for entity type A)
then f may appear in identifying sets for C, D and E. If it appears in all or none of them then 
f may be flagged in the old model as identifying or not. If it appears in some of the identifying sets 
for C, D or E but not for all then we have a condition which cannot be described in the older form.
-->
<!-- There is a difference, therefore, in what can be expressed in the two forms and the newform is more expressive than the old form. 
Models that utilise the additional power of the new form will not be fully represented by diagrams at least as specified in the oldform. Neither will these new models be supported by code generation in the short term until the newform is naturalised. -->


<xsl:template  match="*[ self::entity_type
                        |self::group
                       ]" 
                    mode="newform">
   <xsl:copy>
      <xsl:if test="name">
         <xsl:attribute name="name" select="name"/>
      </xsl:if>
      <xsl:if test="self::entity_type">
         <xsl:if test="has_identifying_feature and not(descendant::entity_type/has_identifying_feature)">
            <xsl:element name="identifying">
               <xsl:for-each select="//composition[type=current()/name][identifying]">
                  <xsl:element name="context">
                     <xsl:if test="inverse and not(inverse='..')">
                        <xsl:attribute name="name" select="inverse"/>
                        <!-- .. will become a default name -->
                     </xsl:if>
                     <xsl:attribute name="type" select="../name"/> 
                             <!-- source entity type name of incoming identifying composition-->
                  </xsl:element>
               </xsl:for-each>
               <xsl:apply-templates select="reference[identifying]" 
                                    mode="newform"/>
               <xsl:apply-templates select="attribute[identifying]"
                                    mode="newform"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="@*|node()[not(self::reference|self::attribute|self::text())]" 
                           mode="newform"/>
      <xsl:apply-templates select="*[self::reference|self::attribute][not(identifying)]" 
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
      <xsl:apply-templates select="@*|*" mode="newform"/> <!-- don't want copy text nodes -->
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


<xsl:template match="*[ self::dependency
                       | self::name
                       | self::type
                       | self::cardinality
                       | self::identifying
                       | self::has_identifying_feature
                     ]" mode="newform">
   <!-- intentionally left blank -->
</xsl:template>

<xsl:template match="composition/inverse[text()='..']" mode="newform">
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
