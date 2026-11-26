*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MAT_GRP_ANZEIG_SET_SE                             *
*----------------------------------------------------------------------*

MODULE MAT_GRP_ANZEIG_SET_SELKZ.
  DATA: DA_TABIX LIKE SY-TABIX,
        DA_SELKZ LIKE SELKZ_LISTE-SELKZ.
  DA_TABIX = TCTRL_MAT_GRP_ANZEIG_LIN1 + SY-STEPL - 1.
* Dynprodaten retten
  DA_SELKZ = SELKZ_LISTE-SELKZ.
* Wenn markiert alle anderen Materialien entmarkieren
  IF DA_SELKZ EQ CHARX.
    LOOP AT SELKZ_LISTE.
      CLEAR SELKZ_LISTE-SELKZ.
      MODIFY SELKZ_LISTE.
    ENDLOOP.
  ENDIF.
* Dynpro-Daten in interne Tabelle schreiben
  SELKZ_LISTE-TABIX = DA_TABIX.
  SELKZ_LISTE-SELKZ = DA_SELKZ.
  MODIFY SELKZ_LISTE INDEX DA_TABIX.
ENDMODULE.