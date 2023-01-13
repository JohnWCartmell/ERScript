<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0" xmlns="http://www.entitymodelling.org/diagram" xmlns:diagram="http://www.entitymodelling.org/diagram" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.entitymodelling.org/diagram">
  <!--  Maintenance Box 

 -->
  <xsl:output indent="yes" method="xml"/>

  <!-- enclosure/label/text -->
  <xsl:template match="label                      
                       [not(text)]                      
                       [../id]" 
                       mode="recursive_diagram_enrichment" priority="20">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <text>
        <xsl:value-of select="../id"/>
      </text>
    </xsl:copy>
  </xsl:template>
</xsl:transform>