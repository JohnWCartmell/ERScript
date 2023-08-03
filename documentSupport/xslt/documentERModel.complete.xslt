<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0">
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="preface bibentry columns col equation eqref textarea text"/>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- GROUP ONE - Making anonymous text explicit -->


  <xsl:template match="a/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="b/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  
    <xsl:template match="block/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="i/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="para/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="item/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="span/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="emph/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  
   <xsl:template match="equation/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="entity/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="footnote/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>


  <xsl:template match="quotation/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="th/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="td/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="courier/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="qq/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="q/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="sub/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="sup/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="small/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  
  <xsl:template match="textarea/text()">
    <text><xsl:value-of select="."/></text>
  </xsl:template>
  
   <xsl:template match="u/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  
  <xsl:template match="var/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="leader/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="trailer/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="chapter/title/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  <xsl:template match="section/title/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  <xsl:template match="subsection/title/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>
  <xsl:template match="chapter/subtitle/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>


  <xsl:template match="caption/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="chapter/preface/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <xsl:template match="code/text()">
    <text>
      <xsl:value-of select="."/>
    </text>
  </xsl:template>

  <!--GROUP TWO Converting to references as modelled in document model --> 

  <xsl:template match="tableref/text()">
    <table>
      <xsl:value-of select="."/>
    </table>
  </xsl:template>

  <xsl:template match="figref/text()">
    <figure>
      <xsl:value-of select="."/>
    </figure>
  </xsl:template>

  <xsl:template match="refchapter">
    <refchapter>
      <chapter>
        <xsl:value-of select="label"/>
      </chapter>
    </refchapter>
  </xsl:template>

  <xsl:template match="refsection">
    <refsection>
      <section>
        <xsl:value-of select="label/section"/>
      </section>
    </refsection>
  </xsl:template>

  <xsl:template match="eqref/label">    
    <equation>
      <xsl:value-of select="."/>
    </equation>
  </xsl:template>

  <xsl:template match="eqref/text()">    
    <equation>
      <xsl:value-of select="."/>
    </equation>
  </xsl:template>

  <!--GROUP THREE Converting tables to document model --> 

  <xsl:template match="table[tr][not(tbody)]">
    <xsl:copy>
      <xsl:apply-templates select="*[not(self::tr)]"/>
      <tbody>
        <xsl:apply-templates select="tr"/>
      </tbody>
    </xsl:copy>
  </xsl:template>

  <!-- GROUP FOUR     
    Change table.columnstyles to columns 
    change table.format to columns
    change table.format text to <alignment>

  -->

  <xsl:template match="table/format">
    <columns>
      <xsl:apply-templates/>
    </columns>
  </xsl:template>

  <xsl:template match="table/columnstyles">
    <columns>
      <xsl:apply-templates/>
    </columns>
  </xsl:template>

  <xsl:template match="col/text()">
    <align>
      <xsl:value-of select="."/>
    </align>
  </xsl:template>

  <!-- GROUP FIVE
        change bibentry to bibref
        change bibentry.label to bibref.entry
        change b.bentry text() to bibref.entry
      -->

  <xsl:template match="bibentry">
    <bibref>
      <xsl:apply-templates/>
    </bibref>
  </xsl:template>

  <xsl:template match="bibentry/label">
    <entry>
      <xsl:apply-templates/>
    </entry>
  </xsl:template>

  <xsl:template match="bibentry/text()">
    <entry>
      <xsl:value-of select="."/>
    </entry>
  </xsl:template>

  <!-- GROUP SIX Numbering equations, figures, tabledisplays -->
  <xsl:template match="figure
	                     |figureOfEquation
	                     |figureOfPicture
	                     |figureOfPictureWithNote">
    <xsl:copy>
      <xsl:apply-templates/>
      <number>
        <xsl:number 
             count="figure
	            |figureOfEquation
	            |figureOfPicture
	            |figureOfPictureWithNote" 
             level="any"
             from="document/chapter"/>
        <!-- chapter is ambiguous  - picks up refchapter/chapter -->
        <!-- WARNING - BUG if figure in document/preface/chapter ??? -->
      </number>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tabledisplay">
    <xsl:copy>
      <xsl:apply-templates/>
      <number>
        <xsl:number count="tabledisplay" level="any" from="chapter"/>
      </number>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="equation/number">
    <xsl:copy>
        <xsl:number count="equation/number" level="any"/>      
    </xsl:copy>     
  </xsl:template>


  <!-- The wildcard -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>
