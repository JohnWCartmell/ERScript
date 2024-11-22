
## 16 November 2024
ERmodel2flex. Introduce surjective and injective attributes into the surface entity model. Provide missing styling logic into ERmodel2flex.
### Shortcoming
At the moment ERmodel2flex does not have logic for the styling of the second half of a relationship nor for the presence or absence of a crowsfoot at the source end of the relationship. This should depend on the cardinality of the inverse.
### Discussion
1. One thing that I have found annoying in the past is having to define the inverse of a relationship as a relationship in its own right. This is necessary in the ER modelling code so far in order to specify the cardinality of the inverse. 
2. This has become less necessary in the case of the inverses to composition relationships when the `surface model syntax' is used. This is  because in this case as *en passant* whilst parsing the surface structure missing dependecies are generated with fairly good rule for generating cardinality.
3. Recently in change 14-Nov-2024 I introduced surjective and injective attributes to be used generating diagrams using ERmodel2diagram.xslt. The intention had been to reuse these in ERmodel2flex but this doesn't work because the implementation is in documentation_enrichment and this code doesn't apply to models in the surface syntax. 
4. This leads us to the following idea. Change the surface structure so that 
attributes 'surjective' and 'injective' attributes may be defined for reference relationships, context relationships and  'surjective' can be defined for composition relationships.
5. The break through in thinking, by the way, is just that we can have these two attributes instead of the rather awful 'cardinality_of_inverse' which I had thought of having previously but which seeemed ghastly.
6. Would like to implement default values for these attributes in the v1.6 surface model parser.
The defaults for surjective attribute value for compositions will be designed to dovetail with the existing defaults for the cardinalities of created context relationships. The logic might in fact be moved earlier into compositions and the rippled into the cardinalities of implicitly created context relationships.
7. Would like these defaults to also be implemented for ERmodel2flex. 
8. There is no place at the moment for such logic that is shared between ERmodel2.flex
and all other generators based on v1.6 parser.
9. Two options- change ERmodel2.flex to be be based on deep structure rather than surface structure or start moving logic upto surface structure level. Hmmmm.  
10. Structure of ERmodel2flex - five passes in all.
+ passzero - 300 or so lines in source file ERmodel2flex.xslt -- creates a flex diagram structure of enclosures, routes etc.
+ passone - 70 lines in source file ERmodel.flex_pass_one_module -- derives a derived relationship  abstract : node(2) -> enclosure' derived relationship.
+ recursive_structure_enrichment - 138 lines in file ERmodel.flex_recursive_structure_enrichment -- derives an attribute of enclosures called 'compositionalDepth'.
+ passes one two and three are in source file ERmodel.flex_pass_two.xslt.
+ passtwo - plants x and y placement expressions for certain enclosures and just y values for some other enclosures
+ passthree - plants x and y values for enclosures not falling into pass two
+ passfour - plants a further number of x value placement expression (not sure this needs to be a separate pass)
11. It will not be difficult to move ER2flex  to be called after the v1.6 parser has run.
12. It will not be difficult to split off a core enrichment pass.
including defaults for injhective and surjective and ids of relationships as per pass one of documentation enriichment.
13. Because I can have ERmodel2flex calling the v1.6 parser optionally will be able
to have ERmodel2flex running off either v1.6 surface structure or exiting ERmodels
like all of examplesConceptual. Excellent for unit testing flex diagramming you would think.

### Idea
The idea is that when using the surface model 
1. It is never necessary to define an inverse to a relationship as an explicit other relationship.
2. There is a choice of how to model composition relationships/ context relationship pairs. They can be modelled as compositions or by way of their inverses as context relationships. In either case the injective and surjective attributes can be used to control inverse cardinality. 

### Proposal
1. Change ERmodel2.flex.xslt to optionally call the ERmodelv1.6 parser prior to passzero. 
Change passzero to work off the abstract syntax, i.e. the ERmodel instance, rather than the surface structure. Can retest at this point.[x]
2. Add boolean attributes 'injective' and 'surjective' to the flex diagram model.[x]
3. Implement default values for attributes 'injective' and 'surjective' in
new source file 'ERmodel.implementation_of_defaults_enrichment.module.xslt.[]
4. We need to take care specifying these default values because if an inverse relationship is present in the model then defaults should be derived from the cardinalities of these relationships. 
5. Defaults for reference relationships are 
	+ injective='false' 
	+ surjective='false'
6. Defaults for composition relationship are 
    + surjective='true' only if destination entity type has no other incoming compositions.
7. Defaults for context relationship
	+ injective='false'
	+ surjective='false'.
	XXXXXX THINK ABOUT THIS.  []
8. Change ERmodel2.flex.xslt to call implementation_of_defaults after calling
'ERmodelv1.6.parser.module.xslt' and before passzero. []
9. Implement the appropriate styling of the routes representing relationships in pass zero in accord with these two new attributes(currently no crowsfeet at all on routes representing reference relationships and all shown as non-surjective).[]
10. Note that for hierarchical models it should never be necessary to supply a value for the surjective attribute in the surface model -- the default value should always suffice.
For network models surjectivity will neeed to be specified.[]

### Testing
1 Rebuild all examplesSelected and inspect both the ERmodel2.svg rendering as well as
the flex2svg rendering.[]
2. In the flex of brinton rendering pay atttention to line styling of surjective relationships.[x] 
3. Check that the routes representing five reference relationships in flex rendering of cricket all now have crows feet. [x]
4. In the rendering of relationalMetaModel3 check both renderings of the column relationship of column:primary key entity -> column. This is an injective reference relationship. [x]


### Completion Date 
Complete (sometime before) 22 November 2024
