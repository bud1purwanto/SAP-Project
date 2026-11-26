*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MAT_GRP_ANZEIG_USER_C                             *
*----------------------------------------------------------------------*

MODULE MAT_GRP_ANZEIG_USER_COMMAND INPUT.
  DATA: DA_SELLINE LIKE SY-STEPL.

  CASE FCODE.
    WHEN 'ENTR' OR 'conu'.
* Auswahl ueber Selektionskennzeichen
      LOOP AT SELKZ_LISTE.
        IF SELKZ_LISTE-SELKZ EQ CHARX.
* ausgewähltes Material zurückgeben
          READ TABLE MAT_LISTE INDEX SY-TABIX.
          MAT_GRP_ANZEIG_KOPF-MATNR = MAT_LISTE-MATNR.
          MAT_GRP_ANZEIG_KOPF-VRKME = MAT_LISTE-VRKME.
          CLEAR FCODE.
          SET SCREEN 0. LEAVE SCREEN.
        ENDIF.
      ENDLOOP.
      MESSAGE I848.
* Doppelklick mit Maus auf Position
    WHEN 'PICK'.
* Zeile auf die geklickt wurde
      CLEAR DA_SELLINE.
      GET CURSOR LINE DA_SELLINE.
      DA_SELLINE = TCTRL_MAT_GRP_ANZEIG-TOP_LINE + DA_SELLINE - 1.
      IF DA_SELLINE GT 0.
        READ TABLE MAT_LISTE INDEX DA_SELLINE.
        IF SY-SUBRC = 0.
          MAT_GRP_ANZEIG_KOPF-MATNR = MAT_LISTE-MATNR.
          MAT_GRP_ANZEIG_KOPF-VRKME = MAT_LISTE-VRKME.
        ENDIF.
        CLEAR FCODE.
        SET SCREEN 0. LEAVE SCREEN.
      ENDIF.
    WHEN 'EXIT'.
      CLEAR FCODE.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CANC'.
      CLEAR FCODE.
      CLEAR MAT_GRP_ANZEIG_KOPF-MATNR.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CONA'.
      CLEAR FCODE.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CONB'.
      CLEAR FCODE.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'P--'.
      CLEAR FCODE.
      PERFORM TCTRL_MAT_GRP_ANZEIG_PAGING USING 'P--'.
    WHEN 'P-'.
      CLEAR FCODE.
      PERFORM TCTRL_MAT_GRP_ANZEIG_PAGING USING 'P-'.
    WHEN 'P+'.
      CLEAR FCODE.
      PERFORM TCTRL_MAT_GRP_ANZEIG_PAGING USING 'P+'.
    WHEN 'P++'.
      CLEAR FCODE.
      PERFORM TCTRL_MAT_GRP_ANZEIG_PAGING USING 'P++'.
  ENDCASE.
ENDMODULE.