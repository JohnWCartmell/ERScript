

## 9 July 2023

Remove the concept of `inherited` (it appears  in the context of `identifying`) from the meta model.

### Summary
This concept isn't used. CHECK.

### Analysis
1. The only apparent use is in 
`newERmodel2.xpath_enrichment.module.xslt` where it is used to determine the generated code. 
2. But
- no examples have `inherited` in the source code
- no xslt code exists that creates `<inherited>`
### Proposal
1. Remove entity type `inherited` from `ERA..logical.xslt`.
2. Replace leg of code in `newERmodel2.xpath_enrichment.module.xslt` that is reached when `identifying/inherited` and replace by a termination and a message that references this change note. 

### Testing

### Completion Date


