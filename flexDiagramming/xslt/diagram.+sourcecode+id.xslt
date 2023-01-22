<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->

<xsl:output method="xml" indent="yes"/>

<xsl:template match="*[self::enclosure|self::route][not(sourcecode)]" 
              mode="recursive_diagram_enrichment"
              priority="999999"> <!-- HIGHEST PRIORITY -->
   <xsl:copy>
      <!-- While I am here create and id for any enclosure of route which doesn't have one
           this will be used for linking an svg object to its assocaited pop-up infobox.
      -->
      <xsl:if test="not(id)">
         <xsl:element name="id">
            <xsl:text>SVG</xsl:text><xsl:value-of select="name()"/><xsl:number level="any"/>
         </xsl:element>
      </xsl:if>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>

      <xsl:variable name="shallow_copy">
         <xsl:call-template name="shallow_copy"/>
      </xsl:variable>
      <xsl:element name="sourcecode">
         <xsl:value-of select="serialize($shallow_copy, map{'indent':true()})"/>
      </xsl:element>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::enclosure|self::route]" 
              name="shallow_copy"
              mode="explicit">
   <xsl:copy>
      <xsl:apply-templates mode="shallow_copy"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*[self::enclosure|self::route]" 
              mode="shallow_copy" >
   <xsl:copy>
      <xsl:copy-of select="id"/>
      <xsl:text>...</xsl:text>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" 
              mode="shallow_copy" >
   <xsl:copy>
      <xsl:apply-templates mode="shallow_copy"/>
   </xsl:copy>
</xsl:template>

</xsl:transform>

