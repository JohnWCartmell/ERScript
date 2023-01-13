<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

  <!--  Maintenance Box 

 -->

  <xsl:output method="xml" indent="yes"/>



  
  <!-- ********** -->
  <!-- path/ramp  -->
  <!-- ********** -->
  <!-- 
          deltaxP => endxP - startxP
   -->
  <xsl:template match="path/ramp[not(deltaxP)]
                               [startxP]
                               [endxP]
                    "
                                  mode="recursive_diagram_enrichment"
                                  priority="55P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltaxP>
        <xsl:value-of select="endxP - startxP"/>
      </deltaxP>
    </xsl:copy>
  </xsl:template>

  <!-- path/ramp
          deltax => deltay / tan degrees
  -->
  <xsl:template match="path/ramp[not(deltaxP)]
                               [deltayP]
                               [degrees]
                    "
                                  mode="recursive_diagram_enrichment"
                                  priority="56P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltaxP>
        <xsl:value-of select="deltayP div diagram:tanP(degrees)"/>
      </deltaxP>
    </xsl:copy>
  </xsl:template>

 <!-- ************************* -->
<!--ewP[source_sweep] + deltax  -->               <!-- NEED TP FULLY PARAMETERISE FOR NS CARDINAL -->
<!-- ************************** -->

<xsl:template match="route[top_down]/path/ewP[source_sweep]
                      [not(deltax)]
                      [../../source/thisEndy]
                      [../../source/otherEndy]
                      [../../source/thisEndx]
                      [../../source/otherEndx]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="56P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax><xsl:value-of select=
               "if (../../source/(number(otherEndy) &gt; number(thisEndy)) )
               then 0
               else if (../../source/(number(otherEndx) &lt; number(thisEndx)) )
               then - 1
               else 1 "/>
      </deltax>
   </xsl:copy>
</xsl:template>

<!-- ******************************** -->
<!--ewP[destination_sweep] + deltax   -->               <!-- NEED TO FULLY PARAMETERISE FOR NS CARDINAL -->
<!-- ******************************** -->

<xsl:template match="route[top_down]/path/ewP[destination_sweep]
                      [not(deltax)]
                      [../../destination/thisEndy]
                      [../../destination/otherEndy]
                      [../../destination/thisEndx]
                      [../../destination/otherEndx]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="56P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax><xsl:value-of select=
               "if (../../destination/(number(otherEndy) &lt; number(thisEndy)) )
               then 0
               else if (../../destination/(number(otherEndx) &lt; number(thisEndx)) )
               then 1
               else - 1 "/>
      </deltax>
   </xsl:copy>
</xsl:template>


</xsl:transform>

