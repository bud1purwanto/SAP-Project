*eject
*---------------------------------------------------------------------*
*       FORM TVLST_SELECT                                              *
*---------------------------------------------------------------------*
*       Liefersperre und zugehörigen Text lesen                       *
*---------------------------------------------------------------------*
FORM TVLST_SELECT USING US_LIFSP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LIFSP NE TVLST-LIFSP.

  IF US_LIFSP = SPACE.
    CLEAR: TVLST.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVLST WHERE SPRAS = SY-LANGU
                               AND LIFSP = US_LIFSP.
  IF SY-SUBRC NE 0.
    CLEAR: TVLST.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBEP-LIFSP' LINE SY-STEPL.
      MESSAGE E388 WITH US_LIFSP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.