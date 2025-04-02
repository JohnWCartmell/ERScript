Examples roughly based on an example of Shlaer & Lang, OOA Report, 1996

Illustrative of shared (collapsed) referentials and displaced (absent) referentials.
For use in "Introduction to Entity Modelling". 

These diagrams will use `name` instead of `id` as an identifying attribute in order to give the possibility of relating to common language and the communication of relationships.
There are related diagrams in examples conceptual (currently with names beginning ShlaerMellor) that are closer to Shlaer Lang in that they assume ids as keys rather than names.

(1) shlaerLang-DeptStudentProfessor..logical.xml
   --- defined three types and three relationships;
    does not specify any relationships to be identifying;
   specifies attributes and whether identifying.
   This diagram does NOT show relationship ids.

(2) shlaerLang-StudentDept..relationship..diagram.xml
       --- single relationship drawn from left to right

(3) shlaerLang-ProfessorDept..relationship..diagram.xml
       --- single relationship drawn from left to right

(4) shlaerLang-StudentProfessor..relationship..diagram.xml
       --- single relationship drawn from left to right

(5) shlaerLang-StudentProfessorDept..path..diagram.xml
       --- two relationships drawn from left to right

(6) shlaerLang-StudentDept..path..diagram.xml
       --- same as (2) but shows id of relationship

(7) shlaerLang-DeptStudentProfessor..relationships..presentation.xml
   --- layout information for the three-relationship triangle

(8) shlaerLang-DeptStudentProfessor..relationships..diagram.xml
   --- specifies attributes None so that not displayed;
   includes just the associated ..logical and the associated ..presentation

(9) shlaerLang-DeptStudentProfessor..attributes..diagram.xml
   --- similar to (8) but specifies attributes identifying only; 
       and display relationship ids.

(10) shlaerLang-DeptStudentProfessor..absentReferential..diagram.xml
   --- similar to (8) but has riser relationship (i.e. prof-dept) specified as identifying

(11) shlaerLang-DeptStudentProfessor..collapsedReferential..diagram.xml
   --- similar to (9) but has diagonal and riser relationship specified as identifying; 

TBD   Aside this  have a scope triangle and hopefully show it (how about a triangle!)
   ACTUALLY HOW ABOUT *diagonal* &#x25B3; *riser* or even BETTER *diagonal* &#x25FF; *riser*.
   All very well saying this but visually conflicts with realtionship id.


TBD (12) shlaerLang-DeptStudentProfessor..explicitReferentials..diagram.xml
   --- similar to (10) but has diagonal and riser relationship specified as identifying; this will NOT have a scope triangle Can I emphasise this with a ^ &#x25B3; ^

