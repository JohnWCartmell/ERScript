
## 21 January 2025
Enable the use of possible to completely specify a reference reference relationship
in the surface model withourt specifying an invertse reference relationships.
Complete the change of 16-Nov-2024 for reference relationships by using the injective and surjective 
attributes of the surface model. 

### Exploration
1. From testing the first two changes in below then it seems that the injective attribute controls both
injectivity and surjectivity! Hence need change 3. also.

2. It seems that  the module "ERmodel.implmentation_of_defualts_enrichment.module.xslt" 
is used only in ERmodel2flex. The code doesn't look right to me but it passes the unitTest (see below) so keep as is but move into the folder xslt/flex.  


### Implementation
1. Change ERmodelv1.6.parser.module.xslt to carrt through an injective attribute of a relationship as an injective element.
2. Fix a bug in the render_path template of ERmodel2.diagram.xslt in how
the surjective element is tested for. Change to "selective='true'".
3. Fix bug in documentation_enrichment.module.xslt by which defaults are only generated for injective and surjective if they are BOTH missing. Doh!
4. Likewise fix bugs with default for reference relationships in documentation_enrichment.module.xslt.
5. Move the file 'ERmodel.implmentation_of_defaults_enrichment.xslt' from xslt to xslt/flex.
   Modify file path in ERmodel2.flex, accordingly.

### Testing
1. Test on the grids selected example. Specify each reference relationship to be surjective="false".
2. Test on proteinCodon --- change not to have inverse reference relationship. 
3. Create a new examplesSelected/unitTest example to test
	4 = 2 (injective) x 2 (surjective) combinations of context dependencies
	and same four combinations of reference relationships.
	Check that the flex diagram routes are correct. [y]

### Completion Date 
Completed 22-Jan-2025.

