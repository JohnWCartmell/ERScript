

## 2 June 2023 Specification of auxiliary scope constraints -- Preparation

### Summary
Various changes to `ERmodel2.physical_enrichment.module.xslt` prior
to implmentation of support for auxiliary scope constraints.
- simplifications 
- extension to 'hs' mode
- bug fix

This change is one part of the change  of 2 Hune 2023.

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
6. Move the variable `compound_name_separator` from `ERmodel2.physical_enrichment.module.xslt` 
and replace with two parameters `long_separator` and `short_separator`
 of the transform `ERmodel2.physical.xslt` with a default value of `_`. 
Modify `ERmodel2.physical_enrichment.module.xslt` to use these parameter values 
in place of `compound_name_separator` in the construction of the names of implmenting attributes. 
Use the `long_separator` to separate relationship name and `short_separator` to separate entity type name from attribute name.
Modify the powershell script  `buildExampleSVG.ps1` to have `long_separator` and `short_separator` as  optional  parameters with default of `_` and, of course pass these values through to the 2physical transform.

7. Create a exampleSelected  called `orderEntry` as follows:
```
NAMED := country | town | street;

NAMED => name : string;

country => Seq Of town;

town => Seq Of street;

street => Seq Of house;

house =>  name_or_number : string;

order => order_no : string,
         delivery_address : Ref To house,
         billing_address_if_different : Opt Ref To house;
```

In the build specify the `long_separator` to be `...` and the 
`short_separator` to be the period character `.`.

NOTE: SHORTCOMING that in this example I represent ER attributes as xml elements since there is no support currently for attributes represented as xml attributes in ERmodel2.xpath_enrichment.module.xslt.

#### Testing

1. Build the `ordeerEntry` example.

Check that in the physical model `order` includes implementing attributes
```
delivery_address...name_or_number 
delivery_address...country.name
delivery_address...town.name
delivery_address...street.name
```

2. Rebuild and diff physical models to check that no changes all of the following models
- cricket
- relational meta model 3
- chromatogram_analysis_record
- ERA.surface..logical
- ERA..logical


