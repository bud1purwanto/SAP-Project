*-----------------------------------------------------------------------
*        Daten für Kommuniaktion mit VL04 Sammelgang
*-----------------------------------------------------------------------

TABLES: VEPVG,
        VBSS.

DATA:    BEGIN OF COMMON PART VL04COM.

DATA:    BEGIN OF TVBVFI OCCURS 50.
           INCLUDE STRUCTURE VBVFI.
DATA:    END OF TVBVFI.

DATA:    BEGIN OF TVBVFP OCCURS 50.
           INCLUDE STRUCTURE VBVFP.
DATA:    END OF TVBVFP.

* erstellte Lieferungen
DATA:   BEGIN OF CVBSS OCCURS 50.
          INCLUDE STRUCTURE VBSS.
DATA:   END OF CVBSS.

DATA:   END OF COMMON PART.
*eject