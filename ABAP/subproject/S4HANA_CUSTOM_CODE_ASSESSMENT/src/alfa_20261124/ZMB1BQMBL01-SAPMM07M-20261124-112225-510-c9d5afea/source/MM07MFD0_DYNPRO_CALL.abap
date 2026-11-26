*eject
*---------------------------------------------------------------------*
*       FORM DYNPRO_CALL                                              *
*---------------------------------------------------------------------*
*       Ein CALL-Dynpro wird gerufen.                                 *
*       Je nach CALL-Code kann es erforderlich sein, nach der Rueck-  *
*       kehr aus dem POP-UP andere Verarbeitungsschritte durchzu-     *
*       fuehren. Dies wird ueber die Auspraegung des Feldes VW ge-    *
*       steuert.                                                      *
*---------------------------------------------------------------------*
FORM DYNPRO_CALL.
  CLEAR OLD_DYNNR.
  CHECK NOT CCODE IS INITIAL.
  CLEAR CCODE.
  DATA: WERKS LIKE RM07M-WERKS.
  WERKS = RM07M-WERKS.
  CALL SCREEN T063C-DYNNR STARTING AT T063C-WINX1 T063C-WINY1
                           ENDING  AT T063C-WINX2 T063C-WINY2.
  CCODE = T063C-CCODE_NEXT.
  IF NOT CCODE IS INITIAL AND T063C-XMODA IS INITIAL.
    SELECT SINGLE * FROM T063C WHERE CCODE = CCODE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH '063C' CCODE.
    ENDIF.
  ENDIF.
  IF RM07M-WERKS IS INITIAL AND RM07M-XAUSW IS INITIAL.
    RM07M-WERKS = WERKS.
  ENDIF.
ENDFORM.