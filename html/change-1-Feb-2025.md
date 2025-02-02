
## 1 February 2025
Support for identification scheme diagrams -- Implement support for a presentation directive that an entity type name be above the entity type box.

### Rationale
So that the identification scheme for an entity type can be drawn 
  + depicting all identifying relationships and attributes drawn left to right
  + with a representation of the type of all universals on the right
  + with all types drawn as vertical lines by setting width to be 0.05.

### Implementation
1. Implement support in ERmodel2diagram.module.xslt for a directive on an entity type
   of presentation/label/position/Upside.
2. Also in ERmodel2diagram.module.xslt nd in ERmodel2tex.xslt support a entity type shape SidesOnly.
   THIS HASNT BEEN IMPLEMENTED IN SVG.

### Testing

Produce the following diagrams
  + dramaticArtsCharacter..identificationScheme..diagram
  + dramaticArtsProduction..identificationScheme..diagram
  + dramaticArtsRole..identificationScheme..diagram

### Completion Date 
Completed 2 February 2025.
