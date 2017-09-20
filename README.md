# ER Script
ER Script is an XML based ER modelling language supporting the notation and concepts described in John cartmell's online book [www.entitymodelling.org](http://www.entitymodelling.org).

ER Script is defined by an XML schema for defining entity models inclusive of their representation as diagrams.

From an ER model represented in XML transforms written in xslt can be used to generate documentation, data definitions and code.

## Documentation

- Diagrams can be generated in **svg**. 
- Diagrams can be generated in postscript and included in pdf documents built using **latex** by making use of the **pstricks** package.

## Data Definition
- Physical schemas in normal form can be generated from logical schemas using John Cartmell's 20xx algorithm.

- XML schemas in the **rng** language can be generated. 

- IDL can be generated for Google's protocol buffers ([developers.google.com/protocol-buffers](https://developers.google.com/protocol-buffers)).

## Code
- **typescript** code can be generated for management of data serialised to and from XML. Functionality includes support for copy and for pullback.
- **python** code can be generated in support of data serialisation to and from XML and Google protocol buffers.
- **xslt** can be generated in support of data transformation and includes support for referential integrity checking of data and enrichment by pullbacks.


