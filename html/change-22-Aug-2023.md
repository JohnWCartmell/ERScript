
## 22 August 2023
Review and revise entity modelling book.

### Rationale


### Summary


### Proposal
#### Perspective

1. Restructure.
- consider merging first three subsections of perspective i.e. `knowledgeframework`, `tangi
blemetaphysics` and `domains of discourse`.
2. Make it clear that Howlers and Violations is about the new concept of a relationship scope.
Add tooltip as part of this.

3. Changes to text sections.
- review and revise `perspective/datamodelling`. 
Can the title be more specific that just "Data Modelling" but need shortness for left hand menu. it would be quite nice to have hover text in left hand menu. Clearly add tooltips to the menu system.

4. Changes to diagrams.
- `equivocalNaming.xml` is very much broken. [x]
- `entityRelationalMetaModel1` is in need of better presentation. Also `RELATIONSHIP` > `Feature`
and `identifier` > `identifying_feature`     [x]

5. Issue - `entityRelationalMetaModel1` is arguably a conceptual model - it has a network structure - it isn't hierarchical. Its caption has it as a logical ER model.

6. Possible issue - when do I say entity model, when ER model, when entity relationship model.

#### Tutorial One - ER
- explanation says this about entities, relationships and attributes but this tutorial explicity isn't about attributes. Need instead highlight that this chapter is ER and later tutorial two is about ERA.
#### Examples One
#### Tutorial Two - ERA
#### Blog
##### Section "ER Meta Models"
1. Change `ERScript/metaModel/build.ps` to use `www.entitymodelling.org/svg` as the docs folder (for all svgs resulting from build.)[]
2. Change `ERScript/index.html` to pick the meta model digrams from from here.                   []
3. Add the meta model diagram ERA..diagram.html to the ER Meta Models section of Blog.           []
4. Review possibilities of othe variant meta models.                                             []

### Testing
From within Sublime Text, build local copy of www.entitymodelling.org nested within build of ERScript. 
Fully review local copy. Make simple change to wording as suits.  Rebuild. Review. 

### Completion Date



