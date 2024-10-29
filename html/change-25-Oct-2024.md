
## 25 October 2024
ER diagram animation -- restructure diagram interaction 
javascript and enable multiple animated svgs on a single html page.  

### Rationale
Tidy up before I implement animation for flex diagrams and new even-odd fill colours for flex diagrams(see change log 27-Oct-2024, 28-Oct_2024). Sorting out the shortcomings paves the way for a more generic scheme for interaction and animation of flex generated diagrams including but not retricted to ER diagrams.

### Summary
Currently javascript precludes multiple svg-objects on a single page of html and therefore tends to preclude interaction on entitymodelling.org.
### Analysis
Following points
1. Currently there is a file 'ersvgdiagramminginteraction.js' which has codesupporting two different interactions
  + A. when enclosures or routes clicked on then a pop up info box displays a text summary of the entity type or relationship.These pop up boxes have close buttons.
  + B. there is also code for 'animating' relationship scopes.
2. The code works fine but has got a not very good implementation because it relies on the cvs classes of the various svg elements and these classes we will change in future and are anyway not generic. Should change this code to rely on generic custom data attributes generated onto the svg elements. 
3. The B. code uses javascript generated into the html file from
a single svg diagram.  This javascript has four constants as follows:
'diagonal_elements', 'diagonal_elements_directions', 'riser_elements' and 'riser_elements_directions'. Put these instead as a json formatted value of an attribute of the root svg element of the svg rendering of the diagram.
4. Modify the way that the pop-up infoboxes are found. Need this because with multiple diagrams on an html page now multiple info boxes can have the same id. To do this need to make assumptions about the html structure.
Most robust way of doing this, is to search relative to grandparent of the containing object element. Hmmm. I cannot navigate 'up' from the root svg element to the containing html. I am going to have to generate something to help wih this.
Simplest way might be to give the root svg element and the containg svg element matching and unique identifiers.
No obvious globally unique identifier available so I will use current date and time.
5. Maybe Change the javascript in file 'ersvgdiagraminteraction.svg' not to rely on classes
in the svg. For this need change the generated svg.

### Proposal
Following points
1. Change ERmodel2.svg.xslt, when it generates into enclosing html an object element with id 'svg-object' 
to generate a custom data attribute named 'data-type' with value 'ERModel'.
2. Change javascript in file 'ersvgdiagraminteraction.js' to find all embedded svg-objects
with the data-type attribute with model ERmodel and to plant callbacks for their content, as appropriate.
Currently the first svg-object is identified and processed:
```
const svgObject = document.getElementById('svg-object');
```
This will change to something like
```
const svgObjects = document.querySelectorAll('object[data-type="ERmodel"]'')
```
Then each svgObject in the list will be processed.

We also need to avoid use of a global svgDoc. Instead the relevant svg document will need to be found.
From a callback we can use
```
const rootSvgForThisClickedElement = getRootSVGElement(elmnt);
```
and it is this root svg element which was previously referenced as a global variable svgDoc.
3. Change ERmodel2.svg.xslt no longer call template plant_javascript_scope_rel_id_arrays.
4. Instead in ERmodel2.svg.xslt into root svg element generate an attribute
      data-methodData="{...}", which represents the four constants as data members in
      JSON format. 
5. Change the javascript in file 'ersvgdiagraminteraction.js'
in function animateRelationship
retrieve the object containing the four constants like so:
```
   const svgRoot = get the root svg element
   const methodDataJSON = svgRoot.dataset.methodData;
   console.log("XXXXX method data ", methodData)

   const methodData = JSON.parse(methodDataJSON);
```
then access, as needed, 
'methodData.diagonal_elements',
'methodData.diagonal_elements_directions',
'methodData.riser_elements',
'methodData.riser_element_directions'.
6. Change ERmodel2.svg.xslt so that the <object/> generated with the diagram svg as content
has is given by
```
<xsl:value-of select="current-dateTime()"/>
```
Change the generated svg so that the root svg element has the same value as an id attribute .
7. Change the javascript in file 'ersvgdiagraminteraction.js' so that the pop-up infoboxes are found
relative to the document (the <object/> containing svg element that is clicked on. 
First need to find the containing <object/> by
   + reading the root svg element, 
   + reading the id of the root svg element,
   + using this id to find the containg object in the overall document.  
Then need to find the required infobox by searching by id relative to the grandparent of the containing object.
8. Also in the javascript need to lose reliance on the global var currentlySelectedRelationshipId and resetArray.
Feeling like I need a table of objects --- one per nested object.

### The Path not taken
1. Change ERmodel2.svg.xslt (where) to generate attribute name data-infoBoxId for rect representing entity types and also for the paths implementing paddings and margins.
This is instead of generating attribute named id.
2. Change ERmodel2.svg.xslt (where) to generate two attributes 
named 'data-infoBoxId' and 'dataRelationshipId' 
for paths representing relationships and relationship hit areas. 
This is instead of generating an attribute named id.
The two attributes have identical contents.
3. Change 'ersvgdiagraminteraction.svg' to use one or other of these attributes,
as appropriate, instead of the id attribute.
4. Take the infoboxmanagement code from  'ersvgdiagraminteraction.js' into 
a separate file
   + svgdiagraminteraction.js

### Testing
1. Rebuild selected examples and exercise.
2. Hand construct an example html with both logical and physical cricket ERmodels and check animation works for both diagrams.
### Completion Date

