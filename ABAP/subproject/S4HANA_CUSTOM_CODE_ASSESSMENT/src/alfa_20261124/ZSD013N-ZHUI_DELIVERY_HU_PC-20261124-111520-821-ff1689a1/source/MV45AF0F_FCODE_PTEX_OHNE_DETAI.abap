*---------------------------------------------------------------------*
*       FORM FCODE_PTEX_OHNE_DETAIL                                   *
*---------------------------------------------------------------------*
*       Übergang zum Positionstextbild ohne XVBAP_DETAIL - Aufruf     *
*---------------------------------------------------------------------*
FORM FCODE_PTEX_OHNE_DETAIL.

  PERFORM XTHEAD_UEBERSICHT_P_ANSTEUERN(SAPFV45T)
                                       USING TVAP-TXTGR
                                             CHARA
                                             VBAK-VBELN
                                             VBAP-POSNR.

ENDFORM.