<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<?xml-stylesheet type="text/xsl" href="ERModel2HTML.xslt"?>




<xsl:template match="/chapter">
<!-- <xsl:apply-templates select="key('bib', ., document('bib.xml'))"/>    -->
  <xsl:call-template name="chapterpage"/>
  <xsl:for-each select="section">  <!-- was "//section" -->
     <xsl:call-template name="sectionpage"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="chapterpage" match="chapter">
   <xsl:result-document href="{concat($chapterFolder,'/overview.html')}">
      <html>
       <head>
	   	 <link href='https://fonts.googleapis.com/css?family=Montserrat:400' rel='stylesheet' type='text/css'/>
         <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/erstyle.css')}" />
         <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/cssmenustyles.css')}" />
         <script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
         <script src="{concat($rootpath,'/script.js')}"></script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-30358501-3', 'auto');
  ga('send', 'pageview');

</script>
         <style>
              ul#<xsl:value-of select="label"/> {display: block !important ;}
         </style>
       </head>
  <body>

  <div class="outer">
     <div class="header">
     EntityLogic.org 
     <br/>
     <p>www.entitylogic.org - entity modelling introduced from first principles - relational database design theory and practice - dependent type theory</p>
     </div>
     <div style="clear:left"></div>
     <hr/>    
     <div style="clear:left"></div>
     <div class="body">
	<xsl:variable name="sidebar" 
		     select="document(concat('whole thing/temp/',$sidebarstem,'.html'))"/>
        <xsl:copy-of select="$sidebar"/>
	 
         <xsl:element name="div">
            <xsl:attribute name="class" select="'page'"/>
			<div class="pageheader" > 
					 <i><xsl:value-of select="title"/></i>
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
     </div>
     <div style="clear:left"></div>
     <hr/>
     <div style="clear:left"></div>
     <div class="footer">
         Copyright John Cartmell 2013-2017
     </div>
  </div>
  </body>
  </html>
  </xsl:result-document>
</xsl:template>

<xsl:template match="section">
  <div style="clear:left"></div> 
  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="sectionpage" match="section">
   <xsl:result-document href="{concat($chapterFolder,'/',label,'.html')}">
      <html>
  <head>
  	  	 <link href='https://fonts.googleapis.com/css?family=Montserrat:400' rel='stylesheet' type='text/css'/>
         <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/erstyle.css')}" />
         <link rel="stylesheet" type="text/css" href="{concat($rootpath,'/cssmenustyles.css')}" />
         <script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>
         <script src="{concat($rootpath,'/script.js')}"></script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-30358501-3', 'auto');
  ga('send', 'pageview');

</script>

         <style>
              ul#<xsl:value-of select="../label"/> {display: block !important ;}
         </style>
  </head>
  <body>

  <div class="outer">
     <xsl:call-template name="header"/>
     <div class="header"> 
	 EntityLogic.org 
     <br/>
     <p>www.entitylogic.org - entity modelling introduced from first principles - relational database design theory and practice  - dependent type theory</p>
     </div>
     <div style="clear:left"></div>
     <hr/>    
     <div style="clear:left"></div>
     <div class="body">
	<xsl:variable name="sidebar" 
		     select="document('whole thing/temp/sidebar.html')"/>
        <xsl:copy-of select="$sidebar"/>
         <xsl:element name="div">
            <xsl:attribute name="class" select="'page'"/>
	
			<div class="pageheader" > 
					 <i><xsl:value-of select="../subtitle"/></i>
		    </div>
            <xsl:apply-templates select="*[not(self::label|self::leader)]"/> 
            <div style="clear:left"></div>
            <hr/>
            <xsl:call-template name="footnotes"/>
            <div style="clear:left"></div>
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
        
     </div>
     <div style="clear:left"></div>
     <hr/>
     <div style="clear:left"></div>
 
           
     <div class="footer">
         Copyright John Cartmell 2013-2015
     </div>
  </div>
  </body>
  </html>
  </xsl:result-document>
</xsl:template>


</xsl:transform>
