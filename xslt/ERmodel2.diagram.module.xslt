<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.diagram.module.xslt 
****************************************************************

Copyright 2016, 2107 Cyprotex Discovery Ltd.

This file is part of the the ERmodel suite of models and transforms.

The ERmodel suite is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ERmodel suite is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
****************************************************************
-->

<!--
****************************
ERmodel2.diagram.module.xslt
****************************

DESCRIPTION
  An xslt module which contains the logic for drawing ER model diagrams
  independent of the format. 
  THis module is used from ERmodel2.svg.xslt and Ermodel2.tex.xslt.

  Note: (1) If an entity type has both  a <below> and a <rightOf> then 
            <x> is determined by the <x> value relative to the <below> 
            <y> is determined by the <y> value relative to the <rightOf>

        (2) <yt><relative><to>ET</to><ratio>1</ratio></relative></yt>
               positions <yt> at the lower edge of ET.

CHANGE HISTORY
         JC  15-Aug-2016 Bugfix: Fix so that use of <ratio> in positioning 
                         using <yt> so that ratio is the proportional distance
                         along the entity being positioned relative to.
                         The fix is in templete et_yFromRelative to pass 
                         $destRatio not $srcRatio to call of et_y_ratio_h.
                         Following this need use $srcRatio NOT $destRatio 
                         in subsequent calculation of y.

CR-18032 JC  17-Aug-2016 Fix shortcoming by which inheritance is not supported
                         in display of scope in template 'text_of_construction'.
                         For this purpose introduce the
                         key AllCoreRelationshipsByQualifiedName.

CR-18651 JC  04-Nov-2016 Modify presentation of scopes.

CR-18657 JC  04-Nov-2016 Use entity_model2.initial_enrichment.module.xslt
                         and replace templates for deriving text of scope
                         by use of scope_display_text.
CR-18712 JC  14-Nov-2016 Don't try printing a constructed_relationship 
                         without an implementation these come about because 
                         the inverse of a constructed relationship needs be
                         a constructed relatonship without an implementation 
CR-20614 TE  18-Jul-2017 Bow-tie notation for pullbacks
25-Sept-2017 J.Cartmell  Do not display scope on diagram when there is a 'noscopes' parameter.
11-Oct-2017 J.Cartmell   Do not generate pop up descriptive text in svg.
23-Sep-2022 J.Cartmell   Modify so that relationship identifiers can be given generated differently to
                         relationship names so that there display can be controlled in generated diagrams. 
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >

<xsl:param name="filestem"/>
<xsl:param name="debug"/>
<xsl:param name="noscopes" as="xs:string?"/>
<xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />
<xsl:variable name="scopeson" as="xs:boolean" select="if (not(exists($noscopes))) then true() else $noscopes='n'" />

<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="ERmodel.assembly.module.xslt"/>
<xsl:include href="ERmodel2.initial_enrichment.module.xslt"/>

<!-- 
-->

<xsl:key name="EntityTypes" 
         match="entity_type|group" 
         use="name"/>
<xsl:key name="IncomingCompositionRelationships" 
         match="composition" 
         use="type"/>
<xsl:key name="AllIncomingCompositionRelationships" 
         match="composition" 
         use="key('EntityTypes',type)/descendant-or-self::entity_type/name"/> 
<xsl:key name="ConstructedRelationshipsByQualifiedName" 
         match="constructed_relationship" 
         use="concat(../name,'.',name)"/>
<xsl:key name="CoreRelationshipsByQualifiedName" 
         match="reference|composition|dependency" 
         use="concat(../name,'.',name)"/>
<!-- CR-18032 -->
<xsl:key name="AllCoreRelationshipsByQualifiedName" 
         match="reference|composition|dependency"
         use ="../descendant-or-self::entity_type/concat(name,'.',current()/name)" />
<!-- end CR-18032 -->
<xsl:key name="RelationshipBySrcTypeAndName" 
         match="reference|composition|dependency" 
         use="concat(../name,':',name)"/>
<xsl:key name="ReferenceBySrcTypeAndName" 
         match="reference" 
         use="concat(../name,':',name)"/>
<xsl:key name="CompositionByDestTypeAndInverseName" 
         match="composition" 
         use="concat(type,':',inverse)"/>
<xsl:key name="whereImplemented" 
         match="implementationOf"
         use="concat(../../name,':',rel)"/>
<xsl:key name="CompRelsByDestTypeAndInverseName" 
         match="composition" 
         use="concat(type,':',inverse)"/>
<xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/concat(name,':',current()/name)" />

<xsl:variable name="comprelArmLen" select="0.4"/>
<xsl:variable name="comprelSrcArmLenNotNamed" select="0.15"/>
<xsl:variable name="comprelDestArmLenDelta" select="0.1"/>
<xsl:variable name="refrelsrcarmlen" select="1.2"/>
<xsl:variable name="refreldestarmlen" select="0.4"/>
<xsl:variable name="rellinearc" select="0.10"/>
<xsl:variable name="relcrowlen" select="0.15"/>
<xsl:variable name="relcrowwidth" select="0.15"/>
<xsl:variable name="relcrowarc" select="0.20"/>
<xsl:variable name="relcrowbendx" select="0.05"/>
<xsl:variable name="relcrowbendy" select="0.17"/>
<xsl:variable name="recursiverelxmargin" select="0.5"/>
<xsl:variable name="etframearc" select="0.2"/>
<xsl:variable name="relLabelxSeparation" select="0.15"/>  <!-- 06/02/2019 What if .. changed from 0.1 -->
<xsl:variable name="relLabelySeparation" select="0.15"/>  <!-- 06/02/2019 What if .. changed from 0.1 -->
<xsl:variable name="relLabelLineHeight" select="0.3"/>
<xsl:variable name="arcDefaultWidthRatio" select="0.8"/>
<xsl:variable name="arcDefaultOffset" select="0.2"/>
<xsl:variable name="arcHeight" select="0.2"/>
<xsl:variable name="popupxPos" select="26.8"/>
<xsl:variable name="popupyPos" select="8.0"/>
<xsl:variable name="popupHeight" select="11.0"/>
<xsl:variable name="horizontalSeparation" select="0.5"/>
<xsl:variable name="horizontalMargin" select="0.25"/>
<xsl:variable name="verticalMargin" select="0.25"/>
<xsl:variable name="attribute_xpos_offset" select="0.2"/>
<xsl:variable name="charlen" select="0.1275"/>  <!-- was 0.125 --> <!-- after which was 0.11 -->  
                                               <!--make it 0.120 based on latex diags and long attr names-->
                                               <!-- 10 Dec 2015 increased to 0.1275 and modified 10px svg to 11px svg-->
<xsl:variable name="titlecharlen" select="$charlen div 11 * 30"/>
<xsl:variable name="etname_y_offset" select="0.35"/>
<xsl:variable name="attribute_ypos_offset" select="$etname_y_offset"/>  <!-- was + 0.3 -->
<xsl:variable name="seq_y_offset" select="0.4"/>
<xsl:variable name="seq_y_step" select="0.06"/>
<xsl:variable name="seq_y_top_offset" select="$seq_y_offset + 4 * $seq_y_step"/>
<xsl:variable name="seq_x_start" select="0.06"/>
<xsl:variable name="seq_x_sweepout" select="0.35"/>
<xsl:variable name="relid_offset" select="0.25"/>  <!-- 05/02/2019 previously was 0.3 (= 2 * relcrowlen) -->
<xsl:variable name="relid_width" select="0.1"/>   
<xsl:variable name="relid_step" select="0.075"/>   <!-- was 0.1 -->
<!-- used in depicting constructed realtionships: -->
<xsl:variable name="conrel_etname_yspacer" select="0.1"/>
<xsl:variable name="conrel_indented_etname_xadjustment" select="0.05"/>
<xsl:variable name="conreltext_xoffset" select="0.2"/>
<xsl:variable name="conreltext_yoffset" select="0.1"/>
<xsl:variable name="conrel_xoffset" select="0.1"/>       <!-- was 0.2 -->
<xsl:variable name="conrel_yoffset" select="0.3"/>
<xsl:variable name="conrel_box_xmargin" select="0.2"/>   <!-- was 0.3 -->
<xsl:variable name="conrel_boxhead_ymargin" select="0.05"/>
<xsl:variable name="conrel_boxtail_ymargin" select="0.1"/>
<!--<xsl:variable name="conrel_height" select="0.5"/> -->
<xsl:variable name="conrel_height" select="0.7"/>
<xsl:variable name="conrel_width" select="3.0"/>

<!--
<xsl:variable name="diagramHeight">
    <xsl:call-template name="getDiagramHeight"/>
</xsl:variable>
-->

<!-- This cannot be a global variable after modularisation change 
     and so this no longer used previously used by absolute and elsewhere
            <xsl:variable name="diagramWidth">   
                <xsl:call-template name="getDiagramWidth"/>
            </xsl:variable>
-->

<xsl:variable name="etDefaultWidth">
   <xsl:choose>
      <xsl:when test="/entity_model/defaults/et_width">
         <xsl:value-of select="/entity_model/defaults/et_width"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="1.3333"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:variable>

<xsl:variable name="etDefaultySeparation">   <!-- this is y separation used when one et positioned below another -->
   <xsl:choose>
      <xsl:when test="/entity_model/defaults/et_y_separation">
         <xsl:value-of select="/entity_model/defaults/et_y_separation"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="0.3"/> 
      </xsl:otherwise>
   </xsl:choose>
</xsl:variable>

<xsl:variable name="etDefaultyDeltaSeparation"> 
           <!-- this is  a delta to y separation when et being 
                positioned below has outgoing composition 
           -->
   <xsl:choose>
      <xsl:when test="/entity_model/defaults/et_y_delta_separation">
         <xsl:value-of select="/entity_model/defaults/et_y_delta_separation"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="0.6"/> 
                  <!-- hit bug if this + 0.3 exactly 2 * comprelArmLen-->
      </xsl:otherwise>
   </xsl:choose>
</xsl:variable>

<xsl:template name="main" match="/">
<xsl:message>In main in 2.diagram.module --- debug = <xsl:value-of select="$debug"/> </xsl:message>
<xsl:message>In main not exists $scopeson = <xsl:value-of select="$scopeson"/> </xsl:message>

   <!-- an initial assembly (see ERmodel2.assembly.module.xslt)        -->
    <xsl:variable name="state">
      <xsl:apply-templates select="*" mode="assembly"/>
    </xsl:variable>

   <xsl:if test="$debugon">
      <xsl:message>putting out state <xsl:value-of select="$state/name()"/></xsl:message>
      <xsl:result-document href="initial_assembly_for_svg_temp.xml" method="xml">
        <xsl:sequence select="$state"/>
      </xsl:result-document>
    </xsl:if>

   <!-- an initial enrichment (see ERmodel2.initial_enrichment.module.xslt)        -->
   <xsl:variable name="state">
      <xsl:call-template name="initial_enrichment">
          <xsl:with-param name="document" select="$state"/>
      </xsl:call-template>
   </xsl:variable>

   <xsl:for-each select="$state/entity_model">
      <xsl:call-template name="entity_model_diagram"/> 
      <xsl:for-each select="//entity_type/constructed_relationship">
         <xsl:if test="join|aggregate">   <!-- the inverse of a constructed relationship is a constructed relatonship without an implementation -->
            <xsl:message> about to call ="output_constructed_relationship" </xsl:message>
            <xsl:call-template name="output_constructed_relationship"/>
         </xsl:if>
      </xsl:for-each>
   </xsl:for-each>
<!--
   <xsl:if test="$fileextension='tex'">
      <xsl:result-document href="{concat('catalogue',$filestem,'.tex')}">
         <xsl:if test="//entity_type/constructed_relationship">
            <xsl:call-template name="subsection">
               <xsl:with-param name="heading" select="'Core Model'"/>
            </xsl:call-template>
         </xsl:if>
         <xsl:value-of select="concat('\input{',$filestem,'}')"/>
         <xsl:call-template name="newline"/>
         <xsl:text>\newline</xsl:text>
         <xsl:call-template name="newline"/>
         <xsl:for-each select="//entity_type/constructed_relationship">
            <xsl:variable name="constructed_rel_filestem">
               <xsl:value-of select="concat($filestem,'.',../name,'.',name)"/>
            </xsl:variable>
            <xsl:call-template name="subsection">
               <xsl:with-param name="heading" 
                               select="$constructed_rel_filestem"/>
            </xsl:call-template>
            <xsl:value-of 
                   select="concat('\input{',$constructed_rel_filestem,'}')"/>
            <xsl:call-template name="newline"/>
            <xsl:text>\newline</xsl:text>
            <xsl:call-template name="newline"/>
         </xsl:for-each>
      </xsl:result-document> 
   </xsl:if>
-->
</xsl:template>

<xsl:template name="entity_model_diagram" match="entity_model">
  <xsl:call-template name="wrap_diagram">
     <xsl:with-param name="acting_filestem" select="$filestem"/>
     <xsl:with-param name="content">
       <xsl:call-template name="diagram_content">
       </xsl:call-template>
     </xsl:with-param>
     <xsl:with-param name="diagramHeight">
        <xsl:call-template name="getDiagramHeight"/>
     </xsl:with-param>
     <xsl:with-param name="diagramWidth">
        <xsl:call-template name="getDiagramWidth"/>
     </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="diagram_content" match="entity_model">
   <xsl:for-each select="entity_type|group">
       <xsl:if test="$debug!=''">
          <xsl:text>\ertrace{</xsl:text>
               <xsl:value-of select="trace(string(name),'entity type name')"/>   
          <xsl:text>}</xsl:text>
       </xsl:if>
       <xsl:call-template name="entity_type">
          <xsl:with-param name="p_et_iseven" select="fn:false()"/>
          <xsl:with-param name="p_grp_iseven" select="fn:false()"/>
       </xsl:call-template>
   </xsl:for-each>
   <xsl:if test="absolute/presentation">
       <xsl:call-template name="titlebox">
          <xsl:with-param name="xcm" select="absolute/presentation/x"/>
          <xsl:with-param name="ycm" select="absolute/presentation/y"/>
          <xsl:with-param name="hcm" select="2"/>
          <xsl:with-param name="wcm" select="((string-length(absolute/name)+ 7) * $titlecharlen )+ 1"/>
          <xsl:with-param name="title" select="concat('Model: ',absolute/name)"/>
       </xsl:call-template>
   </xsl:if>
   <xsl:for-each select="absolute">
       <xsl:call-template name="absolute"/>
   </xsl:for-each>
   <xsl:call-template name="wrap_relationships">
      <xsl:with-param name="relationships">
         <xsl:call-template name="relationship_content"/>
      </xsl:with-param>
      <xsl:with-param name="diagramHeight">
         <xsl:call-template name="getDiagramHeight"/>
      </xsl:with-param>
      <xsl:with-param name="diagramWidth">
         <xsl:call-template name="getDiagramWidth"/>
      </xsl:with-param>
   </xsl:call-template>
   <!-- 11-Oct-2017 J. Cartmell Do not generate pop up text in svg
   <xsl:for-each select="absolute|entity_type|group">
      <xsl:call-template name="entity_type_or_group_description"/>
   </xsl:for-each>
   -->
</xsl:template>

<xsl:template name="absolute" match="absolute">
   <xsl:variable name="diagramWidth">   
        <xsl:call-template name="getDiagramWidth"/>
   </xsl:variable>
   <xsl:call-template name="wrap_entity_type">
      <xsl:with-param name="content">
          <xsl:call-template name="entity_type_box">
             <xsl:with-param name="isgroup" select="false()"/>
             <xsl:with-param name="iseven" select="true()"/>
             <xsl:with-param name="xcm" select="0" />
             <xsl:with-param name="ycm" select="-0.3" />
             <xsl:with-param name="wcm" select="$diagramWidth" />
             <xsl:with-param name="hcm" select="0.5" />
             <!--<xsl:with-param name="shape" select="nonesuchthingy" />-->
          </xsl:call-template>
      </xsl:with-param>
   </xsl:call-template>
</xsl:template>

<xsl:template name="relationship_content" match="entity_model">   
  <xsl:for-each select="//entity_type|absolute">
    <!--
    <xsl:message>Rel content for entity type: <xsl:value-of select="name"/></xsl:message>
    -->
    <xsl:variable name="srcbasex">
       <xsl:call-template name="et_x">
          <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="srcbasey">
       <xsl:call-template name="et_y">
          <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="et_width">
       <xsl:call-template name="et_width"/>
    </xsl:variable>
    <xsl:variable name="et_height"> 
       <xsl:call-template name="et_height"/>
    </xsl:variable>
    <xsl:for-each select="composition">
       <xsl:call-template name="composition"/>
    </xsl:for-each>
    <xsl:for-each select="reference|constructed_relationship">
       <xsl:if test="diagram">
          <xsl:call-template name="reference"/>
       </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="dependency_group">
       <xsl:call-template name="dependency_group">
         <xsl:with-param name="xabsHost">
            <xsl:value-of select="$srcbasex"/>
         </xsl:with-param>
         <xsl:with-param name="yabsHost">
            <xsl:value-of select="$srcbasey"/>
         </xsl:with-param>
         <xsl:with-param name="widthHost"> 
            <xsl:value-of select="$et_width"/>
         </xsl:with-param>
         <xsl:with-param name="heightHost"> 
            <xsl:value-of select="$et_height"/>
         </xsl:with-param>
       </xsl:call-template>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template name="entity_type" match="entity_type|group">
  <xsl:param name="p_et_iseven"/>
  <xsl:param name="p_grp_iseven"/>
  <!--<xsl:message>Entity type: <xsl:value-of select="name"/></xsl:message>  -->
  <xsl:call-template name="wrap_entity_type">
    <xsl:with-param name="content">
      <xsl:call-template name="entity_type_content">
	 <xsl:with-param name="p_et_iseven" select="$p_et_iseven"/>
	 <xsl:with-param name="p_grp_iseven" select="$p_grp_iseven"/>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="entity_type_content" match="entity_type|group">
  <xsl:param name="p_et_iseven"/>
  <xsl:param name="p_grp_iseven"/>
       <xsl:if test="$debug!=''">
          <xsl:text>\ertrace{</xsl:text>
               <xsl:value-of select="trace(string(name),'entity type about to call et_x')"/>   
          <xsl:text>}</xsl:text>
       </xsl:if>
  <xsl:variable name= "xabs">
     <xsl:call-template name="et_x">
	<xsl:with-param name="scheme" select="'ABSOLUTE'"/>
     </xsl:call-template>
  </xsl:variable>
       <xsl:if test="$debug!=''">
          <xsl:text>\ertrace{</xsl:text>
               <xsl:value-of select="trace(string(name),'entity type about to call et_y')"/>   
          <xsl:text>}</xsl:text>
       </xsl:if>
  <xsl:variable name= "yabs">
     <xsl:call-template name="et_y">
	<xsl:with-param name="scheme" select="'ABSOLUTE'"/>
     </xsl:call-template>
  </xsl:variable>
  <xsl:variable name= "height">
     <xsl:call-template name="et_height"/>
  </xsl:variable>
       <xsl:if test="$debug!=''">
          <xsl:text>\ertrace{</xsl:text>
               <xsl:value-of select="trace(string(name),'entity type about to call width')"/>   
          <xsl:text>}</xsl:text>
       </xsl:if>
  <xsl:variable name= "width">
     <xsl:call-template name="et_width"/>
  </xsl:variable>
       <xsl:if test="$debug!=''">
          <xsl:text>\ertrace{</xsl:text>
               <xsl:value-of select="trace(string(name),'entity type back from width')"/>   
          <xsl:text>}</xsl:text>
       </xsl:if>
  <xsl:variable name="cornerRadius">
     <xsl:value-of select="fn:min(($height,$width))*$etframearc div 2"/>
  </xsl:variable>
  <xsl:variable name="etnamexPos">
     <xsl:choose>
	<xsl:when test="entity_type">
	   <xsl:value-of select="$cornerRadius * 0.8"/>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:value-of select="$width * $etframearc div 2"/>
	</xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name= "l_et_iseven" as="xs:boolean">
      <xsl:choose>
	  <xsl:when test="exists(self::group)">
	     <xsl:value-of select="$p_et_iseven"/>
	  </xsl:when>
	  <xsl:otherwise>
	     <xsl:value-of select="not($p_et_iseven)"/>
	  </xsl:otherwise>
       </xsl:choose>
  </xsl:variable>
  <xsl:variable name= "l_grp_iseven" as="xs:boolean">
      <xsl:choose>
	       <xsl:when test="exists(self::group)">
	          <xsl:value-of select="not($p_grp_iseven)"/>
	        </xsl:when>
	     <xsl:otherwise>
	         <xsl:value-of select="$p_grp_iseven"/>
	      </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <xsl:if test="not(self::group) or ($debug!='') or (exists(presentation/shape))">
    <xsl:call-template name="entity_type_box">
       <xsl:with-param name="isgroup" select="exists(self::group)"/>  
       <xsl:with-param name="iseven" as="xs:boolean">
	        <xsl:choose>
	          <xsl:when test="exists(self::group)">
	             <xsl:value-of select="$l_grp_iseven"/>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:value-of select="$l_et_iseven"/>
	          </xsl:otherwise>
	        </xsl:choose>
       </xsl:with-param>
       <xsl:with-param name="xcm" select="$xabs"/>
       <xsl:with-param name="ycm" select="$yabs"/>
       <xsl:with-param name="wcm" select="$width"/>
       <xsl:with-param name="hcm" select="$height"/>
       <xsl:with-param name="shape" select="presentation/shape" />
    </xsl:call-template>
  </xsl:if>
  <!-- annotation of a group -->
  <xsl:if test ="annotation">
     <xsl:variable name="xcm" select="$xabs + 0.1"/>
	 <xsl:variable name="ycm" select="$yabs + 0.3"/>
	 <xsl:variable name="xsign" select="1"/>  <!-- group annotation was previously external to the group boundary -->
                                             <!-- modify to be in the bounding box of the group 28/10/2022-->
  	 <xsl:call-template name="spitLines">
	    <xsl:with-param name="pText" select="annotation"/>
	    <xsl:with-param name="x" select="$xcm"/>
	    <xsl:with-param name="y"   select="$ycm"/>
	    <xsl:with-param name="xsign" select="$xsign"/>
	    <xsl:with-param name="ysign" select="+1"/>
	    <xsl:with-param name="class" select="'groupannotation'"/>
	 </xsl:call-template>
  </xsl:if>
  <xsl:variable name="etnameyPos">
    <xsl:value-of select="$yabs +  $etname_y_offset"/>
  </xsl:variable>
  <xsl:if test="not(presentation/name/None) and not(self::group)">
     <xsl:choose>
   	<xsl:when test="not(entity_type|attribute)">
   	   <!-- center the text in the box -->
   	   <xsl:call-template name="entity_type_name"> 
   	     <xsl:with-param name="xcm" select="$xabs + ($width div 2)"/>
   	     <xsl:with-param name="ycm" select="$etnameyPos"/>
   	     <xsl:with-param name="xsign" select="0"/>
   	   </xsl:call-template>
   	</xsl:when>
   	<xsl:otherwise>
   	   <!-- run the text from the left -->
   	   <xsl:call-template name="entity_type_name"> 
   	     <xsl:with-param name="xcm" select="$xabs + $etnamexPos"/>
   	     <xsl:with-param name="ycm" select="$etnameyPos"/>
   	     <xsl:with-param name="xsign" select="+1"/>
   	   </xsl:call-template>
   	</xsl:otherwise>
     </xsl:choose>
  </xsl:if>
  <xsl:variable name="no_linebreaks_in_etname">  
    <xsl:choose>
      <xsl:when test="presentation/name/Split">
	 <xsl:value-of select="string-length(name) - string-length(replace(name,'_',''))"/>
     </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:for-each select="attribute">
    <xsl:variable name="annotation">
       <xsl:call-template name="annotation"/>
    </xsl:variable>
    <xsl:call-template name="attribute">
      <xsl:with-param name="xcm" select="$xabs + $attribute_xpos_offset"/>
      <xsl:with-param name="ycm"  select="$etnameyPos +(0.3 * (position()+$no_linebreaks_in_etname) )"/>
      <!--       
       <xsl:with-param name="iseven" as="xs:boolean">
	        <xsl:choose>
	          <xsl:when test="exists(self::group)">
	             <xsl:value-of select="$l_grp_iseven"/>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:value-of select="$l_et_iseven"/>
	          </xsl:otherwise>
	        </xsl:choose>
       </xsl:with-param>
       -->
      <xsl:with-param name="annotation" select="$annotation"/>
      <xsl:with-param name="deprecated" select="if (deprecated) then 'yes' else 'no'"/>
    </xsl:call-template>
  </xsl:for-each>
  <xsl:for-each select="entity_type|group">
      <xsl:call-template name="entity_type">
	<xsl:with-param name="p_et_iseven" select="$l_et_iseven"/>
	<xsl:with-param name="p_grp_iseven" select="$l_grp_iseven"/>
      </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xsl:template name="annotation" match="attribute">
   <xsl:if test="implementationOf">   <!-- optimisation and beginings of restructure within above when when/if -->
      <xsl:text>(</xsl:text>
      <xsl:for-each select="implementationOf">
         <xsl:value-of select="if(position() &gt; 1) then ',' else ''"/>
         <xsl:variable name="relid">
               <xsl:value-of select="key('ReferenceBySrcTypeAndName',concat(../../name,':',rel))/id"/>
               <xsl:value-of select="key('CompositionByDestTypeAndInverseName',concat(../../name,':',rel))/id"/>
         </xsl:variable>
         <xsl:value-of select="if ($relid='')then rel else $relid"/>
      </xsl:for-each>
      <xsl:variable name="attributeName" select="name" />
      <xsl:for-each select="../reference">
         <xsl:variable name="relid" select="id"/> 
<!-- keep since dont understand  if 
         <xsl:if test="implementing_attributes[name=$attributeName]">
            <xsl:for-each select="$implementing_attributes">
               <xsl:if test="name=$attributeName">
                 <xsl:value-of select="concat(',',$relid)"/>
               </xsl:if>
            </xsl:for-each>
         </xsl:if>
         -->
         <xsl:for-each select="rdb_navigation/where_component">
               <xsl:if test="srcattr=$attributeName">
                  <xsl:value-of select="concat(',',$relid)"/>
               </xsl:if>
         </xsl:for-each>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
   </xsl:if>
</xsl:template>

<xsl:template name="maxNoOfCharsInEntityTypeName"> 
   <xsl:choose>
      <xsl:when test="presentation/name/Split">   
	 <xsl:call-template name="maxCharsWhenSplitLines">
	    <xsl:with-param name="pText" select="name"/>
	 </xsl:call-template>
      </xsl:when>
      <xsl:otherwise> 
	  <xsl:value-of select="string-length(name)"/>
      </xsl:otherwise> 
   </xsl:choose>
</xsl:template>

<xsl:template name="maxCharsWhenSplitLines">
   <xsl:param name="pText"/>
   <xsl:choose>
      <xsl:when test="contains($pText,'_')">
	 <xsl:variable name="countRecursive" as="xs:double"> 
	    <xsl:call-template name="maxCharsWhenSplitLines">
	       <xsl:with-param name="pText" 
			    select= "substring-after($pText, '_')"/>
	    </xsl:call-template>
	 </xsl:variable>
	 <xsl:variable name="countFirstpart" as="xs:double">
	    <xsl:value-of select="string-length(substring-before($pText,'_'))"/>
	 </xsl:variable>
	 <xsl:value-of select="max(($countRecursive,$countFirstpart))"/>
      </xsl:when>
      <xsl:otherwise>
	  <xsl:value-of select="string-length($pText)"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="entity_type_name">
   <xsl:param name="xcm" />
   <xsl:param name="ycm" />
   <xsl:param name="xsign" />
   <xsl:choose>
      <xsl:when test="presentation/name/Split">    <!-- add some other split directives sometime -->
	 <xsl:call-template name="spitLines">
	    <xsl:with-param name="pText" select="name"/>
	    <xsl:with-param name="x" select="$xcm"/>
	    <xsl:with-param name="y"   select="$ycm"/>
	    <xsl:with-param name="xsign" select="$xsign"/>
	    <xsl:with-param name="ysign" select="+1"/>
	    <xsl:with-param name="class" select="'etname'"/>
	 </xsl:call-template>
      </xsl:when>
      <xsl:otherwise> 
	 <xsl:call-template name="ERtext">
	    <xsl:with-param name="x" select="$xcm"/>
	    <xsl:with-param name="y" select="$ycm"/>
	    <xsl:with-param name="xsign" select="$xsign"/>
	    <xsl:with-param name="pText" select="name"/>
	    <xsl:with-param name="class" select="'etname'"/>
	 </xsl:call-template>
      </xsl:otherwise> 
   </xsl:choose>
</xsl:template>

<xsl:template name="et_xFromRelative" match="entity_type|group">      
   <!-- 
     This is called for an entity type that is defined as  relative to another
	  below or rightOf another entity type. 
     The entity type that it is defined as above or below must have
      the same locality i.e they both must have the same 
     parent entity type.
   -->
   <xsl:param name="scheme"/>
   <!-- This parameter determines whether the y position returned is
	     LOCAL i.e. relative to the parent i
	  or ABSOLUTE  i.e. is the y position on the diagram as a whole
   -->
   <!--
   <xsl:message> et_xFromRelative <xsl:value-of select="concat(name(), ':' , name)"/></xsl:message> 
   -->
   <xsl:variable name="width">
      <xsl:call-template name="et_width"/>
   </xsl:variable>
      <xsl:choose>
	 <xsl:when test="presentation/(xl|xc|xr)/relative"> 
	    <xsl:variable name="srcRatio">
		<xsl:choose>
		   <xsl:when test="presentation/xl">
		      <xsl:value-of select="0"/>
		   </xsl:when>
		   <xsl:when test="presentation/xc">
		      <xsl:value-of select="0.5"/>
		   </xsl:when>
		   <xsl:when test="presentation/xr">
		      <xsl:value-of select="1"/>
		   </xsl:when>
		</xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="destRatio">
		<xsl:choose>
		   <xsl:when test="presentation/(xl|xc|xr)/relative/ratio">
		      <xsl:value-of select="presentation/(xl|xc|xr)/relative/ratio"/>
		   </xsl:when>
		   <xsl:otherwise>
		      <xsl:value-of select="$srcRatio"/>
		   </xsl:otherwise>
		</xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="relativisinget_x">
		<xsl:for-each select="key('EntityTypes',presentation/(xl|xc|xr)/relative/to)">
		    <xsl:call-template name="et_x_ratio_w">
		       <xsl:with-param name="scheme" select="$scheme"/>
		       <xsl:with-param name="ratio" select="$destRatio"/>
		    </xsl:call-template>
		</xsl:for-each>
	     </xsl:variable>
	     <!--
	     <xsl:message>
		  srcRatio <xsl:value-of select="$srcRatio"/>
		  destRatio <xsl:value-of select="$destRatio"/>
		  relativising et x <xsl:value-of select="$relativisinget_x"/>
	     </xsl:message>
	     -->
	     <xsl:choose>
		<xsl:when test="presentation/(xl|xc|xr)/relative/d">
		   <xsl:value-of select="presentation/(xl|xc|xr)/relative/d 
					  + $relativisinget_x - ($width * $srcRatio)"/>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="$relativisinget_x - ($width * $srcRatio)"/>
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:when>
	 <xsl:when test="presentation/below">
	    <xsl:variable name="relativisinget_xMid">
		<xsl:for-each select="key('EntityTypes',presentation/below)">
		    <xsl:call-template name="et_xMid">
		       <xsl:with-param name="scheme" select="$scheme"/>
		    </xsl:call-template>
		</xsl:for-each>
	     </xsl:variable>
	     <xsl:choose>
		<xsl:when test="presentation/x">
		   <xsl:value-of select="presentation/x + $relativisinget_xMid - ($width div 2)"/>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="$relativisinget_xMid - ($width div 2)"/>
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:when>
	 <xsl:when test="presentation/rightOf">   
	    <!-- This branch OK so that can have <rightOf> AND <below> 22/05/2014 -->
            <xsl:if test="not(key('EntityTypes',presentation/rightOf))">
                <xsl:message> *** no such entity type as '<xsl:value-of select="presentation/rightOf"/>' </xsl:message>
            </xsl:if>
	    <xsl:variable name="relativisingxRight">
		   <xsl:for-each select="key('EntityTypes',presentation/rightOf)">
		       <xsl:call-template name="etxRight">
			  <xsl:with-param name="scheme" select="$scheme"/>
		       </xsl:call-template>
		   </xsl:for-each>
		</xsl:variable>
		<xsl:choose>
		   <xsl:when test="presentation/x">
		      <xsl:value-of select="presentation/x + $relativisingxRight"/>
		   </xsl:when>
		   <xsl:otherwise>
		      <xsl:value-of select="$horizontalSeparation + $relativisingxRight"/> 
		   </xsl:otherwise>
	       </xsl:choose>
	 </xsl:when>
      </xsl:choose>
</xsl:template>

<xsl:template name="et_x" match="entity_type|group">
   <xsl:param name="scheme"/>
           <xsl:variable name="number">
   <xsl:choose>
      <xsl:when test="name()='absolute'">
	 <xsl:value-of select="0"/>
      </xsl:when>
      <xsl:when test="presentation/xl/abs">
	 <xsl:if test="$scheme='LOCAL' and (parent::entity_type | parent::group)">
	     <xsl:message terminate = "yes">
		  et_x called with scheme LOCAL with abs presentation and having a parent entity type or group
	     </xsl:message>
	 </xsl:if>
	 <xsl:value-of select="presentation/xl/abs/d"/>
      </xsl:when>
      <xsl:when test="presentation/(below|rightOf|((xl|xc|xr)/relative))">
	 <xsl:call-template name="et_xFromRelative">
	    <xsl:with-param name="scheme" select="$scheme"/>
	 </xsl:call-template>
      </xsl:when>
      <xsl:when test="parent::entity_type or parent::group">
	 <xsl:variable name="offsetToParent">
	    <xsl:choose>
	       <xsl:when test="$scheme='ABSOLUTE'">
		  <xsl:for-each select="parent::entity_type|parent::group">
		     <xsl:call-template name="et_x">
			<xsl:with-param name="scheme" select="'ABSOLUTE'"/>
		     </xsl:call-template>
		  </xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="0"/>
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:variable>
	 <xsl:choose>
	    <xsl:when test="presentation/x">
	       <xsl:value-of select="$offsetToParent + presentation/x"/>
	    </xsl:when>
	    <xsl:otherwise>
	       <xsl:choose>
		  <xsl:when test="parent::group">
		      <xsl:value-of select="$offsetToParent"/>
		  </xsl:when>
		  <xsl:otherwise>
		      <xsl:value-of select="$offsetToParent + $horizontalMargin"/>
		  </xsl:otherwise>
	       </xsl:choose>
	    </xsl:otherwise>
	 </xsl:choose>
      </xsl:when>
      <xsl:when test="presentation/x">
	 <xsl:value-of select="presentation/x"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select="0"/>
      </xsl:otherwise>
   </xsl:choose>
   </xsl:variable>
           <!--
           <xsl:message>
              ET <xsl:value-of select="name"/> x <xsl:value-of select="$number"/>
           </xsl:message>
           -->
   <xsl:value-of select="$number"/>
</xsl:template>


<xsl:template name="attribute_xRight_relative_to_parent" match="attribute">
   <xsl:variable name="annotation">
       <xsl:call-template name="annotation"/>
   </xsl:variable>
   <xsl:value-of select="$attribute_xpos_offset + (string-length(name)+string-length($annotation)) * $charlen"/> 
</xsl:template>


<xsl:template name="et_subtype_xRight_relative_to_parent" match="entity_type|group">
   <xsl:variable name="x">
      <xsl:call-template name="et_x">
	 <xsl:with-param name="scheme" select="'LOCAL'"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="w">
      <xsl:call-template name="et_width"/>
   </xsl:variable>
   <xsl:value-of select="$x + $w"/>
</xsl:template>

<xsl:template name="et_x_ratio_w" match="entity_type|group">
   <xsl:param name="scheme"/>
   <xsl:param name="ratio"/>
   <xsl:variable name="xLeft">
      <xsl:call-template name="et_x">
	 <xsl:with-param name="scheme" select="$scheme"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="$ratio = 0">
	 <xsl:value-of select="$xLeft"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:variable name="width">
	    <xsl:call-template name="et_width"/>
	 </xsl:variable>
	 <xsl:value-of select="$xLeft + ($width * $ratio)"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="et_xMid" match="entity_type|group">
   <xsl:param name="scheme"/>
   <xsl:call-template name="et_x_ratio_w">
      <xsl:with-param name="scheme" select="$scheme"/>
      <xsl:with-param name="ratio" select="0.5"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="etxRight" match="absolute|entity_type|group">
   <xsl:param name="scheme"/>
   <xsl:variable name="x">
      <xsl:call-template name="et_x">
	 <xsl:with-param name="scheme" select="$scheme"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="w">
      <xsl:choose>
	 <xsl:when test="name()='absolute'">
         <xsl:variable name="diagramWidth">   
              <xsl:call-template name="getDiagramWidth"/>
         </xsl:variable>
	      <xsl:value-of select="$diagramWidth" />
	 </xsl:when>
	 <xsl:otherwise>
	    <xsl:call-template name="et_width"/>
	 </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:sequence select="number($x + $w)"/>
</xsl:template>

<xsl:template name="et_height" match="entity_type|group">
   <xsl:variable name="heightIncrement">
      <xsl:choose>
         <xsl:when test="presentation/deltah">
            <xsl:value-of select="presentation/deltah"/>
         </xsl:when>
         <xsl:otherwise>
	    <xsl:value-of select="0"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="presentation/h">
	 <xsl:value-of select="presentation/h"/>
      </xsl:when>
      <xsl:when test="name()='absolute'">
	 <xsl:value-of select="0.5"/>
      </xsl:when>
      <xsl:when test="entity_type|group">  
	 <xsl:variable name="yLowerArray" as="xs:double *">
	    <xsl:for-each select="entity_type|group">
		<xsl:call-template name="et_yLower">
		    <xsl:with-param name="scheme" select="'LOCAL'"/>
		</xsl:call-template>
	    </xsl:for-each>
	 </xsl:variable>
	 <xsl:choose>
	    <xsl:when test="self::group">
	       <xsl:value-of select="max($yLowerArray) + $heightIncrement"/>
	    </xsl:when>
	    <xsl:otherwise>
	       <xsl:value-of select="max($yLowerArray) + $verticalMargin +$heightIncrement"/>
	    </xsl:otherwise>
	 </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:variable name="offsetToETs">
	    <xsl:call-template name="self_offset_to_ets"/>
	 </xsl:variable>
	 <xsl:value-of select="0.25 + $offsetToETs + $heightIncrement"/>        <!-- probably wrong for an empty group --> 
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="et_width" match="entity_type|group">
  <xsl:variable name="maxNoOfCharsInEntityTypeName">
     <xsl:call-template name="maxNoOfCharsInEntityTypeName"/>
  </xsl:variable>
  <xsl:variable name="width_for_et_name">
     <xsl:value-of select="$maxNoOfCharsInEntityTypeName * $charlen * 1.1"/> <!-- leave room for x offset of name -->
  </xsl:variable>
   <xsl:variable name="widthIncrement">
      <xsl:choose>
	  <xsl:when test="presentation/deltaw">
	      <xsl:value-of select="presentation/deltaw"/>
	  </xsl:when>
	  <xsl:otherwise>
	      <xsl:value-of select="0"/>
	  </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="presentation/w">
	 <xsl:value-of select="presentation/w"/>
      </xsl:when>
      <xsl:when test="entity_type|attribute|name">
	 <xsl:variable name="xRightArray" as="xs:double *">
	    <xsl:for-each select="entity_type|group">  
				     <!-- added '|group' 26Nov2014 -->
		<xsl:call-template name="et_subtype_xRight_relative_to_parent"/>
	    </xsl:for-each>
	    <xsl:for-each select="attribute">
		<xsl:call-template name="attribute_xRight_relative_to_parent"/>
	    </xsl:for-each>
	    <xsl:value-of select="$width_for_et_name"/>
	 </xsl:variable>
	 <xsl:choose>
	    <xsl:when test="self::group">
		  <xsl:value-of select="max($xRightArray) + $widthIncrement"/>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:choose>
		    <xsl:when test="presentation/deltaw">
			<xsl:value-of select="max($xRightArray) + $horizontalMargin + presentation/deltaw"/>
		    </xsl:when>
		    <xsl:otherwise>
			<xsl:value-of select="max((max($xRightArray) + $horizontalMargin,$etDefaultWidth))"/> 
		    </xsl:otherwise>
		</xsl:choose>
	    </xsl:otherwise>
	 </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select="$etDefaultWidth + $widthIncrement"/>  <!-- default width -->
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="et_y_ratio_h" match="entity_type|group">
   <xsl:param name="ratio"/>
   <xsl:variable name="y">
      <xsl:call-template name="et_y">
	 <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="h">
      <xsl:call-template name="et_height"/>
   </xsl:variable>
   <xsl:value-of select="$y + $h * $ratio"/> 
</xsl:template>

<xsl:template name="etLowerEdgey" match="entity_type|group">
   <xsl:call-template name="et_y_ratio_h">
	<xsl:with-param name="ratio" select="1"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="etMidPointy" match="entity_type|group">
   <xsl:call-template name="et_y_ratio_h">
      <xsl:with-param name="ratio" select="0.5"/>
   </xsl:call-template>
</xsl:template>

<!-- y functions -->
<xsl:template name="et_yFromRelative" match="entity_type|group">
   <!-- 
     This template is called for an entity type that is defined as below or rightOf or relative to another entity type. 
     The entity type that it is defined as above or below must have the same locality i.e they both must have the same 
     parent entity type. OR MUST THEY see "below nested et" in test.xml
   -->
   <xsl:param name="scheme"/>
   <!-- This parameter determines whether the y position returned is
	     LOCAL i.e. relative to the parent 
	  or ABSOLUTE  i.e. is the y position on the diagram as a whole
   -->

   <!-- If there is a <below> AND a <rightOf> then y determined by the <rightOf> -->
   <!--<xsl:message> 
	   Calling et_height from et_yFromRelative(<xsl:value-of select="name"/>)
       </xsl:message>
   -->
   <xsl:variable name="height">
      <xsl:call-template name="et_height"/>
   </xsl:variable>
      <xsl:choose>
	 <xsl:when test="presentation/(yt|ym|yl)/relative"> 
	    <xsl:variable name="srcRatio">
		<xsl:choose>
		   <xsl:when test="presentation/yt">
		      <xsl:value-of select="0"/>
		   </xsl:when>
		   <xsl:when test="presentation/ym">
		      <xsl:value-of select="0.5"/>
		   </xsl:when>
		   <xsl:when test="presentation/yl">
		      <xsl:value-of select="1"/>
		   </xsl:when>
		</xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="destRatio">
		<xsl:choose>
		   <xsl:when test="presentation/(yt|ym|yl)/relative/ratio">
		      <xsl:value-of select="presentation/(yt|ym|yl)/relative/ratio"/>
		   </xsl:when>
		   <xsl:otherwise>
		      <xsl:value-of select="$srcRatio"/>
		   </xsl:otherwise>
		</xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="relativisinget_y">
		<xsl:for-each select="key('EntityTypes',presentation/(yt|ym|yl)/relative/to)">
		    <xsl:call-template name="et_y_ratio_h">
		       <xsl:with-param name="ratio" select="$destRatio"/>      <!-- 15 Aug 2016 was $srcRatio -->
		    </xsl:call-template>
		</xsl:for-each>
	     </xsl:variable>
            <!--
	     <xsl:message>
		 height <xsl:value-of select="$height"/>
		 dest ratio <xsl:value-of select="$destRatio"/>
		 relativisinget_y <xsl:value-of select="$relativisinget_y"/>
		 relative/d <xsl:value-of select="presentation/(yt|ym|yl)/relative/d"/>
	     </xsl:message>
             -->
	     <xsl:choose>
		<xsl:when test="presentation/(yt|ym|yl)/relative/d">
		   <xsl:value-of select="presentation/(yt|ym|yl)/relative/d + $relativisinget_y + ($height * $srcRatio)"/>
                                                                                        <!--  15 Aug was $destRatio -->
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="$relativisinget_y - ($height * $srcRatio)"/>    <!-- 15 Aug was $destRatio -->
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:when>
	 <xsl:when test="presentation/rightOf">
	    <xsl:variable name="heightAdjustment">
	       <xsl:variable name="myHeight">
		  <xsl:call-template name="et_height"/>
	       </xsl:variable>
	       <xsl:variable name="relativesHeight">
		  <xsl:for-each select="key('EntityTypes',presentation/rightOf)">
		     <xsl:call-template name="et_height"/>
		  </xsl:for-each>
	       </xsl:variable>
	       <xsl:choose>
		  <xsl:when test="presentation/mAlign">
		      <xsl:value-of select="($relativesHeight - $myHeight) div 2"/>
		  </xsl:when>
		  <xsl:when test="presentation/bAlign">
		      <xsl:value-of select="$relativesHeight - $myHeight"/>
		  </xsl:when>
		  <xsl:when test="presentation/tAlign"> # default
		      <xsl:value-of select="0"/>
		  </xsl:when>
		  <xsl:otherwise>
		      <xsl:value-of select="0"/>
		  </xsl:otherwise>
	       </xsl:choose>
	    </xsl:variable>
	    <xsl:variable name="relativisingy">
	       <xsl:for-each select="key('EntityTypes',presentation/rightOf)">
		  <xsl:call-template name="et_y">
		     <xsl:with-param name="scheme" select="$scheme"/>
		  </xsl:call-template>
	       </xsl:for-each>
	    </xsl:variable>
	    <xsl:choose>
	       <xsl:when test="presentation/y">
		  <xsl:value-of select="presentation/y + $relativisingy + $heightAdjustment"/>
	       </xsl:when>
	       <xsl:otherwise>
		  <xsl:value-of select="$relativisingy + $heightAdjustment"/> 
	       </xsl:otherwise>
	    </xsl:choose>
	 </xsl:when>
	 <xsl:when test="presentation/(xl|xr)/relative">    
	    <xsl:for-each select="key('EntityTypes',presentation/(xl|xr)/relative/to)">
                 <xsl:call-template name="et_y">
                      <xsl:with-param name="scheme" select="$scheme"/>
                 </xsl:call-template>
	    </xsl:for-each>
	 </xsl:when>
	 <xsl:when test="presentation/(below|xc/relative)">    
	    <!-- branch moved so can have <below> and <rightOf> 22/05/2014 -->
	    <xsl:variable name="relativisinget_yLower">
		<xsl:for-each select="key('EntityTypes',presentation/(below|xc/relative/to))">
		   <xsl:call-template name="et_yLowerPlusDelta">
		      <xsl:with-param name="scheme" select="$scheme"/>
		   </xsl:call-template>
		</xsl:for-each>
	     </xsl:variable>
	     <xsl:choose>
		<xsl:when test="presentation/y">
		   <xsl:value-of select="presentation/y 
					 + $relativisinget_yLower"/>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="$etDefaultySeparation 
					 + $relativisinget_yLower"/>
			 <!-- first summand is small 0.3 separation -->
			 <!-- second summand includes +delta 0.6 if 
						   outgoing composition-->
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:when>
	 <xsl:otherwise>
	     <xsl:message> non non-supported y format in et_yFromRelative </xsl:message>
	 </xsl:otherwise>
      </xsl:choose>
</xsl:template>

<xsl:template name="et_y" match="entity_type|group">
   <xsl:param name='scheme'/>
   <!-- LOCAL or ABSOLUTE addressing -->
   <xsl:variable name="result">
   <xsl:if test="$scheme='LOCAL' and not(parent::entity_type | parent::group)">
       <xsl:message terminate = "yes">
	    et_y called with scheme LOCAL but no parent entity type or group
       </xsl:message>
   </xsl:if>
   <xsl:choose>
      <xsl:when test="name()='absolute'">
	 <xsl:value-of select="-0.3"/>
      </xsl:when>
      <xsl:when test="presentation/yt/abs">
	 <xsl:if test="$scheme='LOCAL' and (parent::entity_type | parent::group)">
	     <xsl:message terminate = "yes">
		  et_y called with scheme LOCAL with abs presentation and having a parent entity type or group
	     </xsl:message>
	 </xsl:if>
	 <xsl:value-of select="presentation/yt/abs/d"/>
      </xsl:when>
      <xsl:when test="presentation/(below|rightOf|((yt|ym|yr)/relative)|((xl|xc|xr)/relative))">
	 <xsl:call-template name="et_yFromRelative">
	    <xsl:with-param name="scheme" select="$scheme"/>
	 </xsl:call-template>
      </xsl:when>
      <xsl:when test="parent::entity_type or parent::group">
	 <xsl:variable name="offsetToParent">
	    <xsl:choose>
	       <xsl:when test="$scheme='ABSOLUTE'">
		  <xsl:for-each select="parent::entity_type|parent::group">
		     <xsl:call-template name="et_y">
			<xsl:with-param name="scheme" select="'ABSOLUTE'"/>
		     </xsl:call-template>
		  </xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="0"/>
		</xsl:otherwise>
	    </xsl:choose>
	 </xsl:variable>
	 <xsl:variable name="localOffsetToETs">
	    <xsl:call-template name="offset_to_ets"/>
	 </xsl:variable>
	 <xsl:choose>
	    <xsl:when test="presentation/y">
	       <xsl:value-of select="$offsetToParent + presentation/y 
				     + $localOffsetToETs"/> 
				  <!--NOT CORRECT FOR GROUPS -->
	    </xsl:when>
	    <xsl:otherwise>  
	       <xsl:choose>
		  <xsl:when test="parent::group"> 
		     <xsl:value-of select="$offsetToParent"/>
		  </xsl:when>
		  <xsl:otherwise>
		     <xsl:value-of select="$offsetToParent + $verticalMargin  
				     + $localOffsetToETs"/>
		  </xsl:otherwise>
	       </xsl:choose>
	    </xsl:otherwise>
	 </xsl:choose>
      </xsl:when>
      <xsl:when test="presentation/y">
	 <xsl:value-of select="presentation/y" />
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select="0"/>
      </xsl:otherwise>
   </xsl:choose>
   </xsl:variable>
   <!--
   <xsl:message >
	 et_y for et named <xsl:value-of select="name"/> returning <xsl:value-of select="$result"/>
   </xsl:message>
   -->
   <xsl:value-of select="$result"/>
</xsl:template>

<xsl:template name="offset_to_ets" match="entity_type|group">
   <xsl:variable name="numberOfparentAttributes">
      <xsl:value-of select="count(parent::entity_type/attribute)
				+count(parent::entity_type/choice)"/>
   </xsl:variable>   
   <xsl:variable name="no_linebreaks_in_etname">
      <xsl:choose>
	 <xsl:when test="parent::entity_type/presentation/name/Split">
	    <xsl:value-of select="string-length(parent::entity_type/name) 
			   - string-length(replace(parent::entity_type/name,'_',''))"/>
	 </xsl:when>
	 <xsl:otherwise>
	    <xsl:value-of select="0"/>
	 </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:value-of select="$attribute_ypos_offset 
			      + (($numberOfparentAttributes + $no_linebreaks_in_etname) * 0.3)"/>
   </xsl:variable>
   <!--
   <xsl:message>
      offset_to_ets for entity type '<xsl:value-of select="name"/>' returning <xsl:value-of select="$result"/>
   </xsl:message>
   -->
   <xsl:value-of select="$result"/>
</xsl:template>


<xsl:template name="self_offset_to_ets" match="entity_type|group">
   <xsl:variable name="numberOfAttributes">
      <xsl:value-of select="count(self::entity_type/attribute)
				+count(self::entity_type/choice)"/>
   </xsl:variable>   
   <xsl:variable name="no_linebreaks_in_etname">
      <xsl:choose>
	 <xsl:when test="self::entity_type/presentation/name/Split">
	    <xsl:value-of select="string-length(self::entity_type/name) 
			   - string-length(replace(self::entity_type/name,'_',''))"/>
	 </xsl:when>
	 <xsl:otherwise>
	    <xsl:value-of select="0"/>
	 </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:value-of select="$attribute_ypos_offset 
			      + (($numberOfAttributes + $no_linebreaks_in_etname) * 0.3)"/>
   </xsl:variable>
   <!-- 
   <xsl:message>
      self_offset_to_ets for entity type '<xsl:value-of select="name"/>' returning <xsl:value-of select="$result"/>
   </xsl:message>
   -->
   <xsl:value-of select="$result"/>
</xsl:template>

<xsl:template name="et_yLower" match="entity_type|group">
   <xsl:param name="scheme"/>
   <xsl:if test="not($scheme='ABSOLUTE' or $scheme='LOCAL')">
       <xsl:message> et_yLower called with invalid scheme:'<xsl:value-of select="$scheme"/>' </xsl:message>
   </xsl:if>
   <xsl:variable name="y">
      <xsl:call-template name="et_y">
	 <xsl:with-param name="scheme" select="$scheme"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="h">
      <xsl:call-template name="et_height"/>
   </xsl:variable>
   <xsl:value-of select="$y + $h"/>
</xsl:template>

<xsl:template name="et_yLowerPlusDelta" match="entity_type|group">
   <xsl:param name="scheme"/>
   <xsl:variable name="yLower">
      <xsl:call-template name="et_yLower">
	 <xsl:with-param name="scheme" select="$scheme"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>
     <xsl:when test="composition">
	 <xsl:value-of select="$yLower + $etDefaultyDeltaSeparation"/>
     </xsl:when>
     <xsl:otherwise>
	 <xsl:value-of select="$yLower"/>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="getDiagramHeight">
   <xsl:choose>
      <xsl:when test="/entity_model/diagram/box/h">
	 <xsl:value-of select="/entity_model/diagram/box/h"/>
      </xsl:when>
      <xsl:otherwise>
	  <xsl:variable name="deltah">
	     <xsl:choose>
		<xsl:when test="/entity_model/presentation/diagram/deltah">
		   <xsl:value-of 
			select="/entity_model/presentation/diagram/deltah"/>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="0"/>
		</xsl:otherwise>
	     </xsl:choose>
	  </xsl:variable>
	 <xsl:variable name="yLowerArray" as="xs:double *">
	    <xsl:for-each select="//(entity_type|group)">
	       <xsl:call-template name="etLowerEdgey"/>
	    </xsl:for-each>
	 </xsl:variable>
	 <xsl:value-of select="max($yLowerArray) + $deltah"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="getDiagramWidth">
   <xsl:choose>
      <xsl:when test="/entity_model/diagram/box/w">   <!-- this branch not supported by schema-->
	 <xsl:value-of select="/entity_model/diagram/box/w"/>
      </xsl:when>
      <xsl:otherwise>
	  <xsl:variable name="deltaw">
	     <xsl:choose>
		<xsl:when test="/entity_model/presentation/diagram/deltaw">
		   <xsl:value-of 
			select="/entity_model/presentation/diagram/deltaw"/>
<xsl:message> deltaw is <xsl:value-of select="/entity_model/presentation/diagram/deltaw"/> </xsl:message>
		</xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="0"/>
		</xsl:otherwise>
	     </xsl:choose>
	  </xsl:variable>
	 <xsl:variable name="xRightArray" as="xs:double *">
	    <xsl:for-each select="//(entity_type|group)">
	       <xsl:call-template name="etxRight">
		  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
	       </xsl:call-template>
	    </xsl:for-each>
	 </xsl:variable>
	 <xsl:value-of select="max($xRightArray) + $deltaw"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="composition" match="composition">

  <xsl:call-template name="start_relationship">
     <xsl:with-param name="relname" select="name"/>
  </xsl:call-template>
  <!--
   <xsl:message> composition relationship 
	  <xsl:value-of select="../name"/> .
	  <xsl:value-of select="name"/> 
	 type  <xsl:value-of select="type"/> 
   </xsl:message>
  -->
  <xsl:if test="not(key('EntityTypes',type))">
    <xsl:value-of select="error(QName('http://www.entitymodelling.org/ERmodel', 'missing-entity-type'), type)"/>
  </xsl:if>
  <xsl:variable name="inverse">
     <xsl:if test='inverse'>
       <xsl:for-each select="key('RelationshipBySrcTypeAndName',
			       concat(type,':',inverse)
			      )">
	   <xsl:copy-of select="./child::*"/>
       </xsl:for-each>
     </xsl:if>
  </xsl:variable>

  <xsl:variable name="srcbasex">
     <xsl:for-each select="..">
       <xsl:call-template name="et_x">
	  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="srcbasey">
     <xsl:for-each select="..">
       <xsl:call-template name="et_y">
	  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="srcHeight">
     <xsl:for-each select="..">
	<xsl:call-template name="et_height"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="srcWidth">
     <xsl:for-each select="..">
	<xsl:call-template name="et_width"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbasex">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_x">
	  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbasew">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_width"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="xDestMin">
      <xsl:value-of select="$destbasex + $destbasew*0.05"/>
  </xsl:variable>
  <xsl:variable name="xDestMax">
      <xsl:value-of select="$destbasex + $destbasew*0.98"/>
  </xsl:variable>
  <xsl:variable name="xdestAttach">
    <xsl:if test="diagram/path/destattach">
       <xsl:value-of select="diagram/path/destattach"/>
    </xsl:if>
    <xsl:if test="not(diagram/path/destattach)">
       <xsl:value-of select="0.5"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="xsrcAttach">
    <xsl:if test="diagram/path/srcattach">
       <xsl:value-of select="diagram/path/srcattach"/>
    </xsl:if>
    <xsl:if test="not(diagram/path/srcattach)">
       <xsl:value-of select="position() div (last()+1)"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="srcy">
     <xsl:value-of select="$srcbasey + $srcHeight"/>     
  </xsl:variable>
  <xsl:variable name="srcx0">
     <xsl:value-of select="$srcbasex + $srcWidth * $xsrcAttach"/>
  </xsl:variable>
  <xsl:variable name="destx">
    <xsl:choose>
      <xsl:when test="diagram/path/align/ToSrc">
	<xsl:value-of select="max((min(($srcx0,$xDestMax)),$xDestMin))"/>
      </xsl:when>
      <xsl:otherwise>
          <!--
                 <xsl:message>
                        ET <xsl:value-of select="../name"/>
                        COMPREL <xsl:value-of select="name"/>
                        type <xsl:value-of select="type"/>
                        destbasex <xsl:value-of select="$destbasex"/>
                        destbasew <xsl:value-of select="$destbasew"/>
                        xdestbaseAttach <xsl:value-of select="$xdestAttach"/>
                 </xsl:message>
          -->
	 <xsl:value-of select="$destbasex + $destbasew * $xdestAttach"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="srcx">
    <xsl:choose>
      <xsl:when test="diagram/path/align/ToDest">
	<xsl:value-of select="$destx"/>
      </xsl:when>
      <xsl:when test="name(..)!='absolute'">
	<xsl:value-of select="$srcx0"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$destx"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
   
  <xsl:variable name="desty">
    <xsl:for-each select="key('EntityTypes',type)">
      <xsl:call-template name="et_y">
	 <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable  name="srcMandatory">
      <xsl:value-of select="not(cardinality) 
			    or  cardinality/ExactlyOne 
			    or cardinality/OneOrMore "/>
  </xsl:variable>
  <xsl:variable  name="destMandatory">
      <xsl:value-of select="not($inverse/cardinality) 
			    or  $inverse/cardinality/ExactlyOne 
			    or $inverse/cardinality/OneOrMore "/>
  </xsl:variable>

  <xsl:variable name="srcarmlen">
    <xsl:choose>
      <xsl:when test="diagram/path/srcarmlen">
	<xsl:value-of select="diagram/path/srcarmlen"/>
      </xsl:when>
      <xsl:when test="not(diagram/path/hstep) and ($srcx=$destx or $srcy=$desty)">
        <xsl:value-of select="0"/>
      </xsl:when>
      <xsl:when test="not(name)">
	<xsl:value-of select="$comprelSrcArmLenNotNamed"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$comprelArmLen"/>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name="destarmlen">
     <xsl:choose>
	<xsl:when test="diagram/path/destarmlen">
	   <xsl:value-of select="diagram/path/destarmlen"/>
	</xsl:when>
        <xsl:when test="not(diagram/path/hstep) and ($srcx=$destx or $srcy=$desty)">
           <xsl:value-of select="0"/>
        </xsl:when>
	<xsl:when test="sequence">
	   <xsl:choose>
	      <xsl:when test="identifying">
		 <xsl:value-of select="$comprelDestArmLenDelta
					    + $seq_y_offset + $relid_step"/>  <!-- was seq_y_top_offset -->
	      </xsl:when>
	      <xsl:otherwise>
		 <xsl:value-of select="$comprelDestArmLenDelta 
					    + $seq_y_offset"/>  <!-- was seq_y_top_offset -->
	      </xsl:otherwise>
	   </xsl:choose>
	</xsl:when>
	<xsl:when test="identifying">
	   <xsl:value-of select="$comprelDestArmLenDelta + 
					    + $relid_offset + $relid_step"/>
	</xsl:when>
	<xsl:when test=" cardinality/ZeroOneOrMore or cardinality/OneOrMore ">
	   <xsl:value-of select="$comprelDestArmLenDelta + $relcrowlen"/>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:value-of select="$comprelDestArmLenDelta"/>
	</xsl:otherwise>
     </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="relationship_name">
    <xsl:with-param name="srcx" select="$srcx"/>
    <xsl:with-param name="srcy" select="$srcy"/>
    <xsl:with-param name="xsign">
      <xsl:choose>
	<xsl:when test="diagram/path/label/position/Left">
	   <xsl:value-of select="-1"/>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:value-of select="1"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:if test="$inverse/name">
     <xsl:call-template name="inverse_relationship_name">
	<xsl:with-param name="destx" select="$destx"/>
	<xsl:with-param name="desty" select="$desty"/>
	<xsl:with-param name="xsign">
	<xsl:choose>
	  <xsl:when test="diagram/path/inverse/label/position/Left">
	     <xsl:value-of select="-1"/>
	  </xsl:when>
	  <xsl:otherwise>
	     <xsl:value-of select="1"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:with-param>
     </xsl:call-template>
  </xsl:if>
  <xsl:variable name="path">
      <path>
        <xsl:if test="$srcarmlen > 0">
           <xsl:call-template name="line">
              <xsl:with-param name="x0cm"  select="$srcx"/>
              <xsl:with-param name="y0cm"  select="$srcy"/>
              <xsl:with-param name="x1cm"  select="$srcx"/>
              <xsl:with-param name="y1cm"  select="$srcy+$srcarmlen div 2"/>
              <xsl:with-param name="p_ismandatory" select="$srcMandatory"/>
              <xsl:with-param name="p_isconstructed" select="'false'"/>
           </xsl:call-template>
        </xsl:if>

        <xsl:call-template name="traverse">
           <xsl:with-param name="psrc_x1" select="$srcx" />
           <xsl:with-param name="psrc_y1" select="$srcy + $srcarmlen div 2" />
           <xsl:with-param name="psrc_x2" select="$srcx" />
           <xsl:with-param name="psrc_y2" select="$srcy + $srcarmlen" />
           <xsl:with-param name="pdest_x1" select="$destx" />
           <xsl:with-param name="pdest_y1" select="$desty - $destarmlen div 2" />
           <xsl:with-param name="pdest_x2" select="$destx" />
           <xsl:with-param name="pdest_y2" select="$desty - $destarmlen" />
           <xsl:with-param name="srcsign" select="1" />
           <xsl:with-param name="destsign" select="1" />
           <xsl:with-param name="psrcMandatory" select="$srcMandatory" />
           <xsl:with-param name="pdestMandatory" select="$destMandatory" />
           <xsl:with-param name="p_isconstructed" select="'false'"/>
        </xsl:call-template>

          <xsl:if test="$destarmlen > 0">
           <xsl:call-template name="line">
              <xsl:with-param name="x0cm"  select="$destx"/>
              <xsl:with-param name="y0cm"  select="$desty - $destarmlen div 2"/>
              <xsl:with-param name="x1cm"  select="$destx"/>
              <xsl:with-param name="y1cm"  select="$desty"/>
              <xsl:with-param name="p_ismandatory" select="$destMandatory"/>
              <xsl:with-param name="p_isconstructed" select="'false'"/>
           </xsl:call-template>
        </xsl:if>
      </path>
   </xsl:variable>
   <xsl:call-template name="process_path_then_render">
      <xsl:with-param name="relationship_element_id"> 
            <xsl:call-template name="element_text_div_id"/>
      </xsl:with-param>
      <xsl:with-param name="path" select="$path/path"/>
   </xsl:call-template>

     <xsl:if test="sequence">
     <xsl:choose>
       <xsl:when test="identifying">
     <xsl:call-template name="sequence">
        <xsl:with-param name="x" select="$destx"/>
        <xsl:with-param name="y" select="$desty - 0.05 
                   - $relid_step"/>
     </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
     <xsl:call-template name="sequence">
        <xsl:with-param name="x" select="$destx"/>
        <xsl:with-param name="y" select="$desty - 0.05"/>
     </xsl:call-template>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:if>
  <xsl:if test="identifying and not(pullback)">  
     <xsl:call-template name="identifier_comprel">
   <xsl:with-param name="x" select="$destx"/>
   <xsl:with-param name="y" select="$desty - $relid_offset"/>
   <xsl:with-param name="width" select="$relid_width"/>
     </xsl:call-template>
  </xsl:if>
    <xsl:if test="identifying and pullback">  
     <xsl:call-template name="identifier_comprel">
   <xsl:with-param name="x" select="$destx"/>
   <xsl:with-param name="y" select="$desty - 2 * $relcrowlen"/>
   <xsl:with-param name="width" select="$relcrowwidth"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test="pullback">
    <xsl:call-template name="crowsfoot_down_reflected">
   <xsl:with-param name="x" select="$destx"/>
   <xsl:with-param name="y" select="$desty"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test=" cardinality/ZeroOneOrMore or cardinality/OneOrMore ">
     <xsl:call-template name="crowsfoot_down">
   <xsl:with-param name="x" select="$destx"/>
   <xsl:with-param name="y" select="$desty"/>
     </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="sequence">
   <xsl:param name="x"/>
   <xsl:param name="y"/>
   <xsl:call-template name="sequence_indicator">
     <xsl:with-param name="x0" select="$x + $seq_x_start"/>
     <xsl:with-param name="y0" select="($y - $seq_y_offset)"/>
     <xsl:with-param name="x1" select="$x - $seq_x_sweepout"/>
     <xsl:with-param name="y1" select="($y - $seq_y_offset) + $seq_y_step"/>
     <xsl:with-param name="x2" select="$x + $seq_x_sweepout"/>
     <xsl:with-param name="y2" select="($y - $seq_y_offset) + 2 * $seq_y_step"/>
     <xsl:with-param name="x3" select="$x - $seq_x_start"/>
     <xsl:with-param name="y3" select="($y - $seq_y_offset) + 3 * $seq_y_step"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="dependency_group" match="dependency_group">
  <xsl:param name="xabsHost"/>
  <xsl:param name="yabsHost"/>
  <xsl:param name="widthHost"/>
  <xsl:param name="heightHost"/>
  <xsl:choose>
     <xsl:when test="presentation/sign">
	<xsl:call-template name="dependency_group_reference">
	   <xsl:with-param name="xabsHost" select="$xabsHost"/>
	   <xsl:with-param name="yabsHost" select="$yabsHost"/>
	   <xsl:with-param name="heightHost" select="$heightHost"/>
	   <xsl:with-param name="widthHost" select="$widthHost"/>
	   <xsl:with-param name="sign" select="presentation/sign"/>
	</xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
	<xsl:call-template name="dependency_group_composition">
	   <xsl:with-param name="xabsHost" select="$xabsHost"/>
	   <xsl:with-param name="yabsHost" select="$yabsHost"/>
	   <xsl:with-param name="widthHost" select="$widthHost"/>
	</xsl:call-template>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="dependency_group_composition" match="dependency_group">
  <xsl:param name="xabsHost"/>
  <xsl:param name="yabsHost"/>
  <xsl:param name="widthHost"/>
  <xsl:variable name="midx">
    <xsl:choose>
      <xsl:when test="presentation/x">
	 <xsl:value-of select = "$xabsHost + presentation/x"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select = "$xabsHost + $widthHost div 2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="presentation/w">
	 <xsl:value-of select = "presentation/w"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select = "$widthHost * $arcDefaultWidthRatio"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="yOffset">
    <xsl:choose>
      <xsl:when test="presentation/y">
	 <xsl:value-of select = "presentation/y"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select = "$arcDefaultOffset"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="dep_group_composition_arc">
     <xsl:with-param name="startx" select="$midx - $width div 2"/>
     <xsl:with-param name="endx" select="$midx + $width div 2"/>
     <xsl:with-param name="y" select="$yabsHost - $yOffset"/>
  </xsl:call-template>
</xsl:template>


<xsl:template name="dependency_group_reference" match="dependency_group">
  <xsl:param name="xabsHost"/>
  <xsl:param name="yabsHost"/>
  <xsl:param name="heightHost"/>
  <xsl:param name="widthHost"/>
  <xsl:param name="sign"/>
  <xsl:variable name="x">
    <xsl:choose>
       <xsl:when test="$sign &lt; 0">
	  <xsl:value-of select = "$xabsHost - $arcDefaultOffset"/>
       </xsl:when>
       <xsl:when test="$sign &gt; 0">
	  <xsl:value-of select = "$xabsHost + $widthHost + $arcDefaultOffset"/>
       </xsl:when>
       <xsl:otherwise>
	  SIGN IS WHAT <xsl:value-of select="trace(string($sign),'sign XX')"/>XX
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="midy">
    <xsl:value-of select = "$yabsHost + $heightHost div 2"/>
  </xsl:variable>
  <xsl:variable name="height">
    <xsl:choose>
      <xsl:when test="presentation/h">
	 <xsl:value-of select = "presentation/h"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select = "$heightHost * $arcDefaultWidthRatio"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="dep_group_reference_arc">
     <xsl:with-param name="starty" select="$midy - $height div 2"/>
     <xsl:with-param name="endy" select="$midy + $height div 2"/>
     <xsl:with-param name="x" select="$x"/>
     <xsl:with-param name="sign" select="$sign"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="dep_group_composition_arc">
   <xsl:param name="startx"/>
   <xsl:param name="endx"/>
   <xsl:param name="y"/>
   <xsl:variable name="endwidth">
      <xsl:value-of select="($endx - $startx) div 4"/>
   </xsl:variable>
   <xsl:call-template name="arc">
     <xsl:with-param name="x0">
	<xsl:value-of select="$startx"/>
     </xsl:with-param>
     <xsl:with-param name="x1">
	<xsl:value-of select="$startx + $endwidth"/>
     </xsl:with-param>
     <xsl:with-param name="x2">
	<xsl:value-of select="$endx - $endwidth"/>
     </xsl:with-param>
     <xsl:with-param name="x3">
	<xsl:value-of select="$endx"/>
     </xsl:with-param>
     <xsl:with-param name="y0">
	<xsl:value-of select="$y"/>
     </xsl:with-param>
     <xsl:with-param name="y1">
	<xsl:value-of select="$y - $arcHeight"/>
     </xsl:with-param>
     <xsl:with-param name="y2">
	<xsl:value-of select="$y - $arcHeight"/>
     </xsl:with-param>
     <xsl:with-param name="y3">
	<xsl:value-of select="$y"/>
     </xsl:with-param>
   </xsl:call-template>
</xsl:template>

<xsl:template name="dep_group_reference_arc">
   <xsl:param name="starty"/>
   <xsl:param name="endy"/>
   <xsl:param name="x"/>
   <xsl:param name="sign"/>
   <xsl:variable name="endheight">
      <xsl:value-of select="($endy - $starty) div 4"/>
   </xsl:variable>
   <xsl:call-template name="arc">
     <xsl:with-param name="x0">
	<xsl:value-of select="$x"/>
     </xsl:with-param>
     <xsl:with-param name="x1">
	<xsl:value-of select="$x + ($arcHeight * $sign)"/>
     </xsl:with-param>
     <xsl:with-param name="x2">
	<xsl:value-of select="$x + ($arcHeight * $sign)"/>
     </xsl:with-param>
     <xsl:with-param name="x3">
	<xsl:value-of select="$x"/>
     </xsl:with-param>
     <xsl:with-param name="y0">
	<xsl:value-of select="$starty"/>
     </xsl:with-param>
     <xsl:with-param name="y1">
	<xsl:value-of select="$starty + $endheight"/>
     </xsl:with-param>
     <xsl:with-param name="y2">
	<xsl:value-of select="$endy - $endheight"/>
     </xsl:with-param>
     <xsl:with-param name="y3">
	<xsl:value-of select="$endy"/>
     </xsl:with-param>
   </xsl:call-template>
</xsl:template>

<xsl:template name="reference" match="reference|constructed_relationship">
  <xsl:call-template name="start_relationship">
     <xsl:with-param name="relname" select="name"/>
  </xsl:call-template>


  <xsl:variable name="inverse">
     <xsl:if test='inverse'>
       <xsl:for-each select="key('RelationshipBySrcTypeAndName',
			       concat(type,':',inverse)
			      )">
	   <xsl:copy-of select="./child::*"/>
       </xsl:for-each>
     </xsl:if>
  </xsl:variable>

  <xsl:variable name="destMandatory">
      <xsl:value-of select=" $inverse/cardinality/ExactlyOne 
			    or $inverse/cardinality/OneOrMore "/>
  </xsl:variable>

  <xsl:variable name="srcbasex">
    <xsl:for-each select="..">
      <xsl:call-template name="et_x">
	  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="srcbasey">
     <xsl:for-each select="..">
       <xsl:call-template name="et_y">
	 <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
      </xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name= "srcHeight">
     <xsl:for-each select="..">
	<xsl:call-template name="et_height"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name= "srcWidth">
     <xsl:for-each select="..">
	<xsl:call-template name="et_width"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbasex">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_x">
	  <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
       </xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbasey">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_y">
	   <xsl:with-param name="scheme" select="'ABSOLUTE'"/>
	</xsl:call-template>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbasew">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_width"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="destbaseh">
     <xsl:for-each select="key('EntityTypes',type)">
	<xsl:call-template name="et_height"/>
     </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="yDestMin">
      <xsl:value-of select="$destbasey + $destbaseh*0.1"/>
  </xsl:variable>
  <xsl:variable name="yDestMax">
      <xsl:value-of select="$destbasey + $destbaseh*0.9"/>
  </xsl:variable>
  <xsl:variable name="ydestAttach">
    <xsl:if test="diagram/path/destattach">
       <xsl:value-of select="diagram/path/destattach"/>
    </xsl:if>
    <xsl:if test="not(diagram/path/destattach)">
       <xsl:value-of select="0.5"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="ysrcAttach">
    <xsl:if test="diagram/path/srcattach">
       <xsl:value-of select="diagram/path/srcattach"/>
    </xsl:if>
    <xsl:if test="not(diagram/path/srcattach)">
       <xsl:value-of select = "position() div (last()+1)"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="srcy0">
      <xsl:value-of select="$srcbasey + $srcHeight * $ysrcAttach"/>
  </xsl:variable>
  <xsl:variable name="desty">
    <xsl:choose>
      <xsl:when test="diagram/path/align/ToSrc">
	<xsl:value-of select="max((min(($srcy0,$yDestMax)),$yDestMin))"/>
      </xsl:when>
      <xsl:otherwise>
	 <xsl:value-of select="$destbasey + $destbaseh * $ydestAttach"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="srcy">
    <xsl:choose>
      <xsl:when test="diagram/path/align/ToDest">
	<xsl:value-of select="$desty"/>
      </xsl:when>
      <xsl:when test="name(..)!='absolute'">
	<xsl:value-of select="$srcy0"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$desty"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="srcsign">
    <xsl:choose>
       <xsl:when test="diagram/path/srcsign">
	  <xsl:value-of select="diagram/path/srcsign"/>
       </xsl:when>
       <xsl:when test="$srcbasex &gt; ($destbasex + $destbasew)">
	  <xsl:value-of select="-1"/>
       </xsl:when>
       <xsl:otherwise>
	  <xsl:value-of select="1"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="destsign">
    <xsl:choose>
       <xsl:when test="diagram/path/destsign">
	  <xsl:value-of select="diagram/path/destsign"/>
       </xsl:when>
       <xsl:when test="($srcbasex + $srcWidth) &lt; $destbasex">
	  <xsl:value-of select="-1"/>
       </xsl:when>
       <xsl:otherwise>
	  <xsl:value-of select="1"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="srcx">
     <xsl:value-of select="$srcbasex + $srcWidth * max(($srcsign,0))"/>
  </xsl:variable>
  <xsl:variable name="destx">
     <xsl:value-of select="$destbasex + $destbasew * max(($destsign,0))"/>
  </xsl:variable>

  <xsl:variable name="srcarmlen">
    <xsl:choose>
      <xsl:when test="diagram/path/srcarmlen">
	<xsl:value-of select="diagram/path/srcarmlen"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:choose>
           <xsl:when  test="$srcx=$destx or $srcy=$desty">
	       <xsl:value-of select="0"/>
           </xsl:when>
           <xsl:otherwise>
	       <xsl:value-of select="$refrelsrcarmlen"/>
           </xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name="destarmlen">
    <xsl:choose>
      <xsl:when test="diagram/path/destarmlen">
	<xsl:value-of select="diagram/path/destarmlen"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:choose>
           <xsl:when  test="$srcx=$destx or $srcy=$desty">
	       <xsl:value-of select="0"/>
           </xsl:when>
           <xsl:otherwise>
	        <xsl:value-of select="$refreldestarmlen"/>
           </xsl:otherwise>
         </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>

  <xsl:variable  name="srcMandatory">
      <xsl:value-of 
	    select=" cardinality/ExactlyOne or cardinality/OneOrMore "/>
  </xsl:variable>
  <xsl:call-template name="relationship_name">
     <xsl:with-param name="srcx" select="$srcx"/>
     <xsl:with-param name="srcy" select="$srcy"/>
     <xsl:with-param name="xsign" select="$srcsign"/>
  </xsl:call-template>
  <xsl:if test="$inverse/name">
     <xsl:call-template name="inverse_relationship_name"> 
	<xsl:with-param name="destx" select="$destx"/>
	<xsl:with-param name="desty" select="$desty"/>
	<xsl:with-param name="xsign" select="$destsign"/>   
			       <!-- used to be srcsign HMMMM-->
     </xsl:call-template>
  </xsl:if>

  <xsl:variable name="path">
      <path>
        <xsl:if test="$srcarmlen > 0">         
           <xsl:call-template name="line">
              <xsl:with-param name="x0cm" select="$srcx"/>
              <xsl:with-param name="y0cm" select="$srcy"/>
              <xsl:with-param name="x1cm" 
         		     select="$srcx + ($srcarmlen div 2) * $srcsign"/>
              <xsl:with-param name="y1cm" select="$srcy"/>
              <xsl:with-param name="p_ismandatory" select="$srcMandatory"/>
              <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
           </xsl:call-template>
        </xsl:if>

        <xsl:call-template name="traverse">
      	<xsl:with-param name="psrc_x1" 
      			select="$srcx + ($srcarmlen div 2)*$srcsign" />
      	<xsl:with-param name="psrc_y1" select="$srcy" />
      	<xsl:with-param name="psrc_x2" select="$srcx + $srcarmlen*$srcsign" />
      	<xsl:with-param name="psrc_y2" select="$srcy" />
      	<xsl:with-param name="pdest_x1" 
      			select="$destx + ($destarmlen div 2)*$destsign" />
      	<xsl:with-param name="pdest_y1" select="$desty" />
      	<xsl:with-param name="pdest_x2" 
      			select="$destx + $destarmlen*$destsign" />
      	<xsl:with-param name="pdest_y2" select="$desty" />
      	<xsl:with-param name="srcsign" select="$srcsign" />
      	<xsl:with-param name="destsign" select="$destsign" />
      	<xsl:with-param name="psrcMandatory" select="$srcMandatory" />
      	<xsl:with-param name="pdestMandatory" select="$destMandatory" />
      	<xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
        </xsl:call-template>

          <xsl:if test="$destarmlen > 0 ">
           <xsl:call-template name="line">
              <xsl:with-param name="x0cm" 
                 select="$destx + ($destarmlen div 2) * $destsign"/>
              <xsl:with-param name="y0cm" select="$desty"/>
              <xsl:with-param name="x1cm" select="$destx"/>
              <xsl:with-param name="y1cm" select="$desty"/>
              <xsl:with-param name="p_ismandatory" select="$destMandatory"/>
              <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
           </xsl:call-template>
        </xsl:if>
      </path>
   </xsl:variable>
   <xsl:call-template name="process_path_then_render">
      <xsl:with-param name="relationship_element_id"> 
         <xsl:call-template name="element_text_div_id"/>
      </xsl:with-param>
      <xsl:with-param name="path" select="$path/path"/>
   </xsl:call-template>

  <xsl:if test=" cardinality/ZeroOneOrMore or cardinality/OneOrMore ">
     <xsl:call-template name="crowsfoot_across">
	 <xsl:with-param name="xcm" select="$destx"/>
	 <xsl:with-param name="ycm" select="$desty"/>
	 <xsl:with-param name="sign" select="$destsign"/>
	 <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="not(inverse) 
		 or  $inverse/cardinality/ZeroOneOrMore 
		 or  $inverse/cardinality/OneOrMore ">
     <xsl:call-template name="crowsfoot_across">
	 <xsl:with-param name="xcm" select="$srcx"/>
	 <xsl:with-param name="ycm" select="$srcy"/>
	 <xsl:with-param name="sign" select="$srcsign"/>
	 <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="identifying and not(projection)">  
     <xsl:call-template name="identifier_refrel">
	<xsl:with-param name="x" select="$srcx +($relid_offset  * $srcsign)"/>
	<xsl:with-param name="y" select="$srcy"/>
	<xsl:with-param name="width" select="$relid_width"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test="identifying and projection">  
     <xsl:call-template name="identifier_refrel">
	<xsl:with-param name="x" select="$srcx +(2 * $relcrowlen  * $srcsign)"/>
	<xsl:with-param name="y" select="$srcy"/>
	<xsl:with-param name="width" select="$relcrowwidth"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test="projection">
     <xsl:call-template name="crowsfoot_across_reflected">
	 <xsl:with-param name="xcm" select="$srcx"/>
	 <xsl:with-param name="ycm" select="$srcy"/>
	 <xsl:with-param name="sign" select="$srcsign"/>
	 <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
	 </xsl:call-template>
  </xsl:if>

</xsl:template>


<!-- 06/02/2019 This template originally just called for relationship labels.
     Hence use of $relLabelxSeparation and $relLabelySeparation
	 Now also used for rel ids and scopes
-->
<xsl:template name="drawText">
  <xsl:param name="text"/>
  <xsl:param name="class"/>
  <xsl:param name="px"/>
  <xsl:param name="py"/>
  <xsl:param name="xsign"/>
  <xsl:param name="xAdjustment"/>
  <xsl:param name="ysignDefault"/>
  <xsl:param name="yPosition" as="node()?"/>
  <xsl:param name="yAdjustment"/>
  <xsl:param name="presentation" as="node()?"/>
  <xsl:variable name="ysign">
     <xsl:choose>
	<xsl:when test="$yPosition/Downside">
	   <xsl:value-of select="1"/>
	</xsl:when>
	<xsl:when test="$yPosition/Upside">
	   <xsl:value-of select="-1"/>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:value-of select="$ysignDefault"/>
	</xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name="xLabelAdjustment">
    <xsl:choose>
      <xsl:when test="not($xAdjustment = '')">
	<xsl:value-of select="$xAdjustment"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="0"/>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name="yLabelAdjustment">
    <xsl:choose>
      <xsl:when test="not($yAdjustment = '')">
	<xsl:value-of select="$yAdjustment"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="0"/>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:variable name="y">
     <xsl:value-of select="$py + $yLabelAdjustment
			     + $relLabelLineHeight * max(($ysign,0)) 
			     + $relLabelySeparation  * min(($ysign,0))"/> 
    <!-- <xsl:value-of select="10"/>  -->
  </xsl:variable>
  <xsl:choose>
     <xsl:when test="$presentation/NoSplit">           <!-- added 5 Jan 2016 -->
       <xsl:call-template name="ERtext">
	  <xsl:with-param name="x" select="$px + $xLabelAdjustment + $xsign * $relLabelxSeparation"/>
	  <xsl:with-param name="y" select="$y"/>
	  <xsl:with-param name="xsign" select="$xsign"/>
	  <xsl:with-param name="pText" select="$text"/>
	  <xsl:with-param name="class" select="$class"/>
        </xsl:call-template>
     </xsl:when>
     <xsl:when test="$presentation/None">  
     </xsl:when>
     <xsl:otherwise>
        <xsl:call-template name="spitLines">
           <xsl:with-param name="pText" select="$text"/>
           <xsl:with-param name="x" select="$px + $xLabelAdjustment"/>
           <xsl:with-param name="y" select="$y"/>
           <xsl:with-param name="xsign" select="$xsign"/>
           <xsl:with-param name="ysign" select="$ysign"/>
           <xsl:with-param name="class" select="$class"/>
        </xsl:call-template>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="relationship_name" match="composition|reference">
  <xsl:param name="srcx"/> <!-- this is the point of attachement of the relationship -->
  <xsl:param name="srcy"/>
  <xsl:param name="xsign"/>
  <xsl:call-template name="drawText">
     <xsl:with-param name="text" select="name"/>
	 <xsl:with-param name="class" select="'relname'"/>
     <xsl:with-param name="px" select="$srcx"/>
     <xsl:with-param name="py" select="$srcy"/>
     <xsl:with-param name="xsign" select="$xsign"/>
     <xsl:with-param name="xAdjustment">
	<xsl:value-of select="diagram/path/label/xAdjustment"/>
     </xsl:with-param>
     <xsl:with-param name="ysignDefault" select="+1"/>
     <xsl:with-param name="yPosition" select="diagram/path/label/position"/>
     <xsl:with-param name="yAdjustment">
	<xsl:value-of select="diagram/path/label/yAdjustment"/>
     </xsl:with-param>
     <xsl:with-param name="presentation"
                     select="diagram/path/label/name"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="inverse_relationship_name" match="compostion|reference">
  <xsl:param name="destx"/>
  <xsl:param name="desty"/>
  <xsl:param name="xsign"/>
  <xsl:call-template name="drawText">
     <xsl:with-param name="text" select="inverse" />
     <xsl:with-param name="class" select="'relname'"/>
     <xsl:with-param name="px" select="$destx" />
     <xsl:with-param name="py" select="$desty" />
     <xsl:with-param name="xsign" select="$xsign" />
     <xsl:with-param name="xAdjustment">
	<xsl:value-of select="diagram/path/inverse/label/xAdjustment"/>
     </xsl:with-param>
     <xsl:with-param name="ysignDefault" select="-1"/>
     <xsl:with-param name="yPosition" select="diagram/path/inverse/label/position"/>
     <xsl:with-param name="yAdjustment">
	<xsl:value-of select="diagram/path/inverse/label/yAdjustment"/>
     </xsl:with-param>
     <xsl:with-param name="presentation"
                     select="diagram/path/inverse/label/name"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="spitLines">
   <xsl:param name="pText"/>
   <xsl:param name="x"/>
   <xsl:param name="y"/>
   <xsl:param name="xsign"/>
   <xsl:param name="ysign"/>
   <xsl:param name="class"/>
   <xsl:if test="not($pText='')">
   <xsl:variable name="splitLines">
      <xsl:call-template name="splitLines">
	 <xsl:with-param name="pText" select="$pText"/>
	 <xsl:with-param name="ysign" select="$ysign"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:for-each select="$splitLines/*:line">
      <xsl:call-template name="ERtext">
	 <xsl:with-param name="x" select="$x + $xsign * $relLabelxSeparation"/>
	 <xsl:with-param name="y" select="$y + (position()-1) * $relLabelLineHeight * $ysign"/>
	 <xsl:with-param name="xsign" select="$xsign"/>
	 <xsl:with-param name="pText" select="."/>
	 <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
   </xsl:for-each>
   </xsl:if>
</xsl:template>

<xsl:template name="splitLines">
<!-- in reverse order if ysign is minus one -->
   <xsl:param name="pText"/>
   <xsl:param name="ysign"/>
   <xsl:choose>
      <xsl:when test="contains($pText,'_')">
	 <xsl:if test="$ysign=1">
	    <line>
	       <xsl:value-of select="substring-before($pText,'_')"/>
	    </line>
	 </xsl:if>
	 <xsl:call-template name="splitLines">
	    <xsl:with-param name="pText" 
			    select= "substring-after($pText, '_')"/>
	    <xsl:with-param name="ysign" select="$ysign"/>
	 </xsl:call-template>
	 <xsl:if test="$ysign=-1">
	    <line>
	       <xsl:value-of select="substring-before($pText,'_')"/>
	    </line>
	 </xsl:if>
      </xsl:when>
      <xsl:otherwise>
	 <line>
	    <xsl:value-of select="$pText"/>
	 </line>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="traverse" match="reference|composition|hstep|vstep"> 
  <xsl:param name="psrc_x1"/>
  <xsl:param name="psrc_y1"/>
  <xsl:param name="psrc_x2"/>
  <xsl:param name="psrc_y2"/>
  <xsl:param name="pdest_x1"/>
  <xsl:param name="pdest_y1"/>
  <xsl:param name="pdest_x2"/>
  <xsl:param name="pdest_y2"/>
  <xsl:param name="srcsign"/>
  <xsl:param name="destsign"/>
  <xsl:param name="psrcMandatory"/>
  <xsl:param name="pdestMandatory"/>
  <xsl:param name="p_isconstructed"/>
        <xsl:choose>
          <xsl:when test="vstep|hstep|diagram/path/(vstep|hstep)">
            <xsl:for-each select="vstep|hstep|diagram/path/(vstep|hstep)">
      	<xsl:call-template name="step"> 
      	  <xsl:with-param name="psrc_x1" select="$psrc_x1" />
      	  <xsl:with-param name="psrc_y1" select="$psrc_y1" />
      	  <xsl:with-param name="psrc_x2" select="$psrc_x2" />
      	  <xsl:with-param name="psrc_y2" select="$psrc_y2" />
      	  <xsl:with-param name="pdest_x1" select="$pdest_x1" />
      	  <xsl:with-param name="pdest_y1" select="$pdest_y1" />
      	  <xsl:with-param name="pdest_x2" select="$pdest_x2" />
      	  <xsl:with-param name="pdest_y2" select="$pdest_y2" />
      	  <xsl:with-param name="srcsign" select="$srcsign" />
      	  <xsl:with-param name="destsign" select="$destsign" />
      	  <xsl:with-param name="psrcMandatory" select="$psrcMandatory" />
      	  <xsl:with-param name="pdestMandatory" select="$pdestMandatory" />
      	  <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
      	</xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="completeTraverse"> 
         	  <xsl:with-param name="psrc_x1" select="$psrc_x1" />
         	  <xsl:with-param name="psrc_y1" select="$psrc_y1" />
         	  <xsl:with-param name="psrc_x2" select="$psrc_x2" />
         	  <xsl:with-param name="psrc_y2" select="$psrc_y2" />
         	  <xsl:with-param name="pdest_x1" select="$pdest_x1" />
         	  <xsl:with-param name="pdest_y1" select="$pdest_y1" />
         	  <xsl:with-param name="pdest_x2" select="$pdest_x2" />
         	  <xsl:with-param name="pdest_y2" select="$pdest_y2" />
         	  <xsl:with-param name="psrcMandatory" select="$psrcMandatory" />
         	  <xsl:with-param name="pdestMandatory" select="$pdestMandatory" />
         	  <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

</xsl:template>

<xsl:template name="step" match="vstep|hstep"> 
  <xsl:param name="psrc_x1"/>
  <xsl:param name="psrc_y1"/>
  <xsl:param name="psrc_x2"/>
  <xsl:param name="psrc_y2"/>
  <xsl:param name="pdest_x1"/>
  <xsl:param name="pdest_y1"/>
  <xsl:param name="pdest_x2"/>
  <xsl:param name="pdest_y2"/>
  <xsl:param name="srcsign"/>
  <xsl:param name="destsign"/>
  <xsl:param name="psrcMandatory"/>
  <xsl:param name="pdestMandatory"/>
  <xsl:param name="p_isconstructed"/>

  <xsl:variable name="srcstep_x2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'vstep'">
	<xsl:value-of select="$psrc_x2"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'hstep' and reldim">    <!-- XXX -->
	<xsl:value-of 
	    select="$psrc_x2 + (($pdest_x2 - $psrc_x2) * reldim/src * $srcsign)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$psrc_x2 + absdim/src"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="srcstep_y2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'hstep'">
	<xsl:value-of select="$psrc_y2"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'vstep' and reldim">
	<xsl:value-of select="$psrc_y2 + (($pdest_y2 - $psrc_y2) * reldim/src)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$psrc_y2 + absdim/src"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="deststep_x2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'vstep'">
	<xsl:value-of select="$pdest_x2"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'hstep' and reldim and reldim/dest">   
			<!--not symetric with XXX above -->
	<xsl:value-of select="$pdest_x2 + (($pdest_x2 - $psrc_x2) * reldim/dest * $destsign )"/>  
			 <!-- THIS WRONG VALUE? CHECK $destsign ?-->
      </xsl:when>
      <xsl:when test="local-name(.) = 'hstep' and absdim and absdim/dest">
	<xsl:value-of select="$pdest_x2 - absdim/dest"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$srcstep_x2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="deststep_y2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'hstep'">
	<xsl:value-of select="$pdest_y2"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'vstep' and reldim and reldim/dest">
	<xsl:value-of select="$pdest_y2 - (($pdest_y2 - $psrc_y2) * reldim/dest)"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'vstep' and absdim and absdim/dest">
	<xsl:value-of select="$pdest_y2 - absdim/dest"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$srcstep_y2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="srcstep_x1" select="($psrc_x2 + $srcstep_x2) div 2"/>
  <xsl:variable name="srcstep_y1" select="($psrc_y2 + $srcstep_y2) div 2"/>
  <xsl:variable name="deststep_x1" select="($pdest_x2 + $deststep_x2) div 2"/>
  <xsl:variable name="deststep_y1" select="($pdest_y2 + $deststep_y2) div 2"/>
  <xsl:call-template name="drawAngle"> 
    <xsl:with-param name="pa_x" select="$psrc_x1" />   
    <xsl:with-param name="pa_y" select="$psrc_y1" />
    <xsl:with-param name="pb_x" select="$psrc_x2" />
    <xsl:with-param name="pb_y" select="$psrc_y2" />
    <xsl:with-param name="pc_x" select="$srcstep_x1" />
    <xsl:with-param name="pc_y" select="$srcstep_y1" />
    <xsl:with-param name="p_ismandatory" select="$psrcMandatory" />
    <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
  </xsl:call-template>
  <xsl:call-template name="traverse"> 
    <xsl:with-param name="psrc_x1" select="$srcstep_x1" />
    <xsl:with-param name="psrc_y1" select="$srcstep_y1" />
    <xsl:with-param name="psrc_x2" select="$srcstep_x2" />
    <xsl:with-param name="psrc_y2" select="$srcstep_y2" />
    <xsl:with-param name="pdest_x1" select="$deststep_x1" />
    <xsl:with-param name="pdest_y1" select="$deststep_y1" />
    <xsl:with-param name="pdest_x2" select="$deststep_x2" />
    <xsl:with-param name="pdest_y2" select="$deststep_y2" />
    <xsl:with-param name="srcsign" select="$srcsign" />
    <xsl:with-param name="destsign" select="$destsign" />
    <xsl:with-param name="psrcMandatory" select="$psrcMandatory" />
    <xsl:with-param name="pdestMandatory" select="$pdestMandatory" />
    <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
  </xsl:call-template>
  <xsl:call-template name="drawAngle">
    <xsl:with-param name="pa_x" select="$deststep_x1" />
    <xsl:with-param name="pa_y" select="$deststep_y1" />
    <xsl:with-param name="pc_x" select="$pdest_x1" />   
    <xsl:with-param name="pc_y" select="$pdest_y1" />
    <xsl:with-param name="pb_x" select="$pdest_x2" />
    <xsl:with-param name="pb_y" select="$pdest_y2" />
    <xsl:with-param name="p_ismandatory" select="$pdestMandatory" />
    <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
  </xsl:call-template>

</xsl:template>

<xsl:template name="completeTraverse"> 
  <xsl:param name="psrc_x1"/>
  <xsl:param name="psrc_y1"/>
  <xsl:param name="psrc_x2"/>
  <xsl:param name="psrc_y2"/>
  <xsl:param name="pdest_x1"/>
  <xsl:param name="pdest_y1"/>
  <xsl:param name="pdest_x2"/>
  <xsl:param name="pdest_y2"/>
  <xsl:param name="psrcMandatory"/>
  <xsl:param name="pdestMandatory"/>
  <xsl:param name="p_isconstructed"/>
  <!-- because of how this template is used:
   - all 4 points will be colinear if three of them are-->
  <xsl:variable name="colinear">
      <xsl:call-template name="colinear">
	 <xsl:with-param name="pa_x" select="$psrc_x1" />
	 <xsl:with-param name="pa_y" select="$psrc_y1" />
	 <xsl:with-param name="pb_x" select="$psrc_x2" />
	 <xsl:with-param name="pb_y" select="$psrc_y2" />
	 <xsl:with-param name="pc_x" select="$pdest_x1" />
	 <xsl:with-param name="pc_y" select="$pdest_y1" />
      </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="xIntermediate" select="($psrc_x2 + $pdest_x2) div 2"/>
  <xsl:variable name="yIntermediate" select="($psrc_y2 + $pdest_y2) div 2"/>
  <xsl:variable name="rel_id">
    <xsl:value-of select="(ancestor::reference|ancestor::composition|.)/id"/>
  </xsl:variable>
  <!-- <xsl:message>rel_id: '<xsl:value-of select="$rel_id"/>'</xsl:message> -->
  <xsl:variable name="scope">
    <xsl:if test="$scopeson">
       <xsl:for-each select="(ancestor::reference|.)[self::reference]">
           <!--<xsl:call-template name="get_text_of_scope"/>-->
           <xsl:value-of select="scope_display_text"/>
       </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="not($rel_id='') and key('whereImplemented',concat(ancestor-or-self::reference/concat(../name,':',name),
                                                                  ancestor-or-self::composition/concat(type,':',inverse)
                                                                 )
                                       )">
     <xsl:variable name="relid_xsign">
        <xsl:choose>
           <xsl:when test="$colinear='true'">
                <xsl:value-of select="1"/>
           </xsl:when>
           <xsl:when test="($pdest_y2 - $psrc_y2) div ($pdest_x2 - $psrc_x2) &lt; 0">
                <xsl:value-of select="-1"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="1"/>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:variable>
     <xsl:call-template name="drawText">
      	 <xsl:with-param name="text" select="$rel_id"/>
      	 <xsl:with-param name="class" select="'relid'"/>  <!-- changed from relname 23/09/2022 -->
      	 <xsl:with-param name="px" select="$xIntermediate"/>
      	 <xsl:with-param name="py" select="$yIntermediate"/>
      	 <xsl:with-param name="xsign" select="$relid_xsign"/>
          <xsl:with-param name="xAdjustment">
                  <xsl:value-of select="(ancestor::reference|ancestor::composition|.)/diagram/path/id/label/xAdjustment"/>
          </xsl:with-param>
      	 <xsl:with-param name="ysignDefault" select="-1"/>
          <xsl:with-param name="yPosition"
      	                 select="(ancestor::reference|ancestor::composition|.)/diagram/path/id/label/position"/>
          <xsl:with-param name="yAdjustment">
                  <xsl:value-of select="(ancestor::reference|ancestor::composition|.)/diagram/path/id/label/yAdjustment"/>
         </xsl:with-param>
      	 <xsl:with-param name="presentation"
      	                 select="(ancestor::reference|ancestor::composition|.)/diagram/path/id/label/presentation"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test="not($scope='')">
     <xsl:variable name="relid_xsign">
        <xsl:choose>
           <xsl:when test="$colinear='true'">
                <xsl:value-of select="1"/>
           </xsl:when>
           <xsl:when test="($pdest_y2 - $psrc_y2) div ($pdest_x2 - $psrc_x2) &lt; 0">
                <xsl:value-of select="-1"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="1"/>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:variable>
     <xsl:call-template name="drawText">
   	  <xsl:with-param name="text" select="$scope"/>
   	  <xsl:with-param name="class" select="'scope'"/>
   	  <xsl:with-param name="px" select="$xIntermediate"/>
   	  <!-- <xsl:with-param name="py" select="$yIntermediate + (if(not($rel_id='')) then $relLabelLineHeight else 0)"/>   edited 28/06/2016 -->
   	  <xsl:with-param name="py" select="$yIntermediate + $relLabelLineHeight + 0.15"/>
   	  <xsl:with-param name="xsign" select="$relid_xsign"/>
        <xsl:with-param name="xAdjustment">
               <xsl:value-of select="(ancestor::reference|ancestor::composition|.)/diagram/path/scope/label/xAdjustment"/>
        </xsl:with-param>
   	  <xsl:with-param name="ysignDefault" select="-1"/>
        <xsl:with-param name="yPosition"
   	                  select="(ancestor::reference|ancestor::composition|.)/diagram/path/scope/label/position"/>
        <xsl:with-param name="yAdjustment">
               <xsl:value-of  select="(ancestor::reference|ancestor::composition|.)/diagram/path/scope/label/yAdjustment"/>
        </xsl:with-param>
   	  <xsl:with-param name="presentation"
   	                  select="(ancestor::reference|ancestor::composition|.)/diagram/path/scope/label/name"/>
     </xsl:call-template>
  </xsl:if>
  <xsl:if test="$psrc_x2 != $pdest_x2 or $psrc_y2 != $pdest_y2">  
  <!-- This causes missing line piece bug if verticalSep = 2*comprelArmLen -->
    <xsl:choose>
       <xsl:when test="$colinear='true'">
	  <xsl:call-template name="line">
	     <xsl:with-param name="x0cm" select="$psrc_x1"/>
	     <xsl:with-param name="y0cm" select="$psrc_y1"/>
	     <xsl:with-param name="x1cm" select="$xIntermediate"/>
	     <xsl:with-param name="y1cm" select="$yIntermediate"/>
	     <xsl:with-param name="p_ismandatory" select="$psrcMandatory"/>
	     <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
	  </xsl:call-template>
     <midpoint/>
	  <xsl:call-template name="line">
	     <xsl:with-param name="x0cm" select="$xIntermediate"/>
	     <xsl:with-param name="y0cm" select="$yIntermediate"/>
	     <xsl:with-param name="x1cm" select="$pdest_x1"/>
	     <xsl:with-param name="y1cm" select="$pdest_y1"/>
	     <xsl:with-param name="p_ismandatory" select="$pdestMandatory"/>
	     <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
	  </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
	  <xsl:call-template name="drawAngle">
	    <xsl:with-param name="pa_x" select="$psrc_x1" />
	    <xsl:with-param name="pa_y" select="$psrc_y1" />
	    <xsl:with-param name="pb_x" select="$psrc_x2" />
	    <xsl:with-param name="pb_y" select="$psrc_y2" />
	    <xsl:with-param name="pc_x" select="$xIntermediate" />
	    <xsl:with-param name="pc_y" select="$yIntermediate" />
	    <xsl:with-param name="p_ismandatory" select="$psrcMandatory"/>
	    <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
	  </xsl:call-template>
     <midpoint/>
	  <xsl:call-template name="drawAngle">
	    <xsl:with-param name="pa_x" select="$xIntermediate" />
	    <xsl:with-param name="pa_y" select="$yIntermediate" />
	    <xsl:with-param name="pb_x" select="$pdest_x2" />
	    <xsl:with-param name="pb_y" select="$pdest_y2" />
	    <xsl:with-param name="pc_x" select="$pdest_x1" />
	    <xsl:with-param name="pc_y" select="$pdest_y1" />
	    <xsl:with-param name="p_ismandatory" select="$pdestMandatory"/>
	    <xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
	  </xsl:call-template>
       </xsl:otherwise>
    </xsl:choose>
 </xsl:if>
</xsl:template>

<xsl:template name="colinear">
     <!-- If they are collinear then the area of triangle 
	  formed by these points will be 0.
     -->
   <xsl:param name="pa_x"/>
   <xsl:param name="pa_y"/>
   <xsl:param name="pb_x"/>
   <xsl:param name="pb_y"/>
   <xsl:param name="pc_x"/>
   <xsl:param name="pc_y"/>
   <xsl:variable name="area">
      <xsl:call-template name="triangularArea">
	 <xsl:with-param name="pa_x" select="$pa_x" />
	 <xsl:with-param name="pa_y" select="$pa_y" />
	 <xsl:with-param name="pb_x" select="$pb_x" />
	 <xsl:with-param name="pb_y" select="$pb_y" />
	 <xsl:with-param name="pc_x" select="$pc_x" />
	 <xsl:with-param name="pc_y" select="$pc_y" />
       </xsl:call-template>
   </xsl:variable>
   <!-- test against small number to avoid rounding errors -->
   <xsl:choose>
      <xsl:when test="number($area) &lt; 0.0001">
	    <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
	    <xsl:value-of select="'false'"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="triangularArea">
   <!--
	 Shoelace formula:
	  Area of triangle = 1/2|(xa -xc)(yb-ya) - (xa-xb)(yc-ya)|
   -->
   <xsl:param name="pa_x"/>
   <xsl:param name="pa_y"/>
   <xsl:param name="pb_x"/>
   <xsl:param name="pb_y"/>
   <xsl:param name="pc_x"/>
   <xsl:param name="pc_y"/>
   <xsl:value-of select = "fn:abs(
		( ($pa_x - $pc_x) * ($pb_y - $pa_y) ) 
	      - ( ($pa_x - $pb_x) * ($pc_y - $pa_y) )
			      ) div 2"/>
</xsl:template>

<xsl:template name="output_constructed_relationship" 
	      match="constructed_relationship">
   <xsl:message> in output_constructed_relationship </xsl:message>
   <xsl:variable name="qualified_name">
      <xsl:value-of select="concat(../name,'.',name)"/>
   </xsl:variable>
   <xsl:message> constructed relationship <xsl:value-of select="$qualified_name"/> </xsl:message>
   <xsl:variable name="filename">
      <xsl:value-of 
	     select="concat($filestem,'.',$qualified_name,'.',$fileextension)"/>
   </xsl:variable>
   <xsl:result-document href="{$filename}">
      <xsl:variable name="construct_structure">
	 <xsl:call-template name="print_construct">
	    <xsl:with-param name="x" select="0"/>
	    <xsl:with-param name="y" select="0"/>
	    <xsl:with-param name="requiredWidth" select="'NONE'"/>
	 </xsl:call-template>
      </xsl:variable>
      
     <!--<xsl:message> construct structure<xsl:copy-of select="$construct_structure"/> </xsl:message>-->
      <xsl:variable name="diagramHeight">
	    <xsl:call-template name="heightcm"/>
      </xsl:variable>
      <xsl:variable name="diagramWidth">
	    <xsl:call-template name="widthcm"/>
      </xsl:variable>
      <xsl:call-template name="wrap_diagram">
         <xsl:with-param name="acting_filestem" select="concat($filestem,'.',$qualified_name)"/>
         <xsl:with-param name="content">
            <xsl:call-template name="wrap_constructed_relationship">
               <xsl:with-param name="relationships">
                  <xsl:copy-of 
                       select="$construct_structure/*:result/*:content/*:drawing"/> 
               </xsl:with-param>
               <xsl:with-param name="diagramHeight" select="$diagramHeight"/>
               <xsl:with-param name="diagramWidth" select="$diagramWidth"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="diagramHeight" select="$diagramHeight"/>
         <xsl:with-param name="diagramWidth" select="$diagramWidth"/>
      </xsl:call-template>
   </xsl:result-document> 
</xsl:template>

<xsl:template match="entity_model" mode="pass2">
   <!-- in practice this will just use call-template then no need for mode.-->
   I AM HERE: rel name <xsl:value-of select="constructed_relationship/name"/>
   <xsl:copy-of select="."/>
   <xsl:for-each select="key('ConstructedRelationshipsByQualifiedName',
                             'A.f')">
       LOOKED FOR A.f and... FOUND IT!!!!!!!!!
   </xsl:for-each>
   <xsl:for-each select="key('ConstructedRelationshipsByQualifiedName',
                             'individual.parent')">
       LOOKED FOR individual.parent and... FOUND IT!!!!!!!!!
   </xsl:for-each>
</xsl:template>


<xsl:template name="print_construct" match="constructed_relationship">
  <xsl:param name="x" />
  <xsl:param name="y" />
  <xsl:param name="requiredWidth" />
  <xsl:variable name="childWidthNecessary" as="xs:double *">    
     <xsl:call-template name="childWidthNecessary"/>
  </xsl:variable>
  <xsl:variable name="totalChildWidthActual">
     <xsl:choose>
        <xsl:when test="$requiredWidth = 'NONE'">
           <xsl:value-of select="$childWidthNecessary"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:value-of select="$requiredWidth - 2 * $conrel_box_xmargin"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <result>
     <xsl:attribute name="ns" select="'http://www.entityModelling.org'"/>
     <xsl:attribute name="name" select="name"/>
     <xsl:choose>
        <xsl:when test="aggregate">
           <xsl:variable name="childContent">
              <xsl:for-each select="aggregate/component[1]">
                 <xsl:call-template name="printTailComponentsOfAggregate">
                    <xsl:with-param name="x" select="$x 
                                                     + $conrel_box_xmargin" />
                    <xsl:with-param name="y" 
                                    select="$y + $conrel_yoffset 
                                               + $conrel_height 
                                               + $conrel_boxhead_ymargin" />
                    <xsl:with-param name="requiredWidth" 
                                    select="$totalChildWidthActual" />
                 </xsl:call-template>
              </xsl:for-each>
           </xsl:variable>
           <width>
              <xsl:value-of select="$totalChildWidthActual 
                                    + 2 * $conrel_box_xmargin"/>
           </width>
           <height>
              <xsl:value-of select="$conrel_yoffset + $conrel_height 
                                     + $conrel_boxhead_ymargin 
                                     + $childContent/result/height 
                                     + $conrel_boxtail_ymargin"/>
           </height>
           <content>
              <xsl:call-template name="drawRelationship">
                 <xsl:with-param name="srcx">
                    <xsl:value-of select ="$x + $conrel_xoffset"/>
                 </xsl:with-param>   
                 <xsl:with-param name="destx">
                    <xsl:value-of select ="$x + $totalChildWidthActual 
                                           + 2 * $conrel_box_xmargin 
                                           - $conrel_xoffset"/>
                 </xsl:with-param>   
                 <xsl:with-param name="rely">
                    <xsl:value-of select="$y+$conrel_yoffset 
                                            + $conrel_height div 2"/>
                 </xsl:with-param>   
                 <xsl:with-param name="ylower">
                    <xsl:value-of select="$y + $conrel_yoffset 
                                             + $conrel_height 
                                             + $conrel_boxhead_ymargin 
                                             + $childContent/result/height" />
                 </xsl:with-param>  
              </xsl:call-template>
              <xsl:copy-of select="$childContent/result/content/drawing"/>
           </content>
        </xsl:when>
        <xsl:when test="join">
           <xsl:variable name="childContent">
              <xsl:for-each select="join/component[1]">
                 <xsl:call-template name="printTailComponentsOfJoin">
                    <xsl:with-param name="x" 
                                    select="$x + $conrel_box_xmargin" />
                    <xsl:with-param name="y" 
                                    select="$y + $conrel_yoffset 
                                            + $conrel_height 
                                            + $conrel_boxhead_ymargin" />
                    <xsl:with-param name="requiredWidth" 
                                    select="$totalChildWidthActual" />
                 </xsl:call-template>
              </xsl:for-each>
           </xsl:variable>
           <width>
                 <xsl:value-of select="$totalChildWidthActual 
                                       + 2 * $conrel_box_xmargin"/>
           </width>
           <height>
                 <xsl:value-of select=" $conrel_yoffset + $conrel_height 
                                        + $conrel_boxhead_ymargin 
                                        + $childContent/result/height 
                                        + $conrel_boxtail_ymargin"/> 
                                           <!-- hopefully correct -->
           </height>
           <content>
              <xsl:call-template name="drawRelationship">
                 <xsl:with-param name="srcx">
                    <xsl:value-of select ="$x + $conrel_xoffset"/>
                 </xsl:with-param>   
                 <xsl:with-param name="destx">
                    <xsl:value-of select ="$x + $totalChildWidthActual 
                                              + 2 * $conrel_box_xmargin 
                                              - $conrel_xoffset"/>
                 </xsl:with-param>   
                 <xsl:with-param name="rely">
                    <xsl:value-of select="$y + $conrel_yoffset 
                                             + $conrel_height div 2"/>
                 </xsl:with-param>   
                 <xsl:with-param name="ylower">
                    <xsl:value-of select="$y + $conrel_yoffset 
                                             + $conrel_height 
                                             + $conrel_boxhead_ymargin 
                                             + $childContent/result/height" />
                 </xsl:with-param>   
              </xsl:call-template>
              <xsl:copy-of select="$childContent/result/content/drawing"/> 
           </content>
        </xsl:when>
        <xsl:otherwise>
             UNRECOGNISED
        </xsl:otherwise>
     </xsl:choose> 
   </result>
</xsl:template>

<xsl:template name="drawRelationship" 
              match="constructed_relationship|composition|reference">
   <xsl:param name="srcx"/>
   <xsl:param name="destx"/>
   <xsl:param name="rely"/>
   <xsl:param name="ylower"/>
  <drawing>
  <xsl:variable name="inverse">
     <xsl:if test='inverse'>
       <xsl:for-each select="key('RelationshipBySrcTypeAndName',
                               concat(type,':',inverse)
                              )">
           <xsl:copy-of select="./child::*"/>
       </xsl:for-each>
     </xsl:if>
  </xsl:variable>
  <xsl:variable  name="srcMandatory">
      <xsl:value-of select="not(cardinality) 
                            or  cardinality/ExactlyOne 
                            or cardinality/OneOrMore "/>
  </xsl:variable>
  <xsl:variable  name="destMandatory">
      <xsl:value-of select="not($inverse/cardinality) 
                            or  $inverse/cardinality/ExactlyOne 
                            or $inverse/cardinality/OneOrMore "/>
  </xsl:variable>

   <!-- horizontal relationship line -->
   <xsl:call-template name="line">
      <xsl:with-param name="x0cm" select="$srcx" />
      <xsl:with-param name="y0cm" select="$rely" />
      <xsl:with-param name="x1cm" select="($srcx + $destx) div 2" />
      <xsl:with-param name="y1cm" select="$rely" />
      <xsl:with-param name="p_ismandatory" select="$srcMandatory" />
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
   </xsl:call-template>
   <xsl:call-template name="line">
      <xsl:with-param name="x0cm" select="($srcx + $destx) div 2" />
      <xsl:with-param name="y0cm" select="$rely" />
      <xsl:with-param name="x1cm" select="$destx" />
      <xsl:with-param name="y1cm" select="$rely" />
      <xsl:with-param name="p_ismandatory" select="$destMandatory" />
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
   </xsl:call-template>
   <!-- vertical left hand side -->
   <xsl:call-template name="line">
      <xsl:with-param name="x0cm" select="$srcx" />
      <xsl:with-param name="y0cm" select="$rely - $conrel_height div 2" />
      <xsl:with-param name="x1cm" select="$srcx" />
      <xsl:with-param name="y1cm" select="$rely +  $conrel_height div 2" />
      <xsl:with-param name="p_ismandatory" select="'true'" />
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
   </xsl:call-template>
  <!-- crowsfoot left hand side -->
  <xsl:if test="not(inverse) 
                 or  $inverse/cardinality/ZeroOneOrMore 
                 or  $inverse/cardinality/OneOrMore ">
     <xsl:call-template name="crowsfoot_across">
         <xsl:with-param name="xcm" select="$srcx"/>
         <xsl:with-param name="ycm" select="$rely"/>
         <xsl:with-param name="sign" select="1"/>
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
    </xsl:call-template>
  </xsl:if>
   <!-- src et name -->
   <xsl:call-template name="ERtext"> 
      <xsl:with-param name="x" select="$srcx 
                                       - $conrel_indented_etname_xadjustment"/>
      <xsl:with-param name="y" select="$rely - $conrel_height div 2 
                                             - $conrel_etname_yspacer" />
      <xsl:with-param name="xsign" select="1"/>
      <xsl:with-param name="pText" select="../name"/>  
      <xsl:with-param name="class" select="'reletname'"/>
   </xsl:call-template>
   <!-- vertical right hand side -->
   <xsl:call-template name="line">
      <xsl:with-param name="x0cm" select="$destx" />
      <xsl:with-param name="y0cm" select="$rely - $conrel_height div 2" />
      <xsl:with-param name="x1cm" select="$destx" />
      <xsl:with-param name="y1cm" select="$rely +  $conrel_height div 2" />
      <xsl:with-param name="p_ismandatory" select="'true'" />
      <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
   </xsl:call-template>
  <!-- crowsfoot right hand side -->
  <xsl:if test=" cardinality/ZeroOneOrMore or cardinality/OneOrMore ">
     <xsl:call-template name="crowsfoot_across">
         <xsl:with-param name="xcm" select="$destx"/>
         <xsl:with-param name="ycm" select="$rely"/>
         <xsl:with-param name="sign" select="-1"/>
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
    </xsl:call-template>
  </xsl:if>
   <!-- dest et name -->
   <xsl:call-template name="ERtext"> 
      <xsl:with-param name="x" select="$destx 
                                       + $conrel_indented_etname_xadjustment"/>
      <xsl:with-param name="y" select="$rely  -  $conrel_height div 2 
                                              - $conrel_etname_yspacer" />
      <xsl:with-param name="xsign" select="-1"/>
      <xsl:with-param name="pText" select="type"/>
      <xsl:with-param name="class" select="'reletname'"/>
   </xsl:call-template>
   <!-- relationship name --> 
   <xsl:call-template name="ERtext"> 
      <xsl:with-param name="x" select="$srcx + $conreltext_xoffset"/>
      <xsl:with-param name="y" select="$rely - $conreltext_yoffset"/>
      <xsl:with-param name="xsign" select="1"/>
      <xsl:with-param name="pText" select="name"/>
      <xsl:with-param name="class" select="'relname'"/>
   </xsl:call-template>
   <!-- inverse relationship name --> 
   <xsl:call-template name="ERtext"> 
      <xsl:with-param name="x" select="$destx - $conreltext_xoffset"/>
      <xsl:with-param name="y" select="$rely + $conreltext_yoffset + 0.2"/>
                                                 <!-- need move down 1 line -->
      <xsl:with-param name="xsign" select="-1"/>
      <xsl:with-param name="pText" select="inverse"/>
      <xsl:with-param name="class" select="'relname'"/>
   </xsl:call-template>
   <xsl:if test="$ylower!='NONE'">
      <!-- vertical component line left-->
      <xsl:call-template name="line">
         <xsl:with-param name="x0cm" select="$srcx" />
         <xsl:with-param name="y0cm" select="$rely + $conrel_height div 2" />
         <xsl:with-param name="x1cm" select="$srcx" />
         <xsl:with-param name="y1cm" select="$ylower" />
         <xsl:with-param name="p_ismandatory" select="'false'" />
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
      </xsl:call-template>
      <!-- vertical component line right-->
      <xsl:call-template name="line">
         <xsl:with-param name="x0cm" select="$destx" />
         <xsl:with-param name="y0cm" select="$rely + $conrel_height div 2" />
         <xsl:with-param name="x1cm" select="$destx" />
         <xsl:with-param name="y1cm" select="$ylower" />
         <xsl:with-param name="p_ismandatory" select="'false'" />
         <xsl:with-param name="p_isconstructed" select="string(name()='constructed_relationship')"/>
      </xsl:call-template>
   </xsl:if>
  </drawing>
</xsl:template>


<xsl:template name="printTailComponentsOfAggregate" match="component">
  <xsl:param name="x" />
  <xsl:param name="y" />
  <xsl:param name="requiredWidth" />
  <xsl:variable name="qualified_name">
     <xsl:call-template name="qualified_name"/>
  </xsl:variable>
  <xsl:variable name="thisComponent">
     <xsl:choose>
        <xsl:when test="key('ConstructedRelationshipsByQualifiedName',
                            $qualified_name)">
           <xsl:for-each select="key('ConstructedRelationshipsByQualifiedName',
                                      $qualified_name)">
              <xsl:call-template name="print_construct">
                 <xsl:with-param name="x" select="$x" />
                 <xsl:with-param name="y" select="$y" />
                 <xsl:with-param name="requiredWidth" select="$requiredWidth" />
              </xsl:call-template>
           </xsl:for-each>
           <!-- <constructed/> -->
        </xsl:when>
        <xsl:otherwise>
           <result>
              <width>
                 <xsl:value-of select="$requiredWidth"/>
              </width>
              <height>
                 <xsl:value-of 
                          select="$conrel_height + $conrel_yoffset 
                                               + $conrel_boxtail_ymargin"/>
                     <!-- conrel_boxtail_ymargin? -->
              </height>
              <content>
                 <xsl:for-each select="key('CoreRelationshipsByQualifiedName',
                                           $qualified_name)">
                    <xsl:call-template name="drawRelationship">
                       <xsl:with-param name="srcx" 
                                       select="$x + $conrel_xoffset" />
                       <xsl:with-param name="destx" 
                                       select="$x + $conrel_xoffset 
                                                  + $requiredWidth 
                                                  - 2* $conrel_xoffset" />
                       <xsl:with-param name="rely" 
                                       select="$y + $conrel_yoffset
                                                  + $conrel_height div 2" />
                       <xsl:with-param name="ylower" select="'NONE'"/>
                    </xsl:call-template>
                 </xsl:for-each>
              </content>
           </result>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <!-- now get content of all following siblings -->
  <xsl:variable name="remainder">
     <xsl:choose>
        <xsl:when test="(following-sibling::component)[1]"> 
           <xsl:for-each select="(following-sibling::component)[1]">
              <xsl:call-template name="printTailComponentsOfAggregate">
                 <xsl:with-param name="x" select="$x" /> 
                 <xsl:with-param name="y" 
                                 select="$y + $thisComponent/result/height" /> 
                 <xsl:with-param name="requiredWidth" 
                                 select="$requiredWidth" /> 
              </xsl:call-template>
           </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
              <result>
                  <width>
                       <xsl:value-of select="$requiredWidth"/>
                  </width>
                  <height>
                       <xsl:value-of select="0"/>
                  </height>
                  <content>
                  </content>
            </result>
        </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
   <result>
      <width>
          <xsl:value-of select="$requiredWidth"/>
      </width>
      <height>
          <xsl:value-of select="$thisComponent/result/height 
                                + $remainder/result/height"/>
      </height>
      <content>
          <xsl:copy-of select="$thisComponent/result/content/child::*"/>
          <xsl:copy-of select="$remainder/result/content/child::*"/>
      </content>
   </result>
</xsl:template>

<xsl:template name="qualified_name" match="component">
  <xsl:variable name="srctype">
     <xsl:choose>
        <xsl:when test="src">
           <xsl:value-of select="src"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:value-of select="../../../name"/>
           <!-- not correct for component of join other than first -->
           <!-- must use destination type of previous relationship -->
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="concat($srctype,'.',rel)"/>
</xsl:template>

<xsl:template name="printTailComponentsOfJoin" match="component">
  <xsl:param name="x" />
  <xsl:param name="y" />
  <xsl:param name="requiredWidth" />
  <xsl:variable name="qualified_name">
     <xsl:call-template name="qualified_name"/>
  </xsl:variable>
  <xsl:variable name="thisComponent">
     <xsl:choose>
        <xsl:when test="key('ConstructedRelationshipsByQualifiedName',
                             $qualified_name)">
           <xsl:for-each select="key('ConstructedRelationshipsByQualifiedName',
                                     $qualified_name)">
              <xsl:call-template name="print_construct">
                 <xsl:with-param name="x" select="$x" />
                 <xsl:with-param name="y" select="$y" />
                 <xsl:with-param name="requiredWidth" select="'NONE'" />   
                             <!-- NONE for now; later percent stretch-->
              </xsl:call-template>
           </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
           <result>
              <width>
                 <xsl:value-of select="$conrel_width"/>  
              </width>
              <height>
                 <xsl:value-of select="$conrel_height + $conrel_yoffset 
                                       + $conrel_boxtail_ymargin"/>
              </height>
              <content>
                 <xsl:for-each select="key('CoreRelationshipsByQualifiedName',
                                       $qualified_name)">
                    <xsl:call-template name="drawRelationship">
                       <xsl:with-param name="srcx" 
                                       select="$x + $conrel_xoffset" />
                       <xsl:with-param name="destx" 
                                       select="$x + $conrel_xoffset 
                                               + $conrel_width 
                                               - 2* $conrel_xoffset" />
                                              <!-- later might percent scale 
                                                   up conrel_width -->
                       <xsl:with-param name="rely" 
                                       select="$y + $conrel_yoffset 
                                               + $conrel_height div 2" />
                       <xsl:with-param name="ylower" select="'NONE'"/>
                    </xsl:call-template>
                 </xsl:for-each>
              </content>
           </result>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  <!-- now get content of all following siblings -->
  <xsl:variable name="remainder">
     <xsl:choose>
        <xsl:when test="(following-sibling::component)[1]"> 
           <xsl:for-each select="(following-sibling::component)[1]">
              <xsl:call-template name="printTailComponentsOfJoin">
                 <xsl:with-param name="x" 
                                 select="$x + $thisComponent/result/width" /> 
                 <xsl:with-param name="y" select="$y" /> 
                 <xsl:with-param name="requiredWidth" 
                                 select="'NONE'" /> <!-- NONE for now -->
              </xsl:call-template>
           </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
              <result>
                  <width>
                       <xsl:value-of select="0"/>
                  </width>
                  <height>
                       <xsl:value-of select="0"/>
                  </height>
                  <content>
                  </content>
            </result>
        </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
   <result>
      <xsl:attribute name="ns" select="'http://www.entitymodelling.org'"/>
      <width>
          <xsl:value-of select="$requiredWidth"/>
      </width>
      <height>    
          <xsl:value-of select="max(($thisComponent/result/height, 
                                     $remainder/result/height))"/>
      </height>
      <content>
          <xsl:copy-of select="$thisComponent/result/content/child::*"/>
          <xsl:copy-of select="$remainder/result/content/child::*"/>
      </content>
   </result>
</xsl:template>

<xsl:template name="widthcm" match="constructed_relationship">
    <xsl:variable name="childWidthNecessary" as="xs:double *">
       <xsl:call-template name="childWidthNecessary"/>
    </xsl:variable>
    <xsl:value-of select="$childWidthNecessary + 2 * $conrel_box_xmargin "/>
</xsl:template>

<xsl:template name="heightcm" match="constructed_relationship">
    <xsl:variable name="childHeightNecessary" as="xs:double *">
       <xsl:call-template name="childHeightNecessary"/>
    </xsl:variable>
    <xsl:value-of select="$childHeightNecessary
                          + $conrel_boxhead_ymargin + $conrel_boxtail_ymargin +
                          $conrel_height + $conrel_yoffset"/>
</xsl:template>

<xsl:template name="childWidthNecessary" match="constructed_relationship">
   <xsl:variable name="childWidths" as="xs:double *">
      <xsl:for-each select="(join|aggregate)/component">
         <xsl:variable name="qualified_name">
            <xsl:call-template name="qualified_name"/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="key('ConstructedRelationshipsByQualifiedName',
                                $qualified_name)">
               <xsl:for-each 
                        select="key('ConstructedRelationshipsByQualifiedName',
                                    $qualified_name)">
                  <xsl:call-template name="widthcm"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$conrel_width"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:variable>
   <xsl:choose>
       <xsl:when test="aggregate">
          <xsl:value-of select="max($childWidths)"/>
       </xsl:when>
       <xsl:when test="join">
          <xsl:value-of select="sum($childWidths)"/>
       </xsl:when>
       <xsl:otherwise>
             UNRECOGNISED
       </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="childHeightNecessary" match="constructed_relationship">
   <xsl:variable name="childHeights" as="xs:double *">
      <xsl:for-each select="(join|aggregate)/component">
         <xsl:variable name="qualified_name">
            <xsl:call-template name="qualified_name"/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="key('ConstructedRelationshipsByQualifiedName',
                                $qualified_name)">
               <xsl:for-each 
                         select="key('ConstructedRelationshipsByQualifiedName',
                                 $qualified_name)">
                  <xsl:call-template name="heightcm"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$conrel_height + $conrel_yoffset 
                                     + $conrel_boxhead_ymargin 
                                     + $conrel_boxtail_ymargin"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:variable>
   <xsl:choose>
       <xsl:when test="aggregate">
          <xsl:value-of select="sum($childHeights)"/>
       </xsl:when>
       <xsl:when test="join">
          <xsl:value-of select="max($childHeights)"/>
       </xsl:when>
       <xsl:otherwise>
             UNRECOGNISED
       </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="process_path">
   <xsl:param name="path" as="element(path)"/>
   <xsl:message>Number of lines in path is <xsl:value-of select="count($path/line)"/></xsl:message>
   <xsl:message>Number of lines before midpoint is 
   <xsl:value-of select="count($path/line[not(exists(following-sibling::midpoint))])"/>
   </xsl:message>
      <xsl:message>Number of lines after midpoint is 
   <xsl:value-of select="count($path/line[not(exists(preceding-sibling::midpoint))])"/>
   </xsl:message>
   <path>
      <line>
         <xsl:copy-of select="$path/line[not(exists(preceding-sibling::midpoint))]/
            *[self::mandatory|self::optional|self::point[following-sibling::point|parent::line[not(following-sibling::*[1][self::line])]]]"/>
      </line>
      <line>
         <xsl:copy-of select="$path/line[not(exists(following-sibling::midpoint))]/
            *[self::mandatory|self::optional|self::point[following-sibling::point|parent::line[not(following-sibling::line)]]]"/>
      </line>
   </path>
</xsl:template>

<xsl:template name="process_path_then_render">
   <xsl:param name="relationship_element_id" as="xs:string?"/> 
   <xsl:param name="path" as="element(path)"/>
   <xsl:variable name="processed_path">
       <xsl:call-template name="process_path">
          <xsl:with-param name="path" select="$path"/>
       </xsl:call-template>
   </xsl:variable>

   <!--
   <trace>
      <before>
         <xsl:copy-of select="$path"/>
      </before>
      <after>
         <xsl:copy-of select="$processed_path"/>
      </after>
   </trace>
   -->

   <xsl:call-template name="render_path">
      <xsl:with-param name="relationship_element_id" select="$relationship_element_id"/> 
      <xsl:with-param name="source_to_midpoint" select="$processed_path/path/line[1]"/>    
      <xsl:with-param name="midpoint_to_destination" select="$processed_path/path/line[2]"/>
   </xsl:call-template>

</xsl:template>
</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.diagram.module.xslt--> 

