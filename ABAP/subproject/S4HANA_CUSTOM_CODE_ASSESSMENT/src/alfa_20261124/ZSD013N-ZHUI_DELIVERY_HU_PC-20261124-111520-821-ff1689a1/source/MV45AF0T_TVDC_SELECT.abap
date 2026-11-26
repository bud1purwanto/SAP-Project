*---------------------------------------------------------------------*
*       FORM TVDC_SELECT                                              *
*---------------------------------------------------------------------*
*       Lieferfrist lesen                                             *
*---------------------------------------------------------------------*
FORM TVDC_SELECT USING US_DELCO
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_DELCO NE TVDC-DELCO.

  IF US_DELCO = SPACE.
    CLEAR: TVDC, TVDCT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVDC WHERE DELCO = US_DELCO.
  IF SY-SUBRC NE 0.
    CLEAR: TVDC, TVDCT.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBKD-DELCO' LINE SY-STEPL.
      MESSAGE E683 WITH US_DELCO.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.