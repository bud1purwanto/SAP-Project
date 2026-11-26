*----------------------------------------------------------------------*
***INCLUDE MV45AF0V_VBAP_MATNR_GET_F4HELP .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VBAP_MATNR_GET_F4HELP
*&---------------------------------------------------------------------*
*       F4 für Materialnummer und Übernahme selektierter Werte
*----------------------------------------------------------------------*
FORM VBAP_MATNR_GET_F4HELP CHANGING P_MATNR.

  DATA: MATCHCODE_OBJECT     LIKE DD23L-MCONAME,
        SELECT_STRING        LIKE HELP_INFO-FLDVALUE.

* Parameter für F4IF_FIELD_VALUE_REQUEST
  DATA: MC_OBJ LIKE HELP_INFO-MCOBJ.
  DATA: RETURN_VALUES LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

  DATA: DA_MATNR LIKE VBAP-MATNR.
  DATA: DYNPRO_PROGRAM  LIKE SY-REPID. "Programmpool und Nummer in dem
  DATA: DYNPRO_NUMBER   LIKE SY-DYNNR. "das aktuelle Dynpro liegt.
  DYNPRO_PROGRAM  = SY-REPID.
  DYNPRO_NUMBER   = SY-DYNNR.

*   Matchcodeobjekt aufrufen
  MC_OBJ = 'SD_MAT1'.
ENHANCEMENT-POINT VBAP_MATNR_GET_F4HELP_10 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            TABNAME           = SPACE
            FIELDNAME         = SPACE
            SEARCHHELP        = MC_OBJ
*               SHLPPARAM         = ' '
            DYNPPROG          = DYNPRO_PROGRAM
            DYNPNR            = DYNPRO_NUMBER
            DYNPROFIELD       = 'VBAP-MATNR'
*               STEPL             = 0
*               VALUE             = ' '
*               MULTIPLE_CHOICE   = ' '
*               DISPLAY           = ' '
*               CALLBACK_PROGRAM  = ' '
*               CALLBACK_FORM     = ' '
*       TABLES
*            RETURN_TAB        = RETURN_VALUES
      EXCEPTIONS
            FIELD_NOT_FOUND   = 1
            NO_HELP_FOR_FIELD = 2
            INCONSISTENT_HELP = 3
            NO_VALUES_FOUND   = 4
            OTHERS            = 5.
  IF SY-SUBRC = 0.
    DA_MATNR = RETURN_VALUES-FIELDVAL.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT              = DA_MATNR
      IMPORTING
        OUTPUT             = P_MATNR
      EXCEPTIONS
        LENGTH_ERROR       = 1
        OTHERS             = 2
              .
    IF SY-SUBRC <> 0.
      P_MATNR = DA_MATNR.
    ENDIF.

  ENDIF.

ENDFORM.                    " VBAP_MATNR_GET_F4HELP