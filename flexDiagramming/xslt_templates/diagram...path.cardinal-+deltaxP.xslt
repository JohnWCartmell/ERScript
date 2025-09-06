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
<!-- logic moved into diagram...route.node-+sweep_length.xslt -->
<!--******************************************************** -->
<!-- START FOR DELETION -->
<xsl:template match="route  (:[top_down]:)
                          [source[thisEndx][thisEndy][otherEndx][otherEndy]
                            /bottom_edge/deltax
                          ]
                      /path/ewP
                        [source_sweep]
                        [not(deltax)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="56P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax><xsl:value-of select=
               "let $node  := ../../source treat as element(source),
                    $edge  := $node/bottom_edge,
                    $enclosureWidth  := key('Enclosure',$node/id)/w cast as xs:double
               return 
                   if ($node/(number(otherEndy) &gt; number(thisEndy)) )
                   then 0
                   else if ($node/(number(otherEndx) &lt; number(thisEndx)) )
                   then (:sweep left :)
                        let $numberToSweepAround := $edge/slotNo
                        return
                        -0.3 - $edge/deltax - 0.15 * $numberToSweepAround
                   else (:sweep right :)
                        let $numberToSweepAround := $edge/(noOfSlots - slotNo - 1),
                            $distanceToCorner := $enclosureWidth - $edge/deltax
                        return
                        0.3 +  $distanceToCorner + 0.15 * $numberToSweepAround "/>
      </deltax>
   </xsl:copy>
</xsl:template> 


<!-- ******************************** -->
<!--ewP[destination_sweep] + deltax   -->               <!-- NEED TO FULLY PARAMETERISE FOR NS CARDINAL -->
<!-- ******************************** -->

<xsl:template match="route  (:[top_down]:)
                          [destination[thisEndx][thisEndy][otherEndx][otherEndy]
                            /top_edge/deltax
                          ]
                      /path/ewP
                        [destination_sweep]
                        [not(deltax)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="56P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <deltax><xsl:value-of select=
                 "let $node  := ../../destination treat as element(destination),
                      $edge  := $node/top_edge,
                      $enclosureWidth  := key('Enclosure',$node/id)/w cast as xs:double
                  return if ($node/(number(otherEndy) &lt; number(thisEndy)) )
                          then 0
                          else if ($node/(number(otherEndx) &lt; number(thisEndx)) )
                          then (:sweep left :)
                                let $numberToSweepAround := $edge/slotNo
                                return 
                                    0.3 + $edge/deltax + 0.15 * $numberToSweepAround
                          else (:sweep right :)
                                let $numberToSweepAround := $edge/(noOfSlots - slotNo - 1),
                                    $distanceToCorner := $enclosureWidth - $edge/deltax
                                return
                                -0.3 -  $distanceToCorner - 0.15 * $numberToSweepAround 
                  "/>
      </deltax>
   </xsl:copy>
</xsl:template>
<!-- Final rule Delete source_sweep or destination_sweep which has length zero -->
<xsl:template match="route/path
                       [ewP[deltaxP = 0]]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="56P">
   <xsl:copy>
      <xsl:apply-templates select="*[not(self::ewP[deltaxP=0])]" mode="recursive_diagram_enrichment"/>
      <!-- <xsl:message>Deleted <xsl:copy-of select="*[self::ewP[deltaxP=0]]"/></xsl:message> -->
   </xsl:copy>
</xsl:template>

<!-- END FOR DELETION !!!!!!!!!!!!!!!!!!--> 

</xsl:transform>

