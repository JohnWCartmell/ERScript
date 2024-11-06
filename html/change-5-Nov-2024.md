
## 5 November 2024
Document and fix use of linestyles and endline style in flex diagram model.

### Rationale
I want to use flex diagramming to produce new non-topdown diagrams for the `introduction to entity modelling' paper. After recent tidying I have broke ERmodel 2 svg via flex. I seem to have muddled thinking leading to inconsistency in the way that I am trying use linestyles and endline styles. Need to document what the intention of the flex diagram model in this area and then fix the code. Might need to adjust the recently produced style definitions files. Might need to fine tune the flex diagram model.

### Summary
Document here and in the flex diagram model descriptive text. 

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
Go figure!!!

### Proposal
1. Remove the attributes stroke, stroke-width, stroke-dasharray from entity type 'endline_style'.
2. Add text descriptions to the types and relationships summarised above.
3. Update ERmodel2.flex.xslt to generate destination/linestyle (as either solidline or dashedline).
4. Modify eraFlexStyleDefinitions
  + change dashedline and solidline from being endline_styles to being shape_style.
    add a comment to say used for styling routes.
  + add endline_style's for crowsfoot, identifying and squiggle.
5. Modify testFlexStyleDefinitions
  + change the four endline_style'ss to being shape_style's.
    add a comment to say used for styling routes.
  + add endline_style's for crowsfoot, identifying and squiggle.



### Testing
Build all selected examples.

### Completion Date
2nd August 2024.

