*eject
*---------------------------------------------------------------------*
*       FORM FCODE_PRKL                                               *
*---------------------------------------------------------------------*
*       Übergang zum Löschen von unveränderten Positionen bei         *
*       der Rechnungskorrektur                                        *
*---------------------------------------------------------------------*
FORM FCODE_PRKL.
  DATA: BEGIN OF DA_ZVBAP OCCURS 0.
          INCLUDE STRUCTURE IVBAP.
  DATA: END OF DA_ZVBAP.

  DATA: BEGIN OF DA_COMP1,
          ZIEME LIKE VBAP-ZIEME,
          NETWR LIKE VBAP-NETWR,
          VGBEL LIKE VBAP-VGBEL,
          VGPOS LIKE VBAP-VGPOS,
        END   OF DA_COMP1.

  DATA: BEGIN OF DA_COMP2,
          ZIEME LIKE VBAP-ZIEME,
          NETWR LIKE VBAP-NETWR,
          VGBEL LIKE VBAP-VGBEL,
          VGPOS LIKE VBAP-VGPOS,
        END   OF DA_COMP2.

  DATA: SAV_TABIX LIKE SY-TABIX,
        DA_SHKZG1 LIKE VBAP-SHKZG,
        DA_SHKZG2 LIKE VBAP-SHKZG.
  DATA: DA_DELETE,
        DA_TABIX LIKE SY-TABIX.
  DATA: DA_VBAP LIKE VBAPVB.

*  Nur ausführen, wenn der VBTYP eine Gut- oder Lastschrift ist.
  CHECK VBAK-VBTYP = VBTYP_GANF OR VBAK-VBTYP = VBTYP_LANF.

  IF VBAK-VBTYP = VBTYP_GANF.
    MOVE CHARX TO DA_SHKZG1.
    MOVE SPACE TO DA_SHKZG2.
  ENDIF.
  IF VBAK-VBTYP = VBTYP_LANF.
    MOVE SPACE TO DA_SHKZG1.
    MOVE CHARX TO DA_SHKZG2.
  ENDIF.

* Selkz in der IVBAP initialisieren
  PERFORM IVBAP-SELKZ_INIT_ALLE(SAPFV45P).

  SAV_TABIX = 1.

* Lesen der XVBAP
  LOOP AT XVBAP FROM SAV_TABIX WHERE SHKZG = DA_SHKZG1.
    SAV_TABIX = SAV_TABIX + 1.
    MOVE-CORRESPONDING XVBAP TO DA_COMP1.
    IF DA_COMP1-NETWR LT 0.
      DA_COMP1-NETWR = -1 * DA_COMP1-NETWR.
    ENDIF.
    MOVE-CORRESPONDING XVBAP TO DA_ZVBAP.
    APPEND DA_ZVBAP.
    MOVE-CORRESPONDING XVBAP TO DA_VBAP.
*   Suchen nach Position mit gleicher VGBEL und VGPOS
    LOOP AT XVBAP  WHERE SHKZG =  DA_SHKZG2       AND
                         VGBEL =  DA_COMP1-VGBEL  AND
                         VGPOS =  DA_COMP1-VGPOS  AND
                         UPDKZ NE UPDKZ_DELETE.
      MOVE-CORRESPONDING XVBAP TO DA_COMP2.
      IF DA_COMP2-NETWR LT 0.
        DA_COMP2-NETWR = -1 * DA_COMP2-NETWR.
      ENDIF.
*     Wenn die Positionen unverändert sind, Eintrag in DA_ZVBAP
      IF DA_COMP1 EQ DA_COMP2.
        MOVE-CORRESPONDING XVBAP TO DA_ZVBAP.
        APPEND DA_ZVBAP.
      ELSE.
*     Wenn die Positionen verändert sind, wird DA_ZVBAP gelöscht
        REFRESH DA_ZVBAP.
        CLEAR DA_COMP1.
        CLEAR DA_COMP2.
*       check whether item is a subitem
        IF NOT XVBAP-UEPOS IS INITIAL.
*         is entry for upper item in ivbap marked for deletion?
          READ TABLE IVBAP WITH KEY POSNR = XVBAP-UEPOS.
          IF SY-SUBRC EQ 0 AND NOT IVBAP-SELKZ IS INITIAL.
*           upper item must not be deleted
            CLEAR IVBAP-SELKZ.
            MODIFY IVBAP INDEX SY-TABIX.
*           upper item for original entry must not be deleted, either
            READ TABLE IVBAP WITH KEY POSNR = DA_VBAP-UEPOS.
            IF SY-SUBRC EQ 0 AND NOT IVBAP-SELKZ IS INITIAL.
              CLEAR IVBAP-SELKZ.
              MODIFY IVBAP INDEX SY-TABIX.
            ENDIF.
*           check whether any entry will be deleted
            LOOP AT IVBAP WHERE NOT SELKZ IS INITIAL.
              EXIT.
            ENDLOOP.
            IF SY-SUBRC NE 0.
              CLEAR DA_DELETE.
            ENDIF.
          ENDIF.
        ENDIF.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF SY-SUBRC EQ 0.
*     Bei Wechsel, Prüfung, ob mehr als eine Position selektiert
*     Sollte es nur eine Position geben (manuell eingegeben), dann
*     darf diese nicht gelöscht werden.
      IF DA_COMP2 IS INITIAL.
        REFRESH DA_ZVBAP.
        CLEAR DA_COMP1.
      ELSE.
*       Schreiben SELKZ in IVBAP
        LOOP AT DA_ZVBAP.
          LOOP AT IVBAP WHERE POSNR = DA_ZVBAP-POSNR.
            MOVE CHARX TO IVBAP-SELKZ.
            MOVE CHARX TO DA_DELETE.
            MODIFY IVBAP.
          ENDLOOP.
        ENDLOOP.
        REFRESH DA_ZVBAP.
        CLEAR DA_COMP1.
        CLEAR DA_COMP2.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT IVBAP WHERE NOT SELKZ IS INITIAL.
    DA_TABIX = SY-TABIX.
* check sub items in IVBAP
    LOOP AT XVBAP WHERE POSNR = IVBAP-POSNR.
      IF NOT XVBAP-UEPOS IS INITIAL.
* => subitem => check if the main item is flagged for deletion
        READ TABLE IVBAP WITH KEY POSNR = XVBAP-UEPOS
                                  SELKZ = ' '
                                  TRANSPORTING NO FIELDS.
        IF SY-SUBRC EQ 0.
* main item not deleted => sub item must not be deleted
          CLEAR IVBAP-SELKZ.
          MODIFY IVBAP INDEX DA_TABIX.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* check whether any entry will be deleted
  LOOP AT IVBAP WHERE NOT SELKZ IS INITIAL.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    CLEAR DA_DELETE.
  ENDIF.

* check whether there are group conditions -> if there
* are some, new pricing is necessary before items are deleted
  LOOP AT XKOMV WHERE NOT KGRPE IS INITIAL.
    PERFORM PREISFINDUNG_GESAMT USING CHARA.
    EXIT.
  ENDLOOP.

  IF DA_DELETE IS INITIAL.
    MESSAGE I766.
  ELSE.
*   Löschen der unveränderten Positionen
    PERFORM XVBAP_LOESCHEN_LOOP(SAPFV45P).
  ENDIF.

* Konditionen fixieren, da nur noch veränderte Positionen im Beleg und
* vorher eventuell Gruppenkonditionen in Ansatz kamen.
  LOOP AT XKOMV.
    XKOMV-KSTEU = CHARE.
    MODIFY XKOMV.
  ENDLOOP.

ENDFORM.