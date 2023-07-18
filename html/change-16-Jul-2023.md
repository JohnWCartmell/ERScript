

## 16 July 2023

Review and update descriptive text in logical meta model.

### Rationale 
To improve the meta model and then to replace the meta model currently on www.entitymodelling.org.

### Summary  
In the pop up for a compostion relationship offer a see also to pop up the info for the destination type of the relationship.
For example in the pullback compostion relationship append: 
```
<p>
See also <button id="E26" class="popout">Pullback</button>
</p>
```
2. Don't offer this in the case of a relationship whose src type equals destination type.

### Proposal
1. General improvements to text improve the pop ups as follows:

2. Program the see also for a composition relationship in `ERmodel2.svg.xslt` in template named `infobox`.

### State of Play


### Testing

### Completion Date


