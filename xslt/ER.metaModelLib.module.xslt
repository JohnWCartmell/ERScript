<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:myfn="http://www.testing123/functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:er="http://www.entitymodelling.org/ERmodel"
               xmlns:era="http://www.entitymodelling.org/ERmodel"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">


<!--ER.metaModelLib.module.xslt -->

  <xsl:include href="erMetaModelLibConstructor.module.xslt"/>

<xsl:variable name="erMetaModelData" as="element(er:entity_model)">
    <xsl:message> In 'ER.library.module' 
                    root element is '<xsl:value-of select="child::element()/name()"/>'
    </xsl:message> 

    <xsl:variable name="metaDataFile"
              as="document-node()"
              select="
        if (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        then document (child::element()/@metaDataFilePathWrtThisInstanceDocument)
        else document( '../' 
                        || 
                        (child::element()/@metaDataFilePathWrtERHome) cast as xs:string)
                     "/>

   <xsl:variable name="state" 
                 as="element(er:entity_model)" 
                 select="$metaDataFile/er:entity_model"/>
   <xsl:variable name="enrichment" as="document-node()">

        <xsl:call-template name="recursive_xpath_enrichment">
          <xsl:with-param name="interim" select="$state"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="$enrichment/er:entity_model"/>
</xsl:variable>

<xsl:variable name="erMetaModelLib" as="map(xs:string,function(*))">
    <xsl:variable name="model" as="element(er:entity_model)" select="$erMetaModelData"/>
    <xsl:sequence select="$erMetaModelLibConstructor($model)"/>
</xsl:variable>

<!--End of ER.metaModelLib.module.xslt -->

</xsl:transform>