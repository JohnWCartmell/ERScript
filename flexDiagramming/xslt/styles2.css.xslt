<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xpath-default-namespace="http://www.entitymodelling.org/diagram">
  <xsl:output method="text" indent="no"/>
  <xsl:template name="newline">
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>
  <xsl:template name="newlineindent2">
    <xsl:text>&#xA;  </xsl:text>
  </xsl:template>
  <xsl:template name="newlineindent4">
    <xsl:text>&#xA;    </xsl:text>
  </xsl:template>
  <xsl:template name="newlineindent6">
    <xsl:text>&#xA;      </xsl:text>
  </xsl:template>
  <xsl:template name="indent4">
    <xsl:text>    </xsl:text>
  </xsl:template>
  <xsl:template name="indent2">
    <xsl:text>  </xsl:text>
  </xsl:template>
  
  <xsl:template match="all" priority="9">
    <xsl:message>Kicking off css upgrade</xsl:message>
    <xsl:apply-templates select="*"/>

  <!-- now spit out routehitarea styles -->
  <xsl:text>
  .routehitarea {
    fill:none;
    stroke-width: .2;
    pointer-events: stroke;
    stroke-opacity:0;  
  }

  .routehitarea:hover {
    stroke: yellow ; 
    stroke-opacity:0.5;
  }
  </xsl:text>
  </xsl:template>

  <xsl:template match="id|label_long_offset|label_lateral_offset|lateral_extent|long_extent|minarmlen" priority="9">
    <!-- deliberately left empty -->
  </xsl:template>
  
  <xsl:template match="shape_style|text_style|endline_style" priority="8">
    <xsl:text>.</xsl:text>
    <xsl:value-of select="id"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:apply-templates select="*"/>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>
  
  <xsl:template match="*[not(self::id)][not(self::label_long_offset
                                            |self::label_lateral_offset
                                            |self::lateral_extent
                                            |self::long_extent
                                            |self::minarmlen)]">
    <xsl:call-template name="indent4"/>
    <xsl:value-of select="name()"/>
    <xsl:text> : </xsl:text>
    <xsl:value-of select="."/>
    <xsl:apply-templates select="*" mode="deeper"/> 
    <xsl:text> ;</xsl:text>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <xsl:template match="normal|italic|bold|underline" mode="deeper"> <!-- I dont really know why I have had to use a mode here to get it executing -->
    <xsl:value-of select="name()"/>
  </xsl:template>
  



</xsl:transform>


<!-- end of file: ERmodel_v1.2/src/ERmodel2.proto.xslt--> 

