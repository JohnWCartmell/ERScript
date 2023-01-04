<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" indent="yes"/>

   <xsl:param name="filestem"/>

   <xsl:template match="/entity_model" >
      <xsl:copy>
               <xsl:element name="include_model" namespace="http://www.entitymodelling.org/ERmodel">
                    <xsl:attribute name="filename" select="concat($filestem,'..logical.xml')"/>
               </xsl:element>
               <xsl:element name="include_model" namespace="http://www.entitymodelling.org/ERmodel">
                    <xsl:attribute name="filename" select="concat($filestem,'..presentation.xml')"/>
               </xsl:element>
      </xsl:copy>
   </xsl:template>


</xsl:transform>
