<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box ->
23 September 2021 Modify so that first enclosed enclosures placed after any preceeding labels.
 -->

<xsl:output method="xml" indent="yes"/>

<!-- *********** -->
<!-- enclosure  +x -->
<!-- *********** -->
<!-- add [not(preceding-sibling::label)]   -->

<xsl:template match="enclosure
                     [not(x)]
                     [not(preceding-sibling::enclosure)]
					 [not(preceding-sibling::label)]
                    " mode="recursive_diagram_enrichment"
              priority="50">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x>
        <at><left/><margin/><parent/></at>
      </x>
   </xsl:copy>
</xsl:template>

<!-- change to [preceding-sibling::*[self::label|self::enclosure]] -->
<xsl:template match="enclosure
                     [not(x)]
                     [preceding-sibling::*[self::label|self::enclosure]]
                    " mode="recursive_diagram_enrichment"
              priority="50">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x>
        <at><right/><outer/><predecessor/></at>
      </x>
   </xsl:copy>
</xsl:template>

<!-- ******************************* -->
<!-- (diagram|enclosure)/label  +x  -->
<!-- ******************************* -->


<xsl:template match="*[self::diagram|self::enclosure]/label
                     [not(x)]
                     [not(preceding-sibling::label)]
					 [count(parent::*/*[self::label|self::enclosure])=1]
                    " mode="recursive_diagram_enrichment"
              priority="50">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x>
        <at><centre/><edge/><parent/></at>
      </x>
   </xsl:copy>
</xsl:template>


<xsl:template match="*[self::diagram|self::enclosure]/label
                     [not(x)]
                     [not(preceding-sibling::label)]
					 [not(count(parent::*/*[self::label|self::enclosure])=1)]
                    " mode="recursive_diagram_enrichment"
              priority="50">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x>
        <at><left/><margin/><parent/></at>
      </x>
   </xsl:copy>
</xsl:template>


<!-- NON SYMETRIC RULES !!!!!!!  
     Therefore sourced as <x> and <y> and *not* sourced as <x>
-->

<!-- *********** -->
<!-- label/x    -->
<!-- *********** -->

<xsl:template match="*[self::diagram|self::enclosure]/label
                     [not(x)]
                     [preceding-sibling::label]
                    " mode="recursive_diagram_enrichment"
              priority="50">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x>
        <place><left/><edge/></place><at><left/><edge/><predecessor/></at>
      </x>
   </xsl:copy>
</xsl:template>


<xsl:template match="*[self::diagram|self::enclosure]/label
                     [not(y)]
                     [preceding-sibling::label]
                    " mode="recursive_diagram_enrichment"
              priority="52">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <y>
        <at><bottom/><edge/><predecessor/></at>
      </y>
   </xsl:copy>
</xsl:template>


</xsl:transform>

