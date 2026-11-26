***INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_DATUMI .
*&---------------------------------------------------------------------*
*&      Module  ZAHLUNGSKARTEN_DATUMI  INPUT
*&---------------------------------------------------------------------*
*       Datum Prüfen und im interen Format umwandlen
*----------------------------------------------------------------------*
MODULE ZAHLUNGSKARTEN_DATUMI INPUT.

  CALL FUNCTION 'CCARD_DATE_CONVERT_INPUT'
       EXPORTING
            CCINS_I         = CCDATA-CCINS
            EXTERNAL_DATE_I = CCDATE-EXDATBI
       IMPORTING
            INTERNAL_DATE_E = CCDATA-DATBI.

ENDMODULE.                             " ZAHLUNGSKARTEN_DATUMI  INPUT