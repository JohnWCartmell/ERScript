<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="2.0"
               xpath-default-namespace="http://www.entitymodelling.org/ERmodel">

   <xsl:strip-space elements="*"/>
   <xsl:output method="xml" indent="yes"/>

   <xsl:param name="filestem"/>

   <xsl:template match="/" >
      <xsl:copy>
         <xsl:element name="extend" namespace="http://www.entitymodelling.org/ERmodel">
             <xsl:element name="content" namespace="http://www.entitymodelling.org/ERmodel"> 
               <xsl:element name="include" namespace="http://www.entitymodelling.org/ERmodel">
                    <xsl:attribute name="filename" select="concat($filestem,'.core.xml')"/>
               </xsl:element>
             </xsl:element>
             <xsl:element name="with" namespace="http://www.entitymodelling.org/ERmodel"> 
               <xsl:element name="include" namespace="http://www.entitymodelling.org/ERmodel">
                    <xsl:attribute name="filename" select="concat($filestem,'.presentation.xml')"/>
               </xsl:element>
             </xsl:element>
         </xsl:element>
      </xsl:copy>
   </xsl:template>


</xsl:transform>
