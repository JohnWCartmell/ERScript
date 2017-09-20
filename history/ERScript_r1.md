# ERScript_r1

This is a distibution produced as a baseline after moving the source code to GitHub and adding build scripts for creation of distributions on Windows. 

This distribution was built by first creating a folder ERScript_r1 for the distribution with thirdparty software folder present and then by running the following scripts on Windows:

> cd <local repository ERmodelSeriesOne>  
> buildscripts\build.bat <path>ERScript_r1 ERmodel_v1.3  

and then

> cd <path>ERScript_r1\exampleDataModels  
> build.bat  
> cd ..\ERScript_r1\examplesConceptual  
> build.bat  

An installation of latex is required for building of the example pdf documents.

This distribution is tagged in GitHib as both ERScript_r1 and ERmodel_v1.3.

Changes from ERmodel_v1.2 are minor but include:
* Banners stating licence conditions in file headers.
* Rearrangement of folder structure to separate the source code (GitHub) from the built distribution.
* Moving aside two examples that hit bugs in xslt transforms.
* Fixing the generated html for an entity model diagram with pop-up descriptions.
* Cosmetic improvements to data modelling examples.
* Inclusion of Saxon and jing jars in the distribution.
