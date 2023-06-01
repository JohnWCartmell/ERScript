<?xml version="1.0" encoding="UTF-8"?>


<xsl:transform version="2.0" 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:era="http://www.entitymodelling.org/ERmodel" 
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel"
               xmlns="http://www.entitymodelling.org/ERmodel">

<!--  Maintenance Box 

CR-18123 JC  30-Aug-2016 The derived attribute 'base' of a reference rel is 
                     removed.  Remove the use of it from this xslt. It 
                     doesn't need replacing because its use wasn't actually 
                     doing anything.

CR-18376 JC  29-Sep-2016 Support references to entities that are scoped 
                     via their supertypes. 
                     Include pullback support.
                     Infer <projection>. Later: moved out again see CR-18078.
                     Allow relationships to be inherited.

CR-18397 BA  03-Oct-2016 Support for references that include identifying 
                         sequences.

CR-18323 BA  03-Oct-2016 Generated code now null-safe and readonly where 
                         appropriate.

CR-18553 JC  24-Oct-2016 Minor restructure to use 
                         ERmodel2.class_enrichment.module.xslt.
                         mode="explicit" added to guard against specific 
                         templates being used in preference to generic 
                         rule in copy of structure.
                         Add debug='y' as a command line option to direct 
                         that intermediate xml file sbe output.
CR-18708 JC  18-Nov-2016 The enrichment of a reference relationship with a 
                         projection (CR-18376 above) is moved 
                         out of this transform into the 
                         earlier ERmodel2.initial_enrichment.
         JC  29-Nov-2016 Consider removal of riser2. Start by copying enrichment of riser2 to riser.
                         Subsequently replace use of riser2 by use of projection_rel/riser.

CR-18563 BA  25-Oct-2016 Named compositions now throw exceptions when attempting to parse documents
                         with missing name elements when those compositions are mandatory.

CR-20492 BA  29-Jun-2016 EntityList constructor to support Array constructor interface.

 -->

<xsl:output method="text" indent="no"/>

<xsl:key name="Enumeration" match="enumeration_type" use="name"/>
<xsl:key name="EntityTypes" match="entity_type|absolute" use="name"/>
<!-- CR18376 allow composition relationships to be inherited -->
<xsl:key name="CompRelsByDestTypeAndInverseName" 
         match="composition" 
         use="key('EntityTypes',type)/descendant-or-self::entity_type/concat(name,':',current()/inverse)"/>
<xsl:key name="IncomingCompositionRelationships" 
         match="composition" 
         use="type"/>
<!-- CR18376 allow relationships to be inherited -->
<xsl:key name="RelationshipBySrcTypeAndName" 
         match="reference|composition|dependency|constructed_relationship" 
         use="../descendant-or-self::entity_type/concat(name,':',current()/name)"/>
<xsl:key name="inverse_implementationOf" 
       match="implementationOf"
       use="concat(../../name,':',rel)"/>
<xsl:key name="RelationshipById"
         match="composition|reference"
         use="id"/>

<xsl:param name="debug" />
<xsl:variable name="debugon" as="xs:boolean" select="$debug='y'" />


<xsl:include href="ERmodel.functions.module.xslt"/>
<xsl:include href="ERmodel2.class_enrichment.module.xslt"/>

<!-- 
  Given a list of cardinalities, compute the cardinality of the relationship formed by joining a
  list of relationships with the cardinalities provided.

  This expresses the following rules:

      X  |  1  |  ?  |  *  |  +  |
      ___|_____|_____|_____|_____|
         |     |     |     |     |
      1  |  1  |  ?  |  *  |  +  |
      ___|_____|_____|_____|_____|
         |     |     |     |     |
      ?  |  ?  |  ?  |  *  |  *  |
      ___|_____|_____|_____|_____|
         |     |     |     |     |
      *  |  *  |  *  |  *  |  *  |
      ___|_____|_____|_____|_____|
         |     |     |     |     |
      +  |  +  |  *  |  *  |  +  |
      ___|_____|_____|_____|_____|

  Where:

    1 = ExactlyOne
    ? = ZeroOrOne
    * = ZeroOneOrMore
    + = OneOrMore

-->
<xsl:function name="era:join_cardinalities" as="xs:string">
  <xsl:param name="cardinalities" as="element()*"/>
  <xsl:choose>
    <xsl:when test="count($cardinalities)=0">
                   <xsl:value-of select="'ExactlyOne'"/>
    </xsl:when>
    <xsl:when test="count($cardinalities/*)=0">
                   <xsl:value-of select="'ExactlyOne'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="left" select="$cardinalities[1]/*/name()"/>
      <xsl:variable name="right" select="era:join_cardinalities($cardinalities[position()&gt;1])"/>
      <xsl:value-of select="if      ($left = $right) then $left 
                            else if ($left = 'ExactlyOne') then $right 
                            else if ($right = 'ExactlyOne') then $left 
                            else 'ZeroOneOrMore'"/>   
                            <!-- think we can do a bit better than this btw 29/10/2022 -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- LOOKING LIKE WE SHOULD PASS actual cardinality value rather then cardinality element --> 

<!-- following is generic and coud be useful elsewhere -->
<!-- here I use it for constructing cardinality nodes -->
<xsl:template name="element" match="*" mode="explicit">
    <xsl:param name="name" as="xs:string"/>
    <xsl:element name="{$name}" namespace="http://www.entitymodelling.org/ERmodel"/>
</xsl:template>

<xsl:template name="join_cardinality" match="*" mode="explicit">
    <xsl:param name="cardinalities" as="element(cardinality)*"/>
    <xsl:element name="cardinality">
        <xsl:variable name="temp" select="era:join_cardinalities($cardinalities)"/>
        <xsl:if test="string-length($temp)=0">
            <xsl:message terminate="yes">Terminate in join_cardinality AT <xsl:value-of select="name()"/>count<xsl:value-of select="count($cardinalities/*)"/>elements <xsl:value-of select="$cardinalities/*/name()"/></xsl:message>
        </xsl:if>
        <xsl:call-template name="element">
           <xsl:with-param name="name" select="era:join_cardinalities($cardinalities)"/>
        </xsl:call-template>
   </xsl:element>
</xsl:template>

<xsl:template name="navigation_cardinality" match="*" mode="explicit">
    <xsl:param name="cardinalities" as="element(cardinality)*"/>
    <xsl:variable name="temp" select="era:join_cardinalities($cardinalities)"/>
        <xsl:if test="string-length($temp)=0">
            <xsl:message terminate="yes">Terminate in navigation_cardinality AT <xsl:value-of select="name()"/>count<xsl:value-of select="count($cardinalities/*)"/>elements <xsl:value-of select="$cardinalities/*/name()"/>
            </xsl:message>
        </xsl:if>
    <xsl:element name="navigation_cardinality">
        <xsl:call-template name="element">
           <xsl:with-param name="name" select="era:join_cardinalities($cardinalities)"/>
        </xsl:call-template>
    </xsl:element>
</xsl:template>

<xsl:template name="inverse_cardinality" match="*" mode="explicit">
    <xsl:param name="cardinalities" as="element(inverse_cardinality)*"/>
    <xsl:element name="inverse_cardinality">
        <xsl:call-template name="element">
           <xsl:with-param name="name" select="era:join_cardinalities($cardinalities)"/>
        </xsl:call-template>
    </xsl:element>
</xsl:template>

<xsl:template match="/">
   <xsl:message>debug is <xsl:value-of select="$debug"/></xsl:message>
   <xsl:variable name="current_state">
      <xsl:call-template name="recursive_class_enrichment">
         <xsl:with-param name="document" select="."/>  
      </xsl:call-template>
   </xsl:variable>

   <xsl:if test="$debugon">
      <xsl:result-document href="class_enrichment.xml" method="xml">
        <xsl:sequence select="$current_state/entity_model"/>
      </xsl:result-document>
   </xsl:if>

   <xsl:variable name="current_state">
      <xsl:for-each select="$current_state">
         <xsl:copy>
           <xsl:apply-templates mode="initial_pass"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>

   <xsl:if test="$debugon">
      <xsl:result-document href="initial_enrichment.xml" method="xml">
        <xsl:sequence select="$current_state/entity_model"/>
      </xsl:result-document>
   </xsl:if>

   <xsl:variable name="current_state">
     <xsl:call-template name="recursive_js_enrichment">
        <xsl:with-param name="interim" select="$current_state"/>  
         <xsl:with-param name="depth" select="0"/>
     </xsl:call-template>
   </xsl:variable>

   <xsl:if test="$debugon">
      <xsl:result-document href="recursive_enrichment.xml" method="xml">
        <xsl:sequence select="$current_state/entity_model"/>
      </xsl:result-document>
   </xsl:if>

   <xsl:for-each select="$current_state/entity_model">
       <xsl:call-template name="generate_code"/>
   </xsl:for-each>
</xsl:template>

<xsl:template match="*">
<xsl:message>super generic rule <xsl:value-of select="name()"/></xsl:message>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<!-- in the initial pass we add js naming -->
<xsl:template match="*" mode="initial_pass"> 
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="entity_model" mode="initial_pass"> 
  <xsl:copy>
     <xsl:apply-templates mode="initial_pass"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="absolute" mode="initial_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
    <xsl:element name="js_classname">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="name"/>
        </xsl:call-template>
    </xsl:element>
    <xsl:element name="js_listclassname">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="name"/>
        </xsl:call-template>
        <xsl:text>_List</xsl:text>
    </xsl:element>
</xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="initial_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
    <xsl:element name="js_classname">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="name"/>         
        </xsl:call-template>
    </xsl:element>
    <xsl:element name="js_listclassname">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="name"/>         
        </xsl:call-template>
        <xsl:text>_List</xsl:text>
    </xsl:element>
    <xsl:element name="js_parent_classname">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="parentType"/>
        </xsl:call-template>
    </xsl:element>
  </xsl:copy>
</xsl:template>

<xsl:template match="composition|reference" mode="initial_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
    <!-- 'id' added here 30 May 2023 because 'id' no longer present in the physical model that is the input to this transform.
        (could do to get rid of this use of 'id' tbh but that is for another time)
    -->
    <xsl:element name="id">
      <xsl:text>Rel</xsl:text>  
      <xsl:number count="(composition|reference)" level="any" />
   </xsl:element>
   <!-- end of 30 May 2023 -->
    <xsl:element name="js_membername">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name">
              <xsl:choose>
                 <xsl:when test="name">
                    <xsl:value-of select="name"/>
                 </xsl:when>
                 <xsl:otherwise>
                   <xsl:value-of select="type"/>
                 </xsl:otherwise>
               </xsl:choose>
           </xsl:with-param>
        </xsl:call-template>
    </xsl:element>
    <xsl:element name="js_inverse_membername">
        <!--
           composition - inverse is 'parent'
           reference take inverse and mangle if there is one or invent relname_inverse
        -->
        <xsl:choose>
           <xsl:when test="self::composition">
              <xsl:value-of select="'parent'"/>
           </xsl:when>
           <xsl:when test="self::reference">
              <xsl:variable name="basename"
                            select="if (inverse) then inverse else concat(name,'_inverse')"/>
              <xsl:call-template name="js_mangle_name">
                 <xsl:with-param name="name" select="$basename"/>
              </xsl:call-template>
           </xsl:when>
        </xsl:choose>
    </xsl:element>
    <xsl:variable name="objecttype">
        <xsl:if test="key('EntityTypes',type)/module_name">
             <xsl:if test="not(../module_name) or key('EntityTypes',type)/module_name != ../module_name">
                 <xsl:value-of select="key('EntityTypes',type)/module_name"/>
                 <xsl:text>.</xsl:text>
             </xsl:if>
        </xsl:if>
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="type"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:element name="js_objecttype">
      <xsl:value-of select="$objecttype"/>
    </xsl:element>
    <xsl:element name="js_objectlisttype">
      <xsl:value-of select="$objecttype"/>
      <xsl:text>_List</xsl:text>
    </xsl:element>
    <xsl:element name="js_membertype">
      <xsl:value-of select="$objecttype"/>
      <xsl:if test="cardinality/ZeroOneOrMore  or cardinality/OneOrMore">
          <xsl:text>_List</xsl:text>
      </xsl:if>
    </xsl:element>
  </xsl:copy>
</xsl:template>


<xsl:template match="attribute" mode="initial_pass">
  <xsl:copy>
    <xsl:apply-templates mode="initial_pass"/>
    <xsl:element name="js_membername">
        <xsl:call-template name="js_mangle_name">
           <xsl:with-param name="name" select="name"/>
        </xsl:call-template>
    </xsl:element>
    <xsl:element name="js_membertype">
        <xsl:apply-templates select="type" mode="type_subpass"/>
    </xsl:element>
  </xsl:copy>
</xsl:template>

<!-- 
<xsl:template match="composition
                     [not(id)]
                    "
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
       <id>
          <xsl:text>S</xsl:text>  
          <xsl:number count="composition" level="any" />
       </id>
    </xsl:copy>
</xsl:template>

<xsl:template match="dependency
                     [not(id)]
                     [key('CompositionByDestTypeAndInverseName',concat(../name,':',name))/id]
                    "
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
       <id>
          <xsl:value-of select="key('CompositionByDestTypeAndInverseName',concat(../name,':',name))/id"/>
       </id>
       <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="reference
                     [not(id)]" 
              mode="documentation_enrichment_recursive"  priority="1">
   <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="documentation_enrichment_recursive"/>
        <id>
          <xsl:text>R</xsl:text>
          <xsl:number count="reference" level="any" />
       </id>
    </xsl:copy>
</xsl:template>

-->

<xsl:template match="attribute/type[boolean]" mode="type_subpass">
        <xsl:text>boolean</xsl:text>
</xsl:template>
<xsl:template match="attribute/type[string]" mode="type_subpass">
        <xsl:text>string</xsl:text>
</xsl:template>
<xsl:template match="attribute/type[time|dateTime|date]" mode="type_subpass">
        <xsl:text>Date</xsl:text>
</xsl:template>
<xsl:template match="attribute/type[integer|float|positiveInteger|nonNegativeInteger]" 
              mode="type_subpass">
        <xsl:text>number</xsl:text>
</xsl:template>

<xsl:template name="recursive_js_enrichment">
   <xsl:param name="interim"/>
   <xsl:param name="depth"/>
   <xsl:message> in recursive js enrichment </xsl:message>
   <xsl:variable name ="next">
      <xsl:for-each select="$interim">
      <xsl:message> in loop therein </xsl:message>
         <xsl:copy>
            <xsl:apply-templates mode="recursive_js_enrichment"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($interim,$next)) and $depth!=40">
            <xsl:message> changed js enrichment</xsl:message>
            <xsl:call-template name="recursive_js_enrichment">
               <xsl:with-param name="interim" select="$next"/>
               <xsl:with-param name="depth" select="$depth + 1"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> <xsl:value-of select="if($depth!=30) 
                                                then 'unchanged fixed point js enrichment'
                                                else 'TERMINATED EARLY AT DEPTH 30'" />
            </xsl:message>
            <xsl:copy-of select="$interim"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable> 
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="absolute" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js_primary_key)">
        <xsl:element name="js_primary_key"/>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="entity_type" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:variable name="this" select="."/>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:variable name="rel" select="ancestor-or-self::entity_type/key('IncomingCompositionRelationships', name)"/>
      <xsl:if test="not(js_primary_key) and (every $r in $rel satisfies $r/../js_primary_key)">
        <xsl:element name="js_primary_key">
          <xsl:if test="count($rel)=1 and $rel/identifying">
            <xsl:for-each select="$rel/../js_primary_key/attribute">
              <xsl:element name="attribute">
                <xsl:element name="name"><xsl:value-of select="name"/></xsl:element>
                <xsl:element name="type"><xsl:value-of select="type"/></xsl:element>
                <xsl:element name="lookup">.parent<xsl:value-of select="lookup"/></xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:if>
          <xsl:for-each select="ancestor-or-self::entity_type/attribute[identifying]">
            <xsl:element name="attribute">
              <xsl:element name="name"><xsl:value-of select="concat(../js_classname,'_',js_membername)"/></xsl:element>
              <xsl:element name="type"><xsl:value-of select="js_membertype"/></xsl:element>
              <xsl:element name="lookup">.<xsl:value-of select="js_membername"/></xsl:element>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="attribute" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js_member)">
         <xsl:element name="js_member">
           <xsl:value-of select="js_membername"/>
           <xsl:text>: </xsl:text>
           <xsl:value-of select="js_membertype"/>
         </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="reference" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(navigation_cardinality) and riser/cardinality and diagonal/cardinality">
        <xsl:call-template name="navigation_cardinality">
                <xsl:with-param name="cardinalities"
                            select="riser/cardinality|diagonal/cardinality"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not(jscheck) and key/jscheck">
        <xsl:element name="jscheck">
          <xsl:value-of select="key/jscheck"/>
        </xsl:element>
      </xsl:if>
      <!-- 16 Aug 2016  - CR-18123 replace use of base - it isn't doing anything!-->
      <!-- <xsl:if test="not(js_foreign_key) and (not(key) or key/js) and (not(diagonal) or diagonal/theabsolute or (diagonal/js and diagonal/js_foreign_key and base))">  -->
      <xsl:if test="not(js_foreign_key) and (not(key) or key/js) and (not(diagonal) or diagonal/theabsolute or (diagonal/js and diagonal/js_foreign_key ))"> 
        <xsl:element name="js_foreign_key">
            <xsl:choose>
                <xsl:when test="key">   <!-- simplifying assumption that only one dest level (one component in riser in pullback ) -->
                                       <!-- probably need to generalise -->
                  <xsl:variable name="keyreljs" select="key/js"/>

                  <!-- build fk by navigating to projection that key is target and iterating implmentation from there -->
                  <xsl:for-each select="key('EntityTypes',type)/reference[projection]">
                    <xsl:for-each select="key('inverse_implementationOf',concat(../name,':',name))">
                      <xsl:element name="attribute">
                        <xsl:element name="name">
                          <xsl:call-template name="js_mangle_name">
                            <!-- et name -->
                            <xsl:with-param name="name" select="../../name"/>
                          </xsl:call-template>
                          <xsl:text>_</xsl:text>
                          <!-- next line  need mangling ? -->
                          <xsl:value-of select="../name"/>  <!-- attr name -->
                        </xsl:element>
                        <xsl:element name="type"><xsl:value-of select="../type"/></xsl:element>
                        <xsl:element name="lookup">
                          <xsl:text>this</xsl:text>
                          <xsl:value-of select="$keyreljs"/>
                          <xsl:text>.</xsl:text>
                          <xsl:value-of select="destAttr"/>   
                        </xsl:element>
                      </xsl:element>
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>  <!-- the normal case for a stored ref rel implemented by foreign key -->  
                  <xsl:for-each select="key('inverse_implementationOf',concat(../name,':',name))">
                    <xsl:element name="attribute">
                      <xsl:element name="name">
                        <xsl:value-of select="key('EntityTypes', destAttrHostEt)/js_classname"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="destAttr"/>
                      </xsl:element>
                      <xsl:element name="type"><xsl:value-of select="../type"/></xsl:element>
                      <xsl:element name="lookup">
                        <xsl:text>this.</xsl:text>
                        <xsl:value-of select="../js_membername"/>
                      </xsl:element>
                      <!--CR-18323 null safety means we need to exclude undefined attributes from the foreign key -->
                      <xsl:if test="../optional">
                        <xsl:element name="needs_check"/>
                      </xsl:if>
                    </xsl:element>
                  </xsl:for-each>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:sequence select="diagonal/js_foreign_key/attribute"/>
         </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="dependency" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js)">
          <xsl:message>dep acting</xsl:message>
         <xsl:element name="js">
             <xsl:text>parent</xsl:text>
         </xsl:element>
      </xsl:if>
      <xsl:if test="not(*:js_inverse_membername)">
          <xsl:if test="key('CompRelsByDestTypeAndInverseName',concat(../name,':',name))/js_membername"> 
              <xsl:element name="js_inverse_membername">
                  <xsl:value-of select="key('CompRelsByDestTypeAndInverseName',concat(../name,':',name))/js_membername"/>
              </xsl:element>
          </xsl:if> 
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="identity" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js)">
           <xsl:element name="js"/>    <!-- empty string -->
      </xsl:if>
      <xsl:if test="not(*:cardinality)">
        <xsl:element name="cardinality">
            <xsl:element name="ExactlyOne"/>
       </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="theabsolute" mode="recursive_js_enrichment">
  <xsl:variable name="comp_rel" select="key('IncomingCompositionRelationships',../../type)"/>
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:cardinality)">
        <xsl:element name="cardinality"><xsl:element name="ExactlyOne"/></xsl:element>
      </xsl:if>
      <xsl:if test="not(*:inverse_cardinality)">
        <xsl:element name="inverse_cardinality"><xsl:copy-of select="$comp_rel/cardinality/*"/></xsl:element>
      </xsl:if>
      <xsl:if test="not(*:js)">
           <xsl:element name="js">absolute</xsl:element>
      </xsl:if>
      <xsl:if test="not(*:jslookup)">
            <xsl:element name="jslookup">
               <xsl:text>.</xsl:text>
               <xsl:value-of select="$comp_rel/js_membername"/>
            </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="diagonal|along|key" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js)">
         <xsl:if test="identity">
            <xsl:element name="js"/>
         </xsl:if>
         <xsl:if test="(theabsolute|join|component)/js">
            <xsl:element name="js">
               <xsl:text>.</xsl:text>
               <xsl:value-of select="(theabsolute|join|component)/js"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
      <xsl:if test="not(*:dest) and (identity or (component|join)/dest)">
         <xsl:if test="identity">
          <xsl:element name="dest"><xsl:value-of select="../../name"/></xsl:element>
         </xsl:if>
         <xsl:if test="(component|join)/dest">
            <xsl:element name="dest">
               <xsl:value-of select="(component|join)/dest"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
      <xsl:if test="not(jscheck) and (component|join)/jscheck">
        <xsl:element name="jscheck">
          <xsl:value-of select="(component|join)/jscheck"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(cardinality) and (component|join|theabsolute|identity)/cardinality">
        <xsl:copy-of select="(component|join|theabsolute|identity)/cardinality"/>
      </xsl:if>
      <xsl:variable name="target" select="key('EntityTypes', ../type)"/>
      <xsl:variable name="scope" select="key('EntityTypes', dest)"/>
      <xsl:if test="not(js_foreign_key) and $target/js_primary_key and ($scope/self::absolute or $scope/js_primary_key)">
        <xsl:element name="js_foreign_key">
          <xsl:for-each select="$scope/js_primary_key/attribute">
            <xsl:variable name="attrname" select="name"/>
            <xsl:if test="$target/js_primary_key/attribute[name=$attrname]">
              <xsl:element name="attribute">
                <xsl:element name="name"><xsl:value-of select="name"/></xsl:element>
                <xsl:element name="type"><xsl:value-of select="type"/></xsl:element>
                <xsl:element name="lookup">diagonal<xsl:value-of select="lookup"/></xsl:element>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="riser" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(js) and (component|join|theabsolute)/jslookup">
        <xsl:element name="js">
          <xsl:value-of select="(component|join|theabsolute)/jslookup"/>
        </xsl:element>
      </xsl:if>
<!-- 2 DEc 2016 -->
      <xsl:if test="not(*:js_descent)">
         <xsl:if test="(theabsolute|join|component)/js_inverse">
            <xsl:element name="js_descent">
               <xsl:value-of select="(theabsolute|join|component)/js_inverse"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
      <!-- shouldn't need this (CR-18553) but we do because that CR is purely about new attributes of entitties and riser2 isn't an entity -->
      <xsl:if test="not(src) and (theabsolute|join|component)/src">
        <xsl:element name="src"><xsl:value-of select="(theabsolute|join|component)/src"/></xsl:element>
      </xsl:if>
      <xsl:if test="src and not(js_objecttype)">
        <xsl:element name="js_objecttype">
          <xsl:if test="key('EntityTypes',src)/module_name">
               <xsl:if test="not(ancestor::entity_type[1]/module_name) or key('EntityTypes',src)/module_name != ancestor::entity_type[1]/module_name">
                   <xsl:value-of select="key('EntityTypes',src)/module_name"/>
                   <xsl:text>.</xsl:text>
               </xsl:if>
          </xsl:if>
          <xsl:value-of select="key('EntityTypes',src)/js_classname"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(cardinality) and (component|join|theabsolute|identity)/inverse_cardinality">
        <xsl:element name="cardinality">
            <xsl:copy-of select="(component|join|theabsolute|identity)/inverse_cardinality/*"/>
       </xsl:element>
        <!-- CHECK THE ABOVE-->
      </xsl:if>
    </xsl:copy>
</xsl:template>

<xsl:template match="riser2" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js_descent)">
         <xsl:if test="(theabsolute|join|component)/js_inverse">
            <xsl:element name="js_descent">
               <xsl:value-of select="(theabsolute|join|component)/js_inverse"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
      <!-- shouldn't need this (CR-18553) but we do because that CR is purely about new attributes of entitties and riser2 isn't an entity -->
      <xsl:if test="not(src) and (theabsolute|join|component)/src">
        <xsl:element name="src"><xsl:value-of select="(theabsolute|join|component)/src"/></xsl:element>
      </xsl:if>
      <xsl:if test="src and not(js_objecttype)">
        <xsl:element name="js_objecttype">
          <xsl:if test="key('EntityTypes',src)/module_name">
               <xsl:if test="not(ancestor::entity_type[1]/module_name) or key('EntityTypes',src)/module_name != ancestor::entity_type[1]/module_name">
                   <xsl:value-of select="key('EntityTypes',src)/module_name"/>
                   <xsl:text>.</xsl:text>
               </xsl:if>
          </xsl:if>
          <xsl:value-of select="key('EntityTypes',src)/js_classname"/>
        </xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="join" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js) and (every $component in component satisfies boolean($component/js))">
         <xsl:element name="js">
            <xsl:value-of select="string-join(component/js,'.')"/>
         </xsl:element>
      </xsl:if>
      <xsl:if test="not(js_inverse) and (every $component in component satisfies boolean($component/js_inverse))">
         <xsl:element name="js_inverse">
            <xsl:value-of select="string-join(component/js_inverse,'.')"/>
         </xsl:element>
      </xsl:if>
<!-- CR18123 
      <xsl:if test="not(*:dest)">   
          <xsl:if test="component[last()]/dest">
             <xsl:element name="dest">
                <xsl:value-of select="component[last()]/dest"/>
             </xsl:element>
          </xsl:if>
      </xsl:if>
-->
      <xsl:if test="not(jscheck) and component/jscheck">
        <xsl:element name="jscheck">
          <xsl:value-of select="component/jscheck"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(jslookup) and component/jslookup">
        <xsl:element name="jslookup">
          <xsl:for-each select="component">
            <xsl:sort select="position()" data-type="number" order="descending"/>
            <xsl:value-of select="jslookup"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(cardinality) and (every $component in component satisfies boolean($component/cardinality))">
        <!--
        <xsl:element name="cardinality"><xsl:element name="era:join_cardinalities(component/cardinality)"/></xsl:element>
        -->
        <xsl:call-template name="join_cardinality">
            <xsl:with-param name="cardinalities"
                        select="component/cardinality"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not(inverse_cardinality) and (every $component in component satisfies boolean($component/inverse_cardinality))">
            <!-- <xsl:element name="era:join_cardinalities(component/inverse_cardinality)"/> -->
        <xsl:call-template name="inverse_cardinality">
            <xsl:with-param name="cardinalities"
                        select="component/inverse_cardinality"/> 
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not(src) and component[1]/src">
        <xsl:element name="src"><xsl:value-of select="component[1]/src"/></xsl:element>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="component" mode="recursive_js_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_js_enrichment"/>
      <xsl:if test="not(*:js) and src">
         <xsl:choose>
            <xsl:when test="key('CompRelsByDestTypeAndInverseName',concat(src,':',rel))">
               <xsl:element name="js">
                  <xsl:text>parent</xsl:text>
               </xsl:element>
            </xsl:when>
            <xsl:when test="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))">
               <xsl:element name="js">
                  <xsl:value-of select="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/js_membername"/> 
                                                               <!--  before 26 may was simply select="rel"  -->
               </xsl:element>
            </xsl:when>
         </xsl:choose>
      </xsl:if>
      <xsl:if test="not(cardinality) and src">
        
          <xsl:choose>
            <xsl:when test="rel='..'">
                <xsl:element name="cardinality">
                    <xsl:element name="ExactlyOne"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/cardinality"/>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:if>
      <xsl:if test="not(inverse_cardinality) and src">
        <xsl:element name="inverse_cardinality">
          <xsl:choose>
            <xsl:when test="key('CompRelsByDestTypeAndInverseName',concat(src,':',rel))/cardinality">
              <xsl:copy-of select="key('CompRelsByDestTypeAndInverseName',concat(src,':',rel))/cardinality/*"/>
            </xsl:when>
            <xsl:otherwise><xsl:element name="ZeroOneOrMore"/></xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(jscheck) and js and cardinality/ZeroOrOne">
        <xsl:element name="jscheck">
          <xsl:call-template name="ensure_relationship_exists">
            <xsl:with-param name="varname" select="concat('this.', string-join(preceding-sibling::component/js|js, '.'))"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(*:js_inverse) and src and key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/js_inverse_membername">
         <xsl:element name="js_inverse">
            <xsl:value-of select="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/js_inverse_membername"/> 
         </xsl:element>
      </xsl:if>
      <xsl:if test="not(jslookup) and js_inverse">
        <xsl:element name="jslookup">
          <xsl:variable name="ref" select="key('RelationshipById', relid)"/>
          <xsl:variable name="owningEnts" select="ancestor::entity_type"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="js_inverse"/>
          <xsl:if test="$ref/sequence and $ref/identifying and not($owningEnts/attribute[identifying])">
            <xsl:text>.atIndex(foreignKey.</xsl:text>
            <xsl:value-of select="$ref/js_membername"/>
            <xsl:text>_seqNo</xsl:text>
            <xsl:text>)</xsl:text>
          </xsl:if>
          <xsl:if test="not($ref/type = src)">
            <xsl:text>.as_</xsl:text>
            <xsl:value-of select="src"/>
            <xsl:text>()</xsl:text>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      <xsl:if test="not(*:relid) and src">
         <xsl:if test="key('CompRelsByDestTypeAndInverseName',concat(src,':',rel))">
            <xsl:element name="relid">
               <xsl:value-of select="key('CompRelsByDestTypeAndInverseName',concat(src,':',rel))/id"/>
            </xsl:element>
         </xsl:if>
         <xsl:if test="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/js">
            <xsl:element name="relid">
               <xsl:value-of select="key('RelationshipBySrcTypeAndName',concat(src ,':',rel))/id"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:variable name="quote">'</xsl:variable>

<xsl:template name="newline">
   <xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:variable name="javascript_keywords" as="xs:string *">
   <xsl:sequence select="
          '', 'do', 'if', 'in', 'for', 'let', 'new', 'try', 'var', 'case',
          'else', 'enum', 'eval', 'null', 'this', 'true', 'void', 'with',
          'break', 'catch', 'class', 'const', 'false', 'super', 'throw',
          'while', 'yield', 'delete', 'export', 'import', 'public', 'return',
          'static', 'switch', 'typeof', 'default', 'extends', 'finally',
          'package', 'private', 'continue', 'debugger', 'function', 'arguments',
          'interface', 'protected', 'implements', 'instanceof'   "/>
</xsl:variable>

<xsl:template name="js_member_name" match="attribute|composition" mode="explicit">
   <xsl:variable name="name0">
      <xsl:choose>
      <xsl:when test="name">
         <xsl:value-of select="name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="type"/>
      </xsl:otherwise>
   </xsl:choose>
   </xsl:variable>
   <xsl:call-template name="js_mangle_name">
      <xsl:with-param name="name" select="$name0"/>
   </xsl:call-template>
</xsl:template>

<xsl:template name="js_mangle_name">
   <xsl:param name="name"/>
   <xsl:variable name="name1">
      <xsl:value-of select="replace($name,'\((\d)\)','_$1')"/>
   </xsl:variable>
   <xsl:value-of select="if (count(index-of($javascript_keywords,$name1))=0) then $name1 else concat($name1,'_')"/>
</xsl:template>

<xsl:template name="generate_code" match="/entity_model" mode="explicit">
   <xsl:call-template name="prologue"/> 
   <xsl:for-each select="enumeration_type">
      <xsl:text>type </xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text> = </xsl:text>
      <xsl:for-each select="enumeration_value">
         <xsl:text>"</xsl:text>
         <xsl:value-of select="literal"/>
         <xsl:text>"</xsl:text>
         <xsl:if test="not(position()=last())">
           <xsl:text> | </xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>; </xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
   <xsl:call-template name="newline"/>
   <xsl:for-each select="absolute">
      <xsl:call-template name="absolute"/>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
   <xsl:for-each-group select="//entity_type" group-by="module_name">
      <xsl:text>export module </xsl:text>
      <xsl:value-of select="current-grouping-key()"/>
      <xsl:text> {</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:for-each select="current-group()">
         <xsl:call-template name="class_def"/>
         <xsl:call-template name="newline"/>
         <xsl:call-template name="list_def"/>
         <xsl:call-template name="newline"/>
      </xsl:for-each>
      <xsl:text>}  // end of module </xsl:text> 
      <xsl:value-of select="current-grouping-key()"/>
      <xsl:call-template name="newline"/>
      <xsl:call-template name="newline"/>
   </xsl:for-each-group>
<!--
   <xsl:for-each select="//entity_type">
      <xsl:call-template name="class_def"/>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
-->
</xsl:template>

<xsl:template name="absolute" match="absolute" mode="explicit">
      <xsl:call-template name="class_def"/>
      <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="parent_member" match="entity_type">
     <xsl:text>parent: </xsl:text>
     <xsl:value-of select="js_parent_classname"/>
</xsl:template>

<xsl:template name="class_def" match="entity_type|absolute" mode="explicit">
   <xsl:text>/**</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:value-of select="normalize-space(description)"/>
   <xsl:call-template name="newline"/>
   <xsl:text>*/</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:if test="entity_type">
      <xsl:text>export abstract class </xsl:text>
   </xsl:if>
   <xsl:if test="not(entity_type)">
      <xsl:text>export class </xsl:text>
   </xsl:if>
   <xsl:value-of select="js_classname"/>
   <xsl:if test="parent::entity_type">
      <xsl:text> extends </xsl:text>
   </xsl:if>
   <xsl:value-of select="parent::entity_type/js_classname"/>
   <xsl:text>   { </xsl:text>
   <xsl:call-template name="data_member_fields"/>
   <xsl:call-template name="newline"/>
   <xsl:text>    get absolute(): </xsl:text>
   <xsl:value-of select="/entity_model/absolute/name"/>
   <xsl:text>{</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:if test="self::entity_type">
      <xsl:text>        return this.parent.absolute;</xsl:text>
   </xsl:if>
   <xsl:if test="self::absolute">
      <xsl:text>        return this;</xsl:text>
   </xsl:if>
   <xsl:call-template name="newline"/>
   <xsl:text>    }</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:if test="self::entity_type">
      <xsl:call-template name="newline"/>
      <xsl:call-template name="get_primary"/>
      <xsl:call-template name="newline"/>
   </xsl:if>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="constructor"/>
   <xsl:call-template name="newline"/>
   <xsl:if test="not(entity_type)">
      <xsl:if test="key('IncomingCompositionRelationships',ancestor-or-self::entity_type/name)/pullback">
          <xsl:call-template name="create_view"/>
      </xsl:if>
      <xsl:if test="key('IncomingCompositionRelationships',ancestor-or-self::entity_type/name)/copy"> 
          <xsl:call-template name="create_copy"/>
      </xsl:if>
   </xsl:if>

   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/reference">
      <!-- make this conditional until such a time as fuller spec for modules -->
      <xsl:if test="key('EntityTypes',type)/module_name">   
         <xsl:call-template name="get_method"/>
      </xsl:if>
   </xsl:for-each>
   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/composition" >
      <!-- make this conditional until such a time as fuller spec for modules -->
      <xsl:if test="key('EntityTypes',type)/module_name">   
        <xsl:call-template name="create_methods"/>
        <xsl:call-template name="newline"/>
      </xsl:if>
   </xsl:for-each>
   <xsl:call-template name="create_initialisation"/>
   <xsl:call-template name="fromXML"/>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
   <xsl:choose>
       <xsl:when test="self::absolute">
         <xsl:call-template name="absolute_toXML"/>
       </xsl:when>
       <xsl:when test="self::entity_type">
         <xsl:call-template name="toXML"/>
       </xsl:when>
   </xsl:choose>
   <xsl:call-template name="newline"/>
   <xsl:text>}</xsl:text>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="get_primary" match="entity_type" mode="explicit">
   <xsl:text>    get primaryKey(): {</xsl:text>
   <xsl:for-each select="js_primary_key/attribute">
     <xsl:value-of select="name"/>: <xsl:value-of select="type"/>
      <xsl:if test="not(position()=last())">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:for-each>
   <xsl:text>} {</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>        return {</xsl:text>
   <xsl:for-each select="js_primary_key/attribute">
     <xsl:call-template name="newline"/>
     <xsl:text>            </xsl:text>
     <xsl:value-of select="name"/>
     <xsl:text>: this</xsl:text>
     <xsl:value-of select="lookup"/>
     <xsl:if test="not(position()=last())">
        <xsl:text>, </xsl:text>
     </xsl:if>
   </xsl:for-each>
   <xsl:call-template name="newline"/>
   <xsl:text>        };</xsl:text>   
   <xsl:call-template name="newline"/>
   <xsl:text>    }</xsl:text>
</xsl:template>
  
<xsl:template name="constructor" match="entity_type|absolute" mode="explicit">
   <xsl:text>    constructor( </xsl:text>
   <xsl:if test="not(self::absolute)">
     <xsl:if test="not(parent::entity_type)">
       <xsl:text>public readonly </xsl:text>
     </xsl:if>
     <xsl:call-template name="parent_member"/>
   </xsl:if>
   <xsl:for-each select="(ancestor::entity_type)/attribute[identifying]">
     <xsl:text>, </xsl:text>
     <xsl:call-template name="data_member"/>
   </xsl:for-each>
   <xsl:for-each select="attribute[identifying]">
     <xsl:text>, public readonly </xsl:text>
     <xsl:call-template name="data_member"/>
   </xsl:for-each>
   <xsl:text>) {</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:if test="parent::entity_type">
      <xsl:text>        super(parent</xsl:text>
      <xsl:for-each select="../attribute[identifying]">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="js_membername"/>
      </xsl:for-each>
      <xsl:text>);</xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:if>
   <xsl:text>    }</xsl:text>
   <xsl:call-template name="newline"/>
</xsl:template> 

<xsl:template name="create_view" match="entity_type" mode="explicit">
   <xsl:text>    static create_view( </xsl:text>
   <xsl:call-template name="parent_member"/>
   <xsl:text>, </xsl:text>
   <xsl:for-each select="ancestor-or-self::entity_type/reference[projection]">
       <xsl:value-of select="js_membername"/>
       <xsl:text>: </xsl:text>
       <xsl:value-of select="js_membertype"/>
   </xsl:for-each>
   <xsl:text>): </xsl:text>
   <xsl:value-of select="js_classname"/>    
   <xsl:text> {</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>        return new </xsl:text>
   <xsl:value-of select="js_classname"/>    
   <xsl:text>( parent</xsl:text>
   <xsl:variable name="actualname">
         <xsl:value-of select="ancestor-or-self::entity_type/reference[projection]/js_membername"/>
   </xsl:variable>
   <xsl:variable name="destet" select="ancestor-or-self::entity_type/reference[projection]/type"/>
   <xsl:for-each select="key('EntityTypes',$destet)/ancestor-or-self::entity_type/attribute[identifying]">
      <xsl:value-of select="concat(', ', $actualname, '.',  name)"/>
   </xsl:for-each>
   <xsl:text>);</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>    }</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="create_copy" match="entity_type" mode="explicit"> 
           <!-- this adapted from create_view which can be changed to work without a [projection] if we get this copy to work without [projection] -->
   <xsl:text>    static create_copy( </xsl:text>
   <xsl:call-template name="parent_member"/>
   <xsl:text>, </xsl:text>
   <!-- <xsl:for-each select="key('IncomingCompositionRelationships',ancestor-or-self::entity_type/name)/copy">   -->
       <xsl:text>subject: </xsl:text>
       <xsl:value-of select="js_classname"/>
   <!-- </xsl:for-each>  -->
   <xsl:text>): </xsl:text>
   <xsl:value-of select="js_classname"/>    
   <xsl:text> {</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>        let newEntity = new </xsl:text>
   <xsl:value-of select="js_classname"/>    
   <xsl:text>(parent</xsl:text>
   <xsl:variable name="actualname">
         <xsl:value-of select="js_classname"/>
   </xsl:variable>
   <xsl:for-each select="ancestor-or-self::entity_type/attribute[identifying]">
      <xsl:value-of select="concat(', subject.',  name)"/>
   </xsl:for-each>
   <xsl:text>);</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:for-each select="ancestor-or-self::entity_type/attribute[not(identifying)]">
      <xsl:value-of select="concat('        newEntity.',name, ' = subject.',  name, ' ;')"/>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
   <xsl:text>        return newEntity;</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>    }</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="ensure_relationship_exists">
  <xsl:param name="varname"/>
  <xsl:call-template name="newline"/>
  <xsl:text>        if (</xsl:text>
  <xsl:value-of select="$varname"/>
  <xsl:text> === undefined) { </xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>            return undefined;</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>        }</xsl:text>
</xsl:template>

<xsl:template name="get_method" match="reference" mode="expicit">
  <xsl:text>    get </xsl:text>
  <xsl:value-of select="js_membername"/>
  <xsl:text>(): </xsl:text>
  <xsl:value-of select="js_membertype"/>
  <xsl:if test="cardinality/ZeroOrOne">
    <xsl:text> | undefined</xsl:text>
  </xsl:if>
  <xsl:text> {</xsl:text>
  <xsl:choose>
  <xsl:when test="cardinality/ZeroOrOne or cardinality/ExactlyOne">
    <xsl:value-of select="diagonal/jscheck"/>
    <xsl:value-of select="jscheck"/>
    <xsl:call-template name="newline"/>
    <xsl:text>        let diagonal = this</xsl:text>
    <xsl:value-of select="diagonal/js"/>
    <xsl:text>;</xsl:text>
    <xsl:if test="navigation_cardinality/OneOrMore or navigation_cardinality/ZeroOneOrMore ">
      <xsl:for-each select="js_foreign_key/attribute[needs_check]">
        <xsl:call-template name="newline"/>
        <xsl:text>        if (</xsl:text>
        <xsl:value-of select="lookup"/>
        <xsl:text> === undefined) {</xsl:text>
        <xsl:call-template name="newline"/>
        <xsl:text>            return undefined;</xsl:text>
        <xsl:call-template name="newline"/>
        <xsl:text>        }</xsl:text>
      </xsl:for-each>
      <xsl:call-template name="newline"/>
      <xsl:text>        let foreignKey = {</xsl:text>
      <xsl:for-each select="js_foreign_key/attribute">
        <xsl:call-template name="newline"/>
        <xsl:text>            </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="lookup"/>
        <xsl:if test="not(position()=last())">
           <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:call-template name="newline"/>
      <xsl:text>        };</xsl:text>
    </xsl:if>
    <xsl:call-template name="newline"/>
    <xsl:text>        return diagonal</xsl:text>
    <xsl:value-of select="riser/js"/>
    <xsl:if test="navigation_cardinality/OneOrMore or navigation_cardinality/ZeroOneOrMore ">
      <xsl:text>.where(e =&gt; util.keysMatch(foreignKey, e.primaryKey))</xsl:text>
      <xsl:text>.withCardinality('</xsl:text>
      <xsl:value-of select="cardinality/*/name()"/>
      <xsl:text>');</xsl:text>
    </xsl:if>
  </xsl:when>
  <xsl:otherwise>
    <!-- these need handcoding in java script for now -->
    <xsl:value-of select="js"/>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="newline"/>
  <xsl:text>    }</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="create_methods" match="composition" mode="expicit">
   <xsl:variable name="membername" select="js_membername"/>
   <xsl:variable name="objecttype" select="js_objecttype"/>
   <xsl:variable name="src_module_name" as="node()?" select="../module_name"/>
   <xsl:variable name="compname" as="node()?" select="name"/>
   <xsl:variable name="cardinality" select="cardinality/*/name()"/>
   <xsl:for-each select="key('EntityTypes',type)/descendant-or-self::entity_type[not(entity_type)]">
         <!-- <xsl:value-of select="$compname"/>  -->
      <xsl:text>    create</xsl:text>
      <xsl:value-of select="if ($compname) then concat('_',$compname) else ''" />
      <xsl:if test="not($compname) or (not(last()=1))">
         <xsl:text>_</xsl:text>
         <xsl:value-of select="js_classname"/>
      </xsl:if>
      <xsl:text>(</xsl:text>
          <xsl:call-template name="data_members_as_formals"/>
      <xsl:text>): </xsl:text>
      <xsl:value-of select="$objecttype"/>
      <xsl:text> {</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:text>        let newEntity = new </xsl:text>
      <xsl:if test="not($src_module_name) or module_name != $src_module_name">
         <xsl:value-of select="module_name"/>
         <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:value-of select="js_classname"/>
      <xsl:text>(this</xsl:text>
      <xsl:for-each select="ancestor-or-self::entity_type/attribute[identifying]">
         <xsl:text>, </xsl:text>
         <xsl:value-of select="js_membername"/>
      </xsl:for-each>
      <xsl:text>);</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:for-each select="ancestor-or-self::entity_type/attribute[not(identifying)]">
         <xsl:text>        newEntity.</xsl:text>
         <xsl:value-of select="js_membername"/>
         <xsl:text> = </xsl:text>
         <xsl:value-of select="js_membername"/>
         <xsl:text>;</xsl:text>
         <xsl:call-template name="newline"/>
      </xsl:for-each>

      <xsl:text>        this.</xsl:text>
      <xsl:value-of select="$membername"/>
      <xsl:choose>
           <xsl:when test="$cardinality = 'ZeroOneOrMore' or $cardinality = 'OneOrMore'">
              <xsl:text>.push(newEntity);</xsl:text>
           </xsl:when>
           <xsl:otherwise>
              <xsl:text>= newEntity;</xsl:text>
           </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="newline"/>
      <xsl:text>        return newEntity;</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:text>    }</xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
</xsl:template>

<xsl:template name="create_initialisation" match="entity_type|absolute" mode="expicit">
   <xsl:text>    initialise (): void { </xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/composition[pullback|copy]" >
        <xsl:text>        if (this</xsl:text>
        <xsl:value-of select="(pullback|copy)/along/js"/>
        <xsl:text> !== undefined) {</xsl:text>
        <xsl:call-template name="newline"/>
      <xsl:choose>
         <xsl:when test="cardinality/ZeroOneOrMore  or cardinality/OneOrMore">
            <xsl:text>            for(let target of this</xsl:text>
            <xsl:value-of select="(pullback|copy)/along/js"/>
            <xsl:text>.</xsl:text>
            <!-- CR-18804 The riser of a pullback-->
            <!-- This code tested with a diff on of car ts on 2 December 2016 -->
            <xsl:value-of select="(copy/riser2/js_descent)|(key('RelationshipBySrcTypeAndName',era:packArray((type,pullback/projection_rel)))/riser/js_descent)"/>
            <xsl:text>) {</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>            let target = this</xsl:text>
            <xsl:value-of select="(pullback|copy)/along/js"/>
            <xsl:text>.</xsl:text>
            <!-- now change this also 2 DEc 2016 
            <xsl:value-of select="(pullback|copy)/riser2/js_descent"/>
            -->
            <xsl:value-of select="(copy/riser2/js_descent)|(key('RelationshipBySrcTypeAndName',era:packArray((type,pullback/projection_rel)))/riser/js_descent)"/>
            <xsl:text>; </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="newline"/>
      <xsl:text>                if (target instanceof </xsl:text>
      <!-- change this 2 Dec 2016 
      <xsl:value-of select="(pullback|copy)/riser2/js_objecttype"/>
      -->
      <xsl:value-of select="(copy/riser2/js_objecttype)|(key('RelationshipBySrcTypeAndName',era:packArray((type,pullback/projection_rel)))/riser/js_objecttype)"/>
      <xsl:text>) {</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:text>                    let newEntity = </xsl:text>
      <xsl:value-of select="js_objecttype"/>
      <xsl:if test="pullback">
         <xsl:text>.create_view(this, target);</xsl:text>
      </xsl:if>
      <xsl:if test="copy">
         <xsl:text>.create_copy(this, target);</xsl:text>
      </xsl:if>
      <xsl:call-template name="newline"/>
      <xsl:choose>
         <xsl:when test="cardinality/ZeroOneOrMore  or cardinality/OneOrMore">
            <xsl:text>                    this.</xsl:text>
            <xsl:value-of select="js_membername"/>
            <xsl:text>.push(newEntity);</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:text>                    newEntity.initialise();</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:text>                }</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>                    this.</xsl:text>
            <xsl:value-of select="js_membername"/>
            <xsl:text> = newEntity;</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:text>                    newEntity.initialise();</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="newline"/>
      <xsl:text>            }</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:text>        }</xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
   <xsl:text>    }</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="fromXML" match="entity_type|absolute" mode="expicit">
   <xsl:text>    static fromXML( </xsl:text>
   <xsl:if test="not(self::absolute)">
      <xsl:call-template name="parent_member"/>
      <xsl:text>, node:Node): </xsl:text>
   </xsl:if>
   <xsl:if test="self::absolute">
      <xsl:text>document: XMLDocument): </xsl:text>
   </xsl:if>
   <xsl:value-of select="js_classname"/>
   <xsl:text>{</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:if test="not(entity_type)">
      <xsl:if test="self::absolute">
         <xsl:text>        let node= util.getNodes(document, ['</xsl:text>
         <xsl:value-of select="js_classname"/>
         <xsl:text>']).withCardinality('ExactlyOne');</xsl:text>
         <xsl:call-template name="newline"/>
      </xsl:if>
      <xsl:text>        let entity = new </xsl:text>
      <xsl:value-of select="js_classname"/>
      <xsl:text>(</xsl:text>
      <xsl:if test="not(self::absolute)">
         <xsl:text>parent</xsl:text>
      </xsl:if>
      <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/attribute[identifying]">
         <xsl:text>,</xsl:text>
         <xsl:call-template name="newline"/>
         <xsl:text>            util.parseAttribute(node, '</xsl:text>
         <xsl:value-of select="name"/>
         <xsl:text>',</xsl:text>
         <xsl:value-of select="boolean(optional)"/>
         <xsl:text>,'</xsl:text>
                <xsl:value-of select="type/*/name()"/>
                <xsl:text>')</xsl:text>
      </xsl:for-each>
      <xsl:text>);</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/attribute[not(identifying)]">
         <xsl:text>        entity.</xsl:text>
         <xsl:value-of select="js_membername"/>
         <xsl:text> = util.parseAttribute(node, '</xsl:text>
         <xsl:value-of select="name"/>
         <xsl:text>',</xsl:text>
         <xsl:value-of select="boolean(optional)"/>
         <xsl:text>,'</xsl:text>
         <xsl:value-of select="type/*/name()"/>
         <xsl:text>')</xsl:text>
         <xsl:text>;</xsl:text>
         <xsl:call-template name="newline"/>
      </xsl:for-each>

      <xsl:call-template name="newline"/>
      <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/composition" >
         <xsl:if test="not(transient)">
             <!-- make this conditional until such a time as fuller spec for modules -->
            <xsl:if test="key('EntityTypes',type)/module_name">   
               <xsl:if test="name">
                  <xsl:text>        let </xsl:text>
                  <xsl:value-of select="js_membername"/>
                  <xsl:text>_children = util.getNodes(node, ['</xsl:text>
                  <xsl:value-of select="name"/>
                  <xsl:text>']).withCardinality('</xsl:text>
                  <xsl:value-of select="if (cardinality/ZeroOrOne or cardinality/ZeroOneOrMore )
                                        then 'ZeroOrOne'
                                        else 'ExactlyOne'"/>
                  <xsl:text>');</xsl:text>
                  <xsl:call-template name="newline"/>
               </xsl:if>
               <xsl:variable name="leaftypes" as="xs:string*">
                   <xsl:for-each select="key('EntityTypes',type)/descendant-or-self::entity_type[not(entity_type)]">
                       <xsl:value-of select="elementName"/>
                   </xsl:for-each>
               </xsl:variable>
               <xsl:variable name="typearray" select="string-join($leaftypes,''', ''')"/> 
               <xsl:text>        </xsl:text>
               <xsl:if test="(cardinality/ZeroOrOne or cardinality/ZeroOneOrMore ) and name">
                  <xsl:text>if (</xsl:text>
                  <xsl:value-of select="js_membername"/>
                  <xsl:text>_children !== undefined) </xsl:text>                  
               </xsl:if>
               <xsl:text>{</xsl:text>
               <xsl:call-template name="newline"/>
               <xsl:choose>
                  <xsl:when test="cardinality/ZeroOneOrMore  or cardinality/OneOrMore">
                     <xsl:text>            util.loadChildren(</xsl:text>
                     <xsl:if test="not(name)">
                        <xsl:text>node</xsl:text>
                     </xsl:if>
                     <xsl:if test="name">
                        <xsl:value-of select="js_membername"/>
                        <xsl:text>_children</xsl:text>
                     </xsl:if>
                     <xsl:text>, ['</xsl:text>
                     <xsl:value-of select="$typearray"/>
                     <xsl:text>'], entity, </xsl:text>
                     <xsl:value-of select="js_objecttype"/>
                     <xsl:text>, entity.</xsl:text>
                     <xsl:value-of select="js_membername"/>
                     <xsl:text>);</xsl:text>
                  </xsl:when>
                  <xsl:when test="cardinality/ZeroOrOne">
                     <xsl:text>            entity.</xsl:text>
                     <xsl:value-of select="js_membername"/>
                     <xsl:text> = </xsl:text>
                     <xsl:text>util.loadChild(</xsl:text>
                     <xsl:if test="not(name)">
                        <xsl:text>node</xsl:text>
                     </xsl:if>
                     <xsl:if test="name">
                        <xsl:value-of select="js_membername"/>
                        <xsl:text>_children</xsl:text>
                     </xsl:if>
                     <xsl:text>, ['</xsl:text>
                     <xsl:value-of select="$typearray"/>
                     <xsl:text>'], entity, </xsl:text>
                     <xsl:value-of select="js_objecttype"/>
                     <xsl:text>);</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>            entity.</xsl:text>
                     <xsl:value-of select="js_membername"/>
                     <xsl:text> = </xsl:text>
                     <xsl:text>util.mustExist("</xsl:text>
                     <xsl:value-of select="if (name) then name else type"/>
                     <xsl:text>", util.loadChild(</xsl:text>
                     <xsl:if test="not(name)">
                        <xsl:text>node</xsl:text>
                     </xsl:if>
                     <xsl:if test="name">
                        <xsl:value-of select="js_membername"/>
                        <xsl:text>_children</xsl:text>
                     </xsl:if>
                     <xsl:text>, ['</xsl:text>
                     <xsl:value-of select="$typearray"/>
                     <xsl:text>'], entity, </xsl:text>
                     <xsl:value-of select="js_objecttype"/>
                     <xsl:text>));</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:call-template name="newline"/>
               <xsl:text>        }</xsl:text>
               <xsl:call-template name="newline"/>
            </xsl:if>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>        return entity; </xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:if>
   <xsl:if test="entity_type">
       <xsl:text>        switch(node.nodeName){</xsl:text>
       <xsl:call-template name="newline"/>
       <xsl:for-each select="entity_type">
          <xsl:text>          case '</xsl:text>
          <xsl:value-of select="name"/>
          <xsl:text>':</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>            return </xsl:text>
          <xsl:value-of select="js_classname"/>
          <xsl:text>.fromXML(parent,node);</xsl:text>
          <xsl:call-template name="newline"/>
       </xsl:for-each>
       <xsl:text>        }</xsl:text>
       <xsl:call-template name="newline"/>
       <xsl:text>        throw new Error('unexpected node name ' + node.nodeName);</xsl:text>
       <xsl:call-template name="newline"/>
   </xsl:if>
   <xsl:text>    }</xsl:text>
</xsl:template>

<xsl:template name="toXML" match="entity_type|absolute" mode="expicit">
   <xsl:text>    toXML(document: XMLDocument, parent:Node): void {</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:text>        let node = util.subElement(document, parent, '</xsl:text>
   <xsl:value-of select="elementName"/>        
   <xsl:text>');</xsl:text>
   <xsl:call-template name="newline"/>
   <xsl:call-template name="serialisation_section"/>
   <xsl:call-template name="newline"/>
   <xsl:text>    }</xsl:text>
</xsl:template>

<xsl:template name="absolute_toXML" match="absolute" mode="expicit">
    <xsl:text>    toXML(document: XMLDocument): XMLDocument {</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:text>        let node = util.subElement(document, document, '</xsl:text>
    <xsl:value-of select="name"/>        
    <xsl:text>');</xsl:text>
    <xsl:call-template name="serialisation_section"/>
    <xsl:call-template name="newline"/>
    <xsl:text>        return document;</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:text>    }</xsl:text>
    <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="serialisation_section" match="absolute|entity_type" mode="expicit">
   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/attribute">
      <xsl:call-template name="newline"/>
      <xsl:text>        util.serialiseAttribute(document, node, '</xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text>',</xsl:text>
      <xsl:value-of select="boolean(optional)"/>
      <xsl:text>,'</xsl:text>
      <xsl:value-of select="type/*/name()"/>
      <xsl:text>',this.</xsl:text>
      <xsl:value-of select="js_membername"/>
      <xsl:text>);</xsl:text>
   </xsl:for-each>

   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/composition" >
      <xsl:if test="not(transient)">
         <!-- make this conditional until such a time as fuller spec for modules -->
         <xsl:if test="key('EntityTypes',type)/module_name">   
            <xsl:call-template name="newline"/>
            <xsl:text>        </xsl:text>
            <xsl:if test="cardinality/ZeroOrOne">
                <xsl:text>if (this.</xsl:text>
                <xsl:value-of select="js_membername"/>
                <xsl:text> !== undefined) </xsl:text>
            </xsl:if>
            <xsl:if test="cardinality/ZeroOneOrMore ">
                <xsl:text>if (this.</xsl:text>
                <xsl:value-of select="js_membername"/>
                <xsl:text>.length &gt; 0) </xsl:text>
            </xsl:if>
            <xsl:text>{</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:text>            let target = </xsl:text>
            <xsl:choose>
               <xsl:when test="name">
                   <xsl:text>util.subElement(document, node,'</xsl:text>
                   <xsl:value-of select="name"/>
                   <xsl:text>')</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:text>node</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:call-template name="newline"/>
            <xsl:choose>
              <xsl:when test="cardinality/ZeroOneOrMore  or cardinality/OneOrMore">
                <xsl:text>            for(let child of this.</xsl:text>
                <xsl:value-of select="js_membername"/>
                <xsl:text>) {</xsl:text>
                <xsl:call-template name="newline"/>
                <xsl:text>                child.toXML(document, target);</xsl:text>
                <xsl:call-template name="newline"/>
                <xsl:text>            }</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>            this.</xsl:text>
                <xsl:value-of select="js_membername"/>
                <xsl:text>.toXML(document, target);</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="newline"/>
            <xsl:text>        }</xsl:text>
         </xsl:if>
      </xsl:if>
   </xsl:for-each>
</xsl:template>

<xsl:template name="list_def" match="entity_type" mode="expicit">
  <xsl:variable name="rel" select="key('IncomingCompositionRelationships', name)"/>
  <xsl:variable name="seq" select="boolean(key('IncomingCompositionRelationships', name))"/>
  <xsl:text>export class </xsl:text>
  <xsl:value-of select="js_listclassname"/>
  <xsl:text> extends </xsl:text>
  <xsl:choose>
    <xsl:when test="$rel[sequence and identifying] and not(attribute[identifying])">
      <xsl:text>EntitySequenceList&lt;</xsl:text>
      <xsl:value-of select="$rel/../js_classname"/>                          <!-- 31/10/2022 was $rel/../name -->
      <xsl:text>, </xsl:text>
      <xsl:value-of select="js_classname"/>
      <xsl:text>&gt; {</xsl:text>
      <xsl:call-template name="newline"/>
      <xsl:text>    protected navigate(parent: </xsl:text>
      <xsl:value-of select="$rel/../js_classname"/>                    <!-- 31/10/2022 was $rel/../name -->
      <xsl:text>) { return parent.</xsl:text>
      <xsl:value-of select="$rel/js_membername"/>
      <xsl:text>; }</xsl:text>
      <xsl:call-template name="newline"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>EntityList</xsl:text>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="js_classname"/>
      <xsl:text>&gt; {</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>
  <xsl:text>    constructor(entities?: </xsl:text>
  <xsl:value-of select="js_classname"/>
  <xsl:text>[]) {</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>        if (entities !== undefined) {</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>            super(entities);</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>        } else {</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>            super();</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>        }</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>        Object.setPrototypeOf(this, </xsl:text>
  <xsl:value-of select="js_listclassname"/>
  <xsl:text>.prototype);</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:text>    }</xsl:text>
  <xsl:call-template name="newline"/>
  <xsl:if test="$seq">
    <xsl:call-template name="list_def_nav"/>
  </xsl:if>
  <xsl:call-template name="list_def_attributes"/>
  <xsl:call-template name="list_def_relationships"/>
  <xsl:call-template name="list_def_subtypes"/>
  <xsl:text>}</xsl:text>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="list_def_nav" match="entity_type" mode="expicit">
</xsl:template>

<xsl:template name="list_def_attributes" match="entity_type" mode="expicit">
   <!-- Attributes -->
   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/attribute">
      <xsl:text>    get </xsl:text>
      <xsl:value-of select="js_membername"/>
      <xsl:text>(): </xsl:text>
      <xsl:value-of select="js_membertype"/>
      <xsl:text>[] {</xsl:text>
      <xsl:choose>
        <xsl:when test="optional">
          <xsl:text> return util.mapDefined(this, e =&gt; e.</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> return this.map(e =&gt; e.</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="js_membername"/>
      <xsl:text>); }</xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:for-each>
   <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="list_def_relationships" match="entity_type" mode="expicit">
   <!-- Relationships -->
   <xsl:for-each select="(self::absolute|ancestor-or-self::entity_type)/(reference|composition)">
      <xsl:variable name="target" select="key('EntityTypes',type)"/>
      <!-- make this conditional until such a time as fuller spec for modules -->
      <xsl:if test="$target/module_name">   
          <xsl:text>    get </xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>(): </xsl:text>
          <xsl:value-of select="js_objectlisttype"/>
          <xsl:text> { return new </xsl:text>
          <xsl:value-of select="js_objectlisttype"/>
          <xsl:text>(</xsl:text>                
          <xsl:choose>
              <xsl:when test="cardinality/ExactlyOne">
                  <xsl:text>this.map(</xsl:text>
              </xsl:when>
              <xsl:when test="cardinality/ZeroOrOne">
                  <xsl:text>util.mapDefined(this, </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>this.flatMap(</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>e =&gt; e.</xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>)); }</xsl:text>
          <xsl:call-template name="newline"/>
      </xsl:if>
   </xsl:for-each>
</xsl:template>

<xsl:template name="list_def_subtypes" match="entity_type" mode="expicit">
  <xsl:for-each select=".//entity_type">
    <xsl:call-template name="newline"/>
    <xsl:text>    as_</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>(): </xsl:text>
    <xsl:value-of select="js_listclassname"/>
    <xsl:text> {</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:text>        return new </xsl:text>
    <xsl:value-of select="js_listclassname"/>
    <xsl:text>(this.flatMap(e =&gt; e instanceof </xsl:text>
    <xsl:value-of select="js_classname"/>
    <xsl:text>? [e] : []));</xsl:text>
    <xsl:call-template name="newline"/>
    <xsl:text>    }</xsl:text>
  </xsl:for-each>
  <xsl:call-template name="newline"/>
</xsl:template>

<xsl:template name="attribute_name_sequence" match="entity_type" mode="expicit">
   <xsl:for-each select="ancestor-or-self::entity_type/attribute">
      <xsl:value-of select="name"/>
   </xsl:for-each>
</xsl:template>

<xsl:template name="identifying_data_members_as_formals" match="entity_type" mode="expicit">
   <xsl:variable name="seq" as="xs:string*">
        <xsl:call-template name="identifying_data_members_decl_sequence"/>
   </xsl:variable>
   <xsl:value-of select="string-join($seq,', ')"/>
</xsl:template>
   
<xsl:template name="data_members_as_formals" match="entity_type" mode="expicit">
   <xsl:variable name="seq" as="xs:string*">
        <xsl:call-template name="data_members_decl_sequence"/>
   </xsl:variable>
   <xsl:value-of select="string-join($seq,', ')"/>
</xsl:template>

<xsl:template name="identifying_data_members_decl_sequence" match="entity_type" mode="expicit">
   <xsl:for-each select="ancestor-or-self::entity_type/attribute[identifying]">
        <xsl:variable name="flatten">
           <xsl:call-template name="data_member"/>
        </xsl:variable>
        <xsl:value-of select="$flatten"/>
   </xsl:for-each>
</xsl:template>

<xsl:template name="data_members_decl_sequence" match="entity_type" mode="expicit">
   <xsl:for-each select="ancestor-or-self::entity_type/attribute">
        <xsl:variable name="flatten">
           <xsl:call-template name="data_member"/>
        </xsl:variable>
        <xsl:value-of select="$flatten"/>
   </xsl:for-each>
</xsl:template>

<xsl:template name="data_member" match="attribute|composition" mode="expicit">
   <xsl:value-of select="js_membername"/>
   <xsl:text>: </xsl:text>
   <xsl:value-of select="js_membertype"/>
   <xsl:if test="optional">
      <xsl:text> | undefined</xsl:text>
   </xsl:if>
</xsl:template>

<xsl:template name="data_member_fields" match="entity_type|absolute" mode="expicit">
  <xsl:for-each select="attribute|composition">
    <!-- need fuller spec for modules -->
    <xsl:if test="not(self::composition) or key('EntityTypes',type)/module_name">
      <xsl:choose>
        <xsl:when test="self::composition and (cardinality/ZeroOneOrMore  or cardinality/OneOrMore)">
          <xsl:call-template name="newline"/>
          <xsl:text>    readonly </xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text> = new </xsl:text>
          <xsl:value-of select="js_objectlisttype"/>
          <xsl:text>();</xsl:text>
          <xsl:call-template name="newline"/>
        </xsl:when>
        <xsl:when test="optional or (self::composition and cardinality/ZeroOrOne)">
          <xsl:call-template name="newline"/>
          <xsl:text>    </xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>?: </xsl:text>
          <xsl:value-of select="js_membertype"/>
          <xsl:text>;</xsl:text>
          <xsl:call-template name="newline"/>
        </xsl:when>
        <xsl:when test="self::composition or not(identifying)">
          <xsl:call-template name="newline"/>
          <xsl:text>    private _</xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>?: </xsl:text>
          <xsl:value-of select="js_membertype"/>
          <xsl:text>;</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>    get </xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>(): </xsl:text>
          <xsl:value-of select="js_membertype"/>
          <xsl:text> {</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>        return util.mustExist("</xsl:text>
          <xsl:value-of select="name"/>
          <xsl:text>", this._</xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>);</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>    }</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>    set </xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text>(value: </xsl:text>
          <xsl:value-of select="js_membertype"/>
          <xsl:text>) {</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>        this._</xsl:text>
          <xsl:value-of select="js_membername"/>
          <xsl:text> = value;</xsl:text>
          <xsl:call-template name="newline"/>
          <xsl:text>    }</xsl:text>
          <xsl:call-template name="newline"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:for-each>

</xsl:template>

<xsl:template name="prologue" match="/entity_model" mode="expicit">
<![CDATA[
/*
 *  Misc utility definitions
 */

export interface Node {
    readonly nodeName: string;
    readonly textContent: string | null;
    readonly childNodes: NodeList;
    appendChild(node: Node): any;
}

export interface XMLDocument extends Node {
    readonly documentElement: Node;
    createElement(name: string): Node;
    createTextNode(text: string): Node;
}

export interface NodeList {
    readonly length: number;
    [index: number]: Node;
}

declare let Object: {
    setPrototypeOf(o: any, p: any): any;
};

export class EntityList<Entity> extends Array<Entity> {
    constructor()
    constructor(count: number)
    constructor(entities: Entity[], indices?: number[])
    constructor(entities?: Entity[] | number, private indices?: number[]) {
        super(typeof entities === 'number' ? entities : 0);
        if (typeof entities !== 'number' && entities !== undefined) {
            this.push(...entities);
        }
        Object.setPrototypeOf(this, EntityList.prototype);
    }
    // This will filter but in a way that preserves the type of the list.
    where(predicate: (e: Entity) => boolean): this {
        let result = util.fresh(this);
        for (let x of this) {
            if (predicate(x)) {
                result.push(x);
            }
        }
        return result;
    }
    flatMap<T>(f: (x: Entity) => T[]): T[] {
        let result: T[] = [];
        for (let x of this) {
            result.push(...f(x));
        }
        return result;
    }
    withCardinality(cardinality: 'ZeroOrOne'): Entity | undefined;
    withCardinality(cardinality: 'ExactlyOne'): Entity;
    withCardinality(cardinality: 'ZeroOneOrMore' | 'OneOrMore'): Entity[];
    withCardinality(cardinality: 'ZeroOrOne' | 'ExactlyOne' | 'ZeroOneOrMore' | 'OneOrMore'): Entity | Entity[] | undefined {
        switch (cardinality) {
            case 'ExactlyOne':
                if (this.length === 1) {
                    return this[0];
                }
                break;
            case 'ZeroOrOne':
                if (this.length === 1) {
                    return this[0];
                }
                if (this.length === 0) {
                    return undefined;
                }
                break;
            case 'ZeroOneOrMore':
                return this;
            case 'OneOrMore':
                if (this.length >= 1) {
                    return this;
                }
                break;
            default:
                throw new Error('unexpected cardinality: ' + cardinality);
        }
        throw new Error('unexpected number of entities for cardinality ' + cardinality +', found ' + this.length.toString());
    }
}

export abstract class EntitySequenceList<Parent, Entity extends {parent: Parent}> extends EntityList<Entity> {
    constructor(entities?: Entity[]) {
        super(entities);
        Object.setPrototypeOf(this, EntitySequenceList.prototype);
    }
    protected abstract navigate(parent: Parent): EntityList<Entity>;
    // For sequence compositions.
    atIndex(idx: number): this {
        let result = util.fresh(this);
        for (let x of this) {
            let list = this.navigate(x.parent);
            if (list[idx] === x) {
                result.push(x);
            }
        }
        return result;
    }
}

module util {
    export function getNodes(node: Node, names: string[]): EntityList<Node> {
        let found = new EntityList<Node>();
        let children = node.childNodes;
        for (let i = 0; i < children.length; i++) {
            if (names.indexOf(children[i].nodeName) !== -1) {
                found.push(children[i]);
            }
        }
        return found;
    }
    
    export function getNodeText(node: Node, name: string, isOpt: true, deft?: string): string | undefined;
    export function getNodeText(node: Node, name: string, isOpt: false): string;
    export function getNodeText(node: Node, name: string, isOpt: boolean, deft?: string): string | undefined;
    export function getNodeText(node: Node, name: string, isOpt: boolean, deft?: string): string | undefined {
        let nodes = getNodes(node, [name]);
        let text: string | null = null;
        if (isOpt) {
            let node = nodes.withCardinality('ZeroOrOne');
            if (node !== undefined) {
                text = node.textContent;
            }
        } else {
            text = nodes.withCardinality('ExactlyOne').textContent;
        }
        if (text !== null) {
            return text;
        }
        if (isOpt) {
            if (deft !== undefined) {
                return deft;
            }
            return undefined;
        }
        throw new Error('could not find result node ' + name);
    }

    export function subElement(document: XMLDocument, parent: Node, tag: string): Node {
        let node = document.createElement(tag);
        parent.appendChild(node);
        return node;
    }
    
    export function addText(document: XMLDocument, element: Node, text: string): void {
        var node = document.createTextNode(text);
        element.appendChild(node);
    }

    interface EntityLoader<Parent, Child> {
        fromXML(parent: Parent, node: Node): Child;
    }

    export function loadChildren<Parent, Child>(node: Node, names: Array<string>, parent: Parent, loader: EntityLoader<Parent, Child>, into: Child[]): void {
        for (let child of getNodes(node, names)) {
            into.push(loader.fromXML(parent, child));
        }
    }

    export function loadChild<Parent, Child>(node: Node, names: string[], parent: Parent, loader: EntityLoader<Parent, Child>): Child | undefined {
        let child = getNodes(node, names).withCardinality('ZeroOrOne');
        if (child === undefined) {
            return undefined;
        }
        return loader.fromXML(parent, child);
    }

    export function mustExist<T>(name: string, x: T | undefined): T {
        if (x === undefined) {
            throw new Error(name + ' missing');
        }
        return x;
    }

    export function mapDefined<T, U>(array: T[], select: (x: T) => (U | undefined)): U[] {
        let result: U[] = [];
        for (let x of array) {
            let toAdd = select(x);
            if (toAdd !== undefined) {
                result.push(toAdd);
            }
        }
        return result;
    }

    export function keysMatch<Foreign extends Primary, Primary>(foreign: Foreign, primary: Primary): boolean {
        for (let m in primary) if (primary.hasOwnProperty(m)) {
            if ((foreign as any)[m] !== (primary as any)[m]) {
                return false;
            }
        }
        return true;
    }
        
    export function getISODate(attr: string): Date {
        let parsed = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\.\d{3})?Z$/.exec(attr);
        if (parsed === null) {
            throw new Error('malformed date: ' + attr);
        }
        let vals = parsed.slice(1).map(x => parseInt(x, 10));
        let year = vals[0],
            month = vals[1] - 1,
            day = vals[2],
            hour = vals[3],
            minute = vals[4],
            second = vals[5];
        return new Date(year, month, day, hour, minute, second);
    }
    
    type Attribute = boolean | string | number | Date | undefined;
    type AttributeType = 'boolean' | 'string' | 'integer' | 'float' | 'positiveInteger' | 'date' | 'time' | 'dateTime';
    
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'boolean'): boolean | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'string'): string | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'integer'): number | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'float'): number | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'positiveInteger'): number | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: true, erTypeName: 'date' | 'time' | 'dateTime'): Date | undefined;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'boolean'): boolean;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'string'): string;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'integer'): number;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'float'): number;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'positiveInteger'): number;
    export function parseAttribute(node: Node, name: string, isOpt: false, erTypeName: 'date' | 'time' | 'dateTime'): Date;
    export function parseAttribute(node: Node, name: string, isOpt: boolean, erTypeName: AttributeType): never;
    export function parseAttribute(node: Node, name: string, isOpt: boolean, erTypeName: AttributeType): Attribute {
        let attr = getNodeText(node, name, isOpt);
        if (attr === undefined) {
            if (isOpt) {
                return undefined;
            }
            throw new Error('expecting attribute ' + name);
        }
        switch (erTypeName) {
            case 'boolean':
                return attr === 'true';
            case 'string':
                return attr;
            case 'positiveInteger':
            case 'integer':
                return parseInt(attr, 10);
            case 'float':
                return parseFloat(attr);
            case 'date':
            case 'time':
            case 'dateTime':
                return getISODate(attr);
        }
        
        throw new Error('unsupported attribute type: ' + erTypeName);
    }

    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'boolean', value: boolean | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'string', value: string | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'integer', value: number | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'float', value: number | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'positiveInteger', value: number | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: 'date' | 'time' | 'dateTime', value: Date | undefined): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: string, value: never): void;
    export function serialiseAttribute(document: XMLDocument, node: Node, name: string, isOpt: boolean, erTypeName: AttributeType, value: Attribute): void {
        if (value === undefined) {
            if (!isOpt) {
                throw new Error("missing required attribute " + name);
            }
            return;
        } 
        let attr: string;
        switch (erTypeName) {
            case 'date':
            case 'time':
            case 'dateTime':
                attr = (value as Date).toISOString();
                break;
            default:
                attr = value.toString();
                break;
        }
        let element = subElement(document, node, name);            
        addText(document, element, attr);
    }  

    export function fresh<T>(x: T, ...args: any[]): T {
        let cons = <any>x.constructor;
        return new cons(...args);
    }
}
]]>
</xsl:template>


</xsl:transform>

<!-- end of file: ERmodel_v1.2/src/ERmodel2.ts.xslt--> 

