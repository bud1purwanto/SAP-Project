*---------------------------------------------------------------------*
*       FORM TVCOM_FILL_SIMULMODE                                     *
*---------------------------------------------------------------------*
*       Füllen Textkommunikationsblock                                *
*---------------------------------------------------------------------*
FORM TVCOM_FILL_SIMULMODE USING VALUE(LEVEL).

  DATA: DA_XVBAP LIKE XVBAP.

* Füllen Textkommunikationsblock
  CLEAR TVCOM.
  TVCOM-VKORG = VBAK-VKORG.
  TVCOM-VTWEG = VBAK-VTWEG.
  TVCOM-SPART = VBAK-SPART.
  TVCOM-KUNNR = VBAK-KUNNR.
  TVCOM-VKOSP = TVKO_SADR-SPRAS.

  TVCOM-SD_CALLER = CHARA.

  IF LEVEL = 'VBAK'.
* Füllen Textkommunikationsblock
    DA_XVBAP = XVBAP.
    READ TABLE XVBAP INDEX 1.
    TVCOM-VBELV = XVBAP-VGBEL.
    XVBAP = DA_XVBAP.

    TVCOM-POSNV = POSNR_LOW.
    TVCOM-VBELN = VBAK-VBELN.
    TVCOM-POSNN = POSNR_LOW.
    TVCOM-TXTGN = TVAK-TXTGR.
*   Userexit
    PERFORM USEREXIT_MOVE_FIELD_TO_TVCOM_H(SAPMV45A).

  ELSEIF LEVEL = 'VBAP'.
    TVCOM-VBELN = VBAK-VBELN.
    TVCOM-VBELV = VBAP-VGBEL.
    TVCOM-POSNV = VBAP-VGPOS.
*     Nur bei Ändern, sonst werden bei externer Nummernvergabe keine
*     Texte übernommen.
    TVCOM-TXTGN = TVAP-TXTGR.
    TVCOM-POSNN = VBAP-POSNR.
    TVCOM-MATNR = VBAP-MATNR.
*     Userexit
    PERFORM USEREXIT_MOVE_FIELD_TO_TVCOM_I(SAPMV45A).
  ENDIF.

ENDFORM.