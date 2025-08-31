<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform version="2.0" 
               xmlns="http://www.entitymodelling.org/diagram"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:math="http://www.w3.org/2005/xpath-functions/math"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:diagram="http://www.entitymodelling.org/diagram" 
               xpath-default-namespace="http://www.entitymodelling.org/diagram">

<!--  Maintenance Box 
  See change of 21-Nov-2022.
-->

<!-- with help from chatrGPT  -->

<!-- char widths in pixels of 11pt times new roman font -->
<xsl:variable name="charwidths_but_not_double_quote" as="map(xs:string, xs:decimal)"
              select="
                map {
                  'a': 4.4, 'b': 5.0, 'c': 4.4, 'd': 5.0, 'e': 4.4,
                  'f': 3.1, 'g': 5.0, 'h': 5.0, 'i': 2.75, 'j': 2.75,
                  'k': 4.95, 'l': 2.75, 'm': 7.7, 'n': 5.0, 'o': 5.0,
                  'p': 4.95, 'q': 4.95, 'r': 3.25, 's': 3.85, 't': 2.75,
                  'u': 4.9, 'v': 4.9, 'w': 7.15, 'x': 4.85, 'y': 4.9, 'z': 4.4,
                  'A': 7.05, 'B': 6.55, 'C': 6.5, 'D': 7.05, 'E': 6.0,
                  'F': 5.4, 'G': 7.15, 'H': 7.15, 'I': 3.3, 'J': 3.75,
                  'K': 7.15, 'L': 6.2, 'M': 8.9, 'N': 7.2, 'O': 7.2,
                  'P': 5.4, 'Q': 7.15, 'R': 6.7, 'S': 5.45, 'T': 6.1,
                  'U': 7.1, 'V': 7.1, 'W': 9.2, 'X'
                  : 7.1, 'Y': 7.1, 'Z': 6.1,
                  '0': 5.5, '1': 5.5, '2': 5.5, '3': 5.5, '4': 5.5,
                  '5': 5.5, '6': 5.5, '7': 5.5, '8': 5.5, '9': 5.5,
                  '.': 2.5, ',': 2.5, ';': 2.8, ':': 2.8, '!': 2.8,
                  '?': 5.0, '(': 3.2, ')': 3.2, '[': 3.2, ']': 3.2,
                  '{': 3.7, '}': 3.7, ' ': 2.5,
  '-' : 3.5,
  '_' : 4.9,
  '*': 5.1,
  '#': 5.5,
  '@': 9.0,
  '%': 8.5,
  '^': 4.5,
  '&amp;': 6.8,
  '$': 5.5,
  '+': 5.5,
  '=': 5.5,
  '&lt;': 5.5,
  '&gt;': 5.5,
  '/': 3.2,
  '\\': 3.2,
  '|': 2.0,
  '~': 5.0,
  '`': 3.0,
  '''': 2.5
                }
              " />

              <!-- from the above i had to remove single and double quotes.
                    single quote is width 2.5 and double quote is width 3.5 -->
<xsl:variable name="charwidth_of_double_quote" as="map(xs:string, xs:decimal)"
              select='
                map {
                  """": 3.5}
                    ' />  
<xsl:variable name="charwidths_in_pixels_of_11pt_font" as="map(xs:string, xs:decimal)"    
              select="map:merge(($charwidths_but_not_double_quote,
                                $charwidth_of_double_quote))"/>


<xsl:function name="diagram:stringwidth_in_pixels_of_11pt_times_new_roman_font" as="xs:double">
  <xsl:param name="text" as="xs:string"/>
 <xsl:variable name="unmapped_chars" as="xs:string*"
  select="
    distinct-values(
      for $cp in string-to-codepoints($text)
      return
        if (not(map:contains($charwidths_in_pixels_of_11pt_font, codepoints-to-string($cp))))
        then codepoints-to-string($cp)
        else ()
                 )
  "/>

  <xsl:if test="exists($unmapped_chars)">
    <xsl:message>Determining width of  '<xsl:value-of select="$text"/>'</xsl:message>
    <xsl:message>
      Error: unmapped characters: '<xsl:value-of select="string-join($unmapped_chars, ', ')"/>'
    </xsl:message>
</xsl:if>

  <xsl:sequence select="
    sum(
      for $ch in string-to-codepoints($text)
      return map:get($charwidths_in_pixels_of_11pt_font, codepoints-to-string($ch))
    )
  "/>
</xsl:function>

<!-- end chat GPT assisted code -->


<xsl:function name="diagram:stringwidth_in_cms_of_11pt_times_new_roman_font" as="xs:double">
  <xsl:param name="text" as="xs:string"/>
  <xsl:sequence select="
    diagram:stringwidth_in_pixels_of_11pt_times_new_roman_font($text) * 0.1325
  "/>
</xsl:function>

<xsl:function name="diagram:stringwidth_in_cms_of_times_new_roman_font" as="xs:double">
  <xsl:param name="text" as="xs:string"/>
  <xsl:param name="fontsize_in_pixels" as="xs:double"/>
  <xsl:param name="is_bold_text" as="xs:boolean"/>
  <xsl:variable name="fonstsize_in_pts" as="xs:double"
                select ="$fontsize_in_pixels * 72 div 96"/>
  <xsl:value-of select="diagram:stringwidth_in_cms_of_11pt_times_new_roman_font($text)
                                   *  $fonstsize_in_pts div 11
                                   *  (if ($is_bold_text) then 1.07 else 1)"/>
</xsl:function>

  <xsl:function name="diagram:stringwidth_from_text_style">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="textstyle" as="element()"/>
        <xsl:variable name="fontsize" as="xs:string"
                    select="$textstyle/font-size"/>
        <xsl:if test="substring($fontsize,string-length($fontsize)-1)!='px'">
          <xsl:message terminate="yes">Font size in style file needs to be in units of px</xsl:message>
        </xsl:if>
        <xsl:variable name="fontsize_in_pixels" as="xs:double"
                    select="number(substring-before($fontsize,'px'))"/>
        <xsl:variable name="is_bold_text" as="xs:boolean"
                      select="exists($textstyle/font-weight/*[self::bold|self::bolder])"/>
        <xsl:value-of select="diagram:stringwidth_in_cms_of_times_new_roman_font
                                    ($given_string,
                                     $fontsize_in_pixels,
                                     $is_bold_text
                                      )  * 0.3 "/>  <!-- why do I need this 0.3? -->
</xsl:function>

<!-- OLD FUNCTIONS BEFORE REWORK OF  July 2025 -->
<!--    <xsl:function name="diagram:stringwidth_from_text_style">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="textstyle" as="element()"/>
        <xsl:variable name="fontsize" as="xs:string"
                    select="$textstyle/font-size"/>
        <xsl:if test="substring($fontsize,string-length($fontsize)-1)!='px'">
          <xsl:message terminate="yes">Font size in style file needs to be in units of px</xsl:message>
        </xsl:if>
        <xsl:variable name="fontsize_in_pixels" as="xs:double"
                    select="number(substring-before($fontsize,'px'))"/>
        <xsl:variable name="is_bold_text" as="xs:boolean"
                      select="exists($textstyle/font-weight/*[self::bold|self::bolder])"/>
        <xsl:value-of select="diagram:stringwidth_from_font_size_in_pixels
                                    ($given_string,
                                     $fontsize_in_pixels,
                                     $is_bold_text
                                      )"/>
    </xsl:function> -->



   <xsl:function name="diagram:stringwidth_from_font_size_in_pixels">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="font_size_in_pixels" as="xs:double"/>
      <xsl:param name="is_bold_text" as="xs:boolean"/>
      <xsl:variable name="sizefactorwrt11pixels"
                    as="xs:double" 
                    select="$font_size_in_pixels div 11 * (if ($is_bold_text) then 1.07 else 1)"/>
      <xsl:value-of select="diagram:stringwidth_from_size_factor($given_string,$sizefactorwrt11pixels)"/>
    </xsl:function>

   <xsl:function name="diagram:stringwidth_from_size_factor">
    <xsl:param name="given_string" as="xs:string"/>
    <xsl:param name="sizefactorwrt11pixels"/>
    <xsl:variable name="noOfCharsAdjusted"
                  select="diagram:noOfCharactersAdjusted(
                            $given_string
                             )
                  "/> 
    <xsl:value-of select="$noOfCharsAdjusted * $sizefactorwrt11pixels * 0.1325"/>
  </xsl:function>


   <xsl:function name="diagram:noOfCharactersAdjusted">
    <xsl:param name="given_string" as="xs:string"/>
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
    <xsl:value-of select="$noOfCharsAdjusted"/>
  </xsl:function>

   <xsl:function name="diagram:stringheight_from_text_style">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="textstyle" as="element()"/>
        <xsl:variable name="fontsize" as="xs:string"
                    select="$textstyle/font-size"/>
        <xsl:if test="substring($fontsize,string-length($fontsize)-1)!='px'">
          <xsl:message terminate="yes">Font size in style file needs to be in units of px</xsl:message>
        </xsl:if>
        <xsl:variable name="fontsize_in_pixels" as="xs:double"
                    select="number(substring-before($fontsize,'px'))"/>
        <xsl:variable name="is_bold_text" as="xs:boolean"
                      select="exists($textstyle/font-weight/*[self::bold|self::bolder])"/>
        <xsl:value-of select="diagram:stringheight_from_font_size_in_pixels
                                    ($given_string,
                                     $fontsize_in_pixels,
                                     $is_bold_text
                                      )"/>
    </xsl:function>

   <xsl:function name="diagram:stringheight_from_font_size_in_pixels">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="font_size_in_pixels" as="xs:double"/>
      <xsl:param name="is_bold_text" as="xs:boolean"/>
      <xsl:variable name="sizefactorwrt11pixels"
                    as="xs:double" 
                    select="$font_size_in_pixels div 11 * (if ($is_bold_text) then 1.07 else 1)"/>
      <xsl:value-of select="diagram:stringheight_from_size_factor($given_string,$sizefactorwrt11pixels)"/>
    </xsl:function>

  <xsl:function name="diagram:stringheight_from_size_factor">
    <xsl:param name="given_string"/>
    <xsl:param name="sizefactorwrt11pixels"/>
    <xsl:value-of select=" $sizefactorwrt11pixels * 0.3"/>
  </xsl:function>

  <xsl:function name="diagram:NoughtToTwoPiClockwiseAngleFromYaxis">
  <!-- See change note 28 May 2025 -->
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="
       if ($xdiff = 0 and $ydiff = 0) then 0
       else if ($xdiff gt 0 and $ydiff gt 0) then 3 * math:pi() div 2 + math:atan($ydiff div $xdiff)
       else if ($xdiff gt 0 and $ydiff = 0) then 3 * math:pi() div 2
       else if ($xdiff gt 0 and $ydiff lt 0) then (3 * math:pi() div 2) - math:atan(abs($ydiff div $xdiff))
       else if ($xdiff = 0 and $ydiff gt 0) then 0
       else if ($xdiff = 0 and $ydiff lt 0) then math:pi()  
       else if ($xdiff lt 0 and $ydiff lt 0) then math:pi() div 2 + math:atan(abs($ydiff div $xdiff))
       else if ($xdiff lt 0 and $ydiff = 0) then math:pi() div 2
       else if ($xdiff lt 0 and $ydiff gt 0) then math:atan(abs($xdiff div $ydiff))
       else 'OUT OF SPEC'
    "/>
  </xsl:function>

  <xsl:function name="diagram:NoughtToTwoPiAntiClockwiseAngleFromXaxis">
    <!-- See change note 28 May 2025 -->
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="2 * math:pi()
                          - 
                          (diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff) + math:pi() div 2) 
                              mod
                           (2*math:pi())
                          "/>
  </xsl:function>

  <xsl:function name="diagram:bearingFromAngleToNegativeYaxis">
    <!-- angle may be negative or greater than 2*pi -->
    <!-- this function just normalises to bring into the 0 to 2*pi range -->
    <xsl:param name="angle" as="xs:double"/>
    <xsl:value-of select="(2*math:pi() + $angle)
                            mod
                          (2*math:pi())"/>
   </xsl:function>

  <xsl:function name="diagram:NoughtToTwoPiAntiClockwiseAngleFromNegativeYaxis">
    <!-- See change note 28 May 2025 -->
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="2 * math:pi()
                          - 
                          (diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff) + math:pi()) 
                              mod
                           (2*math:pi())
                          "/>
  </xsl:function>

  <xsl:function name="diagram:NoughtToTwoPiClockwiseAngleFromNegativeXaxis">
    <!-- See change note 28 May 2025 -->
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="(diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff) + 3* math:pi() div 2) 
                              mod
                           (2*math:pi()
                           )
                          "/>
  </xsl:function>

  <xsl:function name="diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis">
    <!-- Used to calculate theta ... see change note 18 May 2025 -->
    <xsl:param name="xdiff" as="xs:double"/>
    <xsl:param name="ydiff" as="xs:double"/>
    <xsl:value-of select="(diagram:NoughtToTwoPiClockwiseAngleFromYaxis($xdiff,$ydiff) +  math:pi()) 
                              mod
                           (2*math:pi()
                           )
                          "/>
  </xsl:function>

  <xsl:function name="diagram:hypoteneuse">
    <xsl:param name="x" as="xs:double"/>
    <xsl:param name="y" as="xs:double"/>
    <!-- by pythagorus -->
      <xsl:value-of select="math:sqrt( math:pow($x,2) + math:pow($y,2) )"/>
  </xsl:function>

  <xsl:function name="diagram:xOffsetFromBearingAndDistance">
    <xsl:param name="bearing" as="xs:double"/>
    <xsl:param name="distance" as="xs:double"/>
    <xsl:value-of select="math:sin($bearing) * $distance"/>
  </xsl:function>

  <xsl:function name="diagram:yOffsetFromBearingAndDistance">
    <xsl:param name="bearing" as="xs:double"/>
    <xsl:param name="distance" as="xs:double"/>
    <xsl:value-of select="- math:cos($bearing) * $distance"/>
      <!-- note the minus sign 
          (because y increases as we travel south but bearing is compass bearing to due north) -->
   </xsl:function>

  <xsl:function name="diagram:xOffsetFromBearingAndyOffset">
    <xsl:param name="bearing" as="xs:double"/>
    <xsl:param name="yOffset" as="xs:double"/>
    <xsl:value-of select="- math:tan($bearing) * $yOffset"/>
    <!-- note the minus sign 
          (because y increases as we travel south but bearing is compass bearing to due north) -->
   </xsl:function>

  <!-- tan function given argument in degrees -->
  <xsl:function 
       name="diagram:tan">
      <xsl:param name="degrees" as="xs:float"/>
      <xsl:value-of select="math:tan($degrees div 180 * math:pi())"/>
  </xsl:function>

  <!-- cotan function given argument in degrees -->
  <xsl:function 
       name="diagram:cotan">
      <xsl:param name="degrees" as="xs:float"/>
      <xsl:value-of select="1 div math:tan($degrees div 180 * math:pi())"/>
  </xsl:function>

  <xsl:function name="diagram:escape-for-selector" as="xs:string">
  <xsl:param name="raw" as="xs:string"/>

  <!-- Replace any character that is not [a-zA-Z0-9_-] with a backslash escape -->
  <xsl:sequence select="replace($raw, '([^A-Za-z0-9_-])', '\\$1')"/>
</xsl:function>

</xsl:transform>

