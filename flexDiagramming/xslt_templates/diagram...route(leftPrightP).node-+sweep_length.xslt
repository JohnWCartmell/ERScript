<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

	<xsl:output method="xml" indent="yes"/>


<xsl:template match="route 
                     /*[self::source|self::destination]
                           [thisEndxP][thisEndyP][otherEndxP][otherEndyP]
                           [*[self::right_sideP|self::left_sideP]/deltayP]
                           [not(sweep_length)]
                    " 
                  mode="recursive_diagram_enrichment"
                  priority="342P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <sweep_length><xsl:value-of select=
               "let $edge  := *[self::right_sideP|self::left_sideP] treat as element(*),
                    $enclosurehP  := key('Enclosure',id)/hP cast as xs:double
               return 
                   if (
                       (self::source and (number(otherEndxP) &gt; number(thisEndxP)))
                       or
                       (self::destination and (number(otherEndxP) &lt; number(thisEndxP)))
                      ) 
                   then 0
                   else if (number(otherEndyP) &lt; number(thisEndyP) )
                   then (:sweep in negative direction :)
                        let $numberToSweepAround := $edge/slotNo
                        return
                        -0.3 - $edge/deltayP - 0.15 * $numberToSweepAround
                   else (:sweep positive direction :)
                        let $numberToSweepAround := $edge/(noOfSlots - slotNo - 1),
                            $distanceToCorner := $enclosurehP - $edge/deltayP
                        return
                        0.3 +  $distanceToCorner + 0.15 * $numberToSweepAround "/>
      </sweep_length>
   </xsl:copy>
</xsl:template>

<!--       <deltax><xsl:value-of select=
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
-->


</xsl:transform>

