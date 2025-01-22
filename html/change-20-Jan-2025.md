
## 20 January 2025
Enable the use of context relationships in place of composition relationships in the surface model.

### Summary
Implement the idea of 16-Nov-2024 --- the idea is that when using the surface model 
there is a choice of how to model composition relationships/ context relationship pairs. They can be modelled as compositions,
 or by way of their inverses, as context relationships. 
 In either case the injective and surjective attributes can be used to control inverse cardinality.  The change of 16-Nov-2024 half implemented for ERmodel2flex diagrams --- it  enabled the modelling of compositions fully without definition 
 of their inverse context relationships. These were created on the fly in ERmodel.consolidate.module.xslt.
Now make it possible to model compositions by modelling their inverse context relationships.

### Rationale
This has seemed a good idea for some time but it has become highly desirable now so that along with the change of 21-Jan-2024
it becomes possible to single source examples like theDramaticArts were lots of fragments are to be presented in different ways including by depicting some dependencies as reference relationships i.e. left-to-right instead of top down/bottom up. This is required for the introduction to Entity modelling and the discussion of referencing of entitites and identification schemes.

### Caveats
1. It is still necessary to mention the composition relationship in the presentation file if anything other than the default routing of the relationship is required. This doesn't get in the way of using this feature as envisaged and as mentioned above.  

2. The meta models have pullbacks have pullbacks hanging off compositions. Feels like don't want to change these to hang off dependencies or contexts ... but maybe one day.  Also stye elements sequence transient and copy initialiser hang off compositions.

### Implementation
1. Change ERmodel2.documentation_enrichment.module.xslt to pick up id of a composition from the id of its inverse dependency.
I implemented this on 19th January 2025 but I am now thinking I have got this wrong and that it needs to be in the ERmodelv1.6.parser
xslt.

2. Change ERmodelv1.6.parser.module.xslt to create any absent compositions. 
Logic written in "entity_type" template but need something simiular in "absolute"
3. Note that in ERmodelv1.6.parser.module.xslt lots of code for defaulting dependency names is now duplicated. 
Would it be possible to separate out this code into an initial pass?

### Testing
1. Unit test on examplesSelected/grids remove composition from cardinal to ordinal.

Then test in parallel with change of 21-Jan-2024.
3. Restructure the source of existing diagrams in the theDramaticArts folder in examplesSelected so that relationship ids have a single source.
4. Create identificationScheme diagrams for entities such as role and production which do not already have them.

### Completion Date 

