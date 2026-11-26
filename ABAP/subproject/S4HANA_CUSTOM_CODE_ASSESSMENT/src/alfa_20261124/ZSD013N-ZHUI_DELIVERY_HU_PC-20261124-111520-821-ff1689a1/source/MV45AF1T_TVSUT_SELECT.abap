*---------------------------------------------------------------------*
*       FORM TVSUT_SELECT                                             *
*---------------------------------------------------------------------*
*       Text zum Substitutuinsgrund lesen                             *
*---------------------------------------------------------------------*
FORM TVSUT_SELECT USING US_SUGRD.

  CHECK: US_SUGRD NE TVSUT-SUGRD.

  SELECT SINGLE * FROM TVSUT WHERE SPRAS = SY-LANGU
                               AND SUGRD = US_SUGRD.

  IF SY-SUBRC NE 0.
    CLEAR TVSUT.
  ENDIF.

ENDFORM.