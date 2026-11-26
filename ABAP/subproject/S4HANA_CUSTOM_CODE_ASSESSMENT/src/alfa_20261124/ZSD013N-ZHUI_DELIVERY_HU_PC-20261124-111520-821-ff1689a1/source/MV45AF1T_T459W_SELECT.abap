*---------------------------------------------------------------------*
*       FORM T459W_SELECT                                             *
*---------------------------------------------------------------------*
*       Text zur Bedarfsart lesen                                     *
*---------------------------------------------------------------------*
FORM T459W_SELECT USING US_BEDAE.

  CHECK: US_BEDAE NE T459W-BEDAE.

  SELECT SINGLE * FROM T459W WHERE SPRAS = SY-LANGU
                               AND BEDAE = US_BEDAE.

  IF SY-SUBRC NE 0.
    CLEAR T459W.
  ENDIF.

ENDFORM.