*---------------------------------------------------------------------*
*       FORM TVGRPS_SELECT                                            *
*---------------------------------------------------------------------*
*       Gruppenreferenzbedingung: Schemata  lesen                     *
*---------------------------------------------------------------------*
FORM TVGRPS_SELECT USING US_SCHEME
                         US_ERROR
                         CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SCHEME NE TVGRPS-SCHEME.

  IF US_SCHEME = SPACE.
    CLEAR: TVGRPS, TVGRPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVGRPS WHERE SCHEME = US_SCHEME.

  IF SY-SUBRC NE 0.
    CLEAR: TVGRPS, TVGRPT.
    IF US_ERROR NE SPACE.
      MESSAGE E834 WITH US_SCHEME.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.