<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box ->
Created 16 Jan 2022
 -->

<xsl:output method="xml" indent="yes"/>



   <!-- ************************** -->
   <!-- route  +path       -->
   <!-- ************************** -->

   <xsl:template match="route[top_down]
                   [not(path)]
                  " 
         mode="recursive_diagram_enrichment"
         priority="250">        
      <xsl:copy>
         <xsl:apply-templates mode="recursive_diagram_enrichment"/>
         <path>
            <ew><source_sweep/></ew>
            <ramp/>
            <ew><destination_sweep/></ew>
         </path>
      </xsl:copy>
   </xsl:template>


   <!-- ************************** -->
   <!-- route  +path       -->
   <!-- ************************** -->
   <xsl:template match="route[not(topdown)]
                  [not(path)]
                  " 
         mode="recursive_diagram_enrichment"
         priority="250">        
      <xsl:copy>
         <xsl:apply-templates select="*" mode="recursive_diagram_enrichment"/>
         <path>
            <ramp/>
         </path>
      </xsl:copy>
   </xsl:template>   

   <!-- ************************** -->
   <!-- route  +path       -->
   <!-- ************************** -->
   <!--                                                                  -->
   <!-- all about sweeping to the side to get a recursive top down -->
                         
   <!--                   
                      +.....destination sweep...+
                      |                         |
               +=============+                  |
               |             |                  |
               |             |                  |
               +=============+                  |
                      |                         |
                      |                         |
                      +.......source sweep......+

   -->

   <xsl:template match="route[top_down]
                   [not(path)]
                  " 
         mode="recursive_diagram_enrichment"
         priority="250">        
      <xsl:copy>
         <xsl:apply-templates mode="recursive_diagram_enrichment"/>
         <path>
            <ew><source_sweep/></ew>
            <ramp/>
            <ew><destination_sweep/></ew>
         </path>
      </xsl:copy>
   </xsl:template>


</xsl:transform>

