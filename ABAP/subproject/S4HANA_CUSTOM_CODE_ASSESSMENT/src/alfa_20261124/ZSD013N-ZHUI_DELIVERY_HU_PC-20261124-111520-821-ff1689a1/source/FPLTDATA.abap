*-----------------------------------------------------------------------
*        Datenbanktabelle FPLT
*-----------------------------------------------------------------------

TABLES: FPLT, *FPLT, TFPLT.
TABLES: FPLTD, *FPLTD.
TABLES: CCDATA, *CCDATA, CCDATE, CCARD_CVV, CCARD_RCVV.

DATA: BEGIN OF COMMON PART FPLTCOM.

* Alter Tabellenstand beim Ändern
DATA:   BEGIN OF YFPLT OCCURS 2.
          INCLUDE STRUCTURE FPLTVB.
DATA:   END OF YFPLT.

* Aktueller Tabellenstand
DATA:   BEGIN OF XFPLT OCCURS 10.
          INCLUDE STRUCTURE FPLTVB.
DATA:   END OF XFPLT.

* Kennzeichen, ob Aenderungsbelege nötig
DATA: UPD_FPLT.

DATA: END   OF COMMON PART.
*eject