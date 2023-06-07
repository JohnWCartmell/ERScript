

## 2 June 2023 Specification of auxiliary scope constraints -- Preparation

### Summary
Various changes to `ERmodel2.physical_enrichment.module.xslt` prior
to implmentation of support for auxiliary scope constraints.
- simplifications 
- extension to 'hs' mode
- bug fix

This change is the first of three parts for the overall change specified in outline in the change note of 2 Hune 2023.

### Analysis
1. The `ERmodel2.physical_enrichment.module.xslt` code will be modified as part of this overall change but is overly complex.
There are two opportunities for improving it.
- I can use my better understanding of xpath and xslt to improve the code.
- There is additional information in the input put there by  the v1.6 parser which I can take advantage of.
- Note that I therefore assume that the input is in v1.6. Old examples that haven't been ported to v1.6 will  no longer be supported.

2. Also need to fix a bug that I discover as part of implementing  in partB of this change.

3. Extend the `hs` mode so that can be used when multiple foreign keys only one of which is on the nose.

#### Proposal

1. Remove the code in the template `navigationHead` that dtermines whether a dependency is identifying by navigating to the inverse composition. Reason: this code is already implemented in the v1.6 parser. 
2. From the template `navigationHead` remove the check that a relationship named in a navigation exists. Reason: This is a part of instance validation and can be done prior to logical2physical. 
3. From the template `attributes_reqd_to_identify_from_ancestor` remove the `reentry` paramater. Reason: It isnt used.
4. The function `era:et_is_implemented()` when called at an entity type needs to check that the parent entity type is implemented also. Reason: Long standing bug. 
5. Change reinstate attribute so that its name is
```
"if ($style='hs' and not(implementationOf)) then $relname else concat($prefix,name)"
```

#### Testing
1. Rebuild and diff physical models to check that no changes all of the following models
- cricket
- relational meta model 3
- chromatogram_analysis_record
- ERA.surface..logical
- ERA..logical


