
## 23 October 2024.
Flex Diagramming -- Tidy up examples. Support with new scripts.
### Rationale
To support testing change of 22 October 2024 and to support building of new non-top-down 
examples for entity modelling book.

### Summary

Modify build.ps1 for examples to use a new flex2svg.ps1 which has debug switch to support debugging.
Phase out previous and bugged, btw, generate_svg.bat.


### Proposal
1. Implement new flex2svg.ps1 by copying and reducing er1flex2svg.ps1.
2. Change build.ps1 in each of flexDiagramming/examples to use the new flex2svg.ps1 and not to use
either of buildAllExamples or buildExample.

### Testing
Rebuild all the examples collectively and rebuild the orthogonals example individually with debug switched on.

### Completion Date
24 October 2024
