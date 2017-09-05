@ECHO OFF
echo BUILDSVGLOG %DATE%_%TIME% >buildsvg.log
echo ====================== >>buildsvg.log
FOR %%x IN (*.xml) DO (
  echo %%x
  call runsvg >>buildsvg.log %%x 2>&1  & type buildsvg.log | find "error:"
)