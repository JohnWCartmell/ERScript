
<!-- 
*****************
ERmodel2.svg.xslt
*****************

DESCRIPTION
  Transform an instance of ERmodelERmodel to a digram in svg format.
  Uses module ERmodel2.diagram.module.xslt.

CHANGE HISTORY

23-Sep-2022 J.Cartmell Add a class for relid - same font as relname.
01-Dec-2022            Changes to support pop up descriptions in html divs ...
                       this is essentially a blend of previous approaches to this.
-->
<xsl:transform version="2.0" 
        xmlns="http://www.w3.org/2000/svg"
        xmlns:svg="http://www.w3.org/2000/svg"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink" 
        xmlns:diagram="http://www.entitymodelling.org/diagram" 
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
        exclude-result-prefixes="fn math xs xsl xlink diagram era">

  <xsl:include href="ERmodel2.diagram.module.xslt"/>
  <xsl:include href="../flexDiagramming/xslt/diagram.functions.module.xslt"/>

  <xsl:output method="xml" indent="yes" />

  <xsl:variable name="fileextension">
    <xsl:value-of select="'svg'"/>
  </xsl:variable>
  <!--
<xsl:key name="EntityTypeByLevel" match="entity_type" use="count(ancestor-or-self::entity_type)"/>
-->

  <!-- introduce default rule so that html tags embedded within descriptive text will be passed through -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- ************************ -->
  <!-- svg Specifics start here -->
  <!-- ************************ -->

  <xsl:template name="wrap_diagram" match="entity_model">
    <xsl:param name="acting_filestem"/>
    <xsl:param name="content"/>
    <xsl:param name="diagramHeight"/>
    <xsl:param name="diagramWidth"/>
    <!-- <xsl:result-document href="{concat($acting_filestem,'.svg')}"> -->
    <xsl:element name="svg">
      <xsl:attribute name="width">
        <xsl:value-of select="$diagramWidth + 0.1"/>cm</xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$diagramHeight + 0.1"/>cm</xsl:attribute>
          <xsl:choose>
              <xsl:when test="$bundleOn">
                <style>
                    <xsl:value-of select="unparsed-text('../css/erdiagramsvgstyles.css')" 
                              disable-output-escaping="yes"/>
                    <xsl:value-of select="unparsed-text('../css/erdiagramsvg_hoverstyles.css')" 
                              disable-output-escaping="yes"/>
                </style>
              </xsl:when>
              <xsl:otherwise>
                <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet"
                       type="text/css"
                       href="/css/erdiagramsvgstyles.css"/>
                <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet"
                       type="text/css"
                       href="/css/erdiagramsvg_hoverstyles.css"/>
              </xsl:otherwise>
          </xsl:choose>

      <defs>
        <linearGradient id="topdowngrey" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:#E8E8E8;stop-opacity:1" />
          <stop offset="100%" style="stop-color:white;stop-opacity:1" />
        </linearGradient>
        <filter x="0" y="0" width="1" height="1" id="surfaceattreven">
          <feFlood flood-color="white"/>
          <feComposite in="SourceGraphic" />
        </filter>
        <filter x="0" y="0" width="1" height="1" id="surfaceattrodd">
          <feFlood flood-color="#FFFFCC"/>
          <feComposite in="SourceGraphic" />
        </filter>
        <filter x="-0.05" y="-0.05" width="1.1" height="1.1" id="border">
          <feFlood flood-color="gray"/>
          <feComposite in="SourceGraphic"/>
        </filter>
      </defs>
      <xsl:copy-of select="$content"/>
    </xsl:element>
    <!--
  </xsl:result-document>
-->
    <!-- CR-????  -->
    <xsl:result-document href="{concat($acting_filestem,'.html')}"> 
      <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html4></xsl:text>
      <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
          <xsl:choose>
              <xsl:when test="$bundleOn">
                <style>
                    <xsl:value-of select="unparsed-text('../css/ersvgdiagramwrapper.css')" 
                              disable-output-escaping="yes"/>
                </style>
              </xsl:when>
              <xsl:otherwise>
                <link rel="stylesheet" type="text/css" href="/css/ersvgdiagramwrapper.css"/>
              </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="$animateOn">
          <script>
            <xsl:choose>
               <xsl:when test="$bundleOn">
                  <xsl:value-of select="unparsed-text('../js/ersvgdiagraminteraction.js')" 
                              disable-output-escaping="yes"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="src" select="'/js/ersvgdiagraminteraction.js'"/>
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
              </xsl:otherwise>
          </xsl:choose>
          </script>
          <script>
            <xsl:choose>
               <xsl:when test="$bundleOn">
                  <xsl:value-of select="unparsed-text('../js/draggable.js')" 
                              disable-output-escaping="yes"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:attribute name="src" select="'/js/draggable.js'"/>
            This here text is here in order to prevent the enclosing script tag from self-closing. If the script tag is allowed to self close then it seems that it breaks the page (in Chrome at least).
              </xsl:otherwise>
          </xsl:choose>
          </script>
          <script>
               <xsl:call-template name="plant_javascript_scope_rel_id_arrays"/>
          </script>
          </xsl:if>
          <link xmlns="http://www.w3.org/1999/xhtml"
            rel="stylesheet"
            type="text/css"
            href="/css/erdiagramsvgstyles.css"/>

            <xsl:call-template name="svg_defs"/>
        </head>
        <body>
          <div> 
            <xsl:attribute name="class" select="'bigouter'"/>
            <div>
              <xsl:attribute name="class" select="'entityModelHeader'"/>
              <xsl:text>Entity Model:</xsl:text>
              <xsl:value-of select="absolute/name"/>
            </div>
            <!--<xsl:call-template name="clearleft"/>-->
            <div>
                <xsl:attribute name="class" select="'entityModelDescription'"/>
                <xsl:for-each select="absolute/description">
                  <xsl:apply-templates/>
                </xsl:for-each>
            </div>
            <!--<xsl:call-template name="clearleft"/>-->
            <hr>
              <xsl:attribute name="class" select="'rule'"/>
            </hr>
            <!--<xsl:call-template name="clearleft"/>-->
            <div> 
              <xsl:attribute name="class" select="'bigbody'"/>
              <div> 
                <xsl:attribute name="class" select="'svganddivcontainer'"/>
                <div> 
                   <xsl:attribute name="id" select="'svgcontainer'"/>
                  <object>
                    <xsl:message>acting filestem is <xsl:value-of select="$acting_filestem"/>
                    </xsl:message>
                    <xsl:attribute name="id" select="'svg-object'"/>
                    <xsl:attribute name="data" select="concat($acting_filestem,'.svg')"/>
                    <xsl:attribute name="type" select="'image/svg+xml'"/>
                    <xsl:text>filler to stop contraction of this xml element</xsl:text>
                  </object>
                  <!--<object id ="svg-object" data="cricketMatch.svg" type="image/svg+xml"></object>-->
                </div>
                <xsl:call-template name="render_descriptive_text"/>                
              </div>
            </div>
          </div>
        </body>
      </html>
    </xsl:result-document>
    <!--          -->
  </xsl:template>

  <!-- assume groups are not nested within entity types -->
  <xsl:template name="render_descriptive_text" 
                 match="entity_model">
 <!--    <xsl:if test="not(self::entity_model)">
      <xsl:message terminate="yes">OUT OF SPEC</xsl:message>
    </xsl:if> -->
    <!-- <xsl:call-template name="infobox"/> -->
    <xsl:for-each select="entity_type">
        <xsl:call-template name="infoboxGenerate"/>
    </xsl:for-each>
    <xsl:for-each select="group">
        <xsl:call-template name="render_descriptive_text"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="clearleft">
    <div>
      <xsl:attribute name="style" select="'clear:left'"/>
      <xsl:text> </xsl:text>
    </div>
  </xsl:template>

  <xsl:template name="plant_javascript_scope_rel_id_arrays"
                match="entity_model"
                mode="explicit">
    <xsl:text>
        const diagonal_elements = {</xsl:text>
    <xsl:for-each select="descendant::reference">
        <xsl:text>
        "</xsl:text>
        <xsl:value-of select="id"/>
        <xsl:text>":[</xsl:text>
        <xsl:value-of select="diagonal/*/rel_id_csl"/>
        <xsl:text>],</xsl:text>
    </xsl:for-each>
    <xsl:text>} ;</xsl:text>
    <xsl:text>
        const diagonal_element_directions = {</xsl:text>
    <xsl:for-each select="descendant::reference">
        <xsl:text>
        "</xsl:text>
        <xsl:value-of select="id"/>
        <xsl:text>":[</xsl:text>
        <xsl:value-of select="diagonal/*/rel_inv_csl"/>
        <xsl:text>],</xsl:text>
    </xsl:for-each>
    <xsl:text>} ;</xsl:text>
        <xsl:text>
        const riser_elements = {</xsl:text>
    <xsl:for-each select="descendant::reference">
        <xsl:text>
        "</xsl:text>
        <xsl:value-of select="id"/>
        <xsl:text>":[</xsl:text>
        <xsl:value-of select="riser/*/rel_id_csl"/>
        <xsl:text>],</xsl:text>
    </xsl:for-each>
    <xsl:text>} ;</xsl:text>
    <xsl:text>
        const riser_element_directions = {</xsl:text>
    <xsl:for-each select="descendant::reference">
        <xsl:text>
        "</xsl:text>
        <xsl:value-of select="id"/>
        <xsl:text>":[</xsl:text>
        <xsl:value-of select="riser/*/rel_inv_csl"/>
        <xsl:text>],</xsl:text>
    </xsl:for-each>
    <xsl:text>} ;
    </xsl:text>
  </xsl:template>

  <xsl:template name="infoboxGenerate" 
                match="entity_model|entity_type|reference|composition|arribute" 
                mode="explicit">
    <xsl:call-template name="infobox" />
    <xsl:for-each select="entity_type">
      <xsl:call-template name="infoboxGenerate"/>
    </xsl:for-each>
    <xsl:for-each select="reference|composition|attribute">
      <xsl:call-template name="infoboxGenerate"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="infobox" match="entity_model|entity_type|reference|composition|attribute" 
                                   mode="explicit">
    <xsl:variable name="popUpxPos">
      <xsl:call-template name="popUpxPos"/>
    </xsl:variable>
    <xsl:variable name="popUpyPos">
          <xsl:call-template name="popUpyPos"/>
    </xsl:variable>
      <xsl:variable name="text_div_id" as="xs:string?">
        <xsl:value-of select="concat(id,'_text')"/>
      </xsl:variable>
      <div>
        <xsl:attribute name="id" select="$text_div_id"/>
        <xsl:attribute name="class" select="'infobox'"/>       
        <xsl:attribute name="style" select="concat('left:',$popUpxPos,'cm;top:',$popUpyPos,'cm')"/>
        <div>
            <xsl:attribute name="class" select="'infoboxHeader'"/>
          <div>
            <xsl:attribute name="class" select="'metatype'"/>
            <xsl:choose>
              <xsl:when test="self::entity_type">
                <b><xsl:text>Entity Type: </xsl:text></b>
                <xsl:value-of select="name"/>
              </xsl:when>
              <xsl:when test="self::reference">
                <b><xsl:text>Reference Relationship: </xsl:text></b>
                <xsl:value-of select="display_text"/>
              </xsl:when>
              <xsl:when test="self::composition">
                <b><xsl:text>Composition Relationship: </xsl:text></b>
                <xsl:value-of select="display_text"/>
              </xsl:when>
              <xsl:when test="self::attribute">
                <b><xsl:text>Attribute: </xsl:text></b>
                <xsl:value-of select="display_text"/>
              </xsl:when>
            </xsl:choose>
          </div> 
          <div>
            <xsl:attribute name="class" select="'closecontainer'"/>
            <button>
              <xsl:attribute name="class" select="'close'"/>
              <xsl:attribute name="onClick" >
                <xsl:text>closePopUp('</xsl:text>
                <xsl:value-of select="id"/>       
                <xsl:text>');</xsl:text>
              </xsl:attribute>
              <xsl:text>x</xsl:text>
            </button> 
          </div>
          <!--<xsl:call-template name="clearleft"/>-->
        </div> <!-- end of infoboxHeader -->
        <div>
          <xsl:attribute name="class" select="'infoboxBody'"/>
          <xsl:if test="id">
            Id : <xsl:value-of select="id"/>
            <br/>
          </xsl:if>
          <xsl:if test="scope_display_text">
            Scope : <xsl:value-of select="scope_display_text"/>
            <br/>
          </xsl:if>

          <xsl:if test="self::reference">
            <table>
              <tr>
                <td>
                  <xsl:call-template name="generate_relationship_info_header_svg">
                    <xsl:with-param name="rel" select="."/>
                  </xsl:call-template>
                </td>
              </tr>
              <tr>
                <td>
                  <p>
                    <xsl:attribute name="class" select="'svg'"/>
                    <xsl:value-of select="'In the context of a' || era:indefinite(../name) || ' '"/>
                    <xsl:element name="i"><xsl:value-of select="../name"/></xsl:element>
                    <xsl:value-of select="if (cardinality/ZeroOrOne) then ' there may be' else ' there is'"/>
                    <xsl:value-of select="' a' || era:indefinite(type) || ' '"/>
                    <xsl:element name="i"><xsl:value-of select="type"/></xsl:element>
                    <xsl:text> said to be the </xsl:text>
                    <xsl:element name="i"><xsl:value-of select="name"/></xsl:element>
                    <xsl:text>.</xsl:text>
                  </p>
                </td>
              </tr>
            </table>
          </xsl:if>
          <xsl:if test="self::composition">
            <table>
              <tr>
                <td>
                  <xsl:call-template name="generate_relationship_info_header_svg">
                    <xsl:with-param name="rel" select="."/>
                  </xsl:call-template>
                </td>
                <td>
                  <p>                   
                    <xsl:attribute name="class" select="'svg'"/>
                    <xsl:value-of select="'A' || era:indefinite(../name) || ' '"/>
                    <xsl:element name="i"><xsl:value-of select="../name"/></xsl:element>
                    <xsl:call-template name="posesses_type"/>
                    <xsl:if test="name">
                      <xsl:text> said to be the </xsl:text>
                      <xsl:element name="i">
                        <xsl:value-of select="name"/>
                      </xsl:element> 
                      <xsl:value-of select="' ( ' || type || ')'"/>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                  </p>
                </td>
              </tr>
            </table>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="description">
                  <xsl:copy-of select="description"/>  <!-- was xsl:value-of -->
            </xsl:when>
            <xsl:otherwise>
                  <i><xsl:text>TBD</xsl:text></i>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="self::entity_type and child::entity_type">
              <p>
               <xsl:text>A generalisation of the following types:</xsl:text>
               <table>
               <xsl:for-each select="descendant::entity_type[not(child::entity_type)]">
                 <tr>
                  <td>
                   <button>
                       <xsl:attribute name="id" select="id"/>
                       <xsl:attribute name="class" select="'popout'"/>
                       <xsl:value-of select="name"/>
                    </button>
                  </td>
                  </tr> 
                </xsl:for-each>
              </table>
              </p>
          </xsl:if>
          <xsl:if test="   self::entity_type
                        and
                         (child::composition 
                          or child::reference
                          or (
                                  not(child::entity_type)
                              and (
                                   ancestor::entity_type/(child::composition | child::reference)
                                  )
                             )
                          )">
              <p>
               <xsl:text>See also</xsl:text>
                <table>
                 <xsl:for-each select="if (not(child::entity_type))
                                       then ancestor-or-self::entity_type/(child::composition | child::reference)
                                       else child::composition | child::reference
                                       ">
                    <tr>
                      <td>
                       <button>
                          <xsl:attribute name="class" select="'popout'"/>
                          <xsl:choose>
                            <xsl:when test="name">
                              <xsl:attribute name="id" select="id"/>
                              <xsl:value-of select="name"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:attribute name="id" select="key('EntityTypes',type)/id"/>
                              <xsl:value-of select="type"/>
                            </xsl:otherwise>
                          </xsl:choose>

                        </button> 
                      </td> 
                    </tr>
                  </xsl:for-each>
                </table>
              </p>
          </xsl:if>
          
          <xsl:if test="attribute">
            <div><b>Attributes</b></div>
            <table>
              <xsl:attribute name="class" select="'attributeTable'"/>
              <xsl:for-each select="attribute">
                <xsl:call-template name="attributesummary"/>
              </xsl:for-each>
            </table>
          </xsl:if>
          <xsl:if test="self::composition">
              <xsl:variable name="typeid" select="key('EntityTypes',type)/id"/>
              <p>
               <xsl:text>See </xsl:text>
               <button>
                   <xsl:attribute name="id" select="$typeid"/>
                   <xsl:attribute name="class" select="'popout'"/>
                   <xsl:value-of select="type"/>
                </button> 
              </p>
          </xsl:if>

        </div>
      </div>
  </xsl:template>

  <xsl:template name="posesses_type">
    <xsl:variable name="vowel_modifier" select="era:indefinite(type)"/>
    <xsl:value-of select="(if (cardinality/ZeroOrOne) 
                               then ' may have a' || $vowel_modifier || ' ' 
                               else if (cardinality/ExactlyOne) 
                               then ' has a' || $vowel_modifier || ' '
                               else if (cardinality/ZeroOneOrMore) 
                               then ' has zero, one or more ' 
                               else if (cardinality/OneOrMore) 
                               then ' has one or more ' 
                               else 'NO OTHER CASES HERE'
                             )
                            "/>
    <xsl:element name="i">
       <xsl:value-of select="type"/>
    </xsl:element>
  </xsl:template>

  <xsl:function name="era:indefinite">
    <xsl:param name="noun" as="xs:string"/>
    <xsl:value-of select="let $char := substring($noun,1,1)
                          return if (fn:exists(fn:index-of(('a','e','i','o','u'),
                                                             $char
                                                            )))
                                 then 'n'
                                 else ''
                         "/>
  </xsl:function>


  <xsl:template name="attributesummary" match="attribute" mode="explicit">
     <tr>
        <td>
          <xsl:value-of select="display_text"/>
        </td>
        <td>
          <button>
              <xsl:attribute name="id" select="id"/>
              <xsl:attribute name="class" select="'popout'"/>
              <!--
              <xsl:attribute name="onClick" >
                <xsl:text>showAttributeDetail('</xsl:text>
                <xsl:value-of select="id"/>       
                <xsl:text>');</xsl:text>
              </xsl:attribute>
              -->
              <xsl:text>=&gt;</xsl:text>
          </button> 
        </td>
     </tr>
  </xsl:template>


  <xsl:template name="wrap_relationships" match="entity_model">   
    <xsl:param name="relationships"/>
    <xsl:param name="diagramHeight"/>
    <xsl:param name="diagramWidth"/>
    <svg>
      <xsl:attribute name="width">
        <xsl:value-of select="$diagramWidth"/>cm</xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$diagramHeight"/>cm</xsl:attribute>
      <xsl:attribute name="viewBox">
        <xsl:text>0 0 </xsl:text>
        <xsl:value-of select="$diagramWidth"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$diagramHeight"/>
      </xsl:attribute>
      <xsl:copy-of select="$relationships"/>
    </svg>
  </xsl:template>

  <xsl:template name="wrap_constructed_relationship" match="entity_model">   
    <xsl:param name="relationships"/>
    <xsl:param name="diagramHeight"/>
    <xsl:param name="diagramWidth"/>

    <svg>   
      <xsl:attribute name="width">
        <xsl:value-of select="$diagramWidth"/>cm</xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$diagramHeight"/>cm</xsl:attribute>
      <xsl:attribute name="viewBox">
        <xsl:text>0 0 </xsl:text>
        <xsl:value-of select="$diagramWidth"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$diagramHeight"/>
      </xsl:attribute>
      <xsl:copy-of select="$relationships/drawing/*"/>
    </svg>
  </xsl:template>

  <!--
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
           <xsl:value-of select="fn:min(($hcm,$wcm))*$etframearc div 2"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <rect>
    <xsl:choose>
       <xsl:when test="$isgroup">
           <xsl:attribute name="class">group</xsl:attribute>
       </xsl:when>
       <xsl:when test="$iseven">
           <xsl:attribute name="class">eteven</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
           <xsl:attribute name="class">etodd</xsl:attribute>
       </xsl:otherwise>
    </xsl:choose>
    <xsl:attribute name="x"><xsl:value-of select="$xcm"/>cm</xsl:attribute>
    <xsl:attribute name="y"><xsl:value-of select="$ycm"/>cm</xsl:attribute>
    <xsl:attribute name="rx"><xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
    <xsl:attribute name="ry"><xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
    <xsl:attribute name="width"><xsl:value-of select="$wcm"/><xsl:text>cm</xsl:text></xsl:attribute>
    <xsl:attribute name="height"><xsl:value-of select="$hcm"/><xsl:text>cm</xsl:text></xsl:attribute>
  </rect>
</xsl:template>
-->

  <xsl:template name="titlebox" saxon:trace="yes" xmlns:saxon="http://icl.com/saxon">
    <xsl:param name="xcm"/>
    <xsl:param name="ycm"/>
    <xsl:param name="wcm"/>
    <xsl:param name="hcm"/>
    <xsl:param name="title"/>
    <rect>
      <xsl:attribute name="class">outertitlebox</xsl:attribute>
      <xsl:attribute name="x">
        <xsl:value-of select="$xcm"/>cm</xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="$ycm"/>cm</xsl:attribute>
      <xsl:attribute name="width">
        <xsl:value-of select="$wcm"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$hcm"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
    </rect>
    <rect>
      <xsl:attribute name="class">titlebox</xsl:attribute>
      <xsl:attribute name="x">
        <xsl:value-of select="$xcm + 0.1"/>cm</xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="$ycm + 0.1"/>cm</xsl:attribute>
      <xsl:attribute name="width">
        <xsl:value-of select="$wcm - 0.2"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$hcm - 0.2"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
    </rect>
    <text>
      <xsl:attribute name="class">titletext</xsl:attribute>
      <xsl:attribute name="text-anchor">middle</xsl:attribute>
      <xsl:attribute name="x">
        <xsl:value-of select="$xcm + ($wcm div 2)"/>cm</xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="$ycm + 0.275 + 0.8"/>cm</xsl:attribute>
      <xsl:value-of select="$title" />
    </text>
  </xsl:template>

  <xsl:template name="entity_type_box" saxon:trace="yes" xmlns:saxon="http://icl.com/saxon">
    <xsl:param name="isgroup"/>
    <xsl:param name="iseven"/>
    <!-- FAILED EXPERIMENT 
    <xsl:param name="isboundary"/>
    -->
    <xsl:param name="xcm"/>
    <xsl:param name="ycm"/>
    <xsl:param name="wcm"/>
    <xsl:param name="hcm"/>
    <xsl:param name="shape" as="element(shape)?"/>
    <xsl:variable name="cornerRadiuscm">
      <xsl:choose>
        <xsl:when test="$isgroup">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="fn:min(($hcm,$wcm))*$etframearc div 2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="xAdjustment">
      <xsl:choose>
        <xsl:when test="$shape/Top">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:when test="$shape/TopLeft">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/MiddleLeft">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/BottomLeft">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/TopRight">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:when test="$shape/MiddleRight">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:when test="$shape/BottomRight">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:when test="$shape/Bottom">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="yAdjustment">
      <xsl:choose>
        <xsl:when test="$shape/Top">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/TopLeft">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/MiddleLeft">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:when test="$shape/BottomLeft">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:when test="$shape/TopRight">
          <xsl:value-of select="-0.2"/>
        </xsl:when>
        <xsl:when test="$shape/MiddleRight">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:when test="$shape/BottomRight">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:when test="$shape/Bottom">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="element_id">
      <xsl:value-of select="id"/>
      <!--
      <xsl:call-template name="element_text_div_id"/>
    -->
    </xsl:variable>

    <svg>
      <xsl:attribute name="x">
        <xsl:value-of select="$xcm - 0.1 - $xAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="$ycm - 0.1 - $yAdjustment"/>cm</xsl:attribute>
      <xsl:attribute name="width">
        <xsl:value-of select="$wcm + 0.2"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="height">
        <xsl:value-of select="$hcm + 0.2"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <rect>
        <xsl:attribute name="id" select="id"/>
        <xsl:choose>
          <xsl:when test="$isgroup">
            <xsl:attribute name="class" select="$shape/*/name()"/>
          </xsl:when>
          <!-- not cutrrentl;y doing anything 28/10/2022 
            <xsl:when test="not (string-length($shape)=0)">
              <xsl:attribute name="class">etodd</xsl:attribute>
            </xsl:when>
          -->
          <xsl:when test="$iseven">
            <xsl:attribute name="class">eteven</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">etodd</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <!--
        <xsl:attribute name="onclick">
          <xsl:value-of select="concat('top.showEntityTypeDetail(''',$element_id,''')')"/>
        </xsl:attribute>
        -->
        <xsl:attribute name="x">
          <xsl:value-of select="0.1 + $xAdjustment"/>cm</xsl:attribute>
        <xsl:attribute name="y">
          <xsl:value-of select="0.1 + $yAdjustment"/>cm</xsl:attribute>
        <xsl:attribute name="rx">
          <xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
        <xsl:attribute name="ry">
          <xsl:value-of select="$cornerRadiuscm"/>cm</xsl:attribute>
        <xsl:attribute name="width">
          <xsl:value-of select="$wcm"/>
          <xsl:text>cm</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="height">
          <xsl:value-of select="$hcm"/>
          <xsl:text>cm</xsl:text>
        </xsl:attribute>
      </rect>
    </svg>

  </xsl:template>


  <xsl:template name="attribute" match="attribute">
    <xsl:param name="xcm"/>
    <xsl:param name="ycm"/>
    <xsl:param name="iseven"/>
    <xsl:param name="annotation"/>
    <xsl:param name="deprecated"/>
    <xsl:variable name="element_id">
      <xsl:value-of select="id"/>
      <!--
      <xsl:call-template name="element_text_div_id"/>
    -->
    </xsl:variable>
    <text>
      <xsl:attribute name="id"><xsl:value-of select="id"/></xsl:attribute>
      <xsl:attribute name="class">
        <xsl:value-of select="   
                                if (identifying) then 'idattrname' else (if($deprecated='yes') then 'deprecatedattrname' else 'attrname')   
                             "/>
      </xsl:attribute>
      <xsl:attribute name="x"><xsl:value-of select="$xcm + 0.175"/>cm</xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="$ycm"/>cm</xsl:attribute>
      <!--
      <xsl:attribute name="onclick">
            <xsl:value-of select="concat('top.showAttributeDetail(''',$element_id,''')')"/>
      </xsl:attribute>
    -->
      <xsl:if test="xmlRepresentation='Anonymous'">
        <xsl:text>(</xsl:text>
      </xsl:if>
      <xsl:if test="xmlRepresentation='Attribute'">
        <xsl:text>@</xsl:text>
      </xsl:if>
      <xsl:value-of select="name" />
      <xsl:if test="xmlRepresentation='Anonymous'">
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:value-of select="$annotation" />
    </text>
    <xsl:variable name="class" select="if (implementationOf) then 'surfaceattrmarker' else 'attrmarker'"/>
    <xsl:choose>
      <xsl:when test="optional">
        <circle>
          <xsl:attribute name="class" select="$class"/>
          <xsl:attribute name="cx">
            <xsl:value-of select="$xcm + 0.05"/>cm</xsl:attribute>
          <xsl:attribute name="cy">
            <xsl:value-of select="$ycm - 0.125 + .05"/>cm</xsl:attribute>
          <xsl:attribute name="r">
            <xsl:text>0.05cm</xsl:text>
          </xsl:attribute>
        </circle>
      </xsl:when>
      <xsl:otherwise>
        <rect>
          <xsl:attribute name="class" select="$class"/>
          <xsl:attribute name="x">
            <xsl:value-of select="$xcm"/>cm</xsl:attribute>
          <xsl:attribute name="y">
            <xsl:value-of select="$ycm - 0.125"/>cm</xsl:attribute>
          <xsl:attribute name="width">
            <xsl:text>0.1cm</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="height">
            <xsl:text>0.1cm</xsl:text>
          </xsl:attribute>
        </rect>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="wrap_entity_type">
    <xsl:param name="content"/>
    <g>
      <xsl:attribute name="id">
        <xsl:value-of select="replace(name,' ','_')"/>
        <!--cannot reference groups if names have spaces-->
      </xsl:attribute>
      <xsl:copy-of select="$content"/>
    </g>
  </xsl:template>

  <!--
<xsl:template name="x_rhs_of_ultimate_container" match="entity_type|group">
  <xsl:choose>
     <xsl:when test="parent::entity_type or parent::group">
 for each parent
         <xsl:call-template name="x_rhs_of_ultimate_container"/>
     </xsl:when>
     <xsl:otherwise>
         <xsl:call-template name="etxRight">
            <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
         </xsl:call-template>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

  <!--
<xsl:template name="y_of_ultimate_container" match="entity_type|group">
  <xsl:choose>
     <xsl:when test="parent::entity_type or parent::group">
 for each parent
         <xsl:call-template name="y_of_ultimate_container"/>
     </xsl:when>
     <xsl:otherwise>
         <xsl:call-template name="et_y">
             <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
         </xsl:call-template>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

<!--
  <xsl:template name="entity_type_or_group_description" match="absolute|entity_type|group" mode="explicity">
    <xsl:choose>
      <xsl:when test="name()='entity_type'">
        <xsl:call-template name="entity_type_description"/>
      </xsl:when>
      <xsl:when test="name()='absolute'">
        <xsl:call-template name="entity_type_description"/>
      </xsl:when>
      <xsl:when test="name()='group'">
        <xsl:for-each select="entity_type|group">
          <xsl:call-template name="entity_type_or_group_description"/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
-->

  <xsl:template name="popUpxPos" match="absolute|entity_type|group" mode="explicit">
    <!--
      <xsl:choose>
        <xsl:when test="parent::entity_type">    
          <xsl:value-of select="0.5"/> 
        </xsl:when>
        <xsl:otherwise>
        -->
          <xsl:variable name="xRight">
          <!--     no longer get rid of groups from info stack 01/12/2022
            <xsl:choose>
              <xsl:when test="name(..)='group'">
                <xsl:for-each select="parent::group">
                  <xsl:call-template name="etxRight">
                    <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
              -->
                <xsl:call-template name="etxRight">
                  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
                </xsl:call-template> 
                <!--
              </xsl:otherwise>
            </xsl:choose>
          -->
          </xsl:variable>
          <xsl:value-of select="$xRight + 0.2"/>
          <!--
        </xsl:otherwise>
      </xsl:choose>
    -->
  </xsl:template>

  <xsl:template name="popUpyPos" match="absolute|entity_type" mode="explicit">
    <!--
      <xsl:choose>
        <xsl:when test="parent::entity_type">  
          <xsl:value-of select="2"/>
        </xsl:when>
        <xsl:when test="name()='absolute'">
          <xsl:value-of select="0.2"/>
        </xsl:when>
        <xsl:otherwise>
        -->
          <xsl:call-template name="et_y">
            <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
          </xsl:call-template>
          <!--
        </xsl:otherwise>
      </xsl:choose>
    -->
  </xsl:template>

<!--
  <xsl:template name="entity_type_description" match="absolute|entity_type" mode="explicit">
    <xsl:variable name="popUpxPos">
      <xsl:call-template name="popUpxPos"/>
    </xsl:variable>
    <xsl:variable name="popUpyPos">
          <xsl:call-template name="popUpyPos"/>
    </xsl:variable>
    <svg>
      <xsl:attribute name="x">
        <xsl:call-template name="popUpxPos"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="y">
        <xsl:call-template name="popUpyPos"/>
        <xsl:text>cm</xsl:text>
      </xsl:attribute>
      <g> 
        <xsl:attribute name="class">popupInfoBox</xsl:attribute>
        <rect>
          <xsl:attribute name="class">popupBoundingBox</xsl:attribute>
          <xsl:attribute name="x">0cm</xsl:attribute>
          <xsl:attribute name="y">0cm</xsl:attribute>
          <xsl:attribute name="width">7.0cm</xsl:attribute>
          <xsl:attribute name="height">
            <xsl:value-of select="max((4.0,1.0 + (string-length(description) div 50) * 0.4))"/>cm</xsl:attribute>
        </rect>
        <text>
          <xsl:attribute name="class">popupHeadingText</xsl:attribute>
          <xsl:attribute name="x">0.2cm</xsl:attribute>
          <xsl:attribute name="y">0.4cm</xsl:attribute>
          <xsl:choose>
            <xsl:when test="name()='entity_type'">
                Entity Type:
            </xsl:when>
            <xsl:when test="name()='absolute'">
                Model:
            </xsl:when>
          </xsl:choose>
          <xsl:value-of select="name"/>
        </text>
        <text>
          <xsl:attribute name="class">popupDetailText</xsl:attribute>
          <xsl:attribute name="x">0.2cm</xsl:attribute>
          <xsl:attribute name="y">0.5cm</xsl:attribute>
          <xsl:call-template name="spitLines2">
            <xsl:with-param name="pText" select="description"/>
            <xsl:with-param name="x" select="0.2"/>
            <xsl:with-param name="minLinelen" select="50"/>
          </xsl:call-template>
        </text>
        <set>
          <xsl:attribute name="attributeName">visibility</xsl:attribute>
          <xsl:attribute name="from">hidden</xsl:attribute>
          <xsl:attribute name="to">visible</xsl:attribute>
          <xsl:attribute name="begin">
            <xsl:value-of select="replace(name,' ','_')"/>
            <xsl:text>.click</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="end">
            <xsl:text>click</xsl:text>
          </xsl:attribute>
        </set>
        <xsl:for-each select="entity_type|group">
          <xsl:call-template name="entity_type_or_group_description"/>
        </xsl:for-each>
      </g>
    </svg>
  </xsl:template>
-->
  <!--End of description code-->

  <xsl:template name="start_relationship">
    <xsl:param name="relname"/>
  </xsl:template>


  <xsl:template name="sequence_indicator">
    <xsl:param name="x0"/>
    <xsl:param name="y0"/>
    <xsl:param name="x1"/>
    <xsl:param name="y1"/>
    <xsl:param name="x2"/>
    <xsl:param name="y2"/>
    <xsl:param name="x3"/>
    <xsl:param name="y3"/>
    <path>
      <xsl:attribute name="class">squiggle</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$x0"/>,<xsl:value-of select="$y0"/>
        <xsl:text> </xsl:text>
        <xsl:text>C</xsl:text>
        <xsl:value-of select="$x1"/>,<xsl:value-of select="$y1"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$x2"/>,<xsl:value-of select="$y2"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$x3"/>,<xsl:value-of select="$y3"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="crowsfoot_down">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <path>
      <!-- destination crowsfoot -->
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$x,',',$y - $relcrowlen)"/>
        <xsl:value-of select="concat('L',$x - $relcrowwidth,',',$y)"/>
        <xsl:value-of select="concat('M',$x,',',$y - $relcrowlen)"/>
        <xsl:value-of select="concat('L',$x,',',$y)"/>
        <xsl:value-of select="concat('M',$x,',',$y - $relcrowlen)"/>
        <xsl:value-of select="concat('L',$x + $relcrowwidth,',',$y)"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="crowsfoot_down_reflected">
    <!--Mark-->
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <path>    
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$x + $relcrowwidth,',',$y - (2*$relcrowlen))"/>
        <xsl:value-of select="concat('L',$x - $relcrowwidth,',',$y)"/>
        <xsl:value-of select="concat('M',$x,',',$y - $relcrowlen)"/>
        <xsl:value-of select="concat('L',$x,',',$y)"/>
        <xsl:value-of select="concat('M',$x - $relcrowwidth,',',$y - (2*$relcrowlen))"/>
        <xsl:value-of select="concat('L',$x + $relcrowwidth,',',$y)"/>
       <!-- 05/022019 
	    <xsl:value-of select="concat('M',$x - $relcrowwidth,',',$y - (2*$relcrowlen))"/>
        <xsl:value-of select="concat('L',$x + $relcrowwidth,',',$y - (2*$relcrowlen))"/>
		-->
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="identifier_comprel">
    <!--Mark-->
    <xsl:param name="x"/>
    <xsl:param name="y"/>
	<xsl:param name="width"/>
    <path>   
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$x - $width,',',$y)"/>
        <xsl:value-of select="concat('L',$x + $width,',',$y)"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="identifier_refrel">
    <!--Mark-->
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="width"/>
    <path>   
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$x,',',$y - $width)"/>
        <xsl:value-of select="concat('L',$x,',',$y + $width)"/>
      </xsl:attribute>
    </path>
  </xsl:template>

<!-- reinstated for use from relationship construction diagrams -->
    <xsl:template name="line">
    <xsl:param name="x0cm"/>
    <xsl:param name="y0cm"/>
    <xsl:param name="x1cm"/>
    <xsl:param name="y1cm"/>
    <xsl:param name="p_ismandatory"/>
    <xsl:param name="p_isconstructed"/>
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="$p_ismandatory = 'true'">mandatoryrelationshipline</xsl:when>
        <xsl:otherwise>optionalrelationshipline</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <path>
      <xsl:attribute name="class">
        <xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$x0cm,',',$y0cm)"/>
        <xsl:value-of select="concat('L',$x1cm,',',$y1cm)"/>
      </xsl:attribute>
    </path>
  </xsl:template>


  <xsl:template name="render_hitarea">
      <xsl:param name="rel_id" as="xs:string"/>
      <xsl:param name="line" as="element(line)"/>

      <xsl:call-template name="write_path">
         <xsl:with-param name="element_id" select="$rel_id"/>
         <xsl:with-param name="class" select="'relationshiphitarea'"/>
         <xsl:with-param name="line" select="$line"/>
      </xsl:call-template>
   </xsl:template>

  <xsl:template name="render_half_of_relationship" match="constructed_relationship|composition|reference">
      <xsl:param name="line" as="element(line)"/>
      <xsl:param name="is_mandatory" as="xs:boolean"/>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="$is_mandatory">mandatoryrelationshipline</xsl:when>
          <xsl:otherwise>optionalrelationshipline</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="write_path">
         <xsl:with-param name="class" select="$class"/>
         <xsl:with-param name="line" select="$line"/>
      </xsl:call-template>
  </xsl:template>

  <xsl:template name="write_path">
    <xsl:param name="element_id" as="xs:string?"/>
    <xsl:param name="line" as="element(line)"/> 
    <xsl:param name="class" as="xs:string"/>  
    <path>
        <xsl:if test="exists($element_id)">
           <xsl:attribute name="data-relid" select="$element_id"/>
           <xsl:attribute name="id" select="concat($element_id,'_hitarea')"/>
        </xsl:if>
       <xsl:attribute name="class" select="$class"/>
       <xsl:attribute name="d">
          <xsl:text>M</xsl:text>
          <xsl:value-of select="substring($line/point[1]/x,1,5)"/>
          <xsl:text>,</xsl:text>
          <xsl:value-of select="substring($line/point[1]/y,1,5)"/>
          <xsl:for-each select="$line/point[position() &gt; 1]">
                <xsl:text>L</xsl:text>
                <xsl:value-of select="substring(x,1,5)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="substring(y,1,5)"/>
          </xsl:for-each>
        </xsl:attribute>
        <!--
        <xsl:if test="exists($element_id)">
          <xsl:attribute name="onclick">
            <xsl:value-of select="concat('top.clickRelationship(''',$element_id,''')')"/>
          </xsl:attribute>
        </xsl:if>
        -->
    </path>
  </xsl:template>

  <xsl:template name="arrow">
    <xsl:param name="x0cm"/>
    <xsl:param name="y0cm"/>
    <xsl:param name="x1cm"/>
    <xsl:param name="y1cm"/>
    <xsl:variable name="class">
      <xsl:value-of select="arrow"/>
    </xsl:variable>
    <xsl:variable name="lengthcm">
      <xsl:value-of select="math:sqrt( (x1cm-x0cmp)*(x1cm-x0cmp) + (y1cm-y0cm)*(y1cm-y0cm) )"/>  
    </xsl:variable>
    <xsl:variable name="angle">
      <xsl:value-of select="math:atan((y1cm-y0cm)/ (x1cm-x0cm))"/>
    </xsl:variable>
    <g transform="translate(200,200) rotate(45)">
      <xsl:attribute name="class">
        <xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:attribute name="transform">
        <xsl:value-of select="concat('translate(',$x0cm,',',$y0cm,')')"/>
        <xsl:value-of select="concat('rotate(',$angle,')')"/>
      </xsl:attribute>
      <line x1="0" y1="0" x2="100" y2="0"/>
      <line x1="0" y1="0" x2="5" y2="-7" />
      <line x1="0" y1="0" x2="5" y2="7" />
    </g>
    <path>
      <xsl:attribute name="class">
        <xsl:value-of select="$class"/>
      </xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M0,0L',$lengthcm,',0,')"/>
        <xsl:value-of select="'M0,0L5,-7'"/>
        <xsl:value-of select="'M0,0L5,+7'"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="arc">
    <xsl:param name="x0"/>
    <xsl:param name="x1"/>
    <xsl:param name="x2"/>
    <xsl:param name="x3"/>
    <xsl:param name="y0"/>
    <xsl:param name="y1"/>
    <xsl:param name="y2"/>
    <xsl:param name="y3"/>

    <path>
      <xsl:attribute name="class">arc</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:text>M</xsl:text>
        <xsl:value-of select="$x0"/>,<xsl:value-of select="$y0"/>
        <xsl:text> </xsl:text>
        <xsl:text>C</xsl:text>
        <xsl:value-of select="$x1"/>,<xsl:value-of select="$y1"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$x2"/>,<xsl:value-of select="$y2"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$x3"/>,<xsl:value-of select="$y3"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="crowsfoot_across">
    <xsl:param name="xcm"/>
    <xsl:param name="ycm"/>
    <xsl:param name="sign"/>
    <xsl:param name="p_isconstructed"/>
    <path>
      <!-- crowsfoot -->
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$xcm + $relcrowlen * $sign,',',$ycm)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm - $relcrowwidth)"/>
        <xsl:value-of select="concat('M',$xcm + $relcrowlen * $sign,',',$ycm)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm)"/>
        <xsl:value-of select="concat('M',$xcm + $relcrowlen * $sign,',',$ycm)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm + $relcrowwidth)"/>
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="crowsfoot_across_reflected">
    <!--Mark-->
    <xsl:param name="xcm"/>
    <xsl:param name="ycm"/>
    <xsl:param name="sign"/>
    <xsl:param name="p_isconstructed"/>
    <path>
      <!-- crowsfoot -->
      <xsl:attribute name="class">crowsfoot</xsl:attribute>
      <xsl:attribute name="d">
        <xsl:value-of select="concat('M',$xcm + 2*($relcrowlen * $sign),',',$ycm + $relcrowwidth)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm - $relcrowwidth)"/>
        <xsl:value-of select="concat('M',$xcm + $relcrowlen * $sign,',',$ycm)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm)"/>
        <xsl:value-of select="concat('M',$xcm + 2*($relcrowlen * $sign),',',$ycm - $relcrowwidth)"/>
        <xsl:value-of select="concat('L',$xcm,',',$ycm + $relcrowwidth)"/>
        <!-- 05/02/2019 
		<xsl:value-of select="concat('M',$xcm + 2*($relcrowlen * $sign),',',$ycm - $relcrowwidth)"/>
        <xsl:value-of select="concat('L',$xcm + 2*($relcrowlen * $sign),',',$ycm + $relcrowwidth)"/>
		-->
      </xsl:attribute>
    </path>
  </xsl:template>

  <xsl:template name="spitLines2">
    <xsl:param name="pText"/>
    <xsl:param name="x"/>
    <xsl:param name="minLinelen"/>
    <xsl:variable name="infoTextLineHeight">
      <xsl:value-of select="0.4"/>
    </xsl:variable>
    <xsl:variable name="headTxt">
      <xsl:value-of select="substring(normalize-space($pText),1,$minLinelen)"/>
    </xsl:variable>
    <xsl:variable name="tailTxt">
      <xsl:value-of select="substring(normalize-space($pText),$minLinelen+1)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($tailTxt,' ')">
        <tspan>
          <xsl:attribute name="x" select="concat($x,'cm')"/>
          <xsl:attribute name="dy" select="concat($infoTextLineHeight,'cm')"/>
          <xsl:value-of select= "concat($headTxt,substring-before($tailTxt,' '))"/>
        </tspan>
        <xsl:call-template name="spitLines2">
          <xsl:with-param name="pText" select= "substring-after($tailTxt,' ')"/>
          <xsl:with-param name="x" select= "$x"/>
          <xsl:with-param name="minLinelen" select= "$minLinelen"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <tspan>
          <xsl:attribute name="x" select="concat($x,'cm')"/>
          <xsl:attribute name="dy" select="concat($infoTextLineHeight,'cm')"/>
          <xsl:value-of select= "$pText"/>
        </tspan>
      </xsl:otherwise>
    </xsl:choose>
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
		                       'LTEQ','&#x2272;'
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

    <text>
      <xsl:attribute name="class" select="$class"/>
      <xsl:choose>
        <xsl:when test="$class='relname' or $class='scope' 
                          or $class='relid' or $class='reletname'">
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
    </text>
  </xsl:template>



  <!-- NOT USED -->
  <xsl:template name="draw1Corner" >
    <!-- assumes already positioned at px0,py0 -->
    <xsl:param name="px0"/>
    <xsl:param name="py0"/>
    <xsl:param name="px1"/>
    <xsl:param name="py1"/>
    <xsl:param name="px2"/>
    <xsl:param name="py2"/>
    <xsl:variable name="sweepflag">
      <xsl:call-template name="sweep-flag">
        <xsl:with-param name="px0" select="$px0"/>
        <xsl:with-param name="py0" select="$py0"/>
        <xsl:with-param name="px1" select="$px1"/>
        <xsl:with-param name="py1" select="$py1"/>
        <xsl:with-param name="px2" select="$px2"/>
        <xsl:with-param name="py2" select="$py2"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="xArcStart" select="$px1 - compare($px1,$px0)*$rellinearc"/>
    <xsl:variable name="yArcStart" select="$py1 - compare($py1,$py0)*$rellinearc"/>
    <xsl:variable name="xArcEnd"   select="$px1 + compare($px2,$px1)*$rellinearc"/>
    <xsl:variable name="yArcEnd"   select="$py1 + compare($py2,$py1)*$rellinearc"/>
    <xsl:text>L</xsl:text>
    <xsl:value-of select="$xArcStart"/>,<xsl:value-of select="$yArcStart"/>
    <xsl:text>A</xsl:text>
    <xsl:value-of select="$rellinearc"/>
    <xsl:value-of select="$rellinearc"/> 0 0 <xsl:value-of select="$sweepflag"/>
    <xsl:value-of select="$xArcEnd"/>,<xsl:value-of select="$yArcEnd"/>
    <xsl:text>L</xsl:text>
    <xsl:value-of select="$px2"/>,<xsl:value-of select="$py2"/>
  </xsl:template>

  <xsl:template name="newline">
    <xsl:text>&#xD;&#xA;</xsl:text>
  </xsl:template>

  <xsl:template name="subsection">
    <xsl:param name="heading"/>
    <h2>
      <xsl:value-of select="$heading"/>
    </h2>
  </xsl:template>

  <xsl:template name="sweep-flag" >
    <!-- start point is (px0,py0), corner point is (px1,py1), end point is (px2,py2) -->
    <xsl:param name="px0"/>
    <xsl:param name="py0"/>
    <xsl:param name="px1"/>
    <xsl:param name="py1"/>
    <xsl:param name="px2"/>
    <xsl:param name="py2"/>
    <!--translate so that corner point is at (0,0) -->
    <xsl:variable name="x1" select="$px0 - $px1"/>
    <xsl:variable name="y1" select="$py0 - $py1"/>
    <xsl:variable name="x2" select="$px2 - $px1"/>
    <xsl:variable name="y2" select="$py2 - $py1"/>
    <!--cases based on matrix rotation followed by new y greater or less than zero -->
    <!--rotation is number of degrees to turn x1,y1 to 12 o'oclock -->
    <xsl:choose>
      <xsl:when test="$x1=0 and $y1 &gt; 0">
        <!--zero degrees rotation-->
        <!-- wrong use of compare <xsl:value-of select="max((0,compare($x2,0)))"/>   -->
      </xsl:when>
      <xsl:when test="$x1=0">
        <!-- 90 degrees rotation-->
        <!-- wrong use of compare <xsl:value-of select="max((0,compare(-$y2,0)))"/>  -->
      </xsl:when>
      <xsl:when test="$x1=0 and $y1 &lt; 0">
        <!--180 degrees rotation-->
        <!-- wrong use of compare <xsl:value-of select="max((0,compare(-$x2,0)))"/>  -->
      </xsl:when>
      <xsl:when test="$x1 &gt; 0">
        <!-- 270 degrees rotation-->
        <!-- wrong use of compare <xsl:value-of select="max((0,compare(-$y2,0)))"/>  -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>

<xsl:template name="generate_relationship_info_header_svg">
  <xsl:param name="rel" as="element((:reference|composition:))"/>

  <xsl:variable name="src_etname" as="xs:string" select="$rel/../name"/>
  <xsl:variable name="srcwidth" select="diagram:stringwidth($src_etname,1) + 0.5"/>
  <xsl:variable name="dest_etname" as="xs:string" select="$rel/type"/>
  <xsl:variable name="destwidth" select="diagram:stringwidth($dest_etname,1) + 0.5"/> 
  <xsl:variable name="relname" as="xs:string?" select="$rel/name"/>
  <xsl:variable name="inverse_name" as="xs:string?" select="$rel/inverse"/>
  <xsl:variable name="relationship_half_length" as="xs:float" select="1.5"/>
  <xsl:variable  name="relMandatory" as="xs:boolean"
                  select="exists(cardinality/(ExactlyOne | OneOrMore))
                 "/>
  <xsl:variable  name="relManyValued" 
                 as="xs:boolean"
                 select="exists(cardinality/(ZeroOneOrMore | OneOrMore))"/>
  <xsl:variable name="inverse" 
                as="element((:reference|composition:))?"
                select="if (inverse) 
                        then (
                             if (self::composition)
                             then key('DependencyBySrcTypeAndName',concat(type,':',inverse)) 
                             else key('RelationshipBySrcTypeAndName',concat(type,':',inverse)) 
                             )[current()/../name = type]
                        else ()" />
  <xsl:variable  name="inverseMandatory" as="xs:boolean"
                  select="exists($inverse/cardinality/(ExactlyOne | OneOrMore))"/>
  <xsl:variable  name="inverseManyValued" as="xs:boolean"
                  select="not($inverse) or exists($inverse/cardinality/(ZeroOneOrMore | OneOrMore))"/>
  <xsl:variable name="boxheight" as="xs:double" select="0.6"/>

  <xsl:variable name="xoffset" as="xs:double" select="2.0"/>

  <xsl:variable name="srcx" as="xs:double" select="$xoffset +
                                                   (if (self::reference)
                                                    then 0
                                                    else if ($destwidth &lt; $srcwidth)
                                                         then 0
                                                         else ($destwidth - $srcwidth) div 2
                                                    )
                                                  "/>
  <xsl:variable name="srcy" as="xs:double" select="0.4"/>
  <xsl:variable name="destx" as="xs:double" 
                select="if (self::reference)
                        then $srcx + $srcwidth+2*$relationship_half_length
                        else $xoffset +
                              (if ($srcwidth &lt; $destwidth)
                               then 0
                               else ($srcwidth - $destwidth) div 2
                               )
                        "/>
  <xsl:variable name="desty" as="xs:double" select="if (self::reference)
                                                     then $srcy
                                                     else 2
                                                    "/>
  <xsl:variable name="relsrcx" as="xs:double" select="if (self::reference)
                                                       then $srcx + $srcwidth 
                                                       else $srcx + $srcwidth div 2  "/>
  <xsl:variable name="relsrcy" as="xs:double" select="if (self::reference)
                                                       then $srcy + $boxheight div 2 
                                                       else $srcy + $boxheight "/>
  <xsl:variable name="reldestx" as="xs:double" select="if (self::reference)
                                                     then $relsrcx + $relationship_half_length * 2
                                                     else $relsrcx
                                                    "/>
  <xsl:variable name="reldesty" as="xs:double" select="if (self::reference)
                                                     then $relsrcy
                                                     else 2
                                                    "/>
  <xsl:variable name="diagramHeight" as="xs:double" 
                select="$desty + $boxheight + 0.1"/>

  <xsl:variable name="boxxright" as="xs:double" 
                select="if (self::reference)
                        then $destx + $destwidth
                        else max(($srcx + $srcwidth,$destx + $destwidth))
                        "/>

  <xsl:variable name="relationships_plus_rolenames"   as="element()*">
    <xsl:call-template name="relationship_half_line">
      <xsl:with-param name="startx"  select="$relsrcx"/>
      <xsl:with-param name="midx"  
                        select="($relsrcx + $reldestx) div 2"/>
      <xsl:with-param name="starty" select="$relsrcy"/>            
      <xsl:with-param name="midy" select="($relsrcy + $reldesty) div 2"/>            
      <xsl:with-param name="rolename"  select="$rel/name"/>    
      <xsl:with-param name="is_mandatory" select="$relMandatory"/>
      <xsl:with-param name="is_manyvalued"  select="$inverseManyValued"/>
      <xsl:with-param name="is_identifying"  select="exists($rel/identifying)"/>
      <xsl:with-param name="is_sequence"  select="exists($inverse/sequence)"/>
    </xsl:call-template>

    <xsl:call-template name="relationship_half_line">
      <xsl:with-param name="startx" 
                          select="$reldestx"/>
      <xsl:with-param name="midx" 
                        select="($relsrcx + $reldestx) div 2"/>
      <xsl:with-param name="starty" select="$reldesty"/>            
      <xsl:with-param name="midy" select="($relsrcy + $reldesty) div 2"/>            
      <xsl:with-param name="rolename" select="$rel/inverse"/>
      <xsl:with-param name="is_mandatory" select="$inverseMandatory"/>
      <xsl:with-param name="is_manyvalued"  select="$relManyValued"/>
      <xsl:with-param name="is_identifying"  select="exists($inverse/identifying)"/>
      <xsl:with-param name="is_sequence"  select="exists($rel/sequence)"/>
    </xsl:call-template>
  </xsl:variable>

<xsl:variable name="precount" as="xs:integer" 
              select="count($relationships_plus_rolenames[self::svg:text])"/>
     <!-- <xsl:message>xright precount is '<xsl:value-of select="$precount"/>'</xsl:message>  -->

<xsl:variable name="count" as="xs:integer" 
              select="count($relationships_plus_rolenames[self::svg:text][@xright])"/>
     <!-- <xsl:message>xright count is '<xsl:value-of select="$count"/>'</xsl:message>             -->
  <xsl:variable name="relationship_rolename_xright"
                as="xs:double"
                select="max((0,$relationships_plus_rolenames[self::svg:text]/@xright))"/>

  <!-- <xsl:message>xright is '<xsl:value-of select="$relationship_rolename_xright"/>'</xsl:message> -->

  <xsl:variable name="diagramWidth"
                  as="xs:double"
                  select="max(($relationship_rolename_xright,$boxxright))+0.5"/>

  <xsl:element name="svg">
    <xsl:attribute name="width"  select="format-number($diagramWidth, '#.00') || 'cm'"/>
    <xsl:attribute name="height" select="format-number($diagramHeight, '#.00') || 'cm'"/>

    <xsl:call-template name="labelled_box_of_given_width">
      <xsl:with-param name="x" select="$srcx"/>
      <xsl:with-param name="y" select="$srcy"/>
      <xsl:with-param name="width" select="$srcwidth"/>
      <xsl:with-param name="label" select="$src_etname"/>
    </xsl:call-template>

    <xsl:call-template name="labelled_box_of_given_width">
      <xsl:with-param name="x" select="$destx"/>
      <xsl:with-param name="y" select="$desty"/>
      <xsl:with-param name="width" select="$destwidth"/>
      <xsl:with-param name="label" select="$dest_etname"/>
    </xsl:call-template>

    <xsl:element name="svg">
      <xsl:attribute name="width" select="format-number($diagramWidth, '#.00') || 'cm'"/>
      <xsl:attribute name="height" select="'4cm'"/>
      <xsl:attribute name="viewBox" select="'0 0 ' || $diagramWidth || ' 4'"/>
      <xsl:copy-of select="$relationships_plus_rolenames"/>
    </xsl:element>  <!-- end inner svg (relationships) -->
  </xsl:element>  <!-- end outer svg -->
</xsl:template>

<xsl:template name="relationship_half_line">
    <xsl:param name="startx" as="xs:double"/>
    <xsl:param name="midx" as="xs:double"/>
    <xsl:param name="starty" as="xs:double"/>
    <xsl:param name="midy" as="xs:double"/>
    <xsl:param name="rolename" as="xs:string?"/>
    <xsl:param name="is_mandatory" as="xs:boolean"/>
    <xsl:param name="is_manyvalued" as="xs:boolean"/>
    <xsl:param name="is_identifying" as="xs:boolean"/>
    <xsl:param name="is_sequence" as="xs:boolean"/>

    <xsl:variable name="startxtext" select="$startx"/>
    <xsl:variable name="midxtext" select="$midx"/>
    <xsl:variable name="startytext" select="$starty"/>
    <xsl:variable name="midytext" select="$midy"/>

    <xsl:variable name="path_dvalue" as="xs:string"
                  select="'M' || $startxtext || ',' || $startytext ||
                            'L' || $midxtext || ',' || $midytext "/>

    <xsl:variable name="relclass">
        <xsl:choose>
          <xsl:when test="$is_mandatory">mandatoryrelationshipline</xsl:when>
          <xsl:otherwise>optionalrelationshipline</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:element name="path">
      <xsl:attribute name="class" select="$relclass"/>
      <xsl:attribute name="d" select="$path_dvalue"/>
      <xsl:if test="$is_manyvalued">
        <xsl:attribute name="marker-start" select="'url(#crowsfoot)'"/>
      </xsl:if>
    </xsl:element>

    <xsl:if test="$is_identifying">
      <xsl:element name="path">
         <xsl:attribute name="class" select="$relclass"/>
         <xsl:attribute name="d" select="$path_dvalue"/>
         <xsl:attribute name="marker-start" select="'url(#identifying)'"/>
       </xsl:element>             
    </xsl:if>

    <xsl:if test="$is_sequence">
      <xsl:element name="path">
         <xsl:attribute name="class" select="$relclass"/>
         <xsl:attribute name="d" select="$path_dvalue"/>
         <xsl:attribute name="marker-start" select="'url(#squiggle)'"/>
       </xsl:element>             
    </xsl:if>
    <xsl:element name="text">
      <xsl:attribute name="class" select="'relname'"/>
      <xsl:if test="self::reference">
        <xsl:attribute name="x" 
                      select="if ($startx &lt; $midx) then $startx + 0.1 else $startx - 0.1"/>
        <xsl:attribute name="y"   
                        select="if ($startx &lt; $midx) then '0.5' else '1' "/>
        <xsl:attribute name="text-anchor" 
                      select="if ($startx &lt; $midx) then 'start' else 'end'"/>
        <xsl:attribute name="xright" 
                      select="if ($startx &lt; $midx) 
                              then $startx + 0.1 + diagram:stringwidth($rolename,1)
                              else $startx - 0.1 "/>
      </xsl:if>
      <xsl:if test="self::composition">
        <xsl:attribute name="x" 
                      select="if ($starty &lt; $midy) then $startx - 0.1 else $startx + 0.1"/>
        <xsl:attribute name="y"   
                        select="if ($starty &lt; $midy) then $starty + 0.25 else $starty - 0.12 "/>
        <xsl:attribute name="text-anchor" 
                      select="if ($starty &lt; $midy) then 'end' else 'start'"/>
        <xsl:attribute name="xright" 
                       select="if ($starty &lt; $midy) 
                              then $startx - 0.1 
                              else $startx + diagram:stringwidth($rolename,1)"/>
      </xsl:if>
      <xsl:value-of select="$rolename"/>
    </xsl:element>
</xsl:template>

<xsl:template name="labelled_box_of_given_width">
  <xsl:param name="x" as="xs:double"/>
  <xsl:param name="y" as="xs:double"/>
  <xsl:param name="width" as="xs:double"/>
  <xsl:param name="label" as="xs:string"/>
  <xsl:variable name="boxround" select="'0.06cm'"/>
  <xsl:variable name="boxheight" select="'0.6cm'"/>

  <xsl:element name="rect">
    <xsl:attribute name="class" select="'eteven'"/>
    <xsl:attribute name="x" select="format-number($x, '#.00') || 'cm'"/>
    <xsl:attribute name="y" select="format-number($y, '#.00') || 'cm'"/>
    <xsl:attribute name="rx" select="$boxround"/>
    <xsl:attribute name="ry" select="$boxround"/>
    <xsl:attribute name="width" select="format-number($width, '#.00') || 'cm'"/>
    <xsl:attribute name="height" select="$boxheight"/>
  </xsl:element>
  <xsl:element name="text">
    <xsl:attribute name="class" select="'etname'"/> 
    <xsl:attribute name="x" select="format-number($x + ($width div 2), '#.00') || 'cm'"/> 
    <xsl:attribute name="y" select="format-number($y + 0.35, '#.00') || 'cm'"/> 
    <xsl:attribute name="text-anchor" select="'middle'"/>
    <xsl:value-of select="$label"/>
  </xsl:element>
</xsl:template>

<xsl:template name="svg_defs">
      <svg>
      <xsl:attribute name="style" select="'display:none'"/>
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
</xsl:template>


</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.svg.xslt--> 

