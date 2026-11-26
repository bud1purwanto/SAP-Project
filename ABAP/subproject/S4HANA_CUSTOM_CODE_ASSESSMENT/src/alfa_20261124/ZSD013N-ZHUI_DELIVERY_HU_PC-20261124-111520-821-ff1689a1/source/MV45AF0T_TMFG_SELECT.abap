*---------------------------------------------------------------------*
*       FORM TMFG_SELECT                                             *
*---------------------------------------------------------------------*
*       Material-Frachtgruppe prüfen                                   *
*---------------------------------------------------------------------*
FORM TMFG_SELECT USING US_MFRGR
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MFRGR NE TMFG-MFRGR.

  IF US_MFRGR = SPACE.
    CLEAR: TMFG, TMFGT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TMFG WHERE MFRGR = US_MFRGR.

  IF SY-SUBRC NE 0.
    CLEAR: TMFG, TMFGT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E842 WITH US_MFRGR.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.