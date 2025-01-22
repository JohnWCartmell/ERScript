
## 26 October 2024
Flex diagramming -- Rationalise interaction javascript and supporting svg attributes.   

### Rationale
Tidy up javascript before I tidy up css ( change 27-Oct-2024) and implement new even-odd fill colours (change 27-Oct-2024).

### Summary
The idea is that 
   + javascript should not depend on styling of individual svg elements, because
   + need to have generic interaction for flex diagrams as well as possibility of particular method interactions,
   + multiple svg objects on a single html page.

### Analysis
1. Currently there is a file 'flexsvgdiagramminginteraction.js' which has code allegedly supporting two different interactions
   + A. when enclosures or routes clicked on then a pop up info box displays the source code of that enclosure or route.
      These pop up boxes have close buttons.
   + B. there is also code for 'animating' relationship scopes but this doesn't work.
2. This js file is in source within the methods/era/js folder.
3. The A. code works fine but has got a not very good implementation because it relies on the cvs classes of the various svg elements and these classes we will change in future and are anyway not generic. Should change this code to rely on generic custom data attributes generated onto the svg elements. 
4. This A code made generic to flex diagrams whould be in a different source file which is at the flex css level not the method era css level.
5. The B. code is era specific and so should be in a separate method specific file.
Do not support relationship scope animation in this change but make sure the code we write can be extendced to support it and 
other method specific actions.
6. Because I want multiple svg diagrams in a single web page need to remove use of global varibales as I have done in the ERmodel case in change 25 Oct 2024.
7. Because it is a bit confusing having two actions selection and pop up infor, because may want to plant ERSCript as well
as flex source have a context menu on svg elements instead of just right click.
8. Currently context menu can just have options "Select" and "View Flex Source" and in future can have
"View ER Script" and "Animate ...", Tooltip 'Animate Relationship Scope'.

### Proposal
1. Similar to change of 25 Oct 2024, change diagram2.svg.xslt (where)
   +  to generate attribute named data-infoBoxId for routes and route hit areas. This is instead of generating attribute named id.
   + to generate attribute name data-infoBoxId for rect representing enclosures and also for their padding and margin paths. This is instead of generating attribute named id.
   + plant id attribute both on object conatining svg and on root svg element so that can navigate up
   from root svg element to containing svg element.
2. Change diagram2.svg.xslt to plant a context menu in the surround html.
3. Change the flexDiagram model to have a method attribute of diagram.
4. Change er2flex.xslt to populate the method attribute of the generated flex diagram with method 'era'.
5. Implement new flexDiagamInteraction.js.
   + support context menu,
   + do not use style (classes) to find svg elements.

### Testing
1. Remove the buildarea js folder and rebuild it.
2. Test by rebuilding and exercising the orthogonals route example and cricket example.
3. Test bundled and unbundled.   

### Completion Date
Completed bar the Select menu option 31 October 2024.
Need make progress on change 26-Oct-2024 before completeing this one. 
