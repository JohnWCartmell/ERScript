

## 1 June 2023
Correct the modelling of the `component` entity type in the metaModel `ERA..logical.xml`.

### Summary
1. Add a relationship `relSrc`.
2. Define the scope of the `rel` relationship to be
```
	rel/parent::entity_type = relSrc
``` 

### Starting Point
Currently `component` in the logical meta model is specified as having four relationships:
```
   	component => 
		rel:reference_or_dependency 
		src:entity_type
		dest:entity_type
```
and the scope of the `rel` relationship is defined as
```
	rel/parent::entity_type = src
``` 

### Reason
1. The current scope of `rel` is incorrect.
2. Scopes of `rel` needs to be  corrected  so thatthe metamodel will be navigable with erLib.
3. Want to improve and correct the model so that it can be published  eventually.


#### Analysis
Don't *need* to change any code except for part of the the logical2physical transformation  in `ERmodel1.initial_enrichment.xslt`.

#### Changes
1. Add `relSrc` to `ERA..logical.xml`. Edit `ERA..presentation.xml` `ERA..descriptive_text.xml`.
2. Populate `relSrc` in `ERmodel1.physical_enrichment.xslt`.
3. Rebuild the meta model.

#### Testing
1. Inspect one result to check that `relSrc` is being populated with the correct value in the case when `src` and `relSrc`
are distinct: 
	1. Go to the file ERA..physical.xml
	2. Find the entity `reference` relationship with name `rel` of entity type `implementationOf`.
	3. Look at its `<riser><component>`. It should have `<rel>..</rel>`, `<src>reference_or_depedency</src>` and
		`<relSrc>Relationship</relSrc>`. [x]
2. Test by rebuilding all examplesSelected and checking all physical validation reports for errors.[x]

