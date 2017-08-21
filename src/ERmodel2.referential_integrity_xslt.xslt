<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.referential_integrity_xslt.xslt 
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
****************************************
ERmodel2.referential_integrity_xslt.xslt
****************************************

DESCRIPTION
  This xslt generates an xslt from a physical R model i.e. from an instance 
  of ERmodelERmodel.xslt that has been processed by the ERmodel2.physical 
  chain of enrichments.

  It generates into the output xslt  xpath expressions for the evaluation 
  of reference relationships that are produced prior to this xslt by the 
  enrichment ERmodel2.xpath.enrichment.xslt.

DISCUSSION
  Currently the xpath enrichment is only used from this transform 
  therefore the process could be modified so that the xpath enrichment 
  was invoked from this transofrm and not from the prior ERmodel2.physical transform.


CHANGE HISTORY
         JC  27-Jun-2016 Created
         JC  14-Oct-2016 Do not generate an integrity check for a 
                         reference relationshop which has a key constraint. 
         JC  19-Oct-2016 Do not generate an integrity check for a reference 
                        relationship whose destination type is in a group 
                        named 'external'
CR-18553 JC  25-Oct-2016 Replace use of mangleName by 'identifier' in names 
                         of generated keys.
         JC  04-Nov-2016 Completion of initial development. Tested on
                         ERmodels and chromatography_analysis_records.
CR-18675 JC  09-Nov-2016 Modify the generated xslt to terminate with error
                         if referential integrity errors are found.
             14-Nov-2016 Output current state to a separate .errors
                         xml to get output with embedded errors.
CR-18839 JC  02-Dec-2016 Modify to expand the ER functions library
             14-Dec-2016 instead of generating an include and pass
                         a text representation of all errors as
                         second argument to the call of the error 
                         function.
-->


<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:strip-space elements="*" />

<xsl:output method="xml" indent="yes"/>

<xsl:key name="entity_type" match="entity_type" use="name"/>


<xsl:template name="generate_root_template">
    <!-- straight-copy template -->
    <xsl:element name="xsl:template" namespace="http://www.w3.org/1999/XSL/Transform">
       <xsl:attribute name="match" select="'*'"/>
       <xsl:attribute name="mode" select="'straight_copy'"/>
       <xsl:element name="xsl:copy" namespace="http://www.w3.org/1999/XSL/Transform">
          <xsl:element name="xsl:apply-templates">
             <xsl:attribute name="mode" select="'straight_copy'"/>
          </xsl:element>
       </xsl:element>
    </xsl:element>



   <xsl:element name="xsl:template" namespace="http://www.w3.org/1999/XSL/Transform">
      <xsl:attribute name="match" select="'/'"/>
      <!-- in_filename -->
      <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
         <xsl:attribute name="name" select="'in_filename'"/>
         <xsl:attribute name="select" select="'tokenize(base-uri(),''/'')[last()]'"/>
      </xsl:element>
      <!-- in_filename_wo_extension -->
      <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
         <xsl:attribute name="name" select="'in_filename_wo_extension'"/>
         <xsl:attribute name="select" select="'substring-before($in_filename,''.xml'')'"/>
      </xsl:element>
      <!-- out_filename -->
      <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
         <xsl:attribute name="name" select="'error_filename'"/>
         <xsl:attribute name="select" select="'concat($in_filename_wo_extension,''.errors.xml'')'"/>
      </xsl:element>

      <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
         <xsl:attribute name="name" select="'state'"/>
         <xsl:element name="xsl:apply-templates"/>
      </xsl:element>

      <xsl:element name="xsl:choose">
         <xsl:element name="xsl:when" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="test" select="'boolean($state/descendant-or-self::*:error)'"/>
               <xsl:element name="xsl:result-document" namespace="http://www.w3.org/1999/XSL/Transform">
                  <xsl:attribute name="href" select="'{$error_filename}'"/>
                  <xsl:element name="xsl:for-each" namespace="http://www.w3.org/1999/XSL/Transform">
                     <xsl:attribute name="select" select="'$state/*'"/>
                     <xsl:element name="xsl:copy" namespace="http://www.w3.org/1999/XSL/Transform">
                        <xsl:element name="xsl:apply-templates">
                               <xsl:attribute name="mode" select="'straight_copy'"/>
                        </xsl:element>
                     </xsl:element>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
                  <xsl:attribute name="name" select="'errortext'"/>
                  <xsl:attribute name="select" select="'string(string-join($state/descendant-or-self::*:error,''-----------------------''))'"/>
               </xsl:element>
               <xsl:element name="xsl:value-of" namespace="http://www.w3.org/1999/XSL/Transform">
                  <xsl:attribute name="select" select="'error(QName(''http://www.entitymodelling.org/ERmodel'', ''ReferentialIntegrityError''),$errortext)'"/>
               </xsl:element>
         </xsl:element>
         <xsl:element name="xsl:otherwise" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:element name="xsl:for-each" namespace="http://www.w3.org/1999/XSL/Transform">
               <xsl:attribute name="select" select="'$state/*'"/>
               <xsl:element name="xsl:copy" namespace="http://www.w3.org/1999/XSL/Transform">
                  <xsl:element name="xsl:apply-templates">
                     <xsl:attribute name="mode" select="'straight_copy'"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:element>
</xsl:template>



<xsl:template match="/">
      <xsl:element name="xsl:transform">
         <xsl:attribute name="version">2.0</xsl:attribute>
         <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
         <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'"/>
         <xsl:if test="entity_model/xml/namespace_uri">
             <xsl:message> GENERATING NAMESPACE </xsl:message>
             <xsl:attribute name="xpath-default-namespace"
                            select="/entity_model/xml/namespace_uri"/>
         </xsl:if>
         <xsl:element name ="xsl:output">
             <xsl:attribute name="method">xml</xsl:attribute>
             <xsl:attribute name="indent">yes</xsl:attribute>
         </xsl:element>
<!--
         <xsl:element name="xsl:include">
             <xsl:attribute name="href">ERmodel.functions.module.xslt</xsl:attribute>
         </xsl:element>

-->
         <xsl:value-of disable-output-escaping="yes" select="unparsed-text('ERmodel.functions.fragment.xslt')"/>

         <!-- plant keys for primary keys-->
         <xsl:apply-templates mode="key_section"/>

         <xsl:call-template name="generate_root_template"/>

         <!-- plant wildcard template -->
         <xsl:element name="xsl:template" >
            <xsl:attribute name="name" select="'wildcard'"/>   
            <xsl:attribute name="match" select="'*'"/>
            <xsl:element name="xsl:copy">
               <xsl:element name="xsl:apply-templates"/>
            </xsl:element>
         </xsl:element>

         <!-- plant template for every entity type -->
         <xsl:apply-templates mode="main_section"/>
      </xsl:element>
</xsl:template>


<xsl:template match="*" mode="key_section">
</xsl:template>

<xsl:template match="entity_model|group" mode="key_section">
   <xsl:apply-templates mode="key_section"/>
</xsl:template>

<xsl:template match="entity_type" mode="key_section">
  <xsl:apply-templates mode="key_section"/>
  <xsl:if test="xpath_primary_key != ''">
     <xsl:element name="xsl:key" >
         <xsl:attribute name="name" select="identifier"/>
         <xsl:attribute name="match" select="xpath_qualified_type_classifier"/>  
         <xsl:attribute name="use" select="xpath_primary_key"/>
     </xsl:element>
  </xsl:if>
</xsl:template>


<xsl:template match="*" mode="main_section">
</xsl:template>

<xsl:template  match="entity_model|group" mode="main_section">
           <xsl:apply-templates mode="main_section"/>
</xsl:template>

<xsl:template  match="entity_type|absolute" mode="main_section">
  <xsl:choose>
  <xsl:when test="not(entity_type)">
     <xsl:element name="xsl:template" >
        <xsl:attribute name="name" select="identifier"/>   
        <xsl:attribute name="match" select="xpath_qualified_type_classifier"/>
        <xsl:element name="xsl:copy">
           <xsl:element name="xsl:apply-templates"/>
           <xsl:apply-templates mode="main_section" select="reference"/>
           <xsl:if test="..[self::entity_type]">
                <xsl:element name="xsl:call-template">
                     <xsl:attribute name="name" select="../identifier"/>   
                </xsl:element>
            </xsl:if>
        </xsl:element>
     </xsl:element>
  </xsl:when>
  <xsl:otherwise>
     <xsl:element name="xsl:template" >
        <xsl:attribute name="name" select="identifier"/>   
        <xsl:apply-templates mode="main_section" select="reference"/>
        <xsl:if test="..[self::entity_type]">
           <xsl:element name="xsl:call-template">
               <xsl:attribute name="name" select="../identifier"/>   
           </xsl:element>
        </xsl:if>
     </xsl:element>
     <xsl:apply-templates mode="main_section" select="entity_type"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template  match="reference" mode="main_section">
  <xsl:if test="not(key('entity_type',type)/ancestor::group[name='external'])">
     <xsl:if test="xpath_is_defined and not(xpath_is_defined='')and xpath_foreign_key">  
                           <!-- currently do not need check anythng is a reference relationship has a key constraint-->
        <xsl:if test="not(diagonal)">
            <xsl:call-template name="reference_test" />
        </xsl:if>
        <xsl:if test="diagonal">
           <xsl:element name="xsl:variable" >
              <xsl:attribute name="name" select="'DIAG'"/>
              <xsl:attribute name="as" select="'node()*'"/>
              <xsl:attribute name="select" select="diagonal/*/xpath_evaluate"/>
           </xsl:element>
           <xsl:element name="xsl:if" >
              <xsl:attribute name="test" select="'$DIAG'"/>
              <xsl:call-template name="reference_test"/>
           </xsl:element>
        </xsl:if>
     </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template name="reference_test" match="reference" mode="explicit">
        <xsl:element name="xsl:if" >
           <xsl:attribute name="test" select="xpath_is_defined"/>
           <xsl:element name="xsl:variable" >
              <xsl:attribute name="name" select="'DEST'"/>
              <xsl:attribute name="as" select="'node()*'"/>
              <xsl:attribute name="select" select="xpath_evaluate"/>
           </xsl:element>
           <xsl:element name="xsl:if" >
              <xsl:attribute name="test" select="concat('not($DEST[',xpath_typecheck,'])')"/>
              <xsl:element name="xsl:variable" >
                 <xsl:attribute name="name" select="'FK'"/>
                 <xsl:attribute name="select" select="xpath_foreign_key"/>
              </xsl:element>
              <xsl:element name="xsl:variable" >
                   <xsl:attribute name="name" select="'MESSAGE'" />
                    Entity of type <xsl:value-of select="../name"/> 
                        <xsl:if test="../xpath_primary_key != ''">
                              keyed by 
                             <xsl:element name="xsl:value-of">
                                <xsl:attribute name="select" select="../xpath_primary_key"/>
                             </xsl:element> 
                        </xsl:if>
                   has broken reference relationship '<xsl:value-of select="name"/>' of type '<xsl:value-of select="type"/>'
                   ... foreign key '<xsl:element name="xsl:value-of">
                        <xsl:attribute name="select" select="'$FK'"/>
                    </xsl:element>'
              </xsl:element>
              <xsl:element name="xsl:message" >
                 <xsl:element name="xsl:value-of">
                    <xsl:attribute name="select" select="'$MESSAGE'"/>
                 </xsl:element>
              </xsl:element>
              <xsl:element name="xsl:element" >
                 <xsl:attribute name="name" select="'error'"/>
                 <xsl:element name="xsl:value-of">
                    <xsl:attribute name="select" select="'$MESSAGE'"/>
                 </xsl:element>
              </xsl:element>
           </xsl:element>
        </xsl:element>
</xsl:template>
</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.referential_integrity_xslt.xslt--> 

