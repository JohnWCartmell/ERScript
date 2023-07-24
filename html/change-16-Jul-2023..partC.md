

## 16 July 2023 Part C Produce new scope diagrams.

### Summary  

Produce scope diagrams that can beand embed within the descriptive text.

### Summary
Produce the following diagrams

1. pullback.projection_rel..primary_scope.xml
2. pullback.projection_rel..auxiliary_scope.xml
3. reference.inverse..primary_scope.xml
4. reference.inverse..auxiliary_scope.xml 
5. reference.inverse..primary_scope.xml 
6. composition.inverse..primary_scope.xml
7. component.rel..auxiliary_scope.xml
8. implementationOf.rel..primary_scope.xml

### Implementation
1. Have one source file for each diagram which 
- includes   ERA..logical and, indirectly, ERA..commonDefinitions.
- has presentation specification for required types and relationshps.

2. Add the source files to the metaModel folder.

3. Update build.ps1 in folder metaModel to build each of the 8 diagrams
   using script genSVG.ps1.

### Completion Date


