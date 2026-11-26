*----------------------------------------------------------------------*
*   INCLUDE RKCOSEI2                                                   *
*----------------------------------------------------------------------*

TABLES: *lko74, *aufk, *afpo.

DATA: txtw(45) TYPE c.
* Auftragsteil
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK sender_selection.
PARAMETERS: selexp TYPE xflag NO-DISPLAY.
*SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON /1(40) subscexp USER-COMMAND subscexp.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS:
   werks FOR *lko74-werks MEMORY ID wrk NO INTERVALS.
*SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS:
   auart FOR *aufk-auart MODIF ID exp,
   matnr FOR *afpo-matnr MODIF ID exp,
   aufnr FOR *afpo-aufnr MODIF ID exp.

PARAMETERS:
   in_fauf  LIKE lko74-incl_fauf   DEFAULT 'X' MODIF ID exp     "752910
                                   AS CHECKBOX,                 "752910
   in_piauf LIKE lko74-incl_piauf  DEFAULT 'X' MODIF ID exp     "...
                                   AS CHECKBOX,
   in_pkosa LIKE lko74-incl_pkosa  DEFAULT 'X' MODIF ID exp
                                   AS CHECKBOX,                 "...
   in_qmauf LIKE lko74-incl_qmauf  DEFAULT 'X' MODIF ID exp     "752910
                                   AS CHECKBOX.                 "752910
SELECTION-SCREEN SKIP 1.
PARAMETERS:
   in_proj  LIKE lko74-incl_proj   DEFAULT ' ' MODIF ID exp     "752910
                                   AS CHECKBOX,                 "752910
   in_kstrg LIKE lko74-incl_kstrg  DEFAULT ' ' MODIF ID exp     "752910
                                   AS CHECKBOX.                 "752910
ENHANCEMENT-POINT RKCOSEI2_01 SPOTS ES_RKCOSEI2 STATIC INCLUDE BOUND.
SELECTION-SCREEN SKIP 1.
PARAMETERS:
   aufgr    LIKE lko74-aufgr MODIF ID agr NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK sender_selection.