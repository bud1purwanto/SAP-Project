*-----------------------------------------------------------------------
*        Datenbanktabelle FPLA
*-----------------------------------------------------------------------

TABLES: FPLA, *FPLA, TFPLA, FPLAA.
TABLES: FPLAD, *FPLAD.
ENHANCEMENT-POINT FPLADATA_01 SPOTS ES_FPLADATA STATIC INCLUDE BOUND.

DATA: BEGIN OF COMMON PART FPLACOM.

* Alter Tabellenstand beim Ändern
DATA:   BEGIN OF YFPLA OCCURS 2.
          INCLUDE STRUCTURE FPLAVB.
DATA:   END OF YFPLA.

* Aktueller Tabellenstand
DATA:   BEGIN OF XFPLA OCCURS 10.
          INCLUDE STRUCTURE FPLAVB.
DATA:   END OF XFPLA.

* Kennzeichen, ob Aenderungsbelege nötig
DATA: UPD_FPLA.

DATA: END   OF COMMON PART.
*eject