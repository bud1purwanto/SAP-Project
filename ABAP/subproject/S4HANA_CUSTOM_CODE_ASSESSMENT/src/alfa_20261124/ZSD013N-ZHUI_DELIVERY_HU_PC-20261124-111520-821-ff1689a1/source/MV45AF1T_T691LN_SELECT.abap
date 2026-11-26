*eject
*---------------------------------------------------------------------*
*       FORM T691LN_SELECT                                            *
*---------------------------------------------------------------------*
*       Text Absicherungsschema und Absicherungsform ermitteln        *
*---------------------------------------------------------------------*
FORM T691LN_SELECT
     USING VALUE(H_ABSSC) LIKE VBKD-ABSSC
           VALUE(H_ABFOR) LIKE VBAP-ABFOR.

*------- Lesen Text Absicherungsschema
  IF NOT ( H_ABSSC IS INITIAL ).
    IF H_ABSSC NE T691N-ABSSC.
      SELECT SINGLE * FROM T691N
                      WHERE SPRAS EQ SY-LANGU
                        AND ABSSC EQ H_ABSSC.
      IF NOT ( SY-SUBRC IS INITIAL ).
        CLEAR: T691N.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR: T691N.
  ENDIF.

*------- Lesen Text Absicherungsform
  IF NOT ( H_ABFOR IS INITIAL ).
    IF H_ABFOR NE T691L-ABSFO.
      SELECT SINGLE * FROM T691L
                      WHERE SPRAS EQ SY-LANGU
                        AND ABSFO EQ H_ABFOR.
      IF NOT ( SY-SUBRC IS INITIAL ).
        CLEAR: T691L.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR: T691L.
  ENDIF.

ENDFORM.