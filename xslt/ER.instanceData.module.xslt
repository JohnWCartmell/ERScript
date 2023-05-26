<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:er="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">






<!-- ER.instanceData.module.xslt -->
<xsl:template name="typeTagInstanceData" match="/" mode="explicit">    
    <xsl:copy>
        <xsl:message>ENTER typeTagInstanceData </xsl:message>
        <xsl:for-each select="child::element()">   
            <xsl:variable name="tagTable"
                          as="element()">
                <xsl:call-template name="build_entity_type_tag_table"/>
            </xsl:variable>
            <xsl:apply-templates select="." mode="etTagging">
                <xsl:with-param name="tagTable" select="$tagTable"/>
            </xsl:apply-templates> 
        </xsl:for-each>
        <xsl:message>EXIT typeTagInstanceData </xsl:message>
    </xsl:copy>
</xsl:template>

<xsl:template match="node()" mode="etTagging">
    <xsl:param name="tagTable" as="element()"/>
    <xsl:copy>
        <xsl:for-each select="@*"><xsl:copy/></xsl:for-each>
        <xsl:variable name="taggedElement" 
                      as="element()?"
                      select="$tagTable//*[@source-id = current()/fn:generate-id()]"/>
        <!--<xsl:message>tagged element <xsl:value-of select="current()/fn:generate-id()"/> <xsl:value-of select="exists($taggedElement)"/></xsl:message>-->
        <xsl:if test="exists($taggedElement)">
            <xsl:attribute name="etname" select="$taggedElement/@etname"/>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="etTagging">
            <xsl:with-param name="tagTable" select="$tagTable"/>
        </xsl:apply-templates> 
    </xsl:copy>
</xsl:template>

<xsl:template name="build_entity_type_tag_table">

   <!--<xsl:message>Type tag Instance of type <xsl:value-of select="name()"/></xsl:message>-->
   <xsl:variable name="etlDefn" 
      as="element()?"
      select="$erDataLib?getDefinitionOfInstance(.)
             "/> 
   <xsl:if test="not($etlDefn)">
      <xsl:message terminate="yes">No entity_type_like found that matches element name of instance <xsl:copy-of select="."/></xsl:message>
   </xsl:if>
   <!--<xsl:message> In instance of type <xsl:value-of select="$etlDefn/er:name"/></xsl:message>-->
   <xsl:copy>
        <xsl:attribute name="source-id" select="fn:generate-id()"/>
        <xsl:attribute name="etname" select="$etlDefn/er:name"/>
        <xsl:variable name="instance" as="element()" select="."/>
        <xsl:for-each select="$etlDefn/(self::er:absolute | ancestor-or-self::er:entity_type)/er:composition">   
            <!--<xsl:message>Composition '<xsl:value-of select="$etlDefn/er:name"/>'.'<xsl:value-of select="er:name"/>':'<xsl:value-of select="er:type"/>' </xsl:message>-->
                <xsl:for-each select="$erDataLib?readCompositionRelationship($instance,self::er:composition)">
                  <xsl:call-template name="build_entity_type_tag_table"/>
                </xsl:for-each>
        </xsl:for-each>
   </xsl:copy>
</xsl:template>

</xsl:transform>