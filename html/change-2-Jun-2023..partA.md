

## 2 June 2023 Part A - Specification of auxiliary scope constraints 

### Summary
Enable the specification of auxiliary constraints.

This change is the first of two changes specified in outline in the change note of 2 Hune 2023.

#### Proposal
1. Enable the specification of auxiliary constraints by adding the following to `ERA..logical.xml`
```
reference => auxiliary_scope_constraint*

auxiliary_scope_constraint => identifying_relationship : REF(reference_or_dependency)*,
							  equivalent_path: navigation
```
where the scope of `identifying_relationship` is given by
```
		parent::reference/type::entity_type = identifying_relationship/parent::entity_type 
```

### Analysis 
1. Changes required
	- the surface model to specify auxiliary scope constraint,
	- the logical model to represent auxiliary scope constraint,
	- the 1.6 parser -- to parse auxiliary scope constraint, 
	- physical enrichment -- to take account of auxiliary scope constraint,
	- xpath enrichment -- to implment auxiliary scope constraint.

I originally thought  that `erlib` would the change but it doesn't need to because the change will be picked up via generated `xpath_evaluate`

#### Testing


