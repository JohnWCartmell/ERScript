<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 

 -->
   <xsl:function name="diagram:stringwidth">
    <xsl:param name="given_string"/>
    <xsl:param name="sizefactorwrt11point"/>
    <xsl:variable name="given_but_wo_i" select="translate($given_string, 'i', '')"/>
    <xsl:variable name="no_of_i" select="string-length($given_string)- string-length($given_but_wo_i)"/> 

    <xsl:variable name="given_but_wo_i_j" select="translate($given_but_wo_i, 'j', '')"/>
    <xsl:variable name="no_of_j" select="string-length($given_but_wo_i)- string-length($given_but_wo_i_j)"/> 
    
 
    <xsl:variable name="given_but_wo_i_j_l" select="translate($given_but_wo_i_j, 'l', '')"/>
    <xsl:variable name="no_of_l" select="string-length($given_but_wo_i_j)- string-length($given_but_wo_i_j_l)"/> 

    <xsl:variable name="given_but_wo_i_j_l_m" select="translate($given_but_wo_i_j_l, 'm', '')"/>
    <xsl:variable name="no_of_m" select="string-length($given_but_wo_i_j_l)- string-length($given_but_wo_i_j_l_m)"/> 
  
    <xsl:variable name="given_but_wo_i_j_l_m_w" select="translate($given_but_wo_i_j_l_m, 'w', '')"/>
    <xsl:variable name="no_of_w" select="string-length($given_but_wo_i_j_l_m)- string-length($given_but_wo_i_j_l_m_w)"/> 

    <xsl:variable name="given_but_wo_i_j_l_m_w_space" select="translate($given_but_wo_i_j_l_m_w, ' ', '')"/>
    <xsl:variable name="no_of_space" select="string-length($given_but_wo_i_j_l_m_w)- string-length($given_but_wo_i_j_l_m_w_space)"/> 

    <xsl:variable name="given_but_wo_i_j_l_m_w_space_underscore" select="translate($given_but_wo_i_j_l_m_w_space, '_', '')"/>
    <xsl:variable name="no_of_underscore" 
                  select="string-length($given_but_wo_i_j_l_m_w_space)- string-length($given_but_wo_i_j_l_m_w_space_underscore)"/> 


    <xsl:variable name="noOfCharsAdjusted"
                  select="string-length($given_but_wo_i_j_l_m_w_space_underscore)
                          + ($no_of_i          * 0.63)
                          + ($no_of_j          * 0.63)
                          + ($no_of_l          * 0.65)  
                          + ($no_of_m          * 1.7)
                          + ($no_of_w          * 1.605)
                          + ($no_of_space      * 0.575 )
                          + ($no_of_underscore * 1.1)"/>
    <xsl:value-of select="$noOfCharsAdjusted * $sizefactorwrt11point * 0.1325"/>
  </xsl:function>

  <xsl:function name="diagram:stringheight">
    <xsl:param name="given_string"/>
    <xsl:param name="sizefactorwrt11point"/>
    <xsl:value-of select=" $sizefactorwrt11point * 0.3"/>
  </xsl:function>

<!-- angle to y axis      -->
<!-- y-axis points down   -->
<!-- angles in left hand plane to be considered negative and angles in right half likewise positive -->
<!-- see notes in day book 19 September 2021 -->
<xsl:function name="diagram:angleToYaxis">
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
	<xsl:value-of select="
	   if ($xdiff = 0 or $ydiff = 0) then 0
	   else if ($xdiff gt 0 and $ydiff gt 0) then math:atan($xdiff div $ydiff)
	   else if ($xdiff gt 0 and $ydiff lt 0) then math:pi() + math:atan(abs($ydiff div $xdiff))
	   else if ($xdiff lt 0 and $ydiff lt 0) then - math:pi() - math:atan(abs($ydiff div $xdiff))
	   else if ($xdiff lt 0 and $ydiff gt 0) then - math:atan(abs($xdiff div $ydiff))
	   else 'OUT OF SPEC'
	"/>
</xsl:function>

<!-- angle to negative y-axis is angle to the upward pointring vertical -->
<!-- angles in left hand plane to be considered negative and angles in right half likewise positive -->
<!-- in left half plane angleToNegativey + angleToyaxis = -2pi -->
<!-- in right half plane angleToNegativey + angleToyaxis = 2pi -->
<xsl:function name="diagram:angleToNegativeYaxis">
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="
	  if ($xdiff = 0 or $ydiff = 0) then 0
	  else (if ($xdiff lt 0) then - 2 * math:pi() else 2 * math:pi()) - diagram:angleToYaxis($xdiff,$ydiff)
	"/>
</xsl:function>

</xsl:transform>

