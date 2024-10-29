
## 25 October 2024
ER diagram animation -- restructure diagram interaction 
javascript and enable multiple animated svgs on a single html page.  

### Rationale
Tidy up before I implement animation for flex diagrams and new even-odd fill colours for flex diagrams(see change log 27-Oct-2024, 28-Oct_2024). Sorting out the shortcomings paves the way for a more generic scheme for interaction and animation of flex generated diagrams including but not retricted to ER diagrams.

### Summary
Currently javascript precludes multiple svg-objects on a single page of html and therefore tends to preclude interaction on entitymodelling.org.

### Analysis
1. Currently there is a file 'ersvgdiagramminginteraction.js' which has codesupporting two different interactions
   + A. when enclosures or routes clicked on then a pop up info box displays a text summary of the entity type or relationship/
      These pop up boxes have close buttons.
   + B. there is also code for 'animating' relationship scopes.
3. The code works fine but has got a not very good implementation because it relies on the cvs classes of the various svg elements and these classes we will change in future and are anyway not generic. Should change this code to rely on generic custom data attributes generated onto the svg elements. 
5. The B. code uses javascript generated into the html file from
a single svg diagram.  This javascript has four constants as follows:
'diagonal_elements', 'diagonal_elements_directions', 'riser_elements' and 'riser_elements_directions'. Put these instead as a json formatted value of an attribute of the root svg element of the svg rendering of the diagram.
6. Change the javascript in file 'ersvgdiagraminteraction.svg' not to rely on classes
in the svg. For this need change the generated svg.
### Proposal
1. Change ERmodel2.svg.xslt no longer call template plant_javascript_scope_rel_id_arrays.
2. Instead in ERmodel2.svg.xslt into root svg element generate an attribute
      data-methodData="{...}", which represents the four constants as data members in
      JSON format. 
3. Change the javascript in file 'ersvgdiagraminteraction.js'
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

4. Change ERmodel2.svg.xslt (where) to generate attribute name data-infoBoxId for rect representing entity types and also for the paths implementing paddings and margins.
This is instead of generating attribute named id.
5. Change ERmodel2.svg.xslt (where) to generate two attributes 
named 'data-infoBoxId' and 'dataRelationshipId' 
for paths representing relationships and relationship hit areas. 
This is instead of generating an attribute named id.
The two attributes have identical contents.
6. Change 'ersvgdiagraminteraction.svg' to use one or other of these attributes,
as appropriate, instead of the id attribute.
7. Take the infoboxmanagement code from  'ersvgdiagraminteraction.js' into 
a separate file
   + svgdiagraminteraction.js

### Testing
   

### Completion Date

