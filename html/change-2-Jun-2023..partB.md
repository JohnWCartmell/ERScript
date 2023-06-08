

## 2 June 2023 Part B - Modify meta model so that type of a relationship is identifying. 

### Summary
This change is the second of two material changes to effect the overall change note of 2 June 2023.

### Discussion
I was pretty excited that this change led to the `rel::type` syntax in 'epathlite' expressions. Note however that unlike in future imagined epath langauge the 'type' is the type of the relationship not a subtype. If this is also required in 'epathlite'  then I imagine that the meta model would need be further extended. In fact I think we might like a scope square
for the destination type just as a scope square is required for the src type. Interesting! If in the context of entity of type A we use the expression R::B then we need find types A' and B' and a relationship A -> B such that
A <= A' and B <= B'. Modelled as a component we have src A, rel and dest B so that the diagram
src/ancestor-or-self::entity_type = rel/parent::entity_type
dest/ancestor-or_self::entity_type = rel/type::entity_type 

#### Proposal
1. Copy away `ERA..physical.xml` for safe keeping.[x]
2. In `ERA..logical.xml` change the `type` reference relationship of entity type `Relationship` to be identifying.
3. From the file `ERA..logical.xml` remove the  xpath_evaluate patches of reference relationships `inverse` and `inverseOf`.
Temporarily rename them patch_xpath-evaluate. As a consequence of this change of 2nd June the generated xpath_evaluate will be equivalent to these hand written versions.  
4. Build the meta model so as to generate `ERA..physical.xml`. There will be lots of unwanted foreign keys. Copy this away for comparison later.[x]
	
5. Specify auxiliary scope constraints as follows:
	1. For relationship `inverse: reference -> reference` specify `type=parent::entity_type`.
		 - Generate and check that the unwanted foreign key (`inverse_type`) is no longer there.
	2. For relationship `inverse: constructed_relationship -> constructed_relationship` specify `type=parent::entity_type`.
		 - Generate and check that the unwanted foreign key (`inverse_type`) is no longer there.
	3. For relationship `inverse: composition -> dependency` specify `type=parent::entity_type`.
		 - Generate and check that the unwanted foreign key (`inverse_type`) is no longer there.
	4. For relationship `inverseOf: dependency -> composition` specify `type=parent::entity_type`.
		 - Generate and check that the unwanted foreign key (`inverse_of_type`) is no longer there.
	5. For relationship `rel: component -> reference` specify `type=dest::entity_type`.
		 - Generate and check that the unwanted foreign key is no longer there.
	6. For relationship `projection_rel: pullback -> reference` specify `type=type::entity_type`.
		 - Generate and check that the unwanted foreign key (`projection_rel_type`) is no longer there.

6. Check that instance validation of `ERA..physical` has no errors. Specifically check that unnamed relationships no longer are flagged as errors. 

#### Testing
- Build the meta model.
- Inspect the generated code for xpath_evaluate is equivalent to the previously hand written patch version.
- Instance validate the model xxx. This instance validation failed previous to the patch to inverse. Check that the validation now runs to completion.
- Instance validate the xpath model.  