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
                       [path/*[self::ns | self::ew]/startarm]
                       /source
                       [../path/point[startpoint]/xP/at/offset]
                       [../path/point[startpoint]/wlP]
                       [not(x_lower_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="340">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
  	  <x_lower_boundP>
  	       <xsl:value-of select="../path/point[startpoint]/(xP/at/offset - wlP)"/>
  	  </x_lower_boundP>
    </xsl:copy>
  </xsl:template> -->
  
<!--   <xsl:template match="route
                       [path/*[self::ns | self::ew]/endarm]
                       /destination
                       [../path/point[endpoint]/xP/at/offset]
                       [../path/point[endpoint]/wlP]
                       [not(x_lower_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="340">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
	  <x_lower_boundP>
	       <xsl:value-of select="../path/point[endpoint]/(xP/at/offset - wlP)"/>
	  </x_lower_boundP>
    </xsl:copy>
  </xsl:template> -->

     <!-- **************************************************
       2 June ramp rules                           
       without these rules there is a deadly embrace.
       because label position depdends on bearing which depends 
       on absolute positioning of source and destination enclosures 
       which depends on wr and wl which depends
       on extent of labels which depends on their position
       ***************************************************
  -->
<!-- 5 JUne 2025 BUT I have a deadly embrace for othogonals also. 
     Not sure what the outcome will be but comment out above rules and
     generalise the rules written for ramps to apply to ns and ew also -->
    <xsl:template match="route
                        [path/*/startarm] (:was ramp :)
                        [path/point[startpoint]/xP/at/offset]
                        /source
                        [every $label in ../path/point[startpoint]/label satisfies $label/wP]
                        [not(x_lower_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">

              <!-- was 
                        [not(annotation) or exists(../path/point[startpoint]/label/primary)]
              -->

    <xsl:variable name="fudgefactor" as="xs:double" select="10"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x_lower_boundP>
           <xsl:value-of select="
                       ../path/point[startpoint]/xP/at/offset -
                                 max((../path/point[startpoint]/label/wP,0)) - $fudgefactor"/>
      </x_lower_boundP>
      </xsl:copy>
  </xsl:template>
  
    <xsl:template match="route
                        [path/*/endarm]  (: was ramp :)
                        [path/point[endpoint]/xP/at/offset]
                        /destination
                        [every $label in ../path/point[endpoint]/label satisfies $label/wP]
                        [not(x_lower_boundP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="350">

                <!-- was 
                        [not(annotation) or exists(../path/point[endpoint]/label/primary)]
              -->

    <xsl:variable name="fudgefactor" as="xs:double" select="0.1"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <x_lower_boundP>
           <xsl:value-of select="
                       ../path/point[endpoint]/xP/at/offset -
                                 max((../path/point[endpoint]/label/wP,0)) - $fudgefactor"/>
      </x_lower_boundP>
      </xsl:copy>
  </xsl:template>
  
</xsl:transform>

