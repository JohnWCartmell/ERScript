<!-- 
*****************
ERmodel2.svg.xslt
*****************

DESCRIPTION

CHANGE HISTORY
-->
<xsl:transform version="2.0" 
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink" 
        xmlns:svg="http://www.w3.org/2000/svg" 
        xpath-default-namespace="http://www.entitymodelling.org/diagram">

<xsl:include href="diagram.render.module.xslt"/>

<xsl:output method="xml" indent="yes" />

<xsl:variable name="fileextension">
   <xsl:value-of select="'svg.html'"/>
</xsl:variable>

<!-- ************************ -->
<!-- svg Specifics start here -->
<!-- ************************ -->

<xsl:template name="wrap_diagram" >
  <xsl:param name="acting_filestem"/>
  <xsl:param name="content"/>
  <xsl:param name="diagramHeight"/>
  <xsl:param name="diagramWidth"/>
  <!-- <xsl:result-document href="{concat($acting_filestem,'.svg')}"> -->
     <xsl:message>h<xsl:value-of select="$diagramHeight"/></xsl:message>
    <svg:svg>
         <xsl:attribute name="width"><xsl:value-of select="$diagramWidth + 0.1"/>cm</xsl:attribute>
         <xsl:attribute name="height"><xsl:value-of select="$diagramHeight + 0.1"/>cm</xsl:attribute>
     <svg:defs>

      <svg:linearGradient id="topdowngrey" x1="0%" y1="0%" x2="0%" y2="100%">
        <svg:stop offset="0%" style="stop-color:#E8E8E8;stop-opacity:1" />
        <svg:stop offset="100%" style="stop-color:white;stop-opacity:1" />
      </svg:linearGradient>

      <svg:style type="text/css">
          <xsl:for-each select="text_style">
              <xsl:text>&#xA;  .</xsl:text><xsl:value-of select="id"/><xsl:text>{</xsl:text>
              <xsl:text>&#xA;    fill: </xsl:text><xsl:value-of select="fill"/>
              <xsl:text>;&#xA;    font-size: </xsl:text><xsl:value-of select="font-size"/><xsl:text>px</xsl:text>
              <xsl:for-each select="text-decoration/*">
                 <xsl:text>;&#xA;    text-decoration: </xsl:text><xsl:value-of select="name()"/>
              </xsl:for-each>
              <xsl:for-each select="font-style/*">
                 <xsl:text>;&#xA;    font-style: </xsl:text><xsl:value-of select="name()"/>
              </xsl:for-each>
              <xsl:for-each select="font-weight/*">
                 <xsl:text>;&#xA;    font-weight: </xsl:text><xsl:value-of select="name()"/>
              </xsl:for-each>

              <xsl:text>&#xA;  }&#xA;</xsl:text>
           </xsl:for-each>
           <xsl:for-each select="shape_style">
              <xsl:text>&#xA;  .</xsl:text><xsl:value-of select="id"/><xsl:text>{</xsl:text>
              <xsl:if test="fill">
                 <xsl:text>;&#xA;    fill: </xsl:text><xsl:value-of select="fill"/>
              </xsl:if>
               <xsl:if test="stroke">
                 <xsl:text>;&#xA;    stroke: </xsl:text><xsl:value-of select="stroke"/>
              </xsl:if>             
              <xsl:if test="stroke-width">
                 <xsl:text>;&#xA;    stroke-width: </xsl:text><xsl:value-of select="stroke-width"/>
              </xsl:if>
              <xsl:if test="stroke-dasharray">
                 <xsl:text>;&#xA;    stroke-dasharray: </xsl:text><xsl:value-of select="stroke-dasharray"/>
              </xsl:if>
              <xsl:if test="fill-opacity">
                 <xsl:text>;&#xA;    fill-opacity: </xsl:text><xsl:value-of select="fill-opacity"/>
              </xsl:if>
              <xsl:if test="fill-rule">
                 <xsl:text>;&#xA;    fill-rule: </xsl:text><xsl:value-of select="fill-rule"/>
              </xsl:if>

              <xsl:text>&#xA;  }&#xA;</xsl:text>
           </xsl:for-each>
     </svg:style>
    </svg:defs>
    <xsl:copy-of select="$content"/>
  </svg:svg>
<!--
  </xsl:result-document>
-->
<!-- CR-????  -->
  <xsl:result-document href="{concat($acting_filestem,'.html')}"> 
     <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html4></xsl:text>
     <html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
		<link rel="stylesheet" type="text/css" href="erstyle.css"/>

		<script>
                    function notify(id){
		        var divElement = document.getElementById(id);
			divElement.style.display = 'block';
			divElement.style.visibility = 'visible';
			divElement.style.opacity = 1;}
		</script>

	</head>
     <body>
        <div> 
           <xsl:attribute name="class" select="'bigouter'"/>
           <div>
              <xsl:attribute name="class" select="'header'"/>
              <xsl:value-of select="absolute/name"/>
              <br/>
           </div>
           <xsl:call-template name="clearleft"/>
           <hr/>
           <xsl:call-template name="clearleft"/>
           <div> 
              <xsl:attribute name="class" select="'bigbody'"/>
              <div> 
                 <xsl:attribute name="class" select="'bigsvg'"/>
                 <embed>
                    <xsl:message>acting filestem is <xsl:value-of select="$acting_filestem"/></xsl:message>
                    <xsl:attribute name="src" select="concat($acting_filestem,'.svg')"/>
                 </embed>
              </div>
           </div>
        </div>
     </body>
     </html>
  </xsl:result-document>
<!--          -->
</xsl:template>

<xsl:template name="renderenclosure" match="enclosure">
    <svg:rect>
      <!--
      <xsl:choose>
         <xsl:when test="(depth mod 2) = 1">
           <xsl:attribute name="class">eteven</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">etodd</xsl:attribute>
         </xsl:otherwise>
      </xsl:choose>
    -->
      <xsl:attribute name="class"><xsl:value-of select="shape_style"/></xsl:attribute>
      <xsl:attribute name="x"><xsl:value-of select="x/abs"/>cm</xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="y/abs"/>cm</xsl:attribute>
      <xsl:attribute name="rx"><xsl:value-of select="rx"/>cm</xsl:attribute>
      <xsl:attribute name="ry"><xsl:value-of select="ry"/>cm</xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="w"/><xsl:text>cm</xsl:text></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="h"/><xsl:text>cm</xsl:text></xsl:attribute>
    </svg:rect>
	 <xsl:if test="debug-whitespace='true'">
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

    <svg:path>
       <xsl:attribute name="class" select="'outlinedebug'"/>
       <xsl:attribute name="d">
           <xsl:value-of select="concat( 'M',x/abs,    ',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs,    ',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs ,   ',',y/abs    )"/>
      </xsl:attribute>
    </svg:path>

    <svg:path>
       <xsl:attribute name="class" select="'margin'"/>
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
	
	<!-- 18 June 2019 Removed generation of a margin that duplicated the above - only effect being on colour. -->
    <!-- and remove inside padding 
    <svg:path>
       <xsl:attribute name="class" select="'padding'"/>
       <xsl:attribute name="d">
           <xsl:value-of select="concat( 'M',x/abs,    ',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs    )"/>
           <xsl:value-of select="concat(' L',x/abs + w,',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs,    ',',y/abs + h)"/>
           <xsl:value-of select="concat(' L',x/abs ,   ',',y/abs    )"/>
           <xsl:value-of select="concat(' M',x/abs - padding,      ',',y/abs - padding   )"/>
           <xsl:value-of select="concat(' L',x/abs + w + padding , ',',y/abs -padding   )"/>
           <xsl:value-of select="concat(' L',x/abs + w + padding,  ',',y/abs + h + padding)"/>
           <xsl:value-of select="concat(' L',x/abs - padding,      ',',y/abs + h + padding )"/>
           <xsl:value-of select="concat(' L',x/abs - padding ,      ',',y/abs - padding   )"/>
      </xsl:attribute>
    </svg:path>
	-->
    <!-- outside padding -->
	<xsl:call-template name="render_padding"/>
  </xsl:template>
  
  <xsl:template name="render_padding" match="enclosure|point">
      <svg:path>
       <xsl:attribute name="class" select="'padding'"/>
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
  </xsl:template>
  
  
  


<xsl:template name="clearleft">
   <div>
      <xsl:attribute name="style" select="'clear:left'"/>
   </div>
</xsl:template>

<xsl:template name="entity_type_box" saxon:trace="yes" xmlns:saxon="http://icl.com/saxon">
  <xsl:param name="isgroup"/>
  <xsl:param name="iseven"/>
  <xsl:param name="xcm"/>
  <xsl:param name="ycm"/>
  <xsl:param name="wcm"/>
  <xsl:param name="hcm"/>
  <xsl:param name="shape"/>
  <xsl:variable name="cornerRadiuscm">
    <xsl:choose>
       <xsl:when test="$isgroup">
           <xsl:value-of select="0"/>
       </xsl:when>
       <xsl:otherwise>
           <xsl:value-of select="0"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="xAdjustment">
    <xsl:choose>
     <xsl:when test="$shape='Top'">
        <xsl:value-of select="0"/>
     </xsl:when>
     <xsl:when test="$shape='TopLeft'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='MiddleLeft'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='BottomLeft'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='TopRight'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:when test="$shape='MiddleRight'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:when test="$shape='BottomRight'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:when test="$shape='Bottom'">
        <xsl:value-of select="0"/>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="0"/>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="yAdjustment">
    <xsl:choose>
     <xsl:when test="$shape='Top'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='TopLeft'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='MiddleLeft'">
        <xsl:value-of select="0"/>
     </xsl:when>
     <xsl:when test="$shape='BottomLeft'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:when test="$shape='TopRight'">
        <xsl:value-of select="-0.2"/>
     </xsl:when>
     <xsl:when test="$shape='MiddleRight'">
        <xsl:value-of select="0"/>
     </xsl:when>
     <xsl:when test="$shape='BottomRight'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:when test="$shape='Bottom'">
        <xsl:value-of select="0.2"/>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="0"/>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


<xsl:message>hcm is <xsl:value-of select="$hcm"/> </xsl:message>
<xsl:message>id is <xsl:value-of select="id"/> </xsl:message>
<xsl:message>node type is <xsl:value-of select="name()"/> </xsl:message>
  <svg:svg>
      <xsl:attribute name="x"><xsl:value-of select="$xcm - 0.1 - $xAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="$ycm - 0.1 - $yAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$wcm + 0.2"/><xsl:text>cm</xsl:text></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$hcm + 0.2"/><xsl:text>cm</xsl:text></xsl:attribute>
    <svg:rect>
      <xsl:choose>
         <xsl:when test="$isgroup">
           <xsl:attribute name="class">group</xsl:attribute>
         </xsl:when>
		 <xsl:when test="not (string-length($shape)=0)">
           <xsl:attribute name="class">etodd</xsl:attribute>
         </xsl:when>
         <xsl:when test="$iseven">
           <xsl:attribute name="class">eteven</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="class">etodd</xsl:attribute>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="onclick"><xsl:value-of select="concat('top.notify(''',name, '_text'')')"/></xsl:attribute>
      <xsl:attribute name="x"><xsl:value-of select="0.1 + $xAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="0.1 + $yAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="rx"><xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
      <xsl:attribute name="ry"><xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="$wcm"/><xsl:text>cm</xsl:text></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="$hcm"/><xsl:text>cm</xsl:text></xsl:attribute>
    </svg:rect>
  </svg:svg>
  
</xsl:template>


<xsl:template name="wrap_entity_type">
  <xsl:param name="content"/>
  <!--
  <xsl:message>wrap entity type <xsl:value-of select="name"/> </xsl:message>
  -->
  <svg:g>
    <xsl:attribute name="id">
      <xsl:value-of select="replace(name,' ','_')"/>    <!--cannot reference groups if names have spaces-->
    </xsl:attribute>
    <xsl:copy-of select="$content"/>
  </svg:g>
</xsl:template>


<xsl:template name="ERtext"> 
  <xsl:param name="x"/>
  <xsl:param name="y"/>
  <xsl:param name="xsign"/>
  <xsl:param name="pText"/>
  <xsl:param name="class"/>
  
  <xsl:variable name= "modifiedText">
    <xsl:choose>
	   <xsl:when test="$class='scope'">
     <xsl:value-of select = 
	 "replace(
	          replace(
	                   replace($pText,
		                       '=','&#x2272;'
				              ),
		               '\.\.','&#x2025;'
		              ),
 	          '~',' &#x021B7; '
			 )
	  "/>
	  </xsl:when>
	  <xsl:otherwise>
	     <xsl:value-of select="$pText"/>
	  </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="text-anchor">
      <xsl:choose>
        <xsl:when test="$xsign = 1">
          <xsl:text>start</xsl:text>
        </xsl:when>
        <xsl:when test="$xsign = 0">
          <xsl:text>middle</xsl:text>
        </xsl:when>
        <xsl:when test="$xsign = -1">
          <xsl:text>end</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Unexpected xsign</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <svg:text>
     <xsl:attribute name="class" select="$class"/>
     <xsl:choose>
        <xsl:when test="$class='relname' or $class='scope'">
           <xsl:attribute name="x" select="$x"/>
           <xsl:attribute name="y" select="$y"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:attribute name="x" select="concat($x,'cm')"/>
           <xsl:attribute name="y" select="concat($y,'cm')"/>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:attribute name="text-anchor" select="$text-anchor"/>
     <xsl:value-of select= "$modifiedText"/>
  </svg:text>
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
          <xsl:if test="debug-whitespace='true'">
            <xsl:call-template name="render_enclosure_margins"/>
          </xsl:if>
      </xsl:for-each>
	  <xsl:for-each select="//point">
          <xsl:if test="debug-whitespace='true'">
            <xsl:call-template name="render_padding"/>
          </xsl:if>
      </xsl:for-each>
	  
       <xsl:copy-of select="$relationships"/>
    </svg:svg>
</xsl:template>

<xsl:template name="path">
   <xsl:param name="x0cm"/>
   <xsl:param name="y0cm"/>
   <xsl:param name="x1cm"/>
   <xsl:param name="y1cm"/>
   <xsl:variable name="x0cm"  select="point[1]/x/abs"/>
   <xsl:variable name="y0cm"  select="point[1]/y/abs"/>
  <!-- <xsl:variable name="p1cm"  select="point[2]/concat(x/abs/offset,',',y/abs/offset)"/> -->
  <!-- <xsl:variable name="y1cm"  select="point[2]/y/abs/offset"/>  -->
  <svg:path>
    <xsl:attribute name="class"><xsl:value-of select="'route'"/></xsl:attribute>
    <xsl:attribute name="d">
      <xsl:value-of select="concat('M',$x0cm,',',$y0cm)"/>
      <xsl:for-each select="point[count(preceding-sibling::point) &gt; 0]">
           <xsl:value-of select="concat('L',concat(x/abs,',',y/abs))"/>
      </xsl:for-each>
    </xsl:attribute>
  </svg:path>
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
