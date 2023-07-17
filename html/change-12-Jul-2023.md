

## 12 July 2023

Produce a  model of a pure logical ERA meta model.

### Rationale 
To replace the meta model currently on www.entitymodelling.org.

### Summary
1. The model `ERA..logical` is a logical model of a physical ERA model. We know that it describes physical models because
some attributes are described as being implementations of reference relationships. I would like a version which describes logical models. The only difference is that the logical that describes logical doesn't have an `implementationOf` entity type.
2. The model `ERA..logical` describes some detauils which are relevant to code generation rather than being about entity modlling in the abstract. I would like a cut down pure version that doesn't have directives related to implemention.  The cut down pure version will not have the following entity types
- `xml`,
- `xmlStyle(1)` and `xmlStyle(2)`,
- `initialiser` and `copy`,
- `transient`
nor, arguably,
- `deprecated`.

### Analysis
1. The solution will need to deal with the fact that in the pure model the entity type `pullback` isn't a sub type but in
the current version which we want to keep `pullback` inherits from `initialiser` which also has `copy` as a subtype.
2. The proposal deals with this whilst reusing the definitions of the entity types in the pure model with the exception of the `pullback` entity type. That means we have the pure reuseable core definitions and the pullback extension definition.  


### Proposal
1. We require two versions of the current `ERA..logical` 
	- retain the name `ERA..logical` for the logical model of pure entity modelling
	- use the name `ERScript..logical` for the logical model of current version of ERScript 
2. Both the above files will include a file of common definitions which we can call `ERA.commonDefinitions`
3. We require two versions of the current `ERA.diagram`. Call them
	- `ERA.diagram`
	- `ERScript.diagram`
3. We require two versions of the current `ERA..physical.diagram`. Call them
	- `ERA..physical.diagram`
	- `ERScript..physical.diagram`
4. We require two versions of the current `ERA.presentation` Call them
	- `ERA.presentation` 
	- `ERScript.presentation` 
5. Both these presentation files will include a file of common presentation detail which we will call `ERA..commonPresentation`.
4. We require two versions of the current `ERA.descriptive_text` Call them
	- `ERA..descriptive_text` 
	- `ERScript..descriptive_text` 
5. Both these descriptive_text files will include a file of common descriptive_text which we will call `ERA..commonDescriptive_text`.
6. Change index.html to give access to ERScript model as well as the pure meta model. 
7. Change the `ERmodelv1.6.parser.module.xslt` where it populates meta model attribute to plant `ERScript..physical.xml` instead of `ERA..physical`.

8. Attributes `xpath_evaluate`, `xpath`, `module_name`, `js`, `physical_prefix` should appear in ERScript not in the pure entity modelling of `ERA`.

9. Watch out for ERA..derived attributes!!


### State of Play

I have split out ERScript..commonDefinitions and ERScript..commonPresentation. 

ERScript..presentation and ERScript..commonPresentation have some problems and therefore the build will fail to produce a logical diagram at the moment.

Tried building from debugging so far seems that there is a path without a midpoint. 
NEXT STEP try coding tests for scope and relid where not output if no midpoint. OR change build not to output scopes and relids and see if can get a diagram to see whAT HAPPENING.


### Testing
1. Build both meta models and examine diagrams and validation reports.

### Completion Date



