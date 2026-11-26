*-----------------------------------------------------------------------
*        Tabellen fuer Nachrichtensteuerung
*-----------------------------------------------------------------------
DATA: BEGIN OF COMMON PART NASTCOM.

* current messages
DATA:    XNAST LIKE VNAST OCCURS 20 WITH HEADER LINE.

* old messages
DATA:    YNAST LIKE NAST OCCURS 20 WITH HEADER LINE.

* new messages
DATA:    NNAST LIKE VNAST OCCURS 20 WITH HEADER LINE.


DATA:    TEMP_PROGRAM_NAME LIKE TRDIR-NAME.
DATA: END OF COMMON PART.

*eject