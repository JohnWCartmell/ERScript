# README #

Generate a diagram from an entity model.

The diagram may have embedded enclosures as 'hints'.

Currently passzero, passone, passtwo, passthree, passfour.

Now need a recursive step to calculate a compositionalDepth. This will be after passone and before current passtwo.
I have started work on it as passtwo though.
It will require keys that are currenlty defined in passtwo.

Currently we have
file ERmodel2.diagram.xslt "passzero" converts entity types and relationships to enclosures and routes
                                      copies through any embedded enclosure information
file passone.xslt          "passone"  annotates routes with "source/abstract" and "destination/abstract"
file passtwo.xslt          defines keys that use "abstract"
                           "passtwo" has some prototype code for "compositionalDepth"
                           "passtwo", "passthree" and "passfour" generates various <x> and <y> for layout of diagram
                           	WHY three different passes here? EH?

