*eject
*---------------------------------------------------------------------*
*       FORM TVDCT_SELECT                                             *
*---------------------------------------------------------------------*
*       Lieferzeit mit Text lesen                                     *
*---------------------------------------------------------------------*
FORM TVDCT_SELECT USING US_DELCO
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_DELCO NE TVDCT-DELCO.

  IF US_DELCO = SPACE.
    CLEAR: TVDCT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVDCT WHERE SPRAS = SY-LANGU
                               AND DELCO = US_DELCO.
  IF SY-SUBRC NE 0.
    CLEAR: TVDCT.
    IF US_ERROR NE SPACE.
      MESSAGE E683 WITH US_DELCO.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.