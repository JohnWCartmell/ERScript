

## 20 July 2023

Remove the `inverse` reference relationship of a constructed relationship.

Add `inverse` as a subtype of navigational path.

### Rationale 
1. Seems to make much more sense as a way of accessing the inverse of a constructed relationship or of a reference
relationship with an anonymous inverse.

2. Plays into the way I am envisaging the epath language working.

### Summary

### Analysis

### Proposal

### State of play
- Stage 1 remove the inverse relationship.
- Stage 2 add the new `inverse` subtype. Document it as part of the change of 16 July 2023.
- Stage 3 develop a test for the new `inverse` construction.
- Stage 3 support the new `inverse` relationship in xpath enrichment.

### Testing

### Completion Date


