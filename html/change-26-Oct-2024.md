
## 26 October 2024
Flex diagramming -- Rationalise interaction/animation javascript/css and supporting svg attributes.   

### Rationale
Tidy up before I implement new even-odd fill colours (see change log 27-Oct-2024).

### Summary
The idea is that need to have generic interaction for flex diagrams and possibly particular method interactions.

### Analysis
1. Currently there is a file 'flexsvgdiagramminginteraction.js' which has code allegedly supporting two different interactions
   + A. when enclosures or routes clicked on then a pop up info box displays the source code of that enclosure or route.
      These pop up boxes have close buttons.
   + B. there is also code for 'animating' relationship scopes but this doesn't work.
2. This js file is in source within the methods/era/js folder.
3. The A. code works fine but has got a not very good implementation because it relies on the cvs classes of the various svg elements and these classes we will change in future and are anyway not generic. Should change this code to rely on generic custom data attributes generated onto the svg elements. 
4. This A code made generic to flex diagrams whould be in a different source file which is at the flex css level not the method era css level.
5. The B. code is era specific and so should be in a separate method specific file. 
6. Along the way in implementing the era method support for flex diagrams I have a design decision to make. Javascript content that I want to have available in the flex diagram for method specific interaction do I 
   + generate the javascript in er2flex into an attribute say 'methodjavascript' of the diagram so that flex2svg can then  generate into the generated html or
   + generate json data in er2flex into an attribute 'methodJSONdata' of the diagram
     so that flex2svg can generate methodData=methodJSONdata or
   + generate json data in er2flex into an attribute 'methodJSONdata' of the diagram
     so that flex2svg can generate the same attribute into the svg diagram, now as an attribute of an svg object, plus global javascript
                                methodData=parseJSON(attribute methodJSONdata)
     however that is written.
7. Option two is better than option one because then the information in the xml being
   in json rather than javascript could if needed by parsed and transformed. Basically data is better then code, right?
8. OPtion three seems more elegant but why would I need it. Hang on though does
it fix a problem that I didn't know that I had. I want multiple svgs on a single web page (on my website for example). For this do I want the script n the html to be constant. If so the third option must be the way to go.
Investigate how current diagrams on my own web site share javascript if at all. 

### Proposal
1. Create a folder flexdiagramming/css.
2. Split the code in flexdiagramminginteraction.js into two files.
   + 'ERScript/js/flexDiagramInteraction.js'
   + 'flexdiagramming/methods/era/eraFlexDiagramInteraction.js
(Aside: Don't get confused -- there is also an ERScript/js/ersvgdiagraminteraction.js'. 
   This file used from current ERScripts diagrams before flex came along.)
3. Change the diagram2.svg.xslt to plant use of these two javascript files. User the method attribute of the diagram to contruct the era name and path. See change of Step One of change 26-Oct-2024 for introdution of method name.
4. Change diagram2.svg.xslt (where) to generate attribute named data-infoBoxId for routes and route hit areas. This is instead of generating attribute named id.
5. Change diagram2.svg.xslt (where) to generate attribute name data-infoBoxId for rect representing enclosures and also for their padding and margin paths. This is instead of generating attribute named id.
6. Change the old generators to follow a pattern that we can follow here in the new generators. 
   + modify the form of the generated script in the generated html so that instead
of having four constants for diagonal and riser relationship ids have a single object
named 'methodData' which has the previous constants as members.
   +  change 'ersvgdiagraminteraction' to use the methodData object.
7. Change the flexDiagram model to have a methodData attribute of diagram.
8. Change er2flex.xslt to populate the methodData attribute of the generated flex diagram
with the json object with the four diagonal and riser elements. 
(Should probably protype this by handediting flex html and javascript?)
9. Take modified 'ersvgdiagraminteraction.js' (see above) as the basis for the new
'eraFlexDiagramInteraction.js'.
10. Change the newly isolated code in svgDiagramInteraction.js to select
relationships according to what criteria?

### Testing
1. Remove the buildarea js folder.
2. Re build the two js folders.
3. Test by rebuilding and exercising the orthogonals route example and cricket example.
4. Test bundled and unbundled.   

### Completion Date

