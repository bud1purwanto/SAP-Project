*eject
*---------------------------------------------------------------------*
*       FORM TVAKT_SELECT                                             *
*---------------------------------------------------------------------*
*       Auftragsartentabelle lesen Text                               *
*---------------------------------------------------------------------*
FORM TVAKT_SELECT USING US_AUART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUART NE TVAKT-AUART.

  SELECT SINGLE * FROM TVAKT WHERE SPRAS = SY-LANGU
                               AND AUART = US_AUART.

  IF SY-SUBRC NE 0.
    CLEAR TVAKT.
    IF US_ERROR = CHARX.
      MESSAGE E119 WITH US_AUART SY-LANGU.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.