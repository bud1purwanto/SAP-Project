***INCLUDE MV50AF0F_FCODE_PREF .
*---------------------------------------------------------------------*
*       FORM FCODE_PREF                                               *
*---------------------------------------------------------------------*
*       Aufruf der Referenzdatenpflege auf Lieferpositionsebene       *
*---------------------------------------------------------------------*
FORM FCODE_PREF USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  IF XLIPS-RFVGTYP EQ VBTYP_BESTELL.
    CALL FUNCTION 'SHP_LIPSPO_MAINTAIN'
         EXPORTING
              IF_HANDLE_OBJ = LIKP-HANDLE
              IF_HANDLE     = LIPS-HANDLE
              IF_TRTYP      = 'A'
         CHANGING
              CF_CHANGED    = R185D-DATALOSS
         EXCEPTIONS
              NO_DISPLAY    = 1.
  ELSE.
    CALL FUNCTION 'SHP_LIPSRF_MAINTAIN'
         EXPORTING
              IF_HANDLE_OBJ = LIKP-HANDLE
              IF_HANDLE     = LIPS-HANDLE
              IF_TRTYP      = 'A'
         CHANGING
              CF_CHANGED    = R185D-DATALOSS
         EXCEPTIONS
              NO_DISPLAY    = 1.
  ENDIF.
  IF SY-SUBRC = 1.
    MESSAGE ID SY-MSGID TYPE GC_MSGTY-INFO NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.

ENDFORM.