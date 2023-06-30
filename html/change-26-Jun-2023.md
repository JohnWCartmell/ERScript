

## 26 June 2023
Removal of unnecessary reference relationships from the meta model.

DOUBLECHECK REQUIRED

### Summary
1. Following the change of 2nd June 2023 and in particular following proper support for reference relationships to types
with identifying dependencies change the meta model and remove recently added refrence relationships:
```
component.relSrc   (this only added on 1st June 2023)
implementationOf.destAttrHostEt  (this only added 26 May 2023)
```
### Proposal

1. in `ERA..logical.xml` modify entity type `component`
- remove the relationship `relSrc` 
- remove the scope definition of relationship `rel` so that courtesy of V1.6 parser it defaults to having global scope.

2. in ERmodel2.initial_enrichment..module.xslt global edit `relSrc` to `rel...ENTITY_TYPE.name`. [CHECK}]

3. in `ERA..logical.xml` modify entity type `implementationOf`
- remove the relationship `destAttrHostEt` 
- remove the scope definition of relationship `destAttr` so that courtesy of V1.6 parser it defaults to having global scope

4. in ERmodel2.physical_enrichment..module.xslt global edit `destAttrHostEt` to `destAttr...ENTITY_TYPE.name`. [CHECK}]

5. In `ER..presentation.xml` remove the presentation of relationships `relSrc` and `destAttrHost`

