
## 23 August 2023
Change document model so that sections have subtitles.
Use subtitles as content of tool tips generated into  menu items.
### Rationale
Chapter and section titles need to be short so that they can be presented in left hand menu system. Having tooltips enables more descriptive titles that can be explored by hovering over left hand menu entries.
This will help the reader including me with grasping the structure.

### Summary

### Proposal
1. Change document model so that `subtitle` relationship has entity type `titles` as source. 
2. Modify `documentERmodelcomplete.xslt` to insert text nodes in section subtitles.
2. Modify `cssmenustyles.css` to support tooltips on menu items.
3. Modify document2html to generate tool tips for menu entries from subtitles.
5. Modify document2html to generate section page heading as title emdash subtitle or such.


### Completion Date



