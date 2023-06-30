

## 13 June 2023
Remove the notion of `key` constraint from the meta model and from the code generators. 

### Summary
1. Following the change of 2nd June 2023 and in particular following the introduction of auxiliary scope constraints, 
the notion of a `key` to a reference relationship is redundant since a key constraint is a partiular kind on 
auxiliary scope constraint in which the 
`identifying_relationship` is the `projection_rel` of a pullback and the `equivalent_path` is the `key`.

### Analysis
- key constraints are only used from the chromatographAnalsysRecord example
- need to modify generators that support key constraints to support auxiliary scpe constraints instead
	- typescript
- need to remove all other mention of key constraints
   - meta model
   - xpath-enrichment
   - 2phyiscal enrichment

### Proposal


