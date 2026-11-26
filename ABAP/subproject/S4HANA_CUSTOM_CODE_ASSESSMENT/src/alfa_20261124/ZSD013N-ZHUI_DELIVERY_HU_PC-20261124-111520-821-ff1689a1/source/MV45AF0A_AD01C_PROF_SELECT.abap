*----------------------------------------------------------------------*
*   INCLUDE MV45AF0A_AD01C_PROF_SELECT                                 *
*----------------------------------------------------------------------*
FORM AD01C_PROF_SELECT USING US_PROFNR
                             US_ERROR
                             CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PROFNR NE AD01C_PROF-PROFNR.

  IF US_PROFNR = SPACE.
    CLEAR: AD01C_PROF.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM AD01C_PROF WHERE PROFNR = US_PROFNR.

  IF SY-SUBRC NE 0.
    CLEAR AD01C_PROF.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E845 WITH US_PROFNR.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.