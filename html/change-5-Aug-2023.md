
## 5 August 2023
 Merge and reorganise sources of document model and entitymodellingbook into ERScript. 
Construct a single incremental Sublime Text consistent build system.

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

14. The build of entitymodellingbook/images should be rewritten in powerscript in the Sublime style as a build.ps1.
- should build a single image if called in the context of a tex file or all images otherwise.
- should copy tex into $ERScript/temp/images
- should use get-childitem to iterate through tex files
- for each file should sequentially call `latex`, `dvisps`, `ps2pdf`, and `convert` as per generated buildAll.bat that is currently used.
- the final step - the convert - should place the constructed png  into `www.entitymodelling.org/images`

15. The fact that we now embedd svgs using `<object>` gives a problem for the brinton example and future large examples where we want a scaled down diagram as a thumbnail. I cannot find a way of scaling these objects. However I can find a way
	if I include the svg inline using w3c-include-html and an svg transform as follows:
```
	<a href="../svg/brintonSimpleSentenceStructure.html" target="_blank">
                           <svg width="$imgwidth" height="$imgheight">
                              <g  w3-include-html="../svg/brintonSimpleSentenceStructure.svg" 
                                  transform="scale(0.25 0.25)"/>
                            </svg>
                         </a>
```
where `$imgWidth` and `$imgHeight` are calculated from the width and the height of the svg image optionally scaled.

Change `document2html.xslt` to generate such a structure and to generate required java scripting.
It is the following source that is being generated:
```
 <figureOfPictureWithNote>
      <pictureName>brintonSimpleSentenceStructure</pictureName>
      <framewidth>6cm</framewidth>
      <width>16cm</width>
      <imgwidth>5cm</imgwidth>
      <imgheight>5cm</imgheight>
      ...
```
Change this source to
```
 <figureOfPictureWithNote>
      <pictureName>brintonSimpleSentenceStructure</pictureName>
      <framewidth>6cm</framewidth>
      <width>16cm</width>
      <imgscale>0.3</imgscale>
      ...
```

Change the document er model accordingly replacing `imgwidth` and `imgheight` by `imgscale`.

- documentERModel.xml [x]
- englishsentence.xml [x]
- document2html.xslt [x]

16. Change the brinton example to build directly into www.entitymodelling.org/svg.
- change buildExampleSVG.ps1 to have svgOutputFolder parameter [x]
- change brinton build.ps to specify svgOutputFolder           [x]
- change index.html to reference new location                  [x]

17. Both `document2html.xslt` and `ERmodel2svg.xslt` generate link to `erdiagramsvgstyles.css`.
Therefore remove the hover styles from the file `erdiagramsvgstyles.css` and move into a new file
`erdiagramsvg_hoverstyles.css` and change `ERmodel2svg.xslt` to additionally link to this new file.

The hover styles are
```

        .eteven:hover{
          fill: #FFFF77;
        }
        .etodd:hover{
          fill: lightgrey
        }
        .relationshiphitarea:hover {
          stroke: yellow ; 
          stroke-opacity:0.5;
        }
        .attrname:hover {
          font-weight:bold;
          font-size: 12px ;
        }
        .idattrname:hover {
          font-weight:bold;
          font-size: 12px ;
        }
```  
18. Address ERROR elements generated during generation of documentERmodel.rng by changing
    `class` attribute of `MajorElement` to be represented by an xml attribute.
    - change documentERModel.xml             [x]
    - change tutorial_part_two.xml           [x]
    - change document2html                   [x]

    Along the way had to debug since use of column style to specify class already broken with bug showing up (at least) in figure loveRelationshipLocal3 on live www.entitymodlling.org.

19. Address ERROR elements generated during generation of documentERmodel.rng by fixing bug
in the handling of xmlRepresentatuion for mandatory attributes in
     - ERmodel2.rng.xslt  [x]

20. Address error messages given during generation of documentERmodel.rng Fix the following test condition in `ERmodel2.rng.xslt` 
```
        <xsl:if test="ancestor-or-self::entity_type/attribute/
                      xmlRepresentation[text()='Anonymous' or child::Anonymous] and
                      count(ancestor-or-self::entity_type/attribute) > 1">
          <xsl:message terminate="no">
            Entity '<xsl:value-of select="name"/>' has more than one attribute
            which is not allowed when an attribute has xmlRepresentation Anonymous 
          </xsl:message>
        </xsl:if>
```
to test that in the presence of an anonymous attributes there must be no more than one attribute with the exception of those represented by xml attributes. Change to:
```
        <xsl:if test="ancestor-or-self::entity_type/attribute/
                      xmlRepresentation[text()='Anonymous' or child::Anonymous] and
                      count(ancestor-or-self::entity_type/attribute[not(xmlRepresentation/Attribute)]) > 1">
          <xsl:message terminate="no">
            Entity '<xsl:value-of select="name"/>' has more than one attribute that isn't represemnted by an xml attribute
            which is not allowed when an attribute has xmlRepresentation Anonymous 
          </xsl:message>
        </xsl:if>
```
     - ERmodel2.rng.xslt  [x]
21. Fix schema errors raised when checking book source in `whole.xml` against docvument model rng.
     - add entity type `block` to the document model as a subtype of `divlike` with optional `width` attribute [x]
     - change one of `class` attribute of MajorElement to be optional [x]
     - change `width` attribute of `hspace` to be represented as an xml attribute [x]
     - likewise `class` attribute of `tablelevel` to be represented as an xml attribute [x]
     - likewise `class` attribute of `col` to be represented as an xml attribute [x]
     - likewise `height` attribute of `vspace` [x]
     - add `width` attribute of `td` represented as an xml attribute [x]
     - add `target` and `onclick` attributes entity type  `a` and represent as  xml attributes [x]
     - fix faulty tutorial two `tr` nesting. [x]
     - remove unnecessary `imgheight` specifications (no longer required).[x]

22. Fix whatever is giving the following warnings and errors
```
WARNING:  No such figure as referenced: 'kinship.individual.maternalgrandfather' (2)     [x]
WARNING:  No such figure as referenced: 'kinship.individual.maternalgrandfathersmother'  [x]
Broken reference to section 'furtherexamples' from section examplesone.englishsentence   [x]
WARNING:  No such figure as referenced: 'loveRelationship2' (2)                          [x]
Broken reference to section '' from section tutorialtwo.referenceattributes              [x]
```
The third of these, at least, is a bug in live www.entitymodelling.org.

23. Fix error in `cssmenustyle.css` by removing references to `icon_plus.png` and `icon_minus.png`.


### Testing
From within Sublime Text, build local copy of www.entitymodelling.org nested within build of ERScript. 
Fully review local copy. Make simple change to wording as suits.  Rebuild. Review. 

### Completion Date
Completed 22 August 2023. Happy Birthday.


