<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <?xml-stylesheet type="text/xsl" href="ERModel2HTML.xslt"?>

    <xsl:param name="rootpath"/>
    <xsl:param name="sidebarstem"/>

    <xsl:variable name="runtimepathtosvgfiles" select="concat($rootpath,'/svg/')"/>
    <xsl:variable name="runtimepathtoimages" select="concat($rootpath,'/images/')"/>
    <xsl:variable name="svgFolder" select="'testwebsite/svg/'"/>
    <xsl:variable name="eqnFolder" select="'../tex_source/'"/>
    <xsl:variable name="chapterFolder" select="/chapter/label"/>

    <xsl:template name="wrap_page_and_output" >
        <xsl:param name="filepath"/>
        <xsl:param name="sidebarfilepath"/>
        <xsl:param name="page_content"/>

        <xsl:result-document href="{$filepath}">
            <html>
                <head>
                    <link href='https://fonts.googleapis.com/css?family=Montserrat:400' rel='stylesheet' type='text/css'/>
                    <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/erstyle.css')}" />
                    <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/cssmenustyles.css')}" />
                    <script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"/>
                    <script src="{concat($rootpath,'/script.js')}"/>
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
                            <xsl:variable name="sidebar" 
		     select="document($sidebarfilepath)"/>
                            <xsl:copy-of select="$sidebar"/>
                            <xsl:copy-of select="$page_content"/>
                        </div>
                        <div style="clear:left"/>
                        <hr/>
                        <div style="clear:left"/>
                        <div class="footer">
         Copyright John Cartmell 2013-2016
                        </div>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="/bibliography">

        <!-- <xsl:apply-templates select="key('bib', ., document('bib.xml'))"/>    -->
        <xsl:call-template name="bibliographypage"/>
    </xsl:template>

    <xsl:template name="bibliographypage" match="bibliography">
        <xsl:call-template name="wrap_page_and_output">
            <xsl:with-param name="filepath" select="concat('','bibliography.html')"/>
            <xsl:with-param name="sidebarfilepath" select="concat('whole thing/temp/',$sidebarstem,'.html')" />
            <xsl:with-param name="page_content"> 
                <xsl:element name="div">
                    <xsl:attribute name="class" select="'page'"/>
                    <div class="pageheader" > 
                        <i>Bibliography</i>
                    </div>
                    <h2>
                        <xsl:value-of select="'Bibliography'"/>
                    </h2>

                    <xsl:apply-templates />
                </xsl:element>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="bibliography/article
                     | bibliography/book
                     | bibliography/incollection
                     | bibliography/inproceedings
                     | bibliography/misc
                     | bibliography/phdthesis
                     | bibliography/techreport">
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
        <xsl:element name="div">
            <xsl:attribute name="class" select="'bibentry'"/>
            <xsl:if test="author">
                <xsl:apply-templates select="author"/>
                <xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="title"/>
            <xsl:text>. </xsl:text>

            <xsl:if test="self::phdthesis">
                <xsl:text>PhD thesis, </xsl:text> 
            </xsl:if>
            <xsl:choose>
                <xsl:when test="self::article">
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
                    <xsl:text>Technical Report, </xsl:text>
                    <xsl:value-of select="string-join(
                                                ((
                                                 institution,
                                                 year
                                                 )),', ')"/>
                </xsl:when>
                <xsl:when test="self::book">
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
                                                    publisher,
                                                    year,
                                                    eprint)),', ')"/>
                </xsl:when>

                <xsl:otherwise>
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
            <div style="clear:left"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="bibliography/*/title">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="bibliography/*/journal">
        <i>
            <xsl:value-of select="."/>
        </i>
    </xsl:template>

    <xsl:template match="/chapter">

        <!-- <xsl:apply-templates select="key('bib', ., document('bib.xml'))"/>    -->
        <xsl:call-template name="chapterpage"/>
        <xsl:for-each select="section">
            <!-- was "//section" -->
            <xsl:call-template name="sectionpage"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="chapterpage" match="chapter">
        <xsl:call-template name="wrap_page_and_output">
            <xsl:with-param name="filepath" select="concat($chapterFolder,'/overview.html')"/>
            <xsl:with-param name="sidebarfilepath" select="concat('whole thing/temp/',$sidebarstem,'.html')" />
            <xsl:with-param name="page_content"> 
                <xsl:element name="div">
                    <xsl:attribute name="class" select="'page'"/>
                    <div class="pageheader" > 
                        <i>
                            <xsl:value-of select="title"/>
                        </i>
                    </div>
                    <h2>
                        <xsl:value-of select="subtitle"/>
                    </h2>

                    <xsl:apply-templates select="preface"/>
                    <p>
                        <xsl:value-of select="leader"/>  
                        <xsl:for-each select="section">
                            <xsl:value-of select="leader"/>
                            <ul>
                                <li>
                                    <a href="{concat($rootpath,'/',../label,'/',label,'.html')}">
                                        <xsl:value-of select="title"/>
                                    </a>
                                </li>
                            </ul>
                        </xsl:for-each>
                        <xsl:for-each select="chapterref">
                            <xsl:call-template name="chapterref"/>
                        </xsl:for-each>
                    </p> 
                </xsl:element>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="a">
        <xsl:copy >
            <!-- this copies element name -->
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="chapterref" match="chapterref" mode="explicit">
        <xsl:element name="p">

            <a>
                <xsl:attribute name="href" select="concat($rootpath,'/',label,'/overview.html')"/>
                <xsl:value-of select="title"/>
            </a> 
            <xsl:text> &#8212;</xsl:text>
            <em>
                <xsl:value-of select="subtitle"/>
            </em>
            <xsl:apply-templates select="explanation"/>
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

    <xsl:template match="emdash">
        <xsl:text>&#8212;</xsl:text>
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
            <xsl:apply-templates select="*[not(self::label)]"/>
        </xsl:element>
        <div style="clear:left"/>
    </xsl:template>

    <xsl:template match="equation/number">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'eqno'"/>
           (<xsl:number count="equation/number" level="any"/>)
        </xsl:element>
        <div style="clear:left"/>
    </xsl:template>

    <xsl:template match="eqref">
        <xsl:variable name="label" select="."/>
        <xsl:variable name="referenced" select="//(equation)
                                                   [label=$label]" />  
        <xsl:for-each select="$referenced">
            <xsl:number select="."  count="equation" level="any"/>
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
            <xsl:sequence select="document(concat($svgFolder,filename,'.svg'))"/>
        </xsl:variable>
        <xsl:if test="$svg=''">
            <xsl:message> Filename <xsl:value-of select="concat($svgFolder,filename,'.svg')"/> not found </xsl:message>
        </xsl:if>
        <xsl:element name="div">
            <xsl:attribute name="style" select="'width:100%;padding:0.5cm'"/>
            <xsl:element name="div">
                <xsl:attribute name="style" select="concat('display:block;margin:0 auto; width:',$svg/(*:svg)/@width)"/>
                <xsl:element name="img">
                    <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,filename,'.svg')"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>

    </xsl:template>


    <xsl:template match="er_inline">
        <xsl:variable name="svg">
            <xsl:sequence select="document(concat($svgFolder,filename,'.svg'))"/>
        </xsl:variable>
        <xsl:if test="$svg=''">
            <xsl:message> Filename <xsl:value-of select="concat($svgFolder,filename,'.svg')"/> not found </xsl:message>
        </xsl:if>
        <xsl:element name="img">
            <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,filename,'.svg')"/>
            <xsl:attribute name="class" select="'inline'"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="figure">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'displayfigure'"/>
            <xsl:apply-templates select="*[not(self::label)]"/>
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
                <xsl:number 
             count="figure/caption
	            |figureOfEquation/caption
	            |figureOfPicture/caption
	            |figureOfPictureWithNote/caption" 
             level="any"/>
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
            <xsl:sequence select="document(concat($svgFolder,pictureName,'.svg'))"/>
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
                    <xsl:element name="img" >
                        <xsl:attribute name="class" select="'er'"/>
                        <xsl:if test="imgwidth">
                            <xsl:attribute name="style" select="concat('width:',imgwidth)"/>
                        </xsl:if>
                        <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <div style="clear:left"/>
            <xsl:apply-templates select="caption"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="figureOfPictureWithNote">
        <xsl:variable name="svg">
            <xsl:sequence select="document(concat($svgFolder,pictureName,'.svg'))"/>
        </xsl:variable>
        <xsl:if test="$svg=''">
            <xsl:message> Filename <xsl:value-of select="concat($svgFolder,pictureName,'.svg')"/> not found </xsl:message>
        </xsl:if>
        <xsl:variable name="imgwidth" select="if (imgwidth) then imgwidth else $svg/(*:svg)/@width" />
        <xsl:variable name="imgheight" select="if (imgheight) then imgheight else $svg/(*:svg)/@height" />


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
                    <xsl:attribute name="style" select="concat('margin:auto;
                                                         width:',$imgwidth
                                                       )"/>
                    <xsl:element name="a">
                        <xsl:attribute name="href" select="href"/>
                        <xsl:attribute name="target" select="'_blank'"/>
                        <xsl:element name="img" >
                            <xsl:attribute name="class" select="'er'"/>
                            <xsl:if test="imgwidth">
                                <xsl:attribute name="style" select="concat('width:',imgwidth)"/>
                            </xsl:if>
                            <xsl:attribute name="src" select="concat($runtimepathtosvgfiles,pictureName,'.svg')"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="div">
                <xsl:attribute name="class" select="'middlingContainer'"/>
                <xsl:attribute name="style" select="concat('height:',$imgheight
                                                   )"/>
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
            </xsl:element>
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
        <xsl:variable name="label" select="."/>
        <xsl:variable name="referenced" select="//(figure|figureOfPicture|figureOfPictureWithNote|figureOfEquation)
                                                   [pictureName=$label or equationName=$label or label=$label]" />
        <!-- or label=$label??? -->
        <xsl:for-each select="$referenced">
            <xsl:number select="."  count="figure|figureOfPicture|figureOfPictureWithNote|figureOfEquation/caption" level="any"/>
        </xsl:for-each>
        <xsl:if test="not($referenced)">
            <xsl:message>WARNING:  No such figure as referenced: '<xsl:value-of select="."/>'</xsl:message>
        </xsl:if>
    </xsl:template>




    <xsl:template match="footnote">
        <sup>
            <xsl:number count="footnote" from="section" level="any"/>
        </sup>
    </xsl:template>


    <xsl:template name="footnotes" match="section" mode="explicit">
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

    <xsl:template match="alpha">
        <xsl:text>&#945;</xsl:text>
    </xsl:template>
    <xsl:template match="beta">
        <xsl:text>&#946;</xsl:text>
    </xsl:template>
    <xsl:template match="pi">
        <xsl:text>&#960;</xsl:text>
    </xsl:template>

    <xsl:template match="scopesubject">
        <xsl:text>&#x021B7;</xsl:text>
    </xsl:template>
    <xsl:template match="scopeup">
        <!-- up arrow <xsl:text>&#x2B61;</xsl:text> -->
        <xsl:text>&#x2025;</xsl:text>
    </xsl:template>
    <xsl:template match="scopeequiv">
        <xsl:text>&#x2272;</xsl:text>
    </xsl:template>



    <xsl:template match="degreecelsius">
        <xsl:text>&#8451;</xsl:text>
    </xsl:template>

    <xsl:template match="squarecontainedin">
        <xsl:text>&#8849;</xsl:text>
    </xsl:template>

    <xsl:template match="containedin">
        <xsl:text>&#8838;</xsl:text>
    </xsl:template>

    <xsl:template match="relationship">
        <xsl:text>&#8954;&#9473;</xsl:text>
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
        '<xsl:value-of select="."/>'
    </xsl:template>

    <xsl:template match="qq">
        "<xsl:value-of select="."/>"
    </xsl:template>

    <xsl:template match="quotation">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'quotation'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="refchapter" >
        <a>
            <xsl:attribute name="href" select="concat($rootpath,'/',label,'/overview.html')"/>
            <xsl:value-of select="title"/>
        </a>
    </xsl:template>

    <xsl:template match="refsection" >
        <a>
            <xsl:attribute name="href" select="concat($rootpath,'/',label/chapter,'/',label/section,'.html')"/>
            <xsl:value-of select="title"/>
        </a>
    </xsl:template>

    <xsl:template match="section">
        <div style="clear:left"/> 
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="sectionpage" match="section">
        <xsl:call-template name="wrap_page_and_output">
            <xsl:with-param name="filepath" select="concat($chapterFolder,'/',label,'.html')"/>
            <xsl:with-param name="sidebarfilepath" select="'whole thing/temp/sidebar.html'" />
            <xsl:with-param name="page_content">
                <xsl:element name="div">
                    <xsl:attribute name="class" select="'page'"/>

                    <div class="pageheader" > 
                        <i>
                            <xsl:value-of select="../subtitle"/>
                        </i>
                    </div>
                    <xsl:apply-templates select="*[not(self::label|self::leader)]"/> 
                    <div style="clear:left"/>
                    <hr/>
                    <xsl:call-template name="footnotes"/>
                    <div style="clear:left"/>
                    <div class="bottomnavigation">
                        <div style="float:left">
                            <xsl:if test="preceding-sibling::section[1]">
                                <a href="{concat($rootpath,'/',$chapterFolder,'/',preceding-sibling::section[1]/label,'.html')}">
                   PREVIOUS <xsl:value-of select="   preceding-sibling::section[1]/title"/>
                                </a>
                            </xsl:if>
                        </div>
                        <div style="float:right">
                            <xsl:choose>
                                <xsl:when test="following-sibling::section">
                                    <a href="{concat($rootpath,'/',$chapterFolder,'/',following-sibling::section[1]/label,'.html')}">
                         NEXT <xsl:value-of select="   following-sibling::section[1]/title"/>
                                    </a>
                                </xsl:when>
                                <xsl:when test="/chapter/nextchapter">
                                    <a href="{concat($rootpath,'/',/chapter/nextchapter/label,'/overview.html')}">
                         NEXT Chapter <xsl:value-of select="/chapter/nextchapter/title"/>
                                    </a>
                                </xsl:when>
                            </xsl:choose>
                        </div>
                    </div>
                </xsl:element>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="sectionsign">
        <xsl:text>&#167;</xsl:text>
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

    <xsl:template match="table">
        <xsl:element name="table">
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:if test="class">
                <xsl:attribute name="class" select="class"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::class|self::columnstyles)]"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="tabledisplay">
        <xsl:element name="div">
            <xsl:attribute name="class" select="'displaytable'"/>
            <xsl:if test="width">
                <xsl:attribute name="style" select="concat('width:',width)"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::label|self::width)]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tabledisplay/caption">
        <!-- <div style="clear:left"></div> -->
        <xsl:element name="div">
            <xsl:attribute name="class" select="'caption'"/>
            <xsl:element name="div">
                <xsl:attribute name="class" select="'captionHeading'"/>
           Table <xsl:text>   </xsl:text>
                <xsl:number count="tabledisplay/caption" level="any"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
        <div style="clear:left"/>
    </xsl:template>

    <xsl:template match="tableref">
        <xsl:variable name="label" select="."/>
        <xsl:variable name="referenced" select="//tabledisplay
                                                   [label=$label]" />
        <xsl:for-each select="$referenced">
            <xsl:number select="."  count="tabledisplay" level="any"/>
        </xsl:for-each>
        <xsl:if test="not($referenced)">
            <xsl:message>WARNING:  No such table as referenced: '<xsl:value-of select="."/>'</xsl:message>
        </xsl:if>
    </xsl:template>


    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="th">
        <xsl:copy >
            <!-- this copies element name -->
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- PREVIOUSLY 
<xsl:template match="th">
   <xsl:element name="th">   
      <xsl:if test="n">
         <xsl:attribute name="colspan" select="n"/>
      </xsl:if>
      <xsl:value-of select="text"/>
   </xsl:element>
</xsl:template>
-->

    <xsl:template match="thead">
        <xsl:element name="thead">
            <xsl:if test="class">
                <xsl:attribute name="class" select="class"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::class)]" />
        </xsl:element>
    </xsl:template>

    <!-- want to add rowspan and colspan (see n above) to <td> but having <text> everywhere
   very hard work  therefore pass all attributes through using xslt:copy-of!!-->
    <xsl:template match="td">
        <xsl:variable name="colno" select="position()"/>
        <xsl:copy >
            <!-- this copies element name -->
            <xsl:variable name="class" select="ancestor::table/columnstyles/col[$colno]/class"/>
            <xsl:if test="not($class='')">
                <xsl:attribute name="class" select="$class"/>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <!-- this copies all its attributes -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="title">
        <!--generic title ...deliberately empty-->
    </xsl:template>

    <xsl:template match="tr">
        <xsl:element name="tr">
            <xsl:apply-templates select="*[not(self::class)]"/>
        </xsl:element>
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

    <!--
<xsl:template match="*" mode="verbatim">
   <xsl:value-of select = "name()"/>
   <xsl:apply-templates mode="verbatim"/>
   <xsl:value-of select = "name()"/>
</xsl:template>
-->




</xsl:transform>
