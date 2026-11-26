*----------------------------------------------------------------------*
*   INCLUDE MV45AF0V_VBAP_MATNR_VALUES                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VBAP_MATNR_VALUES
*&---------------------------------------------------------------------*
*       F4 für Materialnummer
*----------------------------------------------------------------------*
FORM VBAP_MATNR_VALUES USING FIELDNAME_VBAP_MATNR.

  DATA: BEGIN OF DYNPFIELDS OCCURS 1.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF DYNPFIELDS.
  DATA: DYNPRO_DISPLAY.
  DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
  DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.
  DYNPRO_PROGRAM  = SY-REPID.          "believe it or not -
  DYNPRO_NUMBER   = SY-DYNNR.          "these assignments are necessary!

* zu lesende Feld vormerken.
  MOVE FIELDNAME_VBAP_MATNR   TO DYNPFIELDS-FIELDNAME.
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
            ERROR_MESSAGE            = 9
            OTHERS                   = 10.

  READ TABLE DYNPFIELDS WITH KEY FIELDNAME = FIELDNAME_VBAP_MATNR.
  IF SY-SUBRC EQ 0.
    IF NOT DYNPFIELDS-FIELDINP = 'X'.
      DYNPRO_DISPLAY = 'X'.
    ENDIF.


* Parameter für F4IF_FIELD_VALUE_REQUEST
    DATA: MC_OBJ LIKE HELP_INFO-MCOBJ.

*   Matchcodeobjekt aufrufen
    MC_OBJ = 'SD_MAT1'.
    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
         EXPORTING
              TABNAME           = SPACE
              FIELDNAME         = SPACE
              SEARCHHELP        = MC_OBJ
*               SHLPPARAM         = ' '
              DYNPPROG          = DYNPRO_PROGRAM
              DYNPNR            = DYNPRO_NUMBER
              DYNPROFIELD       = DYNPFIELDS-FIELDNAME
              STEPL             = DYNPFIELDS-STEPL
*               VALUE             = ' '
*               MULTIPLE_CHOICE   = ' '
              DISPLAY           = DYNPRO_DISPLAY
*               CALLBACK_PROGRAM  = ' '
*               CALLBACK_FORM     = ' '
        EXCEPTIONS
              FIELD_NOT_FOUND   = 1
              NO_HELP_FOR_FIELD = 2
              INCONSISTENT_HELP = 3
              NO_VALUES_FOUND   = 4
              OTHERS            = 5.
  ENDIF.

ENDFORM.                    " VBAP_MATNR_VALUES