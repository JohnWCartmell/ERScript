

## 2 June 2023
Refinement to how relationships identified in the meta model `ERA..logical.xml` and associated code changes.

### Summary
1. Specify the relationship `type:RELATIONSHIP -> entity_type` to be identifying.
### Starting Point

### Reason

#### Analysis

#### Proposal

#### Testing
Regression testing should be carried out. All relevant outputs generated before and after the change.  
1. Test on meta model but note that the specialised hierarchical style used (-hs) doesn't test the internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.
2. Test on `chromatogramAnalysisRecord` example because it an -h style hierarchical example. 
This is  to test  internal use of `typeOfOrigin` in `ERModel2.physical_enrichment.module.xslt`.
3. Test on relationalMetaModel3 use of physical enrichment with style 'r' (relational).
4. Test by regression testing typescript generated from ERmodel2.ts for the`chromatogramAnalysisRecord` example.  
In powershell use `diff (cat filename) (cat filenameofregressioncopy)`.

