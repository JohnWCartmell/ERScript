
## 1 August 2024
Change ER2.diagram to render the name of absolute (the name of the model therefore) in the rail respresenting absolute at the top of a diagram.

### Rationale
This name represents the domain of discourse and the context for the model.
Just been thinking this will be of help
in the document "Introduction to Entity Modelling" that I am writing.

### Analysis
1. Requires change to ER2.diagram.module.xslt. No other source needs to change.
2. Need extend the size of the top rail slightly.
3. While I am at it add constants for the placement of the box representing the rail and its height. 
4. Points of change documented in source code as change of 4/09/2024.


### Testing
1. Rebuild examples being used in the "Introduction to Entity Modelling".
2. For Chen manuafacturing example need add name attribute to absolute.
Add name="Chen '76 Manufacturing Company".

### Completion Date
5 September 2024

