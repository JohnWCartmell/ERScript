

## 2 June 2023 Part C - Reorganise meta model access library

### Summary
Arrange for configurability of the meta model access library so that the library can be deployed in two ways relative to the current document:
1. the `erMetaModelLib` configuration uses meta model information (i.e. an er model) held in a separate file and linked to from instance data contained in the current document using one of two MetaModel filename attributes.
2. the `erModelInstanceLib` configuration can and is to be used when the current document is an entity model. 


### Rationale
We already use this library of functions in its first configuration. We require the libarry to be extended and also to have it available in its second configuration for use in the implementation of auxiliary scope constraints for which we need to  restructure the code generated as xpath_evaluate for reading of reference relationships. In this second configuration the library will be useful in simplifying most existing coe generators. 

#### Proposal

1. From  file `erMetaModelLib.module.xslt` create a new file `erMetaModelLibConstructor.module.xslt`.

2. `erMetaModelLibConstructor.module.xslt` contains an xslt variable `metaModelLibraryConstructor`
which is of type `function(model as element(er:entity_model)) as map(xs:string, function(*))`
whose value is that of the current `erMetaModelLib` variable of file `erMetaModelLib.module.xslt` rexpressed as a function.

3. Modify file `erMetaModelLib.module.xslt`
- include file `erMetaModelLibConstructor.module.xslt`
- redefine `erMetaModelLib` variable as `$metaModelLibraryConstructor($erMetaModelData)`

4. Create a new file `erModelInstanceLib.module.xslt`
- include file `erMetaModelLibConstructor.module.xslt`
- define `erMetaModelLib` variable as `$metaModelLibraryConstructor(/entity_model)`

#### Testing
##### Regression Test Configuration 1
Build the cricket example and inspect the validation reports.[x]

##### Testing of Configuration 2 
This will take place in part D of this overall change.