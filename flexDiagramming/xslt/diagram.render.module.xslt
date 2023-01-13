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
	<xsl:param name="debug"/>
	<xsl:param name="noscopes"/>

	<!-- <xsl:include href="ERmodel.functions.module.xslt"/> -->

	<xsl:template name="entity_model_diagram" match="/diagram">
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
		<xsl:call-template name="wrap_entity_type">
			<xsl:with-param name="content">
				<xsl:call-template name="entity_type_content"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="entity_type_content" match="enclosure">
		<xsl:call-template name="renderenclosure"/>   
		<xsl:for-each select="enclosure">
			<xsl:call-template name="enclosure"/>	
		</xsl:for-each>	
		<!--<xsl:call-template name="enclosure_id"/>-->
	</xsl:template>

	<xsl:template name="enclosure_id">
		<xsl:param name="xsign" />
		<xsl:call-template name="ERtext">
			<xsl:with-param name="x" select="abs/x + 0.1" />
			<xsl:with-param name="y" select="abs/y + 0.1 "/>
			<xsl:with-param name="xsign" select="1"/>
			<xsl:with-param name="pText" select="id"/>
			<xsl:with-param name="class" select="'etname'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="line_content" match="diagram">
		<xsl:for-each select="//path">
			<xsl:call-template name="path">
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

</xsl:transform>
