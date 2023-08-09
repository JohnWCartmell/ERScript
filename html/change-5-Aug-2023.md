
## 5 August 2023

 . Have a single incremental Sublime consistent build system.

### Rationale
Driven by short term goal of publishing the meta model to the online book www.entitymodelling.org. 
Require changes to document support anyway following changes to ERScript. Putting the three sets of sources together will result in a simpler build process and faster development of material www.entitymodelling.org.

### Summary
Bring the documentModel and the entitymodellingbook sources which are currently separate GitHub repositiories into a single ERScript repository.
Reorganize the Build Area so that a web site rooted at the Buid Area can contain both the ERScript web pages and the entity book local build.
Have a single build which is incremental and fits into sublime text (Ctrl-B).

### Analysis
1. Diagrams and html files need reach common css and js. svg file as generated in ERSCript and viewed in web pages there before being copied over into the entity modelling book and viewed in web pages there. The css files and js files cannot be located in a place where they can be consistently accessed. The only solution is to access through absolute paths and to make sure that these paths are satisfied by 
correct versions of css and js when loaded online into www.entitymodelling.org.
2. The structure of the generated svg was changed  since the images that are currently in the online book were created. The generated svg no longer contains its own style definitions but links to these elsewhere. Also svg definitions that are required are expected to be in the containing html. For this reason svgs that were previously embeded as `<img>` elements are now embedded as `objects`. 
The driver for this change was the desire to get the svg into the dom so that the diagrams could be animated in javscript.
This means that svg definitions need to be created by document supports `doc2html` transform.
3. Example diagrams for the book are contained in ERScript. Currently they are built into ERScript folders and then copied in the build of the onlinebook.
In the book, svg files are stored in a single `svg` folder. 
We can improve by having a single build that places the svg files directly in this book svg subfolder and puts html files that wrap
these diagrams into different folder (examplesConceptual and examplesdataModels). These folders for html will be outside of the online book but link to 
(include) svg files within the book area. 
4. Have the following new subfolders in the structure for the built ERScript:
ERScript
	- css
	- js
	- www.entitymodelling.org
	- documentModel
	- examplesConceptual(contains html only)
	- exampleDataModels(contains html only)

### Proposal

1. Create two new folders in ERSCript one called `documentSupport` containing xslt, scripts and latex and one named `documentModel` containing the entity model describing documents. 
2. Create a new entitymodellingbook folder within ERScript.
3. Write build scripts in the sublime text style for examplesConceptual and ExampleDataModels. Create a new `buildLegacySVG.ps1` script to support the legacy style (that constrasts with v1.6 style).

4. Fix bugs that arise building these examples or work around them (bugs  appeared after various recent changes that were not regression tested for these examples).
5. Use the newly incoporated Document Support to build a local copy of the entity modelling book.
6. Test by cd to the BuildArea and start a web server (`http-server` command).
- Navigate around ERScript pages.
- Navigate around the local copy of the www.entitymodelling.org pages.
7. Fix generators as necessary.

8. Change document2html to use absolute paths `/css` and `/js` for location of runtime css and javascript files. Rationale: See Analysis 1 above (need reach via root of www.entitymodelling.org when live but root which is BuilsArea when testing).
9. Change ERmodel2svg to use absolute paths `/css` and `/js` for location of runtime css and javascript files. Same reason.
10. Change build scripts to copy css and js into like named foldes in ERSCript 
- ERScript/css 					[x]
- ERScript/javascript			[x]
- ERScript/documentSupport/css  [x]
- ERScript/documentSupport/js  	[x]

11. There are two copies of erstyle.cs one in `ERSCript/css` one in `documentSupport/css` but
which one do I want?
- the one that is online seems is exactly the one  in documentSupport therfore use this one.
- the one in ERModelSeries1/css has the following note:
```
/* Styles used on www.entitymodelling.org */
/* 13 Nov 2022 Styles bigouter, bigbody, bigsvg, inforolist, inforlevel1...inforlevel5, infotextbox, metatype, closecontainer 
and close moved into ersvgdiagramwrapper.css */
```
Rename this one `erstyles.css.forreasonunknown`. [x]

12. Keep the following builds as they are but add an additional step that copies html and svg into www.entitymodelling.org:
- Brinton example. 
- metaModel. 
- Cricket example. 

13. Change the following so that generated html expects css and js to be found on absolute paths
`/css` and `/js`
- documentSupport\xslt\document2html [x]


### Testing





### Completion Date
Testing completed 12 July 2023


