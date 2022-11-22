<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:output method="xml" indent="yes"/>

   <xsl:template match="/">
      <xsl:message> In root entity in 2.description_template which is <xsl:value-of select="name()"/></xsl:message>
      <xsl:copy>
        <xsl:apply-templates select="*" mode="description_template"/>
      </xsl:copy>
   </xsl:template>


   <xsl:template match="@*|node()" mode="description_template">
   </xsl:template>

   <xsl:template match="entity_model" mode="description_template">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="description_template"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[self::absolute|self::entity_type|self::group]"
                 mode="description_template">
      <xsl:copy>
         <xsl:copy-of select="name" copy-namespaces="no"/>
            <xsl:element name="description" namespace="http://www.entitymodelling.org/ERmodel">
               <xsl:choose>
                  <xsl:when test="description">
                     <xsl:copy-of select="description/(*|text())"/>
                  </xsl:when>
                  <xsl:when test="exists(entity_type)">
                     <xsl:text>A generalisation of the types </xsl:text>
                     <xsl:for-each select="entity_type">
                        <xsl:value-of select="name"/>
                        <xsl:value-of select="if (count(following-sibling::entity_type)&gt; 1) then ', ' 
                                              else if (following-sibling::entity_type) then ' and ' else '.'"/>
                     </xsl:for-each> 
                      <xsl:text>.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>An entity type.</xsl:text>
                      <xsl:value-of select="type/*/name()"/>
                      <xsl:text>.</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:element>
            <xsl:apply-templates select="*" mode="description_template"/>
      </xsl:copy>   
   </xsl:template>

   <xsl:template match="*[self::attribute]"
                 mode="description_template">
      <xsl:copy copy-namespaces="no"> <!-- <attribute> -->
         <xsl:copy-of select="name" copy-namespaces="no"/>
         <xsl:element name="description" namespace="http://www.entitymodelling.org/ERmodel">
            <xsl:choose>
               <xsl:when test="description">
                  <xsl:copy-of select="description/(*|text())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>An attribute of type</xsl:text>
                   <xsl:value-of select="type/*/name()"/>
                   <xsl:text>.</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="*[self::reference|self::composition|self::dependency|self::constructed_relationship]"
                 mode="description_template">
      <xsl:copy>
          <xsl:copy-of select="name" copy-namespaces="no"/>
          <xsl:copy-of select="type" copy-namespaces="no"/>
         <xsl:element name="description" namespace="http://www.entitymodelling.org/ERmodel">
               <xsl:copy-of select="description/(*|text())"/>
               <xsl:text>.</xsl:text>
         </xsl:element>
      </xsl:copy>
   </xsl:template>
         
</xsl:transform>
