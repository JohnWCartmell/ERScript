

## 13 June 2023
Remove the notion of `key` constraint from the meta model and from the code generators. 

### Summary
1. Following the change of 2nd June 2023 and in particular following the introduction of auxiliary scope constraints, 
the notion of a `key` to a reference relationship is redundant since a key constraint is a partiular kind on 
auxiliary scope constraint in which the 
`identifying_relationship` is the `projection_rel` of a pullback and the `equivalent_path` is the `key`.

### Analysis
1. Key constraints are only used from the chromatographAnalsysRecord example
2. Need to modify generators that support key constraints to support auxiliary scope constraints instead. 
3. Change `ERmodel2.ts.xslt` to support auxiliary scope constraints and tremove support dor key constraints.
   The code that needs change is 
   - need generate of `js` fragment for equivalent_paths of auxiliary scope constraints.
   - need generate lookup CHECK of equivalent path in foreign key section of reference relationship in recursive_js_enrichment.
   - need try keep  intermediate xml and thus generated ts the same so as can regression test.
4. Can  remove all other mention of key constraints
   - meta model, surface model
   - ERmodel2.xpath_enrichment..module.xslt
   - ERmodel2.phyiscal_enrichment..module.xslt.

### Proposal
1. Simplify and regression test `ERmodel2.ts.xslt` before continuing. 
   - For improved readability
   change the internally used element `attribute` to be `attribute_pair`. Note that the bit of code that produces a list
   of `attribute_pair`s implementing a reference relationship may be useful as a way of simplifying 
   `xpath_enrichment..module.xslt`.
   - Replace intermediate element `dest` from template match="diagonal|along|key" mode="recursive_js_enrichment"
     and replace by local variable. Rename variable `scope` to be `scopeTopType`. 
   - Similarly, remove intermediate element `dest` from templates match="riser" and match ="riser2" mode="recursive_js_enrichment"
      and replace by local variable 
   - Remove test of existence of element `src` from template match ="component" mode="recursive_js_enrichment"
      (can replace by an initial assertion)

2. Recode js_foreign_key in "reference". Copy and edit the logic of the $tertiary_clause_constructor from xpath_enrichment..module.xslt.
   Then, possibly take the `attribute_pair` logic back again. Possibly think of a better name for `attribuite_pair`.

### Testing
Generate and diff `chromatogram_analysis_record.ts`. The generate typescript should be identical to that generated before the change.



