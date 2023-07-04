<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.class_enrichment.module.xslt 
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
*************************************
ERmodel2.class_enrichment.module.xslt
*************************************

DESCRIPTION
  This xslt contains definitions of enrichment attributes whose
  definitions can be shared between java, python and typescript
  code generators.


      entity_type =>
         module_name      
      


CHANGE HISTORY

CR18533 JC  24-Oct-2016 Created. Definition of 'module_name'
                        moved from the ERmodel2.physical.xslt.

-->

<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:output method="text" indent="no"/>

<xsl:template name="recursive_class_enrichment">
   <xsl:param name="document"/>
   <xsl:variable name ="next">
      <xsl:for-each select="$document">
         <xsl:copy>
           <xsl:apply-templates mode="recursive_class_enrichment"/>
         </xsl:copy>
      </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="result">
      <xsl:choose>
         <xsl:when test="not(deep-equal($document,$next))">
            <xsl:message> changed in class enrichment</xsl:message>
            <xsl:call-template name="recursive_class_enrichment">
               <xsl:with-param name="document" select="$next"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message> unchanged fixed point of class enrichment</xsl:message>
            <xsl:copy-of select="$document"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>  
   <xsl:copy-of select="$result"/>
</xsl:template>

<xsl:template match="*" mode="recursive_class_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_class_enrichment"/>
   </xsl:copy>
</xsl:template>


<xsl:template match="entity_type[not(module_name)][parent::*/module_name]" mode="recursive_class_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_class_enrichment"/>
          <module_name><xsl:value-of select="parent::*/module_name"/></module_name>
   </xsl:copy>
</xsl:template>

<xsl:template match="entity_type[not(module_name)]
                                [not(parent::*/module_name)]
                                [//entity_type[name eq current()/ancestor-or-self::entity_type/dependency[1]/type]]" 
              mode="recursive_class_enrichment" >
   <xsl:copy>
      <xsl:apply-templates mode="recursive_class_enrichment"/>
      <xsl:variable name="structuralParent"
                    as="element()" 
                    select="//entity_type[name eq current()/ancestor-or-self::entity_type/dependency[1]/type]"/>
      <xsl:if test="$structuralParent/module_name">
       <module_name><xsl:value-of select="$structuralParent/module_name"/></module_name>
      </xsl:if>
   </xsl:copy>
</xsl:template>

<xsl:template match="entity_type[not(module_name)]
                     [not(parent::*/module_name)]
                     [not(//entity_type[name eq current()/ancestor-or-self::entity_type/dependency[1]/type])]
                     [child::entity_type/module_name]"
                     mode="recursive_class_enrichment">
   <xsl:copy>
      <xsl:apply-templates mode="recursive_class_enrichment"/>
       <xsl:copy-of select="(child::entity_type/module_name)[1]"/>
   </xsl:copy>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.class_enrichment.module.xslt--> 

