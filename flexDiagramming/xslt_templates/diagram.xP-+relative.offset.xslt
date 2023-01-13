<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

Contains xP, leftP and rightP. See readme for how these are substituted.

 -->

<xsl:output method="xml" indent="yes"/>

<!-- **************** -->
<!-- enclosure/xP/relative/offset  -->
<!-- **************** -->


<xsl:template match="xP
                     [not(relative)]
                     [local]
                    "
              mode="recursive_diagram_enrichment"
              priority="200">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
         <offset trace="xP3">
           <xsl:value-of select="local"/>
        </offset>
      </relative>
   </xsl:copy>
</xsl:template>

<!-- Will need change ancestor::enclosure in the code below to be ancestor::*[self::enclosure|self::point] -->
<!-- (enclosure|label)/xP/relative/offset -->
<!-- Nesting of relative address -->
<!-- used to have [parent::enclosure|parent::point] in precondition -->
<xsl:template match="*[self::enclosure|self::label|self::point|self::ns|self::ew|self::ramp]
                      [parent::enclosure|parent::point|parent::path|parent::side|parent::ground|parent::ceiling]
                      /xP[count(relative/(offset|tbd)) &lt; count(../ancestor::*[self::enclosure|self::point][1]/xP/relative/offset) + 1]
                              /relative/offset[count(following-sibling::offset)=0]
					  
					  [
					      ..[self::relative]
						  /..[self::xP]
						  /..[self::enclosure|self::label|self::point|self::ns|self::ew|self::ramp]
						  /(ancestor::enclosure|ancestor::point)[count(current()/preceding-sibling::*)+1]
                                        /xP/relative/*[1][self::offset]
					  ]
					" 
              mode="recursive_diagram_enrichment"
              priority="50P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
   </xsl:copy>
   <!-- offset[i+1] = offset[i] + ancestor::enclosure[i]/offset[1] -->
   <offset trace="xP4">
        <xsl:value-of select="number(.)
                               +  ..[self::relative]
							     /..[self::xP]
								 /..[self::enclosure|self::label|self::point|self::ns|self::ew|self::ramp]
							     /ancestor::*[self::enclosure|self::point]
                                                          [count(current()/preceding-sibling::*)+1]
                                        /xP/relative/*[1][self::offset]
                             "
        />
		<!-- Alternatively replace first summand by ../../relative/offset[1]  and use simpler second summand-->
   </offset>
</xsl:template>

<!--  
<xsl:template match="*[not(self::enclosure)]/xP[count(relative/(offset|tbd)) &lt; count(../ancestor::enclosure[1]/xP/relative/offset) + 1]
                          /relative/offset[count(following-sibling::offset)=0]
                      [../ancestor::enclosure
                                      [count(current()/preceding-sibling::offset)+1]
                                        /xP/relative/*[1][self::offset]
                      ]
                    " 
              mode="recursive_diagram_enrichment"

              priority="50P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
   </xsl:copy>
   <offset trace="xP5">
-->
   <!-- was ../ancestor changed to ../../../ancestor::enclosure -->
   <!--
        <xsl:value-of select="number(.)
                               + ../../../ancestor::enclosure
                                      [count(current()/preceding-sibling::offset)+1]
                                        /xP/relative/*[1][self::offset]
                             "
        />
   </offset>
   -->
   <!-- Only diffferent that we have simpler way of getting to ancestor::enclosure's.
        How significant is this? Not very I think. Try single sourcing this rule and the one
		above prior to generalsing to allow points in here.
	--><!--
</xsl:template>
-->


<!-- **************** -->
<!-- enclosure/xP/abs  -->
<!-- **************** -->

<!-- FOLLOWS GOOD PATTERN -->

<xsl:template match="xP
                      [not(abs)]
                      [relative/*[count(preceding-sibling::*) = current()/../depth - 1]]
                    "
              mode="recursive_diagram_enrichment"
              priority="50P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <abs>
           <xsl:value-of select="relative/*[count(preceding-sibling::*) = current()/../depth - 1]"/>
      </abs>
   </xsl:copy>
</xsl:template>


<!-- **************** -->
<!-- path/point/xP/abs  -->
<!-- **************** -->

<!-- CHANGE THIS TO FOLLOW PATTERN -->
<xsl:template match="path/point/xP[not(abs)]
                                [../../depth  &lt; count(relative/offset)+1]
                    "
              mode="recursive_diagram_enrichment"           
              priority="50P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <abs>
            <xsl:value-of select="relative/*[count(following-sibling::*)=0]"/>
      </abs>
   </xsl:copy>
</xsl:template>



<!-- from absolute --> 
<xsl:template match="xP[not(relative)]
                         [abs]
                         [not(../ancestor::enclosure)]
                    " mode="recursive_diagram_enrichment"
              priority="51P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
          <offset trace="xP6"><xsl:value-of select="abs"/></offset>
      </relative>
   </xsl:copy>
</xsl:template>
<!-- Note rules from absolute dont take account of points -->

<!-- from absolute -->
<xsl:template match="xP[not(relative)]
                         [abs]
                         [../ancestor::enclosure[1]/xP/abs]
                    " mode="recursive_diagram_enrichment"

              priority="51P">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <relative>
          <offset trace="xP1"><xsl:value-of select="abs - ../ancestor::enclosure[1]/xP/abs"/></offset>
      </relative>
   </xsl:copy>
</xsl:template>

<!-- Replace final tbd in a relative by an offset -->
<xsl:template match="*[depth]/xP/relative/tbd
                                        [following-sibling::*[1][self::offset]]
                                        [
                                         (../../../ancestor::enclosure)
                                         [current()/../../../depth - (current()/count(preceding-sibling::*)+1)]
                                                /xP/relative/*[1][self::offset]
                                        ]
                    "
              mode="recursive_diagram_enrichment"        
              priority="50P">
   <offset trace="xP2">
       <xsl:variable name="offset"
             select="following-sibling::*[1][self::offset]
                     -
                     (../../../ancestor::enclosure)
                      [current()/../../../depth - (current()/count(preceding-sibling::*)+1)]
                      /xP/relative/*[1][self::offset]"/>
       <xsl:value-of select="$offset"/>
   </offset>
</xsl:template>

</xsl:transform>

