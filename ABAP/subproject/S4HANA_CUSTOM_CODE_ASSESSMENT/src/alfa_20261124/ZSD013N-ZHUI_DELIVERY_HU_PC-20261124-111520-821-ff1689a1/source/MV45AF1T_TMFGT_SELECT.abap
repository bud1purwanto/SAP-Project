*eject
*&---------------------------------------------------------------------*
*&      Form  TMFGT_SELECT
*&---------------------------------------------------------------------*
*       Text zur Materialfrachtgruppe lesen
*----------------------------------------------------------------------*
*      -->US_MFRGR : Materialfrachtgruppe                              *
*      -->US_ERROR : Errorhandling                                     *
*      <--CH_SUBRC : Returncode                                        *
*----------------------------------------------------------------------*
FORM TMFGT_SELECT USING   US_MFRGR LIKE VBAP-MFRGR
                          US_ERROR
                          CH_SUBRC.

  CH_SUBRC = 0.
  CHECK  US_MFRGR NE TMFGT-MFRGR.

  IF US_MFRGR = SPACE.
    CLEAR: TMFGT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TMFGT WHERE SPRAS = SY-LANGU AND
                                   MFRGR = US_MFRGR.

  IF SY-SUBRC NE 0.
    CLEAR TMFGT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
*  Keine meldung vorgesehen; Pending discussion with Thomas Bach (21.01)
*     message e074 with us_mfrgr.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.                               " TMFGT_SELECT