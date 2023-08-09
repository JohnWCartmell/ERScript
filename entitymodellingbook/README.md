# entitymodellingbook
Source of my online book www.entitymodelling.org. 


OLD DESCRIPTION OF BUILD:

The source is represented in xml described by a [document model](https://github.com/JohnWCartmell/documentmodel) and transformed by xslt into html/svg.
The document model is implemented in [ERScript](https://github.com/JohnWCartmell/ERScript). 

To build the website locally create a folder called entitymodelllingbook.
Need a distribution of the document model and this in turn requires a distribution of ERScript.
Then to build from dos command prompt:
>cd entitymodelllingbook
create a folder named as you please but lets say  www.entitymodelling.org
> documentmodeldistribution\commands\set_path_variables.bat
> documentmodeldistribution\commands\quickbuild.bat pathtosourcecodeofentitymodelllingbook\whole.xml www.entitymodelling.org

The above does everything except for buiding of pngs from text. Source code is in entitymodelllingbook\tex_source
There are build scripts in there too. Mostly can just take images from previous deployment.

END OLD DESCRIPTION
                                                
