
## 28 May 2025
flex diagramming ---  calculation of endpoints using angleToOtherEnd.


### Overview 
1. The calculation of endpoints for top down routes has previously been implemented but, as it turns out now, is incorrect in some instances.
2. This change is to improve that implementation and to implement for sideways routes as well.
3. This change is a branch out from the change of 18-May-2035 which is not yet implmented.

### Language, Model, Rules
+ routes are directional they lead from one enclosure to another, possibly the same,
+ they are specified to start from an specific edge of a source and to lead to a specific edge of a
destination. We have the following model 
```
node(2) ::= source | destination;

node(2) => :specific_edge;    # unnamed composition

specific_level ::=  top_edge  | bottom_edge ;
specific_side ::= left_side | right_side ;
specific_edge ::= specific_level | specific_side ;
```
+ a route has two terminating points one is flagged as the startpoint the other as the endpoint,
+ the position of a point that terminates at one of the top_edge or the bottom_edge is specified in an attribute deltax,
+ likewise, the position of an edge that terminates at left_side or right_side is specifed by an attribute deltay. 
There are rules which define the values of deltax and deltay by comparing the directions of all routes terminating at the same side or edge and be assigning slotNos. These directions are specifed as attribute `angleToOtherEnd`. 
We have, therefore, the following attributes:
```node(2) ::= angleToOtherEnd ;

specific_edge =>
            noOfSlots : NonNegativeInteger, 
            slotNo : NonNegativeInteger, # slots are number from 0 to noOfSlots - 1 
specific_level => deltax : float ;
specific_side => deltay : float ;
```

### Definition  of angleToOtherEnd
My previous defintion of this was flawed and not thought out. The revised definition now meets the requirement that we have for calculation of slot numbers. The revised definition fixes a bug that I hadn't noticed in the original implementation for top down routes which showed up in the relatively rare case of an enclosure having multiple top down routes arriving at its top edge. 

As in the original definition, the revised direction calculates an angle to a line connecting the top left corner of an enclosure at one end of a route to the top left corner coordinate of the enclosure at the other end of a route. 
Call this line the `route direction vector`. Each route has two direction vectors, one as considered from the source and one as considered from the destination.

The angleToOtherEnd is defined for routes connecting to each specific edge as follows:
+ top_edge -- the clockwise angle from the y axis to the route direction vector,
+ right_side -- the clockwise angle from the x axis to the route direction vector,
+ bottom_edge -- the anti-clockwise angle from the negative y axis to the route direction vector.
+ left_side -- the anti-clockwise angle from the negative axis to the route direction vector.

The reason for the anti-clockwise measurements is that for the left_side is so that slot nos  be allocated
 anti-clockwise, that is top down, because deltay increases downward.

 Likewise the bottom edge angle is anti-clockwise because deltax is from left to right which on the bottom edge is anti-clockwise.


### Implementation


#### Changes to the flex diagram model
1.  Modify the flex diagram meta model `flexDiagram..logical.xml` and the associated
`flexDiagram..presentation.xml` to document some of the attributes we will be working with. 
Flag the following attributes of node(2) as derived by adding a cheeky `<implementationOf/>` flag:
+ slotNo
+ angleToOtherEnd

2. In the  source file remove the unused attributes of node(2)
+ `ratio`
+ `destRelPos`[x]

3. Add derived attribute noOfSlots to specific_edge.[x]

4. In the same diagram model source files, move slotNo attribute to entity type specific edge.
+ Modify `diagram..route.node-+slotNo.xslt` accordingly and change name of the file to be
`diagram..route.node.specificEdge-+slotNo.xslt`. [x]
+ Modify `diagram..route.node.specificEdge-+deltax.xslt` accordingly.[x]
+ Modify `diagram.route.path.xslt` accordingly.  
  Rename this file to be `diagram...path.cardinal-+deltax-+deltay.xslt`  [x]

#### Implementing the Rules
5. Remove existing angle calculation functions in file `diagram.function.module.xslt`.
Implement four functions:
+ diagram:NoughtToTwoPiClockwiseAngleFromXaxis
+ diagram:NoughtToTwoPiClockwiseAngleFromYaxis
+ diagram:NoughtToTwoPiAntiClockwiseAngleFromNegativeXaxis
+ diagram:NoughtToTwoPiAntiClockwiseAngleFromNegativeYaxis

6. Using the four function, revise the rules for angleToOtherEnd in file `diagram..route.node.-+angleToOtherEnd.xslt`.

7. Revise rules for slotNo in file `diagram..route.node.specificEdge-+slotNo.xslt`.

8. Implement rules for deltay in a new file `diagram..route.node.specificEdge-+deltay.xslt`.

### Testing
1. Test  on all examplesER2flex.Pay particular attention to
+ Testing routes from different quadrants 

2. Test on all examplesSelected.
Pay particular attention to
+ cricket (entity type `player` has multiple incoming routes to left hand side),
+ relational meta model (entity type `primary key entry` has outgoing and incoming on its right side).

### Completion Date 
28 May 2025

