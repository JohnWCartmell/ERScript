

## 8 July 2023

Remove the concept of `projection` from the meta model.

### Summary
Because I wish to publish the meta model I wish it to be as trimmed down as far as possible and to be in normal form. 
For this need to remove the concept of a `projection` as it is derived from
`pullback` and `projection_rel`.

### Analysis
1. Instances of `projection` are created in `ERmodel2.initial_enrichment.xslt`.
2. In the context of a reference relationship the test that triggers flagging it as a `projection` is
```
[key('IncomingCompositionRelationships', ../name)/pullback/projection_rel = name]
```
3. Instances have `xpath_delta_key` and `xpath_inverse_fragment` added to them in `(new)ERmodel2.xpath_enrichment.module.xslt` as intermediates 
that are then usedin constructing the xpath for xpath_resolve_candidate which in turn used within `xpath_iterate`. This, finally, is used to check that 
in an instance the diagram that is specified as a pullback really is a pullback or to construct a default pullback. 
4. Instances are used in `ERmodel2.diagram.module.xslt` to decorate the projection rel.
5. Instances are used in `ERmodel2.ts.xslt` to generate appropriate typescript.
6. In the example `chromatogram_analysis_record` appropriate reference relationships are already in the logical model flagged as projections.
### Proposal
1. To support regression testing add a -xpath switch to generation of the physical model.                                         [x]
2. Remove `projection` from `ERA..logical.xml`                                                                                    [x]
3. Remove creation of `projection` from `ERmodel2.initial_enrichment.xslt`.                                                       [x]
3. Change diagam module to test $projection as `key('IncomingCompositionRelationships', ../name)/pullback/projection_rel = name`  [x]
4. Recode `xpath_enrichment..module` not to require `projection` entity type by recoding `<xpath_resolve_candidate.`              [x]
5. Recode `ERmodel2.ts.xslt` - use the test from 2. above in pace of [projection].                                                [x]

### Testing
1. Regression test the generated xpath by diff testing the physical model generated with the new -xpath swicth.
 One possibility is that I get the grids example working and generating grid instances. 
In this way when in `chromatogram_analysis_record..physical.xml` there is an entity type `interpretation_event`
with a  composition relationship of type `sample_group(3)` which is a pullback. For this pullback 
`xpath_resolve_candidate`  is
```
key('sample_group_3',era:packArray((current()/../session_guid,samplelist_name,group_alpha_code)))
BECOMES after change
key('sample_group_3',era:packArray((current()/../session_guid,samplelist_name,group_alpha_code)))

```
Check that this xpath is not effected by this change. [x]


2. Regression test the generated typescript by diff testing chromatogram_analysis_record.ts. [x]

### Completion Date
Completed 12 July 2023

