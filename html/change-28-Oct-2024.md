
## 25 October 2024
Implement support for even odd fill colour in flex diagramming and modify era method to use it.

### Rationale
For the long term. 
Also in short term so as to be able draft some ER diagrams that are not strictly in the structured top-down style as examples of other styles for the entity modelling book.

### Summary

Support a default style that has an shape_style_odd in addition to shape_style.

### Analysis
1. Will first implement the changes of 22,23 and 24 October 2024.

### Proposal
1. To the flex diagramming meta model add shape_style_odd as a reference relationship, 
      shape_style_odd: default -> shape_style.
  For this edit files flexDiagram.logical.xml and flexDiagram.presentation.xml (folder flexDiagramming/flexDiagramModel).
2. Modify 'xslt/flex/ERmodel2flex'
      to plant default shape style eteven and default shape_style_odd to be etodd.
      not to generate shape style for an enclosure.
3. Modify `flexDiagramming/xslt/diagram.shape_style.xslt` so that the shape_style gennerated for an enclosure which doesn't have one is either default shape style or default shape style odd depending whther enclosure is at an even or odd depth.
Each outermost enclosure should have shape style etodd.


### Testing
Rebuild examplesSelected -- Brinton example, Chen example, Order Entry.

### Completion Date

