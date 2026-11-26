***INCLUDE MV45AF0Z_ZAHLUNGSKARTEN_DATUMO .
*&---------------------------------------------------------------------*
*&      Module  ZAHLUNGSKARTEN_DATUMO  OUTPUT
*&---------------------------------------------------------------------*
*       Umwandlung des Datums im externen Format
*----------------------------------------------------------------------*
MODULE ZAHLUNGSKARTEN_DATUMO OUTPUT.

  CALL FUNCTION 'CCARD_DATE_CONVERT_OUTPUT'
       EXPORTING
            CCINS_I         = CCDATA-CCINS
            INTERNAL_DATE_I = CCDATA-DATBI
       IMPORTING
            EXTERNAL_DATE_E = CCDATE-EXDATBI.

ENDMODULE.                             " ZAHLUNGSKARTEN_DATUMO  OUTPUT