
** Folder <DISTRIBUTION>/exampleDataModels **

The ER models in the src subfolder are logical models and need  to be 
transformed to physical models using the logical2physical transform 
before they can be used to either describe data or as the basis of code 
generation. 

To build all the examples in a Microsoft Windows environment use the windows command prompt: 
cd to this examplesSelected folder
and then run the script ..\<ERHOME>\scripts\buildAllLogicalandPhysical.bat 

 
Both hierarchical and relational models and associated svg 
diagrams are generated for all models in the src folder. This script uses the 
following scripts which can also be used individually from the src folder:

  <DISTRIBUTION>\<ERHOME>\scripts\genSvg can be used to generate or 
  regenerate a diagram xxxx.svg in the docs subfolder from the ERmodel 
  source xxxx.xml.

  <DISTRIBUTION>\<ERHOME>\scripts\genAllSvg may be used to generate all 
  such diagrams in a single command.

  <DISTRIBUTION>\<ERHOME>\scripts\genHierarchical can be used to generate or 
  regenerate a hierarchical physical data model  xxxx.hierarchical.xml in 
  the temp subfolder from a logial ERmodel source xxxx.xml. 

  <DISTRIBUTION>\<ERHOME>\scripts\genRelational can be used to generate or 
  regenerate a relational physical data model  xxxx.relational.xml in the 
  temp subfolder from a logial ERmodel source xxxx.xml.

  These last two scripts also produce diagrams of the resulting data models 
  in the docs subfolder.

  The script <DISTRIBUTION>\<ERHOME>\scripts\genAllPhysical can be used to 
  generate both physical and relational data models and associated svg 
  diagrams for all models in the src folder. 

 

