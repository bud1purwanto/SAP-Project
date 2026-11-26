*eject
*---------------------------------------------------------------------*
*       FORM FCODE_FAUF                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Auftragsbearbeitung aufrufen                *
*---------------------------------------------------------------------*
FORM FCODE_FAUF.

  SET PARAMETER ID 'VRV' FIELD VBAK-VBTYP.
  SET PARAMETER ID 'VRA' FIELD VBAK-VBELN.
  SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
  SET PARAMETER ID 'VTW' FIELD VBAK-VTWEG.
  SET PARAMETER ID 'SPA' FIELD VBAK-SPART.
  SET PARAMETER ID 'AAT' FIELD TVAK-AUARA.
  IF R185D-DATALOSS NE SPACE.
    PERFORM BELEG_SICHERN USING CHARX
                                SY-SUBRC.
    IF SY-SUBRC = 0.
      PERFORM VBAK-VBELN_GET_PARAMETER(SAPFV45K).
      SET PARAMETER ID 'VRA' FIELD VBAK-VBELN.
      CLEAR VBAK-VBELN.
    ENDIF.
  ENDIF.

ENDFORM.