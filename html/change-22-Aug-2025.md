
## 22 Aug 2025
er2flex diagramming --- improve support for central and right positioning and introduce a new unspecified 
positioning.

### Problems
1. When an enclosure is positioned at the centre or the right of its parent enclosure then if and enclosure is positioned relative to this enclosre then positioning algorithm doesn't terminate.
2. When problem 1 is fixed then when auto layout rules are being used such as the tactic four rules then the resulting x values of for the local positions of enclosures may be  negative. Currently the brinton selected example exhibits this problem and the entity type `verb phrase` half disappears off the left hand side of the diagram.
3. With future tactics the same problem could happen with the y values also. (Suppose we started from a middle entity type
which is selected as complicated and positioned relative to this.)  
### Analysis 
1. Right and central positioning is support by clocal and rlocal coordinates. Problem 1 can be fixed very simply by the introduction of additional rules that define  clocal and rlocal for enclosures that are positioned relative to 
enclosures with clocal and rlocal.

2. Problem 2 can be fixed by introducing a new deferred coordinate system dlocal which works similarly to clocal but 
without the symetry.

### Oddity
If we did address problem 2 in this way it would mean that position at left didnt necessarily mean that. Likewise position at right. It is almost as if position at left or position at right just means position freely!!

### Implementation
1. Implement two new rules, one  for clocal, one for rlocal,  into 'diagramming.addressing.xP.wP.smarts.xslt'.

2. Implement rules for dlocal similar to the rules for clocal except for:
+ there is a rule for enclosures to have dlocalLowerBound attribute.
+ the rule for local coordinate calculated from dlocal is 
'local = dlocal + padding - ../dlocalLowerBound' + ../margin.

3. Modify tactic four for the first nested enclosure not having an x value to have '<x><dlocal>0</dlocal></x>'.
Note that any other value would be fine too! 

### Testing 
1. Test the new rules that support positioning relative to left and right positioned enclosures with a new test
`x.nestedboxes_exploration`.
2. Test the new rules for dlocal by copying the test `x.nestedboxes_exploration` to file `x.deferredPositioning`
and changing entity types specified at left and at right to have unspecified positions.
  + Change `Right(OfParent)` to `DeferredOne` and `Left(OfParent)` to `DeferredTwo`.
  + Check that the ZERO enclosure exactly contains 
  all its nested enclosures (which it doesn't in the `x.nestedboxes_exploration` example )
3. Rebuild all selected examples. Check that all of the Brinton types are now visible on the diagram.

### Completion Date 
New clocal rule 14 August 2025
new rlocal rule 23 August 2025.
Completed with support for dlocal 25 August 2025.


