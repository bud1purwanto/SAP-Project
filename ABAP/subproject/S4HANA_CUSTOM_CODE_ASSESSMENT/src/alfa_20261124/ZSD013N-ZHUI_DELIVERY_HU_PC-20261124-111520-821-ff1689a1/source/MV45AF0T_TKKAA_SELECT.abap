*---------------------------------------------------------------------*
*       FORM TKKAA_SELECT                                             *
*---------------------------------------------------------------------*
*       Abgrenzungsschlüssel prüfen                                   *
*---------------------------------------------------------------------*
FORM TKKAA_SELECT USING US_ABGSL
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ABGSL NE TKKAA-ABGSL.

  IF US_ABGSL = SPACE.
    CLEAR: TKKAA, TKKAD.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TKKAA WHERE ABGSL = US_ABGSL.

  IF SY-SUBRC NE 0.
    CLEAR: TKKAA, TKKAD.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E839 WITH US_ABGSL.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.