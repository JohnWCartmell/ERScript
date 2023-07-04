

## 4 July 2023

Remove the concept of `group` from the meta model whilst keeping it in the presentation of existing ER models.

### Summary
Because I wish to publish the meta model I wish it to be as trimmed down as possible. The concept of a `group` of entity types
is in there at the moment but is almost entirely used for grouping togther for the sakes of presentation of the diagram.
The only other functionality of group is to group together entity types which are to be generated in the same typescript module but we can easily do without this. In brief
- remove group from ERA meta model
- in all examples that use groups move group from ..logical.xml into ..presentation.xml
- in chromatogram_analysis_model move module_name directives from groups onto entity types.  

### Proposal
1. Recode `ERmodel.consolidate..module.xslt` to consolidate group structure into entity type structure.
2. Recode `ERmodel2.class_enrichment module` to propagate module name down composition structure (in addition to current propogation to sub types)
3. In each exampleSelected move groups into ..presentation file.
4. In chromatogram_analysis_record example move module_name directives from enclosing groups onto their root entity types
5. From `ERA..logical.xml` remove entity types `group` and `entity_type_like`.
6. Move groups from `ERA..logical.xml` into `ERA..presentation.xml`.

### Testing

### Completion Date


