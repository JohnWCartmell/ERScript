

## 26 June 2023
Removal of unnecessary reference relationships from the meta model.

### Summary
1. Following the change of 2nd June 2023 and in particular following proper support for reference relationships to types
with identifying dependencies change the meta model and remove recently added refrence relationships:
```
component.relSrc   (this only added on 1st June 2023)
auxiliary_scope_constraint.idRelationshipSrc (this was only a temporary addition)
implementationOf.destAttrHostEt  (this only added 26 May 2023)
```
### Proposal


