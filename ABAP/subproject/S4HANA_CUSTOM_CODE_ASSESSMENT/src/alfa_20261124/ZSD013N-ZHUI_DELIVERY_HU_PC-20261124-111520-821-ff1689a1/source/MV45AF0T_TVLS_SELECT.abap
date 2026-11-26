*---------------------------------------------------------------------*
*       FORM TVLS_SELECT                                              *
*---------------------------------------------------------------------*
*       Liefersperre lesen                                            *
*---------------------------------------------------------------------*
FORM TVLS_SELECT USING US_LIFSP
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LIFSP NE TVLS-LIFSP.

  IF US_LIFSP = SPACE.
    CLEAR: TVLS, TVLST.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVLS WHERE LIFSP = US_LIFSP.
  IF SY-SUBRC NE 0.
    CLEAR: TVLS, TVLST.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBEP-LIFSP' LINE SY-STEPL.
      MESSAGE E387 WITH US_LIFSP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.