
## 30 October 2024 
Crash generating flex svg for relationalMetaModel3..logical.

### Summary
flex2svg is breaking on the diagram produced by er2flex for relationalMetaModel3..logical.

### Investigation
ERmodel2flex.xslt is not generating the source of the route properly when a reference relationship is identifying.

### Fix
1. A one line fix in ERmodel2flex.xslt.

### Testing
Fixes three examples in all
	+ grids
	+ relational meta model 3
	+ chromatogram analysis record

### Completion Date
Fixed - 1st November 2024.