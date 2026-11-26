*eject
*---------------------------------------------------------------------*
*       FORM FUSSZEILE_SETZEN                                         *
*---------------------------------------------------------------------*
*       Fuellen der MSEG-Felder aus der Fusszeile.                    *
*---------------------------------------------------------------------*
FORM fusszeile_setzen.
  IF NOT fcausw-xneup IS INITIAL.
    PERFORM segment_init.
    MOVE-CORRESPONDING rm07m TO mseg.
    READ TABLE ymsegk INDEX 1.
    IF sy-subrc IS INITIAL.
      IF ymsegk-rsnum IS INITIAL.
        msegk-konto = ymsegk-konto.
        MOVE-CORRESPONDING ymsegk TO mseg.
      ELSE.
        CLEAR: ymsegk-rsnum, msegk-rsnum, ymsegk-konto, msegk-konto.
        MOVE-CORRESPONDING ymsegk TO mseg.
        MODIFY ymsegk INDEX 1.
      ENDIF.
    ENDIF.
    mseg-zeile = m_zeile + 1.
  ENDIF.

ENDFORM.