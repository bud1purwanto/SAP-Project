*&---------------------------------------------------------------------*
*&      Form  TSABT_SELECT                                             *
*&---------------------------------------------------------------------*
*       Abteilung lesen                                                *
*----------------------------------------------------------------------*
FORM TSABT_SELECT USING US_ABTNR
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ABTNR NE TSABT-ABTNR.

  IF US_ABTNR = SPACE.
    CLEAR: TSABT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TSABT WHERE SPRAS = SY-LANGU
                               AND ABTNR = US_ABTNR.

  IF SY-SUBRC NE 0.
    CLEAR: TSABT.
    IF US_ERROR = CHARX.
      MESSAGE E640 WITH US_ABTNR.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.                               " TSABT_SELECT