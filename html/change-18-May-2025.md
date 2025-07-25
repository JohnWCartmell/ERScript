
## 18 May 2025
flex diagramming --- upgrade support for annotations on route endpoints.

Support a second label at each end of a route.

### Overview and Rationale
1. support a second label at each end of a route so that can draw diagrams with cardinality as a text label as in UML.
2. Generalise label positioning so that works on sloping terminal arms as well as horizontal and vertical as at present. 
3. Gravitate toward more general orientation directives -- focus on clockwise
and anticlockwise instead of left, right, high and low as at present. 
4. Improve the positioning of endpoints for routes along the edges of enclosures.

### Language
+ routes are directional they lead from a source enclosure to a destination enclosure,
+ routes follow paths which are sequences of points and line segments,
+ lines segments are cardinals (ns and ew) and ramps,
+ a route has two terminating points one is flagged as the `<startpoint>` the other as the `<endpoint>`,
+ a route has two terminal arms one is flagged as the `<startarm>` and the other as the `<endarm>`,
+ a route currently has two labels. One is attached to the startpoint and one to the endpoint.
+ the text of the labels can be specified as the source/annotation and the destination/annotation and rules 
then represent the labels on their respective endpoints.

### Aside
Much code would be simpler if a route was represented by a pair of paths to a midpoint. Unless we do this change which involves writing new code as well as simplifing existing code (and whichI don't want to do just now) there needs to be different rules for start points and arms to end points and arms. So be it.

### Analysis
In the current code, irrespective of the presence or absence of annotations,
+ a label is created on the startpoint of a route by the rule which creates
startpoint and startarm of a route in source `diagram..path-+point.startpoint+ewQ.xslt`.
+ a label is created on the endpoint of a route by the rule which creates
endpoint and endarm of a route in source `diagram..path-+point.endpoint+ewQ.xslt`. 

Subsequently,
+ the text of the label is populated from appropriate annotation by a rule in source `diagram..route.path.point.label-+text.xslt`;
+ the text style of the label is populated from that specified for the route by a rule in `diagram.text_style.xslt`. This file name ought to change, btw, to diagram..label-+text_style;
+ the x of a label is populated by rules in source `diagram...route.path.point.label-+xP`;
+ the y of a label is populated by the duals of the rules for x.

### Recap
In the current code, labels are positioned so as to avoid conflicting with crowsfeet or arrowheads or other markers at the tip (the terminating point) of the terminal arm. 
To achieve this two distances the source and destination of the route
have attributes `label_lateral_offset` and `label_long_offset`. These attributes are set to contain values determined by the line_style of the route and its endline markers (it would be possible to specify these directly in the diagram if required). The  rules for these attributes are, respectively,
in the source files `diagram...route.node-+label_long_offset`. There is no need to change to this particular code, by the way, but the filename ought to be changed. It should be `diagram...route.node-+label_long_offset+label_lateral_offset`. 
(Aside:
 The rules defined in this file don't actually take into account the end markers they simply use the line style --- should improve in the future to implement as I first imagined.)

### Design
There will be schematic places for positioning labels.

Imagine a wheel with spokes radiating out in all directions.
Imagine the hub of the wheel as an enclosure and the spokes as possible terminal arms of routes.
Imagine the spokes to be labelled and that the labels overlay neither the hub nor the spokes.
Such a label can be said to be positioned clockwise or anticlockwise depending on its position either
earlier or later than the spoke it labels. 

In this way we have explained how the terminal arm of a route can be labelled in a clockwise position or an anticlockwise position. 

To illustrate this
+ For routes connected to the top edge of an enclosure 
   + clockwise labels are on right of the endarm
   + anticlockwise labels are on left
+ For routes connected to the right hand side 
   + clockwise routes are lower than the endarm
   + anticlockwise routes are higher

in a similar manner, routes connected to the bottom edge or the left hand side have a clockwise and anticlockwise label positions. 

### Angle theta of an terminal arm.
Terminal arms can radiate out in all 360 degrees from an enclosure. The actual angle of the endarm will be referred to as theta. We follow compass bearings so that 
+ zero degrees is an endarm heading directly upwards due north,
+ pi/2 is due east i.e. an endarm heading away to the right hand side,
+ pi is due south,
+  3 * pi/2 is due west,
+  2 * pi + infinitesimal is infinitesimally close to due south. 

#### Naming
+ ** This angle theta can be represented in the data model as  attribute `bearing`. **
+ Gives the possibility, should we need it in the future, of using the name `back-bearing`.
### Preferred Positions for Labels
#### Preferred Label Position Non-Cardinals - Position of Closest Approach

If you look at the wagon wheel,  for those spokes that are not cardinals then there is a preferred label position which gives most room for a close approach to both endarm and enclosure.

In this diagram 

![preferred positions](labelPosition.jpg),

you see that the closest position is the *clockwise* position in the following quadrants
+ north west ( 0 < theta < pi/2)
+ south east ( pi < theta < 3/2 pi )

and is the *anticlockwise* position in the other quadrants
+ south west (pi/2 < theta < pi)
+ north east (3/2 pi < theta < 2pi)



#### Preferred Label Position East-West Cardinals
Define the preferred label position for all mid-point connecting east west cardinals 
 to be the *anti-clockwise* position.
This is a convention rather than a space saver. The result is that for a simple east west relationship we get the end labelling as follows
```
------+                   +------
      | label1            |
      |-------------------|                         
      |            label2 |
------+                   +------
```
(both label1 and label2 are in the anti-clockwise position).

For other east-west cardinals label on the externally rather than internally so that we get

```
------+                                +------
      | right-upper       left-upper   |
      |--------------------------------|                         
      |                                |
      |--------------------------------|                         
      | right-lower       left-lower   |
------+                                +------
```

Implement as follows:
+ right upper --- anti-clockwise
+ right middle -- anti-clockwise
+ right lower -- clockwise
+ left upper --- clockwise
+ left middle --- anti-clockwise
+ left lower --- anti-clockwise
> Testing: flexDiagramming/examples/src_routes/sideways_routes

#### Preferred Label Position North-South Cardinals
For cardinals there is no position of closest approach. 
The rationale for the specification is similar to that for East-West cardinals.
+ top left --- anti-clockwise 
+ top centre --- clockwise  
+ top right --- clockwise   
+ bottom left --- clockwise
+ bottom centre -- clockwise 
+ bottom right -- anti-clockwise 
These nicely fit with the non-cardinals.
> Testing: flexDiagramming/examples/src_routes/topdown_routes

### Positioning of Labels
Labels have a preferred position (specified as above) and this then translates into
the rules for x and y values for labels. Labels are placed relative to an anchor point.


#### Anchor points Hc and Ha.
Note that these are merely conceptual points --- they are not represented by instances of points in the flex representation of the diagram.

Imagine a terminal arm having a rectangular box. 
This box has two corners that are relevant to label positioning.
These are Hc and Ha. Hc is the corner in the clockwise direction and Ha is the corner in the anticlockwise direction. 

Ha and Hc are at a distant h from the endpoint of the route where h is given by pythagorous from 
label_lateral_offset and label_long_offset as, say,
```
h = root(lat^2 +long^2)
```
The hypotenuse meets the terminal arm at the terminal point of the route. Denote by alpha the angle between the two.
Alpha us given by
```
alpha = tan^-1(lat/long)
```

#### Equations for calculating x and y for the point Hc.
Assume x and y are the usual cartesian coordinates (in particular that, unlike the flex coordinate system, y grows in an upward direction).
If theta is greater that zero (for endarms leaving from left to right)
then from h, theta and alpha we can calculate x and y values 
of Hc as follows
```
Hc.x =  cos(pi/2 - theta - alpha) * h
Hc.y =  sin(pi/2 - theta - alpha) * h
```
If theta is less that zero then the value for x needs to be negated. Therefore, for all theta
the x and y values can be calculated as
```
Hc.x =  sign(theta) * cos(pi/2 - theta - alpha) * h
Hc.y =  sin(pi/2 - theta - alpha) * h
```

The formula for the anticlockwise corner Ha are obtained by negating alpha to get:
```
Ha.x =  sign(theta) * cos(pi/2 - theta + alpha) * h
Ha.y =  sin(pi/2 - theta + alpha) * h
```
*These y values need to be negated, in the implementation, to take account of flex downpointing y-axis in the implementation*

#### The x and y values for a label
The `<at>` value for x and y values of a label is the anchor point.

The `place` value for the y value is either the top of bottom of the labels
as follows:
```
+ 7π/4 < bearing <= π/4    --- bottom 
+ π/4  < bearing <= 3π/4 
   + clockwise             --- top
   + anti-clockwise        --- bottom
+ 3π/4 < bearing <= 5π/4   --- top 
+ 5π/4 < bearing <= 7π/4
   + clockwise             --- bottom
   + anti-clockwise        --- top 
```

### Secondary label Positions
If a terminal arm has two labels and one label takes the preferred position then the other label
must take a secondary position. Let us support just one secondary position.

Looking at an example UML diagram in which cardinality and rolename are represented in labels then
the cardinality is shown the opposite side of the line to the rolename. One approach therefore is to
define the secondary position to a clockwise preferred position to be anti-clockwise and vice-versa.

#### Alternative Secondary Position Top-edge and Bottom-edge Endarms
An alternative secondary position which saves space for endarms connected to top and bottom edges 
is to position the secondary on the same side as the preferred position but further away.
If we call the further away positions point H2a and H2c, depending on whether anticlockwise or clockwise,
 then the calculation of the H2a and H2c y coordinate follows this pattern
```
top edge: H2a(y) = Ha(y) - text_height
bottom edge: H2a(y) = Ha(y) + text_height 
```
x coordinate must be calculated by following the angle alpha of the terminal arm. The calcualtions will
be something like
```
H2a(x) = Ha() + tan(beta) x text_height  
```
where beta is the angle between the endarm and the vertical and is between -pi/2 and pi/2.

Call these positions the clockwiseOuter and anticlockwiseOuter positions.

Use function `diagram:stringheight_from_text_style` for text height.
Call new function `diagram:xOffsetFromBearingAndyOffset` in file
`diagram.functions.module.xslt` to get x displacement.

### Implementation

#### Changes to the flex diagram model
1.  Modify the flex diagram meta model `flexDiagram..logical.xml` and the associated
`flexDiagram..presentation.xml` to document some of the attributes we will be working with. 
Flag the following attributes of node(2) as derived by adding a cheeky `<implementationOf/>` flag:
+ label_lateral_offset [x]
+ label_long_offset    [x]

2. In the same flex diagram model source files: 
+ add attribute secondary_annotation to node(2). Recall node(2) ::= source | destination.
+ remove annotate_left, annotate_right, annotate_high, annotate_low. 
+ add entity type orientation ::= clockwise | anti-clockwise.
+ add compositions 
```
orientation => clockwise | anti-clockwise ;
specific_edge => labelPosition : orientation, 
                 secondaryLabelPosition : orientation ;

orientation => :out(2) ; # an unnamed composition relationship

out(2) => ;                   # an attributeless entity type
```
Completed  [x]

3. Implement entity types startarm and endarm. Represent theta as attribute `bearing` as follows:
```
role ::= terminatingArm | source_sweep | destination_sweep | midarm ;

terminatingArm ::= startarm | endarm ;

terminatingArm => bearing : float;
```
Completed [x]

#### Calculation of angle theta as attribute `bearing`.

1. In source file `diagram.functions.module.xslt`
implement a function `diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis`
(by using `diagram:NoughtToTwoPiClockwiseAngleFromYaxis`)
to use 

Completed [x].

2. In new source file `diagram...path.cardinal.terminatingArm-+bearing.xslt`
implement rules for theta represented as attribute `bearing`

There is a lack of symmetry in the calculation of theta in that calculation will differ for startarm and endarm as follows:
```
+ startarm
   + ns theta = if starty < endy then 0 else pi
   + ew theta = if startx < endx then pi/2 else 3pi/2
   + ramp theta = diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis(endx-startx,endy-starty)

+ endarm 
   + ns theta = if starty < endy then pi else 0
   + ew theta = if startx < endx then 3pi/2 else pi/2
   + ramp theta = diagram:NoughtToTwoPiClockwiseAngleFromNegativeYaxis(startx-endx,starty-endy)
```

In xslt we will have upto 6 templates such as
```
match "path/ns[starty][endy]/startarm[not(bearing)]"
select "if (../starty &lt; ../endy) then 0 else math:pi()"
```

Completed [x].

#### Name change
Change the name of file  `diagram...route.node-+label_long_offset.xslt` to be 
`diagram...route.node-+label_long_offset+label_lateral_offset.xslt`. 

Completed [x].


#### Rules for labelPosition
Implement the following rules in file `diagram...route.specific_edge-+labelPosition.xslt`
+ top edge
``` 
if centre slot of an odd number 
then clockwise               
else if left half of top edge
then anti-clockwise          
else if right half of top edge
then clockwise               
```
+ left side
``` 
if middle slot of an odd number 
then anti-clockwise               
else if top half of left edge
then clockwise         
else if bottom half of left edge
then anti-clockwise 
```
+ bottom edge
``` 
if centre slot of an odd number 
then clockwise               
else if left half of bottom edge
then clockwise          
else if right half of bottom edge
then anti-clockwise 
```
+ right side
``` 
if middle slot of an odd number 
then anti-clockwise               
else if top half of right side
then anti-clockwise          
else if top half of right side
then clockwise 
```
Completed [x]

#### Rules for secondaryLabelPosition


Implement the following rules in file `diagram...route.specific_edge-+secondaryLabelPosition.xslt`.

Make the default secondary label position the opposite side of the endarm to the 
primary default position.  

Completed [x]. 

#### Rules for Creating labels
1. Add two new functions to file diagram.functions.module.xslt.
+ xOffsetFromBearingAndDistance (bearing:double, distance:double)
  = sin(bearing * distance)
+ yOffsetFromBearingAndDistance (bearing:double, distance:double)
  = - cos(bearing * distance)

The minus sign comes about because bearing is clockwise from north and our y axis is the direction south.

2. Add a function hypoteneuse to file diagram.functions.module.xslt.

Completed [x]

3. No longer create a label as part of creating the endpoints in source 
files `diagram...path-+point.endpoint+ewQ.xslt` and `diagram..path-+point.startpoint+ewQ.xslt`.

Completed [x].

4. Introduce a new source file  `diagram..route.path.point-+label.xslt` to create labels on startpoint and endpoint one for each annotation present. 
Flag each label as `<primary/>` or `<secondary/>`.

Completed for primaries [x].
Completed for secondaries [x].

5. Remove file  `diagram...route.path.point.label-+xP`
Replace by two files
 + `diagram...route.path.point.label-+x`
 + `diagram...route.path.point.label-+y`

These generate rules for  x and y for endpoint labels. 

The rule for x will call the function `diagram:xOffsetFromBearingAndDistance`  to get the x offset.
+ the distance to pass is the hypoteneuse `h` described above using pythagorus
from label_lateral_offset and label_long_offset,
+ clockwise the angle to pass is theta + alpha,
+ anticlockwise the angle to pass is  theta - alpha,
+ alpha is `math:atan(label_lateral_offset/label_long_offset)`.

Similarly the rule for y will  call function `diagram:yOffsetFromBearingAndDistance`.

Completed [x].

6. **As a tie-over until better scheme specified an implemented** Improve the distribution of endpoints of routes along edges of enclosures. By modifying the rule in files `diagram...route.specific_edge-+deltax`
and `diagram...route.specific_edge-+deltay`. 
If noOfSlots greater than two then reduce the distance between first and last slots and the corners. 
Currently deltax is given be
```
w * (slotNo + 1) div (noOfSlots + 1)
```
where w is the width of (the edge of) the enclosure. This equals
```
(w div (noOfSlots+1)) + ((w*slotNo) div (NoOfSlots+1))

```
change this to be
```
((w div noOfSlots) div 2) + ((w*slotNo) div (NoOfSlots))

```
This then will equally space the slots and have only a half space between corners first/last slot and respective corners.

Change deltay calculation likewise.

Completed [x].

### Testing
1. Test primary labels, default positioning on: flexDiagramming/examples/src_routes/topdown_routes.

> Extend this example so that there is an instance of an enclosure with two incoming routes
>  extend with enclosures H and I and two top down routes from H to I.
[x]
2. Test primary labels, default positioning on: flexDiagramming/examples/src_routes/ramps.[x] 

3. Test primary labels on: flexDiagramming/examples/goodlandCarHire/goodlandVariantA. [x]

4. Test primary labels on: all selected examples. [x]

5. Test secondary labels, default positioning on: flexDiagramming/examples/src_routes/ramps.[x]

### Completion Date 
Completed  22/07/2025.

We still need fine tuning of secondary labels but that will need to be done when I have places I want to use them.

Other side issues will need to be addressed separately:

+ calculation of label widths needs to be more accurate
+ need label_lateral_offset and label_long_offset to take account of presence or absence and extents
of endline markers such as arrow heads or diamonds.
+ a feature/bug ---  empty labels are created when no annotations are specified.
(Currently get a warning messages when a route has no annotation on one end or another.)
Note that these are needed as flags. See comments in code where labels created.
