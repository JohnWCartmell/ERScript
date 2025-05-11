
## 08 May 2025
flex diagramming --- improve the rules for laying out sideways routes
### Description
Sideways routes are generated from reference relationships by ER2flex. 
Improving the auto layout will improve ER2flex.

### Analysis
Currently the default rules for laying out sideways routes are intended  to draw straightline from the midpoint of the right hand edge of the source to the midpoint of the left hand edge of destination. 
There is a bug in the code somewhere though because it looks like the destination is conected to the left hand sise and then sets off to the *right* which is into the entity type reather than away from it. 
This current implementation is found in file in ER2flex.xslt and for the source plants:
```
      <right_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </right_side>
```
and within the destination plants
```
	  <left_side>
         <deltay>0.5</deltay>
         <annotate_low/>
      </left_side>
``` 


### The Idea
Remove this code from ER2flex and add rules to determine left hand side or right side by 
some means.

It first seems that I could use of `angleToTheOtherEnd` or more secifically the sign of that value.
Sadly this causes a circularity in the dependencies. We need a more subtly way.

### Implementation.
2. Update the example flexDiagramming/examples/src_routes/sideways_routes not to specify specific edges 
   and so as to text left to right and right to left routes.
3. Move the generation of left_side and right_side out of er2flex into diagram..route.node-+specific_edge.xslt.
   Use angleToOtherEnd to decide between left_side and right_side.


### Testing

A good example to test the enhancements is
+ exampleSelected/airlineTravel..logical.xml.xml 

### Completion Date 
TBD

