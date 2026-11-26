*---------------------------------------------------------------------*
*       FORM TPRIO_SELECT                                             *
*---------------------------------------------------------------------*
*       Lieferpriorität  prüfen                                       *
*---------------------------------------------------------------------*
FORM TPRIO_SELECT USING US_LPRIO
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LPRIO NE TPRIO-LPRIO.

  IF US_LPRIO = SPACE.
    CLEAR: TPRIO, TPRIT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TPRIO WHERE LPRIO = US_LPRIO.

  IF SY-SUBRC NE 0.
    CLEAR: TPRIO, TPRIT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E074 WITH US_LPRIO.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.