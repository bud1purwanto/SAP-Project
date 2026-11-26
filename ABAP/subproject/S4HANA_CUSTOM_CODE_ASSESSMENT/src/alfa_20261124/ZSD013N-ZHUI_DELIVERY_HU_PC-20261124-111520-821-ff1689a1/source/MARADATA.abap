*-----------------------------------------------------------------------
*        Materialstammtabellen
*-----------------------------------------------------------------------

TABLES:  MCHAR,                        "Chargenview wie CHARG
         MSKA,                         "Einzelbestand
        *MTCOM,                        "zu MAAPV
         MBEW,
         MAKT,
         MAPOV,
         MAWEV,
         MAAPV,
         MT06A,
         MT61D,                        "für Bedarfserfassung
         MTCOM,                        "zu MAEPV
         MTCOR,
         MAEPV.

DATA: BEGIN OF COMMON PART MARACOM.

DATA: MATERIAL_VORSTEP_GELAUFEN,
      MATERIAL_VORSTEP_SPRACHE LIKE SY-LANGU.

DATA: BEGIN OF MATKEY OCCURS 20.
        INCLUDE STRUCTURE PRE01.
DATA: END OF MATKEY.

DATA: BEGIN OF MAKT_MTCOM.
        INCLUDE STRUCTURE MTCOM.
DATA: END OF MAKT_MTCOM.

DATA: BEGIN OF CHARG_MTCOM.
        INCLUDE STRUCTURE MTCOM.
DATA: END OF CHARG_MTCOM.

DATA: BEGIN OF MENGE_MTCOM.
        INCLUDE STRUCTURE MTCOM.
DATA: END OF MENGE_MTCOM.

DATA: BEGIN OF MT61D_MTCOM.
        INCLUDE STRUCTURE MTCOM.
DATA: END OF MT61D_MTCOM.

DATA: BEGIN OF MBEW_MTCOM.
        INCLUDE STRUCTURE MTCOM.
DATA: END OF MBEW_MTCOM.

* Steuerung Puffern Materialstamm
* Beim ersten Aufruf 100, dann plus Anzahl Positionen

DATA:
MAXTZ_MAAPV LIKE MTCOM-MAXTZ VALUE 100,
MAXTZ_HIGH  LIKE MTCOM-MAXTZ VALUE 0999,
MAXTZ_NORM  LIKE MTCOM-MAXTZ VALUE 100.

DATA: END OF COMMON PART MARACOM.
*eject