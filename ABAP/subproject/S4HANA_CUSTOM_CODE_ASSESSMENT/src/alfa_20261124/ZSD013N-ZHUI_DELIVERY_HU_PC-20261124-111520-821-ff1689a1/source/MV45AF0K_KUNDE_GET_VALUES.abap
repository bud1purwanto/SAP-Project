*&---------------------------------------------------------------------*
*&      Form  KUNDE_GET_VALUES
*&---------------------------------------------------------------------*
*       F4 für Kunde Auftraggeber und Übernahme selektierten Wert
*----------------------------------------------------------------------*
*  <-- Kunde Auftraggeber Warenempfänger
*----------------------------------------------------------------------*
FORM KUNDE_GET_VALUES USING FIELDNAME_KUNDE_AG.

  DATA: BEGIN OF DYNPFIELDS OCCURS 1.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF DYNPFIELDS.

  DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
  DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.
  DYNPRO_PROGRAM  = SY-REPID.          "believe it or not -
  DYNPRO_NUMBER   = SY-DYNNR.          "these assignments are necessary!

* Kunde wird dynamisch mit dem übergebenen Feldname assoziiert.
  FIELD-SYMBOLS:  <KUNDE_AG> LIKE RV45S-KUNNR.
  ASSIGN (FIELDNAME_KUNDE_AG)  TO <KUNDE_AG>.

* zu lesende Feld vormerken.
  MOVE FIELDNAME_KUNDE_AG   TO DYNPFIELDS-FIELDNAME.
  APPEND DYNPFIELDS.

* Feldinhalte vor dem automatischen Feldtransport beim PAI
* explizit auslesen
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME                   = DYNPRO_PROGRAM
            DYNUMB                   = DYNPRO_NUMBER
*         TRANSLATE_TO_UPPER       = ' '
*         REQUEST                  = ' '
            PERFORM_INPUT_CONVERSION = 'X'
       TABLES
            DYNPFIELDS               = DYNPFIELDS
       EXCEPTIONS
            INVALID_ABAPWORKAREA     = 1
            INVALID_DYNPROFIELD      = 2
            INVALID_DYNPRONAME       = 3
            INVALID_DYNPRONUMMER     = 4
            INVALID_REQUEST          = 5
            NO_FIELDDESCRIPTION      = 6
            INVALID_PARAMETER        = 7
            UNDEFIND_ERROR           = 8
            OTHERS                   = 9.

  READ TABLE DYNPFIELDS WITH KEY FIELDNAME = FIELDNAME_KUNDE_AG.
  <KUNDE_AG>   =   DYNPFIELDS-FIELDVALUE.

  PERFORM KUNDE_GET_F4HELP  USING     DYNPFIELDS-FIELDINP
                                      DYNPFIELDS-FIELDVALUE
                           CHANGING  <KUNDE_AG>.

ENDFORM.                               " KUNDE_GET_VALUES