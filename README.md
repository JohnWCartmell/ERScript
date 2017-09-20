# ERmodel
An XML based ER modelling language supporting the notation concepts described in John cartmell's online book [link](www.entitymodelling.org).

An XML schema for defining entity models inclusive of their representation as diagrams.

From an ER model represented in XML the following may be generated:

- Diagrams can be generated in **svg** 
- Diagrams can be generated in postscript and included in pdf documents built using **latex** by making use of the **pstricks** package.

- Code can be generated in **typescript** and **python**.
- IDL can be generated for Google's protocol buffers ([link](https://developers.google.com/protocol-buffers))

- Physical schemas in normal form can be generated from logical schemas using John Cartmell's 20xx algorithm.

- XML schemas in the **rng** language can be generated. 
