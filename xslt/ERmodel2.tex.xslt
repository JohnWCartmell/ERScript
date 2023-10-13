<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.tex.xslt 
****************************************************************


****************************************************************
15/03/2019 Modify ERText to honour 'class' parameter by planting calls to macros
                                 er<class> in place of vanila ertext.
12-Sep-2022 J.cartmell Implement a 'slideware' parameter. This is only relevant to tex generation 
                        and directs that hierarchical and relational attributes be
                        surrounded by onslide directives. Also attributes not annotated in this case.
22-Sep-2022 J.Cartmell Escape # characters in names since special characters in latex.
                        Modify tex generated for hierarchical and relational attributes so
                        as to make possible the successive revealing of attributes in a Beamer presentation.
11-Oct-2022 J. Cartmell Add all attributes into the scheme of 22-Sept-2022 so that display of attributes
                        can be 'switched off' in a Beamer presentation.

-->

<xsl:transform version="2.0" 
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink" 
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel" >

	<xsl:include href="ERmodel2.diagram.module.xslt"/>

	<xsl:output method="text"/>

	<xsl:variable name="fileextension">
		<xsl:value-of select="'tex'"/>
	</xsl:variable>


	<!-- *********************************** -->
	<!-- latex pstricks specifics start here -->
	<!-- *********************************** -->
	<xsl:template name="newline">
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>

	<xsl:template name="subsection">
		<xsl:param name="heading"/>
		<xsl:call-template name="newline"/>
		<xsl:text>\subsection{</xsl:text>
		<xsl:value-of select="$heading"/>
		<xsl:text>}</xsl:text>
		<xsl:call-template name="newline"/>
	</xsl:template>

	<xsl:template name="wrap_diagram" match="entity_model">
		<xsl:param name="acting_filestem"/>
		<xsl:param name="content"/>
		<xsl:param name="diagramHeight"/>
		<xsl:param name="diagramWidth"/>
		<xsl:text>\begin{erdiagram}{</xsl:text>
		<xsl:value-of select="$diagramHeight"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="$diagramWidth"/>
		<xsl:text>}</xsl:text>
		<xsl:call-template name="newline"/>
		<xsl:if test="$debug!=''">
			<xsl:text>\psgrid</xsl:text>
			<xsl:call-template name="newline"/>
		</xsl:if>
		<xsl:copy-of select="$content"/>
		<xsl:call-template name="newline"/>
		<xsl:text>\end{erdiagram}</xsl:text>
		<xsl:call-template name="newline"/>
	</xsl:template>

	<xsl:template name="wrap_relationships" match="entity_model">   
		<xsl:param name="relationships"/>
		<xsl:param name="diagramHeight"/>  <!-- needed in svg variant - not used in tex -->
		<xsl:param name="diagramWidth"/>  <!-- needed in svg variant - not used in tex -->
		<xsl:call-template name="newline"/>
		<xsl:copy-of select="$relationships"/>
	</xsl:template>

	<xsl:template name="wrap_constructed_relationship" match="entity_model">   
		<xsl:param name="relationships"/>
		<xsl:param name="diagramHeight"/>  <!-- needed in svg variant - not used in tex -->
		<xsl:param name="diagramWidth"/>  <!-- needed in svg variant - not used in tex -->
		<xsl:call-template name="wrap_relationships">
			<xsl:with-param name="relationships" select="$relationships"/>
			<xsl:with-param name="diagramHeight" select="$diagramHeight"/>
			<xsl:with-param name="diagramWidth"  select="$diagramWidth"/> 
		</xsl:call-template>
	</xsl:template>


	<xsl:template name="entity_type_box">
		<xsl:param name="isgroup"/>
		<xsl:param name="iseven"/>
		<xsl:param name="xcm"/>
		<xsl:param name="ycm"/>
		<xsl:param name="wcm"/>
		<xsl:param name="hcm"/>
		<xsl:param name="shape" as="node()?"/>
		<xsl:call-template name="newline"/>
		<!--<xsl:message> entity_type_box isgroup '<xsl:value-of select="$isgroup"/></xsl:message>-->
		<xsl:choose>
			<xsl:when test="$isgroup">
				<xsl:value-of select="'\ergrp{'"/>
			</xsl:when>
			<xsl:when test="$shape/Top">
				<xsl:value-of select="'\erettop{'"/>
			</xsl:when>
			<xsl:when test="$shape/TopLeft">
				<xsl:value-of select="'\erettl{'"/>
			</xsl:when>
			<xsl:when test="$shape/MiddleLeft">
				<xsl:value-of select="'\eretml{'"/>
			</xsl:when>
			<xsl:when test="$shape/BottomLeft">
				<xsl:value-of select="'\eretbl{'"/>
			</xsl:when>
			<xsl:when test="$shape/TopRight">
				<xsl:value-of select="'\erettr{'"/>
			</xsl:when>
			<xsl:when test="$shape/MiddleRight">
				<xsl:value-of select="'\eretmr{'"/>
			</xsl:when>
			<xsl:when test="$shape/BottomRight">
				<xsl:value-of select="'\eretbr{'"/>
			</xsl:when>
			<xsl:when test="$shape/Bottom">
				<xsl:value-of select="'\eretbtm{'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'\eret{'"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="round($xcm*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round(($ycm + $hcm)*1000) div 1000"/> 
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(($xcm + $wcm)*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($ycm*1000) div 1000"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="not($shape)">
			<xsl:text>{</xsl:text>
			<xsl:value-of select="$etframearc"/>
			<xsl:text>}{</xsl:text>
			<xsl:choose>
				<xsl:when test="$iseven">
					<xsl:text>1</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>}</xsl:text>
		</xsl:if>
	</xsl:template>

	<!--
<xsl:template  name="entity_type_name" match="entity_type">
  <xsl:param name="xcm"/>
  <xsl:param name="ycm"/>
  <xsl:text>\eretname{</xsl:text>
  <xsl:value-of select="round($xcm*1000) div 1000"/>
  <xsl:text>}{</xsl:text>
  <xsl:value-of select="-round((($ycm - 0.1))*1000) div 1000"/>
  <xsl:text>}{</xsl:text>
  <xsl:value-of select="name" />
  <xsl:text>}</xsl:text>
</xsl:template>
-->

	<xsl:template name="attribute" match="attribute">
		<xsl:param name="xcm"/>
		<xsl:param name="ycm"/>
		<xsl:param name="annotation"/>
		<xsl:param name="deprecated"/>
		<!--<xsl:param name="slideware"/>-->
		<xsl:call-template name="newline"/>
		<xsl:choose>   <!-- 22/09/2022 modified to distinguish attributes in realtional and hierarchical models -->
			<xsl:when test="count(implementationOf) = 2">  <!-- added 26/10/2022 so that a hand coded example
				                                                      shlaerMellorDeptStudentProfessor3 
				                                                       can be made to work.
				                                                   (Even though this example doesn't meet schema in that
				                                                   in metamodel implementationOf is specified as single valued)
				                                                   This example is better at documenting ALL implmented relationships
				                                              -->
				<xsl:text>\erRelationalAttribute{</xsl:text>
			</xsl:when>
			<xsl:when test="implementationOf and key('ReferenceBySrcTypeAndName',concat(../name,':',implementationOf/rel))">

				<xsl:text>\erHierarchicalAttribute{</xsl:text>
			</xsl:when>
			<xsl:when test="implementationOf">
				<xsl:text>\erRelationalAttribute{</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>\erCoreAttribute{</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="round($xcm*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round((($ycm - 0.1))*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="optional">
				<xsl:text>0</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="identifying">
				<xsl:text>0</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="replace(replace(name, '_', '\\textunderscore '),'#','\\#')" /> <!-- 12/09/2022-->
	                                                                                       <!-- 22/09/2022-->
		<xsl:text>}{</xsl:text>                                                              <!-- 22/09/2022-->
		<xsl:value-of select="$annotation" />
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="wrap_entity_type">
		<xsl:param name="content"/>
		<xsl:copy-of select="$content"/>
	</xsl:template>

	<xsl:template name="entity_type_or_group_description" match="entity_type">
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
		<xsl:text>\errelseq{</xsl:text>
		<xsl:value-of select="round($x0*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y0)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y0*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x1*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y1)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y1*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x2*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y2)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y2*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x3*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y3)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y3*1000) div 1000"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="start_relationship">
		<xsl:param name="relname"/>
		<xsl:call-template name="newline"/>
		<xsl:text>% relationship </xsl:text> 
		<xsl:value-of select="$relname"/>
		<xsl:call-template name="newline"/>
	</xsl:template>

	<xsl:template name="crowsfoot_down">
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:text>\ercrowfoot{</xsl:text>
		<xsl:value-of select="round($x*1000) div 1000"/>                    <!-- x0 -->
		<xsl:text>}{</xsl:text>  
		<xsl:value-of select="-round(($y - $relcrowlen)*1000) div 1000"/>   <!-- y0 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(($x - $relcrowwidth)*1000) div 1000"/>  <!-- x11 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y11 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x*1000) div 1000"/>                    <!-- x12  -->
		<xsl:text>}{</xsl:text> 
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y12  -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(($x + $relcrowwidth)*1000) div 1000"/>  <!-- x13  -->
		<xsl:text>}{</xsl:text> 
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y13  -->
		<xsl:text>}{0}</xsl:text>
	</xsl:template>

	<xsl:template name="crowsfoot_up">
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:text>\ercrowfoot{</xsl:text>
		<xsl:value-of select="round($x*1000) div 1000"/>                    <!-- x0 -->
		<xsl:text>}{</xsl:text>  
		<xsl:value-of select="-round(($y + $relcrowlen)*1000) div 1000"/>   <!-- y0 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(($x - $relcrowwidth)*1000) div 1000"/>  <!-- x11 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y11 -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x*1000) div 1000"/>                    <!-- x12  -->
		<xsl:text>}{</xsl:text> 
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y12  -->
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(($x + $relcrowwidth)*1000) div 1000"/>  <!-- x13  -->
		<xsl:text>}{</xsl:text> 
		<xsl:value-of select="-round($y*1000) div 1000"/>                   <!-- y13  -->
		<xsl:text>}{0}</xsl:text>
	</xsl:template>

	<xsl:template name="crowsfoot_down_reflected"><!-- JC 05/02/2019 -->
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:call-template name="crowsfoot_down">
			<xsl:with-param name="x" select="$x"/>
			<xsl:with-param name="y" select="$y"/>
		</xsl:call-template>
		<xsl:call-template name="crowsfoot_up">
			<xsl:with-param name="x" select="$x"/>
			<xsl:with-param name="y" select="$y - 2 * $relcrowlen"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="crowsfoot_across">
		<xsl:param name="xcm"/>
		<xsl:param name="ycm"/>
		<xsl:param name="sign"/>
		<xsl:param name="p_isconstructed"/>
		<xsl:text>\ercrowfoot{</xsl:text>
		<xsl:value-of select="round(($xcm + $relcrowlen * $sign) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($ycm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($xcm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round(($ycm - $relcrowwidth) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($xcm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($ycm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($xcm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round(($ycm + $relcrowwidth) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="$p_isconstructed = 'true'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="crowsfoot_across_reflected"> <!--JC 05/02/2019 -->
		<xsl:param name="xcm"/>
		<xsl:param name="ycm"/>
		<xsl:param name="sign"/>
		<xsl:param name="p_isconstructed"/>
		<xsl:call-template name="crowsfoot_across">
			<xsl:with-param name="xcm" select="$xcm"/>
			<xsl:with-param name="ycm" select="$ycm"/>
			<xsl:with-param name="sign" select="$sign"/>
			<xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
		</xsl:call-template>
		<xsl:call-template name="crowsfoot_across">
			<xsl:with-param name="xcm" select="$xcm + 2 * $sign * $relcrowwidth"/>
			<xsl:with-param name="ycm" select="$ycm"/>
			<xsl:with-param name="sign" select="$sign * -1"/>
			<xsl:with-param name="p_isconstructed" select="$p_isconstructed"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="identifier_comprel">
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:param name="width"/>
		<xsl:text>\eridcomprel{</xsl:text>
		<xsl:value-of select="$x - $width"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="$x + $width"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-($y)"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="identifier_refrel">
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:param name="width"/>
		<xsl:text>\eridrefrel{</xsl:text>
		<xsl:value-of select="$x"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-($y - $width)"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-($y + $width)"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

  <xsl:template name="render_hitarea">
      <xsl:param name="rel_id" as="xs:string"/>
      <xsl:param name="line" as="element(line)"/>
      <!-- no action - no hit area representation  in tex -->
   </xsl:template>
                   
  <xsl:template name="render_half_of_relationship" 
                match="constructed_relationship|composition|reference">
      <xsl:param name="line" as="element(line)"/>
      <xsl:param name="is_mandatory" as="xs:boolean"/>
<xsl:message>render_half  is_mandatory'<xsl:value-of select="$is_mandatory"/>'</xsl:message>
      <xsl:for-each select="$line/point[exists(following-sibling::point)]">
      	<xsl:message> call line_section</xsl:message>
	      <xsl:call-template name="line_section">
	      	<xsl:with-param name="x0cm" select="substring(x,1,5)"/>
					<xsl:with-param name="y0cm" select="substring(y,1,5)"/>
					<xsl:with-param name="x1cm" select="substring(following-sibling::point[1]/x,1,5)" />
					<xsl:with-param name="y1cm" select="substring(following-sibling::point[1]/y,1,5)"/>
					<xsl:with-param name="p_ismandatory" select="$is_mandatory"/>
				</xsl:call-template>
      </xsl:for-each>
      <xsl:message>end render_half</xsl:message>
  </xsl:template>

	<xsl:template name="line_section" match="constructed_relationship|composition|reference">   
		<xsl:param name="x0cm"/>
		<xsl:param name="y0cm"/>
		<xsl:param name="x1cm"/>
		<xsl:param name="y1cm"/>
		<xsl:param name="p_ismandatory" as="xs:boolean"/>
		<xsl:text>\errelarm{</xsl:text>	
		<xsl:value-of select="round(number($x0cm) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y0cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round(number($y0cm) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round(number($x1cm) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y1cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round(number($y1cm) *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="$p_ismandatory">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="self::constructed_relationship">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}</xsl:text>
	</xsl:template>

<!-- unchanged -->
	<xsl:template name="line">
		<xsl:param name="x0cm"/>
		<xsl:param name="y0cm"/>
		<xsl:param name="x1cm"/>
		<xsl:param name="y1cm"/>
		<xsl:param name="p_ismandatory"/>
		<xsl:param name="p_isconstructed"/>
		<xsl:message>template "line"</xsl:message>
		<xsl:text>\errelarm{</xsl:text>
		<xsl:value-of select="round($x0cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y0cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round($y0cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x1cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y1cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round($y1cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="$p_ismandatory = 'true'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="$p_isconstructed = 'true'">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="arrow">
		<xsl:param name="x0cm"/>
		<xsl:param name="y0cm"/>
		<xsl:param name="x1cm"/>
		<xsl:param name="y1cm"/>
		<xsl:text>\erarrow{</xsl:text>
		<xsl:value-of select="round($x0cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y0cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round($y0cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x1cm *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y1cm) *1000) div 1000"/> -->
		<xsl:value-of select="-round($y1cm *1000) div 1000"/>
		<xsl:text>}</xsl:text>
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

		<xsl:text>\erarc{</xsl:text>
		<xsl:value-of select="round($x0*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y0)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y0*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x1*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y1)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y1*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x2*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y2)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y2*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($x3*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<!--<xsl:value-of select="round(($diagramHeight - $y3)*1000) div 1000"/> -->
		<xsl:value-of select="-round($y3*1000) div 1000"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="ERtext"> 
		<xsl:param name="x"/>
		<xsl:param name="y"/>
		<xsl:param name="xsign"/>
		<xsl:param name="pText"/>
		<xsl:param name="class"/>
		<xsl:variable name="text-anchor">
			<xsl:choose>
				<xsl:when test="$xsign = 1">
					<xsl:text>l</xsl:text>
				</xsl:when>
				<xsl:when test="$xsign = -1">
					<xsl:text>r</xsl:text>
				</xsl:when>
				<xsl:when test="$xsign = 0">
					<xsl:text></xsl:text>
				</xsl:when>
				<xsl:otherwise> 
					<xsl:message>Unexpected xsign</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="macroname" select="concat('\er',$class)"/>
		<xsl:value-of select="$macroname"/>
		<xsl:text>{</xsl:text>
		<xsl:value-of select="round($x*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($y *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="$text-anchor"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="replace(replace(replace($pText,'\^','\\textasciicircum '),'~','\\textasciitilde '), '_', '\\textunderscore ')"/>   <!-- escaping underscore -->
		<xsl:text>}</xsl:text>
	</xsl:template>

<!--
	<xsl:template name="drawAngle"> 
		<xsl:param name="pa_x"/>
		<xsl:param name="pa_y"/>
		<xsl:param name="pb_x"/>
		<xsl:param name="pb_y"/>
		<xsl:param name="pc_x"/>
		<xsl:param name="pc_y"/>
		<xsl:param name="p_ismandatory"/>
		<xsl:param name="p_isconstructed"/>
		<xsl:text>\errelangle{</xsl:text>
		<xsl:value-of select="round($pa_x*1000)div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($pa_y *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($pb_x*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($pb_y *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="round($pc_x*1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:value-of select="-round($pc_y *1000) div 1000"/>
		<xsl:text>}{</xsl:text>
		<xsl:if test="$p_ismandatory = 'false'">0</xsl:if>
		<xsl:if test="$p_ismandatory = 'true'">1</xsl:if>
		<xsl:text>}{</xsl:text>
		<xsl:if test="$p_isconstructed = 'false'">0</xsl:if>
		<xsl:if test="$p_isconstructed = 'true'">1</xsl:if>
		<xsl:text>}</xsl:text>
	</xsl:template>
-->


	<xsl:template name="titlebox" saxon:trace="yes" xmlns:saxon="http://icl.com/saxon">
		<xsl:param name="xcm"/>
		<xsl:param name="ycm"/>
		<xsl:param name="wcm"/>
		<xsl:param name="hcm"/>
		<xsl:param name="title"/>
		<!-- introduced in svg and not yet implmented in tex -->
	</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.tex.xslt--> 

