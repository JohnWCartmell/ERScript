
## 1 August 2024
Upgrade ERmodel2.diagram.module to be OK with an entity type having multiple depedencies of the same name.

### Rationale
This is required for the flexDiagramModel and anyhow is required to complete the implementation of the change 
of [2nd June 2023](../2023/change-2-Jun-2023.md)

### Summary
Change so that the inverse to a composition is found by searching for a dependency by source type, name and destination type.

### Analysis
1. Currently there is a key in ERmodel2.diagram.xslt as follows:
```
    <xsl:key name="DependencyBySrcTypeAndName" 
          match="dependency" 
          use="concat(../name,':',name)"/>
```
This is used from render_path template and from the composition template.

When used in the later it is used to find the inverse as
```
<xsl:variable name="inverse" 
                as="element(dependency)?"
                select="key('DependencyBySrcTypeAndName',
                              concat(type,':',inverse)
                           )[current()/../name = type]
                           "/>
```
but when used in render_path it is used without the condition `[current()/../name = type]`
which apparently was previously there but removed 12/10/2023. 
Why was this condition removed? 

Maybe it should go in on the reference branch also. ***In fact it should*** Added to reference branch
on 18 August 2025 to fix a failure to  build the airlineTravel example. I can't explain why this problem has just showed up. 

### Proposal
Put the condition in on the dependency branch.

### Testing
Build flexDiagramModel. For this I have had to fix the source code which had groups in the logical model
and the descriptive text and didn't build. Much confusion for a while until I sorted out.
Rebuild metaModel. The ER2flex part of the build fails and maybe this never worked?
Mark up the index to say not working.

### Completion Date
2nd August 2024.

