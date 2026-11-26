*----------------------------------------------------------------------*
***INCLUDE MV45AF0K_KUNDE_GET_F4HELP .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KUNDE_GET_F4HELP
*&---------------------------------------------------------------------*
*       F4 für Kunde Auftragsgeber
*----------------------------------------------------------------------*
*      <-- <P_KUNDE_AG>  text
*----------------------------------------------------------------------*
FORM KUNDE_GET_F4HELP USING    P_DYNPFIELDS_FIELDINP
                               P_DYNPFIELDS_FIELDVAL
                      CHANGING P_KUNDE_AG.

  DATA: MATCHCODE_OBJECT     LIKE DD23L-MCONAME,
        SELECT_STRING        LIKE HELP_INFO-FLDVALUE.

* Parameter für F4IF_FIELD_VALUE_REQUEST
  DATA: MC_OBJ LIKE HELP_INFO-MCOBJ.
  DATA: RETURN_VALUES LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
  DATA: DA_DISPLAY TYPE C.

*   Matchcodeobjekt aufrufen
  MC_OBJ = 'SD_DEBI'.
  IF P_DYNPFIELDS_FIELDINP EQ SPACE.
     DA_DISPLAY = CHARX.
  ENDIF.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            TABNAME           = SPACE
            FIELDNAME         = SPACE
            SEARCHHELP        = MC_OBJ
*           SHLPPARAM         = ' '
*           DYNPPROG          = ' '
*           DYNPNR            = ' '
            DYNPROFIELD       = 'X'
*           STEPL             = 0
            VALUE             = P_DYNPFIELDS_FIELDVAL
*           MULTIPLE_CHOICE   = ' '
            DISPLAY           = DA_DISPLAY
*           CALLBACK_PROGRAM  = ' '
*           CALLBACK_FORM     = ' '
       TABLES
            RETURN_TAB        = RETURN_VALUES
      EXCEPTIONS
            FIELD_NOT_FOUND   = 1
            NO_HELP_FOR_FIELD = 2
            INCONSISTENT_HELP = 3
            NO_VALUES_FOUND   = 4
            OTHERS            = 5.
  IF SY-SUBRC = 0 AND
     P_DYNPFIELDS_FIELDINP NE SPACE.
    P_KUNDE_AG = RETURN_VALUES-FIELDVAL.
  ENDIF.

ENDFORM.                    " KUNDE_GET_F4HELP