
## 11 November 2024
Flex Diagramming - fault taking account of total extent of label with padding. 
Also it would be good if the padding around labels was given visualisation when debug whitespace set.

### Problem
A label attached to a point, the extent of the outer of the point does not take account of the padding right and bottom.
### Summary
I discovered this bug when testing and experimenting with stack_of_labelled points example
when testing change of 10-Nov-2024.

### Analysis

### Proposal
1. Change diagram2.svg.xslt to render padding of labels -- only one line needs change to include labels
(the line is in template wrap_relationships).
2. Change file diagram.wrP.xslt, change the rule for defining the wrP of a point to include padding of an attached label.
3. Modify example x.cardinalsandtest.smarts.xml to include use of points with multiple labels demonstating padding of points. Have a single point with four texts attached: north,south, east and west.
### Testing
Use stack_of_labelled_points example to unit test. Testing will take place anyhow as part of change of
5-Nov-2024 which this change will precede.
### Completion Date
11th November 2024. 

