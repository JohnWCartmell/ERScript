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


<!-- *************** -->
<!-- diagram/depth -->
<!-- *************** -->
<xsl:template match="diagram[not(depth)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="80">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <depth><xsl:value-of select="0"/></depth>
   </xsl:copy>
</xsl:template>


<!-- *************** -->
<!-- box/depth       -->
<!-- *************** -->

<xsl:template match="*[self::enclosure|self::label|self::point|self::ns|self::ew|self::ramp]
	                          [not(depth)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="80" >
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	  <!-- In following sum the final term will always be 1 -->
      <depth><xsl:value-of select="  count(../ancestor-or-self::enclosure)
	                               + count(../ancestor-or-self::point)
								   + count(../ancestor-or-self::diagram)"/></depth>
   </xsl:copy>
</xsl:template>

<!--
<xsl:template match="enclosure[not(depth)]
                              [../depth]
                    " 
              mode="recursive_diagram_enrichment"
              priority="80">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <depth><xsl:value-of select="../depth + 1"/></depth>
   </xsl:copy>
</xsl:template>
-->

<!-- *************** -->
<!-- path/depth -->
<!-- *************** -->
<!--
<xsl:template match="path[not(depth)]
                              [not(parent::enclosure)]
                    " 
              mode="recursive_diagram_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <depth><xsl:value-of select="1"/></depth>
   </xsl:copy>
</xsl:template>

<xsl:template match="path[not(depth)]
                              [../depth]
                    " 
              mode="recursive_diagram_enrichment">
   <xsl:message>path depth</xsl:message>
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <depth><xsl:value-of select="../depth + 1"/></depth>
   </xsl:copy>
</xsl:template>
-->



</xsl:transform>

