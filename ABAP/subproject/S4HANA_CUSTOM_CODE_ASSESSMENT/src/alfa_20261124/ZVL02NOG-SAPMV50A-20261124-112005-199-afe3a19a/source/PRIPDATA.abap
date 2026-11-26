***INCLUDE PRIPDATA.

* Internal tables for the pricing functionality of the delivery

tables: komv, kompax.

data: begin of common part pripdata.

* Communication structure header
*data: tkomk type standard table of komk with header line. "v_696724
DATA: TKOMK LIKE STANDARD TABLE OF KOMK
                 WITH KEY KEY_UC
                 INITIAL SIZE 2
                 WITH HEADER LINE.                         "^_696724

* Communication structure item
data: tkomp type standard table of komp with header line.

* Conditions
data: tkomv type standard table of komv with header line.

data: end of common part.