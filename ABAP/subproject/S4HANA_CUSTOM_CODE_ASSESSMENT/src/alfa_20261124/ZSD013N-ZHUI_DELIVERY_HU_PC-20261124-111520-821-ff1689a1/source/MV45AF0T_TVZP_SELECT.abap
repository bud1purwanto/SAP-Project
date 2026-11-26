*eject
*---------------------------------------------------------------------*
*       FORM TVZP_SELECT                                              *
*---------------------------------------------------------------------*
*       Planabrufvorschriften prüfen                                  *
*---------------------------------------------------------------------*
FORM TVZP_SELECT USING US_PLAVO
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PLAVO NE TVZP-PLAVO.

  IF US_PLAVO = SPACE.
    CLEAR: TVZP, TVZPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVZP WHERE PLAVO = US_PLAVO.

  IF SY-SUBRC NE 0.
    CLEAR: TVZP, TVZPT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E841 WITH US_PLAVO.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.