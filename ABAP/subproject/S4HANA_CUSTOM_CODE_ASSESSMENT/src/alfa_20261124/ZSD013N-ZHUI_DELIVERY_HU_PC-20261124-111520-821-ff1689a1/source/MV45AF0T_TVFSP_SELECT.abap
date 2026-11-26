*---------------------------------------------------------------------*
*       FORM TVFSP_SELECT                                             *
*---------------------------------------------------------------------*
*       Fakturasperre und zugehörigen Text lesen                      *
*       Aus Performacegründen wird nur Tabelle TVFST gelesen          *
*---------------------------------------------------------------------*
FORM TVFSP_SELECT USING US_FAKSP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_FAKSP NE TVFST-FAKSP.

  IF US_FAKSP = SPACE.
    CLEAR: TVFST.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVFST WHERE SPRAS = SY-LANGU
                               AND FAKSP = US_FAKSP.
  IF SY-SUBRC NE 0.
    CLEAR: TVFST.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAP-FAKSP' LINE SY-STEPL.
      MESSAGE E390 WITH US_FAKSP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.