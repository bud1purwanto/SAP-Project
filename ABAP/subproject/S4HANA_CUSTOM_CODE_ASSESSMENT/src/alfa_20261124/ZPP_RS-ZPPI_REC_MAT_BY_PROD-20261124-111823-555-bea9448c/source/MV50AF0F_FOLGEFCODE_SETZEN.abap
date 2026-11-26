***INCLUDE MV50AF0F_FOLGEFCODE_SETZEN .
*---------------------------------------------------------------------*
*       FORM FOLGEFCODE_SETZEN                                        *
*---------------------------------------------------------------------*
*       Falls kein Funktionscode eingegeben wurde, wird der           *
*       Default-Funktionscode gesetzt.                                *
*---------------------------------------------------------------------*
FORM FOLGEFCODE_SETZEN.

  IF FCODE EQ SPACE.
    FCODE = T185F-FCODE.
  ENDIF.

ENDFORM.