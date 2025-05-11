
## 05 May 2025
Flex diagramming --- Fix bugs in generated svg

### Description
There are svg:line elements and svg:paths generated into svg which have missing x and or y values resulting in errors being shown in the console when the page is loaded.

### Analysis
These are caused by unconditional generation of points into svgs. Points that are part of implmention of cardinals `<ns>` and `<ew>` and `<ramp>` cannot be rendered. 
+ There is a `<point>` within each `<ns>` element and this is present only to hold an x value and does not have an y value. 
+  There is a `<point>` within each `<ew>` element and this is  present only to hold an y value and has no x value present. 
+ There is a `<point>` within each `<ramp>` and this has neither x nor y and may not actually serve any purpose.

The lines in error are the attempted renderings of  points as crosses.
The paths in error  are the attempted renderings of the boundaries of points. 

Additional possible confusion: Points are rendered by lines with style "point". 
There is no such style in the er method. I won't address this inconsistency right now.

### Implementation
Change not to render points and bounderies of points that are children of `<ns>`, `<ew>` or `<ramp>`.
Change 
+ flexDiagramming/xslt/diagram.render.module.xslt 
+ flexDiagramming/xslt/diagram2.svg.xslt.

Add some tests so that messages will be output during rendering in future if points are incompletely specified.

### Testing

Build and check examplesER2flex/simpleRecursion..logical.xml.

### Completion Date 
06 May 2025

