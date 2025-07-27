# README #

Generate a diagram from a logical entity model.

The logical entity model may have embedded enclosures as 'hints'.


Structure of ERmodel2flex - multiple passes
+ parse__conditional - translates the surface model into an instance of the ERmodel metamodel
+ implementation_of_defaults_enrichment
     + in file `ERmodel.implmentation_of_defaults_enrichment.module.xslt`
     +  this implements default values for attributes injective and surjjective
+ passzero 
    +  in source file ERmodel2flex.xslt 
    + creates a flex diagram structure of enclosures, routes etc.
+ passone
    + in source file ERmodel.flex_pass_one_module.xslt
    + derives a derived relationship  abstract : node(2) -> enclosure' derived relationship.
           A node in sense of node(2) ::= source | destination identifies one or other end of
           a route. This identified end is an enclosure. This enclosure may be nested. The outermost
           enclosure in which it is nested. This is what 'abstract' is defined to be.
           Thus node(2) => abstract : enclosure.

+ recursive_structure_enrichment
    + in source file ERmodel.flex_recursive_structure_enrichment.xslt 
    + derives an attribute of enclosures called 'compositionalDepth'.
+ passes one two and three are in source file ERmodel.flex_pass_two.xslt.
+ passtwo    - plants x and y placement expressions for certain enclosures and just y values for some other enclosures
+ passthree  - plants x and y values for enclosures not falling into pass two
+ passfour   - plants a further number of x value placement expression (not sure this needs to be a separate pass)


