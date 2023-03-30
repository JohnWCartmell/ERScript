# run this from the folder which has the src xml file

Param(
   [Parameter(Position=0,Mandatory=$True)]
       [string]$pathToSourceXMLfile,
   [Parameter(Mandatory=$False)]
       [string]$outputFolder=$((Get-Item $pathToSourceXMLfile).DirectoryName)
)


$commandFolder=Split-Path $MyInvocation.MyCommand.Path

echo ('pathtosourcefile' + $pathToSourceXMLfile)

$filenamebase=(Get-Item $pathToSourceXMLfile).Basename
$filenameExtension=(Get-Item $pathToSourceXMLfile).Extension
$filename=(Get-Item $pathToSourceXMLfile).Name
$srcDirectoryName = (Get-Item $pathToSourceXMLfile).DirectoryName

echo ('outputFolder' + $outputFolder)
If(!(test-path -PathType container $outputFolder))
{
      New-Item -ItemType Directory -Path $outputFolder
}


. ($commandFolder +'\set_path_variables.ps1')

echo $SAXON_JAR


<# In the invocation of java below I have set the stack size to 2megabyte.
     I did this because my xpath3.1 parser seemed to be getting a stack overflow 
     (reported by Saxon as too many nested templates -- but could also be cause by a regexp according to Michael Kay)
     There is something very odd though because if instead of setting this stack size I switch on some debugging by
     putting out a message everytime I enter the "nt" template (EBNF.parse.module.xslt) then I no longer get
     the stack overflow. 
     I am unsure what the stack size is by default -- I suppose I have increased the stack size but I have no way of knowing
     as the command java -XX:+PrintFlagsFinal -version outputs a stackthread size of 0. 
    #>  
java -Xss2m -jar $SAXON_JAR -opt:0 -s:$pathToSourceXMLfile `
                      -xsl:$ERHOME\xslt\EBNF\EBNF.test.xslt `
                       -o:$outputFolder\$filenamebase.parseout.xml
