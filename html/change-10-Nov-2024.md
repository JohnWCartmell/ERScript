
## 10 November 2024
Flex Diagramming - recursive diagram enrichment fault in positioning of left aligned text.

### Problem
Experimenting with the stack_of_labelled_points example I find a bug in the layout when a label is within a point within an enclosure and the label has an x position specified by
```
<x><place><left/><edge/></place><at><parent/></at></x>
```
The label is placed too far to the right and the determining factor seems to be the value of the margin of the
grand parent enclosure.
### Summary
I need fix this but also need to document what the effect of margin and padding is for points and labels. 

### Analysis
1. Currently points have padding and this padding is visualised when debug white space is set.
2. Labels so not have padding currently but in this example because labels are contained within points
then the padding of the point contains the label and so in this example they appear to have padding.
In change of 11-Nov-2024 the padding of labels is now visualalised if debug whitespace is set.
3. The template that causes this observed behaviour is in file diagram.addressing.xPwP.smarts.xslt as follows:
```
  <xsl:template match="xP/at[
                            some $frameOfReference in ../../(ancestor::enclosure|ancestor::diagram)[last()]
                            satisfies .
                               [not(offset)]
                               [parent]
                               [margin]
                               [leftP]
                               [$frameOfReference/margin]
                           ]
                    " 
              mode="recursive_diagram_enrichment"
              priority="172P"
              >
    <xsl:variable name="frameOfReference" select="../../(ancestor::enclosure|ancestor::diagram)[last()]"/>
    <xsl:copy>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
      <offset trace="17LM">
                <xsl:call-template name="float">
                    <xsl:with-param name="value" 
                                    select="$frameOfReference/margin"/>
                </xsl:call-template>
      </offset>      
     </xsl:copy>
  </xsl:template>
```
5. It seems clear to me that only enclosures should have margins and therefore the margin attribute should be an attribute of enclosure and not box. In fact this is the way that the rule in file diagram.margin.xslt to apply a default margin is coded.

6. Should change the smarts so that place at margin of parent only occurs when the parent is an enclosure.
Currently the margin is the default  and is implemented in file diagram.addressing.xPwP.smarts.xslt by this rule
```
  <xsl:template match="*[not(self::label and (parent::point/startpoint or parent::point/endpoint))] 
                        /xP/at[not(margin|edge|outer)]
                                     [rightP|leftP]
                                     [parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
    <xsl:copy>
      <xsl:message> Inserting margin into at of xP of '<xsl:value-of select="../../name()"/>'</xsl:message>
      <xsl:message> <xsl:copy-of select="."/></xsl:message>
         <margin/>
      <xsl:apply-templates mode="recursive_diagram_enrichment"/>
    </xsl:copy>
  </xsl:template>
```

### Proposal
1. Modify the flex diagram data model. Move the margin attribute from box to enclosure.
2. Change the smarts so that place at margin of parent only applies when the parent is an enclosure.
3. Change smarts so that an error is given if the margin of a non-enclosure is specified or implied.
in file diagram.addressing.xPwP.smarts.xslt have a template that terminates with an error and with high priority
defined by
```
<xsl:template match="*[not(self::enclosure | self::diagram)]
                     /xP/at/margin"
              priority="1000">
```

4. Change the template quoted in 4. above so that the precondition  is given as shown here:
```
  <xsl:template match="xP/at[not(offset)]
                            [parent]
                            [margin]
                            [leftP]
                            [../..[self::enclosure|self::diagram]/margin]
                           
                    " 
```
and change the body accordingly.

5. Change template quoted in 6. above that implements margin as a default so that its precondition is as
follows:
```
  <xsl:template match="enclosure/*/xP/at[not(margin|edge|outer)]
                                        [rightP|leftP]
                                        [parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
```
and add a rule for defaulting to edge with precondition as follows:
```
  <xsl:template match="*[not(self::enclosure)]/*/xP/at[not(margin|edge|outer)]
                                        [rightP|leftP]
                                        [parent]
                    " 
              mode="recursive_diagram_enrichment"
              priority="170P">
```

### Testing
Use stack_of_labelled_points example to unit test. Testing will take place anyhow as part of change of
5-Nov-2024 which this change will precede.
### Completion Date
11-Nov-2024.

