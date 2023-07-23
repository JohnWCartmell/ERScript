

## 16 July 2023 Part F Use trailing superscript -1 to contruct default name for inverse of a relationship.


### Rationale

Currently a dependency lacking a name is given the name of the inverse composition postfixed with a hat (^)
symbol. This is a nod in the direction of the latex ^{-1}.  
### Analysis

1. There are  unicode charcaters for superscript minus (-) sign and superscipt 1. 
Therefore we can use these in the names of relationships.
2. Superscript minus (-) sign can be written as an html entity as &#x207B;
3. Superscript minus (1) sign can be written as an html entity as &#x00B9;
3. We may need to mangle names containing these characters when we generate python, typescript etc.

### Proposal
1. Change ERmodelv1.6.parser.module.xslt.
2. Leave the question of code generation until we hit this as a problem downstream sometime.

### Testing
Rebuild the meta model and inspect the logical diagram.

### Completion Date
23 July 2023.


