*eject
*---------------------------------------------------------------------*
*       FORM TVZB_SELECT                                              *
*---------------------------------------------------------------------*
*       Zahlungsbedingungen prüfen                                    *
*---------------------------------------------------------------------*
FORM TVZB_SELECT USING US_ZTERM
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ZTERM NE TVZB-ZTERM.

  IF US_ZTERM = SPACE.
    CLEAR: TVZB, TVZBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVZB WHERE ZTERM = US_ZTERM.

  IF SY-SUBRC NE 0.
    CLEAR: TVZB, TVZBT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBKD-ZTERM' LINE SY-STEPL.
      MESSAGE E398 WITH US_ZTERM.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.