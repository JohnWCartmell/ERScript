
## 07 May 2025
flex diagramming --- fix a weakness in the layout produced by ERmodel2flex.xslt
### Discussion
Some entity types are outermost entity types with incoming top down composition relationships.
In flex terms they are outermost enclosures with incoming top down routes. 

We can define a meta-relationship which returns a set of top down routes to an enclosure or into any of its nested enclosures. We can define this meta relationship to be defined only for outermost enclosures.
This relationship is defined as an xslt key like this:
```
    <!-- enclosure => set of route ... routes down to or into an outermost enclosure -->
   <xsl:key name="IncomingTopdownRoute"  match="route[top_down]" use="destination/abstract"/> 
```
(File ERmodel.flex_pass_one_module.xslt)

Outermost enclosures having incoming top down routes have a y position defined in ERmodel.flex_pass_two.module.xslt by the following rule:
```
   <xsl:template match="enclosure[key('IncomingTopdownRoute',id)]
                        [not(y)]" 
                   mode="passtwo">
      <xsl:copy>
         <xsl:apply-templates mode="passtwo"/>
         <y> 
            <passtwoA/>
            <place>
               <top/>
            </place>
            <at>
               <bottom/>
               <of>
                  <xsl:value-of select="key('OutermostEnclosuresFromWhichIncomingTopDownRoute',id)
                                            [compositionalDepth+1=current()/compositionalDepth]
                                           [1]/id"/>
               </of>
            </at>
            <delta>1</delta>   <!-- make room for incoming top down route -->
         </y>
      </xsl:copy>
   </xsl:template>
```

The subject of this change note is the x position to be used for such enclosures.

For some of these enclosures an x position is defined in ERmodel.flex_pass_two.module.xslt by the following rule:

```
   <xsl:template match="enclosure
                        [not(x)]
                        [key('IncomingTopdownRoute',id)]
                        [not(preceding::enclosure
                           [(key('IncomingTopdownRoute',id)[1]/source/abstract)
                           =
                           (key('IncomingTopdownRoute',current()/id)[1]/source/abstract)
                         ]
                       )
                     ]
                     " 
                   mode="passfour">
      <xsl:copy>
         <xsl:apply-templates mode="passfour"/>
         <x> 
            <xsl:attribute name="rule" select="'passfour'"/>
            <passfourA/>
            <place>
               <left/>
            </place>
            <at>
               <left/>
               <of>
                  <xsl:value-of select="key('IncomingTopdownRoute',id)[1]/source/abstract"/>
               </of>
            </at>
         </x>
      </xsl:copy>
   </xsl:template>
```
This rule fires when there is no preceding enclosure with an incoming topdown route from the same abstract source.

This change note more specifically is what should the x position be when there is such a preceding
enclosure i.e. there are none with an incoming top down route with the same abstract source. 

Currently there is no rule to specify this x position in er2flex. Therefore the general rules (the smarts) of recursive diagram enrichment determine x. In this situation x is determined as
```
         <x>
            <place>
               <left/>
            </place>
            <at>
               <right/>
               <predecessor/>
            </at>
         </x>
```
This is the behaviour currently.


### Problem Description Part One

With this current behaviour,  the ordering of the entity types in the logical ER model influences the layout because with different orderings different predecessors are picked up. This was noticed in the brinton example where this caused entity type NP|AP|PP to have y specified to be  below sentence which is good but x to the right of its predecessor which is verb_group which is child of verb phrase which is also below sentence. The result was that NP|AP|PP was laid out over half of verb_phrase which it should have been to the right of.  

Following this change many examples actually look worse --- only some look better. 
But the change is worthwhile because it is more explicit and as such better starting point for future developments. The weakness is because it doesn't ensure compostional children do not overlap. This needs to be dealt with separately.

### Part One Change
The x rule we require is one that will fire in circumstances that the current rule `<passtwoA/>` fires
but that rule ` <passfourA/>` does not fire. In this situation we want to position our
enclosure NOT to the right of the predecessor (the current behaviour) but to the right of that preceding enclosure that we have found to have an incoming route from the same abstract source.

The rule we require is apparently this:
```
   <xsl:template match="enclosure
                        [not(x)]
                        [key('IncomingTopdownRoute',id)]
                        [not(preceding::enclosure
                           [(key('IncomingTopdownRoute',id)[1]/source/abstract)
                           =
                           (key('IncomingTopdownRoute',current()/id)[1]/source/abstract)
                         ]
                       )
                     ]
                     " 
                   mode="passfour">
      <xsl:copy>
         <xsl:apply-templates mode="passfour"/>
         <x> 
            <xsl:attribute name="rule" select="'passfour'"/>
            <passfourB/>
            <place>
               <left/>
            </place>
            <at>
               <left/>
               <of>
                  <xsl:value-of select="key('IncomingTopdownRoute',id)[1]/source/abstract"/>
               </of>
            </at>
         </x>
      </xsl:copy>
   </xsl:template>
```

We have to be careful though because an outer level enclosure may have recursive top down relationships. We need to guard against these. The rule will need exclude these incoming top down routes. 
The easiest thing to do is to change the relationship to be 'IncomingNonRecursiveTopdownRoutes'
???????.


Add this rule to ERmodel.flex_pass_two.module.xslt.

### Testing

Test on the examplesER2flex/shieldedDecomposition which has been designed to exhibit the problem.

Test on the examplesER2flex/simpleRecursion  to demonstate that can deal with recusrion at the top level.

### Problem Description PartTwo

The next thing to be aware of is that all the above deals with outermost enclosures. But the layout implemented makes equal sense if the top down structure in question is entirely nested within an enclosure. Part Two
of this change is to adopt the logic so that the whole thing can be taking place within a containing enclosure. First thought is that this isn't going to be a simple matter because the above rules rely heavily on 
the `source/abstract` and `destination/abstract` which are defined as outermost enclosures and which are precalculated.
We are going to want similar with respect to some containing enclosure.
This shortcoming of the above rules is witnessed in examplesSelected/orderEntry.

#### Meta Relationships
Meta-Relationships of interest are

##### exitContainer
```
exitContainer : route -> enclosure?
``` 
From a route, the largest enclosure which contains the source but does not contain the destination. This will be undefined for some recursive relationships. Call this the exit container because we can think of the route exiting this container on its way from the source.
Assume for the moment that this is precalculated.
We could calculate it alongside of source/abstract as source/exitContainer.

In the context of a route/source we need the following xpath to calculate
```
let $source := //enclosure[id = current()/id],
    $dest   := //enclosure[id = current()/../destination/id]
   return $source/ancestor-or-self::enclosure
                     [not(./descendant::enclosure = $dest)
                       and 
                       not(./self::enclosure  = $dest)
                     ][1]/id
```
Use this expression in the precalculation of source/exitContainer.
##### entryContainer
```
entryContainer : route -> enclosure?
```
From a route, the largest enclosure which contains the destination but does not contain the source. This will be undefined for some recursive relationships. Call this the entry container because we can think of the route entering this container.
Assume for the moment that this is precalculated.
We could calculate it alongside of destination/abstract as destination/exitContainer.
##### EnteringTopdownRoute
```
EnteringTopdownRoute : enclosure -> route* 
```
From an enclosure,  routes for which this enclosure is an entry container.  Implement by 
```
   <xsl:key name="EnteringTopdownRoute"  match="route[top_down]" use="destination/entryContainer"/>
```
##### ExitingTopdownRoute
From an enclosure, routes which have this as the exit container.
Implement by

```
<xsl:key name="ExitingTopdownRoute" match="route[top_down]" use="source/exitContainer"/>
```
##### ExitContainersOfEnteringTopdownRoutes
```
ExitContainersOfEnteringTopdownRoutes : enclosure -> enclosure*
```
From an enclosure, enclosures that entering top down routes exit from. 
In otherwords,
```
ExitContainersOfEnteringTopdownRoutes
        ::= EnteringTopDownRoute/ExitContainer
```
Implement by
```
   <xsl:key name="ExitContainersOfEnteringTopdownRoutes"
            match="enclosure"
            use="key('ExitingTopdownRoute',id)/destination/entryContainer"/> 
```
##### ActualIncomingTopdownRoute
```
ActualIncomingTopdownRoute : enclosure -> route* 
```
From an enclosure, those top down routes which have this enclosure as their destination. Implement by
```
    <xsl:key name="ActualIncomingTopdownRoute" match="route[top_down]" use="destination/id"/>
```
##### TerminatingNonLocalIncomingTopdownRoute
```
TerminatingNonLocalIncomingTopdownRoute: enclosure -> route* 
```
From an enclosure, those top down routes which have this enclosure as a destination and which have a source that is neither this destination nor is enclosed in the
parent enclosure of the destination.
Implement by
```
<xsl:key name="TerminatingNonLocalIncomingTopdownRoute" 
       match="route[top_down]
                  [let $destination := key('Enclosure',destination/id),
                       $source := key('Enclosure',source/id)
                   return  $destination treat as element(enclosure)
                              and $source treat  as element(enclosure)
                              and not($source/ancestor-or-self::enclosure = $destination/parent::enclosure)
                  ] 
                  "
                  use="destination/id"/>
```
QUESTION: Do all these routes have destinations which have parent enclosures?

#### Analysis --- Do we still need source/abstract and destination/abstract?
Probably not.


### Summary of Rules

#### Rule x1 (pass two)
Applies to any enclosure which has a preceeding enclosure
and which is neither the entry container of a top down route 
nor has a top down route arriving at it.
For these enclosures 
```
<x> 
   <at>
      <left/>
      <predecessor/>
   </at>
</x>
```
In the absense of rules for y will be generated by smarts as
```
<y>
   <place><top/></place>
   <at><bottom/><predecessor/></at>
</y>
```
Big weakness here if predecessor has an outgoing topdown route!!

#### Rule y1 (pass two)
Applies to enclosures which are entryContainers for topdown routes.
For these enclosures, 
```
<y>
   <place><top/></place>
   <at><bottom/><of>exitContainerOfFirstCompositionalParent</of></at>
</y>
```
TBD Might add something about compositional depth in specifying
exitContainerOfFirstCompositionalParent DBT

#### Rules 3A,B,C (pass three)
Apply to any nested enclosure to which rule y1 does nor apply and which is the destination of at least one
top down route whose source is outside of the parent enclosure within
which the enclosure is nested.

##### Rule 3A
Applies if the enclosure is the first enclosure within its parent enclosure and is preceded by a label. For these enclosures, place left of the parent enclosure
underneath the label as so
```
<x> 
   <at><left/><parent/></at>
</x>
<y>
   <place><top/><edge/></place>
   <at><bottom/><predecessor/></at>
</y>
```
NOTE: This rule could be refined so that when the label long compared to x offset of the route the enclosure is offset. 

##### Rule 3B
Applies if the enclosure is the first enclosure within its parent enclosure and is NOT preceded by a label. For these enclosures,
```
<y>
   <place><top/><edge/></place>
   <at><top/><parent/></at>
</y>
```
We test this with a parent which is a group and has no label.
x smarts give:
```
<x>
   <place><left></place>
   <at><left/><parent/></at>
</x>
```

##### Rule 3C
Applies if the enclosure is not the first enclosure within its parent enclosure.
For these enclosures:
```
<y>
   <place><top/><edge/></place>
   <at><top/><predecessor/></at>
</y>
```
Smarts apply and therefore we get
```
<x>
   <place><left></place>
   <at><right/><predecessor/></at>
</x>
```
Rules test shows this y and subsequent x to be suboptimal.
Should be at the top of parent and to the left of previous placement to the parent.
How would we find this??? Maybe just preceding-sibling such that precondition holds.

#### Rule x5 (pass three)
Applies to any nested enclosure which is the first within its containing enclosure, to which rule y1 does nor apply and which is not the destination of a top down route whose source is outside of the containing enclosure. For these enclosures, place left of the parent enclosure
underneath the label as so
```
<x> 
 <at><left/><parent/></at>
</x>
<y>
 <place><top/><edge/></place>
   <at><bottom/><predecessor/>
   </at>
</y>
```

#### Rule x6A and x6B (pass four)
Apply to enclosures which are entry containers for topdown routes.
In particular there is a first-such-route. 
Rule x6A or rule x6B applies depending on whether
there is a preceding enclosure that is the entry container for a top down route with the same exit container as the first-such-route.  

##### Rule x6A
If there is no such preceding enclosure then line up the x cordinate of the enclosure with the exit container of the first-such-route.
```
<x> 
   <place><left/></place>
   <at><left/>
      <of>
         <xsl:value-of select="key('EnteringTopdownRoute',id)[1]/source/exitContainer"/>
      </of>
   </at>
</x>
```
##### Rule x6B
If there is such a preceding enclosure then place the enclosure to the right of the preceding enclosure 
```
<x> 
   <place>
      <left/>
   </place>
   <at>
      <right/>
      <of>
         <xsl:value-of select="preceding::enclosure
                  [key('EnteringTopdownRoute',id)[1]/source/exitContainer
                   =
                   key('EnteringTopdownRoute',current()/id)[1]/source/exitContainer
                  ][1]/id"/>
      </of>
   </at>
</x>
```
### Testing 
1. Test on examplesER2flex/nestedShieldedComposition.
2. Test on examplesSelected/orderEntry.
AS AT 11th May 2025 brinton and complexRecursion examples shows the algorithm to be flawed.

### Completion Date 