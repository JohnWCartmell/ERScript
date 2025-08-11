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

 + tactics_one_recursive (source file `tactics_one_recursive_enrichment.module.xslt`)
      - implementation of 
                    yPositionalPriors : enclosure -> Set Of enclosure
                    entryContainer: source -> enclosure
                    exitContainer : destination -> enclosure  

 + tactics_two_parameterised (source file `tactics_two_parameterised_enrichment.module.xslt`)
        + recursive_structure_enrichment (source ERmodel.flex_recursive_structure_enrichment.xslt) 
            - implements 'yPositionalDepthShort': enclosure -> non-negative number
            THIS IS A DEPTH PARAMETERISED PASS

+  tactics_three_recursive (source file `tactics_three_recusive_enrichment.module.xslt.xslt`) 
            - implements 'yPositionalDepthLong': enclosure -> non-negative number
                         'yPositionalReferencePoint' : enclosure -> enclosure
                             COULD BE PARAMETERISED BT TACTIC Short or Long
+ tactics_four_enrichment (source file 'tactics_4_enrichment.module.xslt')
             - plants x and y directives
    + intrusion              COULD BE PARAMETERISED BY Intrude or not 


