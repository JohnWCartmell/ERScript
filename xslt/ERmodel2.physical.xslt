<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.physical.xslt 
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

-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:include href="ERmodel.functions.module.xslt"/>

  <xsl:param name="style"/>   
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


  <xsl:param name="debug" />
  <xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />



  <!-- Make copy template available as a default -->
  <xsl:template match="*" >
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:include href="ERmodel2.initial_enrichment.module.xslt"/>
  <xsl:include href="ERmodel2.physical_enrichment.module.xslt"/>
  <xsl:include href="ERmodel2.xpath_enrichment.module.xslt"/>

  <xsl:template match="/">
    <xsl:if test="not($style='h' or $style='hs' or $style='r')">
      <xsl:message terminate="yes">
          style should be either 'h' hierarchical or 'hs' hierarchical stylised or 'r' relational 
      </xsl:message>
    </xsl:if>
    <!-- an initial enrichment (see ERmodel2.initial_enrichment.module.xslt)        -->
    <xsl:variable name="state">
      <xsl:call-template name="initial_enrichment">
        <xsl:with-param name="document" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$debugon">
      <xsl:result-document href="initial_enriched_temp.xml" method="xml">
        <xsl:sequence select="$state/entity_model"/>
      </xsl:result-document>
    </xsl:if>
    <!-- is followed by the main algorithm (see ERmodel2.physical_enrichment.module.xslt) -->
    <xsl:variable name="state">
      <xsl:call-template name="physical_enrichment">
        <xsl:with-param name="document" select="$state"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- and finally the document is optionally enriched by xpath attributes (see ERmodel2.xpath_enrichment.module.xslt) -->
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
  </xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.physical.xslt--> 

