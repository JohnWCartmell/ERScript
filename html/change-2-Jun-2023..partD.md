

## 2 June 2023 Part D - Update reference relationship xpath_evaluate to include evaluation of on or more auxiliary scope constraints

### Summary
In file `erModel2xpath-enrichment.module.xslt` restructure what is generated in 'xpath_evaluate' for the evaluation of reference relationships.

### Analysis
1. Let `r: x -> y` be a reference relationship. We can consider that in general the expression to evaluate the expression is
```
//destination_type[primary_subcondition]
                  [secondary_subcondition]
                  [tertiary_subcondition]
```
1. where, evaluated at an instance `$instance`, the `primary_subcondition` is 
```
$riser is $instance/$diagonal
```
where $riser_evaluate evaluates the riser and $diagonal_evaluate evaluates the diagonal
```
2. the `secondary_subcondition` is of the form
```
pa1 eq $instance/fa1 and ... pan eq $instance/fan
```
where `fa1`,...`fan` are implmenting attributes of the host entity type `x` of `r`  that implementing the relationship `r` and that reference attributes `pa1`,...`pa2` of the destination type of `r`,
```
3. the tertiary_subcondition is a conjunction over subsubconditions, one for each `auxiliary_scope_constraint` of `r`.
The tertiary subsubconditions for a particular `auxiliary_scope_constraint` has to test that
```
ir is $instance/ep
```
where `ir` and  `ep` evaluates the identifying relationship, respectively the `equivalent_path`, specified in the `auxiliary_scope_constraint`. This tertiary_subsubcondition can more efficiently be evaluated as
```
[fb1 eq $instance/erp/b1 and ... fbm eq $instance/ep/bm]
```
where `fb1`,...`fbm` are implementing attributes of the destination entity type of `r`  that implement the `identifying_relationship` relationship and that reference the attributes `b1`,...`bm` of the destination type of both the `identifying_relationship` and the `equivalent_path`.


4. To give the xslt processor the best chance of optimising the evaluation we shall plant the code in a different order and the epath_evaluate for the reference relationship will be planted as:
```
//destination_type[secondary_subcondition] and tertiary_subcondition]
                  [primary_subcondition]
```
The idea is that for all except the trailing primary subcondition the Saxon xslt processor will build a key on the fly.  I can find a general reference to saxon-EE (which I dont use currently) building indexes on the fly in such cases but have memory of reading this elsewhere as well.  If it seemed desirable then at some future time I could build and use an explicit key match="destination_type" use=(pa1,...pan,fb1,...fbm).

### Rationale
- Need to take account of auxiliary scope constraints in the generation of xpath_evaluate for reference relationships.
- An initial implmentation failed because foreign keys where not in the correct order.
- This has suggested a better way of generating the xpath_evaluate code as described here.

### Proposal

xpath_evaluate calculated as

```

let $primarySubcondition := (:$riser is $instance/diagonal:)
         self::reference/riser/xpath_evaluate
         || ' is $instance/'
         self::reference/diagonal/xpath_evaluate
    $secondarySubcondition := 
		let $implementingAttributes := parent::entity_type/attribute[implementationOf/rel eq current()/self::reference/name],
	    in string-join($implementingAttributes ! (implementationOf/destAttr || 'eq $instance/' || name) ,
	                   'and ' 
	                  ),
    $tertiarySubcondition :=
	    let $destination_type := destinationTypeOfRelationship(self::reference),
	        $let $tertiary_clause_constructor
	             := function ($asc as element(auxiliary_scope_constraint)) as xs:string
	                {
	                  	let $implementingAttributes := (: CHECK THE LOGIC OF THE FOLLOWING :)
	                        $destination_type/ancestor-or-self::entity_type/attribute
	                  	                     [implementationOf/rel eq $asc/identifying_relationship],
	                  	in string-join($implementingAttributes ! (self::attribute/name implementationOf/destAttr 
	                  										      || 'eq $instance/'
	                  	                                          ||  $asc/equivalent_path/xpath_evaluate
	                  	                                          || '/' 
	                  	                                          || implementationOf/destAttr
	                  	                                         ) ,
	                                   ' and ' 
	                                   )

	                }
	    in string-join( auxiliary_scope_constraint ! ( . => tertiary_clause_constructor() ) ,
	    	            ' and '
	    	          )
in 
  '//'
  || self::reference/type
  || '['
  || $secondary_implementation
  || if ($secondarySubcondition ne '' and $tertiarySubcondition ne '') then ' and ' else ''
  || $tertiarySubcondition
  || ']['
  || $primarySubcondition 
  || ']'

``` 


#### Testing
1. Regression test by building the examplesSelected and checking each the physical validation report.
- if required use the cricket example with debugSwitch specified in the build.ps1 and inspect the xpath enrichment in file docs/erMetaModelData.xml.
2. Rebuild the metaModel
- inspect the validation report for the phsyical model and see that there are no longer problems following the reference relationship
`identifying_relationship` from `auxiliary_scope_constraint` entities.
- if required use the debugSwitch specified in the build.ps1 and inspect the xpath enrichment in file docs/erMetaModelData.xml.
3. Be really cautious. Rebuild all examplesSelected and check all diagrams and reports.