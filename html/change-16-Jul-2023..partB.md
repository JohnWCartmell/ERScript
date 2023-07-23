
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
4. Change `reference_or_dependency` to `primitive_relationship`. [x]
5. Move `identifying(1)` from `Relationship` to `primitive_relationship`. [x]
- knock-on v1.6 parser change not to create identifying for a composition relationship [x]
- knock-on change `ERmodel2.diagram.module.xslt` to display comp as identifying if inverse dependency is identifying
6. Remove the reference relationship named `inverse` from constructed_relationship.[x]
7. Give the name `host entity type` to the dependencies up to entity type from `Relationship` and `attribute`[x]
- include changes in `diagonal` and `riser` paths in `ERA.commonDefinitions.xml` and `ERA..logical.xml`[x]
8. Give the name `subject_relationship` to the dependency up from `pullback`[x]
- knock on change to scope diagonals and risers[x]
8. Give the name `subject_relationship` to the dependency up from `auxiliary_scope_constraint`[x]
8. Change `navigation` to `directional path` [x]
- knock on changes to comments (where???) []
9. Change `complex` to `composite` [x]
10. Change `component` to `step` []

### Testing
1. Rebuild and validate meta model.
2. Rebuild and validate cricket model.

### Completion Date


