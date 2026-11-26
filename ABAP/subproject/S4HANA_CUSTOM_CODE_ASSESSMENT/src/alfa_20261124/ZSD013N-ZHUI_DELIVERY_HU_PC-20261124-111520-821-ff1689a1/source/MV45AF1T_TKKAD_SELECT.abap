***INCLUDE MV45AF1T .
*---------------------------------------------------------------------*
*       FORM TKKAD_SELECT                                             *
*---------------------------------------------------------------------*
*       Abgrenzzungsschlüssel Text                                    *
*---------------------------------------------------------------------*
FORM TKKAD_SELECT USING US_ABGSL
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ABGSL NE TKKAD-ABGSL.

  IF US_ABGSL = SPACE.
    CLEAR: TKKAD.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TKKAD WHERE ABGSL = US_ABGSL
                               AND SPRAS = SY-LANGU.
  IF SY-SUBRC NE 0.
    CLEAR: TKKAD.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.