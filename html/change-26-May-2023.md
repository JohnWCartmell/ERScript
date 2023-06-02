



## 26 May 2023
Correct the modelling of the `implementationOf` entity type in the metaModel `ERA..logical.xml`.

### Summary
1. Remove the relationship `attrOfOrigin`.
2. Rename the `destattr` relationship to be `destAttr`
3. Replace the relationship `typeOfOrigin` by  relationship  `destAttrHostEt`.
4. Define the scope of the `destAttr` relationship to be
```
	destAttr/parent::entity_type = destAttrHostEt
``` 

### Starting Point
Currently `implementationOf` in the logical meta model is specified as having four relationships:
```
   	implementationOf => 
		rel:reference_or_dependency 
		destattr:attribute
		typeOfOrigin:entity_type
		attrOfOrigin:attribute
```
These result in four like-named attributes in the physical model.

### Reason
1. `attrOfOrigin` is redundant. 
2. Scopes of `destAttr` and `rel` are corrected then the metamodel will not be navigable with erLib.
3. Want to improve and correct the model so that it can be published  eventually.


#### Analysis
Attributes `attrOfOrigin` and `typeOfOrigin` are created during generation of the physical model in `ERModel2.physical_enrichment.module.xslt`.
The attribute `typeOfOrigin` is used internally within this code to use as a prefix when naming certain reinstantiated attributes. In this code there is no need for the second attribute `attrOfOrigin`.

The attributes `typeOfOrigin` and  `attrOfOrigin` are only used in `ERmodel2.ts.xslt`. As far as I can tell `destAttr` can be used in place of `attrOfOrigin` in that the only example we have they have the same content.

The attribute `destattr` is used in `ERmodel2.elaboration_xslt.xslt`, `ERmodel2.physical_enrichment.module.xslt`, `ERmodel2.ts.xslt` and is defined in the metaModel in files `ERA..logical.xml`, `ERA..descriptive_text.xml`, `ERA..presentation.xml`.

#### Proposal
1. Rename attribute `destattr` to be named `destAttr` in `ERA..logical.xml`  and modify associated descriptive text and presentation.
2. Remove relationship `attrOfOrigin`  from `ERA..logical.xml` and remove associated descriptive text and presentation directions. 
3. Rename relationship  `typeOfOrigin`  to be `destAttrHostEt` in `ERA..logical.xml` and modify associated descriptive text and presentation. 
4. Change `ERModel2.physical_enrichment.module.xslt` not to externalise `typeOfOrigin` and `attrOfOrigin` but to externalise
 `destAttrHostEt`. Output `destAttr` in place of `destattr`.
5. Change `ERmodel2.ts.xslt` to use `destAttr` `destAttrHostEt` in place of `destattr`, `attrOfOrigin` and `typeOfOrigin`. 
6. Modify `ERmodel2.elaboration_xslt.xslt` to use `destAttr` in place of `destattr`.

#### Testing
Regression testing should be carried out. All relevant outputs generated before and after the change.  
1. Test on meta model but note that the specialised hierarchical style used (-hs) doesn't test the internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.[x]
2. Test on `chromatogramAnalysisRecord` example because it an -h style hierarchical example. 
This is  to test  internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.[x]
3. Test on relationalMetaModel3 use of physical enrichment with style 'r' (relational).[x]
4. Test by regression testing typescript generated from ERmodel2.ts for the`chromatogramAnalysisRecord` example.  
In powershell use `diff (cat filename) (cat filenameofregressioncopy)`.[x]

#### At first I missed the following error showing up in relationaModel3 example. 
The error shows up as a referential integrity error  in the physical validation report.
Have
```
   <entity_type>
      <name>foreign key entry</name>
      <attribute>
         <name>table_name</name>
         <type>
            <string/>
         </type>
         <identifying/>
         <implementationOf>
            <rel>partof</rel>
            <destAttrHostEt>table</destAttrHostEt>
            <destAttr>table_name</destAttr>
         </implementationOf>
      </attribute>
```
`<destAttrHostEt>table</destAttrHostEt>` should be `<destAttrHostEt>foreign key</destAttrHostEt>`.

Error has now been fixed but suggests a further test required in which identifying attributes cascade along reference relationships.
This *is* tested though because `to_column_name` attribute of entity type `foreign key entry` is such. Inspection shows it to be generated 
with have the following (correct) implementationOf element:
```
<implementationOf>
            <rel>to</rel>
            <destAttr>column_name</destAttr>
            <destAttrHostEt>primary key entry</destAttrHostEt>
         </implementationOf>
```


