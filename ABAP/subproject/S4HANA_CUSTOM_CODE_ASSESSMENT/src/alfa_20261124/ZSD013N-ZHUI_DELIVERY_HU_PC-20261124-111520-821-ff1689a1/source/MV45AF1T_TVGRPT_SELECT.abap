*&---------------------------------------------------------------------*
*&      Form  TVGRPT_SELECT
*&---------------------------------------------------------------------*
*       Text des Gruppenreferenzschemas lesen
*----------------------------------------------------------------------*
FORM TVGRPT_SELECT USING    US_SCHEME_GRP
                            US_ERROR
                            CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SCHEME_GRP NE TVGRPT-SCHEME.

  IF US_SCHEME_GRP = SPACE.
    CLEAR: TVGRPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVGRPT WHERE SPRAS = SY-LANGU
                               AND SCHEME = US_SCHEME_GRP.
  IF SY-SUBRC NE 0.
    CLEAR: TVGRPT.
    IF US_ERROR NE SPACE.
      MESSAGE E662 WITH US_SCHEME_GRP.
    ELSE.
      CH_SUBRC = 12.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                               " TVGRPT_SELECT