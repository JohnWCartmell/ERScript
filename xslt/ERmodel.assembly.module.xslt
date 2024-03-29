<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
   <xsl:strip-space elements="*"/>

   <xsl:template match="@*|node()" mode="assembly">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="assembly"/>
      </xsl:copy>
   </xsl:template>

<!-- was <xsl:apply-templates select="document(@filename)/entity_model/*" mode="assembly"/> -->

   <xsl:template match="include_model" mode="assembly">
      <!-- Note that this implementation supports recursive includes -->
      <xsl:message>In include_model ... filename '<xsl:value-of select="@filename"/>'</xsl:message>
      <xsl:variable name="included_entity_model" 
                     as="element(entity_model)"
                     select="document(@filename,$docnode)/entity_model"/>
                     <!-- also test using saxon doc function in place of document -->
      <xsl:variable name="included_entity_model_after_parsing_if_required"
                     as="element(entity_model)">
         <xsl:apply-templates select="$included_entity_model" mode="parse__conditional"/>
      </xsl:variable>
      
       <xsl:apply-templates select="$included_entity_model_after_parsing_if_required/*" mode="assembly"/>
   </xsl:template>

</xsl:transform>
