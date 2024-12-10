This readme describes the thinking behind this EBNF folder. 

The goal is to be able to generate layouts of structured entity relationship diagrams automatically. 

To reach this goal I have designed a general purpose way of describing
 the layout of diagrams of shapes and connections or routes between shapes and I call this flex diagramming.
Flex diagrams are written in xml.
The structure of this xml is decribed by an  entity model the source code for which is in folder 
`flexDiagramming/flexDiagramModel`.

A flex diagram has general instructions on how shapes are to be placed relative to each other and 
an xslt transform  has been written to interpret these instructions and render the flexDiagram
in svg (transform 'flexDiagramming/xslt/diagram2svg.xslt'). Later a  transform will be written to generate 
latex using the pstricks package (tbd). 


To produce diagrams automatically from entity models 
a transform 'xslt/flex/ERmodel2.flex.xslt' generates a flex diagram from an entity model.


The transform 'diagram2svg.xslt' has been written using a vry particulat coding style which I refer to
as *recursive entrichment*.

The implementation of flex diagrams proceeds by filling out the xml that describes the diagram 
with increasing amounts of detailed attributes until the level of physical positioning
and sizing attributes are resolved (x,y,w and h).  
Though this code is written in xslt currently it can be thought of as a 
recursive definition of a view of the original source of the diagram.
Another way of thinkinjg about views and views of views is by seing them as a layering and an 
accumulation of  derived attributes. 
I have come to believe that the required algorithm can be better described not in xslt directly
but as a series of definitions of derived attributes
and that the derivations required can be described in either xpath at the xml level 
or in a more abstract language in terms of the flex diagram meta-model expressed as an ER model.

This brings me to the idea of a langauge very closely related to xpath but operating at the level of 
an entity relationship model. This language I shall call *epath*.

I have a project, therefore,  is to specify a language epath and to implement an epath to  xpath translator 
that works alongside of the ERmodel to xml schema converter that is already present in this repository
(transform 'xslt/ERmodel2.rng.xslt')
The idea is to write this translator in xslt and xpath and to bootstrap into epath. 

I therefore envisage an ER model that describes the abstract syntax of epath and a parser 
that parses epath into an XML representation of this model.

As a preliminary step toward this implementation 
I have modelled the abstract syntax of xpath (see  'xpathModel/xpath..logical.xml')
and produced a compiler for xpath  which compiles into 
instances of the abstract xpath syntax represented in xml.

The compiler for xpath  is actually an interpreter which 
reads the grammer of xpath at run time before compiling given xpath instances.
The grammar of xpath is described in
files 'xpath-3.1/xpath-3.1.EBNF.lexis.xml' and 'xpath-3.1/xpath-3.1.EBNF.xml' and the mapping into xml
is described in  file 'xpath-3.1/xpath-3.1.EBNF.mapping.xml'

At the moment the grammar and text xpath for compiling is presented in file 'xpath-3.1.text.xml'.
A number of transforms are run (see file 'xpath-3.1/build.ps1') but the crucial
transform is 'xslt/EBNF/EBNF.compile.xslt'. What this does is to interpret both the grammar (of xpath)
and test instances of xpath (wrapped in xml) and to deliver and instance of the xpath model i.e. the abstract syntax of the text cases.  

Say more about EBNF and how parsed???? I feel there ought to be an er model of ebnf somewhere. Is there.




