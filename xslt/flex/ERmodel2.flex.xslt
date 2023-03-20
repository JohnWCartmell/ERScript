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
		xmlns:file="http://expath.org/ns/file"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"       
		xmlns:xlink="http://www.w3.org/TR/xlink" 
		xmlns:svg="http://www.w3.org/2000/svg" 
		xmlns:era="http://www.entitymodelling.org/ERmodel"
		xmlns:diagram="http://www.entitymodelling.org/diagram" 
		xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
		xmlns="http://www.entitymodelling.org/diagram"
		>
	<xsl:param name="ERHOME" as="xs:string" />
	<xsl:param name="maxiter" />
  <xsl:variable name="maxdepth" as="xs:integer" select="if ($maxiter) then $maxiter else 100" />

  <xsl:param name="debug" />
 <xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />

 <xsl:include href="../ERmodel.functions.module.xslt"/>

	<xsl:include href="ERmodel.flex_pass_one_module.xslt"/>

	<xsl:include href="ERmodel.flex_recursive_structure_enrichment.xslt"/>

	<xsl:include href="ERmodel.flex_pass_two_module.xslt"/>

	<xsl:output method="xml" indent="yes" />

	<xsl:template name="main" match="entity_model">
		<xsl:variable name="state">
			<diagram:diagram>
				<xsl:namespace name=""  select="'http://www.entitymodelling.org/diagram'"/>
				<xsl:variable name="path" select="replace(concat($ERHOME,'/flexDiagramming/methods/era/xml')
					                                         ,'\\'
					                                         ,'/')"/>
				<include>
					<filename><xsl:text>file:///</xsl:text>
						        <xsl:value-of select="$path"/>
					          <xsl:text>/text_style_definitions.xml</xsl:text>
				 </filename>
				</include>
				<include>
					<filename><xsl:text>file:///</xsl:text>
						        <xsl:value-of select="$path"/>
					          <xsl:text>/shape_style_definitions.xml</xsl:text>
					</filename>
				</include>
				<include>
					<filename><xsl:text>file:///</xsl:text>
						        <xsl:value-of select="$path"/>
					          <xsl:text>/endline_style_definitions.xml</xsl:text>
					</filename>
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
				<xsl:apply-templates select="//reference" mode="passzero"/>
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

<!--
			<xsl:for-each select="$state/*">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		-->

  <xsl:if test="true()">
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

		</xsl:if>
	</xsl:template>


	<xsl:template match="absolute" mode="passzero">
		<xsl:message>passzero</xsl:message>
		<xsl:element name="enclosure">
			<id><xsl:value-of select="@name"/></id>
			<shape_style>entity_type_outline</shape_style>
			<w>15</w> <!--temporary measures!!!!!!!!!!!!!!!!!***************>-->
			<rx>0.25</rx>
			<ry>0.25</ry>
			<label/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="entity_type[diagram:enclosure]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="@name"/></id>
			<shape_style>codedfor_entity_type_outline</shape_style>
			<rx>0.25</rx>  <!-- cheap and cheerful -->
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="entity_type[not(diagram:enclosure)]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="@name"/></id>
			<shape_style>entity_type_outline</shape_style>
			<rx>0.25</rx>  <!-- cheap and cheerful -->
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="group[diagram:enclosure]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="@name"/></id>
			<shape_style>codedfor_group_outline</shape_style>
			<!-- <label/>  -->
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template>
	
		<xsl:template match="group[not(diagram:enclosure)]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="@name"/></id>
			<shape_style>group_outline</shape_style>
			<!-- <label/>  -->
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template>
	

	<xsl:template match="composition" mode="passzero">
		<xsl:variable name="type" select="era:typeFromExtendedType(@type)"/>
		<route>
			<top_down/>
			<source>
				<id><xsl:value-of select="../@name"/></id>
				<annotation><xsl:value-of select="@name"/></annotation>
				<linestyle>
					 <xsl:choose>
					 	<xsl:when test="(substring(@type,string-length(@type))='*')
					 		               or (substring(@type,string-length(@type))='?')">
					 		<xsl:text>dashedline</xsl:text>
					 	</xsl:when>
					 	<xsl:otherwise>
					 		<xsl:text>solidline</xsl:text>
					 	</xsl:otherwise>
					 </xsl:choose>
				</linestyle>
			</source>
			<destination>
				<id><xsl:value-of select="$type"/></id>
				<annotation><xsl:value-of select="@inverse"/></annotation>
				<xsl:if test="(substring(@type,string-length(@type))='*')
					 		               or (substring(@type,string-length(@type))='+')"> 		
					<endline>
						<style>
						 		<xsl:text>crowsfoot</xsl:text>
						 	</style>
					</endline>
        </xsl:if>
        <xsl:if test="pullback">
        	<endline>
						<style>
						 		<xsl:text>pullback</xsl:text>
						 	</style>
					</endline>
				</xsl:if>
        <xsl:if test="//identifying/context/../../@name=$type">
        	<endline>
						<style>
						 		<xsl:text>identifying</xsl:text>
						 	</style>
					</endline>
				</xsl:if>
				<xsl:if test="sequence">
        	<endline>
						<style>
						 		<xsl:text>squiggle</xsl:text>
						 	</style>
					</endline>
				</xsl:if>

			</destination>			
		</route>
	</xsl:template>


	<xsl:template match="reference" mode="passzero">
		<xsl:variable name="type" select="era:typeFromExtendedType(@type)"/>
		<route>
			<sideways/>
			<source>

      <!-- temporary measures -->
      <right_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </right_side>

				<id><xsl:value-of select="../@name"/></id>
				<annotation><xsl:value-of select="@name"/></annotation>
				<linestyle>
					 <xsl:choose>
					 	<xsl:when test="(substring(@type,string-length(@type))='*')
					 		               or (substring(@type,string-length(@type))='?')">
					 		<xsl:text>dashedline</xsl:text>
					 	</xsl:when>
					 	<xsl:otherwise>
					 		<xsl:text>solidline</xsl:text>
					 	</xsl:otherwise>
					 </xsl:choose>
				</linestyle>
				<xsl:if test="parent::identifying">
        	<endline>
						<style>
						 		<xsl:text>identifying</xsl:text>
						</style>
				   </endline>
			  </xsl:if>
			  <xsl:if test="//composition/pullback[projection_rel=current()/id]"> <!-- type check needed also -->
        	<endline>
						<style>
						 		<xsl:text>pullback</xsl:text>
						 	</style>
					</endline>
				</xsl:if>
			</source>
			<destination>
      <!-- temporary measures -->
			<left_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </left_side>


				<id><xsl:value-of select="$type"/></id>
				<annotation><xsl:value-of select="@inverse"/></annotation>
			</destination>			
		</route>
	</xsl:template>

	<xsl:template match="*"/>

</xsl:transform>