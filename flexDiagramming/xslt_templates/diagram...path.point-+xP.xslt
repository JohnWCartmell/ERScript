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



  <!-- **************** -->
  <!-- path/point   =xP     -->
  <!-- **************** -->
  <!-- point => xP derived from preceding or following nsP.xP 
                             or from preceding (ewP|ramp) endxP
                             or from following (ewP|ramp) startxP
-->
  <xsl:template match="path/point[not(xP)]
                                [following-sibling::*[1][self::nsP]/point/xP]"
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:copy-of select="following-sibling::*[1][self::nsP]/point/xP"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="path/point[not(xP)]
                                [preceding-sibling::*[1][self::nsP]/point/xP]"
                                  mode="recursive_diagram_enrichment"                              
                                  priority="56">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xsl:copy-of select="preceding-sibling::*[1][self::nsP]/point/xP"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="path/point[not(xP)]
                                [following-sibling::*[1][self::ewQ|self::ramp]/startxP]"
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xP>
        <relative>
          <offset>
            <xsl:value-of select="following-sibling::*[1][self::ewQ|self::ramp]/startxP"/>
          </offset>
        </relative>
      </xP>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="path/point[not(xP)]
                                [preceding-sibling::*[1][self::ewQ|self::ramp]/endxP]"
                                  mode="recursive_diagram_enrichment"
                                  priority="56">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xP>
        <relative>
          <offset>
            <xsl:value-of select="preceding-sibling::*[1][self::ewQ|self::ramp]/endxP"/>
          </offset>
        </relative>
      </xP>
    </xsl:copy>
  </xsl:template>
  
  

  <!-- ********** -->
  <!-- path/nsP +xP -->
  <!-- ********** -->
  
  <xsl:template match="path/nsP
                               [preceding-sibling::*[1][self::point]/xP]
							   /point[not(xP)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
        <xsl:copy-of select="../preceding-sibling::*[1][self::point]/xP"/>
    </xsl:copy>
  </xsl:template>

   <xsl:template match="path/nsP
                               [following-sibling::*[1][self::point]/xP]
							   /point[not(xP)]
                      "
                                  mode="recursive_diagram_enrichment"
                                  priority="56">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
        <xsl:copy-of select="../following-sibling::*[1][self::point]/xP"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>

