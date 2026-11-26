*---------------------------------------------------------------------*
*       FORM TVZPT_SELECT                                             *
*---------------------------------------------------------------------*
*       Planabrufvorschrift prüfen                                    *
*---------------------------------------------------------------------*
FORM TVZPT_SELECT USING US_PLAVO
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PLAVO NE TVZPT-PLAVO.

  IF US_PLAVO = SPACE.
    CLEAR: TVZPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVZPT WHERE SPRAS = SY-LANGU
                               AND PLAVO = US_PLAVO.

  IF SY-SUBRC NE 0.
    CLEAR TVZPT.
  ENDIF.

ENDFORM.