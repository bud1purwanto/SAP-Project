*&---------------------------------------------------------------------*
*&      Module  VEDA_COMPLETENESS_H INPUT
*&---------------------------------------------------------------------*
*       Es wird die Vollständikeit der Vertragsdaten geprüft           *
*----------------------------------------------------------------------*
MODULE VEDA_COMPLETENESS_H INPUT.

  CHECK NOT TVAK-VTERL IS INITIAL.

* Prüfen ob sich Kopfvertragsdaten geändert haben
  PERFORM XVEDA_LESEN(SAPFV45P) USING VEDA
                                VBAK-VBELN
                                POSNR_LOW
                                T180-TRTYP.
  CHECK VEDA NE *VEDA_K.

  CALL FUNCTION 'SD_VEDA_CREATE'
       EXPORTING
            I_TRTYP             = T180-TRTYP
            I_PROFILE           = TVAK-VPROF
            I_VBELN             = VBAK-VBELN
            I_VPOSN             = POSNR_LOW
            I_UEPOS             = POSNR_LOW
            I_FEHGR             = TVAK-FEHGR
            I_DIALOG_INCOMPLETE = CHARX
            I_TVAK              = TVAK
       TABLES
            T_HVBUV             = HVBUV
            T_XVBUV             = XVBUV.

  PERFORM VEDA_CHECK_ITEM_COMPLETENESS.

ENDMODULE.                             " VEDA_COMPLETENESS  INPUT