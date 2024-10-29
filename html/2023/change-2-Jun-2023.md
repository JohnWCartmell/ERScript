

## 2 June 2023
Refinement of how relationships identified in the meta model `ERA..logical.xml`.
Knock-on bug fixes to logical2physical (hierarchical) regarding implementation of relationships
whose destination type has an incoming identifying dependency dominated by the riser
and including those whose riser is specified as theabsolute.    

### Summary
1. Specify the relationship `type:Relationship -> entity_type` to be identifying.

### Starting Point
Currently relationships are of four  types:
```
Relationship ::= reference_or_dependency | dependency | constructed_relationship
```
There is an identifying unnamed composition `: ENTITY_TYPE -> Relationship*` with `inverse ..: Relationship -> ENTITY_TYPE`.
There is an identifying name attribute
```
Relationship => name : string
```
There are no other identifying relationships nor attributes of `Relationship` or its subtypes.
Relationships are specified in the meta model, therefore, to be identified by source entity type and by name. 

The practice is different in that in many models 
1. multiple composition relationships with common source entity type are unnamed,
2. multiple depedencies of a single entity type are labelled '..'.  

To make up for this much xslt code that I have written uses source entity type, name and destination type to disambiguate (i.e. identify) relationships.

As a result of this divergence between  practice and meta model 
validation of the phsyical reports the failure of uniqueness of identification.

### Reason

This proposed change to the meta model will 

1. Justify the practice of like-named compositions and dependencies disambiguated by type.
2. Enable future use of like named reference relationships disambiguated by type.
3. Remove validation errors from physical model validation so that in future can terminate with error if validation errors found.
4. Enable use of erlib to navigate the meta model.

#### Analysis
1. There are three reference relationships with type of `Relationship` or a subtype thereof in the meta model. There are
	1. `rel: component -> Relationship`
	2. `rel : implementationOf -> reference_or_dependency`
	3. `inverse: constructed_relationship -> constructed_relationship`
	4. `inverse: reference -> reference`
	5. `inverse: composition -> dependency`
	6. `inverseOf: dependency -> dependency`
2. For each of these six reference relationships we will require a way of identifying the type of the referenced relationship.
   - In case 2. (the `rel` reference from `implmentationOf`) a new foreign key will need be introduced. 
   - In cases 3. - 6. (`inverse` and `inverseOf`) a new kind of scope constraint will need be required.
   - In case 1. (the `rel` reference from `component`) the current 'dest' attribute of component can be seen as a (currently) after the fact foreign key.
3. We require a syntax to extend the current path syntax used in the surface structure and parsed by the v1.6 parser. The sytax we can use is compatible with my envisaged epath extension/front-end to xpath
	- specify relationship named `R` with destination type `T` as `R::T`
	- an unnamed relationship with destination type `T` will be specified simply as `::T`.
4. We will need change physical enrichment not to generate additional foreign keys in case of relationships with the new kind of scope constraint.
5. We will need modify `readRelationship` in erlib to be able to use the new kind of scope constraint to identify teh destinations of relationships.
	- ideally we will need to change code generators (python, typescript, ?) and run times as well to incorporate the new read relationship logic.
6. Existing logic for example in xpath enrichment and  physical enrichment that already successfully disambiguates  can stay the way it is for the time being. At some time it will be replaced by erlib based code. 
7. The changes should be restricted to
	- the logical model, 
	- the 1.6 parser, 
	- physical enrichment
	- erlib
	- changes to examples to use the new feature (WHICH?) 
		- the meta model --- the xpath_evaluate patch can be removed
8. The new an additional scope constraint ideally will enable 
	- specification of an identifying feature of the destination type of a reference 
	- specification of an equivalent path
9. May as well assume that there can be any number of auxiliary scope constraints.
10. Will need to change the meta model and the surface model to describe the new auxiliary constraints.  

#### Proposal
Split this change into a numnber of smaller steps that can be separately implemented and tested:
- preparation simplification and improvement of code
- Part A -- specification of auxiliary scope constraints
- Part B -- specifying the type of a relationship to be identifying

