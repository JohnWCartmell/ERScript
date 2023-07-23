

## 16 July 2023 Part E Updates to ERmodel2.html.xslt.


   Part F Use trailing superscript -1 to contruct default name for inverse of a relationship.



### Rationale 
To improve the meta model and then to replace the meta model currently on www.entitymodelling.org.

### Summary  
1. In the pop up for a compostion relationship offer a "See also" to pop up the info for the destination type of the relationship.
For example in the pullback compostion relationship append: 
```
<p>
See also <button id="E26" class="popout">Pullback</button>
</p>
```
2. Don't offer this in the case of a relationship whose src type equals destination type.

3. In the pop up for an abstract entity type offer a "See also" and a list of  buttons to pop up the info for the concrete subtypes type.

4. Introduce new entity types or rename existing ones if the text strongly suggests new terminology. 

5. Where useful link to the entity modelling book.

### Analysis
1. In the entity modelling book I contrast core from constructed. Consider instead a contrast between primitive and inferred.
Consider primitive (relationship) ::= composition | reference | dependency. 
Consider renaming `constructed_relationship` to be `inferred_relationship`.
Would want to change entity modelling book likewise.   

### Proposal
1. General improvements to  improve the pop ups as follows:

- Program the "See also" for a composition relationship in `ERmodel2.svg.xslt` in template named `infobox`.

- Likewise the "See also" for abstract entity types.

2. Change `complex` to `composite` (surely!).

3. Change `component` to `step`.

3. Change `Relationship` to `directional relationship`.

4. Change `constructed_relationship` to `inferred_relationship`.

5. Change `navigation` to `directional path`.

6. Change `ENTITY_TYPE` to `entity type like`.

### State of Play


### Testing

### Completion Date


