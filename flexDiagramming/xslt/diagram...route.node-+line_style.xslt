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

<!-- ********************** -->
<!-- node    +line_style -->
<!-- ********************** -->
<xsl:template match="*[self::source|self::destination]
                      [not(line_style)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="38">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
<!--       <endline_style><xsl:value-of select="(ancestor-or-self::*/default/end_style)[last()]"/></endline_style> --> <!-- change 5-Nov-2024 -->
       <line_style><xsl:value-of select="(ancestor-or-self::*/default/line_style)[last()]"/></line_style>
   </xsl:copy>
</xsl:template>

</xsl:transform>

