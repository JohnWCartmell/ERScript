
## 2 June 2025
flex diagramming --- support routes having paths consisting of a single line and debug
wl and wr when terminating arms are ramps.

This change is a spur off of the change of 18th May 2025.


### Overview and Rationale
This is a relatively small detail in the overall change of 18th May 2025.


1. Require to be able to have a flex source file in which a route
is specified to be a single possibly sloping line as
```
<path>
   <ramp>
      <startarm/>
      <endarm/>
   </ramp>
</path>
```
2. To achieve this need to separate the creation of startpoints and endpoints from the rules that create terminating arms.

3. I encounter a problem in the rules for calculating wl, wr, ht and hb for enclosures which 
currently take account of labels on routes by using wl and wr of points that carry the labels.
These rules in turn use positioning of labels, which in turn, for ramps, relies on bearing
of the ramp which requires on psositioning or source and destination. 
This positioning relies on wr, wl, ht and hb. Hence circularity.

### Implementation

1. Part of the above circle of rules described above are the rules in source files
+ `diagram...node-+x_lower_boundP.xslt` 
+ `diagram...node-+x_upper_boundP.xslt`
Modify the rules in those files to apply only to ns and ew endarms.
Add new rules which apply to ramps and use approximations by examining widths and heights of labels. These rules will work best when the labels are positioned near the enclosure and do not overlap it (which would be rubbish anyway).

2. From rules in the source files 
+ `diagram...path-+point.endpoint+ewQ.xslt`
+ `diagram...path-+point.startpoint+ewQ.xslt`
create separate rules for terminating points and tetrminating arm in source files

+ `diagram...path(leftPrightP)-+point.endpoint.xslt`
+ `diagram...path(leftPrightP)-+point.startpoint.xslt`
+ `diagram...path-+ewQ.startarm.xslt`
+ `diagram...path-+ewQ.endarm.xslt`

### Testing
Construct new flex example `ramps.xml` with a variety of routes which
are single line ramps.

### Completion Date 
3 June 2025

