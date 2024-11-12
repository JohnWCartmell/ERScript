
## 5 November 2024
Document and fix use of linestyles and endline style in flex diagram model.

### Rationale
I want to use flex diagramming to produce new non-topdown diagrams for the `introduction to entity modelling' paper. After recent tidying I have broke ERmodel 2 svg via flex. I seem to have muddled thinking leading to inconsistency in the way that I am trying use linestyles and endline styles. Need to document what the intention of the flex diagram model in this area and then fix the code. Might need to adjust the recently produced style definitions files. Might need to fine tune the flex diagram model.

### Summary
1. Document here and in the flex diagram model descriptive text. 

2. First fix bug in positioning of text, see change of 10-Nov-2024.

### Analysis
1. Relevant entity types in the flex diagram model are
```
node ::= source | destination

node => anonymouscomposition: Set Of (endline),
        linestyle: shape_style;

endline =>  style : endline_style
```
2. The intention I think is that the node.linestyle reference relationship gives the two half linestyles for a route and that the endlines on a route specify markers such as crowsfoot, identifying and squiggle(sequence indicator).
3. The endline_style.id is currently used to identify a marker in svg and so can only take one of a limited number of values. Currently the values supported are crowsfoot, identifying and squiggle.
3. Note that the linestyle reference is to a shape_style so shape_style defined both shapes for enclosures but also styling of routes. 
4. The type endline_style has an id attribute and various different kinds of attribute. Group A consisting of stroke, stroke-width, stroke-dasharray, are aimed at styling. Group B label_long_offset,label_lateral_offset, lateral_extent, long_extent are there so that we can have rules that can be used to avoid labels overlaying the markers. Finally, the minarmlen attribute supports the lengthening of end arms of a route so as to accomodate its markers.

5. It seems to me that the group A attributes are redundant. 
6. Currently ERmodel2.flex.xslt generates r topdown and sideways routes with
 source/linestyle set but does not generate destination/linestyle. 
 It does generate endline/style/crowsfoot and or  endline/style/identifying as required. 
7. I note that er2flex generates empty annotation nodes for source's and destination's when a relationships 
do not have names respectively inverses.
8. How are the group B attributes used currently?
  + label_long_offset is used in diagram...route.path.point.label-+xP.xslt.
     It is used in four places to determine the x (or y) value for the label for relationship name.
     The code is in error in two ways. 1. It has endline_style not endline/style. 2. It is written as 
     if there is only one endline_style but of course there may be many endline/style's
  + label_lateral_offset is used. 
     as above it is used in four places but the code is in error.
  + long_extent is not used
  + lateral_extent is not used
Go figure!!! The way it is coded, although actually miscoded, I think label_long_extent is the distance
along the first arm of the route that the label should be position at.
The lateral extent is the distancy away from the arm that it should be positioned at. 
Depending which side of the end box that this end of the route is at then the width or height of the text has to be taken into account to work out the x value or y value for the label. The source code is for the x value and the y value is coded from the x value in the build. The build from templates swaps x and y and swaps width and heigth. It should also swap
label_long_extent and label_lateral_extent.  
If there was always exactly one endline/style then we could now fix the code. 
But there may be zero endline styles more than one. So what do we want and is the diagram model right anyhow or do we need to change it? Look at how we place labels in practice.
The code whould probably take account of the label padding also. We need to document this carefully because it means when we specify long_extent and lateral_extent then we do not need to pad, this should be taken account of in the x and y of the label. If I don't get clear on this then I get confused later and the code is confused. 

Two possibilities really. 
  + Gross simplification remove these extent attributes from endline/style, put two somewhere else (where?) so that extents are independent of line markings.
  + Have just the two that are used currently and allow them to be optional.
    If they are defined they give minimum distants and so a max of those that are defined
    is what we want to calculate x or y. 

9. The possible meaning of long_extent and lateral_extent:
  + these refer to the extent of the arm without taking account of the label. 
  + when I add identifying and sequence indicator to a line then it makes the line
    wider and longer. This width and length will need to be taken account of when
    calculating armlengths and when tring to squeeze lines together as I sometimes
    do 'by hand'. Of these the long_extent is of more consequence than the lateral extent.
    The lateral extent comes into play when I have two routes with crowsfeet leaving the same side of a box and I want them close together. I label them on opposite sides so I can get them close but I cant get them that close that their (crows) feet touch.
    Sounds like I want to keep long_extent and lateral_extent and when I code to use them then I want to use maximum values from all endline/styles.

10. Sounds like I ought to have an 'undecorated' or 'invisible' style and use this as a
    default endline style. Or,  have lateral_extent and long_extent attributes of node(2). It would make sense if route hit area made lateral_extent visible. 
    Sounds more like I should have the latter calculated from the former. 

11. I need to ask the question what is the difference between long_extent and minarmlem ?
Hmmmm. Looking at example that I have drawn minarmlen is long_extent plus a small amount pf padding. Seems to me that I should equate the two and specify long_extent to include a sliver of padding.  

12. It is feeling horribly to me like I need change the name of 'endline_style'
to being 'line_marker', which by the way is vectorial. Introduce a supertype of 'shape_style' called 'graphic_style'. Introduce a second subtype of 'shape_style' which is 'line_style'. Copy attribute lateral_extent to 'linestyle' and add attribute 'minarmlen'.
13. Remove 'minarmlen' from 'line_marker'.
14. Investigating whether I can use place right edge of label at offset from point to position labels
(instead of having logic that uses width and height thereby reusing existing logic of width, height and padding). Extended stack_of_labelled_points example to check this out - it sort of works but the logic for calculating size of text seems flawed. 

### Proposal
1. Modify the flex diagram model
  + Remove the attributes stroke, stroke-width, stroke-dasharray and minarmlen from entity type 'endline_style'.
  + Rename 'endline_style' to 'line_marker'. 
  + rename reference relationships endline.style, default.start_style, default.end_style
  to endline_marker, default.start_marker, default.end_marker.
  + Introduce types 'graphic_style' and 'line_style' so that
  ```
  graphic_style ::= shape_style | line style;

  graphic _style => fill; stroke, stroke-width, stroke-dasharray, fill-opacity, fill-rule.

  line_style => label_long_offset (optional), 
                label_lateral_offset(opptional),
                lateral_extent,
                long_extent;
  ```
  + add to type 'node(2)' new attributes  label_lateral_offset and label_long_offset 
  + change the linestyle reference relationship of node(2) to be called line_style and to be of type line_style.
  + rename reference relationships from defaults to be 'start_marker' and 'end_marker'
  + add text descriptions to the  types and relationships discussed in this change note.
4. Update flex2.css.xslt to generate style defintions from line_styles.
5. Update that xslt that implments defaults with the new names of defaults.
  + Need to rename 'diagram.endpoint.endline_style' to be called 'diagram...route.node-+line_style.xslt'
and recode.
6. Update diagram.route.path.xslt which uses endline_style and minarmlen.
************  Keep minarmlen or replace? ***
7. Update ERmodel2.flex.xslt to 
  + generate destination/linestyle (as either solidline or dashedline).
  + not to generate empty annotations when relationship names or inverse names are absent.
8. Modify eraFlexStyleDefinitions
  + change dashedline and solidline from being endline_styles to being line_style.
    and add extent attributes for these styles.
  + add endline_style's for crowsfoot, identifying and squiggle.
9. Modify testFlexStyleDefinitions
  + as above, change the four endline_style'ss to being line_style's.
    and add extent attributes for these styles.
  + add endline_style's for crowsfoot, identifying and squiggle.
10. Add new xslt files with new rules for calculation of attributes 
node(2).label_lateral_offset and node(2).label_long_offset. Code these rules in template
xslt file 'diagram...route.node-+label_long_extent'.
11. Recode diagram...route.path.label-+xP to use node(2).label_lateral_offset and node(2).label_long_offset.
12. Modify xslt_templates 'build.ps1'  to swap label_long_extent and label_lateral_extent?
13. Raise a separate change note to describe code that is needed to complete implementation of the ideas discussed here.
### Testing
Rebuild test and era methods. Build all selected examples. Also rebuild src_route flex examples.
### Completion Date
???

