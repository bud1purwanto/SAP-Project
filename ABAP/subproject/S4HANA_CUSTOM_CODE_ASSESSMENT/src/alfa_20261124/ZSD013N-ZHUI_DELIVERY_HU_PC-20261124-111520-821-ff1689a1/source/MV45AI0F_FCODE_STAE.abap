*---------------------------------------------------------------------*
*     MODULE FCODE_Stae                                               *
*---------------------------------------------------------------------*
*       Änderungspopup für den Systemstatus ansteuern                 *
*---------------------------------------------------------------------*
MODULE FCODE_STAE.

  CHECK FCODE = 'STAE'.
ENHANCEMENT-SECTION     FCODE_STAE_01 SPOTS ES_SAPMV45A.
  CALL SCREEN 258
       STARTING AT 10 11
       ENDING   AT 70 14.
END-ENHANCEMENT-SECTION.
  IF FCODE = FCODE_ABBRECHEN.
    FCODE = FCODE_GLEICHE_SEITE.
  ENDIF.

ENDMODULE.