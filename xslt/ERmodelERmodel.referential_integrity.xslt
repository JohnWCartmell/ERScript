<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="xml" indent="yes"/><!-- 
****************************************************************
ERmodel_v1.2/src/ERmodel.functions.fragment.xslt 
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
  This file is created as a copy of ERmodel.functions.modules.xslt but
  with the root transform commented out. It is used to
  generate fucntion defs into a generated xslt.

CHANGE HISTORY

CR18720 JC  16-Nov-2016 Created
<xsl:transform version="2.0" 
        xmlns="http://www.entitymodelling.org/ERmodel"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:era="http://www.entitymodelling.org/ERmodel"
        xmlns:erafn="http://www.entitymodelling.org/ERmodel/functions"
        xpath-default-namespace="http://www.entitymodelling.org/ERmodel">
-->

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
<!--
</xsl:transform>
-->

<!-- end of file: ERmodel_v1.2/src/ERmodel.functions.fragment.xslt--> 

<xsl:key name="table" match="table" use="name"/>
   <xsl:key name="primary_key_entry"
             match="primary_key_entry"
             use="era:packArray((../name,era:packArray((table_name,column_name))))"/>
   <xsl:key name="column"
             match="column"
             use="era:packArray((../name,era:packArray((table_name,name))))"/>
   <xsl:key name="foreign_key"
             match="foreign_key"
             use="era:packArray((../name,era:packArray((table_name,name))))"/>
   <xsl:key name="foreign_key_entry"
             match="foreign_key_entry"
             use="era:packArray((../era:packArray((../name,era:packArray((table_name,name)))),era:packArray((table_name,foreign key_name,to_column_name))))"/>
   <xsl:template match="*" mode="straight_copy">
      <xsl:copy>
         <xsl:apply-templates mode="straight_copy"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="/">
      <xsl:variable name="in_filename" select="tokenize(base-uri(),'/')[last()]"/>
      <xsl:variable name="in_filename_wo_extension"
                     select="substring-before($in_filename,'.xml')"/>
      <xsl:variable name="error_filename"
                     select="concat($in_filename_wo_extension,'.errors.xml')"/>
      <xsl:variable name="state">
         <xsl:apply-templates/>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="boolean($state/descendant-or-self::*:error)">
            <xsl:result-document href="{$error_filename}">
               <xsl:for-each select="$state/*">
                  <xsl:copy>
                     <xsl:apply-templates mode="straight_copy"/>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:result-document>
            <xsl:variable name="errortext"
                           select="string(string-join($state/descendant-or-self::*:error,'-----------------------'))"/>
            <xsl:value-of select="error(QName('http://www.entitymodelling.org/ERmodel', 'ReferentialIntegrityError'),$errortext)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="$state/*">
               <xsl:copy>
                  <xsl:apply-templates mode="straight_copy"/>
               </xsl:copy>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="wildcard" match="*">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="" match="">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="table" match="table">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="primary_key_entry" match="primary_key_entry">
      <xsl:copy>
         <xsl:apply-templates/>
         <xsl:variable name="DIAG" as="node()*" select=".."/>
         <xsl:if test="$DIAG">
            <xsl:if test="column_name">
               <xsl:variable name="DEST"
                              as="node()*"
                              select="key('column', concat(../name,':',column_name))"/>
               <xsl:if test="not($DEST[self::column])">
                  <xsl:variable name="FK" select="concat(../name,':',column_name)"/>
                  <xsl:variable name="MESSAGE">
                    Entity of type primary key entry
                              keyed by 
                             <xsl:value-of select="era:packArray((../name,era:packArray((table_name,column_name))))"/>
                   has broken reference relationship 'column' of type 'column'
                   ... foreign key '<xsl:value-of select="$FK"/>'
              </xsl:variable>
                  <xsl:message>
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:message>
                  <xsl:element name="error">
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:element>
               </xsl:if>
            </xsl:if>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="column" match="column">
      <xsl:copy>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="foreign_key" match="foreign_key">
      <xsl:copy>
         <xsl:apply-templates/>
         <xsl:variable name="DIAG" as="node()*" select=""/>
         <xsl:if test="$DIAG">
            <xsl:if test="to_table_name">
               <xsl:variable name="DEST" as="node()*" select=""/>
               <xsl:if test="not($DEST[self::table])">
                  <xsl:variable name="FK" select="to_table_name"/>
                  <xsl:variable name="MESSAGE">
                    Entity of type foreign key
                              keyed by 
                             <xsl:value-of select="era:packArray((../name,era:packArray((table_name,name))))"/>
                   has broken reference relationship 'to_table' of type 'table'
                   ... foreign key '<xsl:value-of select="$FK"/>'
              </xsl:variable>
                  <xsl:message>
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:message>
                  <xsl:element name="error">
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:element>
               </xsl:if>
            </xsl:if>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   <xsl:template name="foreign_key_entry" match="foreign_key_entry">
      <xsl:copy>
         <xsl:apply-templates/>
         <xsl:variable name="DIAG" as="node()*" select="../.."/>
         <xsl:if test="$DIAG">
            <xsl:if test="from_column_name">
               <xsl:variable name="DEST"
                              as="node()*"
                              select="key('column', concat(../../name,':',from_column_name))"/>
               <xsl:if test="not($DEST[self::column])">
                  <xsl:variable name="FK" select="concat(../../name,':',from_column_name)"/>
                  <xsl:variable name="MESSAGE">
                    Entity of type foreign key entry
                              keyed by 
                             <xsl:value-of select="era:packArray((../era:packArray((../name,era:packArray((table_name,name)))),era:packArray((table_name,foreign key_name,to_column_name))))"/>
                   has broken reference relationship 'from_column' of type 'column'
                   ... foreign key '<xsl:value-of select="$FK"/>'
              </xsl:variable>
                  <xsl:message>
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:message>
                  <xsl:element name="error">
                     <xsl:value-of select="$MESSAGE"/>
                  </xsl:element>
               </xsl:if>
            </xsl:if>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
</xsl:transform>
