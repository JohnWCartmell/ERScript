
## 9 October 2024
Presentation mode 'supressInverseNames' and goodlandSSADMcarHireExample.
1. Introduce a mode of presentation suited to diagrams of paths.
2. Produce path diagrams and candidate commuting diagrams for the goodlandSSADMcarHire example
   which are implmented by presentations of the logical model that is in source file
   'goodlandSSADMcarHire..logical'.

### Rationale
This will be of help producing diagrams
in the document "Introduction to Entity Modelling" that I am writing
and the technique will then be reused for other diagrams.


### Analysis
1. I currently have the following candidate commuting diagrams in the examplesConceptual folder.
    * SSADMCarHireCommuting
    * SSADMCarHireNonCommuting1A
    * SSADMCarHireNonCommuting1B
    * SSADMCarHireNonCommuting1C
    * SSADMCarHireNonCommuting2
2. I wish to create new diagrams which display individual paths. Not sure yet how many. 

3. I can use the existing feature by which individual labels on relationships can be suporessed
     by, for example, 

        <diagram><path><inverse><label><None/></label></inverse></path></diagram>
    I seem to need add this (without the inverse) to the compostion end which is a little annoying but easy to live with.

4.  Need various changes
    * need to supress the absolute.
    * need to supress entity types that don't have a presentation.
    * will need to supress relationships which they or inverse doesn't have diagram/path

### Proposal 
1. move the above sources from examplesConceptual to the goodlandSSADMcarHire folder in examplesSelected
and rename as follows:
    * SSADMCcrHireCommuting..diagram
    * SSADMcarHireNonCommuting1A..diagram
    * SSADMcarHireNonCommuting1B..diagram
    * SSADMcarHireNonCommuting1C..diagram
    * SSADMcarHireNonCommuting2..diagram
2. Modify build.ps1 to build the above.
2. Edit each file 
    * to be presentation only 
    * to include model goodlandSSADMcarHire..logical.xml
    * to supress relationship labels as described above
    * to contain the directive 
           <absolute><presentation><None/></presentation></absolute>
3. Implement changes to ERmodel2.diagram.module.xslt.
    * Not to render absolute if <presentation><None/></presentation> as above.
    * Not to render an entity type unless it has a presentation or is a child entity type.
    * not to render a relationship unless host entity type and destination entity type
      are being rendered.

### Testing

1. Build various goodlandSSADMcarHire diagrams and include
in the draft "Introduction to Entity Modelling Book.

### Completion Date.
9th October 2024.

