
## 22 January 2025
Enable the use  the  sideways presentation of dependencies as if they were reference relationships.

xxxx Support a directive by which attributes are nor displayed on diagrams.

### Rationale
So that multiple presentations of subsets of the same logical model can be made with some depedencies drawn left to right as if reference relationships. Want to share the logical model especially relationship ids and
the identifying flags.

### How?
Introduce a <sideways/> flag that a dependency is to be treated as if a reference relationship. 

So a dependency having
```
<diagram>
	<path>
		<sideways/>
	etc. etc.
	</path>
</diagram>
```
is treated as if a reference relationship.

### Implementation
1. Modify ERmodel2.diagram.module.xslt to treat dependencies flagged as above as if references and to ignore compositions which have such dependencies as inverses.

### Testing

Restructure the source of existing diagrams in the theDramaticArts folder in examplesSelected so that relationship ids have a single source.
1. Change dramaticArts1..logical.xml so that all non-absolute structure is represented by dependencies rather than by composition relationships.
2. Edit dramaticArts1Path1..diagram and dramaticArtsPath2..diagram to 
include dramaticArts1..logical and dramaticArts1.annotate.presentation, to remove relationship ids and cardinalities and to  draw dependencies sideways.
3. In the same style, create identificationScheme diagrams
	dramaticArts1Character..identificationScheme..diagram.xml
	dramaticArts1Role..identificatioinScheme..diagram.xml
	dramaticArts1Production..identificatioinScheme..diagram.xml

### Completion Date 
Coded in Ermodel2diagram 24 January 2025.
Complete testing 25 January 2025.
