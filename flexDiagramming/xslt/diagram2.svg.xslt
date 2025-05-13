<!-- 
*****************
ERmodel2.svg.xslt
*****************

DESCRIPTION

CHANGE HISTORY
25-Oct-2024 - Tidy up java script files. 
              Generate data-infoBoxId in place of id attributes.
-->
<xsl:transform version="2.0" 
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink" 
        xmlns:svg="http://www.w3.org/2000/svg" 
        xpath-default-namespace="http://www.entitymodelling.org/diagram">


<xsl:include href="diagram.elaboration.module.xslt"/>
<xsl:include href="diagram.recursive_enrichment.module.xslt"/>
<xsl:include href="diagram.render.module.xslt"/>

<xsl:output method="xml" indent="yes"/>

<xsl:variable name="fileextension">
   <xsl:value-of select="'svg.html'"/>
</xsl:variable>

<xsl:variable name="source">
   <xsl:copy-of select="/"/>
</xsl:variable>

<!-- ************************ -->
<!-- svg Specifics start here -->
<!-- ************************ -->


<xsl:template name="wrap_diagram" match="diagram">
    <xsl:param name="acting_filestem"/>
    <xsl:param name="content"/>
    <xsl:param name="diagramHeight"/>
    <xsl:param name="diagramWidth"/>
    <xsl:message>METHOD is <xsl:value-of select="method"/></xsl:message>
    <svg:svg>
      <xsl:attribute name="id" select="current-dateTime()"/>
      <xsl:attribute name="width">
        <xsl:value-of select="$diagramWidth + 0.1"/>cm</xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$diagramHeight + 0.1"/>cm</xsl:attribute>
      <xsl:variable name="method" select="if (exists(method)) then method else 'test'"/>
      <!-- css file -->
      <xsl:variable name="filename" 
                          select="concat($method,'FlexStyleDefinitions.css')"/>
      <xsl:choose>
          <xsl:when test="$bundleOn">
            <svg:style>
                <xsl:value-of select="unparsed-text('../../flexDiagramming/' || $method || '.css/' || $filename)" 
                          disable-output-escaping="yes"/>
            </svg:style>
          </xsl:when>
          <xsl:otherwise>
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet"
                   type="text/css"
                   href="/css/{$filename}"/>
          </xsl:otherwise>
      </xsl:choose>
      <svg:defs>
        <svg:linearGradient id="topdowngrey" x1="0%" y1="0%" x2="0%" y2="100%">
          <svg:stop offset="0%" style="stop-color:#E8E8E8;stop-opacity:1" />
          <svg:stop offset="100%" style="stop-color:white;stop-opacity:1" />
        </svg:linearGradient>
        <svg:filter x="0" y="0" width="1" height="1" id="surfaceattreven">
          <svg:feFlood flood-color="white"/>
          <svg:feComposite in="SourceGraphic" />
        </svg:filter>
        <svg:filter x="0" y="0" width="1" height="1" id="surfaceattrodd">
          <svg:feFlood flood-color="#FFFFCC"/>
          <svg:feComposite in="SourceGraphic" />
        </svg:filter>
        <svg:marker id="crowsfoot" 
              markerWidth="10" 
              markerHeight="12"
              refX="10" refY="6" 
              stroke-width="1"
              stroke="black"
              orient="auto-start-reverse">
              <svg:path d="M 0,6 L 10,12 M 0,6 L 10,6 M 0,6 L 10,0" />
        </svg:marker>
        <svg:marker id="identifying"
                   markerWidth="17"
                   markerHeight="16"
                   refX="16"
                   refY="6"
                   stroke-width="1"
                   stroke="black"
                   orient="auto-start-reverse">
            <svg:path d="M 1,1 L 1,11"/>
        </svg:marker>
      <svg:marker id="squiggle"
                   markerWidth="10"
                   markerHeight="22"
                   refX="28"
                   refY="11"
                   stroke="black"
                   fill="none"
                   orient="auto-start-reverse">
         <svg:path d="M 0,13 C 3,0 6,22 9,9"/>
      </svg:marker>
      </svg:defs>
      <xsl:copy-of select="$content"/>
    </svg:svg>
    <xsl:result-document href="{concat($acting_filestem,'.html')}" cdata-section-elements="sourcecode"> 
      <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html4></xsl:text>
      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
          <xsl:choose>
              <xsl:when test="$bundleOn">
                <style>
                    <xsl:value-of select="unparsed-text('../../css/ersvgdiagramwrapper.css')" 
                              disable-output-escaping="yes"/>
                </style>
              </xsl:when>
              <xsl:otherwise>
                <link rel="stylesheet" type="text/css" href="/css/ersvgdiagramwrapper.css"/>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="render_scripts"/> 
        </head>
        <body>
          <div id="contextMenu" class="menu">
              <ul>
                  <li id="select">Select</li>
                  <li id ="flexsource">View Flex Source</li>
              </ul>
          </div>
          <div> 
            <xsl:attribute name="class" select="'bigouter'"/>
            <div> 
              <xsl:attribute name="class" select="'bigbody'"/>
              <div> 
                <xsl:attribute name="class" select="'svganddivcontainer'"/>
                <div> 
                   <xsl:attribute name="id" select="'svgcontainer'"/>
                  <object>
                    <xsl:message>acting filestem is <xsl:value-of select="$acting_filestem"/>
                    </xsl:message>
                    <xsl:attribute name="data-type" select="'flex'"/>
                    <xsl:attribute name="data-method" select="method"/> 
                                            <!-- method is generated by er2flex.xslt -->
                    <xsl:attribute name="id" select="current-dateTime()"/>
                    <xsl:attribute name="data" select="concat($acting_filestem,'.svg')"/>
                    <xsl:attribute name="type" select="'image/svg+xml'"/>
                    <xsl:text>filler to stop contraction of this xml element</xsl:text>
                  </object>
                </div>
                <xsl:call-template name="render_descriptive_text"/>                
              </div>
            </div>
          </div>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*" mode="copy">
      <xsl:copy>
         <xsl:apply-templates mode="copy"/>
      </xsl:copy>
  </xsl:template>

<xsl:template name="render_descriptive_text">
    <xsl:for-each select="//*[self::enclosure|self::route]">
        <xsl:call-template name="infobox"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="infobox" match="enclosure|route" 
                                   mode="explicit">
    <xsl:variable name="popUpxPos">
      <xsl:value-of select="x/abs + w"/>
    </xsl:variable>
    <xsl:variable name="popUpyPos">
           <xsl:value-of select="x/abs"/>
    </xsl:variable>
      <xsl:variable name="text_div_id" as="xs:string?">
        <xsl:value-of select="concat(id,'_text')"/>
      </xsl:variable>
      <div>
        <xsl:attribute name="id" select="$text_div_id"/>
        <xsl:attribute name="class" select="'infobox'"/>       
        <!--<xsl:attribute name="style" select="concat('left:',$popUpxPos,'cm;top:',$popUpyPos,'cm')"/>-->
        <div>
          <xsl:attribute name="class" select="'infoboxHeader'"/>
          <div>
            <xsl:attribute name="class" select="'metatype'"/>
            <xsl:choose>
              <xsl:when test="self::enclosure">
                <b><xsl:text>Enclosure: </xsl:text></b>
                <xsl:value-of select="id"/>
              </xsl:when>
              <xsl:when test="self::route">
                <b><xsl:text>Route: </xsl:text></b>
                <xsl:value-of select="id"/>
              </xsl:when>
            </xsl:choose>
          </div> 
          <div>
            <xsl:attribute name="class" select="'closecontainer'"/>
            <button>
              <xsl:attribute name="class" select="'close'"/>
              <xsl:attribute name="onClick" select="'closePopUp(this)'"/>
              <xsl:text>x</xsl:text>
            </button> 
          </div>
          <!--<xsl:call-template name="clearleft"/>-->
        </div> <!-- end of infoboxHeader -->
        <div>
            <xsl:attribute name="class" select="'infoboxBody'"/>
            <pre>
                <xsl:value-of select="sourcecode"/>
            </pre>
        </div>
      </div>
  </xsl:template>

<xsl:template name="render_scripts" match="diagram">
    <xsl:if test="$animateOn">
          <script>
            <xsl:choose>
               <xsl:when test="$bundleOn">
                  <xsl:value-of select="unparsed-text('../../js/flexDiagramInteraction.js')" 
                              disable-output-escaping="yes"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="src" select="'/js/flexDiagramInteraction.js'"/>
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
              </xsl:otherwise>
          </xsl:choose>
          </script>
          <script>
            <xsl:choose>
               <xsl:when test="$bundleOn">
                  <xsl:value-of select="unparsed-text('../../js/draggable.js')" 
                              disable-output-escaping="yes"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="src" select="'/js/draggable.js'"/>
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
              </xsl:otherwise>
          </xsl:choose>
          </script>
          <!-- THIS ISNT ACHIEVING ANYTHING CURRENTLY I THINK 01-Nov-2024 -->
          <xsl:if test="exists(method)">
            <xsl:variable name="filename" 
                          select="concat(method,'FlexDiagramInteraction.js')"/>
            <script>
              <xsl:choose>
                 <xsl:when test="$bundleOn">
                    <xsl:value-of 
                        select="unparsed-text('../../js/' 
                                               || $filename
                                              )" 
                                disable-output-escaping="yes"/>
                 </xsl:when>
                 <xsl:otherwise>
                    <xsl:attribute name="src" select="'/js/' || $filename"/>
              This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
                </xsl:otherwise>
              </xsl:choose>
            </script>
          </xsl:if>
    </xsl:if>
</xsl:template>


<xsl:template name="renderenclosure" match="enclosure">
    <svg:rect>
      <xsl:attribute name="class"><xsl:value-of select="shape_style"/></xsl:attribute>
      <xsl:attribute name="data-infoBoxId"><xsl:value-of select="id"/></xsl:attribute>
      <xsl:attribute name="x"><xsl:value-of select="x/abs"/>cm</xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="y/abs"/>cm</xsl:attribute>
      <xsl:if test="rx">
         <xsl:attribute name="rx"><xsl:value-of select="rx"/>cm</xsl:attribute>
      </xsl:if>
      <xsl:if test="ry">
        <xsl:attribute name="ry"><xsl:value-of select="ry"/>cm</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="width"><xsl:value-of select="w"/><xsl:text>cm</xsl:text></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="h"/><xsl:text>cm</xsl:text></xsl:attribute>
    </svg:rect>
	 <xsl:if test="false()">
	    <!-- tick marks-->
	   <xsl:variable name="xabs" select="x/abs"/>
	   <xsl:variable name="yabs" select="y/abs"/>
	   <xsl:variable name="margin" select="margin"/>
	   <!-- x-axis minor tick marks -->
	   <xsl:for-each select="0 to xs:integer(floor(w*10))">
	      <xsl:variable name="index" select="."/>
	      <svg:line>
	        <xsl:attribute name="class"><xsl:value-of select="'tickmarks'"/></xsl:attribute>
	        <xsl:attribute name="x1"><xsl:value-of select="$xabs + $index div 10"/>cm</xsl:attribute>
		     <xsl:attribute name="x2"><xsl:value-of select="$xabs + $index div 10"/>cm</xsl:attribute>
     	     <xsl:attribute name="y1"><xsl:value-of select="$yabs"/>cm</xsl:attribute>
		     <xsl:attribute name="y2"><xsl:value-of select="$yabs + $margin div 3"/>cm</xsl:attribute>   
          </svg:line>
	   </xsl:for-each>
		<!-- x-axis major tick marks -->
	   <xsl:for-each select="0 to xs:integer(floor(w))">
	      <xsl:variable name="index" select="."/>
	      <svg:line>
	         <xsl:attribute name="class"><xsl:value-of select="'tickmarks'"/></xsl:attribute>
	         <xsl:attribute name="x1"><xsl:value-of select="$xabs + $index"/>cm</xsl:attribute>
	   	     <xsl:attribute name="x2"><xsl:value-of select="$xabs + $index"/>cm</xsl:attribute>
     	     <xsl:attribute name="y1"><xsl:value-of select="$yabs"/>cm</xsl:attribute>
		     <xsl:attribute name="y2"><xsl:value-of select="$yabs + $margin div 1.5"/>cm</xsl:attribute>   
          </svg:line>
	   </xsl:for-each>

	   <!-- y-axis minor tick marks -->
	   <xsl:for-each select="0 to xs:integer(floor(h*10))">
	      <xsl:variable name="index" select="."/>
	      <svg:line>
	         <xsl:attribute name="class"><xsl:value-of select="'tickmarks'"/></xsl:attribute>
	         <xsl:attribute name="x1"><xsl:value-of select="$xabs"/>cm</xsl:attribute>
		     <xsl:attribute name="x2"><xsl:value-of select="$xabs + $margin div 3"/>cm</xsl:attribute>
     	     <xsl:attribute name="y1"><xsl:value-of select="$yabs + $index div 10"/>cm</xsl:attribute>
		     <xsl:attribute name="y2"><xsl:value-of select="$yabs + $index div 10"/>cm</xsl:attribute>   
          </svg:line>
	   </xsl:for-each>
		<!-- x-axis major tick marks -->
	   <xsl:for-each select="0 to xs:integer(floor(h))">
	      <xsl:variable name="index" select="."/>
	      <svg:line>
	         <xsl:attribute name="class"><xsl:value-of select="'tickmarks'"/></xsl:attribute>
	         <xsl:attribute name="x1"><xsl:value-of select="$xabs "/>cm</xsl:attribute>
	   	     <xsl:attribute name="x2"><xsl:value-of select="$xabs + $margin div 1.5"/>cm</xsl:attribute>
     	     <xsl:attribute name="y1"><xsl:value-of select="$yabs + $index"/>cm</xsl:attribute>
		     <xsl:attribute name="y2"><xsl:value-of select="$yabs + $index"/>cm</xsl:attribute>   
          </svg:line>
	   </xsl:for-each>
	 </xsl:if>
  </xsl:template>

  <xsl:template name="render_enclosure_margins" match="enclosure">
    <!--
    <svg:path>
       <xsl:attribute name="class" select="'outlinedebug'"/>
       <xsl:attribute name="id" select="id"/>
       <xsl:attribute name="d">
           <xsl:value-of select="concat( 'M',x/abs,    ',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs,    ',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs ,   ',',y/abs    )"/>
      </xsl:attribute>
    </svg:path>
  -->
    <svg:path>
       <xsl:attribute name="class" select="'margin'"/>
       <xsl:attribute name="data-infoBoxId" select="id"/>
       <xsl:attribute name="d">
           <xsl:value-of select="concat('M',x/abs,    ',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs,    ',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs ,   ',',y/abs    )"/>
           <xsl:value-of select="concat(' M',x/abs + margin,      ',',y/abs + margin   )"/>
           <xsl:value-of select="concat(' L',x/abs + w - margin , ',',y/abs + margin   )"/>
           <xsl:value-of select="concat(' L',x/abs + w - margin,  ',',y/abs + h - margin)"/>
           <xsl:value-of select="concat(' L',x/abs + margin,      ',',y/abs + h -margin )"/>
           <xsl:value-of select="concat(' L',x/abs + margin,      ',',y/abs + margin   )"/>
      </xsl:attribute>
    </svg:path>

    <!-- outside padding -->
	 <xsl:call-template name="render_padding"/>
  </xsl:template>
  
  <xsl:template name="render_padding" match="enclosure|point">
    <xsl:if test="not(self::point and (parent::ns | parent::ew | parent::ramp))">
        <!-- such points are not rendered...they are partial ... don't have both x and y values -->
        <xsl:if test="not(x/abs)">
          <xsl:message>ERROR: No x position for padding of '<xsl:value-of select="name()"/>' child of '<xsl:value-of select="../name()"/>'</xsl:message>
        </xsl:if>
        <svg:path>
         <xsl:attribute name="class" select="'padding'"/>
         <xsl:attribute name="data-infoBoxId" select="id"/>
         <xsl:attribute name="d">
             <xsl:value-of select="concat(' M',x/abs - wl,      ',',y/abs - ht)"/>  
             <xsl:value-of select="concat(' L',x/abs + w + wr, ',',y/abs - ht)"/>
             <xsl:value-of select="concat(' L',x/abs + w + wr,  ',',y/abs + h + hb)"/> 
             <xsl:value-of select="concat(' L',x/abs - wl,      ',',y/abs + h + hb)"/>
             <xsl:value-of select="concat(' L',x/abs - wl,      ',',y/abs - ht )"/>
             <xsl:value-of select="concat(' M',x/abs - wl -  padding,      ',',y/abs - ht - padding   )"/>  <!-- this then needs to be - 2 * padding -->
             <xsl:value-of select="concat(' L',x/abs + w + wr + padding , ',',y/abs -ht - padding   )"/>
             <xsl:value-of select="concat(' L',x/abs + w + wr + padding,  ',',y/abs + h + hb + padding)"/>
             <xsl:value-of select="concat(' L',x/abs - wl - padding,      ',',y/abs + h + hb + padding )"/>
             <xsl:value-of select="concat(' L',x/abs - wl - padding ,      ',',y/abs - ht - padding   )"/>
        </xsl:attribute>
      </svg:path>
    </xsl:if>
  </xsl:template>
  
<xsl:template name="clearleft">
   <div>
      <xsl:attribute name="style" select="'clear:left'"/>
   </div>
</xsl:template>

<xsl:template name="wrap_relationships" match="diagram">   
  <xsl:param name="relationships"/>
  <xsl:param name="diagramHeight"/>
  <xsl:param name="diagramWidth"/>
  <svg:svg>
       <xsl:attribute name="width"><xsl:value-of select="$diagramWidth"/>cm</xsl:attribute>
       <xsl:attribute name="height"><xsl:value-of select="$diagramHeight"/>cm</xsl:attribute>
       <xsl:attribute name="viewBox">
           <xsl:text>0 0 </xsl:text> <xsl:value-of select="$diagramWidth"/> <xsl:text> </xsl:text> <xsl:value-of select="$diagramHeight"/>
       </xsl:attribute>
       <xsl:for-each select="//enclosure">
            <xsl:call-template name="render_enclosure_margins"/>
      </xsl:for-each>
	   <xsl:for-each select="//*[self::point|self::label]">
            <xsl:call-template name="render_padding"/>
      </xsl:for-each>
       <xsl:copy-of select="$relationships"/>
    </svg:svg>
</xsl:template>

<xsl:template name="render_path" match="path" mode="explicit">
  <xsl:param name="classname" as="xs:string"/>
   <xsl:variable name="x0cm"  as="xs:double" select="point[1]/x/abs"/>
   <xsl:variable name="y0cm"  as="xs:double" select="point[1]/y/abs"/>
  <!-- <xsl:variable name="p1cm"  select="point[2]/concat(x/abs/offset,',',y/abs/offset)"/> -->
  <!-- <xsl:variable name="y1cm"  select="point[2]/y/abs/offset"/>  -->
  <svg:path>
    <xsl:if test="parent::route">
      <!-- <xsl:attribute name="id"><xsl:value-of select="parent::route/id"/></xsl:attribute> -->
      <xsl:attribute name="data-infoBoxId"><xsl:value-of select="parent::route/id"/></xsl:attribute>
                                                   <!-- change of 25-Oct-2024 -->
    </xsl:if>
    <xsl:attribute name="class"><xsl:value-of select="$classname"/></xsl:attribute>
    <!--
    <xsl:message> path parent '<xsl:value-of select="parent::*/name()"/>'</xsl:message>
    <xsl:message> path id '<xsl:value-of select="parent::route/id"/>'</xsl:message>
  -->
    <xsl:attribute name="d">
      <xsl:value-of select="concat('M',$x0cm,',',$y0cm)"/>
      <xsl:for-each select="point[count(preceding-sibling::point) &gt; 0]">
          <!--
          <xsl:message> point at x: '<xsl:value-of select="x/abs"/>', y: '<xsl:value-of select="y/abs"/>'</xsl:message>
        -->
          <xsl:variable name="x"  as="xs:double" select="x/abs"/>
          <xsl:variable name="y"  as="xs:double" select="y/abs"/>
           <xsl:value-of select="concat('L',concat($x,',',$y))"/>
      </xsl:for-each>
    </xsl:attribute>
  </svg:path>
</xsl:template>

<xsl:template name="render_route" match="route" mode="explicit">
   <xsl:variable name="x0cm"  as="xs:double" select="path/point[1]/x/abs"/>
   <xsl:variable name="y0cm"  as="xs:double" select="path/point[1]/y/abs"/>
   <xsl:variable name="sourcestyle" as="xs:string"
                   select="if (source/line_style) then source/line_style else 'dashedline'"/>
    <xsl:variable name="deststyle" as="xs:string"
                   select="if (destination/line_style) then destination/line_style else 'solidline'"/>

    <xsl:variable name="pointcount" select="count(path/point)"/>
    <!--<xsl:message>Route id <xsl:value-of select="id"/> Number of points is <xsl:value-of select="$pointcount"/></xsl:message>-->
    <!--<xsl:message>route/source in question is <xsl:copy-of select="source"/></xsl:message>  
    <xsl:message>route/destination in question is <xsl:copy-of select="destination"/></xsl:message>  
    <xsl:message>route/path in question is <xsl:copy-of select="path"/></xsl:message>  
  -->
    <xsl:variable name="midpointxcm" as="xs:double">
      <xsl:choose>
        <xsl:when test="$pointcount mod 2 = 1">
            <!-- not the norml case currently cant bbe sure of the midpoint but..-->
          <xsl:value-of  select="path/point[($pointcount + 1) div 2]/x/abs"/>
        </xsl:when>
        <xsl:otherwise>  
          <xsl:if test="not(path/point[$pointcount div 2]/x/abs)">
            <xsl:message terminate="yes">Midpoint problem with <xsl:copy-of select="path"/></xsl:message>
          </xsl:if> 
          <xsl:variable name="mid_segment_startx" 
                    as="xs:double"
                    select="path/point[$pointcount div 2]/x/abs"/>  
                    <!--<xsl:message>midpoint x in question is <xsl:copy-of select="path/point[($pointcount div 2)+1]/x"/></xsl:message>  --> 

                      
          <xsl:variable name="mid_segment_endx" 
                    as="xs:double"
                    select="path/point[($pointcount div 2)+1]/x/abs"/>    
          <xsl:value-of  select="($mid_segment_startx + $mid_segment_endx) div 2"/>        
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="midpointycm" as="xs:double">
      <xsl:choose>
      <xsl:when test="$pointcount mod 2 = 1">
          <!-- not the norml case currently cant be sure of the midpoint but..-->
        <xsl:value-of  select="path/point[($pointcount + 1) div 2]/y/abs"/>
      </xsl:when>
      <xsl:otherwise> 
        <xsl:variable name="mid_segment_starty" 
                  as="xs:double"
                  select="path/point[$pointcount div 2]/y/abs"/>
        <xsl:variable name="mid_segment_endy" 
                  as="xs:double"
                  select="path/point[($pointcount div 2)+1]/y/abs"/>
        <xsl:value-of select="($mid_segment_starty + $mid_segment_endy) div 2"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

  <!-- source half of route -->    
  <!-- I draw the half route  path and then (since I cant add multiple markers to a path in svg (i think))
       for every endline/marker I draw the last line segment again and specify the endline style as a marker
  -->
  <xsl:variable name="sourcemarker"
                   select="if (source/endline/marker) then source/endline/marker else 'none'"/>
  <svg:path>
    <xsl:attribute name="class"><xsl:value-of select="$sourcestyle"/></xsl:attribute>
    <xsl:attribute name="d">
      <xsl:value-of select="concat('M',$x0cm,',',$y0cm)"/>
      <xsl:for-each select="path/point[count(preceding-sibling::point) &gt; 0]
                                      [count(preceding-sibling::point) &lt; ($pointcount div 2) ]
                            ">
          <xsl:variable name="x"  as="xs:double" select="x/abs"/>
          <xsl:variable name="y"  as="xs:double" select="y/abs"/>
           <xsl:value-of select="concat('L',concat($x,',',$y))"/>
      </xsl:for-each>
      <xsl:value-of select="concat('L',concat($midpointxcm,',',$midpointycm))"/>
    </xsl:attribute>
<!--     <xsl:if test="$sourcemarker != 'none'">
      <xsl:attribute name="marker-start" select="concat('url(#',$sourcemarker,')')"/>
    </xsl:if> -->
  </svg:path>
      <xsl:variable name="xstartcm" select="path/point[1]/x/abs"/>
    <xsl:variable name="ystartcm" select="path/point[1]/y/abs"/>
    <xsl:variable name="xnextcm" select="path/point[2]/x/abs"/>
    <xsl:variable name="ynextcm" select="path/point[2]/y/abs"/>

    <xsl:for-each select="source/endline"> <!-- see comments above for an explanation -->
      <svg:path>
        <xsl:attribute name="class"><xsl:value-of select="$sourcestyle"/></xsl:attribute>
        <xsl:attribute name="d">
          <xsl:value-of select="concat('M',$xnextcm, ',', $ynextcm,
                                       'L',$xstartcm,         ',', $ystartcm)"/>
        </xsl:attribute>
        <xsl:attribute name="marker-end" select="concat('url(#', marker, ')')"/>
      </svg:path>
    </xsl:for-each>

  <!-- destination half of route -->
  <!-- I draw the half route  path and then (since I cant add multiple markers to a path in svg (i think))
       for every endline/marker I draw the last line segment again and specify the endline style as a marker
  -->

    <svg:path>
      <xsl:attribute name="class"><xsl:value-of select="$deststyle"/></xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$midpointxcm,',',$midpointycm)"/>
        <xsl:for-each select="path/point[count(preceding-sibling::point) &gt; (($pointcount div 2)-1)]">
            <xsl:variable name="x"  as="xs:double" select="x/abs"/>
            <xsl:variable name="y"  as="xs:double" select="y/abs"/>
             <xsl:value-of select="concat('L',concat($x,',',$y))"/>
        </xsl:for-each>
      </xsl:attribute>
    </svg:path>
    <xsl:variable name="xendcm" select="path/point[$pointcount]/x/abs"/>
    <xsl:variable name="yendcm" select="path/point[$pointcount]/y/abs"/>
    <xsl:variable name="xpenultimatecm" select="path/point[$pointcount - 1]/x/abs"/>
    <xsl:variable name="ypenultimatecm" select="path/point[$pointcount - 1]/y/abs"/>

    <xsl:for-each select="destination/endline"> <!-- see comments above for an explanation -->
      <svg:path>
        <xsl:attribute name="class"><xsl:value-of select="$deststyle"/></xsl:attribute>
        <xsl:attribute name="d">
          <xsl:value-of select="concat('M',$xpenultimatecm, ',', $ypenultimatecm,
                                       'L',$xendcm,         ',', $yendcm)"/>
        </xsl:attribute>
        <xsl:attribute name="marker-end" select="concat('url(#', marker, ')')"/>
      </svg:path>
    </xsl:for-each>

  <!-- next i render the whole path again as a hitarea -->
  <xsl:for-each select="path">
    <xsl:call-template name="render_path">
        <xsl:with-param name="classname" select="'routehitarea'"/>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>


<xsl:template name="text_element" match="label">
  <svg:text>
     <xsl:attribute name="class" select="text_style"/>
     <xsl:choose>
        <xsl:when test="false()">
           <xsl:attribute name="x" select="x/abs"/>
           <xsl:attribute name="y" select="y/abs"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:attribute name="x" select="concat(x/abs,'cm')"/>
           <xsl:attribute name="y" select="concat(y/abs,'cm')"/>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:attribute name="text-anchor" select="'start'"/>
	 <xsl:attribute name="dominant-baseline" select="'hanging'"/>
     <xsl:value-of select= "text"/>
  </svg:text>
</xsl:template>


<xsl:template name="point" match="point">
  <svg:line>
    <xsl:attribute name="class"><xsl:value-of select="'point'"/></xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="x/abs - 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="y/abs + 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="x/abs + 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="y/abs - 0.1"/>cm</xsl:attribute>
  </svg:line>
    <svg:line>
    <xsl:attribute name="class"><xsl:value-of select="'point'"/></xsl:attribute>
	<xsl:attribute name="x1"><xsl:value-of select="x/abs + 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="y1"><xsl:value-of select="y/abs + 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="x2"><xsl:value-of select="x/abs - 0.1"/>cm</xsl:attribute>
	<xsl:attribute name="y2"><xsl:value-of select="y/abs - 0.1"/>cm</xsl:attribute>
  </svg:line>
</xsl:template>



</xsl:transform>
