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


<!-- new 5 Sept 2025 -->

<!-- WILL NOT NEED THIS -->
<!--   <xsl:template match="route[source[exitContainer]/left_edgeP]
                       /path/point[not(xP)]
                                [preceeding-sibling::*[1][self::ewP/startarm]
                                ]"
                                  mode="recursive_diagram_enrichment"
                                  priority="55">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <xP>
        <rule>point following ewP[startarm] has xP calculated "diagram...path.point-+xP.xslt"</rule>
        <xsl:choose>
          <xsl:when test=" followed by source sweep">
            <subrule>Followed by source_sweep "diagram...path.point-+xP.xslt"</subrule>
        </xsl:when>
        <xsl:otherwise>
            <subrule>Not followed by source_sweep "diagram...path.point-+xP.xslt"</subrule>
          <xsl:value-of select="xxxx"/>
        </xsl:otherwise>
        </xsl:choose>
      </xP>
    </xsl:copy>
  </xsl:template> -->

  <!-- based on previous
      <deltay>
        <xsl:value-of select="
        let $increment := 0.1,
        $slotNo := ../../source/bottom_edge/slotNo,
        $noOfSlots := ../../source/bottom_edge/noOfSlots,
        $noOfIncrements := if ($slotNo &lt; ($noOfSlots div 2))
                           then $slotNo
                           else $noOfSlots - $slotNo - 1
        return max((
          key('line_style',../../source/line_style)/minarmlen
                   + $noOfIncrements * $increment, 
          key('box',../../source/id)/hb
          ))"/>
      </deltay>
-->


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
      <rule>into path/point copy xP from following sibling nsP point "diagram...path.point-+xP.xslt"</rule>
      <xsl:copy-of select="following-sibling::*[1][self::nsP]/point/xP"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="path/point[not(xP)]
                                [preceding-sibling::*[1][self::nsP]/point/xP]"
                                  mode="recursive_diagram_enrichment"                              
                                  priority="56">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <rule>into path/point copy xP from preceding sibling nsP point "diagram...path.point-+xP.xslt"</rule>
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
        <rule>copy xP  offset from  following sibling ewQ or ramp startxP "diagram...path.point-+xP.xslt"</rule>
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
        <rule>copy xP offset from endxP of preceding sibling ewQ or ramp "diagram...path.point-+xP.xslt"</rule>
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

        <rule>into nsP copy xP from preceding sibling point "diagram...path.point-+xP.xslt"</rule>
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
              <rule>into nsP copy xP from following sibling point "diagram...path.point-+xP.xslt"</rule>
        <xsl:copy-of select="../following-sibling::*[1][self::point]/xP"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>

