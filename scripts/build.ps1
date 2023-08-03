$commandFolder=Split-Path $MyInvocation.MyCommand.Path

. ($commandFolder + '\..\buildscripts\setBuildtimePathVariables.ps1')

echo ("*** building from   $SOURCE scripts folder")

$SOURCESCRIPTS = $SOURCE + '\scripts'

echo "."
echo "================================================================= begin bat ==================="
echo "***"
& $SOURCESCRIPTS\bat\build.ps1                # NOTE THAT '&' is the powershell call operator
echo "***"
echo "================================================================= end bat ====================="
echo "."

echo "."
echo "================================================================= begin powershell ==================="
echo "***"
& $SOURCESCRIPTS\powershell\build.ps1  
echo "***"
echo "================================================================= end powershe;; ====================="
echo "."