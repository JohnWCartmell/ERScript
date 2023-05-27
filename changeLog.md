
## 26 April 2023 Part A
Simplify the metaModel in the area of the `implementationOf` entity type.
Currently `implementationOf` in the logical meta model is specified as having four relationships:
```
   	implementationOf => 
		rel:reference_or_dependency 
		destattr:attribute
		typeOfOrigin:entity_type
		attrOfOrigin:attribute
```
These result in four like-named attributes in the physical model.

### Simplification
The meta model `ERA..logical.xml` is overly complicated in that
both `attrOfOrigin` and `typeOfOrigin` are redundant since they can be derived from `rel` and from `desattr`. 
For the first, need recursive definition like so
```
      	attrOfOrigin ::= if not(destattr::attribute/child::implementationOf) 
      	                 then destattr::attribute 
      	                 else destattr::attribute/child::implementationOf/attrOfOrigin::attribute
``` 
then
```	
		typeOfOrigin ::= typeOfOrigin::*/parent::entity_type
```
#### Analysis
Attributes `attrOfOrigin` and `typeOfOrigin` are created during generation of the physical model in `ERModel2.physical_enrichment.module.xslt`.
The attribute `typeOfOrigin` is used internally within this code to use as a prefix when naming certain reinstantiated attributes. In this code there is no need for the second attribute `attrOfOrigin`.

The attribute `typeOfOrigin` is not used anywhere else.

The attribute `attrOfOrigin` is used in `ERmodel2.ts.xslt`.

#### Proposal
1. Remove relationships `attrOfOrigin` and `typeOfOrigin` from `ERA..logical.xml` and remove associated descriptive text and presentation directions. 
2. Remove `attrOfOrigin` from `ERModel2.physical_enrichment.module.xslt`.
3. Change `ERModel2.physical_enrichment.module.xslt` not to externalise `typeOfOrigin`.
4. Change `ERmodel2.ts.xslt` to calculate `attrOfOrigin` rather than read it from its input. 
	* How to do this? Least elaborate way is with recursive template. Do this.

#### Testing
Regression testing should be carried out. Tests should be selected before the change and all relevant outputs generated before and after the change.  
1. Test on meta model but note that the hierarchical style used doesn't test the internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.
2. Test on an -hs style hierarchical example (which?). This is the was to test  internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.
3. Test on use of physical enrichment with style 'r' (relational).
4. Test by generating typescript. Chromatography (CAR) example is the obvious one.  

## 26 April 2023 Part B 
Correct a serious flaw the metaModel in the area of the `implementationOf` entity type.
### Flaw
After completion of the previous change
the  `implementationOf` entity type  in the logical meta model will be specified as having two relationships:
```
   	implementationOf => 
		rel:reference_or_dependency 
		destattr:attribute
```
and these result in two like-named attributes in the physical model because the scope of the `destattr` relationship is specified to be
```
	destattr/parent::entity_type = rel/type
``` 
But this specification is incorrect therefore navigation of the `destattr` using  `erDataLib`'s `readRelationship` will fail.
#### Discussion
In ToolBuilder we would be able to specify the true scope of `destattr` using a scope square. We cannot do this in ERScript currently and it would be a distraction to go off down the route of trying to fix this more far reaching shortcoming in ERScript. We have a perfectly acceptable alternative proposal.
#### Proposal
1. Replace the scope of `destattr` defining it to be of global scope.
2. Generate the physical model and see that an additional foreign key is generated for the entity type that hosts the destination attribute. (Need experiment with this)
3. Modify  `ERModel2.physical_enrichment.module.xslt` to output this additional foreign key.
#### Testing
Rerun tests as in part A of this change and inspect the generated code.

