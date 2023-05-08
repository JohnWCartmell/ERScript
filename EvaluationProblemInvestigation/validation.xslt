<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"             
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:fn="http://www.w3.org/2005/xpath-functions"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               version="2.0"
               xpath-default-namespace=""
               xmlns="">
<xsl:output method="xml" indent="yes"/>

<xsl:variable name="lib" as="map(xs:string,function(*))">

<xsl:sequence select="
let 
$readRel
:=
function(
         $instance as element(),
         $name as xs:string,
         ) as element()*
{
  let 
      $readFn := $relationship_evaluation_lib($name)
  return $readFn($instance)
}

return map {
  'readRel'              : $readRel
  }
"/>
</xsl:variable>  

<xsl:variable name="relationship_evaluation_lib" 
                as="map(xs:string, function(element(*)) as element()?)">
   <xsl:variable name="mapset" 
               as="map(xs:string, function( element(*)) as element()?)*">  
        <xsl:for-each select="/cricket/code/relationship">
            <xsl:variable name="read_function" 
                          as="function(element()) as element()?">
                <xsl:evaluate  xpath="@xpath_read">
                     <xsl:with-param name="lib" select="$lib"/>
                 </xsl:evaluate>
            </xsl:variable>
            <xsl:variable name="relName" as="xs:string"
                          select="@name"/>
            <xsl:message>Registering <xsl:value-of select="$relName"/></xsl:message>
            <xsl:sequence select="
                map{
                     $relName : $read_function
                   }
                 "/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="map:merge($mapset)"/>
</xsl:variable>

<xsl:template match="*">
   <xsl:copy>
      <xsl:apply-templates/>
   </xsl:copy>
</xsl:template>

<xsl:template match="/">
   <xsl:message> in root of document </xsl:message>
   <xsl:for-each select="cricket/match/innings">
       <xsl:copy>
         <xsl:apply-templates/>
         <!-- next copy the fieldingSide into this innings -->
         <xsl:copy-of select="$lib?readRel(.,'fieldingSide')"/>
      </xsl:copy>
   </xsl:for-each>  
</xsl:template>

<xsl:template match="over">
       <xsl:copy>
         <xsl:apply-templates/>
         <!-- next copy the bowler into this innings -->
         <xsl:apply-templates select="$lib?readRel(.,'bowler')"/>
      </xsl:copy>
</xsl:template>

</xsl:transform>
