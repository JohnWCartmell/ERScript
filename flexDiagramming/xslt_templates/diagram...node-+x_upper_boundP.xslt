<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

  <!--  
DESCRIPTION
 -->

  <xsl:output method="xml" indent="yes"/>

<!--   <xsl:template match="route
                       [path/*[self::ns | self::ew]/endarm]
                       [path/point[startpoint]/xP/at/offset]
                       [path/point[startpoint]/wrP]
                       /source
                       [not(x_upper_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
  	  <x_upper_boundP>
  	       <xsl:value-of select="../path/point[startpoint]/(xP/at/offset + wrP)"/>
  	  </x_upper_boundP>
    </xsl:copy>
  </xsl:template> -->
  
<!--   <xsl:template match="route
                       [path/*[self::ns | self::ew]/endarm]
                       [path/point[endpoint]/xP/at/offset]
                       [path/point[endpoint]/wrP]
                       /destination
                       [not(x_upper_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
  	  <x_upper_boundP>
  	       <xsl:value-of select="../path/point[endpoint]/(xP/at/offset + wrP)"/>
  	  </x_upper_boundP>
    </xsl:copy>
  </xsl:template> -->

   <!-- **************************************************
       2 June ramp rules                           
       without these rules there is a deadly embrace.
       becaus elabel psotion depdends on bearing which depends 
       on absolute positioning of source and destination enclosures 
       which depends on wr and wl which depends
       on extent of labels which depends on their position
       ***************************************************
  -->
  <!-- likewise with ns and ew on 5 June 2025 -->
    <xsl:template match="route
                         [path/point[startpoint]/xP/at/offset]
                         [path/*/startarm] (: was ramp :)
                         /source
                         [every $label in ../path/point[startpoint]/label satisfies $label/wP]
                         [not(x_upper_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">
              <!-- was
                         [not(annotation) or exists(../path/point[startpoint]/label/primary)]
              -->

    <xsl:variable name="fudgefactor" as="xs:double" select="0.1"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x_upper_boundP>
           <xsl:value-of select="
                       ../path/point[startpoint]/xP/at/offset +
                                 max((../path/point[startpoint]/label/wP,0)) + $fudgefactor"/>
      </x_upper_boundP>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="route
                       [path/*/endarm] (:was ramp :)
                       [path/point[endpoint]/xP/at/offset]
                       /destination
                       [every $label in ../path/point[endpoint]/label satisfies $label/wP]
                       [not(x_upper_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">
              <!-- was
                       [not(annotation) or exists(../path/point[endpoint]/label/primary)]
              -->
    <xsl:variable name="fudgefactor" as="xs:double" select="0.1"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x_upper_boundP>
           <xsl:value-of select="
                       ../path/point[endpoint]/xP/at/offset +
                                 max((../path/point[endpoint]/label/wP,0)) + $fudgefactor"/>
      </x_upper_boundP>
      </xsl:copy>
  </xsl:template>

  
</xsl:transform>

