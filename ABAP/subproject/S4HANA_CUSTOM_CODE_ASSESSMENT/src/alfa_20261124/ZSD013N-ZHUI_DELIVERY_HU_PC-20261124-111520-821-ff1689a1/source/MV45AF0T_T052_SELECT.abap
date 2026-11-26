*eject
*---------------------------------------------------------------------*
*       FORM T052_SELECT                                              *
*---------------------------------------------------------------------*
*       Zahlungsbedingungen prüfen                                    *
*---------------------------------------------------------------------*
FORM T052_SELECT USING US_ZTERM
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ZTERM NE T052-ZTERM.

  IF US_ZTERM = SPACE.
    CLEAR: T052.
    EXIT.
  ENDIF.

* generischer Zugriff
  SELECT * FROM T052 WHERE ZTERM = US_ZTERM.
    EXIT.
  ENDSELECT.

  IF SY-SUBRC NE 0.
    CLEAR T052.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBKD-ZTERM' LINE SY-STEPL.
      MESSAGE E398 WITH US_ZTERM.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.