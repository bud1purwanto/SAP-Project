*&---------------------------------------------------------------------*
*&      Form  VEDA_DATUM_PRUEFEN
*&---------------------------------------------------------------------*
*       Vertrasbeginn bzw. Vertragsende auf Position pruefen
*----------------------------------------------------------------------*
*  -->  veda-vbegdat
*       veda-venddat
*----------------------------------------------------------------------*
FORM VEDA_DATUM_PRUEFEN.

  DATA: DA_FEHGR LIKE TVAK-FEHGR.

  IF VBAP-POSNR EQ POSNR_LOW.
    DA_FEHGR = TVAK-FEHGR.
  ELSE.
    DA_FEHGR = TVAP-FEHGR.
  ENDIF.

  CALL FUNCTION 'SD_VEDA_CHECK_START_END_DATE'
       EXPORTING
            I_VEDA_VPOSN        = VBAP-POSNR
            I_VEDA_VBELN        = VBAK-VBELN
            I_VEDA_VBEGDAT      = VEDA-VBEGDAT
            I_VEDA_VENDDAT      = VEDA-VENDDAT
            I_TRTYP             = T180-TRTYP
            I_FEHGR             = DA_FEHGR
            I_DIALOG_INCOMPLETE = SPACE
       TABLES
            T_XVBUV             = XVBUV
            T_HVBUV             = HVBUV
       EXCEPTIONS
            OTHERS              = 1.

* Status bei Vertragsdatenänderung neu ermitteln
  CHECK VEDA NE *VEDA AND VBAP-POSNR NE POSNR_LOW.
  VBAP_ENDE_BEARBEITUNG = CHARX.

ENDFORM.