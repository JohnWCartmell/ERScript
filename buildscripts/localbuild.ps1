Param(
   [Parameter(Mandatory=$False)]
       [string]$filename
)

echo 'localbuild.ps1'

powershell -Command .\build.ps1 -filename $filename
