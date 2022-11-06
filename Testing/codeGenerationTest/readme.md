Can test generation of typescript from the window command prompt:
- cd src
- ..\..\..\genHierarchical.bat chromatogram_analysis_record.xml
- cd ..\temp
- ..\..\..\genTypescript.bat chromatogram_analysis_record.hierarchical.xml
- cd ..\typescript
- ..\..\..\thirdparty\npm\node_modules\.bin\tsc.cmd -t es5 chromatogram_analysis_record.hierarchical.ts