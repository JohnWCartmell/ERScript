
## 19January 2024
Fix bug in positioning of entity type names when split across lines.
### Summary
Code uses relationship label separation to move to the right slightly. Not noticed this before!
### Implementation
1. I fixed this bug 4 days ago and am not docuymenting the fix.
2. I changed ERmodel2diagram.xslt by moving some adjustment code that should apply only to relationship labels from
from template 'spitLines' where it applied in all cases to template 'drawText' where it can is conditional on that it is a relationship label being positioned.
3. I added  comments around the fix including  FIX BUG WITH SPLIT ET NAMES 
### Testing
Rebuild the example 'postalAddressISO20022' on which I noticed this.
### Completion Date 
15 January 2024
