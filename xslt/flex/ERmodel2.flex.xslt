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
 <xsl:include href="../ERmodel.assembly.module.xslt"/>
 <xsl:include href="../ERmodel.consolidate.module.xslt"/>
 <xsl:include href="ERmodel.implementation_of_defaults_enrichment.module.xslt"/>

<!--
 <xsl:include href="new.flex.recursive_enrichment.module.xslt"/>
 <xsl:include href="ERmodel.flex_recursive_structure_enrichment.xslt"/>
 <xsl:include href="flex.second_recursive_enrichment.module.xslt"/> -->



<xsl:include href="tactics_0_enrichment.module.xslt"/>
<xsl:include href="tactics_1_recursive_enrichment.module.xslt"/>
<xsl:include href="tactics_2_parameterised_enrichment.module.xslt"/>
<xsl:include href="tactics_3_recursive_enrichment.module.xslt"/>
<xsl:include href="tactics_4_enrichment.module.xslt"/>
<xsl:include href="tactics_4_x_rules.module.xslt"/>
<xsl:include href="tactics_4_y_rules.module.xslt"/>


<!--  <xsl:include href="ERmodel.flex_pass_two_module.xslt"/> -->

	<xsl:output method="xml" indent="yes" />

<!-- ERmodel2flex - multiple  passes:
+ parse__conditional - translates the surface model into an instance of the ERmodel metamodel
+ assemble
+ consolidate
+ implementation_of_defaults_enrichment - fills in default values
+ ERmodel2flex     (source file ERmodel2flex.xslt)
      -  creates a flex diagram structure of enclosures, routes etc.


 "tactics_one_recursive" (source file `tactics_one_recursive_enrichment.module.xslt`)
      - implementation of 
                    yPositionalPriors : enclosure -> Set Of enclosure
                    entryContainer: source -> enclosure
        			exitContainer : destination -> enclosure  

"tactics_two_parameterised" (source file `tactics_two_parameterised_enrichment.module.xslt`)
   + recursive_structure_enrichment (source ERmodel.flex_recursive_structure_enrichment.xslt) 
            - implements 'yPositionalDepthShort': enclosure -> non-negative number
            THIS IS A DEPTH PARAMETERISED PASS

"tactics_three_recursive" (source file `tactics_three_recusive_enrichment.module.xslt.xslt`)
   + second_recursive_structure_enrichment (source ERmodel.flex_recursive_structure_enrichment.xslt) 
            - implements 'yPositionalDepthLong': enclosure -> non-negative number
                         'yPositionalReferencePoint' : enclosure -> enclosure
                             COULD BE PARAMETERISED BT TACTIC Short or Long


"tactics_four_enrichment" (source file 'tactics_4_enrichment.module.xslt')
	+ intrusion              COULD BE PARAMETERISED BY Intrude or not 
-->


<!-- Keep a global reference to the document node so that can be used from assembly.module
     for a base URI for access to included models by filename. See document() function. 
-->
<xsl:variable name="docnode" select="/"/>

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
      <xsl:message>putting out ER model instance (1)</xsl:message>
      <xsl:result-document href="ERmodel_instance_after_surface_parsed.xml" method="xml">
        <xsl:copy-of select="$state"/>
      </xsl:result-document>
    </xsl:if>

   <xsl:message> about to call assembly </xsl:message>
   <xsl:variable name="state" as="document-node()">
   	  <xsl:copy>
          <xsl:apply-templates select="$state" mode="assembly"/>
      </xsl:copy>
   </xsl:variable>

   <xsl:if test="true()">
      <xsl:message>putting out ER model instance(2)</xsl:message>
      <xsl:result-document href="ERmodel_instance_after_assembly.xml" method="xml">
        <xsl:copy-of select="$state"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:variable name="state" as="document-node()">
    	<xsl:copy>
      		<xsl:apply-templates select="$state" mode="consolidate"/>
  		</xsl:copy>
   </xsl:variable>

   <xsl:if test="true()">
      <xsl:message>putting out ER model instance(3)</xsl:message>
      <xsl:result-document href="ERmodel_instance_after_consolidation.xml" method="xml">
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
		<xsl:message>initiating ERmodel2flex transform</xsl:message>
			<xsl:copy>
				<xsl:apply-templates select="$state" mode="ERmodel2flex"/>
			</xsl:copy>
	</xsl:variable>	

   <xsl:if test="true()">
      <xsl:message>putting out ER model instance(4)</xsl:message>
      <xsl:result-document href="ERmodel_instance_after_ERmodel2flex.xml" method="xml">
        <xsl:copy-of select="$state"/>
      </xsl:result-document>
    </xsl:if>

	<xsl:variable name="state" as="document-node()">
			<xsl:message>initiating tactics zero enrichment </xsl:message>
			<xsl:copy>
				<xsl:apply-templates select="$state" mode="tactics_zero_enrichment"/>
			</xsl:copy>
	</xsl:variable>	

    <xsl:variable name="state" as="document-node()">
	  <xsl:message>initiating tactics one recursive enrichment</xsl:message>
      <xsl:call-template name="tactics_one_recursive">
         <xsl:with-param name="interim" select="$state/*"/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="state" as="document-node()">
			<xsl:message>initiating tactics two parameterised enrichment</xsl:message>
      <xsl:call-template name="tactics_two_parameterised">
         <xsl:with-param name="interim" select="$state/*"/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="state" as="document-node()">
			<xsl:message>initiating tactics three recursive enrichment</xsl:message>
      <xsl:call-template name="tactics_three_recursive">
         <xsl:with-param name="interim" select="$state/*"/>  
         <xsl:with-param name="depth" select="0"/>  
      </xsl:call-template>
    </xsl:variable>

	<xsl:message>initiating tactics four enrichment</xsl:message>
	<xsl:copy>
		<xsl:apply-templates select="$state" mode="tactics_four_enrichment"/>
	</xsl:copy>
</xsl:template>

	<xsl:template match="entity_model" mode="ERmodel2flex">
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
				<xsl:element name="enclosure">
					<id>diagram</id>
					<label><id>required</id><text>xxx</text></label>
					<shape_style>group_outline_visible</shape_style>
					<y><abs>0</abs></y>
					<x><abs>0</abs></x>
					<xsl:apply-templates select="absolute|entity_type|group" mode="ERmodel2flex"/>
				</xsl:element>
				<xsl:copy-of select="diagram:enclosure/*"/>
				<xsl:apply-templates select="//composition" mode="ERmodel2flex"/>
				<xsl:apply-templates select="//reference" mode="ERmodel2flex"/>
			</diagram:diagram>
	</xsl:template>


	<xsl:template match="absolute" mode="ERmodel2flex">
		<xsl:message>ERmodel2flex</xsl:message>
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>eteven</shape_style>
			<padding>0</padding>
			<wFill/> <!-- UNDER INVESTIGATION --> 
			<!-- <w>3.0</w> --> <!-- hard coded instead? -->
			<framearc>0.2</framearc>
			<label/>
			<x/>
			<y/>
		</xsl:element>
	</xsl:template>

<!-- cleaned up and upgraded change 28-Oct-2024 -->  <!-- except see comment above -->
	<xsl:template match="entity_type" mode="ERmodel2flex">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<xsl:variable name="nestingDepth" as="xs:integer" select="count(ancestor-or-self::entity_type)-1"/>
			<xsl:variable name="iseven" as="xs:boolean" select="($nestingDepth mod 2)=0"/>
			<xsl:variable name="shapestyle" as="xs:string" select="if ($iseven) then 'eteven' else 'etodd'"/>
			<shape_style><xsl:value-of select="$shapestyle"/></shape_style>
			<framearc>0.2</framearc>
			<label><text_style>etname</text_style><id><xsl:value-of select="name"/>nameLabel</id></label>
            <!-- the following ensures that diagram information can be embedded in  the 
                 entity type and copies forward into the flex diagram -->
			<xsl:copy-of select="diagram:enclosure/*"/>
            <!-- if not embedded the x and y stubs created wehich will
                  subsequently be populated in tactics four
            -->
            <xsl:if test="not(diagram:enclosure/diagram:x)">
            	<x/>
            </xsl:if>
            <xsl:if test="not(diagram:enclosure/diagram:y)">
            	<y/>
            </xsl:if>
			<xsl:apply-templates select="entity_type|group|attribute" mode="ERmodel2flex"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="group(:[not(diagram:enclosure)]:)" mode="ERmodel2flex">
		<xsl:element name="enclosure">
			<id><xsl:value-of select="name"/></id>
			<shape_style>group_outline</shape_style>
			<xsl:apply-templates select="entity_type|group" mode="ERmodel2flex"/>
			<xsl:copy-of select="diagram:enclosure/*"/>
			<xsl:if test="not(diagram:enclosure/diagram:x)">
            	<x/>
            </xsl:if>
            <xsl:if test="not(diagram:enclosure/diagram:y)">
            	<y/>
            </xsl:if>
		</xsl:element>
	</xsl:template>

  <xsl:template match="attribute" mode="ERmodel2flex">
			<label>
        	<text><xsl:text>-</xsl:text>
        	      <xsl:value-of select="name"/>
        	      <xsl:if test="substring(type,string-length(type))='?'">   <!--optional attribute --> <!-- XXXXXXXXXXXXXXXXXXX -->
        	      	<xsl:text>?</xsl:text>
        	      </xsl:if>
        	</text>
        	<text_style>attrname</text_style>
        	<id><xsl:value-of select="../name || '__' || name"/></id> <!-- added 20 Aug 2025 for use by tactics four rules for positioning -->
      </label>
  </xsl:template>
	
	<xsl:template match="composition" mode="ERmodel2flex">
		<xsl:variable name="type" select="era:typeFromExtendedType(type)"/>
		<!--XXXX -->
		<route>
			<text_style>relname</text_style>
			<top_down/>
			<source>
				<id><xsl:value-of select="../name"/></id>
				<annotation><xsl:value-of select="name"/></annotation>
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
<!-- 				FIXED 21-Jan-2025 BUG INTRODUCED 2024 when v1.6 parser introduced into flex generation. 
				<line_style>
					 <xsl:choose>
					 	<xsl:when test="(substring(type,string-length(type))='*')
					 		               or (substring(type,string-length(type))='?')">
					 		<xsl:text>dashedline</xsl:text>
					 	</xsl:when>
					 	<xsl:otherwise>
					 		<xsl:text>solidline</xsl:text>
					 	</xsl:otherwise>
					 </xsl:choose>
				</line_style> -->
			</source>
			<destination>
				<id><xsl:value-of select="$type"/></id>
				<annotation><xsl:value-of select="inverse"/></annotation>
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

        <xsl:if test="pullback">  <!-- IS THIS RIGHHT??? XXXX-->
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

	<xsl:template match="reference" mode="ERmodel2flex">
		<!-- <xsl:variable name="type" select="era:typeFromExtendedType(type)"/> -->
		<route>
			<text_style>relname</text_style>
			<sideways/>
			<source>

      <!-- temporary measures --> <!-- REMOVED change of 6th May 2025 -->
<!--       <right_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </right_side> -->

				<id><xsl:value-of select="../(if (self::identifying) then ../name else name)"/></id>
				<annotation><xsl:value-of select="name"/></annotation>
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
<!-- 			<left_side>  REMOVED change of 6th May 2025
         <deltay>0.5</deltay>
         <annotate_low/>
      </left_side>  -->
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