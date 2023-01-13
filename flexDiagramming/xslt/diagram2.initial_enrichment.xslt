<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->

<xsl:output method="xml" indent="yes"/>
<xsl:param name="maxiter" />
<xsl:variable name="maxdepth" as="xs:integer" select="if ($maxiter) then $maxiter else 100" />

<xsl:param name="debug" />
<xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />

<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="diagram.functions.module.xslt"/>

<xsl:include href="diagram...x-+place.xslt"/>            <!-- priority  199 -->
<xsl:include href="diagram...y-+place.xslt"/>            <!-- priority  199 -->

<xsl:include href="diagram.addressing.xw.smarts.xslt"/> <!-- priority  179 - 183 -->
<xsl:include href="diagram.addressing.yh.smarts.xslt"/> <!-- priority  169 - 173 -->

<xsl:include href="diagram...route-+src_rise+dest_rise.xslt "/> <!-- priority  169 -->

<xsl:include href="diagram.depth.xslt"/>                <!-- priority  80  -->
<xsl:include href="diagram.margin.xslt"/>               <!-- priority  76  -->
<xsl:include href="diagram.text_style.xslt"/>           <!-- priority  77  -->
<xsl:include href="diagram.padding.xslt"/>              <!-- priority  78  -->
<xsl:include href="diagram.shape_style.xslt"/>          <!-- priority  79  -->
<xsl:include href="diagram.text.xslt" />                <!-- priority  20  -->
<xsl:include href="diagram.debug_whitespace.xslt"/>     <!-- priority  55  -->
<!--
<xsl:include href="diagram.label.x.xslt"/>               
<xsl:include href="diagram.label.y.xslt"/>
-->            
<xsl:include href="diagram...box-+x.xslt"/>             <!-- priority  50  -->
<xsl:include href="diagram...box-+y.xslt"/>             <!-- priority  48  -->

<xsl:include href="diagram...box-+x_outer_upper_offset.xslt"/>   <!-- priority  50 -->
<xsl:include href="diagram...box-+y_outer_upper_offset.xslt"/>   <!-- priority  50 -->
<xsl:include href="diagram...box-+x_outer_lower_offset.xslt"/>   <!-- priority  50 -->
<xsl:include href="diagram...box-+y_outer_lower_offset.xslt"/>   <!-- priority  50 -->

<xsl:include href="diagram.x-+relative.offset.xslt"/>   <!-- priority  50 - 51 -->
<xsl:include href="diagram.y-+relative.offset.xslt"/>   <!-- priority  48 - 49 -->
<xsl:include href="diagram.wl.xslt"/>                   <!-- priority  40  -->
<xsl:include href="diagram.wr.xslt"/>                   <!-- priority  42  -->
<xsl:include href="diagram.w.xslt"/>                    <!-- priority  42  -->
<xsl:include href="diagram.h.xslt"/>                    <!-- priority  43  -->
<xsl:include href="diagram.ht.xslt"/>                   <!-- priority  41  -->
<xsl:include href="diagram.hb.xslt"/>                   <!-- priority  43 -->

<!-- No longer reqd I think
<xsl:include href="diagram...edge-+id.xslt"/>  -->           <!-- priority  40  -->
<xsl:include href="diagram.route.path.xslt"/>             <!-- priority  40  -->
<xsl:include href="diagram...route.node-+specific_edge.xslt"/>   <!-- priority  42  -->
<xsl:include href="diagram...route.node-+slotNo.xslt"/>            <!--priority 40 -->
<xsl:include href="diagram...route.node-+angleToOtherEnd.xslt"/>   <!--priority 40 -->
<xsl:include href="diagram...route.node.specific_edge-+deltax.xslt"/>   <!-- priority  42  -->
<xsl:include href="diagram...path-+point.xslt"/>          <!-- priority  54, 55 ,57 -->
<xsl:include href="diagram...path.point-+x.xslt"/>        <!-- priority  55, 56  -->
<xsl:include href="diagram...path.point-+y.xslt"/>        <!-- priority  55, 56  -->


<xsl:include href="diagram...path-+point.startpoint+ew.xslt"/>  <!-- priority  40  -->
<xsl:include href="diagram...path-+point.startpoint+ns.xslt"/>  <!-- priority  40  -->

<xsl:include href="diagram...path.point_startpoint_-+x.xslt"/>  <!-- priority  40  -->
<xsl:include href="diagram...path.point_startpoint_-+y.xslt"/>  <!-- priority  40  -->
<xsl:include href="diagram...path.point_endpoint_-+x.xslt"/>    <!-- priority  40  -->
<xsl:include href="diagram...path.point_endpoint_-+y.xslt"/>    <!-- priority  40  -->

<xsl:include href="diagram...path-+point.endpoint+ew.xslt"/>    <!-- priority  41  -->
<xsl:include href="diagram...path-+point.endpoint+ns.xslt"/>    <!-- priority  41  -->
<xsl:include href="diagram...route.path.point.label-+text.xslt"/>    <!-- priority  40  -->
<xsl:include href="diagram...route.path.point.label-+x.xslt"/>    <!-- priority  40  -->
<xsl:include href="diagram...route.path.point.label-+y.xslt"/>    <!-- priority  40  -->
<xsl:include href="diagram...path.cardinal-+startx.xslt"/>      <!-- priority  60  -->
<xsl:include href="diagram...path.cardinal-+starty.xslt"/>      <!-- priority  61  -->
<xsl:include href="diagram...path.cardinal-+deltax.xslt"/>      <!-- priority  55,56  -->
<xsl:include href="diagram...path.cardinal-+deltay.xslt"/>      <!-- priority  57,58  -->
<xsl:include href="diagram...path.cardinal-+endx.xslt"/>      <!-- priority  40  -->
<xsl:include href="diagram...path.cardinal-+endy.xslt"/>      <!-- priority  40  -->
<xsl:include href="diagram...node-+x_lower_bound.xslt"/>       <!-- priority 40 -->
<xsl:include href="diagram...node-+y_lower_bound.xslt"/>       <!-- priority 40 -->
<xsl:include href="diagram...node-+x_upper_bound.xslt"/>       <!-- priority 40 -->
<xsl:include href="diagram...node-+y_upper_bound.xslt"/>       <!-- priority 40 -->        
<xsl:include href="diagram.endpoint.endline_style.xslt"/> <!-- priority  38  -->

<xsl:key name="Enclosure" match="enclosure" use="id"/>
<xsl:key name="box" match="path|label|point|ns|ew|ramp|enclosure" use="id"/>
<xsl:key name="text_style" match="diagram:text_style" use="id"/>
<xsl:key name="endline_style" match="endline_style" use="id"/>
<xsl:key name="right_side_is_endpoint_of" match="*[self::source|self::destination][right_side]" use="id"/> 
<xsl:key name="left_side_is_endpoint_of" match="*[self::source|self::destination][left_side]" use="id"/> 
<xsl:key name="top_edge_is_endpoint_of" match="*[self::source|self::destination][top_edge]" use="id"/> 
<xsl:key name="bottom_edge_is_endpoint_of" match="*[self::source|self::destination][bottom_edge]" use="id"/>
<xsl:key name="is_endpoint_of" match="*[self::source|self::destination]" use="id"/>  

<!-- HMMM -->
<xsl:key name="startpoint" match="point[startpoint]"   use="xP/at/of"/>

<xsl:template match="/">
      <xsl:message>Max depth is <xsl:value-of select="$maxdepth"/> </xsl:message>
      <xsl:call-template name="recursive_diagram_enrichment">
         <xsl:with-param name="interim" select="."/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
</xsl:template>

<xsl:template match="*">
<xsl:message>super generic rule <xsl:value-of select="name()"/></xsl:message>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template name="recursive_diagram_enrichment">
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in recursive diagram enrichment                                     - depth <xsl:value-of select="$depth"/> </xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
         <xsl:copy>
            <xsl:apply-templates mode="recursive_diagram_enrichment"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:if test="$debugon">
      <xsl:result-document href="concat('class_enriched_temp',$depth,'.xml')" method="xml">
        <xsl:sequence select="$next/diagram"/>
      </xsl:result-document>
   </xsl:if>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next)) and $depth!=$maxdepth">
            <xsl:call-template name="recursive_diagram_enrichment">
               <xsl:with-param name="interim" select="$next"/>
               <xsl:with-param name="depth" select="$depth + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> <xsl:value-of select="if($depth!=$maxdepth) 
                                                then 'unchanged fixed point diagram enrichment'
                                                else 'TERMINATED EARLY AT max iterations'" />
            </xsl:message>
            <xsl:copy-of select="$next"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable> 
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_diagram_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="*" name="float">
    <xsl:param name="value" as="xs:double"/>
    <xsl:if test="exists($value)">
        <xsl:value-of select="$value"/>
    </xsl:if>
    <xsl:if test="not(exists($value))">
         <xsl:message terminate="yes">************float is undefined************</xsl:message>
    </xsl:if>
</xsl:template>

</xsl:transform>

