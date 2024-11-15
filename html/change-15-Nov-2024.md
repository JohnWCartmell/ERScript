
## 15 November 2024
ERmodel2.diagram.xslt. Fix bug in display of partial reflexive reference relationship that shows up in the example 'conceptualExamples/individualIsMarried.xml'.
### Problem
After changes to rendering code last year, the rendering (in svg at least) of this
reflexive relationship  had dashed lines superposed with the effect of making them appear as a solid line. Thus it appears that the relationship is mandatory whereas it is in fact optional.
### Proposal
1. Modify ERmodel2diagram.module.xslt, template 'render_path' not to render the second half of a relationship in the event of a relationship being reflexive i.e. being its own inverse.
### Testing
Check that the problem with the rendering of example individualIsMarried.xml in svg is ok.
### Completion Date 
15 November 2024
