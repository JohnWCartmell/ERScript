
## 15 May 2025
flex diagramming --- Introduce `<wfill/>` and `<hfill/>` directives.
### Description
Add support  for a directive `<wFill/>` directive for enclosures which directs that
the width of the enclosure be the width of its parent enclosure, if it has one, or the parent diagram otherwise.
Similarly, en passant, add support for `<hFill/>`. 

### Reason
1. To support name stripe for UML style class diagrams.
2. To be used for the root (absolute) of the diagram.

### Analysis
1. Need to be careful because  calculation of `wr` for the child
enclosure is dependent on the width of the child which is directed to be set to the width of the parent, but the width of the parent depends on the wr of the child.
Unless we specify the wr of the child to be some constant then we get a circular dependency.
The obvious thing to do is to set it to zero.
2. For absolute it looks good if we set the width to be the width of the diagram minus twice the margin.
3. Setting width to be parent width minus twice margin is likely to be the most useful option. If tight fit is required then margin can be set to zero. 

### Implementation
1. flexDiagramming/xslt_tempates/diagram.wP.xslt For enclosure without a specfied width (wP) and with wFill (wPFill) specified set width to be parent width minus twice parent margin.

2. flexDiagramming/xslt_tempates/diagram.wrP.xslt For enclosure without a specifed wr (wrP) and with wFill (wPFill) specified set wr to be zero.

3. ERmodel2flex.xslt for absolute  generate an embedded wFill directive in place of the current (temporary) fixed width.

### Testing
1. Regenerate all flex diagrams from examplesSelected.
2. Use wFill for a name stripe (or an attribute box?) in the hand coded UML diagram flexDiagramming/examples/UML/shlaerMellorDepStudentProfessor0.UML.flex.xml.

### Completion Date 


