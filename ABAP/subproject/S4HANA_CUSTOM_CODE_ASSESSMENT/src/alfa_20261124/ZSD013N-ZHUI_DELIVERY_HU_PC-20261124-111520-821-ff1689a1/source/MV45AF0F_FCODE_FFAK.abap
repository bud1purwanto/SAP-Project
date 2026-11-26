*---------------------------------------------------------------------*
*       FORM FCODE_FFAK                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Fakturierung aufrufen                       *
*---------------------------------------------------------------------*
FORM FCODE_FFAK.

  SET PARAMETER ID 'VFR' FIELD VBAK-VBELN.
  SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
  SET PARAMETER ID 'VTW' FIELD VBAK-VTWEG.
  SET PARAMETER ID 'SPA' FIELD VBAK-SPART.
  IF R185D-DATALOSS NE SPACE.
    PERFORM BELEG_SICHERN USING CHARX
                                SY-SUBRC.
  ENDIF.
  set parameter id 'SD_METHOD_CALL' field ' '.

ENDFORM.