

## 2 June 2023 Part A - Specification of auxiliary scope constraints 

### Summary
Enable the specification of auxiliary constraints.

This change is the first of two material changes specified in outline in the change note of 2 Hune 2023.

#### Proposal

1. Enable the specification of auxiliary constraints by adding an entity type `auxiliary_scope_constraint` t to `ERA.surface..logical.xml`
as follows
```
reference => auxiliary_scope_constraint*

auxiliary_scope_constraint => identifying_relationship : string,
							  equivalent_path : string
```

2. Add to the logical model `ERA..logical.xml`
```
reference => auxiliary_scope_constraint*

auxiliary_scope_constraint => identifying_relationship : REF(reference_or_dependency)*,
							  equivalent_path: navigation
```
where the scope of `identifying_relationship` is given by
```
		parent::reference/type::entity_type = identifying_relationship/parent::entity_type 
```

3. Extend  the 1.6 parser -- to parse auxiliary scope constraint.
4. Modify physical enrichment -- to take account of auxiliary scope constraint when generating foreign keys.

5. Modify xpath enrichment -- to use the auxiliary scope constraint in `xpath_eveluate` of a `reference`	 relationshuip

I originally thought  that `erlib` would the change but it doesn't need to because the change will be picked up via generated `xpath_evaluate`

#### Testing

We will test this feature by implementing part B of this chenage of the 2nd June 2023. 
