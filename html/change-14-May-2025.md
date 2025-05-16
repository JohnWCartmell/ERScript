
## 14 May 2025
flex diagramming --- implement support for framearc to specify proportional rounding of corners of enclosures.

### Description
A framearc parameter is used in latex psframe and this is used in ERmodel2.diagram.module.xslt and rendered into both text and svg.
Support a similar approach in flex diagramming and specify the framearc parameter in xslt/flex/ERmodel2flex.xslt.

### Rationale
1. Improve look of er2flex produced ER models to better chance of switching for real.
2. Prepare for limited support for UML and framearcx=0. 
### Implementation.
1. Change ERmodel2flex.xslt to specify frameac=0.2 of instead of specifying rx and rx.
2. Implement a rule for rx and ry in new file flexDiagramming/xslt/diagram..enclosure-+rx+ry.xslt.
Use the algorithm from xslt/ERmodel2.svg

### Testing
Rebuild examplesSelected.

### Completion Date 
14 May 2025 

