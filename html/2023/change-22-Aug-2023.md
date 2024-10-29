
## 22 August 2023
Review and revise entity modelling book.

### Issues/Rationale/Ideas
0. What is my big message? How can I phrase it so as not to sound pompous?
1. Should I start refering to Structured Entity Modelling? In lots of places I say 'as described here', 'as promoted here' etc maybe I better just come up with the title 'Structured Entity Modelling'.  

2. Shouldn't I start refering to chapters and sections to give some feeling of structure - to help the reader around. I am sure I should because it will help me. 

3. I should get rid of the leading and trailing text and write more cogent summaries of the sections with a chapter.

4. Table of chapters:

| Menu Short Title    | Chapter Title                                                                  |
| --------------------|--------------------------------------------------------------------------------|
| 1. Introduction     | Introduction to Structured Entity Modelling                                    |
| 2. Guide to ER      | Guide to Concept Modelling using Structured Entity-Relationship Models         |
| 3. Examples         | Examples of Structured ER Models                                               |
| 4. Guide to ERA     | Guide to Data Modelling using Structured Entity-Relationship-Attribute Models  |
| 5. Further Examples | Examples of Structured ERA Models                                              |

5. How much of the Theory of Data should I include here? Where even am I up to the the Theory of Data?


### Summary


### Proposal
#### Introduction to Structured Entity Modelling
0. This is the Perspectives Chapter renamed.

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



