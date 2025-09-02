## 1 Sept 2025
flex diagramming --- in calculations of widths and heights of enclosures
                           take account of routes and their labels 
### Overview 
Ensure that the width and height of an enclosures has sufficient room for its connecting routes and their labels.

### Analysis 
Would like to calculate the exact position and extents of labels of connecting routes. But cannot do so
because I cannot know the positions of endpoints as width and height are calculated  because      
  + the relative positions of endpoints are calculated from slot numbers
  + whose calculation requires angles to other end
  + whose calculation requires positions of enclosures
  + whose calculation requires widths of enclosures.   

### Design
Instead of an exact calculation use a heuristic:
add the widths (heights) of all labels of all connecting routes together and add three times the padding.

### Implementation
1. Implement xpath functions in a hash table flexLib in file `diagram.flexLib.module.xslt`.
2. Use these function to implement the heuristic in file `diagram.wP.xslt`.

### Completion Date 
1 September 2025

