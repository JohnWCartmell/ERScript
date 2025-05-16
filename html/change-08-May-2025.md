
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
Sadly this causes a circularity in the dependencies. We need a more subtle way. I have described
a better way of laying out in day notes of 13 May 2025.

### Implementation
To prevent the circularity instead of using the angle use the ordering of the enclosures in the source file.
1. Update the example flexDiagramming/examples/src_routes/sideways_routes not to specify specific edges 
   and so as to text left to right and right to left routes.
2. Move the generation of left_side and right_side out of er2flex into diagram..route.node-+specific_edge.xslt.
   Decide between left_side and right_side.
   To prevent the circularity instead of using the angle to other end use the ordering of the enclosures in the source file.
   Not ideal but works better than current until we can come up with a better approach.
### Testing
Test on examplesSelected using er2flex.
+ airTravel..logical.flex.svg isn't too bad but is suffering because all sideways routes connected at midpoint of side.
+ theDramaticArts..logical.flex.svg is now incredibly good!! A few tweaks will perfect it I think.
+ shlaer-lang..logical.flex.svg is also very good.
+ unitTest..logical.flex.svg is pretty poor and shows that improvements needed. Day notes of 13 May describe possible improvements.

### Completion Date 
Implemented 14th May 2025

