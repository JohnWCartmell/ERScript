echo ("*** building from  source $SOURCE scripts folder")

$SOURCEPOWERSHELLSCRIPTS = $SOURCE + '\scripts\powershell'
$SOURCEBATSCRIPTS = $SOURCE + '\scripts\bat'
$TARGETSCRIPTS = $TARGET + '\scripts'

# CREATE target scripts folder if it doesn't already exist
If(!(test-path -PathType container $TARGETSCRIPTS))
{
      echo ('CREATING target scripts folder ' + $TARGETSCRIPTS)
      New-Item -ItemType Directory -Path $TARGETSCRIPTS
}

# COPY powershell scripts 
attrib -R $TARGETSCRIPTS\*.ps1
copy-item -Path $SOURCEPOWERSHELLSCRIPTS\*.ps1 -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.ps1

# COPY bat scripts 
attrib -R $TARGETSCRIPTS\*.bat
copy-item -Path $SOURCEBATSCRIPTS\*.bat -Destination $TARGETSCRIPTS
attrib +R $TARGETSCRIPTS\*.bat
