<!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel2.html.xslt 
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

<xsl:transform version="2.0" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

<?xml-stylesheet type="text/xsl" href="ERModel2HTML.xslt"?>

<xsl:template match="/entity_model">
  <html>
  <style type="text/css">

    table, td, th
    {
      border:1px solid green;
      border-collapse:collapse;
      padding:5px;
    }
    th
    {
      border:1px solid white;
      background-color:green;
      color:white;
    }
  </style>
  <body>

  <h2>Entity Type Table </h2>
  <xsl:call-template name="entityTypeTable"/>
<!-- Don't seem to add much Commented out 10/may2016.
  <h2>Composition Relationships </h2>
  <xsl:call-template name="compositionRelationshipTable"/>
  <h2>Reference Relationships </h2>
  <xsl:call-template name="referenceRelationshipTable"/>
-->
  <h2>Attributes </h2>
  <xsl:call-template name="attributeTable"/>
  </body>
  </html>
</xsl:template>

<xsl:template name="entityTypeTable" match="entity_model">
  <table>
    <tr>
      <th> Entity Type </th>
      <th> IsA         </th>
      <th> Description </th>
    </tr>
    <xsl:for-each select="//entity_type">
      <tr>
       <xsl:call-template name="entityType"/>
      </tr>
    </xsl:for-each>
  </table>
</xsl:template>


<xsl:template name="entityType" match="entity_type">
   <td>
   <xsl:value-of select="name"/>
   </td>
   <td>
     <xsl:if test="parent::entity_type">
       <xsl:value-of select="../name"/>
     </xsl:if>
   </td>
   <td>
      <xsl:value-of select="description"/>
   </td>
</xsl:template>


<xsl:template name="compositionRelationshipTable" match="entity_model">
  <table>
    <tr>
      <th rowspan="2"> Entity Type </th>
      <th colspan="3"> Composition Relationship </th>
    </tr>
    <tr>
      <th> Name </th>
      <th> Cardinality </th>
      <th> Destination </th>
      <th> Description </th>
    </tr>
    <xsl:for-each select="//entity_type">
       <xsl:call-template name="entityTypeCompositionRels"/>
    </xsl:for-each>
  </table>
</xsl:template>

<xsl:template name="entityTypeCompositionRels" match="entity_type">
   <xsl:for-each select="composition">
     <tr>
       <td>
 	 <xsl:value-of select="../name"/>
       </td>
       <td>
 	 <xsl:value-of select="name"/>
       </td>
       <td>
	 <xsl:value-of select="cardinality/name()"/>
       </td>
       <td>
	 <xsl:value-of select="type"/>
       </td>
       <td>
         <xsl:value-of select="description"/>
       </td>
     </tr>
   </xsl:for-each>
</xsl:template>

<xsl:template name="referenceRelationshipTable" match="entity_model">
  <table>
    <tr>
      <th rowspan="2"> Entity Type </th>
      <th colspan="3"> Reference Relationship </th>
    </tr>
    <tr>
      <th> Name </th>
      <th> Cardinality </th>
      <th> Type </th>
      <th> Description </th>
    </tr>
    <xsl:for-each select="//entity_type">
       <xsl:call-template name="entityTypeReferenceRels"/>
    </xsl:for-each>
  </table>
</xsl:template>

<xsl:template name="entityTypeReferenceRels" match="entity_type">
   <xsl:for-each select="reference">
     <tr>
       <td>
 	 <xsl:value-of select="../name"/>
       </td>
       <td>
 	 <xsl:value-of select="name"/>
       </td>
       <td>
	 <xsl:value-of select="cardinality/name()"/>
       </td>
       <td>
	 <xsl:value-of select="type"/>
       </td>
       <td>
         <xsl:value-of select="description"/>
       </td>
     </tr>
   </xsl:for-each>
</xsl:template>
<xsl:template name="attributeTable" match="entity_model">
  <table>
    <tr>
      <th rowspan="2"> Entity Type </th>
      <th colspan="3"> Attribute </th>
    </tr>
    <tr>
      <th> Name </th>
      <th> Optionality </th>
      <th> Type </th>
      <th> Description </th>
    </tr>
    <xsl:for-each select="//entity_type">
       <xsl:call-template name="entityTypeAttributes"/>
    </xsl:for-each>
  </table>
</xsl:template>

<xsl:template name="entityTypeAttributes" match="entity_type">
   <xsl:for-each select="attribute">
     <tr>
       <xsl:if test="position()=1">
          <xsl:element name="td">
             <xsl:attribute name="rowspan">
                 <xsl:value-of select="count(../attribute)"/>
             </xsl:attribute>
 	     <xsl:value-of select="../name"/>
          </xsl:element>
       </xsl:if>
       <td>
 	 <xsl:value-of select="name"/>
       </td>
       <td>
         <xsl:if test="optional">
            OPTIONAL
            <xsl:for-each select="optional/value">
                  (DEFAULT: 
	            <xsl:value-of select="."/>
                    )
            </xsl:for-each>
         </xsl:if>
       </td>
       <td>
         <xsl:if test="name()='value'">
	   <xsl:value-of select="type"/>
         </xsl:if>
         <xsl:if test="name()='choice'">
            <xsl:value-of select='from'/>
         </xsl:if>
       </td>
      <td>
         <xsl:value-of select="description"/>
      </td>
     </tr>
   </xsl:for-each>
</xsl:template>

</xsl:transform>
<!-- end of file: ERmodel_v1.2/src/ERmodel2.html.xslt--> 

