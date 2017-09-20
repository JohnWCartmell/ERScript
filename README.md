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

## Acknowledgements

The author, John Cartmell, was employed by Cyprotex Discovery Ltd. 2001-2017 where version 1.2 of this software was written by him, with assistance from David Roe and Bob Appleyard, jointly, on the python generator, and from Bob Appleyard on the implementation of the support for Typescript and for Google Protocol buffers and who, significantly, championed both these technologies in software development projects within Cyprotex. In July 2017 Cyprotex elected to support this software being released as open source software. 

Many of the ideas in this software were conceived of when working at Ipsys Software on Computer Aided software Engineering (CASE) tools  and particularly on the Toolbuilder Meta-CASE tool with Albert Alderson, Tony Elliott, Ferrie Smit and Brian Passingham.

Code generators inclusive of the diagram generators have been written in xslt 2.0 and we gratefully acknowledge use of the Saxon xslt processor; Saxon-HE (home edition) is an open source product available under the Mozilla Public License version 2.0 ( www.saxon.sourceforge.net).

Schema checking for both models and instances is carried out using the jing RELAX NG validator from the Thai Open Software Centre (www.thaiopensource.com/relaxng/jing.html). 


