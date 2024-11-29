This readme describes the thinking behind this EBNF folder. It all comes from a long term project.

The goal is to be able to generate layouts of structured entity relationship diagrams automatically. 

To reach this goal I have designed a general purpose way of describing the layout of diagrams of shapes and connections or routes between shapes and I call this flex diagramming.
There is an entity model that describes flex diagrams. This entity model has a mapping to xml. I write flex diagrams in xml. 
A flex diagram has general instructions on how shapes are to be placed relative to each other and an xslt transform 
interprets these general instructions to generate the diagram in svg or in latex using pstricks.

A transform ERmodel2.flex.xslt generates a flex diagram from an entity model.

The implementation of flex diagrams proceeds by filling out the xml that describes the diagarm with increasing amounts of detailed attributes until the level of physical positioning
and sizing attributes are resoloved (x,y,w and h).  Though this code is written in xslt currently it can be thought of as a recursive definition of a view of the original source of the diagram.
Views can be described as numbers of derived attributes. I have come to believe that the required algorithm can be better described as a series of definitions of derived aattributes
and that the derivations required can be described in either xpath at the xml level or in a more abstract language in terms of the flex diagram meta-model expressed as an ER model.
This brings me to the idea of a langauge very closely related to xpath but operating at the level of entity relationship model. This language I shall call epath.

My project is to write an epath to xpath translator that works alongside of the ERmodel to xml schema converter that is already present in this repository.
The idea is to write this translator in xpath. 

I therefore envisage an ER model that describes the abstract syntax of e-path and a parser that parses e-path into an XML representation of this model.

AS a preliminary step toward this implementation I have modelled the abstract syntax of xpath and written a prser in xpath that parses xml into instances of this abstract xpath syntax represented in xml.

This parser is implemented by interpreting the xpath syntax written in EBNF.

I represent EBNF as xml following the abstract syntax of EBNF. 

This EBNF folder holds this source code:
xx
xx
xx
xx



