# ER Script
ER Script is an XML based ER modelling language supporting the notation and concepts described in John Cartmell's online book www.entitymodelling.org.

ER Script is defined by an XML schema for defining entity models inclusive of their representation as diagrams.

From an ER model represented in XML, transforms written in xslt can be used to generate documentation, data definitions and code.

## Documentation

- Diagrams can be generated in **svg**. 
- Diagrams can be generated in postscript and included in pdf documents built using **latex** by making use of the **pstricks** package.

## Data Definition
By use of transform logical2physical.xslt, a hierarchical ER model and a relational ER model  can be generated from a single logical ER model.  This transform implements [John Cartmell's 2016 algorithm](http://www.entitymodelling.org/blog/relationaldatadesign.html). Provided that definitions of relationship scopes are included in the logical model then both the hierarchical and the relational model will be in normal form. 

From a physical hierarchical ER model:
- an  XML schema in the **RELAX NG** format (www.relaxng.org) can be generated. 

- **IDL** can be generated for Google's protocol buffers (www.developers.google.com/protocol-buffers).

## Code
From a physical hierarchical ER model:
- **typescript** (www.wikipedia.org/wiki/TypeScript)  can be generated for management of data serialised to and from XML. Functionality includes support for copy and for pullback.
- **python** code can be generated in support of data serialisation to and from XML and to and from Google protocol buffers.
- **xslt** can be generated in support of data transformation and includes support for both referential integrity checking of data and enrichment by pullbacks.


