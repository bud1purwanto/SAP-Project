*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------
TABLES: ISEG.

DATA: BEGIN OF COMMON PART MM07ICMB.

DATA: BEGIN OF XISEG OCCURS 0.
        INCLUDE STRUCTURE ISEG.
DATA: END OF XISEG.

DATA: BEGIN OF XVM07I OCCURS 0.
        INCLUDE STRUCTURE VM07I.
DATA: END OF XVM07I.

ENHANCEMENT-POINT MM07ICMB_01 SPOTS ES_MM07ICMB STATIC INCLUDE BOUND.
DATA:    END OF COMMON PART.
*eject