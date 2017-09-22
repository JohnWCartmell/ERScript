<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.v1.2_to_v1.4_xslt.xslt 
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
ERmodelv1.3_to_v1.4.xslt
****************************************

DESCRIPTION


CHANGE HISTORY

-->


<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xmlns="http://www.entitymodelling.org/ERmodel"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<xsl:strip-space elements="*" />

<xsl:output method="xml" indent="yes"/>

<xsl:template match="*" >
   <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template match="value">
    <attribute>
        <xsl:apply-templates/>
    </attribute>
</xsl:template>

<!--
<xsl:template match="value/type">
    <type>
        <xsl:element name="{.}"/>
    </type>
</xsl:template>

<xsl:template match="cardinality">
    <cardinality>
        <xsl:element name="{.}"/>
    </cardinality>
</xsl:template>

-->

<xsl:template match="
                     presentation/name
                     |
                     label/name
                     |
                     cardinality
                     |
                     value/type
                     |
                     path/align
                     |
                     label/position
                     |
                     presentation/shape
                     |
                     xml/attributeDefault
                     |
                     value/xmlRepresentation
                     |
                     choice/xmlRepresentation
                     |
                     entity_type/xmlRepresentation
                    ">
    <xsl:element name="{name()}">
        <xsl:element name="{.}"/>
    </xsl:element>
</xsl:template>





</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.elaboration_xslt.xslt--> 

