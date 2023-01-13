<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

  <!--  
****************************************
diagram.addressing.xw.smarts.module.xslt
****************************************

DESCRIPTION
  This xslt contains rules to implement diagram
  xP and wP structure from higher level directives
  to position enclosures wrPt other enclosures
  It is a template with vbls xP, wP etc so that by substitution, See readme.


CHANGE HISTORY
        JC  26-May-2017 Created. 
		JC  24-Jul-2019 Modified to template.

 -->

  <xsl:output method="xml" indent="yes"/>

  <!-- ********************************** -->
  <!-- xP/at/src_rise -->
  <!-- xP/at/dest_rise -->

  <xsl:template match="xP/at[not(src_rise)]
                           [../../depth]
                           [key('box',of)/depth]
                    " 
              mode="recursive_diagram_enrichment"
              priority="169P"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <src_rise>
        <xsl:value-of select="../../depth - 
                                (  ancestor::*
                                      intersect
                                   (key('box',of)/ancestor::*)
                                )[not(self::route)][last()]/depth
                                      "/>
      </src_rise>
      <dest_rise>
        <xsl:value-of select="key('box',of)/depth - 
                                (  ancestor::*
                                      intersect
                                   (key('box',of)/ancestor::*)
                                ) [not(self::route|self::path)][last()]/depth
                                      "/>  <!-- added self::side now removed -->
      </dest_rise>
    </xsl:copy>
  </xsl:template>

  <!-- Add defaults for relative of an at  -->
  <!-- if no preceding boxes then parent   -->  <!-- NEED complete the enumeration of the box types -->
  <!-- else predecessor                    -->
  <xsl:template match="*[self::enclosure|self::label]/xP/at[not(of|parent|predecessor)]
                                     [not(preceding-sibling::enclosure|preceding-sibling::label)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <parent/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[self::enclosure|self::label]/xP/at[not(of|parent|predecessor)]
                                     [preceding-sibling::enclosure|preceding-sibling::label]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <predecessor/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Add defaults for at anchor -->  <!-- new rule 29 July 2019 -->
  <!-- xP/at          - left   -->
    <xsl:template match="*/xP/at[not(leftP | rightP | centreP | xP)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
       <leftP/>
       <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  

  <!-- Add defaults for at aspect                      -->
  <!-- enclosure/xP[place[leftP]/at/leftP    - edge    --> 
  <!-- enclosure/xP[place[leftP]/at/rightP   - outer   --> 
  <!-- enclosure/xP[place[rightP]/at/leftP   - outer   --> 
  <!-- enclosure/xP[place[rightP]/at/rightP  - edge    -->  
  <!-- xP/at/(centreP|xP)                    - edge    -->
  
  <!-- 17 June 2019 modifed precondition for outer from [of] to [of|predecessor] -->
  
  <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP[place/leftP]/at[not(margin|edge|outer)]
                                     [leftP]
                                     [of|predecessor]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
   <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP[place/leftP]/at[not(margin|edge|outer)]
                                     [rightP]
                                     [of|predecessor]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <outer/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
    <xsl:template match="*
                         [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                         /xP[place/rightP]/at[not(margin|edge|outer)]
                                     [leftP]
                                     [of|predecessor]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <outer/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
   <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP[place/rightP]/at[not(margin|edge|outer)]
                                     [rightP]
                                     [of|predecessor]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
 
  
  <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP/at[not(margin|edge|outer)]
                                    [centreP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP/at[not(margin|edge|outer)]
                                     [rightP|leftP]
                                     [parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <margin/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  
    <xsl:template match="*
                        [not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP/at[not(margin|edge|outer)]
                                       [xP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>

  
  <!-- Add defaults for place    aspect               -->
  <!-- enclosure/xP[at/rightP]/place/(leftP)   - outer   -->  <!-- modifed 29th July 2019 -->
  <!-- enclosure/xP[at/rightP]/place/(rightP)  - edge   -->  <!-- modifed 29th July 2019 -->
  <!-- enclosure/xP[at/leftP]/place/(leftP)    - edge   -->  <!-- modifed 29th July 2019 -->
  <!-- enclosure/xP[at/leftP]/place/(rightP)   - outer   -->  <!-- modifed 29th July 2019 -->
  <!-- ABOVE 4 rules USED TO BE 1 rule LESS SPECIFIC enclosure/xP/place/(rightP|leftP)       - outer   -->
  <!-- not(enclosure)/xP/place/(rightP|leftP)  - edge   -->
  <!-- xP/place/(centreP|x)                   - edge    -->
  
  <xsl:template match="enclosure/xP[at/rightP]/place[not(margin|edge|outer)]
                                          [leftP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <outer/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="enclosure/xP[at/rightP]/place[not(margin|edge|outer)]
                                        [rightP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
   <xsl:template match="enclosure/xP[at/leftP]/place[not(margin|edge|outer)]
                                          [leftP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="enclosure/xP[at/leftP]/place[not(margin|edge|outer)]
                                        [rightP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <outer/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="enclosure/xP/place[not(margin|edge|outer)]
                                        [centreP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="enclosure/xP/place[not(margin|edge|outer)]
                                        [xP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*[not(self::enclosure)]/xP/place[not(margin|edge|outer)]
                                                      [leftP|centreP|rightP|xP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
         <edge/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  
 
  
      
  <!-- Rules for effective_ratio attribute of xanchor -->
  <!-- where xanchor ::= leftP | centreP | rightP | xP(3) -->
  <xsl:template match="leftP[not(effective_ratio)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="171P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <effective_ratio>0</effective_ratio>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[self::at|self::place]/xP[not(effective_ratio)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="171P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <effective_ratio><xsl:value-of select="ratio"/></effective_ratio>  <!-- changed from zero 1Aug 2019 -->
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="centreP[not(effective_ratio)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="171P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <effective_ratio>0.5</effective_ratio>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="rightP[not(effective_ratio)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="171P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <effective_ratio>1.0</effective_ratio>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- DERIVATION OF VALUE FOR ATTRIBUTE offset of entity type at(2) -->
  <!-- WAS enclosure/xP-->


 <xsl:template match="xP/at[not(offset)]
                           [of]
                           [*/effective_ratio]
                           [key('box',of)/padding]
                           [leftP or key('box',of)/wP ]
                           [rightP or edge or key('box',of)/wlP]
                           [leftP or edge or key('box',of)/wrP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>

      <offset trace="9">
          <xsl:choose>
             <xsl:when test="leftP">
                  <xsl:variable name="offset" as="xs:double" select="if (leftP and outer) then -key('box',of)/(wlP + padding) else 0"/>
                  <xsl:value-of select="$offset"/>
             </xsl:when>
             <xsl:otherwise>
                  <xsl:variable name="effective_width"
                                select = "key('box',of)/wP 
                                           + (if(outer) 
                                              then (key('box',of)/(wrP + padding))
                                              else 0
                                              )"/>
                  <xsl:variable name="offset" as="xs:double"  select="*/effective_ratio 
                                                                     * $effective_width"/>
                  <xsl:value-of select="$offset"/>
             </xsl:otherwise>
          </xsl:choose>
      </offset>      
     </xsl:copy>
  </xsl:template>


<!--  23 September 2021 Use new attribute x_outer_upper_bound because labels do not have wrP attribute -->
<!--  would like to split the  existing rule into as many as four rules -->
<!--  start by splitting into two rules and then testing -->

<!-- new rule split off for leftP-->
 <xsl:template match="xP/at[not(offset)]
                           [predecessor]
						   [leftP]	
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/padding]
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wlP]						   
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset>
            <xsl:value-of select="if (outer) then -../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/(wlP + padding) else 0"/>
      </offset>      
     </xsl:copy>
  </xsl:template>
  
  <!-- not(leftP)  and outer -->
 <xsl:template match="xP/at[not(offset)]
                           [predecessor]
						   [rightP | centreP]
						   [outer]
                           [*/effective_ratio]
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/padding]
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wP ]
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wrP]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="8B">
                  <xsl:variable name="effective_width"
                                select = "../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wP 
								            + ../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/(wrP + padding)
                                           "/>
                      <xsl:value-of select="*/effective_ratio 
                                              * $effective_width"/> 
      </offset>      
     </xsl:copy>
  </xsl:template>
  
<!-- not(leftP) and not(outer)-->
 <xsl:template match="xP/at[not(offset)]
                           [predecessor]
						   [rightP | centreP]
						   [not(outer)]
                           [*/effective_ratio]
                           [../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wP ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="8C">
                  <xsl:variable name="effective_width"
                                select = "../../preceding-sibling::*[self::enclosure|self::label|self::point][1]/wP 
                                           "/>
                      <xsl:value-of select="*/effective_ratio 
                                              * $effective_width"/> 
      </offset>      
     </xsl:copy>
  </xsl:template>

<!-- FRIDAY 25 August 2017 BROKE THIS TEMPLATE AS WITNESSED BY x.cardinalsandtext.samrts and others -->
<!-- problem is that the squiggle (ancestor::enclosure|ancestor::diagram)[1] returns the diagram -->
<!-- need use last() - FIX applied and tested WEDNESDAY 30 August 2017 -->
<!--
     30 August 2017 - Introduced $frameOfReference using xpath existential quantification and xsl variable 
-->
<!-- 30  August 2017 -->
<!-- Previous rule split into 6 rules:
       3  [outer | margin | edge]
     * 2  [leftP  | (centreP | rightP) ]
-->


  <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [parent]
                               [outer ]
                               [leftP]
                               [exists($frameOfReference/(wlP + padding))]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17LO">
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                    select="-$frameOfReference/(wlP + padding)"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>

    <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [parent]
                               [margin]
                               [leftP]
                               [$frameOfReference/margin]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17LM">
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                    select="$frameOfReference/margin"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>

  <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [parent]
                               [edge]
                               [leftP]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17LE">
           0
      </offset>      
     </xsl:copy>
  </xsl:template>



    <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [*/effective_ratio]
                               [parent]
                               [outer]
                               [centreP | rightP]
                               [$frameOfReference/wP]
                               [exists($frameOfReference/(wrP + padding))]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17CR">
                  <xsl:variable name="effective_width"
                                as="xs:double"
                                select = "$frameOfReference/wP 
                                           + ($frameOfReference/(wrP + padding))
                                        "/>
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                   select="*/effective_ratio * $effective_width"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>

   <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [*/effective_ratio]
                               [parent]
                               [margin]
                               [centreP | rightP]
                               [$frameOfReference/wP]
                               [$frameOfReference/margin]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17CR">
                  <xsl:variable name="effective_width"
                                as="xs:double"
                                select = "$frameOfReference/wP 
                                           - $frameOfReference/margin 
                                         "/>
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                   select="*/effective_ratio * $effective_width"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>

   <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [*/effective_ratio]
                               [parent]
                               [edge]
                               [centreP | rightP]
                               [$frameOfReference/wP]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17CR">
                  <xsl:variable name="effective_width"
                                as="xs:double"
                                select = "$frameOfReference/wP"/>
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                   select="*/effective_ratio * $effective_width"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>
  
    <!-- DERIVATION OF VALUE FOR ATTRIBUTE place/offset of entity type xP -->
    <!-- 30 August 2017 introduce $subject as subject of placement -->
    <!-- 30 August 2017 Split into multiple rules (COME BACK -INSPECTION SHOWS IRREGULARITIES -->
   <xsl:template match="xP/place
                        [
                         some $subject in ../..
                         satisfies .
                           [not(offset)]
                           [$subject/padding]
                           [*/effective_ratio]
                           [leftP]
                           [edge or (not($subject[self::enclosure|self::point]) or $subject/wlP)]
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="173P"
              >
    <xsl:variable name="subject" select="../.."/> <!-- subject that is being placed -->
    <xsl:variable name="delta_offset"
                  select="if (../delta) then (- ../delta) else 0"/>                
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="10L">
                  <xsl:variable name="offset"  as="xs:double" select="$delta_offset + (if (outer) then -($subject/((if (self::enclosure or self::point) then wlP else 0) + padding)) else 0)"/>
                  <xsl:value-of select="$offset"/>
             
      </offset>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="xP/place
                        [
                         some $subject in ../..
                         satisfies .
                           [not(offset)]
                           [$subject/padding]
                           [*/effective_ratio]
                           [centreP | rightP]
                           [$subject/wP]
                           [rightP or edge or (not($subject[self::enclosure]) or $subject/wlP)]
                           [edge or (not($subject[self::enclosure]) or $subject/wrP)]
                        ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="173P"
              >
    <xsl:variable name="subject" select="../.."/> <!-- subject that is being placed -->
    <xsl:variable name="delta_offset"
                  select="if (../delta) then (- ../delta) else 0"/>                
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="10">
                  <xsl:variable name="effective_width"
                                select = "$subject/wP 
                                           + (if(outer) 
                                              then $subject/((if (self::enclosure) then wrP else 0) + padding) 
                                              else 0
                                              )"/>
                  <xsl:variable name="offset" as="xs:double"  select="number($delta_offset
                               + (*/effective_ratio 
                                 * $effective_width))"/>
                  <xsl:value-of select="$offset"/>
      </offset>
     </xsl:copy>
  </xsl:template>

  

  
  <!--  THE MAIN WORK OF DERIVING a suitable relative offset from the SMART placement at-->
  <!-- was enclosure/xP-->
 
 <xsl:template match="*[not(self::point)]/xP[not(relative/offset)] 
                        [place/offset]
                        [at/offset]
                        [key('box',at/of)
                             /xP/relative/*[position()=current()/at/dest_rise]
                                              [self::offset]
                        ]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>  <!--below modifed from child in descendant::enclosure to descendant::* -->
        <xsl:for-each 
                select="../ancestor::enclosure
                         [not(some $child in descendant::*
                              satisfies $child/id = current()/at/of)
                         ]">
                         <xsl:message>Inserted TBD for <xsl:value-of select="concat(name(),' having id ',id)"/></xsl:message>
          <tbd/>
        </xsl:for-each>
        <offset trace="1">
          <xsl:variable name="offset" as="xs:double"  select="key('box',at/of)/xP/relative
                                            /*[position()=current()/at/dest_rise][self::offset]
                                + at/offset - place/offset"/>
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>

  <!-- for a point is equivalent to place offset = 0 -->
   <xsl:template match="point/xP[not(relative/offset)] 
                        [at/offset]
                        [key('box',at/of)
                             /xP/relative/*[position()=current()/at/dest_rise]
                                              [self::offset]
                        ]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
        <xsl:for-each 
                select="../ancestor::enclosure
                         [not(some $child in descendant::enclosure 
                              satisfies $child/id = current()/at/of)
                         ]">
          <tbd/>
        </xsl:for-each>
        <offset trace="2">
          <xsl:variable name="offset" as="xs:double"  select="key('box',at/of)/xP/relative
                                            /*[position()=current()/at/dest_rise][self::offset]
                                + at/offset"/>
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>


<!-- DID PREVIOUSLY SAY not(self::point) -->
   <xsl:template match="*/xP[not(relative/offset)] 
                        [place/offset]
                        [at/offset]
                        [at/predecessor]
                        [../preceding-sibling::*[self::enclosure|self::label|self::point][1]
                             /xP/relative/*[1][self::offset]
                        ]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
        <offset trace="3">
          <xsl:variable name="offset" as="xs:double"  select="../preceding-sibling::*[self::enclosure|self::label|self::point][1]/xP/relative
                                            /*[1][self::offset]
                                + at/offset - place/offset"/>
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>


<!-- PREVIOUSLY HAD
  <xsl:template match="point/xP[not(relative/offset)] 
                        [at/offset]
                        [at/predecessor]
                        [../preceding-sibling::*[self::enclosure|self::label][1]
                             /xP/relative/*[1][self::offset]
                        ]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
        <offset trace="4">
          <xsl:variable name="offset" as="xs:double"  select="../preceding-sibling::*[self::enclosure|self::label][1]/xP/relative
                                            /*[1][self::offset]
                                + at/offset"/>
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>
  
  -->

   <xsl:template match="*[not(self::point)]/xP[not(relative/offset)] 
                        [place/offset]
                        [at/offset]
                        [at/parent]
                        [not(parent::enclosure) or ../wlP]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
        <offset trace="5">
          <!-- CHANGE WEDNESDAY FOR NESTED BOXES
          <xsl:value-of select="at/offset - place/offset + (if (parent::enclosure) then ../wlP else 0) + ../padding + ../ancestor::enclosure[1]/margin "/>  
        -->
                               <!-- I question this +wlP ditto +margin maybe restructure around here in fact just broke centrePd label-->
          <xsl:variable name="offset" as="xs:double"  select="at/offset - place/offset"/> 
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>

  <xsl:template match="point/xP[not(relative/offset)] 
                        [at/offset]
                        [at/parent]
                        [not(parent::enclosure) or ../wlP]
                        [../padding]
                      " 
              mode="recursive_diagram_enrichment"
              priority="173P">
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
        <offset trace="6">
          <!-- CHANGE WEDNESDAY FOR NESTED BOXES
          <xsl:value-of select="at/offset - place/offset + (if (parent::enclosure) then ../wlP else 0) + ../padding + ../ancestor::enclosure[1]/margin "/>  
        -->
                               <!-- I question this +wlP ditto +margin maybe restructure around here in fact just broke centrePd label-->
          <xsl:variable name="offset" as="xs:double"  select="at/offset"/> 
          <xsl:value-of select="$offset"/>
        </offset>
      </relative> 
    </xsl:copy>
  </xsl:template>




  <!--**********-->
  <!-- xP/clocal  -->
  <!-- ********* -->
  <!-- This attribute is used in the parents width calculation. 
       It enables centreP alignment of a box within its parent enclosure 
       without predjucing the parent's width calculation from relative 
       positions and widths of its children. 
  -->
  <xsl:template match="xP
                       [not(clocal)]
                       [at/centreP]
                       [at/parent]
                       [../wP]
                       "
                mode="recursive_diagram_enrichment"
                priority="173P">

    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
  
      <xsl:if test="place">
	  <!--
          <xsl:message>
             Not yet implemented - support for place in this context - see file diagram.addressing.smarts.xslt
          </xsl:message>
	   -->
      </xsl:if>
      <clocal>
          <xsl:value-of select="-(../wP div 2)"/>  <!-- this the rightP hand end wrPt centreP of parent. -->
      </clocal>
    </xsl:copy>
  </xsl:template>


  <!--**********-->
  <!-- xP/rlocal  -->
  <!-- ********* -->
  <!-- This attribute is used in the parents width calculation. 
       It enables rightP alignment of a box within its parent enclosure 
       without predjucing the parent's width calculation from relative positions 
       and widths of its children. 
  -->
  <xsl:template match="*[not(self::point)]/xP
                       [not(rlocal)]
                       [at/rightP]
                       [at/parent]
                       [../wP]
                       [(place/outer and (not(..[self::enclosure]) or ../wrP) and ../padding) or place/edge or (place/margin and ../margin)]
                       [(at/outer and ../ancestor::enclosure[1]/(wlP and padding)) 
                          or at/edge or (at/margin and ../ancestor::enclosure[1]/margin)] 
                       "
                mode="recursive_diagram_enrichment"
                priority="173P">

                <!-- was ../../ancestor::enclosure[1]/ {wlP, padding,margin} -->

    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>

      <rlocal>
          <xsl:value-of 
            select="- ../wP
                    + (if(place/outer) then -(../(if (self::enclosure) then wrP else 0) + ../padding)
                       else if (place/margin) then ../margin 
                       else 0 
                      )
                   + (if (at/outer) then ../ancestor::enclosure[1]/(wlP + padding)
                      else if (at/margin) then (- ../ancestor::enclosure[1]/margin)
                      else 0
                     )"/>  
      </rlocal>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="point/xP
                       [not(rlocal)]
                       [at/rightP]
                       [at/parent]
                       [(at/outer and ../../ancestor::enclosure[1]/(wlP and padding)) 
                          or at/edge or (at/margin and ../../ancestor::enclosure[1]/margin)] 
                       "
                mode="recursive_diagram_enrichment"
                priority="173P">

    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>

      <rlocal>
          <xsl:value-of 
            select="(if (at/outer) then ../ancestor::enclosure[1]/(wlP + padding)
                      else if (at/margin) then (- ../ancestor::enclosure[1]/margin)
                      else 0
                     )"/>  
      </rlocal>
    </xsl:copy>
  </xsl:template>

</xsl:transform>

