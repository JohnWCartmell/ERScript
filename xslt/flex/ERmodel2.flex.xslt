<!-- 

-->

<!-- 
*****************
ERmodel2.diagram.xslt
*****************

DESCRIPTION
  Transform an instance of ERmodelERmodel to a diagram.

CHANGE HISTORY
         JC  12-Sept-2019 Created
-->
<xsl:transform version="2.0" 
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:math="http://www.w3.org/2005/xpath-functions/math"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
		xmlns:xlink="http://www.w3.org/TR/xlink" 
		xmlns:svg="http://www.w3.org/2000/svg" 
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
		xmlns="http://www.entitymodelling.org/diagram"
		>

	<xsl:param name="maxiter" />
  <xsl:variable name="maxdepth" as="xs:integer" select="if ($maxiter) then $maxiter else 100" />

  <xsl:param name="debug" />
 <xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />

	<xsl:include href="ERmodel.flex_passone.xslt"/>

	<xsl:include href="ERmodel.flex_recursive_structure_enrichment.xslt"/>

	<xsl:include href="ERmodel.flex_passtwo.xslt"/>

	<xsl:output method="xml" indent="yes" />

	<xsl:template name="main" match="entity_model">
		<xsl:variable name="state">
			<diagram:diagram>
				<xsl:namespace name=""  select="'http://www.entitymodelling.org/diagram'"/>
				<include>
					<filename>shared/text_style_definitions.xml</filename>
				</include>
				<include>
					<filename>shared/shape_style_definitions.xml</filename>
				</include>
				<include>
					<filename>shared/endline_style_definitions.xml</filename>
				</include>
				<default>
					<hmin>0.5</hmin>
					<wmin>0.05</wmin>
					<margin>0.2</margin>
					<padding>0.15</padding>
					<packing>horizontal</packing>
					<text_style>normal</text_style>
					<shape_style>outline</shape_style>
					<debug-whitespace>false</debug-whitespace>
					<end_style>testline</end_style>
				</default>
				<xsl:apply-templates select="absolute|entity_type|group" mode="passzero"/>
				<xsl:apply-templates select="//composition" mode="passzero"/>
			</diagram:diagram>	
		</xsl:variable>

		<xsl:variable name="state">
			<xsl:for-each select="$state/*">
				<xsl:message>initiating passone from <xsl:value-of select="name()"/></xsl:message>
				<xsl:copy>
					<xsl:apply-templates mode="passone"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>	

    <xsl:message>Max depth is <xsl:value-of select="$maxdepth"/> </xsl:message>
    <xsl:variable name="state">
      <xsl:call-template name="recursive_structure_enrichment">
         <xsl:with-param name="interim" select="$state/*"/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
    </xsl:variable>

		<xsl:variable name="state">
			<xsl:for-each select="$state/*">
				<xsl:message>initiating passtwo</xsl:message>
				<xsl:copy>
					<xsl:apply-templates mode="passtwo"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>	
		<xsl:variable name="state">
			<xsl:for-each select="$state/*">
				<xsl:message>initiating passthree</xsl:message>
				<xsl:copy>
					<xsl:apply-templates mode="passthree"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>	
		<xsl:for-each select="$state/*">
			<xsl:copy>
				<xsl:message>initiating passfour</xsl:message>
				<xsl:apply-templates mode="passfour"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="absolute" mode="passzero">
		<xsl:message>passzero</xsl:message>
		<enclosure>
			<id><xsl:value-of select="name"/></id>
			<shape_style>entity_type_outline</shape_style>
			<w>35</w> <!--temporary measures!!!!!!!!!!!!!!!!!***************>-->
			<rx>0.25</rx>
			<ry>0.25</ry>
			<label/>
		</enclosure>
	</xsl:template>

	<xsl:template match="entity_type[diagram:enclosure]" mode="passzero">
		<enclosure>
			<id><xsl:value-of select="name"/></id>
			<shape_style>codedfor_entity_type_outline</shape_style>
			<rx>0.25</rx>  <!-- cheap and cheerful -->
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</enclosure>
	</xsl:template>
	
	<xsl:template match="entity_type[not(diagram:enclosure)]" mode="passzero">
		<enclosure>
			<id><xsl:value-of select="name"/></id>
			<shape_style>entity_type_outline</shape_style>
			<rx>0.25</rx>  <!-- cheap and cheerful -->
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</enclosure>
	</xsl:template>

	<xsl:template match="group[diagram:enclosure]" mode="passzero">
		<enclosure>
			<id><xsl:value-of select="name"/></id>
			<shape_style>codedfor_group_outline</shape_style>
			<!-- <label/>  -->
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</enclosure>
	</xsl:template>
	
		<xsl:template match="group[not(diagram:enclosure)]" mode="passzero">
		<enclosure>
			<id><xsl:value-of select="name"/></id>
			<shape_style>group_outline</shape_style>
			<!-- <label/>  -->
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</enclosure>
	</xsl:template>
	

	<xsl:template match="composition" mode="passzero">
		<route>
			<top_down/>
			<source>
				<id><xsl:value-of select="../name"/></id>
				<annotation><xsl:value-of select="name"/></annotation>
			</source>
			<destination>
				<id><xsl:value-of select="type"/></id>
				<annotation><xsl:value-of select="inverse"/></annotation>
			</destination>			
		</route>
	</xsl:template>

	<xsl:template match="*"/>

</xsl:transform>