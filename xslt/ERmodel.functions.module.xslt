<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel.functions.module.xslt 
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
ERmodel.functions.module.xslt
*************************************

DESCRIPTION
  user defined functions for use from other xslts.

CHANGE HISTORY

CR18720 JC  16-Nov-2016 Created
-->
<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xmlns:erafn="http://www.entitymodelling.org/ERmodel/functions"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<!-- Construct a composite key value from individual key values -->
<xsl:function 
     name="era:packArray">
    <xsl:param name="parts" as="xs:string*"/>
    <xsl:value-of select="string-join($parts,':')"/>
</xsl:function>

<xsl:function 
    name="era:packArrayOfNonEmpties">
    <xsl:param name="elements" as="xs:string*"/>
    <xsl:variable name="nonempty_elements" as="xs:string*">
         <xsl:for-each select="$elements">
            <xsl:if test=".!=''">
               <xsl:value-of select="."/>
            </xsl:if>
         </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="string-join($nonempty_elements,':')"/>
</xsl:function>

<!-- Unpack a packed array -->
<xsl:function 
    name="era:unpackArray">
    <xsl:param name="parray" as="xs:string"/>
    <xsl:sequence select="tokenize($parray,':')"/>
</xsl:function>

<!-- Prefix every element of a packed array -->
<xsl:function 
    name="era:prefixPackedArray">
    <xsl:param name="parray" as="xs:string"/>
    <xsl:param name="prefix" as="xs:string"/>

    <xsl:variable name="elements" as="xs:string*" 
                       select="era:unpackArray($parray)"/>
    <xsl:variable name="prefixedelements" as="xs:string*">
         <xsl:for-each select="$elements">
            <xsl:value-of select="concat($prefix,.)"/>
         </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="era:packArray($prefixedelements)"/>
</xsl:function>

</xsl:transform>

<!-- end of file: ERmodel_v1.2/src/ERmodel.functions.module.xslt--> 

