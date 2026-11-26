*---------------------------------------------------------------------*
*       MODULE RV45A_RB_AUART_GROUP_CHECK INPUT                        *
*---------------------------------------------------------------------*
*       Prüfung ob die Auftragsart geändert werden darf               *
*---------------------------------------------------------------------*
MODULE RV45A_RB_AUART_GROUP_CHECK INPUT.

DATA: DA_AUART_ORG   LIKE TVAK-AUART,     " orginal Auftragsart
      DA_AAUART      LIKE TVAK-AUART,     " zu prüfende Auftragsart
      DA_AAUART1     LIKE TVAK-AAUART1,   " 1. alternative AUART
      DA_AAUART2     LIKE TVAK-AAUART2.   " 1. alternative AUART

  IF DA_AAUART IS INITIAL.
    DA_AUART_ORG   = TVAK-AUART.
    DA_AAUART1     = TVAK-AAUART1.
    DA_AAUART2     = TVAK-AAUART2.
  ENDIF.

* bei Ausgabe eines Errors aus VBAK_AAUART_PRUEFEN, muß die TVAK mit
* der Originalauftragsart gelesen werden
  IF NOT DA_AUART_ORG IS INITIAL AND
         DA_AUART_ORG NE TVAK-AUART.
    PERFORM TVAK_SELECT(SAPMV45A) USING DA_AUART_ORG
                                        CHARX
                                        SY-SUBRC.
    PERFORM TVAKT_SELECT(SAPMV45A) USING DA_AUART_ORG
                                         CHARX
                                         SY-SUBRC.
  ENDIF.

* Setzen der alternativen Auftragsart
   IF NOT RV45A-RB_AUART IS INITIAL.
     DA_AAUART = DA_AUART_ORG.
   ENDIF.
  IF NOT RV45A-RB_AAUART1 IS INITIAL.
    DA_AAUART = DA_AAUART1.
  ENDIF.
  IF NOT RV45A-RB_AAUART2 IS INITIAL.
    DA_AAUART = DA_AAUART2.
  ENDIF.
  PERFORM VBAK_AAUART_PRUEFEN(SAPFV45K) USING DA_AAUART.
  CLEAR DA_AAUART.

ENDMODULE.
