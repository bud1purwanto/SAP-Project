*eject
*---------------------------------------------------------------------*
*       FORM TVZBT_SELECT                                             *
*---------------------------------------------------------------------*
*       Zahlungsbedingungen prüfen                                    *
*---------------------------------------------------------------------*
FORM TVZBT_SELECT USING US_ZTERM
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ZTERM NE TVZBT-ZTERM.

  IF US_ZTERM = SPACE.
    CLEAR: TVZBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVZBT WHERE SPRAS = SY-LANGU
                               AND ZTERM = US_ZTERM.

  IF SY-SUBRC NE 0.
    CLEAR TVZBT.
  ENDIF.

ENDFORM.