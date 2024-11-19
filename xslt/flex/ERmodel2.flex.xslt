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

 <xsl:include href="../ERmodelv1.6.parser.module.xslt"/>

 <xsl:include href="../ERmodel.implementation_of_defaults_enrichment.module.xslt"/>

	<xsl:include href="ERmodel.flex_pass_one_module.xslt"/>

	<xsl:include href="ERmodel.flex_recursive_structure_enrichment.xslt"/>

	<xsl:include href="ERmodel.flex_pass_two_module.xslt"/>

	<xsl:output method="xml" indent="yes" />

<!-- Structure of ERmodel2flex - seven passes in all.
+ parse__conditional - translates the surface model into an instance of the ERmodel metamodel
+ implementation_of_defaults_enrichment - fills in default values
+ passzero -  in source file ERmodel2flex.xslt -
           -  creates a flex diagram structure of enclosures, routes etc.
+ passone  - in source file ERmodel.flex_pass_one_module.xslt
           - derives a derived relationship  abstract : node(2) -> enclosure' derived relationship.
+ recursive_structure_enrichment
            - in source file ERmodel.flex_recursive_structure_enrichment 
            - derives an attribute of enclosures called 'compositionalDepth'.
+ passes one two and three are in source file ERmodel.flex_pass_two.xslt.
+ passtwo    - plants x and y placement expressions for certain enclosures and just y values for some other enclosures
+ passthree  - plants x and y values for enclosures not falling into pass two
+ passfour   - plants a further number of x value placement expression (not sure this needs to be a separate pass)
-->

<!-- ******************** -->
<!-- ******************** -->
<!--     <xsl:template match="@*|node()" mode="copyme">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="copyme"/>
      </xsl:copy>
   </xsl:template> -->
<!-- ******************** -->
<!-- ******************** -->

<xsl:template name="main" match="/">

    <!-- optional parsing of v1.6 -->
    <!-- I found I had to structure it this way to avoid losing context in which included documents are found 
         by saving $docnode. Surely I could keep the document context by keep copying the document node
         all the way the various stages.
      -->

  <xsl:variable name="state" as="document-node()">
       <xsl:choose>
         <xsl:when test="entity_model/@ERScriptVersion='1.6'">
         	<xsl:message>Parsing</xsl:message>
         	     <xsl:copy>
               		<xsl:apply-templates select="." mode="parse__conditional"/>
               	</xsl:copy>
             <!-- cant get assembly to work here -->
             <!-- therefore support newform on included files and on top level files but not both -->
         </xsl:when>
         <xsl:otherwise>
               <xsl:copy-of select="."/> 
          </xsl:otherwise>
       </xsl:choose>
  </xsl:variable>

  <xsl:if test="true()">
      <xsl:message>putting out ER model instance</xsl:message>
      <xsl:result-document href="ERmodel_instance_after_surface_parsed.xml" method="xml">
        <xsl:copy-of select="$state"/>
      </xsl:result-document>
    </xsl:if>

  <xsl:variable name="state" as="document-node()">
		<xsl:message>initiating implementation_of_defaults </xsl:message>
			<xsl:copy>
				<xsl:apply-templates select="$state" mode="implementation_of_defaults_enrichment"/>
			</xsl:copy>
	</xsl:variable>	

	<xsl:variable name="state" as="document-node()">
		<xsl:message>initiating passzero</xsl:message>
			<xsl:copy>
				<xsl:apply-templates select="$state" mode="passzero"/>
			</xsl:copy>
	</xsl:variable>	

	<xsl:variable name="state" as="document-node()">
			<xsl:message>initiating passone</xsl:message>
			<xsl:copy>
				<xsl:apply-templates select="$state" mode="passone"/>
			</xsl:copy>
	</xsl:variable>	

    <xsl:message>Max depth is <xsl:value-of select="$maxdepth"/> </xsl:message>
    <xsl:variable name="state" as="document-node()">
      <xsl:call-template name="recursive_structure_enrichment">
         <xsl:with-param name="interim" select="$state/*"/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
    </xsl:variable>

		<xsl:variable name="state" as="document-node()">
				<xsl:message>initiating passtwo</xsl:message>
				<xsl:copy>
					<xsl:apply-templates select="$state" mode="passtwo"/>
				</xsl:copy>
		</xsl:variable>	

 		<xsl:variable name="state" as="document-node()"> 
				<xsl:message>initiating passthree</xsl:message>
				<xsl:copy>
					<xsl:apply-templates select="$state" mode="passthree"/>
				</xsl:copy>
		</xsl:variable>	

			<xsl:copy>
				<xsl:message>initiating passfour</xsl:message>
				<xsl:apply-templates select="$state" mode="passfour"/>
			</xsl:copy>
	</xsl:template>

	<xsl:template match="entity_model" mode="passzero">
			<diagram:diagram>
				<xsl:namespace name=""  select="'http://www.entitymodelling.org/diagram'"/>
				<method>era</method>
				<xsl:variable name="path" select="replace(concat($ERHOME,'/flexDiagramming/methods/era/xml')
					                                         ,'\\'
					                                         ,'/')"/>
				<include>
					<filename><xsl:text>file:///</xsl:text>
						        <xsl:value-of select="$path"/>
					          <xsl:text>/eraFlexStyleDefinitions.xml</xsl:text>
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
	</xsl:template>



	<xsl:template match="absolute" mode="passzero">
		<xsl:message>passzero</xsl:message>
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>eteven</shape_style>
			<w>15</w> <!--temporary measures!!!!!!!!!!!!!!!!!***************>-->
			<rx>0.25</rx>
			<ry>0.25</ry>
			<label/>
		</xsl:element>
	</xsl:template>

<!--
Where the heck did this come from?
xxxThis commented out Oct2024. B
xxxProbable wrongly! The idea must be that can put
xxxenclosure information inside a logical model 
xxxto copy through

 	<xsl:template match="entity_type[diagram:enclosure]" mode="passzero">
		<xsl:message terminate="yes"> entity type has diagram:enclosure eh?</xsl:message>
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>eteven</shape_style>
			<rx>0.25</rx>  
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group|attribute" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template> -->
<!-- 	was
	<xsl:template match="entity_type[not(diagram:enclosure)]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>eteven</shape_style>
			<rx>0.25</rx>  
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group|attribute" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template> -->

<!-- cleaned up and upgraded change 28-Oct-2024 -->  <!-- except see comment above -->

	<xsl:template match="entity_type" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<xsl:variable name="nestingDepth" as="xs:integer" select="count(ancestor-or-self::entity_type)-1"/>
			<xsl:variable name="iseven" as="xs:boolean" select="($nestingDepth mod 2)=0"/>
			<xsl:variable name="shapestyle" as="xs:string" select="if ($iseven) then 'eteven' else 'etodd'"/>"
			<shape_style><xsl:value-of select="$shapestyle"/></shape_style>
			<rx>0.25</rx>  
			<ry>0.25</ry>
			<label/>
			<xsl:apply-templates select="entity_type|group|attribute" mode="passzero"/>
		</xsl:element>
	</xsl:template>


<!-- PROBABLY NOT REQUIRED -->
		<xsl:template match="group[not(diagram:enclosure)]" mode="passzero">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>group_outline</shape_style>
			<xsl:apply-templates select="entity_type|group" mode="passzero"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
		</xsl:element>
	</xsl:template>

  <xsl:template match="attribute" mode="passzero">
			<label>
        	<text><xsl:text>-</xsl:text>
        	      <xsl:value-of select="name"/>
        	      <xsl:if test="substring(type,string-length(type))='?'">   <!--optional attribute --> <!-- XXXXXXXXXXXXXXXXXXX -->
        	      	<xsl:text>?</xsl:text>
        	      </xsl:if>
        	</text>
      </label>
  </xsl:template>
	
	<xsl:template match="composition" mode="passzero">
		<xsl:variable name="type" select="era:typeFromExtendedType(type)"/>
		<!--XXXX -->
		<route>
			<top_down/>
			<source>
				<id><xsl:value-of select="../name"/></id>
				<annotation><xsl:value-of select="name"/></annotation>
				<line_style>
					 <xsl:choose>
					 	<xsl:when test="(substring(type,string-length(type))='*')
					 		               or (substring(type,string-length(type))='?')">
					 		               <!-- XXXXXXXXXXXXXXX  -->
					 		<xsl:text>dashedline</xsl:text>
					 	</xsl:when>
					 	<xsl:otherwise>
					 		<xsl:text>solidline</xsl:text>
					 	</xsl:otherwise>
					 </xsl:choose>
				</line_style>
			</source>
			<destination>
				<id><xsl:value-of select="$type"/></id>
				<annotation><xsl:value-of select="inverse"/></annotation>
        <xsl:message>Composition Surjective '<xsl:value-of select="surjective"/>'</xsl:message>
				<line_style>
					 <xsl:value-of select="if (surjective='true')
					                       then 'solidline' 
					                       else 'dashedline'
					                       "/>
				</line_style> 
				<!-- need change this next test to deep structure test -->
				<xsl:if test="cardinality/(ZeroOneOrMore|OneOrMore)"> 
					<endline>
						<marker>
						 		<xsl:text>crowsfoot</xsl:text>
						 	</marker>
					</endline>
        </xsl:if>

        <xsl:if test="pullback">  <!-- IS THGIS RIGHHT??? XXXX-->
        	<endline>
						<marker>
						 		<xsl:text>pullback</xsl:text>
						 	</marker>
					</endline>
				</xsl:if>
        <xsl:if test="identifying">  <!--????-->
        	<endline>
						<marker>
						 		<xsl:text>identifying</xsl:text>
						 	</marker>
					</endline>
				</xsl:if>
				<xsl:if test="sequence">
        	<endline>
						<marker>
						 		<xsl:text>squiggle</xsl:text>
						 	</marker>
					</endline>
				</xsl:if>
			</destination>			
		</route>
	</xsl:template>

	<xsl:template match="reference" mode="passzero">
		<!-- <xsl:variable name="type" select="era:typeFromExtendedType(type)"/> -->
		<route>
			<sideways/>
			<source>

      <!-- temporary measures -->
      <right_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </right_side>

				<id><xsl:value-of select="../(if (self::identifying) then ../name else name)"/></id>
				<annotation><xsl:value-of select="name"/></annotation>
				<xsl:message>Reference Surjective '<xsl:value-of select="surjective"/>'</xsl:message>
        <xsl:message>Reference Injective '<xsl:value-of select="injective"/>'</xsl:message>
				<line_style>
					 <xsl:choose>
					 	<xsl:when test="cardinality/(ZeroOrOne|ZeroOneOrMore)">
					 		<xsl:text>dashedline</xsl:text>
					 	</xsl:when>
					 	<xsl:otherwise>
					 		<xsl:text>solidline</xsl:text>
					 	</xsl:otherwise>
					 </xsl:choose>
				</line_style>
				<xsl:if test="identifying">
        	<endline>
						<marker>
						 		<xsl:text>identifying</xsl:text>
						</marker>
				   </endline>
			  </xsl:if>
			  <xsl:if test="//composition/pullback[projection_rel=current()/id]"> <!-- type check needed also -->
        	<endline>
						<marker>
						 		<xsl:text>pullback</xsl:text>
						</marker>
					</endline>
				</xsl:if>
			  <xsl:if test="injective='false'">
        	<endline>
						<marker>
						 		<xsl:text>crowsfoot</xsl:text>
						</marker>
					</endline>
				</xsl:if>
			</source>
			<destination>
      <!-- temporary measures -->
			<left_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </left_side> 
				<line_style>
					 <xsl:value-of select="if (surjective='true')
					                       then 'solidline' 
					                       else 'dashedline'
					                       "/>
				</line_style> 
				<id><xsl:value-of select="type"/></id>
				<annotation><xsl:value-of select="inverse"/></annotation>
			</destination>			
		</route>
	</xsl:template>

	<xsl:template match="*"/>

</xsl:transform>