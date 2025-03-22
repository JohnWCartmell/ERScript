
## 22 March 2025
ERmodel2diagram.xslt --- Implement a diagram level directive to SuppressPathless compositions

### Background
Currently if the two entity types related by a composition relationship are presented on a diagram then so too is the composition relationship even if it does not have a diagram/path
specified.


### Rationale
I want to be able to present just part of a logical model but without thius change I can get an unwanted composition relationship. See Testing below.

### Specification
Add the directive alongside other entity_model/diagram/path directives so that in all
we have
````````````````
<presentation>
  <diagram>
      <attributes><None/>|<IdentifyingOnly/>|</attributes>
      <relid_condition><All>|<AllHavingImplementations/>|<None/></relid_condition>
      <dependency_relid_prefix>r<</depedency_relid_prefix>
      <reference_relid_prefix>r<</reference_relid_prefix>
      <compositions><SuppressPathless/></compositions/>
  </diagram>
</presentation>
````````````````


### Implementation
Simple implementation in Ermodel2.diagram.xslt.

### Testing

Produce the following diagram in the shlaer lang examplesSelected
  + shlaerLang-StudentProfessorDept..path..diagram

### Completion Date 
22 March 2025

