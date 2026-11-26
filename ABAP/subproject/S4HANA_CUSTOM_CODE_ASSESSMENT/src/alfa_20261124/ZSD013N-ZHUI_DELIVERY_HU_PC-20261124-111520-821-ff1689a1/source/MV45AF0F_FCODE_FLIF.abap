*---------------------------------------------------------------------*
*       FORM FCODE_FLIF                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Lieferung aufrufen                          *
*---------------------------------------------------------------------*
FORM FCODE_FLIF.

  SET PARAMETER ID 'ALT' FIELD SPACE.                         "n_810897
  SET PARAMETER ID 'AUF' FIELD VBAK-VBELN.
  SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
  SET PARAMETER ID 'VTW' FIELD VBAK-VTWEG.
  SET PARAMETER ID 'SPA' FIELD VBAK-SPART.
  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                  AND PVPOS IS INITIAL.
ENHANCEMENT-POINT FCODE_FLIF_01 SPOTS ES_SAPMV45A.
    IF XVBAP-VSTEL NE SPACE.
      PERFORM XVBUP_LESEN(SAPFV45P) USING XVBAP-VBELN
                                          XVBAP-POSNR.
      IF NOT XVBUP-POSNR IS INITIAL.
        CHECK XVBUP-LFGSA CA 'AB' AND
              XVBUP-UPDKZ NE UPDKZ_DELETE.
      ELSE.
        CONTINUE.
      ENDIF.
      SET PARAMETER ID 'VST' FIELD XVBAP-VSTEL.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF R185D-DATALOSS NE SPACE.
    PERFORM BELEG_SICHERN USING CHARX
                                SY-SUBRC.
  ENDIF.
  set parameter id 'SD_METHOD_CALL' field ' '.

ENDFORM.