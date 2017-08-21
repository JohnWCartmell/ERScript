<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.elaboration_xslt.xslt 
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
ERmodel2.elaboration_integrity_xslt.xslt
****************************************

DESCRIPTION
  This xslt generates an xslt from a physical R model i.e. from an instance 
  of ERmodelERmodel.xslt that has been processed by the ERmodel2.physical 
  chain of enrichments.

  It supports elaboration of include directives and elaboration of pullbacks.


CHANGE HISTORY
CR-18708 JC  27-Nov-2016 Created
         JC  04-Dec-2016 Commence support for pullbacks involving unnamed compositions
CR-19099 JC  18-Jan-2016 Support for include directive.
         JC  17-Feb-2017 debug support for pullbacks - addition wildcard template generated.
-->


<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:strip-space elements="*" />

<xsl:output method="xml" indent="yes"/>

<xsl:key name="entity_type" match="entity_type" use="name"/>

<xsl:template name="generate_invoke_pass">
   <xsl:param name="passno"/>
   <xsl:element name="xsl:copy" namespace="http://www.w3.org/1999/XSL/Transform">
      <xsl:element name="xsl:apply-templates">
         <xsl:attribute name="mode" select="concat('pass_',$passno)"/>
      </xsl:element>
   </xsl:element>
</xsl:template>

<xsl:template name="generate_root_template">
    <xsl:element name="xsl:template" namespace="http://www.w3.org/1999/XSL/Transform">
       <xsl:attribute name="match" select="'/'"/>

      <xsl:variable name="finalpassno" select="max((//pbe_passno,0))"/>
      <xsl:message>final passno is <xsl:value-of select="$finalpassno"/> </xsl:message>

       <xsl:for-each select="distinct-values((//pbe_passno,'0'))">
	   <xsl:variable name="passno" select="." />
	   <xsl:message> generate pass no <xsl:value-of select="$passno"/> </xsl:message>
	   <xsl:choose>
	      <xsl:when test="$passno='0' and $finalpassno=0">
		   <xsl:call-template name="generate_invoke_pass">
		      <xsl:with-param name="passno" select="$passno"/>
		   </xsl:call-template>
	      </xsl:when>
	      <xsl:when test="$passno='0'">
		 <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
		     <xsl:attribute name="name" select="concat('state_',$passno)"/>
		     <xsl:call-template name="generate_invoke_pass">
			<xsl:with-param name="passno" select="$passno"/>
		     </xsl:call-template>
		 </xsl:element>
	      </xsl:when>
	      <xsl:when test="number($passno)=$finalpassno">
		 <xsl:element name="xsl:for-each">
		    <xsl:attribute name="select" select="concat('$state_',$passno - 1)"/>
		    <xsl:call-template name="generate_invoke_pass">
		       <xsl:with-param name="passno" select="$passno"/>
		    </xsl:call-template>
		 </xsl:element>
	      </xsl:when>
	      <xsl:otherwise>
		 <xsl:element name="xsl:variable" namespace="http://www.w3.org/1999/XSL/Transform">
		     <xsl:attribute name="name" select="concat('state_',$passno)"/>
		     <xsl:element name="xsl:for-each">
			<xsl:attribute name="select" select="concat('$state_',$passno - 1)"/>
			<xsl:call-template name="generate_invoke_pass">
			     <xsl:with-param name="passno" select="$passno"/>
			</xsl:call-template>
		     </xsl:element>
		 </xsl:element>
	      </xsl:otherwise>
	   </xsl:choose>
       </xsl:for-each>
    </xsl:element>
</xsl:template>

<xsl:template name="generate_wildcards" >
   <xsl:for-each select="distinct-values((//pbe_passno,'0'))">
      <xsl:variable name="passno" select="." />
         <xsl:element name="xsl:template" >
              <xsl:attribute name="match" select="'*'"/>
              <xsl:attribute name="mode" select="concat('pass_',$passno)"/>
              <xsl:element name="xsl:copy">
                 <xsl:element name="xsl:apply-templates">
                    <xsl:attribute name="mode" select="concat('pass_',$passno)"/>
                 </xsl:element>
              </xsl:element>
          </xsl:element>
   </xsl:for-each>
   <xsl:element name="xsl:template" >
      <xsl:attribute name="match" select="'*'"/>
      <xsl:element name="xsl:copy">
          <xsl:element name="xsl:apply-templates"/>
      </xsl:element>
   </xsl:element>
</xsl:template>

<xsl:template name="generate_total_include" >
   <xsl:element name="xsl:template" >
      <xsl:attribute name="match" select="'include[not(*/self::type)]'"/>
      <xsl:attribute name="mode" select="'pass_0'"/>
      <xsl:element name="xsl:apply-templates">
          <xsl:attribute name="select" select="'document(filename)/*/*'"/>
          <xsl:attribute name="mode" select="'pass_0'"/>
      </xsl:element>
   </xsl:element>
</xsl:template>

<xsl:template name="generate_typed_include_level_1" >
   <xsl:element name="xsl:template" >
      <xsl:attribute name="match" select="'/*/include[*/self::type]'"/>
      <xsl:attribute name="mode" select="'pass_0'"/>
      <xsl:element name="xsl:variable">
          <xsl:attribute name="name" select="'temp'"/>
          <xsl:attribute name="select" select="'../name()'"/>   
      </xsl:element>
      <xsl:element name="xsl:apply-templates">
          <xsl:attribute name="select" select="'document(filename)/*[name()=$temp]/*[name()=current()/type]'"/>
          <xsl:attribute name="mode" select="'pass_0'"/>
      </xsl:element>
   </xsl:element>
</xsl:template>

<xsl:template name="generate_typed_include_level_2" >
   <xsl:element name="xsl:template" >
      <xsl:attribute name="match" select="'/*/*/include[*/self::type]'"/>
      <xsl:attribute name="mode" select="'pass_0'"/>
      <xsl:element name="xsl:variable">
          <xsl:attribute name="name" select="'temp'"/>
          <xsl:attribute name="select" select="'../../name()'"/>   
      </xsl:element>
      <xsl:element name="xsl:variable">
          <xsl:attribute name="name" select="'temp2'"/>
          <xsl:attribute name="select" select="'../name()'"/>   
      </xsl:element>
      <xsl:element name="xsl:apply-templates">
          <xsl:attribute name="select" select="'document(filename)/*[name()=$temp]/*[name()=$temp2]/*[name()=current()/type]'"/>
          <xsl:attribute name="mode" select="'pass_0'"/>
      </xsl:element>
   </xsl:element>
</xsl:template>

<xsl:template match="/">
      <xsl:element name="xsl:transform">
         <xsl:attribute name="version">2.0</xsl:attribute>
         <xsl:namespace name="era" select="'http://www.entitymodelling.org/ERmodel'"/>
         <xsl:if test="entity_model/xml/namespace_uri">
             <xsl:attribute name="xpath-default-namespace"
                            select="/entity_model/xml/namespace_uri"/>
         </xsl:if>
         <xsl:element name ="xsl:output">
             <xsl:attribute name="method">xml</xsl:attribute>
             <xsl:attribute name="indent">yes</xsl:attribute>
         </xsl:element>
         <xsl:element name="xsl:include">
             <xsl:attribute name="href">ERmodel.functions.module.xslt</xsl:attribute>
         </xsl:element>
         <!-- plant keys for primary keys-->
         <xsl:apply-templates mode="key_section"/>

         <xsl:call-template name="generate_root_template"/>  

         <xsl:call-template name="generate_wildcards"/>  

         <xsl:call-template name="generate_total_include"/>  
         <xsl:call-template name="generate_typed_include_level_1"/>  
         <xsl:call-template name="generate_typed_include_level_2"/>  
         <!-- 
           plant template for every entity type 
           having outgoing pullbacks relationships
         -->
         <xsl:apply-templates />
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

<xsl:template match="*" >
</xsl:template>

<xsl:template  match="entity_model|group" >
      <xsl:apply-templates />
</xsl:template>

<xsl:template  match="entity_type|absolute">
   <xsl:if test="not(entity_type)">
      <xsl:variable name="current_entity_type" as="element()" select="."/>

      <xsl:for-each select="distinct-values((ancestor-or-self::entity_type|self::absolute)/composition/pullback/pbe_passno)">
         <xsl:variable name="passno" select="."/>
         <xsl:for-each select="$current_entity_type">
            <xsl:element name="xsl:template" >
               <xsl:attribute name="match" select="xpath_qualified_type_classifier"/>
               <xsl:attribute name="mode" select="concat('pass_',$passno)"/>   
               <xsl:element name="xsl:copy">
                  <xsl:element name="xsl:apply-templates">
                     <xsl:attribute name="mode" select="concat('pass_',$passno)"/>
                     <xsl:attribute name="select">
                        <xsl:text>*[not(</xsl:text>
                        <xsl:value-of select="string-join((ancestor-or-self::entity_type|self::absolute)/
                                                  composition[pullback/pbe_passno=$passno]/
                                                  concat('self::',if(name)then name else type),' or ')"/> 
                                                              <!-- need generalise to type classifier -->
                        <xsl:text>)]</xsl:text>
                     </xsl:attribute>
                  </xsl:element>
                  <xsl:for-each select="(ancestor-or-self::entity_type|self::absolute)/
                                                  composition[pullback/pbe_passno=$passno]">
                       <xsl:element name="xsl:call-template">
                            <xsl:attribute name="name" select="concat(if (name) then name else 'anon',
                                                                    '_',key('entity_type',type)/identifier)"/>   
                       </xsl:element>
                   </xsl:for-each>
               </xsl:element>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:if>
   <xsl:apply-templates/>
</xsl:template>

<xsl:template  match="composition[pullback]" >
  <xsl:message> at pullback </xsl:message>
  <xsl:element name="xsl:template" >
     <xsl:attribute name="name" select="concat(if (name) then name else 'anon','_',key('entity_type',type)/identifier)"/>   
     <xsl:choose>
        <xsl:when test="name">
           <xsl:element name="{name}">
               <xsl:call-template name="pullbackbody"/>
           </xsl:element>
        </xsl:when>
        <xsl:otherwise>
           <xsl:call-template name="pullbackbody"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:element>
</xsl:template>


<xsl:template name="pullbackbody" match="composition[pullback]"  mode="explicit">
         <xsl:element name="xsl:for-each">
            <xsl:attribute name="select" select="pullback/xpath_iterate"/>
            <xsl:element name="xsl:choose">
               <xsl:element name="xsl:when">
                  <xsl:attribute name="test" select="concat('self::*:',key('entity_type',type)/elementName)"/>     <!-- GENERALISE type ?? -->
                     <xsl:element name="xsl:copy">
                        <xsl:element name="xsl:apply-templates"/>
                     </xsl:element>
               </xsl:element>
               <xsl:element name="xsl:otherwise">
                     <xsl:element name="{key('entity_type',type)/elementName}">                                  <!-- GENERALISE type ? -->
                        <xsl:for-each select="key('entity_type',type)/value/implementationOf[rel=current()/pullback/projection_rel]">
                            <!-- could be choice? -->
                            <xsl:element name="{../name}">
                                <xsl:element name="xsl:value-of">
                                    <xsl:attribute name="select" select="destattr"/>                 <!-- might need navigate up here for cascaded key -->
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                     </xsl:element>
               </xsl:element>
           </xsl:element>
        </xsl:element>
</xsl:template>


</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.elaboration_xslt.xslt--> 

