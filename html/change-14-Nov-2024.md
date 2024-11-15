
## 14 November 2024
ERmodel code restructure  - derive injective and surjective attributes.

### Problem
There is code in various places to derive the cardinality of an inverse to a relationship including the defaults when not specified explicitly. 

### Summary
Restructure existing code to derived two new attributes of a relationship named
'injective' and 'surjective'.

The original intention was to use these derived attributes to style relationships in ERmodel2flex.xslt This was misguided because ERmodel2flex uses the surface structure directly and doesn't use documentation_enrichment.

### Analysis
1. That an inverse needs a crows foot as am end marker is equivalent to 'not(injective)'.
2. That an inverse needs to be drawn with a solid line (rather than dashed) is equivalent to 'surjective'.
3. It would be good to change the reporting xslt ERmodel2html to display injective and surjective columns. 
 This will assist in testing the change.
 Also fix a bug in this report which means cardinality isn't being reported properly.
 This will require invokinging documentation_enrichment. Not currently invoked.
 Needs restructure of definition of keys or, better, recoding not to use keys. 

4. For composition and reference
Crucial comment made 1/08/2024 in ERmodel2.diagram.xslt
where inverse calculated like this:
```
  <xsl:variable name="inverse" 
                as="element()?"
                select="if (inverse) 
                        then (
                             if (self::composition)
                             then key('DependencyBySrcTypeAndName',concat(type,':',inverse))
                                                [current()/../name = type]
                             else key('RelationshipBySrcTypeAndName',concat(type,':',inverse)) 
                             )
                        else ()" />
```
same code defines
```
   <xsl:variable  name="inverseMandatory" as="xs:boolean"
                  select="exists($inverse/cardinality/(ExactlyOne | OneOrMore))"/>
```
which of course is 'surjective'.

5. There are other code fragments in ERmodel2.diagram.xslt some of which are 
sub optimal and some may not implement the above mentioned change.

### Proposal
1. Derive attributes of reference and compsotion relationships in documentation enrichment.
2. Remove the above code from ERmodel2.diagram.module.xslt and replace by use of attributes 'injective' and 'surjective'.

### Testing
1. Test the ERmodel2.diagram restructure by checking the following after rebuilds:
+ Brinton check surjective composition relationship sentence -> verb phrase and many injective composition relationship. 
+ cricket example which has has four non-surjective non-injective relationships.
+ shlaerMellorDeptStudentProfessor0B.xml example which has a single surjective non-injective reference relationship.
+ individualIsMarried which has a partial injective (reflexive) reference relationship.
This actually turned up a problem with an earlier code change -- see change of 15-Nov-2024.
+ recursiveManyMany example  has a many-valued surjective  reference relationship
+ relationalMetaModel4 example which has a partial injective reference relationship.
                                       
### Completion Date 
15 November 2024
