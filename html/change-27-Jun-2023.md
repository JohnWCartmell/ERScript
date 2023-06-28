

## 27 June 2023 - Generalise auxiliary scope constraints to support Zaniola Telephone Model 

### Summary
Develop the support for auxiliary scope constraints so that reference relationships may be completely 
defined by their auxiliary scope constraint by allowing the identifying_relationship to specify the identity relationship
on the destination type of the subject relationship.

Another way of talking about this change would be to say that we are enabling derived relationships to be both specified as identifying and also to be depicted on diagrams.

#### Rationale
This will enable support for Zaniolas telephone number model.

#### Proposal

1. In  entity type `auxiliary_scope_constraint` in `ERA.surface..logical.xml`
change identifying_relationship to be optional so that `auxiliary_scope_constraint` appears as follows
```
reference => auxiliary_scope_constraint*

auxiliary_scope_constraint => 
                       identifying_relationship : string?,
							  equivalent_path : string
```
 
2. Change various (presumably) so that if the identifying_relationship is absent from  auxiliary scope constraint of
a  reference relationship then the reference relationship has no implmenting attributes generated 
and is evaluated simply by evaluating the equivalent path.


#### Testing

