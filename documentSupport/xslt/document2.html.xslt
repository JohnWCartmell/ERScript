<xsl:transform version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"           
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <!-- <?xml-stylesheet type="text/xsl" href="ERModel2HTML.xslt"?>  WHAT THE HECK WAS THIS DOING HERE-->

  <xsl:include href="symbols2.html.xslt"/>
  <xsl:include href="tables2.html.xslt"/>
  <xsl:include href="messages2.html.xslt"/>

  <!-- <xsl:strip-space elements="para quotation item a b span caption code couier eqref emph entity q qq sub sub var leader title trailer"/>-->
  <xsl:strip-space elements ="*"/>

  <xsl:param name="rootfolder"/>

  <xsl:variable name="pathtoroot" select="'..'"/>

  <xsl:variable name="runtimepathtosvgfiles" select="concat($pathtoroot,'/svg/')"/>
  <xsl:variable name="runtimepathtoimages" select="concat($pathtoroot,'/images/')"/>

<!--   <xsl:variable name="parentpath"
      select="'file:///C:/Users/John/Documents/Cloudwork/Scripting/entitymodellingbook'" /> -->
      <xsl:variable name="parentpath" select="'..'"/> <!--   6 Aug 2023
                                                              also changed all uses of document() to have second argument . 
                                                             this has effect of interpreting relative paths as relative to source document -->

  <xsl:variable name="svgFolder" select="'../www.entitymodelling.org/svg/'"/> 
  <xsl:variable name="eqnFolder" select="'../tex_source/'"/>
  <!-- ??????????????????  -->
  <!--<xsl:variable name="chapterFolder" select="/chapter/label"/>-->

  <xsl:key name="chapter" match="chapter"   use="label"/> 
  <xsl:key name="section" match="section"   use="label"/>
  <xsl:key name="entry"  match="  article
      | book
      | incollection
      | inproceedings
      | misc
      | phdthesis
      | techreport
      " 
      use="label"/>
  <xsl:key name="figure"  match="figure
      |figureOfEquation
      |figureOfPicture
      |figureOfPictureWithNote" 
      use="label"/>

  <xsl:key name="table"   match="tabledisplay"     use="label"/>
  <xsl:key name="equation" match="equation" use="label"/>



  <xsl:template match="/document"> 
    <xsl:apply-templates>
      <xsl:with-param name="sidebarcontent">
        <xsl:apply-templates select="." mode="sidebar"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>      

  <xsl:variable name="rootprefix" select="if ($pathtoroot='') then '' else concat($pathtoroot,'/')"/>

  <xsl:template name="sidebar" match="document" mode="sidebar">
    <div id="cssmenu" class="sidebar">
      <ul> 
        <li>
          <a id="home" href="{concat($rootprefix,'home/overview.html')}">
            <span>Home</span>
          </a>
        </li>	      
        <xsl:apply-templates mode="sidebar"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="chapter" mode="sidebar">
    <li class='has-sub'>
      <a id="{label}" href="{concat($rootprefix,label,'/overview.html')}">
        <span>
          <xsl:value-of select="title"/>
        </span>
      </a>
      <xsl:if test="section">
        <ul id="{label}">
          <xsl:variable name="chapterlabel" select="label"/>
          <xsl:for-each select="section">
            <li>
              <a id="{concat($chapterlabel,'.',label)}"
                  href="{concat($rootprefix,$chapterlabel,'/',label,'.html')}">
                <xsl:value-of select="title"/>
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="*" mode="sidebar">
  </xsl:template>


  <xsl:template name="wrap_page_and_output" >
    <xsl:param name="filepath"/>
    <xsl:param name="sidebarcontent"/>
    <xsl:param name="page_content"/>

    <xsl:result-document href="{$filepath}">
      <html>
        <head>

    <!-- Google tag (gtag.js) -->
    <script async="async" src="https://www.googletagmanager.com/gtag/js?id=G-732VLCP0ME"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', 'G-732VLCP0ME');
    </script>

          <link href='https://fonts.googleapis.com/css?family=Montserrat:400' rel='stylesheet' type='text/css'/>
          <link rel="stylesheet" type="text/css" href="/css/erstyle.css" media="screen" />
          <link rel="stylesheet" type="text/css" href="/css/cssmenustyles.css"   media="screen" />
          <link rel="stylesheet" type="text/css" href="/css/print.css"           media="print" />
          <link rel="stylesheet" type="text/css" href="/css/printmenustyles.css" media="print" />
  <!-- start new 2 aug 2023 -->
  <!--<link rel="stylesheet" type="text/css" href="/css/ersvgdiagramwrapper.css"/>-->
          <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="/css/erdiagramsvgstyles.css"/>
    <!--      <script src="/js/ersvgdiagraminteraction.js">
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
          </script>
          <script src="/js/draggable.js">
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
           </script>   
         -->
              <svg>
                 <defs>
                    <marker id="crowsfoot"
                             markerWidth="10"
                             markerHeight="12"
                             refX="10"
                             refY="6"
                             stroke-width="1"
                             stroke="black"
                             orient="auto-start-reverse">
                       <path d="M 0,6 L 10,12 M 0,6 L 10,6 M 0,6 L 10,0"/>
                    </marker>
                    <marker id="identifying"
                             markerWidth="17"
                             markerHeight="16"
                             refX="16"
                             refY="6"
                             stroke-width="1"
                             stroke="black"
                             orient="auto-start-reverse">
                       <path d="M 1,1 L 1,11"/>
                    </marker>
                    <marker id="squiggle"
                             markerWidth="10"
                             markerHeight="22"
                             refX="28"
                             refY="11"
                             stroke="black"
                             fill="none"
                             orient="auto-start-reverse">
                       <path d="M 0,13 C 3,0 6,22 9,9"/>
                    </marker>
                 </defs>
              </svg>
  <!-- end new 2nd Aug 2023 -->               
          <script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"/>
          <script src="/js/w3c_script.js"/>
          <script>
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
            })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

            ga('create', 'UA-30358501-3', 'auto');
            ga('send', 'pageview');
          </script>
          <style>
            ul#<xsl:value-of select="ancestor-or-self::chapter/label"/> {display: block !important ;}
          </style>
        </head>
        <body>

          <div class="outer">
            <div class="header">
              Entity Modelling 
              <br/>
              <p>www.entitymodelling.org - entity modelling introduced from first principles - relational database design theory and practice - dependent type theory</p>
            </div>
            <div style="clear:left"/>
            <hr/>    
            <div style="clear:left"/>
            <div class="body">
              <xsl:copy-of select="$sidebarcontent"/>
              <xsl:copy-of select="$page_content"/>
            </div>
            <div style="clear:left"/>
            <hr/>
            <div style="clear:left"/>
            <div class="footer">
              Copyright John Cartmell 2013-2023
            </div>
          </div>
        </body>
        <script>
          includeHTML();
        </script>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="bibref">
    <xsl:for-each select="key('entry',entry)">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="article
      | book
      | incollection
      | inproceedings
      | misc
      | phdthesis
      | techreport">
    <xsl:variable name="volumeNumberPages">
      <xsl:value-of select="volume"/>
      <xsl:if test="number">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="number"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="pages">
        <xsl:text>:</xsl:text>
        <xsl:value-of select="pages"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="author">
      <xsl:apply-templates select="author"/>
      <xsl:text>. </xsl:text>
    </xsl:if>

    <xsl:if test="self::phdthesis">
      <xsl:apply-templates select="title"/>
      <xsl:text>. </xsl:text>
      <xsl:text>PhD thesis, </xsl:text> 
    </xsl:if>
    <xsl:choose>
      <xsl:when test="self::article">
        <xsl:apply-templates select="title"/>
        <xsl:text>. </xsl:text>
        <i>
          <xsl:value-of select="journal"/>
        </i>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="string-join(
            (($volumeNumberPages,
            booktitle,
            series,
            school,
            if (issue_date) then issue_date else concat(month,' ',year)
            )),', ')"/>
      </xsl:when>
      <xsl:when test="self::incollection">
        <xsl:apply-templates select="title"/>
        <xsl:text>. </xsl:text>
        <xsl:text>In </xsl:text> 
        <xsl:value-of select="editor"/>
        <xsl:text>, editor, </xsl:text>
        <i>
          <xsl:value-of select="booktitle"/>
        </i>
        <xsl:if test="volume">
          <xsl:text>, volume </xsl:text>
          <xsl:value-of select="volume"/>                        
        </xsl:if>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="string-join(
            ((
            series,
            pages,
            address,
            school,
            publisher,
            year,
            eprint)),', ')"/>

      </xsl:when>
      <xsl:when test="self::inproceedings">
        <xsl:apply-templates select="title"/>
        <xsl:text>. </xsl:text>
        <xsl:text>In </xsl:text> 
        <i>
          <xsl:value-of select="booktitle"/>
        </i>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="string-join(
            ((
            series,
            pages,
            address,
            school,
            year,
            publisher,
            eprint)),', ')"/>

      </xsl:when>
      <xsl:when test="self::techreport">
        <xsl:apply-templates select="title"/>
        <xsl:text>. </xsl:text>
        <xsl:text>Technical Report, </xsl:text>
        <xsl:value-of select="string-join(
            ((
            institution,
            year
            )),', ')"/>
      </xsl:when>
      <xsl:when test="self::book">
        <i>
          <xsl:apply-templates select="title"/>
          <xsl:text>. </xsl:text>
        </i>
        <xsl:value-of select="string-join(
            ((
            series,
            pages,
            publisher,
            address,
            year,
            eprint)),', ')"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="title"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="string-join(
            ((booktitle,
            series,
            pages,
            address,
            school,
            year,
            publisher,
            eprint)),', ')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="bibliography/*/title">
    <xsl:value-of select="."/>
  </xsl:template>
  <!--
    <xsl:template match="document/preface/chapter" priority="1000">      
        <xsl:message>pathtoroot is <xsl:value-of select="$pathtoroot"/></xsl:message>
        <xsl:message>In /chapter <xsl:value-of select="title"/></xsl:message>
        <xsl:call-template name="chapterpage"/>
        <xsl:for-each select="section">
            <xsl:call-template name="sectionpage"/>
        </xsl:for-each>
    </xsl:template>
    
    -->
  <xsl:template name="chapterpage" match="chapter">
    <xsl:param name="sidebarcontent"/>
    <xsl:message>Chapter <xsl:value-of select="title"/> label <xsl:value-of select="label"/> title <xsl:value-of select="title"/>
    </xsl:message>
    <xsl:call-template name="wrap_page_and_output">
      <xsl:with-param name="filepath" 
          select="concat($rootfolder,'/',label,'/overview.html')"/>
      <xsl:with-param name="sidebarcontent" select="$sidebarcontent" />
      <xsl:with-param name="page_content"> 
        <xsl:element name="div">
          <xsl:attribute name="class" select="'page'"/>
          <div class="pageheader" > 
            <i>
              <xsl:value-of select="title"/>
            </i>
          </div>
          <h2>
            <xsl:apply-templates select="subtitle"/>
          </h2>
          <xsl:apply-templates select="preface"/>
          <p>
            <xsl:apply-templates select="leader"/>  
            <xsl:for-each select="section">
              <xsl:apply-templates select="leader"/>
              <ul>
                <li>
                  <a href="{concat($pathtoroot,'/',../label,'/',label,'.html')}">
                    <xsl:value-of select="lower-case(title)"/>
                  </a>
                  <xsl:apply-templates select="trailer"/>
                </li>
              </ul>
            </xsl:for-each>
            <xsl:if test="parent::preface">  
              <!-- we are generating the home page -->
              <xsl:for-each select="ancestor::document/chapter">
                <xsl:call-template name="contents_entry"/>
              </xsl:for-each>
            </xsl:if>
          </p> 
          <div style="clear:left"/>
          <hr/>
          <xsl:for-each select="preface">
            <xsl:call-template name="footnotes"/>
          </xsl:for-each>
          <div style="clear:left"/>
        </xsl:element>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="sidebarcontent" select="$sidebarcontent"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template  name="contents_entry" match="chapter" mode="contents">
    <xsl:element name="p">
      <a>
        <xsl:attribute name="href" select="concat($pathtoroot,'/',label,'/overview.html')"/>
        <xsl:value-of select="title"/>
      </a> 
      <xsl:text> &#8212;</xsl:text>
      <em>
        <xsl:apply-templates select="subtitle"/>
      </em>
      <xsl:apply-templates select="explanation"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="a">
    <xsl:copy >
      <!-- this copies element name -->
      <xsl:copy-of select="@*"/>
      <!-- this copies all its attributes -->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
 <xsl:template match="block">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'block'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::width)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="center">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'centercontent'"/>
          <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="code">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'code'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="commentary">
    <xsl:element name="p">
      <xsl:attribute name="class" select="'small'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="courier">
    <xsl:element name="span">
      <xsl:attribute name="class" select="'courier'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'div'"/>
      <xsl:if test="maxwidth">
        <xsl:attribute name="style" select="concat('width:',maxwidth)"/>
      </xsl:if>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width,';margin:auto')"/>
      </xsl:if>
      <xsl:if test="padding">
        <xsl:attribute name="style" select="concat('padding:',padding)"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::padding|self::maxwidth|self::width)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="emph">
    <xsl:element name="em">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="entity">
    <xsl:element name="em">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="equation">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displayequation'"/>
      <xsl:element name="table">
        <xsl:attribute name="class" select="'equation'"/>
        <xsl:element name="tr">
          <xsl:element name="td">
            <xsl:apply-templates select="text()|*[not(self::label) and not(self::number)]"/>
          </xsl:element>
          <xsl:element name="td">
            <xsl:attribute name="class" select="'eqno'"/>
            (<xsl:value-of select="number"/>)       
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
    <div style="clear:left"/>
  </xsl:template>
  <!--
    <xsl:template match="equation/number">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'eqno'"/>
           (<xsl:number count="equation/number" level="any"/>)
        </xsl:element>
        <div style="clear:left"/>
    </xsl:template>
-->
  <xsl:template match="eqref">
    <xsl:variable name="label" select="equation"/>
    <xsl:variable name="referenced" select="//(equation)
        [label=$label]" />  
    <xsl:for-each select="$referenced">
      <xsl:value-of select="number"/>
    </xsl:for-each>
    <xsl:if test="not($referenced)">
      <xsl:message>WARNING:  No such equation as referenced: '<xsl:value-of select="."/>'</xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="equ_center">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displaypicture'"/>
      <xsl:element name="img">
        <xsl:attribute name="class" select="'er'"/>
        <xsl:if test="filename">
          <xsl:attribute name="src" select="concat($runtimepathtoimages,'/',filename,'.png')"/>
          <xsl:message>DEPRECATED use of filename in equ_center ... use equationName instead</xsl:message>
        </xsl:if>
        <xsl:if test="equationName">
          <xsl:attribute name="src" select="concat($runtimepathtoimages,'/',equationName,'.png')"/>
        </xsl:if>
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="equ_inline">
    <xsl:element name="img">
      <xsl:attribute name="class" select="'er'"/>
      <xsl:attribute name="src" select="concat($runtimepathtoimages,equationName,'.png')"/>
      <xsl:attribute name="class" select="'inline'"/>
      <xsl:attribute name="style" select="concat('width:',width)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="er_center">
    <xsl:variable name="svg">
      <xsl:sequence select="document(concat($svgFolder,filename,'.svg'),.)"/>  <!-- ADDED A DOT SO THAT RELATIVE TO INPUT DOC -->
    </xsl:variable>
    <xsl:if test="$svg=''">
      <xsl:message> Filename <xsl:value-of select="concat($svgFolder,filename,'.svg')"/> not found </xsl:message>
    </xsl:if>
    <xsl:element name="div">
      <xsl:attribute name="style" select="'width:100%;padding:0.5cm'"/>
      <xsl:element name="div">
        <xsl:attribute name="style" select="concat('display:block;margin:0 auto; width:',$svg/(*:svg)/@width)"/>

        <xsl:element name="object">
          <xsl:attribute name="id" select="'svg-object'"/>
          <xsl:attribute name="data" select="concat($runtimepathtosvgfiles,filename,'.svg')"/>
          <xsl:attribute name="type" select="'image/svg+xml'"/>
          <xsl:text>filler to stop contraction of this xml element</xsl:text>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="er_inline">
    <xsl:variable name="svg">
      <xsl:sequence select="document(concat($svgFolder,filename,'.svg'),.)"/>
    </xsl:variable>
    <xsl:if test="$svg=''">
      <xsl:message> Filename <xsl:value-of select="concat($svgFolder,filename,'.svg')"/> not found </xsl:message>
    </xsl:if>

<!-- 
    <xsl:element name="img">
      <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,filename,'.svg')"/>
      <xsl:attribute name="class" select="'inline'"/>
    </xsl:element>
 -->
    <xsl:element name="object">
      <xsl:attribute name="id" select="'svg-object'"/>
      <xsl:attribute name="class" select="'inline'"/>
      <xsl:attribute name="data" select="concat($runtimepathtosvgfiles,filename,'.svg')"/>
      <xsl:attribute name="type" select="'image/svg+xml'"/>
      <xsl:text>filler to stop contraction of this xml element</xsl:text>
    </xsl:element>


  </xsl:template>

  <xsl:template match="figure">
    <xsl:message>figure label <xsl:value-of select="label"/></xsl:message>
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displayfigure'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width,';margin:auto')"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::label or self::number or self::width)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figure/caption
      |figureOfEquation/caption
      |figureOfPicture/caption
      |figureOfPictureWithNote/caption">
    <!-- <div style="clear:left"></div> -->
    <xsl:element name="div">
      <xsl:attribute name="class" select="'caption'"/>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'captionHeading'"/>
        Figure <xsl:text>   </xsl:text> 
        <xsl:value-of select="../number"/>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figuregroup">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'figuregroup'"/>
      <xsl:if test="maxwidth">
        <xsl:attribute name="style" select="concat('width:',maxwidth)"/>
      </xsl:if>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width,';margin:auto')"/>
      </xsl:if>
      <xsl:if test="padding">
        <xsl:attribute name="style" select="concat('padding:',padding)"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::padding|self::maxwidth|self::width)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figureOfPicture">
    <xsl:variable name="svg">
      <xsl:sequence select="document(concat($svgFolder,pictureName,'.svg'),.)"/>
    </xsl:variable>
    <xsl:if test="$svg=''">
      <xsl:message> Filename <xsl:value-of select="concat($svgFolder,pictureName,'.svg')"/> not found </xsl:message>
    </xsl:if>
    <xsl:variable name="width">
      <xsl:value-of select="if (width) then width else '90%'"/>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displayfigure'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:if>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'div'"/>
        <xsl:attribute name="style" select="concat(
            'padding:0.1cm;',
            if (framewidth) then concat('width:',framewidth) else ''
            )"/>
        <xsl:variable name="imgwidth" select="if (imgwidth) then imgwidth else $svg/(*:svg)/@width" />
        <xsl:element name="div">
          <xsl:attribute name="class" select="'er'"/>
          <xsl:attribute name="style" select="concat('margin:auto;width:',
              $imgwidth
              )"/>


<!--
          <xsl:element name="img" >
            <xsl:attribute name="class" select="'er'"/>
            <xsl:if test="imgwidth">
              <xsl:attribute name="style" select="concat('width:',imgwidth)"/>
            </xsl:if>
            <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
          </xsl:element>
        -->

          <xsl:element name="object">
            <xsl:attribute name="id" select="'svg-object'"/>
            <xsl:attribute name="class" select="'er'"/>
            <xsl:if test="imgwidth">
              <xsl:attribute name="style" select="concat('width:',imgwidth)"/>
            </xsl:if>
            <xsl:attribute name="data" select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
            <xsl:attribute name="type" select="'image/svg+xml'"/>
            <xsl:text>filler to stop contraction of this xml element</xsl:text>
          </xsl:element>



        </xsl:element>
      </xsl:element>
      <div style="clear:left"/>
      <xsl:apply-templates select="caption"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figureOfPictureWithNote">
    <xsl:variable name="svg">
      <xsl:sequence select="document(concat($svgFolder,pictureName,'.svg'),.)"/>
    </xsl:variable>
    <xsl:if test="$svg=''">
      <xsl:message> Filename <xsl:value-of select="concat($svgFolder,pictureName,'.svg')"/> not found </xsl:message>
    </xsl:if>
    <xsl:variable name="svgimgwidthcms" 
                  as="xs:double" 
                  select="number(substring-before($svg/(*:svg)/@width,'cm'))" />
    <xsl:variable name="svgimgheightcms" 
                  as="xs:double"
                  select="number(substring-before($svg/(*:svg)/@height,'cm'))" />

    <xsl:variable name="imgwidthcms"  select="if (imgscale) 
                                              then $svgimgwidthcms * imgscale
                                              else $svgimgwidthcms" />
    <xsl:variable name="imgheightcms" select="if (imgscale) 
                                              then $svgimgheightcms * imgscale 
                                              else $svgimgheightcms" />
    <xsl:variable name="imgwidth"  select="format-number($imgwidthcms, '#.00') || 'cm'"/>
    <xsl:variable name="imgheight"  select="format-number($imgheightcms, '#.00') || 'cm'"/>

    <xsl:variable name="width">
      <xsl:value-of select="if (width) then width else '90%'"/>
    </xsl:variable>
    <xsl:variable name="notewidth">
      <xsl:value-of select="if (note/width) then note/width else '6cm'"/>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displayfigure'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:if>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'div'"/>
        <xsl:attribute name="style" select="concat(
            'padding:0.1cm;',
            if (framewidth) then concat('width:',framewidth) else ''
            )"/>


        <xsl:element name="div">
          <xsl:attribute name="class" select="'er'"/>
          <xsl:attribute name="style" select="'margin:auto'"/>
          <xsl:element name="a">
            <xsl:attribute name="href" select="href"/>
            <xsl:attribute name="target" select="'_blank'"/>

<!--
            <xsl:element name="object">
              <xsl:attribute name="id" select="'svg-object'"/>
              <xsl:attribute name="class" select="'er'"/>
              <xsl:if test="imgwidth">
                <xsl:attribute name="style" select="concat('width:',imgwidth)"/>
              </xsl:if>
              <xsl:attribute name="data" select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
              <xsl:attribute name="type" select="'image/svg+xml'"/>
              <xsl:text>filler to stop contraction of this xml element</xsl:text>
            </xsl:element>
   -->
            
              <xsl:choose>
                <xsl:when test="imgscale">                  
                  <xsl:element name="svg">
                    <xsl:attribute name="width" select="$imgwidth"/>
                    <xsl:attribute name="height" select="$imgheight"/>
                    <xsl:element name="g">
                      <xsl:attribute name="w3-include-html" 
                                     select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
                      <xsl:attribute name="transform" 
                                     select="'scale(' || imgscale || ' ' || imgscale || ')'"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="div">
                    <xsl:attribute name="w3-include-html" 
                                   select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:element>  <!-- </a>  -->
        </xsl:element>   <!-- </div> -->
      </xsl:element>  <!-- </div> -->

      <xsl:variable name="note" >
        <xsl:element name="div">
          <xsl:attribute name="class" select="'middledContent'"/>
          <xsl:attribute name="style" select="concat('width:',$notewidth
              )"/>
          <xsl:for-each select="note">
            <xsl:apply-templates select="*[not(self::width)]"/>            
          </xsl:for-each> 
          <xsl:if test="not(*[self::muchtext])">
            <xsl:apply-templates select="caption"/>
          </xsl:if>
        </xsl:element>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="lowertext">
          <xsl:copy-of select="$note"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="div">
            <xsl:attribute name="class" select="'middlingContainer'"/>
            <xsl:attribute name="style" select="'height:' || $imgheight"/>
            <xsl:copy-of select="$note"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="*[self::muchtext]">
        <div style="clear:left"/>
        <xsl:apply-templates select="caption"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figureOfEquation">
    <xsl:variable name="width">
      <xsl:value-of select="if (width) then width else '90%'"/>
    </xsl:variable>
    <xsl:variable name="notewidth">
      <xsl:value-of select="if (note/width) then note/width else '6cm'"/>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displayfigure'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:if>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'div'"/>
        <xsl:attribute name="style" select="concat(
            'padding:0.1cm;',
            if (framewidth) then concat('width:',framewidth) else ''
            )"/>
        <xsl:element name="div">
          <xsl:element name="img">
            <xsl:attribute name="src" select="concat($runtimepathtoimages,'/',equationName,'.png')"/>
            <xsl:attribute name="style" select="concat('width:',framewidth)"/>
          </xsl:element>

        </xsl:element>
      </xsl:element>
      <xsl:element name="div">
        <xsl:element name="div">
          <xsl:for-each select="note">
            <xsl:copy>
              <xsl:apply-templates select="*[not(self::width)]"/>            
            </xsl:copy>
          </xsl:for-each> 
          <xsl:apply-templates select="caption"/>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figref">
    <xsl:variable name="label" select="figure"/>

    <!-- Occasionally have multipel figures with same label because picture is repeated elsewhere -->
    <!-- First look in containing section -->

    <xsl:variable name="foundinsection" 
        select="ancestor::section/(descendant::figure
        |descendant::figureOfPicture
        |descendant::figureOfPictureWithNote
        |descendant::figureOfEquation)
        [pictureName=$label or equationName=$label or label=$label]"/>
    <xsl:variable name="foundinchapter" 
        select="ancestor::chapter/(descendant::figure
        |descendant::figureOfPicture
        |descendant::figureOfPictureWithNote
        |descendant::figureOfEquation)
        [pictureName=$label or equationName=$label or label=$label]" />
    <xsl:variable name="foundindocument" 
        select="ancestor::document/(descendant::figure
        |descendant::figureOfPicture
        |descendant::figureOfPictureWithNote
        |descendant::figureOfEquation)
        [pictureName=$label or equationName=$label or label=$label]" />
    <xsl:variable name="referenced" select="if ($foundinsection) 
        then $foundinsection
        else (if ($foundinchapter) then $foundinchapter else $foundindocument)"/>
    <xsl:for-each select="$referenced">
      <xsl:value-of select="number"/>
    </xsl:for-each>
    <xsl:if test="not($referenced)">
      <xsl:message>WARNING:  No such figure as referenced: '<xsl:value-of select="."/>'</xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="footnote">
    <sup>
      <xsl:number count="footnote" from="section|chapter" level="any"/>
    </sup>
  </xsl:template>

  <xsl:template name="footnotes" match="preface|section" mode="explicit">
    <div>
      <xsl:for-each select="descendant::footnote">
        <div class="footnote" style="clear:left">
          <sup>
            <xsl:value-of select="position()"/>
          </sup> 
          <xsl:copy>
            <xsl:apply-templates/>
          </xsl:copy>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="format">
    <!-- ...deliberately empty-->
  </xsl:template>


  <xsl:template match="hspace">
    <xsl:element name="div">
      <!--<xsl:attribute name="class" select="'div'"/>-->
      <xsl:attribute name="style" select="concat('display: inline-block; overflow: hidden; height: 1px; width:',@width)"/>
      hhhhhh
    </xsl:element>
  </xsl:template>


  <xsl:template match="item">
    <xsl:element name="li">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="itemize">
    <xsl:element name="ul">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="latex">
    <!-- ...deliberately empty-->
  </xsl:template>

  <xsl:template match="longrightarrow">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'longrightarrow'"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="newline">
    <div style="clear:left"/>
  </xsl:template>

  <xsl:template match="note/para">
    <xsl:element name="p">
      <xsl:attribute name="class" select="'small'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="para">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'normal'"/>
      <xsl:element name="p">
        <xsl:attribute name="class" select="'normal'"/>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="picture">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displaypicture'"/>
      <xsl:element name="img">
        <xsl:attribute name="class" select="'er'"/>
        <xsl:attribute name="src" select="concat($runtimepathtoimages,filename,'.png')"/>
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="position">
    <!-- ...deliberately empty-->
  </xsl:template>

  <xsl:template match="production">
    <xsl:element name="div">
      <xsl:element name="div">
        <xsl:attribute name="class" select="'div'"/>
        <xsl:apply-templates select="lhs"/>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'longrightarrow'"/>
      </xsl:element>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'div'"/>
        <xsl:apply-templates select="rhs"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="q">
    <xsl:call-template name="leftsinglequote"/>
    <xsl:value-of select="."/>
    <xsl:call-template name="rightsinglequote"/>
  </xsl:template>

  <xsl:template match="qq">
    "<xsl:value-of select="."/>"
  </xsl:template>

  <xsl:template match="quotation">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'quotation'"/>
      <xsl:apply-templates/>
    </xsl:element>
    <div style="clear:left"/>  <!-- 14 Nov 2017 -->
  </xsl:template>

  <xsl:template match="refchapter" >
    <xsl:variable name="chapter" select="key('chapter',chapter)"/>
    <xsl:if test="not($chapter)">
      <xsl:message>Broken reference to chapter '<xsl:value-of select="chapter"/>' from section <xsl:value-of select="ancestor-or-self::section/concat(../label,'.',label)"/>
      </xsl:message>
    </xsl:if>
    <a>
      <xsl:attribute name="href" select="concat($pathtoroot,'/',chapter,'/overview.html')"/>
      <xsl:value-of select="$chapter/title"/>
    </a>
  </xsl:template>

  <xsl:template match="refsection" >
    <xsl:variable name="section" select="key('section',section)"/>
    <xsl:if test="not($section)">
      <xsl:message>Broken reference to section '<xsl:value-of select="section"/>' from section <xsl:value-of select="ancestor-or-self::section/concat(../label,'.',label)"/>
      </xsl:message>
    </xsl:if>
    <a>
      <xsl:attribute 
          name="href" 
          select="concat($pathtoroot,'/',
          $section/ancestor::chapter/label,
          '/',$section/label,'.html')"/>
      <xsl:value-of select="lower-case($section/title)"/>
    </a>
  </xsl:template>
  <!--
    <xsl:template match="section">
        <div style="clear:left"/> 
        <xsl:apply-templates/>
    </xsl:template>
    
    -->

  <xsl:template name="sectionpage" match="section">
    <xsl:param name="sidebarcontent"/>
    <xsl:variable name="chapterFolderName" select="..[self::chapter]/label" />
    <xsl:call-template name="wrap_page_and_output">
      <xsl:with-param name="filepath" select="concat($rootfolder,'/',$chapterFolderName,'/',label,'.html')"/>
      <xsl:with-param name="sidebarcontent" select="$sidebarcontent" />
      <xsl:with-param name="page_content">
        <xsl:element name="div">
          <xsl:attribute name="class" select="'page'"/>

          <div class="pageheader" > 
            <i>
              <xsl:apply-templates select="../subtitle"/>
            </i>
          </div>
          <xsl:apply-templates select="*[not(self::label|self::leader|self::trailer)]"/> 
          <div style="clear:left"/>
          <hr/>
          <xsl:call-template name="footnotes"/>
          <div style="clear:left"/>
          <div class="bottomnavigation">
            <div style="float:left">
              <xsl:if test="preceding-sibling::section[1]">
                <a href="{concat($pathtoroot,'/',$chapterFolderName,'/',preceding-sibling::section[1]/label,'.html')}">
                  PREVIOUS <xsl:value-of select="   preceding-sibling::section[1]/title"/>
                </a>
              </xsl:if>
            </div>
            <div style="float:right">
              <xsl:choose>
                <xsl:when test="following-sibling::section">
                  <a href="{concat($pathtoroot,'/',$chapterFolderName,'/',following-sibling::section[1]/label,'.html')}">
                    NEXT <xsl:value-of select="   following-sibling::section[1]/title"/>
                  </a>
                </xsl:when>
                <xsl:when test="ancestor::chapter/following-sibling::chapter">
                  <a href="{concat($pathtoroot,'/',ancestor::chapter/following-sibling::chapter[1]/label,'/overview.html')}">
                    NEXT Chapter <xsl:value-of select="ancestor::chapter/following-sibling::chapter[1]/title"/>
                  </a>
                </xsl:when>
              </xsl:choose>
            </div>
          </div>
        </xsl:element>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="section/title">
    <xsl:element name="h2">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="small">
    <xsl:element name="span">
      <xsl:attribute name="class" select="'small'"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="sub">
    <xsl:element name="sub">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="subsection">
    <xsl:element name="div">
      <xsl:attribute name="style" select="'clear:left'"/>
      <xsl:if test="label">
        <xsl:attribute name="id" select="label"/>
      </xsl:if>
    </xsl:element>
    <xsl:apply-templates select="*[not(self::label)]"/>
  </xsl:template>

  <xsl:template match="subsection/title">
    <xsl:element name="h3">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="sup">
    <xsl:element name="sup">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>



  <xsl:template match="tabledisplay">
    <xsl:element name="div">
      <xsl:attribute name="class" select="'displaytable'"/>
      <xsl:if test="width">
        <xsl:attribute name="style" select="concat('width:',width)"/>
      </xsl:if>
      <xsl:apply-templates select="*[not(self::label|self::width|self::number)]"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tabledisplay/caption">
    <!-- <div style="clear:left"></div> -->
    <xsl:element name="div">
      <xsl:attribute name="class" select="'caption'"/>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'captionHeading'"/>
        Table <xsl:text>   </xsl:text>
        <xsl:value-of select="../number"/>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>
    <div style="clear:left"/>
  </xsl:template>

  <xsl:template match="tableref">
    <xsl:variable name="label" select="table"/>
    <xsl:variable name="referenced" select="//tabledisplay
        [label=$label]" />
    <xsl:for-each select="$referenced">
      <xsl:value-of select="number"/>
    </xsl:for-each>
    <xsl:if test="not($referenced)">
      <xsl:message>WARNING:  No such table as referenced: '<xsl:value-of select="."/>'</xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="textarea">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="text"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="title">
    <!--generic title ...deliberately empty-->
  </xsl:template>


  <xsl:template match="u">
    <xsl:element name="u">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="var">
    <xsl:element name="i">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="verbatim">
    <div align="middle">
      <xsl:element name="pre">
        <xsl:copy-of select="."/> 
        <!--  <xsl:apply-templates/> -->
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="vspace">
    <xsl:element name="div">
      <!--<xsl:attribute name="class" select="'div'"/>-->
      <xsl:attribute name="style" select="concat('float: left; overflow: hidden; height:',@height, '; width:1px')"/>
      VVVVV
    </xsl:element>
    <xsl:element name="div">
      <xsl:attribute name="style" select="'clear:left'"/>
    </xsl:element>  
  </xsl:template>

  <!--
<xsl:template match="*" mode="verbatim">
   <xsl:value-of select = "name()"/>
   <xsl:apply-templates mode="verbatim"/>
   <xsl:value-of select = "name()"/>
</xsl:template>
-->

  <!-- The wildcard -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>
