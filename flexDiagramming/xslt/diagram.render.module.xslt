<!--
****************************
ERmodel2.diagram.module.xslt
****************************

DESCRIPTION
-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/diagram"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
        xmlns:xlink="http://www.w3.org/TR/xlink"
        xpath-default-namespace="http://www.entitymodelling.org/diagram" >

	<xsl:param name="filestem"/>
<xsl:param name="bundle"   as="xs:string?" select="y" />    <!-- inlines required scripts and css styling into the html file -->
<xsl:param name="animate"  as="xs:string?" select="n"/>
<xsl:param name="debug"    as="xs:string?" select="n"/>
<xsl:param name="trace"    as="xs:string?" select="n"/>


<xsl:variable name="bundleOn"  as="xs:boolean" select="$bundle='y'" />
<xsl:variable name="animateOn" as="xs:boolean" select="$animate='y'" />
<xsl:variable name="debugOn"   as="xs:boolean" select="$debug='y'" />
<xsl:variable name="traceOn"   as="xs:boolean" select="$trace='y'" />


<xsl:template  match="/">
	<xsl:variable name="state">
      <xsl:apply-templates select="." mode="elaborate"/>
   </xsl:variable>

   <xsl:variable name="state">
      	<xsl:apply-templates select="$state" mode="recursive_diagram_enrichment"/>>
   </xsl:variable>

   <xsl:if test="$debugOn">
      <xsl:message>putting out recursive enrichment <xsl:value-of select="$state/name()"/></xsl:message>
      <xsl:result-document href="recursive_diagram_enrichment.xml" method="xml">
        <xsl:copy-of select="$state"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:copy>
	   <xsl:for-each select="$state/diagram">
			<xsl:call-template name="entity_model_diagram"/>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

	<xsl:template name="entity_model_diagram" match="/diagram" mode="explicit">
		<xsl:message> entity_model_diagram </xsl:message>
		<xsl:call-template name="wrap_diagram">
			<xsl:with-param name="acting_filestem" select="$filestem"/>
			<xsl:with-param name="content">
				<xsl:call-template name="diagram_content">
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="diagramHeight" select="h"/>
			<xsl:with-param name="diagramWidth" select="w"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="diagram_content" match="diagram">
		<xsl:for-each select="enclosure">
			<xsl:if test="$debug!=''">
				<xsl:text>\ertrace{</xsl:text>
				<xsl:value-of select="trace(string(id),'enclosure')"/>   
				<xsl:text>}</xsl:text>
			</xsl:if>
			<xsl:call-template name="enclosure"/>
		</xsl:for-each>
		<xsl:for-each select="//label">
			<xsl:call-template name="text_element">
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="//point">
			<xsl:call-template name="point"/>
		</xsl:for-each>
		<xsl:call-template name="wrap_relationships">
			<xsl:with-param name="relationships">
				<xsl:call-template name="line_content"/>
			</xsl:with-param>
			<xsl:with-param name="diagramHeight" select="h"/>
			<xsl:with-param name="diagramWidth" select="w"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="enclosure" match="enclosure">
	    <xsl:call-template name="entity_type_content"/>
	</xsl:template>

	<xsl:template name="entity_type_content" match="enclosure">
		<xsl:call-template name="renderenclosure"/>   
		<xsl:for-each select="enclosure">
			<xsl:call-template name="enclosure"/>	
		</xsl:for-each>	
	</xsl:template>

	
	<xsl:template name="line_content" match="diagram">
		<xsl:for-each select="//*[not(self::route)]/path">
			<xsl:call-template name="render_path">
			        <xsl:with-param name="classname" select="'standalonepath'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="//route">
			<xsl:call-template name="render_route"/>
		</xsl:for-each>
	</xsl:template>

</xsl:transform>
