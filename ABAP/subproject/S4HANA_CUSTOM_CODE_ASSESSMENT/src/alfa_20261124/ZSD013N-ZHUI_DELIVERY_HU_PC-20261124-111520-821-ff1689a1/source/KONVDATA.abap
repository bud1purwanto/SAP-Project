*-----------------------------------------------------------------------
*        Datenbank-Tabelle KONV
*-----------------------------------------------------------------------

TABLES: KONP.
TABLES: KOMPAX.

DATA:    BEGIN OF COMMON PART KONVCOM.

*DATA:   BEGIN OF TKOMK OCCURS 2.
*          INCLUDE STRUCTURE KOMK.
*DATA:   END   OF TKOMK.
DATA: TKOMK LIKE STANDARD TABLE OF KOMK
                 WITH KEY KEY_UC
                 INITIAL SIZE 2
                 WITH HEADER LINE.

DATA:   BEGIN OF TKOMP OCCURS 10.
        INCLUDE STRUCTURE KOMP.
DATA:   END   OF TKOMP.

DATA:   BEGIN OF TKOMG OCCURS 10.
        INCLUDE STRUCTURE KOMG.
DATA:   END   OF TKOMG.

DATA:   BEGIN OF XVCKEY OCCURS 0.                           "2.2B
        INCLUDE STRUCTURE VCKEY.                            "2.2B
DATA:   END   OF XVCKEY.                                    "2.2B

DATA:   BEGIN OF XVCTXT OCCURS 0.                           "2.2B
        INCLUDE STRUCTURE VCTXT.                            "2.2B
DATA:   END   OF XVCTXT.                                    "2.2B

DATA:   BEGIN OF XKOMV OCCURS 50.
        INCLUDE STRUCTURE KOMV.
DATA:   END   OF XKOMV.

DATA:   BEGIN OF XVCOND OCCURS 0.
        INCLUDE STRUCTURE API_VCOND.
DATA:   END   OF XVCOND.


DATA:   KONV_GEAENDERT(1).

ENHANCEMENT-POINT KONVDATA_10 SPOTS ES_KONVDATA STATIC INCLUDE BOUND.
DATA:   END OF COMMON PART.
*eject