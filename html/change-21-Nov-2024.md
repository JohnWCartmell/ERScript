
## 21 November 2024
Flex Diagramming. Improve code structure by which string widths estimated.
This is  preparation for reuse of library code in ERmodel2.diagram.xslt (see change of [22 Nov 2024](change-22-Nov-2024.md)).
### Summary
Change the function diagram:stringwidth in file diagram.functions.module.xslt.
Replace by a number of functions one of which is suitable for use from ERmodel2.diagram.module,xslt.
For symmetry replace the diagram:stringheight function likewise.
### Analysis
1. The string width function is called by the following code currently found in 
file diagram.wP.xslt
```
      <xsl:variable name="textstyle" as="element()"
                    select="key('text_style',text_style)"/>
      <!-- <xsl:message>text_style element ===<xsl:copy-of select="$textstyle"/>'===</xsl:message> -->               
      <xsl:variable name="fontsize" as="xs:string"
                    select="$textstyle/font-size"/>
    <!--   <xsl:message>font size '<xsl:value-of select="$fontsize"/>'</xsl:message>
      <xsl:message>font size units'<xsl:value-of select="substring($fontsize,string-length($fontsize)-1)"/>'</xsl:message> -->
      <xsl:if test="substring($fontsize,string-length($fontsize)-1)!='px'">
         <xsl:message terminate="yes">Font size in style file needs to be in units of px</xsl:message>
      </xsl:if>

      <xsl:variable name="fontsize_as_numeric" as="xs:double"
                    select="number(substring-before($fontsize,'px'))"/>
      <xsl:variable name="wP" as="xs:double"
                  select="diagram:stringwidthP(text, $fontsize_as_numeric div 11) 
                                                        * (if (key('text_style',text_style)/font-weight/*[self::bold|self::bolder])
                                                           then 1.07
                                                            else 1 
                                                          )"/>
```
2. We do not have text_styles available in ERmodel2.diagram so can't just reuse this code directly.
Should restructure so that this code goes into the function library diagram.functions.module.xslt
and is implemented by a function that can be called from ERmodel2.diagram.
### Proposal
1. Correct a misnomer replace parameter 'sizefactorwrt11points' by 'sizefactorwrt11pixels'.[x]
2. Replace the diagram:stringwidth function as summarised above by three functions:
```
   <xsl:function name="diagram:stringwidth_from_text_style">          <!-- used in flex diagramming -->
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="text_style" as="element()"/>
   </xsl:function>
   <xsl:function name="diagram:stringwidth_from_font_size_in_pixels"> <!-- suitable for use from ERmodel2.diagram.module.xslt -->
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="font_size_in_pixels" as="xs:double"/>
      <xsl:param name="is_bold_text" as="xs:boolean"/>
   </xsl:function>
    <xsl:function name="diagram:stringwidth_from_size_factor">        <!-- private -->
        <xsl:param name="given_string" as="xs:string"/>
        <xsl:param name="sizefactorwrt11pixels"/>
   </xsl:function>
```
3. Replace the diagram:stringheight function likewise.[x]
4. Massively simplify  the calling code in diagram.wP.xslt in line with the restructure so that for a label the 
width element is given by
```
      <xsl:variable name="textstyle" as="element()"
                    select="key('text_style',text_style)"/>
      <wP>
         <xsl:value-of select="diagram:stringwidth_from_text_styleP(text,$text_style)"/>
      </wP>
```
5. Modify the xslt_template build modifyinging the stringwidthP lines with the new function names.[x]
### Testing
1. Rebuild and inspect text example - flexDiagramming/examples/src_text_tests/boxed.text.xml.[x]
### Completion Date 
24th November 2024
