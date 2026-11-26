*eject
*---------------------------------------------------------------------*
*       MODULE DATUM_HILFE                                            *
*---------------------------------------------------------------------*
*       Allgemeines Kalender-Popup                                    *
*---------------------------------------------------------------------*
MODULE DATUM_HILFE.

* DATA-Definitionen
  DATA: DYNP_NAME  LIKE SY-REPID.
  DATA: DYNP_NUMB  LIKE SY-DYNNR.
  DATA: FIELD_NAME LIKE AM61K-FNAME.
  DATA: HELP_DATE  LIKE SY-DATUM.
  DATA: LOC_WERKS  LIKE T001W-WERKS.
  DATA: BEGIN OF DYNP_FIELDS OCCURS 1.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF DYNP_FIELDS.
  FIELD-SYMBOLS: <DATE>.

* Festwerte
  DYNP_NAME = SY-REPID.
  DYNP_NUMB = SY-DYNNR.
  DYNP_FIELDS-FIELDNAME = 'RM07M-WERKS'.
  APPEND DYNP_FIELDS.

* Werk vom Dynpro lesen
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME               = DYNP_NAME
            DYNUMB               = DYNP_NUMB
       TABLES
            DYNPFIELDS           = DYNP_FIELDS
       EXCEPTIONS
            OTHERS               = 1.
  IF SY-SUBRC IS INITIAL.
    READ TABLE DYNP_FIELDS INDEX 1.
    MOVE DYNP_FIELDS-FIELDVALUE TO LOC_WERKS.
  ENDIF.

* Werkskalender lesen
  CLEAR T001W.
  SELECT SINGLE * FROM T001W WHERE WERKS = LOC_WERKS.

* F4-Datumsauswahl
  CALL FUNCTION 'GET_DATE_FROM_CALID'
       EXPORTING
            CALID      = T001W-FABKL
            REPID      = DYNP_NAME
            DYNNR      = DYNP_NUMB
       IMPORTING
            FIELD_NAME = FIELD_NAME
            NEW_DATE   = HELP_DATE.

* Selektiertes Datum übernehmen
  ASSIGN TABLE FIELD (FIELD_NAME) TO <DATE>.
  MOVE HELP_DATE TO <DATE>.

ENDMODULE.