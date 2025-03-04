
## 2 October 2024
Upgrades related to display of relids for entity modelling book.
1. Complete implementation of buildExampleSVG.ps1.
2. Improve display of rel ids.
3. Enable rel ids on logical diagrams.
4. Fix missing rel ids in generated tex.

### Rationale
This will be of help
in the document "Introduction to Entity Modelling" that I am writing.

Currently rel ids are not working in the scripts that I am using.
Expecting to use rel ids in the descriptions of commuting diagrams.
Need more flexibility and tighter use of space  -- I am using goodlandsSSADMCarHire as an example.

### Analysis
1. Implementation of buildExampleSVG.ps1 is incomplete --- many switches not passed through to genSVG.ps1.
2. Implementation of genSVG.ps1 is incomplete switches are nor being passed to ERmodel2.tex.xslt.
3. Place rel ids text on top of the centre point of the relationship line.
    * style with light yellow background and border 
    * when space is tight might want to reposition off the line
4. Need the flexibility to decide on rel ids in logical. Currently not show at all on logical 
by design --- programmed that way in ERmodel2.diagram.xslt render_relid template.
   - should be able to determine in presentation whether to display relids or not
   - currently only displayed when used in implementation of attributes
and when relids switch is passed in
        *   at the moment the relids only displayed if used in an implementation
        * this means at moment get reasonable default behaviour for logical,
                          hierarchical and relational models.
   - could also require to be shown conditionally on whether used on scopes
5. With such functionality sometimes I would require multiple presentations --- this is 
   easy enough, for example
    the meta-model shares some presentation between two models ---
    diagrammed presentation begins with

        <include_model filename="ERA..presentation.xml"/>

 6. Would like control over the format of rel ids. Originally I had the format Ri. Subsequently and
 currently I have the format Si,Ri meaning structural and reference. Equally I could have had Di for dependency. I am now wondering whether ri might be better.
    - the one thing putting me off ri is that I want to use r_1/r_2/...r_n in an explanation of paths.
    - what is more important the look of the diagram or the ability to describe in the book?
    - r1(e) looks better than R1(e)? 
 7. Largely by accident whilst prototyping the display of relids in latex (by editing erdiagram.tex in shared macros folder) with a little bit of help from chatgpt (until it started going round in circles) I have come up with quite a decent display that somehow makes the labels look like road numbers --- this will do for now I think.
 8. Speaking of road numbers I have also wonder about having different letters at different levels, think motorways, A roads and B roads. And also numbering hierarchically r1, r11, r12, r13,... r2, r21, r22, r23, etc.
 9. I notice there appears to be gaps in the allocations of numbers to reference relationships. 
 This come about because numbers afre being allocated to the inverses of reference relationships which are of course themselves reference relationships. Not sure if these relids to inverses ever get used.
 It would be good if we could get rid of thes gaps. In a physical model can rely on which references have
 implementations by reference attributes. There can be one-to-one relationships in which cardinality doesn't decide which end id which. There doesnt seem to be any logic in logical2physical that breaks this tie and this might come back to bite us at some point.
 The answer from the relids point of view is to give a reference relationship the same relid as its inverse.


10. Note that at the time relids are being generated then there is no information as to how or which ones will be presented on any subsequent diagram. We cannot expect that the ones shown on the diagram will be nicely numbered R1,R2,R3,.. or whatever. One way around this is to specify relids in the logical model for those that we know we intend to display on the diagram.

### Proposal 
1. Modify buildExampleSVG.ps1 to pass all switches through to genSVG.ps1.
2. Modify ERmodel2.diagram.xslt, template "render_relid" to to position over midpoint by default
        * call ERText and pass coordinates of midpoint,
        * allow repositioning by honouring xAdjustment and yAdjustment in ./diagram/path/id/label.
3. For styling of relid in svg:
   - Modify erdiagramsvgstyles.svg, style relid add filter attribute to fill background of relid text  with light yellow
    and second filter to put border around,
   - Change ERmodel2.svg.xslt to plant the border filter.
4. Modify genSVG.ps1 to pass trace, scopes, relids switches to ERmodel2.tex.xslt as already passed to ERmodel2.svg.xslt.
5.  For styling relid in tex
    * Change erdiagram.tex so that 3 params and passes empty to errelidbody as third param, use rput* and psframebox,
    * careful multiple sources of this file,
    * do this change so that backwards compatible.
6. Dont forget to copy the erdiagram changes into the source of ERScript. 
7. Add more vertical space to selected example goodlandSSADMcarHire so that relids not overly cramped.
8. Change presentation meta model by addition of three new attributes

        diagram => relid_condition : (All | AllHavingImplementations | None),
                   reference_relid_prefix : string,
                   dependency_relid_prefix : string
    - program (the meaning) as follows
         * if there is a condition defined then follow this condition regardless of the relids switch
         * if no condition is defined then follow the relids switch and if set render relids for those relationships  having implementing attributes (as at current logic does). 
         * in otherwords program a default condition of AllHavingImplementations

         * AllInvolvedInScopes means all having a scope or used in a scope.
         * AllHavingImplementations means all those implmented by one of more referential attributes.
    - implement the relid_condition  in template "render_relid"
      of ERmodel2.diagram.module.xslt.
9. Generation of relids, where absent, implement support for reference_relid_prefix and dependency_relid_prefix in  ERmodel2.documentation_enrichment.module.xslt to implement the above when generating relids.
Add logic to give the same id to reference relationships and inverses.
Warning: This means relationship ids will never be identifying. 

### Testing

1. Build goodlandSSADMcarHire example with relids. 
Unit test by specifying all the various different options.

2. Return the example back to default with no conditions specified.

2. Get on writing the book and see how the new look works in practice.

### Completion Date.
8 October 2024



