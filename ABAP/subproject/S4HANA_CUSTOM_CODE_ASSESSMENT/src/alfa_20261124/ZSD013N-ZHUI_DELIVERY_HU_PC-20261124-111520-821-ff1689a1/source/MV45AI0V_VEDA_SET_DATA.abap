*eject
*---------------------------------------------------------------------*
*       MODULE VEDA_SET_DATA                                          *
*---------------------------------------------------------------------*
*       Daten für Includescreen vorbereiten                           *
*---------------------------------------------------------------------*
MODULE VEDA_SET_DATA.

  CHECK NOT TVAK-VTERL IS INITIAL.

  CALL FUNCTION 'SD_VEDA_SET_DATA'
       EXPORTING
            I_TVAK  = TVAK
       TABLES
            T_XVBUV = XVBUV
            T_HVBUV = HVBUV.

* Kopfvertragsdaten für späteren Vergleich merken
  PERFORM XVEDA_LESEN(SAPFV45P) USING *VEDA_K
                                VBAK-VBELN
                                POSNR_LOW
                                T180-TRTYP.

ENDMODULE.