# README #

Generate a diagram from a logical entity model.

The logical entity model may have embedded enclosures as 'hints'.

Structure of ERmodel2flex - multiple passes
+ parse__conditional - translates the surface model into an instance of the ERmodel metamodel
+ assembly - to suport file inclusion
+ consolidate - to support consolidation of multiple partial representations of the same entity type 
+ implementation_of_defaults_enrichment
     + in file `ERmodel.implmentation_of_defaults_enrichment.module.xslt`
     +  this implements default values for attributes injective and surjjective
+ ERmodel2flex 
    +  in source file `ERmodel2flex.xslt` 
    + creates a flex diagram structure of enclosures, routes etc.

+ recursive_diagram_prior_enrichment  (source file `new.flex.recursive_enrichment.module.xslt`)
    + implementation of many valued relationship
    ```
        yPositionalPriors : enclosure -> Set Of enclosure
    ```
+ passone
    + in source file `ERmodel.flex_pass_one_module.xslt`
   
    + derives and stores two derived relationships:
```
        entryContainer: source -> enclosure
        exitContainer : destination -> enclosure
```

***Merge the above two passes into a single recursive pass. ????? ***


+ recursive_structure_enrichment
    + in source file `ERmodel.flex_recursive_structure_enrichment.xslt` 
    + derives an attribute of enclosures called `yPositionalDepthShort`
+ recursive_structure_enrichment_pass_two
    + implements what ???
+ passes two, three and four are in source file `ERmodel.flex_pass_two.xslt`.
+ passtwo    - plants x and y placement expressions for certain enclosures and just y values for some other enclosures
+ passthree  - plants x and y values for enclosures not falling into pass two
+ passfour   - plants a further number of x value placement expression (not sure this needs to be a separate pass)


