From this source I built all the pages for my website www.entitymodelling.org on 19 Dec 2022
and copied over to the website as hosted on GoDaddy. I used FileZilla client to copy over the files.

To build the pages I used documentmodel_r3. I previously chnged document model to plant the latest google analytics tag. Previous version of google analytics goes out of operation at the end of the year.

I built the web site by creating a folder www.entitymodelling.org within a folder entitymodellingbook.
I copied in a folder of svg files for the website from a previous build. The build relies on the presence of these svgs. 

From the windows command from folder entitymodellingbook I used the quickbuild command of documentModel as follows:
> ..\documentmodel_r3\commands\quickbuild.bat www.entitymodelling.org ..\..\GitHub\entitymodellingbook\whole.xml  

