<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

  <!--  
****************************************
diagram....xP.place.xslt
****************************************

DESCRIPTION
  Rules for generating place for x and y.
  Note some rules in diagram.label.x.xslt also generate 'place'. 

CHANGE HISTORY
        JC  26-May-2017 Created as addressing smarts.
        JC  24-Jul-2019 Modified to processed template for x and y.
        JC  23-Aug-2019 Rules for 'place' moved into  'place' separate file
                        includes recent rules for route endpoint labels.
						Make rules other than endpoints more specific.
	    JC 9-Sept2019   Rules for endpoint removed aslabels now subordinate to endpoints.
 -->

  <xsl:output method="xml" indent="yes"/>

  
  <!-- Add defaults for xP/place/anchor                               -->
  <!-- xP/at/rightP of X                      -  place/leftP          -->
  <!-- xP/at/leftP  of X                      -  place/leftP          -->  <!-- modifed 29 July 2019 -->
  <!-- xP/at/rightP (of containing enclosure) -  place/rightP         -->
  <!-- xP/at/leftP  (of containing enclosure) -  place/leftP          -->
  <!-- xP/at/centreP                          -  place/centreP        -->
  <!-- xP/at/xP                               -  place/leftP          -->
  
  <xsl:template match="*[not(self::point)]
						/xP[not(place)]
                        [at/rightP] 
                        [at/(of|predecessor)]
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <leftP/>
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[not(self::point)]
                        /xP[not(place)]
                        [at/leftP] 
                        [at/(of|predecessor) ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <leftP/> <!-- modified 29th July 2019 -->
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[not(self::point)]
                        /xP[not(place)]
                        [at/rightP] 
                        [at/parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <rightP/><outer/>
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[not(self::point)]
                        /xP[not(place)]
                        [at/leftP] 
                        [at/parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <leftP/><outer/>
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>

    
  <xsl:template match="*[not(self::point)]
                         /xP[not(place)]
                        [at/centreP] 
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <centreP/><edge/>
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
  
    
  <xsl:template match="enclosure/xP[not(place)]
                                  [at/xP] 
                    " 
              mode="recursive_diagram_enrichment"
              priority="199">
    <xsl:copy>
      <place>
         <leftP/><edge/>
      </place>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>

