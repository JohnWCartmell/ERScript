
<!--
**********************
ERmodel2.physical.xslt
**********************

DESCRIPTION
 Generate a  physical model, either hierarchical or a relational from 
 a logical ER model.

 Parameter 'style' species that either a relational or a 
                   hierarchical physical model is required.

 style must be one oN:
     'r'  - relational            - for a representation in which all 
                                    relationships are represented solely 
                                    by foreign keys and not by context in a 
                                    hierarchy
     'h'  - hierarchical          - reference relationships have foreign key 
                                    attributes generated for them
                                    composition relationships are 
                                    represented by context within a hierarchy
     'hs' - hierarchical stylised - this is used for the ER meta model itself 
                                    for specific conventions used in 
                                    representing ER models in xml. In 
                                    particular primary key is the 'name' 
                                    attribute and foreign key is named 
                                    the same as the reference relationship.

CHANGE HISTORY

CR18553 JC  21-Oct-2016 Work now done in a series of enrichment modules.
CR18720 JC  16-Nov-2016 Use packArray function from ERmodel.functions.module.xslt
CR19229 JC  27-Jan-2016 Support absolute scopes.

3-Oct-2022 JC Modularistion support add an initial assembly pass.

-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


  <xsl:param name="style"/>   
  <xsl:param name="longSeparator" as="xs:string" select="'_'"/>  <!-- used to separate rel name in name of implementing attributes -->   
  <xsl:param name="shortSeparator" as="xs:string" select="'_'"/>  <!-- used as separate et name and attr name  in name of implementing attributes -->
  <xsl:param name="debug" as="xs:string?"/>

  <!-- can be 'h' or 'hs' for hierarchical and 'r' for relational -->
  <!-- 'hs' is hierarchical stylised - at most one identifying 
              attribute per entity type, explicit diagonals, inheritance, 
              foreign keys named as relationship
              This style used specifically for the ER meta model.
          -->

  <xsl:key name="Testkey" 
         match="entity_type|group" 
         use="(if (false()) then '' else '',description)"/>
  <xsl:key name="EntityTypes" 
         match="absolute|entity_type|group" 
         use="if(string-length(name)=0 and self::absolute) then 'EMPTYVALUEREPLACED' else name"/>
  <!--CR19229 added absolute -->
  <xsl:key name="IncomingCompositionRelationships" 
         match="composition" 
         use="type"/>
  <!-- CR-18032 -->
  <xsl:key name="AllIncomingCompositionRelationships" 
         match="composition" 
         use="key('EntityTypes',type)/descendant-or-self::entity_type/name"/>    
  <!-- was "descendant-or-self::entity_type/type" until 23-Aug-2016 and therefore primary key for "reference" in meta-model wrong-->
  <!-- end CR-18032 -->
  <xsl:key name="AllMasterEntityTypes" 
         match="entity_type" 
         use="composition/key('EntityTypes',type)/descendant-or-self::entity_type/name"/>
  <xsl:key name="CompRelsByDestTypeAndInverseName" 
         match="composition" 
         use="era:packArray((type,inverse))"/>
  <xsl:key name="ConstructedRelationshipsByQualifiedName" 
         match="constructed_relationship" 
         use="era:packArray((../name,name))"/>
  <xsl:key name="CoreRelationshipsByQualifiedName" 
         match="reference|composition|dependency" 
         use="era:packArray((../name,name))"/>
  <xsl:key name="RelationshipBySrcTypeAndName" 
         match="reference|composition|dependency|constructed_relationship" 
         use="era:packArray((../name,name))"/>
  <!-- CR-18032 -->
  <xsl:key name="AllRelationshipBySrcTypeAndName"
         match="reference|composition|dependency|constructed_relationship"
         use ="../descendant-or-self::entity_type/era:packArray((name,current()/name))" />
  <!-- end CR-18032 -->
  <xsl:key name="whereImplemented" 
         match="implementationOf"
         use="era:packArray((../../name,rel))"/>


  <xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />

  <!-- save $docnode for use from assembly module 
      but surely I could do better than this abd keep the context all way
      through various stages.
  -->
  <xsl:variable name="docnode" select="/" />   
  
  <!-- Make copy template available as a default -->
  <xsl:template match="*" >
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:include href="ERmodel.functions.module.xslt"/>
  <xsl:include href="ERmodelv1.6.parser.module.xslt"/>
  <xsl:include href="ERmodel.assembly.module.xslt"/>
  <xsl:include href="ERmodel.consolidate.module.xslt"/>
  <xsl:include href="ERmodel2.initial_enrichment.module.xslt"/>
  <xsl:include href="ERmodel2.physical_enrichment.module.xslt"/>
  <xsl:include href="ERmodel2.xpath_enrichment.module.xslt"/>


  <xsl:template match="/">
    <xsl:if test="not($style='h' or $style='hs' or $style='r')">
      <xsl:message terminate="yes">
          style should be either 'h' hierarchical or 'hs' hierarchical stylised or 'r' relational 
      </xsl:message>
    </xsl:if>
    <xsl:message>===========================</xsl:message>
    <xsl:message> ENTER ERmodel2.physical   </xsl:message>
    <xsl:message> debug: '<xsl:value-of select="$debug"/>'</xsl:message>
    <xsl:message> style: '<xsl:value-of select="$style"/>'</xsl:message>
    <xsl:message>---------------------------</xsl:message>
    <xsl:message>Information: style is one of 'h' hierarchical or 'hs' hierarchical stylised or 'r' relational </xsl:message>
    <xsl:if test="not($style='h' or $style='hs' or $style='r')">
      <xsl:message terminate="yes">
          Error: style should be either 'h' hierarchical or 'hs' hierarchical stylised or 'r' relational 
      </xsl:message>
    </xsl:if>

    <!-- optional parsing of v1.6 -->

   <xsl:variable name="state">
       <xsl:choose>
         <xsl:when test="entity_model/@ERScriptVersion='1.6'">
               <xsl:apply-templates select="." mode="parse__conditional"/>
             <!-- cant get assembly to work here -->
             <!-- therefore support newform on included files and on top level files but not both -->
         </xsl:when>
         <xsl:otherwise>
               <xsl:copy-of select="."/> 
          </xsl:otherwise>
       </xsl:choose>
   </xsl:variable>

   <xsl:variable name="state">
      <xsl:apply-templates select="$state" mode="assembly"/>
   </xsl:variable>

   
    <xsl:variable name="state">
      <xsl:apply-templates select="$state" mode="consolidate"/>
    </xsl:variable>

    <xsl:if test="$debugon">
      <xsl:message>Debug is on </xsl:message>
      <xsl:result-document href="initial_consolidated assembly_temp.xml" method="xml">
        <xsl:sequence select="$state/entity_model"/>
      </xsl:result-document>
    </xsl:if>

    <!-- is followed by an initial enrichment (see ERmodel2.initial_enrichment.module.xslt)        -->
    <xsl:variable name="state">
      <xsl:call-template name="initial_enrichment">
        <xsl:with-param name="document" select="$state"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$debugon">
      <xsl:result-document href="initial_enriched_temp.xml" method="xml">
        <xsl:sequence select="$state/entity_model"/>
      </xsl:result-document>
    </xsl:if>
    <!-- is followed by the main algorithm (see ERmodel2.physical_enrichment.module.xslt) -->
    <!--
    <xsl:variable name="state">
    -->
      <xsl:call-template name="physical_enrichment">
        <xsl:with-param name="document" select="$state"/>
      </xsl:call-template>
      <!--
    </xsl:variable>
  -->

    <!-- and finally the document is optionally enriched by xpath attributes (see ERmodel2.xpath_enrichment.module.xslt) -->
    <!-- but it doesn't have to be does it ?? could do this on the fly where needed -->
    <!--
    <xsl:choose>
      <xsl:when test="$style='h' or $style='hs'">
        <xsl:call-template name="recursive_xpath_enrichment">
          <xsl:with-param name="interim" select="$state"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$state"/>
      </xsl:otherwise>
    </xsl:choose>    
  -->
    <xsl:message>-------------------------</xsl:message>
    <xsl:message> EXIT ERmodel2.physical   </xsl:message>
    <xsl:message>=========================</xsl:message>
  </xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.physical.xslt--> 

