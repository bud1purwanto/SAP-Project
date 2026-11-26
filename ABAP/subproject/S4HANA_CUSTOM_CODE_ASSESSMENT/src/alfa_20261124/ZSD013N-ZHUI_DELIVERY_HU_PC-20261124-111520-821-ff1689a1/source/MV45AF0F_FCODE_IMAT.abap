*---------------------------------------------------------------------*
*       FORM FCODE_IMAT                                               *
*---------------------------------------------------------------------*
*       Anzeige Material                                              *
*---------------------------------------------------------------------*
FORM FCODE_IMAT.

  IF VBAP-MATNR IS INITIAL.
    MESSAGE S034.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    PERFORM TVTA_SELECT USING VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.
    IF VBAK-VKORG IS INITIAL.
      SET PARAMETER ID 'MXX' FIELD CHARD.
    ELSE.
      SET PARAMETER ID 'MXX' FIELD CHARV.
    ENDIF.
    SET PARAMETER ID 'MAT' FIELD VBAP-MATNR.
    SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
    SET PARAMETER ID 'VTW' FIELD TVTA-VTWKU.
    SET PARAMETER ID 'WRK' FIELD VBAP-WERKS.
  ENDIF.

ENDFORM.