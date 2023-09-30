<xsl:transform version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"           
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:include href="symbols2.tex.xslt"/>
  <xsl:include href="tables2.tex.xslt"/>
  <xsl:include href="messages2.tex.xslt"/>

  <xsl:param name="docrootfolder"/>  

  <xsl:variable name="pathtoroot" select="'..'"/>

  <xsl:variable name="runtimepathtoimages" select="concat($pathtoroot,'/images/')"/>

  <xsl:variable name="parentpath" select="'..'"/> <!--   6 Aug 2023
                                                              also changed all uses of document() to have second argument . 
                                                             this has effect of interpreting relative paths as relative to source document -->
  <xsl:variable name="svgFolder" select="'../www.entitymodelling.org/svg/'"/>
                                  <!-- svg images used just to get the dimensions of corresponding images --> 
  <xsl:variable name="eqnFolder" select="'../tex_source/'"/>


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

  <xsl:template name="newline">
    <xsl:text>&#xD;&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="/document"> 
    <xsl:text>
\documentclass[10pt,a4paper]{article}
%\usepackage {scrpage}

\newcommand{\Theory}[0]{../../../GitHub/Theory}
\newcommand{\SharedMacros}[0]{\Theory/SharedMacros}
\input{\SharedMacros/ermacros}
\input{\SharedMacros/erdiagram}
\input{\SharedMacros/syntaxmacros}
\renewcommand{\erpictureFolder}[0]{images}
\usepackage[font=small,labelfont=bf]{caption}
\setlength{\captionmargin}{2cm}

\title{EntityModelling}
\author{John Cartmell}


\begin{document}
\maketitle
    </xsl:text>
    <xsl:for-each select="chapter">
      <xsl:value-of select="'\input{' || label || '}'"/>
      <xsl:call-template name="newline"/>
    </xsl:for-each> 
    <xsl:text>
  \bibliography{\Theory/SharedBibliography/temp/bibliography}
\end{document}
    </xsl:text>
    <xsl:apply-templates select="chapter"/>
  </xsl:template>      

  <xsl:variable name="rootprefix" select="if ($pathtoroot='') then '' else concat($pathtoroot,'/')"/>

  <xsl:template name="wrap_page_and_output" >
    <xsl:param name="filepath"/>
    <xsl:param name="page_content"/>
<xsl:message>Filepath <xsl:value-of select="$filepath"/></xsl:message>
    <xsl:result-document href="{$filepath}" method="text">
      <xsl:copy-of select="$page_content"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="bibref">
      <xsl:value-of select="'\cite{' || entry/text() || '}'"/>
  </xsl:template>

  <xsl:template name="chapterpage" match="chapter">
    <xsl:message>Chapter <xsl:value-of select="title"/> label <xsl:value-of select="label"/> title <xsl:value-of select="title"/>
    </xsl:message>
    <xsl:call-template name="wrap_page_and_output">
      <xsl:with-param name="filepath" 
          select="concat($docrootfolder,'/',label,'.tex')"/>
      <xsl:with-param name="page_content"> 
          <xsl:value-of select="'\section{' || title || '}'"/>
          <xsl:call-template name="newline"/>
          <xsl:apply-templates select="*[not(self::title)]"/>
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
    <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="entity">
    <xsl:text>\underline{</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
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
    <xsl:value-of select="'\ercenterPicture{' || filename || '}'"/>
  </xsl:template>

  <xsl:template match="er_inline">
    <xsl:value-of select="'\erinlinePicture{' || filename || '}'"/>
  </xsl:template>

  <xsl:template match="explanation">
      <!-- deliberately left blank -->
  </xsl:template>

  <xsl:template match="figure">
    <xsl:message>figure label <xsl:value-of select="label"/></xsl:message>
    <!-- <xsl:if test="width">
      <xsl:message>**********No account taken of figure width '<xsl:value-of select="width"/>'. </xsl:message>
    </xsl:if> -->
    figure TBD
    
    <xsl:apply-templates select="*[not(self::label or self::width or self::caption)]"/>
  </xsl:template>

  <xsl:template match="figure/caption
      |figureOfEquation/caption
      |figureOfPicture/caption
      |figureOfPictureWithNote/caption">
<!--     <xsl:element name="div">
      <xsl:attribute name="class" select="'caption'"/>
      <xsl:element name="div">
        <xsl:attribute name="class" select="'captionHeading'"/>
        Figure <xsl:text>   </xsl:text> 
        <xsl:value-of select="../number"/>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element> -->
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
<!--     <xsl:variable name="svg">
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
    </xsl:element> -->
    <xsl:if test="width">
      <xsl:message>**********No account taken of figure width '<xsl:value-of select="width"/>'. </xsl:message>
    </xsl:if> 
    <xsl:value-of select="'\erplainFig{' || pictureName || '}{h}{' || caption || '}'"/>
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
    <xsl:variable name="notewidthcms">
      <xsl:value-of select="if (note/width) then substring-before(note/width,'cm') else '6'"/>
    </xsl:variable>
    <!--
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

          <xsl:variable name="content" as="element()">
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
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="href">
              <xsl:element name="a">
                <xsl:attribute name="href" select="href"/>
                <xsl:attribute name="target" select="'_blank'"/>
                <xsl:copy-of select="$content"/>
              </xsl:element>  
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>  
      </xsl:element>  
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
    </xsl:element> -->

    <xsl:if test="width">
      <xsl:message>**********No account taken of figure width '<xsl:value-of select="width"/>'. </xsl:message>
    </xsl:if> 

    <xsl:value-of select="'\begin{ernotedDimFig}{' ||
                          pictureName    || '}{'  ||
                          'H'            || '}{'  ||
                          caption        || '}{'  ||   
                          $imgheightcms  || '}{'  ||
                          $notewidthcms  || '}'
                          "/>
    <xsl:apply-templates select="note/*[not(self::width)]"/>
    <xsl:value-of select="'\end{ernotedDimFig}'"/>
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
    <xsl:text>\footnote{</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
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
    <xsl:text>\item{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="itemize">
    <xsl:text>\begin{itemize}</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:apply-templates/>
    <xsl:call-template name="newline"/>
    <xsl:text>\end{itemize}</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <xsl:template match="label">
    <xsl:value-of select="'\label{' || text() || '}'"/>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <xsl:template match="latex">
    <xsl:message terminate="yes"> NOT Implemented</xsl:message>
  </xsl:template>

  <xsl:template match="leader">
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
    <xsl:call-template name="newline"/>
    <xsl:text>\noindent </xsl:text><xsl:apply-templates/><xsl:text>\\</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <xsl:template match="picture">
    <xsl:value-of select= "'\input{\erpictureFolder/' || filename || '}'"/>
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
    <xsl:text>\begin{erquote}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{erquote}</xsl:text>
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


<!--   <xsl:template name="sectionpage" match="section">
    <xsl:variable name="chapterFolderName" select="..[self::chapter]/label" />
    <xsl:call-template name="wrap_page_and_output">
      <xsl:with-param name="filepath" select="concat($docrootfolder,'/',$chapterFolderName,'/',label,'.tex')"/>
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
  </xsl:template> -->

  <xsl:template match="section">
    <xsl:value-of select="'\subsection{' || title || '}'"/>   
    <xsl:call-template name="newline"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="shorttitle">
     <!-- intentionally left blank -->
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
    <xsl:value-of select="'\subsubsection{' || title || '}'"/>
    <xsl:call-template name="newline"/>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="sup">
    <!-- <xsl:element name="sup"> -->
      <xsl:text>^{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    <!-- </xsl:element> -->
  </xsl:template>



  <xsl:template match="tabledisplay">
        <xsl:text>\begin{table}[h]</xsl:text>
        <xsl:apply-templates select="table"/>
        <xsl:apply-templates select="caption"/>
        <xsl:value-of select="'\label{' || label || '}'"/>
        <xsl:text>\end{table}</xsl:text>
  </xsl:template>

  <xsl:template match="tabledisplay/caption">
    <xsl:text>\caption{</xsl:text>
      <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
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

      <xsl:template match="trailer">
    <!-- ...deliberately empty-->
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
