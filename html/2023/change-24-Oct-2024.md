
## 24 October 2024.
Flex Diagramming -- Bug fix generation of paths in a route regarding interplay between deltax and noOfSlots.

### Rationale
The orthogonals.xml and mixed_routes.xml examples are broken.

### Analysis
Rules have been implemented which rely on noOfSlots.
noOfSlots is generated when deltax is generated.
This breaks routes in which deltax is specified in the diagram source. 
Therefore need to separate out the generation of deltax and the generation of noOfSlots.

### Proposal
1. Create a new file in flexDiagramming xslt folder named `diagram...route.node.specific_edge-+noOfSlots.xslt`
containing rules for creating noOfSlots.
2. Edit rules in file 'diagram...route.node.specific_edge-+deltax.xslt'
to have noOFSlots as a precondition instead of creating noOfSlots alongside deltax.

### Testing
Rebuild all example routes.
Rebuild brinton example.
Rebuild cricket example.

### Completion Date
24th October 2024