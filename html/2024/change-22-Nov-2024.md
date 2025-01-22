
## 22 November 2024
Standardise font size and style in ER diagrams - ERmodel2.svg, ERmodel2.tex and flex2svg.xslt.
### Summary
No two of these three ways of diagramming an ER model use the same styles or the same font sizes.
### Idea
Make them all the same and don't worry too much on what this is. Document the code that is involved. 
Improve the ERmodel2.diagram code to use the width algorithm developed for flex diagramming. Its by no means perfect but it is better than what currently in use. 
### Analysis
Various styles and sizes and proposed convergence as follows:
|  	      |         | ERmodel2.svg  | ERmodel2.tex | ERmodel2flex2svg|  standardise all three on |
|---------|---------|:-------------:|:------------:|:---------------:|:-------------------------:|
|et name  | fontsize| 11px          |    8pt       |     11px        | 11px                      |
|         | style   | normal        |    italic    |     italic      | normal                    |
|rel name | fontsize| 9.45px(0.25cm)|    7pt       |     11px        | 10px (0.265cm)             |
|         | style   | italic        |    italic    |     italic      | italic                    |
|attr name| fontsize| 11px          |    7pt       |     11px        | 10px                      |
|         | style   | italic        |    italic    |     italic      | italic                    |


### Implementation
1. ERmodel2flex2svg
+ change methods/era/eraFlexStyleDefinitions.xml to have styles 'etname', 'relname', 'attrname' defined as per final column of table above.
+ change ER2flex to plant these styles for entiuty type  names, rel names and attr names. For example for entity type name need to plant
```
<label><text_style>etname</text_style></label>
``` 
plant text_style for routes.
+ need modify 'diagram...path-+point.endpointewQ.xslt'
and  'diagram...path-+point.startpointewQ.xslt' to plant 
```
<label><text_style><xsl:value-of select="../text_style"/></text_style></label>
```
instead of  
```
<label>
```
 as at present. [x]

2. In support of above, edit the flex diagram model to add a
reference relationship 'text_style' to entity type route. [x]
3. ERmodel2diagram.module
	+ change to include file diagram.functions.module.xslt and to use the function diagram:stringwidth_from_font_size_in_pixels whereever the 
	width of a string of characaters is calculated (estimated) and based on the sizes given in the final column above. []
	See also change of [21-Nov-2024](change-21-Nov-2024.md).
    Use the following function
```
   <xsl:function name="diagram:stringwidth_from_font_size_in_pixels">
      <xsl:param name="given_string" as="xs:string"/>
      <xsl:param name="font_size_in_pixels" as="xs:double"/>
      <xsl:param name="is_bold_text" as="xs:boolean"/>
```
   + need to restructure slightly and replace template maxNoOfCharsInEntityTypeName
     by a template maxWidthOfEntityTypeName (because one line might have more characters than another 
       but measure less when rendered). Change template maxCharsWhenSplitLines to be maxWidthWhenSplitLines
       and have a font_size_in_pixels parameter on both of these.
4. ERmodel2svg also change to use above string width function for relationship names.
   Also (while I am at it and to simplify code) fix a bug by which empty svg text elements generated for relationships roles even when no role name supplied.
5. ERmodel2.tex
    + modify shared macros file 'erdiagram.tex' to change etname, relname and attrname to use
    fontsizes in points that are equivalent to the pixels specified in final column above.
    Convert pixels to points by multiplying by 72/96.
    I calculated that in \fontsize command I needed
     etname 8.25pt relname and attrname 7.5pt
     but needed to proceed by trial and error and use for etname
```
\newcommand {\ertext}[4]
{
\rput[B#3]{0}(#1,#2){\fontsize{6.6}{8.4}\selectfont #4} %Change of 22-Nov-2024
}
```
and for relname and attrname I used
```
\newcommand {\erextrasmallitalictext}[1]
{\fontsize{6}{8}\selectfont \textit{#1}} 
```
+ modify shared file ermacros not to change to italics when embedding a diagram. Modify the \erexample command by removal of \itshape.[x]
6. ERmodel2.svg
   + modify the styles in css/erdiagramsvgstyles.css in accord with the final column above. [x]
#### Warning.
Change theory/SharedMacros/ermacros.tex and erdiagram.tex. COPY THE LATTER into ERScript/latex folder.

### Testing
1. unit test on goodland example. make sure that ERmodel2svg and ERmodel2tex diagrams look the same. For one thing check the spacing around the relationship 'from and to'.[x]
2. Edit  the Goodland variant A flex example to bring it line with changes to the flex model.
This should previusly been don most likely. Build the flex diagram and copy across into handcrafted images
in the IntroductionToEntityModelling. Use inkscape to produce eps from the svg. (the svg uses the bundle option by the way). Compare the Goodland ERmodel structured diagram and the flex non-structured diagram and check
all the fonts look the same.[]

### Completion Date 

