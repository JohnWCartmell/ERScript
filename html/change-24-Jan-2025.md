
## 24 January 2025
Implement a diagram level directive by which the presentation of  attributes  on the diagram may be supressed.

### Rationale
So that multiple presentations of subsets of the same logical model can be made some with all atributes, some with just identifying attributes and some with no attributes at all. 

### How?
Introduce a directive
entity_model/presentation/diagram/attributes
whose values can be None or IdentifyingOnly. 


### Implementation
1. Modify ERmodel2.diagram.module.xslt three places that needs coding for.
template "self_offset_to_ets", template "offset_to_ets"
template "entity_type_content".

### Testing

1. Will be required for. and therefore tested by, the diagrams mentioned in change of 22-Jan-2025.
 	+ dramaticArts1Path1..diagram [y]
 	+ dramaticArtsPath2..diagram [y]
	+ dramaticArts1Character..identificationScheme..diagram.xml [y]
	+ dramaticArts1Role..identificationScheme..diagram.xml  [y]
	+ dramaticArts1Production..identificationScheme..diagram.xml [y]

2. To test the change for abstract entity types experiment with the directives 
using the selected example chromatography_analyis_record. [y]

### Completion Date 
Completed 25 January 2025.
