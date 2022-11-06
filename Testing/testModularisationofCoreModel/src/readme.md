6th November 2022

From a dos command prompt

cd to this folder.

Test either 
1. using stand-alone assemble script
    ..\..\..\ERScript_r5\scripts\assemble.bat grids.core.xml

which places assembled xml in file ..\temp\grids.core.assembles.xml
or
2. by generating a physical model by
    ..\..\..\ERScript_r5\genHierarchical.bat grids.core.xml
which will build a hierarchical physical model in file ..\temp\grids.core.hierarchical.xml.
Currently, 6 Novemeber 2022, this script will also try building an svg but this will fail. 

