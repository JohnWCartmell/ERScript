
## 06 May 2025
flex diagramming --- fix bugs in layout and formatting of routes 
### Description
1. Bug One. Sideways routes connect the right hand side of the source to the left hand side of the destination but the endarm sets off in the wrong direction.
2. Bug Two. None of the src_route flexDiagramming examples build. All fail because an empty text style is generated into labels and this causes a subsequent crash when trying to use font information.


### Implementation.
1. Bug One fix. Edit diagram.route.path.xslt and remove one minus sign. 

2. Bug Two fix. Remove the generation of text_style into endpoint label from source  diagram..path-+point.startpoint+ewQ.xslt  and diagram..path-+point.endpoint+ewQ.xslt.
Merge the removed logic  with the current logic to use defaul text_style in source diagram.text_style.

### Testing
1. The bug regarding direction of destination arm can be tested using
+ exampleSelected/cricketMatch..logical.xml
2. Test the fix to bug two by rebuilding all the src_route flex diagramn examples and by 
rebuilding and checking 
cricketMatch and checking that it still uses style relname and hasn't started using style "normal".

### Completion Date 
TBD
