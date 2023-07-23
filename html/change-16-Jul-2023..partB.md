
## 16 July 2023 Part B Update the meta model.

### Summary  
1. Introduce new entity types or rename existing ones if the text strongly suggests new terminology. 

2. Some knock on changes to xslt.

### Analysis
1. In the entity modelling book I contrast core from constructed. Consider instead a contrast between primitive and inferred.
Consider primitive (relationship) ::= composition | reference | dependency. 
Consider renaming `constructed_relationship` to be `inferred_relationship`.
Would want to change entity modelling book likewise.   

### Proposal

1. Change `ENTITY_TYPE` to `entity type like`. [x]
- knock on code change to `ERmodel2.initial_enrichment.module.xslt` and `ERmodel2.physical_enrichment.module.xslt`. [x]

2. Change `entity_type` to `entity type`. [x]
3. Change `Relationship` to `directional relationship`. [x]
4. Change `reference-or_dependency` to `primitive_relationship`. [x]
5. Move `identifying(1)` from `Relationship` to `primitive_relationship`. [x]
6. Remove the reference relationship named `inverse` from constructed_relationship.[x]
7. Give the name `host entity type` to the dependencies up to entity type from `Relationship` and `attribute`[]
- knock on change (where??) from TBD_readrel('..') to TBD_readrel('host_entity_type') []
8. Change `navigation` to `directional path` [x]
- knock on changes to comments (where???) []
9. Change `complex` to `composite` [x]
10. Change `component` to `step` []

### Testing
1. rebuild and validate meta model.
2. rebuild and validate cricket model.

### Completion Date


