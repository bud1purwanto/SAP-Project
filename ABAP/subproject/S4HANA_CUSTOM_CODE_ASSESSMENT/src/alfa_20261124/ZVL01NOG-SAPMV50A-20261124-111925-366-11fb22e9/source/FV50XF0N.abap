*----------------------------------------------------------------------*
*   INCLUDE FV50XF0N                                                   *
*       PERFORM  naturalrabatt_pruefen.
*       PERFORM  natrb_aendern.
*       PERFORM  natrb_loeschen.
*       PERFORM  natrb_aupstab_insert.
*       PERFORM  natrb_execute_status.
*       PERFORM  natrb_check_uepos_included.
*       PERFORM  natrb_execute_prio.
*       PERFORM  natrb_partial.
*       PERFORM  natrb_check_item_vbap.
*       PERFORM  natrb_check_item_lips.
*       PERFORM  natrb_check_item.
*       PERFORM  natrb_get_rule.
*       PERFORM  natrb_delete_item.
*       PERFORM  natrb_vorgaenger_xvbfa.
*----------------------------------------------------------------------*
TYPE-POOLS: vlkor.


*eject
*&---------------------------------------------------------------------*
*&      Form  NATURALRABATT_PRUEFEN
*&---------------------------------------------------------------------*
*      <->PVBAP    aktuelle Auftragspositionen, keine Veränderungen erw.
*      <->PT_ITEMS Tabelle, in der die Chargenhauptpositionen gesammelt
*                  werden, die gelöscht wurden, zum späteren löschen der
*                  evtl existierenden Splitpositionen
* folgende globale Variablen werden angesprochen:
*         lips-vgtyp
*         vbtyp_verk,    rvvbtyp
*         naturalrabatt, rvdirekt
*         xlikp-vbeln
*         xlips in gerufenen FORM's
*         xvbup in gerufenen FORM's
*         muß eine NR-Pos gelöscht werden, werden im xlips_löschen
*             alle möglichen Tabellen benötigt (ylips...)
*         bei Regel D NR Prio: im Korr_Menge_Setzen alle mögl. Tabellen
*----------------------------------------------------------------------*
FORM naturalrabatt_pruefen TABLES pvbap    STRUCTURE vbapvb
                                  pt_items TYPE      vlkor_items.

  STATICS aupstab TYPE vlkor_aupstab WITH HEADER LINE.
  DATA: lf_rule  LIKE vbap-uepvw,
        lf_lfsta LIKE vbup-lfsta,
        lf_incl,
        lf_status(10),
        lf_natrb_type LIKE vbap-uepvw,
        lf_nr_loeschen.

  DATA: ls_save_lips  LIKE lips,
        ls_save_lipsd LIKE lipsd,
        ls_save_xlips LIKE lipsvb,
        ls_save_ilips LIKE ilips,
        ls_save_slips LIKE slips,
        ls_save_vbap  LIKE vbapvb.

  CHECK strukturpflege_rekursiv_lips  IS INITIAL.

* Naturalrabatt nur für Aufträge implementiert
  CHECK NOT pvbap[] IS INITIAL.

  ls_save_lips  = lips.
  ls_save_lipsd = lipsd.
  ls_save_xlips = xlips.
  ls_save_ilips = ilips.
  ls_save_slips = slips.
  ls_save_vbap  = pvbap.

* Naturalrabatt-Auftragspositionen in aupstab aufnehmen
  PERFORM natrb_aupstab_insert TABLES aupstab cvbap.

  READ TABLE aupstab INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

* Naturalrabatt prüfen
  LOOP AT aupstab WHERE NOT lstanr IS INITIAL.              "nur NR-UPos
    CASE aupstab-lstanr.
*     Auslieferung erfolgt, wenn HP teilweise oder vollst. beliefert
      WHEN 'A' OR 'B'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ENDIF.
*     Auslieferung erfolgt wie bei A oder B, aber nur mit HPos zusammen
      WHEN 'C'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ELSE.
          PERFORM natrb_check_uepos_included USING    aupstab
                                             CHANGING lf_incl.
          IF lf_incl IS INITIAL.
            lf_nr_loeschen = 'X'.
          ENDIF.
        ENDIF.
*     Prio
*     WHEN 'D'.
*         PERFORM natrb_execute_prio TABLES pvbap aupstab.
*     Auslieferung NR Anteilig zur Hauptposition
      WHEN 'E'.
        PERFORM natrb_partial TABLES pvbap
                                     aupstab
                              USING  lf_nr_loeschen.
    ENDCASE.

    IF lf_nr_loeschen = 'X'.
      CLEAR lf_nr_loeschen.
      PERFORM natrb_delete_item TABLES pt_items
                                USING  xlikp-vbeln aupstab.
    ENDIF.
  ENDLOOP.

  lips  = ls_save_lips.
  lipsd = ls_save_lipsd.
  xlips = ls_save_xlips.
  ilips = ls_save_ilips.
  slips = ls_save_slips.
  pvbap = ls_save_vbap.

ENDFORM.                               " NATURALRABATT_PRUEFEN


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_aendern
*&---------------------------------------------------------------------*
FORM natrb_aendern TABLES  pvbap    STRUCTURE vbapvb
                           ct_items TYPE      vlkor_t_items.

  DATA: lf_natrb_type LIKE vbap-uepvw,
        lf_nr_loeschen,
        lf_incl,
        aupstab TYPE vlkor_aupstab WITH HEADER LINE.

  CHECK strukturpflege_rekursiv_lips  IS INITIAL.

* Naturalrabatt nur für Aufträge implementiert
  READ TABLE pvbap INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

* Naturalrabatt-Auftragspositionen in aupstab aufnehmen
  PERFORM natrb_aupstab_insert TABLES aupstab pvbap.

  READ TABLE aupstab INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

* Prüfen, ob aupstab auf NR-Unterposition positioniert ist.
  PERFORM natrb_check_item_vbap
                           TABLES   pvbap
                           USING    lips-vgbel lips-vgpos
                                    lips-uepvw lips-uepos
                           CHANGING lf_natrb_type.
  CHECK lf_natrb_type = 1.            "Nur weiter, wenn NR-Hauptposition

* Naturalrabatt prüfen
  LOOP AT xlips WHERE uepos = lips-posnr AND
                      vbeln = lips-vbeln AND
                      uecha IS INITIAL   AND
                      updkz <> updkz_delete.

    READ TABLE aupstab WITH KEY vbeln = xlips-vgbel
                                posnr = xlips-vgpos.
    CASE aupstab-lstanr.
*     Auslieferung erfolgt, wenn HP teilweise oder vollst. beliefert
      WHEN 'A' OR 'B'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ENDIF.
*     Auslieferung erfolgt wie bei A oder B, aber nur mit HPos zusammen
      WHEN 'C'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ELSE.
          PERFORM natrb_check_uepos_included USING    aupstab
                                             CHANGING lf_incl.
          IF lf_incl IS INITIAL.
            lf_nr_loeschen = 'X'.
          ENDIF.
        ENDIF.
*     Prio
*     WHEN 'D'.
*         PERFORM natrb_execute_prio TABLES pvbap aupstab.
*     Auslieferung NR Anteilig zur Hauptposition
      WHEN 'E'.
        PERFORM natrb_partial TABLES pvbap
                                     aupstab
                              USING  lf_nr_loeschen.
    ENDCASE.

    IF lf_nr_loeschen = 'X'.
      CLEAR lf_nr_loeschen.
      PERFORM natrb_delete_item TABLES ct_items
                                USING  likp-vbeln aupstab.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "natrb_aendern



*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_loeschen
*&---------------------------------------------------------------------*
FORM natrb_loeschen USING if_vbeln LIKE lips-vbeln
                          if_posnr LIKE lips-posnr
                          if_all   TYPE c.

  DATA: lf_natrb_type  LIKE vbap-uepvw,
        lf_nr_loeschen,
        lf_incl,
        aupstab TYPE vlkor_aupstab WITH HEADER LINE.

  CHECK strukturpflege_rekursiv_lips IS INITIAL.

* Naturalrabatt-Auftragspositionen in aupstab aufnehmen
  PERFORM natrb_aupstab_insert TABLES aupstab xvbap.

  READ TABLE aupstab INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

  READ TABLE xlips WITH KEY vbeln = if_vbeln
                            posnr = if_posnr.
  CHECK sy-subrc = 0.

  READ TABLE xvbap WITH KEY vbeln = xlips-vgbel
                            posnr = xlips-vgpos.
  CHECK sy-subrc = 0.

* Prüfen, ob aupstab auf NR-Hauptposition positioniert ist.
  PERFORM natrb_check_item_vbap
                           TABLES   xvbap
                           USING    xlips-vgbel xlips-vgpos
                                    xlips-uepvw xlips-uepos
                           CHANGING lf_natrb_type.
  CHECK lf_natrb_type = 1.             "1 = NR-Hauptposition

* Wenn NR-HPos, muß Upos mit gelöscht werden
  LOOP AT xlips WHERE updkz <> updkz_delete
                AND   vbeln = lips-vbeln
                AND   uepos = lips-posnr
*               and   uepvw ca naturalrabatt.
                AND   uepvw CA gc_uepvw-check_lstanr.

    READ TABLE aupstab WITH KEY vbeln = xlips-vgbel
                                posnr = xlips-vgpos.
    CASE aupstab-lstanr.
*     Auslieferung erfolgt, wenn HP teilweise oder vollst. beliefert
      WHEN 'A' OR 'B'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ENDIF.
*     Auslieferung erfolgt wie bei A oder B, aber nur mit HPos zusammen
      WHEN 'C'.
        IF aupstab-lfgsa CA aupstab-status.
          lf_nr_loeschen = 'X'.
        ELSE.
          PERFORM natrb_check_uepos_included USING    aupstab
                                             CHANGING lf_incl.
          IF lf_incl IS INITIAL.
            lf_nr_loeschen = 'X'.
          ENDIF.
        ENDIF.
*     Prio
*     WHEN 'D'. Keine Aktion. NR muß extra gelöscht werden.

*     Auslieferung NR Anteilig zur Hauptposition
      WHEN 'E'.
        lf_nr_loeschen = 'X'.
    ENDCASE.

    CHECK lf_nr_loeschen = 'X'.

    PERFORM message_handling(sapmv50a) USING lips-vgpos
                                             '271' 'I' 'VL'
                                             xlips-vbeln
                                             xlips-posnr
                                             xlips-lstanr space.
    lips = xlips.
    PERFORM xlips_loeschen(sapfv50p) USING if_all tabix_0.
  ENDLOOP.
  PERFORM ilips_aufbauen_alle(sapfv50p).

ENDFORM.                    "natrb_loeschen






*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_AUPSTAB_INSERT
*&---------------------------------------------------------------------*
*       Schreibt Infos von allen Naturalrabatts-Positionen der
*       übergebenen pvbap (Haupt- und Unterpositionen) in die AUPSTAB.
*       Auftragspositionstabelle pvbap
*----------------------------------------------------------------------*
*      <->P_AUPSTAB  Infos zur Naturalrabattsposition
*      <->P_PVBAP    aktuelle AuFTragspositionen;
*                    nur aus Performance per Referenz
*----------------------------------------------------------------------*
FORM natrb_aupstab_insert TABLES  aupstab TYPE vlkor_aupstab
                                  pvbap   STRUCTURE vbapvb.

  DATA: lf_vbeln LIKE lips-vbeln,
        lf_posnr LIKE lips-posnr,
        ls_vbap  LIKE xvbap.

  CLEAR   aupstab.
  REFRESH aupstab.
* Naturalrabatt-Positionen suchen
  LOOP AT xlips WHERE vbeln = xlikp-vbeln    AND
*                     UEPVW CA NATURALRABATT AND
                      uepvw CA gc_uepvw-check_lstanr AND
*                 NOT uepos IS INITIAL       AND
                      updkz <> updkz_delete.
*   Unterposition
    aupstab-mandt = xlips-mandt.
    aupstab-vbeln = xlips-vgbel.                            "v_n_925303
    aupstab-posnr = xlips-vgpos.                            "^_n_925303
    aupstab-grkor = xlips-grkor.
    aupstab-uepvw = xlips-uepvw.

    aupstab-uepos = xlips-vguepos.     "nur beim kopieren gefüllt
    IF aupstab-uepos IS INITIAL.                            "n_925303
      sy-subrc = 0.
      IF pvbap-vbeln <> xlips-vgbel
      OR pvbap-posnr <> xlips-vgpos.
        READ TABLE pvbap WITH KEY vbeln = xlips-vgbel
                                  posnr = xlips-vgpos.
      ENDIF.
      IF sy-subrc = 0.
        aupstab-uepos = pvbap-uepos.
      ENDIF.
*     Lines deleted n_925303
    ENDIF.

    aupstab-lstanr = xlips-lstanr.     "nur beim kopieren gefüllt
    IF aupstab-lstanr IS INITIAL.                           "n_925303
      sy-subrc = 0.
      IF pvbap-vbeln <> xlips-vgbel
      OR pvbap-posnr <> xlips-vgpos.
        READ TABLE pvbap WITH KEY vbeln = xlips-vgbel
                                  posnr = xlips-vgpos.
      ENDIF.
      IF sy-subrc = 0.
        aupstab-lstanr = pvbap-lstanr.
      ENDIF.
*     Lines deleted n_925303
    ENDIF.

    CASE aupstab-lstanr.
      WHEN 'A'.    aupstab-status = 'A'.
      WHEN 'B'.    aupstab-status = 'AB'.
      WHEN 'C'.    aupstab-status = 'A'.
      WHEN OTHERS. aupstab-status = space.
    ENDCASE.

    PERFORM korr_check_lieferrelevanz USING    aupstab-vbeln" n_925303
                                               aupstab-uepos
                                      CHANGING aupstab-lfgsa.
*   Lines deleted n_925303

    PERFORM korr_aupstab_insert TABLES aupstab.

*   zugehörige Hauptposition                                "v_n_925303
    PERFORM natrb_vorgaenger_xvbfa USING    xlips-vbeln xlips-uepos
                                            xlikp-vbtyp
                                   CHANGING aupstab-vbeln
                                            aupstab-posnr
                                            sy-subrc.
    IF sy-subrc <> 0 AND xlips-vgsys IS INITIAL.
      PERFORM natrb_uepos_vbap  TABLES   pvbap
                                USING    xlips-vgbel xlips-vgpos
                                CHANGING aupstab-posnr
                                         sy-subrc.
      IF sy-subrc = 0.
        aupstab-vbeln = xlips-vgbel.
      ELSE.
        aupstab-vbeln = space.
      ENDIF.
    ENDIF.                                                  "^_n_925303

    IF sy-subrc =  0.
      CLEAR: aupstab-uepos, aupstab-lstanr,  " Momentan keine Markierung
             aupstab-uepvw, aupstab-status,  " der NR-Hpos
             aupstab-lfgsa.
      PERFORM korr_aupstab_insert TABLES aupstab.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " NATRB_AUPSTAB_INSERT


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_EXECUTE_STATUS
*&---------------------------------------------------------------------*
*      <->PT_ITEMS  siehe NATRB_DELETE_ITEM
*      -->pv_vbeln  Aktuell bearbeitete Lieferungsnummer
*      -->AUPSTAB   NR-Upos im Auftrag, die geprüft wird
*      -->PV_STATUS siehe NATRB_GET_RULE
*----------------------------------------------------------------------*
FORM natrb_execute_status TABLES   pt_items        TYPE vlkor_items
                          USING    value(pv_vbeln) LIKE likp-vbeln
                                   value(aupstab)  TYPE vlkor_s_aupstab
                                   value(pv_status).

  DATA: lf_lfgsa LIKE vbup-lfgsa.

  CHECK aupstab-lfgsa <> space.        "Nicht lieferrelevant
  IF aupstab-lfgsa CA pv_status.
*   Lieferstatus der NR-Hpos führt zum Löschen der NR-Upos.
    PERFORM natrb_delete_item TABLES pt_items
                              USING  pv_vbeln
                                     aupstab.
  ENDIF.
ENDFORM.                               " NATRB_EXECUTE_STATUS


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_CHECK_UEPOS_INCLUDED
*&---------------------------------------------------------------------*
* Prüfung, ob die aktuell zu prüfende NR-Upos in AUPSTAB
* eine NR-Hpos im Auftrag hat, die auch in der aktuellen Lieferung
* enthalten ist.
*
* Also: ob NR-Unter- und NR_Hauptposition gemeinsam in einer Liefrung
*       sind, unabhängig von den Mengen (auch 0-Mengen zählen als
*       existent).
*&---------------------------------------------------------------------*
FORM natrb_check_uepos_included
                      USING value(aupstab) TYPE vlkor_s_aupstab
                      CHANGING cf_incl     TYPE c.

  READ TABLE xvbfa WITH KEY mandt = sy-mandt
                            vbelv = aupstab-vbeln
                            posnv = aupstab-uepos
                            vbeln = xlikp-vbeln
                            vbtyp_n = xlikp-vbtyp
                   BINARY SEARCH
                   TRANSPORTING NO FIELDS.

  IF sy-subrc = 0.
    cf_incl = charx.
  ELSE.
    cf_incl = space.
  ENDIF.

ENDFORM.                               " NATRB_CHECK_UEPOS_INCLUDED


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_EXECUTE_PRIO
*&---------------------------------------------------------------------*
*       Naturalrabatt mit Priorität ausliefern,
*       wenn Draufgabe von gleichem Material.
*----------------------------------------------------------------------*
*  -->  pvbap     aktuelle Auftragspositionen
*  <--  auapstab  alle NR-Positionen
*----------------------------------------------------------------------*
FORM natrb_execute_prio TABLES pvbap   STRUCTURE vbapvb
                               aupstab TYPE      vlkor_aupstab.

  DATA: lf_natrb_type LIKE vbap-uepvw,
        ls_aups       TYPE vlkor_s_aupstab,
        ls_lips_hpos  TYPE vlkor_s_xlips,
        ls_lips_upos  TYPE vlkor_s_xlips,
        lf_gesamt_ofmng   LIKE xlips-ofmng,
        lf_gesamt_lfimg   LIKE xlips-lfimg_flo,
        lf_upos_lfimg_new LIKE xlips-lfimg,
        lf_hpos_lfimg_new LIKE xlips-lfimg,
        lf_upos_tabix LIKE sy-tabix,
        lf_hpos_tabix LIKE sy-tabix.

* Priorisierung nur für Draufgaben, Dreingaben besser als Gutschrift
  CHECK aupstab-uepvw = natrab_drauf.

* Prüfen, ob aupstab auf NR-Unterposition positioniert ist.
  PERFORM natrb_check_item_vbap
                           TABLES   pvbap
                           USING    aupstab-vbeln aupstab-posnr
                                    aupstab-uepvw aupstab-uepos
                           CHANGING lf_natrb_type.
  CHECK lf_natrb_type = 2.             "Keine NR-Unterposition

* Zugehörige NR-Haupstposition dazu lesen
  READ TABLE aupstab INTO ls_aups
                     WITH KEY vbeln = aupstab-vbeln
                              posnr = aupstab-uepos.

* Alle zugehörigen NR-Unterpositionen in aktueller Lieferung bearbeiten
  LOOP AT xlips INTO ls_lips_upos
                WHERE vbeln = xlikp-vbeln
                  AND vgbel = aupstab-vbeln
                  AND vgpos = aupstab-posnr
                  AND NOT uepos IS INITIAL
                  AND (  updkz = updkz_update
                      OR updkz = updkz_new ).
    lf_upos_tabix = sy-tabix.

*   NR-Hauptposition in Lieferung dazu lesen
    READ TABLE xlips INTO ls_lips_hpos
                     WITH KEY vbeln = xlikp-vbeln
                              posnr = ls_lips_upos-uepos.
    lf_hpos_tabix = sy-tabix.

    IF sy-subrc <> 0 OR ls_lips_hpos-updkz = updkz_delete.
      CONTINUE.              "Hpos nicht da. Priorisierung nicht möglich
    ENDIF.

*   Priorisierung nur für gleiches Material möglich
    CHECK ls_lips_hpos-matnr = ls_lips_upos-matnr.

    lf_gesamt_ofmng = ls_lips_hpos-ofmng + ls_lips_upos-ofmng.

*   Mengenverteilung nur nötig,   wenn Upos noch nicht voll beliefert
*                und nur möglich, wenn Hpos etwas hat.
    CHECK ls_lips_upos-lfimg < ls_lips_upos-ofmng AND                "#&
          ls_lips_hpos-lfimg > 0.      "#&

*   Mengenverteilung nur bei gleichen Mengeneinheiten zulässig
    CHECK ls_lips_hpos-vrkme = ls_lips_upos-vrkme.

*   Neue Mengen berechnen
    lf_gesamt_lfimg = ls_lips_hpos-lfimg_flo + ls_lips_upos-lfimg_flo."&

    IF lf_gesamt_lfimg <= ls_lips_upos-ofmng.                        "#&
      lf_upos_lfimg_new = lf_gesamt_lfimg.                           "#&
      lf_hpos_lfimg_new = 0.           "#&
    ELSE.
      lf_upos_lfimg_new = ls_lips_upos-ofmng.                        "#&
      lf_hpos_lfimg_new = lf_gesamt_lfimg - ls_lips_upos-ofmng.      "#&
    ENDIF.

*   Hauptposition Menge reduzieren, Unterposition Menge erhöhen
    CHECK lf_upos_lfimg_new > ls_lips_upos-lfimg.                    "#&
    READ TABLE xlips INDEX lf_hpos_tabix.
    lips = xlips.
    strukturpflege_rekursiv_lips = charx.
    PERFORM korr_menge_setzen(sapmv50a) USING lf_hpos_tabix
                                              lf_hpos_lfimg_new.     "#&

    READ TABLE xlips INDEX lf_upos_tabix.
    lips = xlips.
    PERFORM korr_menge_setzen(sapmv50a) USING lf_upos_tabix
                                              lf_upos_lfimg_new.     "#&
    strukturpflege_rekursiv_lips = space.
  ENDLOOP.
ENDFORM.                               " NATRB_EXECUTE_PRIO


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_CHECK_ITEM_VBAP
*&---------------------------------------------------------------------*
*  Ermitteln, ob eine Naturalrabatt-Auftragsposition
*  Haupt- oder Unterposition ist.
*
*      <->pvbap    = alle aktuelle Auftragspositionen, nur aus
*                    Performancegründen per Referenz
*      -->pv_vbeln = zu prüfende Auftragsnummer
*      -->pv_posnr = zu prüfende Positionsnummer im Auftrag pv_vbeln
*      -->pv_uepvw = zu prüfende Verwendung  Lieferung/Auftrag
*      -->pv_uepos = Uebergeordente Position Lieferung/Auftrag
*      <->pv_rc    = 0 keine Naturalrabatts-Position
*                    1 Naturalrabatt-Unterposition
*                    2 Naturalrabatt-Hauptposition
* Ablauf:
* Zuerst wird geprüft, ob pv_uepvw und pv_uepos auf NR hinweisen.
*
* Wenn nicht wird in der übergebenen Auftragspositionstabelle pvbap
* gesucht, ob es im Auftrag pv_vbeln eine Unterposition gibt, die als
* NR markiert ist und als Überposition pv_posnr hat (D.h. die übergebene
* Position ist eine NR-Hauptposition, war aber selbst nicht als solche
* markiert).
*----------------------------------------------------------------------*
FORM natrb_check_item_vbap TABLES   pvbap STRUCTURE vbapvb
                           USING    value(pv_vbeln) LIKE vbap-vbeln
                                    value(pv_posnr) LIKE vbap-posnr
                                    value(pv_uepvw) LIKE vbap-uepvw
                                    value(pv_uepos) LIKE vbap-uepos
                           CHANGING pv_natrb_type   LIKE vbap-uepvw.

  DATA: ls_vbap LIKE pvbap.

  PERFORM natrb_check_item USING    pv_uepvw pv_uepos
                           CHANGING pv_natrb_type.
  CHECK pv_natrb_type IS INITIAL.

* In VBAP suchen, ob zur übergebenen Position eine NR-Upos existiert
  LOOP AT pvbap INTO ls_vbap
                WHERE vbeln =  pv_vbeln
                AND   uepos =  pv_posnr
*               AND   UEPVW CA NATURALRABATT.
                AND   uepvw CA gc_uepvw-check_lstanr.
    EXIT.                "Im Auftrag existiert eine NR-Unterposition zur
    "aktuellen Lips-Vorgängerposition,
    "dh.aktuelle Lips ist NR-Hauptposition
  ENDLOOP.
  IF sy-subrc = 0.
    pv_natrb_type = 1. EXIT.           "Hauptposition
  ELSE.
    CLEAR  pv_natrb_type.     EXIT.    "Kein Naturalrabatt
  ENDIF.

ENDFORM.                               " NATRB_CHECK_ITEM_VBAP


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_CHECK_ITEM_LIPS
*&---------------------------------------------------------------------*
*  wie NATRB_CHECK_ITEM_VBAP, jedoch wird in der LIPS nach der
*  NR-Hauptposition gesucht.
*----------------------------------------------------------------------*
FORM natrb_check_item_lips TABLES   plips STRUCTURE lipsvb
                           USING    value(pv_vbeln) LIKE lips-vbeln
                                    value(pv_posnr) LIKE lips-posnr
                                    value(pv_uepvw) LIKE lips-uepvw
                                    value(pv_uepos) LIKE lips-uepos
                           CHANGING pv_natrb_type   LIKE vbap-uepvw.

  DATA: ls_lips LIKE plips.

  PERFORM natrb_check_item USING    pv_uepvw pv_uepos
                           CHANGING pv_natrb_type.
  CHECK pv_natrb_type IS INITIAL.

* In LIPS suchen, ob zur übergebenen Position eine NR-Upos existiert
  LOOP AT plips INTO ls_lips
                WHERE vbeln =  pv_vbeln
                AND   uepos =  pv_posnr
*               AND   UEPVW CA NATURALRABATT.
                AND   uepvw CA gc_uepvw-check_lstanr.
    EXIT.                     "Zur LIPS existiert eine NR-Unterposition
  ENDLOOP.
  IF sy-subrc = 0.
    pv_natrb_type = 1. EXIT.           "Hauptposition
  ELSE.
    CLEAR  pv_natrb_type.     EXIT.    "Kein Naturalrabatt
  ENDIF.

ENDFORM.                               " NATRB_CHECK_ITEM_LIPS


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_CHECK_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PVBAP  text                                                *
*      -->P_PV_UEPVW  text                                             *
*      -->P_PV_UEPOS  text                                             *
*      <--P_PV_NATRB_TYPE  text                                        *
*----------------------------------------------------------------------*
FORM natrb_check_item USING    pv_uepvw      LIKE lips-uepvw
                               pv_uepos      LIKE lips-uepos
                      CHANGING pv_natrb_type LIKE lips-uepvw.
  CLEAR pv_natrb_type.
* IF PV_UEPVW CA NATURALRABATT.
  IF pv_uepvw CA gc_uepvw-check_lstanr.
    IF pv_uepos IS INITIAL.
      pv_natrb_type = 1. EXIT.         "NR-Hauptposition
    ELSE.
      pv_natrb_type = 2. EXIT.         "NR-Unterposition
    ENDIF.
  ENDIF.
ENDFORM.                               " NATRB_CHECK_ITEM


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_GET_RULE
*&---------------------------------------------------------------------*
*  -->  pvbap     Auftragspositionen
*  -->  pv_vbeln  Beleg-...
*  -->  pv_ponsr  ...  -Position, deren Naturalrabatt-Regel gesucht wird
*  <--  pv_rule   Regel, wie der Naturalrabatt behandelt werden soll.
*                 Nun in Festwert der Domäne STATVNR hinterlegt
*  <--  pv_status Bei Regeln A, B, C genügt der Status der NR-Hpos,
*                 um entscheiden zu können, ob die NR-Upos geliefert
*                 werden darf. Hier werden die Status der NR-Hpos
*                 bestimmt, bei denen man die NR-Upos nicht ausliefert.
*----------------------------------------------------------------------*
FORM natrb_get_rule TABLES   pvbap STRUCTURE vbapvb
                    USING    value(pv_vbeln) LIKE vbap-vbeln
                             value(pv_posnr) LIKE vbap-posnr
                    CHANGING pv_rule         TYPE c
                             pv_status       TYPE c.

  STATICS: ss_vbap LIKE pvbap.

  IF ss_vbap-vbeln <> pv_vbeln OR
     ss_vbap-posnr <> pv_posnr.
    READ TABLE pvbap INTO ss_vbap
                     WITH KEY vbeln = pv_vbeln
                              posnr = pv_posnr
                     TRANSPORTING vbeln posnr lstanr.
  ENDIF.
  pv_rule = ss_vbap-lstanr.

* Regel umsetzen in Status
  CASE pv_rule.
    WHEN 'A'.    pv_status = 'A'.
    WHEN 'B'.    pv_status = 'AB'.
    WHEN 'C'.    pv_status = 'A'.
    WHEN OTHERS. pv_status = space.
  ENDCASE.

ENDFORM.                               " NATRB_GET_RULE


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_DELETE_ITEM
*&---------------------------------------------------------------------*
*       Löscht alle NR-Unterpositonen die in der aktuellen Lieferung
*       angefaßt wurden und zur übergebenen aupstab gehören.
*  --> pv_vbeln aktuelle Lieferungsnummer
*  <-> aupstab  Struktur mit info zur NR-Unterposition, deren Folge-
*               lieferpositionen gelöscht werden sollen.
*  <-> pt_items Ranges-Tabelle die ChargenHauptPositionen enthält,
*               welche gelöscht wurden. Deren Split-Positionen
*               müssen später auch noch gelöscht werden.
*               Dies sollte am Ende der Liefergruppen-Komplett-Prüfung
*               passieren. Dort ist auch gewährleistet, daß die
*               Lieferungsnummer noch stimmt.
*----------------------------------------------------------------------*
FORM natrb_delete_item TABLES pt_items        TYPE vlkor_items
                       USING  value(pv_vbeln) LIKE lips-vbeln
                              value(aupstab)  TYPE vlkor_s_aupstab.
  DATA: lf_tabix LIKE sy-tabix.
  DATA: ls_save_lips LIKE lips.                             "46A

  IF v50agl-sammelgang = space.
    PERFORM message_handling(sapmv50a)
                        USING aupstab-uepos '261' 'I' 'VL'
                              aupstab-uepos space space space.
  ELSE.
    likp = xlikp.
    ls_save_lips = lips.                                    "46A
*   Naturalrabatt-Unterposition löschen
    LOOP AT xlips WHERE vbeln =  pv_vbeln      AND
                        vgbel =  aupstab-vbeln AND    "Auftragsnummer
                        vgpos =  aupstab-posnr AND    "Auftragsposition
*                   NOT uepos IS INITIAL       AND    "Nur UPos löschen
                        updkz <> space         AND
                        updkz <> updkz_delete.
      lf_tabix = sy-tabix.
      PERFORM korr_check_chp_collect TABLES pt_items
                                     USING  xlips.
      lips = xlips.                                         "46A
      PERFORM xlips_loeschen(sapfv50p) USING charx lf_tabix.
    ENDLOOP.
    lips = ls_save_lips.                                    "46A

    IF sy-subrc = 0.
      PERFORM message_handling(sapmv50a)
                          USING aupstab-uepos '260' 'E' 'VL'
                                aupstab-uepos space space space.
    ENDIF.

    MOVE-CORRESPONDING likp TO xlikp.
    IF v50agl-sammelgang = charx.
      MODIFY xlikp.
    ENDIF.
  ENDIF.

ENDFORM.                               " NATRB_DELETE_ITEM


*eject
*&---------------------------------------------------------------------*
*&      Form  NATRB_VORGAENGER_XVBFA
*&---------------------------------------------------------------------*
*       Ermittelt zu einer übergebenen VertriebsbelegPosition mit VBTYP
*       die VorgängerbelegPosition aus der xvbfa
*----------------------------------------------------------------------*
*      -->P_XLIPS_VBELN  Lieferungsnummer                              *
*      -->P_XLIPS_POSNR  Lieferungsposition                            *
*      -->P_XLIKP_VBTYP  Lieferungs-VBTYP                              *
*      <--P_AUPSTAB_VBELV  Vorgänger-Belegnummer                       *
*      <--P_AUPSTAB_POSNV  Vorgänger-Position                          *
*----------------------------------------------------------------------*
FORM natrb_vorgaenger_xvbfa USING    value(if_vbeln) LIKE vbfa-vbeln
                                     value(if_posnr) LIKE vbfa-posnn
                                     value(if_vbtyp) LIKE vbfa-vbtyp_n
                            CHANGING       cf_vbelv  LIKE vbfa-vbelv
                                           cf_posnv  LIKE vbfa-posnv
                                     value(cf_subrc) LIKE sy-subrc.
  DATA  ls_vbfa  LIKE xvbfa.

  READ TABLE xvbfa INTO ls_vbfa
                   WITH KEY vbeln   = if_vbeln
                            posnn   = if_posnr
                            vbtyp_n = if_vbtyp
                   TRANSPORTING vbelv posnv.
  cf_subrc = sy-subrc.

  IF sy-subrc = 0.
    cf_vbelv = ls_vbfa-vbelv.
    cf_posnv = ls_vbfa-posnv.
  ELSE.
    CLEAR cf_vbelv.
    CLEAR cf_posnv.
  ENDIF.

ENDFORM.                               " NATRB_VORGAENGER_XVBFA


*&---------------------------------------------------------------------*
*&      Form  NATRB_VORGAENGER_VBAP
*&---------------------------------------------------------------------*
*       Ermittelt zu einer übergebenen LieferungsPosition
*       die VorgängerbelegPosition aus der vbap
*----------------------------------------------------------------------*
FORM natrb_uepos_vbap  TABLES   it_vbap         STRUCTURE vbapvb
                       USING    value(if_vbeln) LIKE      vbap-vbeln
                                value(if_posnr) LIKE      vbap-posnr
                       CHANGING value(cf_uepos) LIKE      vbap-uepos
                                value(cf_subrc) LIKE      sy-subrc.
  DATA  ls_vbap LIKE xvbap.

  READ TABLE it_vbap INTO ls_vbap
                   WITH KEY vbeln   = if_vbeln
                            posnr   = if_posnr
                   TRANSPORTING uepos.
  cf_subrc = sy-subrc.
  IF sy-subrc = 0.
    cf_uepos = ls_vbap-uepos.
  ELSE.
    cf_uepos = space.
  ENDIF.

ENDFORM.                               " NATRB_VORGAENGER_VBAP


*&---------------------------------------------------------------------*
*&      Form  NATRB_PARTIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUPSTAB  text                                              *
*      -->P_LF_NR_LOESCHEN  text                                       *
*----------------------------------------------------------------------*
FORM natrb_partial TABLES pvbap          STRUCTURE vbapvb
                          aupstab        TYPE      vlkor_aupstab
                   USING  cf_nr_loeschen TYPE      c.

  DATA: lf_natrb_type LIKE vbap-uepvw,
        ls_aups       TYPE vlkor_s_aupstab,
        ls_lips_hpos  TYPE vlkor_s_xlips,
        ls_lips_upos  TYPE vlkor_s_xlips,
        lf_lfgsa          LIKE xvbup-lfgsa,
        lf_gesamt_lfimg   LIKE xlips-lfimg_flo,
        lf_upos_lfimg_new LIKE xlips-lfimg_flo,
        lf_hpos_lfimg_new LIKE xlips-lfimg_flo,
        lf_lfimg          LIKE xlips-lfimg,
        lf_lfimg_flo      LIKE xlips-lfimg_flo,
        lf_lgmng          LIKE xlips-lgmng,
        lf_lgmng_flo      LIKE xlips-lgmng_flo,
        lf_gesamt_lsmeng  LIKE xvbap-lsmeng,
        lf_upos_lsmeng    LIKE vbap-lsmeng,
        lf_hpos_lsmeng    LIKE vbap-lsmeng,
        lf_upos_vrkme     LIKE vbap-vrkme,
        lf_hpos_vrkme     LIKE vbap-vrkme,
        lf_upos_tabix LIKE sy-tabix,
        lf_hpos_tabix LIKE sy-tabix,
        lf_incl,
        a TYPE f,
        b TYPE f,
        c TYPE f,
        x TYPE f,
        y TYPE f.

  DATA:
    lf_round_sign_natrb_upos TYPE rndsg
  , lf_round_sign_natrb_hpos TYPE rndsg
  .

  DATA: lf_menge     LIKE lips-lfimg,                       "v_n_656454
        lf_b         LIKE lips-lfimg,
        lf_mchar(19) TYPE c.                                "^_n_656454



* Wenn die NR-Hpos nicht in der Lieferung enthalten ist wird
* entweder die UPos
* - beim Anlegen mit allem Verfügbaren ausgeliefert, wenn HPos
*   erledigt ist oder
* - nicht erzeugt/gelöscht
  PERFORM korr_check_lieferrelevanz USING aupstab-vbeln aupstab-uepos
                                    CHANGING lf_lfgsa.
  PERFORM natrb_check_uepos_included USING    aupstab
                                     CHANGING lf_incl.

  IF lf_incl IS INITIAL.               "NR-HPos nicht in der LF drin
    IF     v50agl-kopieren    = charx  "anlegen
    AND    lf_lfgsa    CA 'C'.         "Auftragspos. erledigt
      EXIT.                            "alles liefern
    ELSEIF lf_lfgsa    CA ' AB'.
      cf_nr_loeschen = 'X'.
      EXIT.                            "löschen
    ENDIF.
  ENDIF.

* Prüfen, ob aupstab auf NR-Unterposition positioniert ist.
  PERFORM natrb_check_item_vbap
                           TABLES   pvbap
                           USING    aupstab-vbeln aupstab-posnr
                                    aupstab-uepvw aupstab-uepos
                           CHANGING lf_natrb_type.
  CHECK lf_natrb_type = 2.            "Nur weiter, wenn NR-Unterposition

* Zugehörige NR-Haupstpositions-Aupstab dazu lesen
  READ TABLE aupstab INTO ls_aups
                     WITH KEY vbeln = aupstab-vbeln
                              posnr = aupstab-uepos.

* Alle NR-Unterpositionen berarbeiten mit Aupstab-NR-Upos als Vorgänger
  LOOP AT xlips INTO  ls_lips_upos
                WHERE vbeln = xlikp-vbeln
                  AND vgbel = aupstab-vbeln
                  AND vgpos = aupstab-posnr
*                 AND NOT uepos IS INITIAL
                  AND     uecha IS INITIAL
                  AND (  updkz = updkz_update
                      OR updkz = updkz_new
                      OR updkz = space ).

    lf_upos_tabix = sy-tabix.

*   NR-Hauptposition in Lieferung dazu lesen
    LOOP AT xlips INTO  ls_lips_hpos
                  WHERE vbeln EQ xlikp-vbeln AND
                        posnr EQ ls_lips_upos-uepos AND
                        updkz NE updkz_delete.
      lf_hpos_tabix = sy-tabix.                               "n_628546
      EXIT.
    ENDLOOP.

    IF sy-subrc <> 0.                                       "v_n_628546
      lf_hpos_tabix = sy-tabix.
    ENDIF.                                                  "^_n_628546

*   Mengen bestimmen: Verhältnis im Auftrag
    PERFORM korr_vorgaenger_lsmeng(sapmv50a)
                            TABLES pvbap
                            USING  ls_lips_hpos-vgtyp
                                   ls_lips_hpos-vgbel
                                   ls_lips_hpos-vgpos
                            CHANGING    lf_hpos_lsmeng
                                        lf_hpos_vrkme.


    PERFORM korr_vorgaenger_lsmeng(sapmv50a)
                            TABLES pvbap
                            USING  ls_lips_upos-vgtyp
                                   ls_lips_upos-vgbel
                                   ls_lips_upos-vgpos
                            CHANGING    lf_upos_lsmeng
                                        lf_upos_vrkme.

    lf_gesamt_lsmeng = lf_hpos_lsmeng + lf_upos_lsmeng.
    IF lf_gesamt_lsmeng <= 0.          "Sonst Division durch Null
      EXIT.
    ENDIF.

*   Mengenverteilung nur bei gleichen Mengeneinheiten in Hpos und Upos
*   Auftrags-vrkme und Lieferungs-Vrkme darf unterschiedlich sein
    IF ls_lips_hpos-vrkme <> ls_lips_upos-vrkme.

      PERFORM round_sign_determine
              USING    ls_lips_hpos
              CHANGING lf_round_sign_natrb_hpos.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input         = ls_lips_hpos-lfimg  "#&
          no_type_check = charx
          round_sign    = lf_round_sign_natrb_hpos
          unit_in       = ls_lips_hpos-vrkme
          unit_out      = ls_lips_upos-vrkme
        IMPORTING
          output        = ls_lips_hpos-lfimg  "#&
        EXCEPTIONS
          OTHERS        = 99.
      ls_lips_hpos-vrkme = ls_lips_upos-vrkme.
    ENDIF.


*   Konvertierung in Float
*   Zu prüfende Mengen berechnen
    lips = ls_lips_hpos.
    PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
            CHANGING lf_lfimg
                     lf_lfimg_flo
                     lf_lgmng
                     lf_lgmng_flo.

    a = lf_gesamt_lfimg = lf_lfimg.

    lips = ls_lips_upos.
    PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
            CHANGING lf_lfimg
                     lf_lfimg_flo
                     lf_lgmng
                     lf_lgmng_flo.

    lf_gesamt_lfimg = lf_gesamt_lfimg + lf_lfimg.
    c = lf_gesamt_lfimg.               "#&
    x = lf_hpos_lsmeng.
    y = lf_upos_lsmeng.

*   Beim Anlegen keine Verteilung für Draufgabe mit gleichem Material
    IF ls_lips_upos-matnr <> ls_lips_hpos-matnr OR
*      slips-tabix <> 0.
       ls_lips_upos-updkz <> updkz_new OR
       ls_lips_hpos-updkz <> updkz_new OR
       v50agl-kopieren    <> charx.

*     Nur NR-UPos Menge gemäß Auftragsverhältnis setzen.
*     a = ls_lips_hpos-lfimg.
      IF y = 0.
        b = 0.
      ELSE.
*       x / y  = a / b   Auftrags-Verhältnis = Lieferverhältnis
        b = a * y / x.

        PERFORM round_sign_determine
                USING    ls_lips_upos
                CHANGING lf_round_sign_natrb_upos.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input         = b
            no_type_check = charx
            round_sign    = lf_round_sign_natrb_upos
            unit_in       = lf_upos_vrkme
            unit_out      = lf_upos_vrkme
          IMPORTING
            output        = b
          EXCEPTIONS
            OTHERS        = 99.
      ENDIF.
* Check whether free goods is already packed
      PERFORM xvbup_lesen(sapfv50p) USING likp-vbeln        "v_n_656454
                                      lips-posnr.
      IF xvbup-pksta NE space.
        PERFORM xvbapf_lesen(sapfv50p) USING likp-vbeln
                                             lips-posnr
                                             sy-subrc.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
              matnr                = ls_lips_upos-matnr
              meinh                = lf_upos_vrkme
              meins                = ls_lips_upos-meins
              input                = xvbapf-xmenge
              werks                = ls_lips_upos-werks
          IMPORTING
              output               = lf_menge
          EXCEPTIONS
              conversion_not_found = 01
              input_invalid        = 02
              material_not_found   = 03
              meinh_not_found      = 04
              meins_missing        = 05
              no_meinh             = 06
              output_invalid       = 07
              overflow             = 08.
        lf_b = b.
        IF lf_menge GT lf_b.
          WRITE lf_menge LEFT-JUSTIFIED NO-GAP
                TO lf_mchar UNIT lf_upos_vrkme.
          PERFORM message_handling(sapmv50a) USING lips-posnr
                                                   '616'
                                                   'W'
                                                   'VL'
                                                   lf_mchar
                                                   lf_upos_vrkme
                                                   space
                                                   space.
          EXIT.
        ENDIF.
* restore former xvbapf
        PERFORM xvbapf_lesen(sapfv50p) USING lips-vbelv
                                             lips-uepos
                                             sy-subrc.
      ENDIF.
* restore former xvbup
      PERFORM xvbup_lesen(sapfv50p) USING lips-vbelv
                                          lips-uepos.       "^_n_656454
      lf_upos_lfimg_new = b.           "#&
*     Unterposition reduzierte Menge neu setzen
*     IF lf_upos_lfimg_new <> ls_lips_upos-lfimg.
      lips = ls_lips_upos.
      PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
              CHANGING lf_lfimg
                       lf_lfimg_flo
                       lf_lgmng
                       lf_lgmng_flo.
      IF  lf_upos_lfimg_new   <> lf_lfimg
      AND ls_lips_upos-kcmeng  = 0.

        READ TABLE xlips INDEX lf_upos_tabix.
        lips = xlips.
        strukturpflege_rekursiv_lips = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_upos_tabix
                                                  lf_upos_lfimg_new. "#&
        strukturpflege_rekursiv_lips = space.
      ENDIF.
    ELSE.
*     Bei gleichem Material: Mengenverteilung !
*     Auftrag HPos:                  100 ST = x = lf_hpos_lsmeng
*     Auftrag UPos:                   10 ST = y = lf_upos_lsmeng
*     Lieferung Verfügbar gesamt nur  50 ST = c = lf_gesamt_lfimg    "#&
*     Liefermenge HPos soll = 45
*     Liefermenge UPos soll =  5
*       x /  y  =  a / b =  a / (c -a)  => a = c * x / x + y
*     100 / 10  =  a / b  = a / (50-a)  => a = 50 * 100 / 110 = 45,4545
      a = c * x / ( x + y ).

      PERFORM round_sign_determine
              USING    ls_lips_hpos
              CHANGING lf_round_sign_natrb_hpos.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input         = a
          no_type_check = charx
          round_sign    = lf_round_sign_natrb_hpos
          unit_in       = lf_hpos_vrkme
          unit_out      = lf_hpos_vrkme
        IMPORTING
          output        = a
        EXCEPTIONS
          OTHERS        = 99.
      lf_hpos_lfimg_new = a.           "#&
      lf_upos_lfimg_new = lf_gesamt_lfimg - lf_hpos_lfimg_new.       "#&
*     Hauptposition Menge reduzieren, Unterposition Menge erhöhen
*     IF lf_hpos_lfimg_new < ls_lips_hpos-lfimg.
      lips = ls_lips_hpos.
      PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
              CHANGING lf_lfimg
                       lf_lfimg_flo
                       lf_lgmng
                       lf_lgmng_flo.
      IF  lf_hpos_lfimg_new   <> lf_lfimg
      AND ls_lips_upos-kcmeng  = 0
      AND ls_lips_hpos-kcmeng  = 0.

*       no batches, make sure that after the conversion the quantity of
*       the main item does not exceed its open quantity      v_n_628751
        IF lf_hpos_lfimg_new > ls_lips_hpos-ofmng.
          lf_hpos_lfimg_new = ls_lips_hpos-ofmng.
          lf_upos_lfimg_new = lf_gesamt_lfimg - lf_hpos_lfimg_new.
        ENDIF.                                              "^_n_628751

        READ TABLE xlips INDEX lf_hpos_tabix.
        lips = xlips.
        strukturpflege_rekursiv_lips = charx.
        v50agl-quan_no_check = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_hpos_tabix
                                                  lf_hpos_lfimg_new. "#&
        v50agl-quan_no_check = space.
*     ENDIF.
        READ TABLE xlips INDEX lf_upos_tabix.
        lips = xlips.
        v50agl-quan_no_check = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_upos_tabix
                                                lf_upos_lfimg_new.   "#&
        strukturpflege_rekursiv_lips = space.
        v50agl-quan_no_check = space.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " NATRB_PARTIAL
*&---------------------------------------------------------------------*
*&      Form  round_sign_determine
*&---------------------------------------------------------------------*
FORM round_sign_determine USING    is_lips             LIKE lipsvb
                          CHANGING cf_round_sign_natrb TYPE rndsg.

  DATA:
    lf_round_mode
  .
* Rounding according customizing flag in item category ?
  PERFORM natrb_round_mode_determine CHANGING lf_round_mode.

  CASE lf_round_mode.

    WHEN '1'.             "Default: Upgrade-compatible Release 4.0-4.6C
      cf_round_sign_natrb = charx.

    WHEN '2'.             "use flag from item-category

      PERFORM tvlp_select(sapmv50a) USING is_lips-pstyv sy-subrc.

      cf_round_sign_natrb = tvlp-rndsg.

  ENDCASE.

ENDFORM.                    " round_sign_determine
*&---------------------------------------------------------------------*
*&      Form  natrb_round_mode_determine
*&---------------------------------------------------------------------*
FORM natrb_round_mode_determine CHANGING cf_round_mode TYPE c.

* see note 319700 for further information

* this form is delivered in the release after 4.6C as a user exit.
* in releases 4.5 - 4.6C this form can be used for a modification.

* Upgrade-Compatible mode: always round quantities in freegoods
* processing with round_sign = 'X'
* Rounding is done due to mathematical correctness according
* to sales unit of measure (t005)
* 1,500 pc --> 2 pc if 0 digits are defined at UoM pc
* 1,499 pc --> 1 pc if 0 digits are defined at UoM pc

  cf_round_mode = '1'.



* Use flag in delivery-item-category to determine, how rounding
* is executed (see domain rndsg for possiblities)

* cf_round_mode = '2'.



ENDFORM.                    " natrb_round_mode_determine
*&---------------------------------------------------------------------*
*&      Form  spe_free_goods_check
*&---------------------------------------------------------------------*
FORM spe_free_goods_check  TABLES   ct_items TYPE vlkor_items.

  STATICS aupstab TYPE vlkor_aupstab WITH HEADER LINE.
  DATA: lf_rule  LIKE vbap-uepvw,
        lf_lfsta LIKE vbup-lfsta,
        lf_incl,
        lf_status(10),
        lf_natrb_type LIKE vbap-uepvw,
        lf_nr_loeschen.

  DATA: ls_save_lips  LIKE lips
      , ls_save_lipsd LIKE lipsd
      , ls_save_xlips LIKE lipsvb
      , ls_save_ilips LIKE ilips
      , ls_save_slips LIKE slips
      .

  CHECK strukturpflege_rekursiv_lips  IS INITIAL.

  ls_save_lips  = lips.
  ls_save_lipsd = lipsd.
  ls_save_xlips = xlips.
  ls_save_ilips = ilips.
  ls_save_slips = slips.

* Naturalrabatt-Auftragspositionen in aupstab aufnehmen
  PERFORM natrb_aupstab_insert TABLES aupstab cvbap.

  READ TABLE aupstab INDEX 1 TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.

* Naturalrabatt prüfen
  LOOP AT aupstab WHERE NOT lstanr IS INITIAL.              "nur NR-UPos
    CASE aupstab-lstanr.
*     Auslieferung erfolgt, wenn HP teilweise oder vollst. beliefert
      WHEN 'A' OR 'B' OR 'C'.
        PERFORM spe_natrb_check_uepos_included USING    aupstab
                                           CHANGING lf_incl.
        IF lf_incl IS INITIAL.
          lf_nr_loeschen = 'X'.
        ENDIF.
      WHEN 'E'.
        PERFORM spe_natrb_partial TABLES aupstab
                                  USING  lf_nr_loeschen.
    ENDCASE.

    IF lf_nr_loeschen = 'X'.
      CLEAR lf_nr_loeschen.
      PERFORM natrb_delete_item TABLES ct_items
                                USING  xlikp-vbeln aupstab.
    ENDIF.
  ENDLOOP.

  lips  = ls_save_lips.
  lipsd = ls_save_lipsd.
  xlips = ls_save_xlips.
  ilips = ls_save_ilips.
  slips = ls_save_slips.

ENDFORM.                    " spe_free_goods_check
*&---------------------------------------------------------------------*
*&      Form  spe_natrb_partial
*&---------------------------------------------------------------------*
FORM spe_natrb_partial  TABLES   aupstab        TYPE vlkor_aupstab
                        USING    if_nr_loeschen TYPE c.

  DATA: lf_natrb_type LIKE vbap-uepvw,
        ls_aups       TYPE vlkor_s_aupstab,
        ls_lips_hpos  TYPE vlkor_s_xlips,
        ls_lips_upos  TYPE vlkor_s_xlips,
        lf_lfgsa          LIKE xvbup-lfgsa,
        lf_gesamt_lfimg   LIKE xlips-lfimg_flo,
        lf_upos_lfimg_new LIKE xlips-lfimg_flo,
        lf_hpos_lfimg_new LIKE xlips-lfimg_flo,
        lf_lfimg          LIKE xlips-lfimg,
        lf_lfimg_flo      LIKE xlips-lfimg_flo,
        lf_lgmng          LIKE xlips-lgmng,
        lf_lgmng_flo      LIKE xlips-lgmng_flo,
        lf_gesamt_lsmeng  LIKE xvbap-lsmeng,
        lf_upos_lsmeng    LIKE vbap-lsmeng,
        lf_hpos_lsmeng    LIKE vbap-lsmeng,
        lf_upos_vrkme     LIKE vbap-vrkme,
        lf_hpos_vrkme     LIKE vbap-vrkme,
        lf_upos_tabix LIKE sy-tabix,
        lf_hpos_tabix LIKE sy-tabix,
        lf_incl,
        a TYPE f,
        b TYPE f,
        c TYPE f,
        x TYPE f,
        y TYPE f.

  DATA:
    lf_round_sign_natrb_upos TYPE rndsg
  , lf_round_sign_natrb_hpos TYPE rndsg
  .

  DATA: lf_menge     LIKE lips-lfimg,
        lf_b         LIKE lips-lfimg,
        lf_mchar(19) TYPE c.


* Wenn die NR-Hpos nicht in der Lieferung enthalten ist wird
* entweder die UPos
* - beim Anlegen mit allem Verfügbaren ausgeliefert, wenn HPos
*   erledigt ist oder
* - nicht erzeugt/gelöscht
  PERFORM korr_check_lieferrelevanz USING aupstab-vbeln aupstab-uepos
                                    CHANGING lf_lfgsa.
  PERFORM natrb_check_uepos_included USING    aupstab
                                     CHANGING lf_incl.

  IF lf_incl IS INITIAL.               "NR-HPos nicht in der LF drin
    IF     v50agl-kopieren    = charx  "anlegen
    AND    lf_lfgsa    CA 'C'.         "Auftragspos. erledigt
      EXIT.                            "alles liefern
    ELSEIF lf_lfgsa    CA ' AB'.
      if_nr_loeschen = 'X'.
      EXIT.                            "löschen
    ENDIF.
  ENDIF.

* Prüfen, ob aupstab auf NR-Unterposition positioniert ist.
***  PERFORM natrb_check_item_vbap
***                           TABLES   pvbap
***                           USING    aupstab-vbeln aupstab-posnr
***                                    aupstab-uepvw aupstab-uepos
***                           CHANGING lf_natrb_type.
  CHECK lf_natrb_type = 2.            "Nur weiter, wenn NR-Unterposition

* Zugehörige NR-Haupstpositions-Aupstab dazu lesen
  READ TABLE aupstab INTO ls_aups
                     WITH KEY vbeln = aupstab-vbeln
                              posnr = aupstab-uepos.

* Alle NR-Unterpositionen bearbeiten mit Aupstab-NR-Upos als Vorgänger
  LOOP AT xlips INTO  ls_lips_upos
                WHERE vbeln = xlikp-vbeln
                  AND vgbel = aupstab-vbeln
                  AND vgpos = aupstab-posnr
*                 AND NOT uepos IS INITIAL
                  AND     uecha IS INITIAL
                  AND (  updkz = updkz_update
                      OR updkz = updkz_new
                      OR updkz = space ).

    lf_upos_tabix = sy-tabix.

*   NR-Hauptposition in Lieferung dazu lesen
    LOOP AT xlips INTO  ls_lips_hpos
                  WHERE vbeln EQ xlikp-vbeln AND
                        posnr EQ ls_lips_upos-uepos AND
                        updkz NE updkz_delete.
      lf_hpos_tabix = sy-tabix.
      EXIT.
    ENDLOOP.

    IF sy-subrc <> 0.
      lf_hpos_tabix = sy-tabix.
    ENDIF.

*   determine quantities: quantities in the unchecked delivery
*    PERFORM spe_korr_vorgaenger_lsmeng  USING  ls_lips_hpos-vgbel
*                                               ls_lips_hpos-vgpos
*                                     CHANGING  lf_hpos_lsmeng
*                                               lf_hpos_vrkme.
*
*
*    PERFORM spe_korr_vorgaenger_lsmeng  USING  ls_lips_upos-vgtyp
*                                               ls_lips_upos-vgbel
*                                               ls_lips_upos-vgpos
*                                     CHANGING  lf_upos_lsmeng
*                                               lf_upos_vrkme.
*
    lf_gesamt_lsmeng = lf_hpos_lsmeng + lf_upos_lsmeng.
    IF lf_gesamt_lsmeng <= 0.          "Sonst Division durch Null
      EXIT.
    ENDIF.

*   Mengenverteilung nur bei gleichen Mengeneinheiten in Hpos und Upos
*   Auftrags-vrkme und Lieferungs-Vrkme darf unterschiedlich sein
    IF ls_lips_hpos-vrkme <> ls_lips_upos-vrkme.

      PERFORM round_sign_determine
              USING    ls_lips_hpos
              CHANGING lf_round_sign_natrb_hpos.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input         = ls_lips_hpos-lfimg  "#&
          no_type_check = charx
          round_sign    = lf_round_sign_natrb_hpos
          unit_in       = ls_lips_hpos-vrkme
          unit_out      = ls_lips_upos-vrkme
        IMPORTING
          output        = ls_lips_hpos-lfimg  "#&
        EXCEPTIONS
          OTHERS        = 99.
      ls_lips_hpos-vrkme = ls_lips_upos-vrkme.
    ENDIF.


*   Konvertierung in Float
*   Zu prüfende Mengen berechnen
    lips = ls_lips_hpos.
    PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
            CHANGING lf_lfimg
                     lf_lfimg_flo
                     lf_lgmng
                     lf_lgmng_flo.

    a = lf_gesamt_lfimg = lf_lfimg.

    lips = ls_lips_upos.
    PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
            CHANGING lf_lfimg
                     lf_lfimg_flo
                     lf_lgmng
                     lf_lgmng_flo.

    lf_gesamt_lfimg = lf_gesamt_lfimg + lf_lfimg.
    c = lf_gesamt_lfimg.               "#&
    x = lf_hpos_lsmeng.
    y = lf_upos_lsmeng.

*   Beim Anlegen keine Verteilung für Draufgabe mit gleichem Material
    IF ls_lips_upos-matnr <> ls_lips_hpos-matnr OR
*      slips-tabix <> 0.
       ls_lips_upos-updkz <> updkz_new OR
       ls_lips_hpos-updkz <> updkz_new OR
       v50agl-kopieren    <> charx.

*     Nur NR-UPos Menge gemäß Auftragsverhältnis setzen.
*     a = ls_lips_hpos-lfimg.
      IF y = 0.
        b = 0.
      ELSE.
*       x / y  = a / b   Auftrags-Verhältnis = Lieferverhältnis
        b = a * y / x.

        PERFORM round_sign_determine
                USING    ls_lips_upos
                CHANGING lf_round_sign_natrb_upos.

        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input         = b
            no_type_check = charx
            round_sign    = lf_round_sign_natrb_upos
            unit_in       = lf_upos_vrkme
            unit_out      = lf_upos_vrkme
          IMPORTING
            output        = b
          EXCEPTIONS
            OTHERS        = 99.
      ENDIF.
* Check whether free goods is already packed
      PERFORM xvbup_lesen(sapfv50p) USING likp-vbeln
                                      lips-posnr.
      IF xvbup-pksta NE space.
        PERFORM xvbapf_lesen(sapfv50p) USING likp-vbeln
                                             lips-posnr
                                             sy-subrc.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
              matnr                = ls_lips_upos-matnr
              meinh                = lf_upos_vrkme
              meins                = ls_lips_upos-meins
              input                = xvbapf-xmenge
              werks                = ls_lips_upos-werks
          IMPORTING
              output               = lf_menge
          EXCEPTIONS
              conversion_not_found = 01
              input_invalid        = 02
              material_not_found   = 03
              meinh_not_found      = 04
              meins_missing        = 05
              no_meinh             = 06
              output_invalid       = 07
              overflow             = 08.
        lf_b = b.
        IF lf_menge GT lf_b.
          WRITE lf_menge LEFT-JUSTIFIED NO-GAP
                TO lf_mchar UNIT lf_upos_vrkme.
          PERFORM message_handling(sapmv50a) USING lips-posnr
                                                   '616'
                                                   'W'
                                                   'VL'
                                                   lf_mchar
                                                   lf_upos_vrkme
                                                   space
                                                   space.
          EXIT.
        ENDIF.
* restore former xvbapf
        PERFORM xvbapf_lesen(sapfv50p) USING lips-vbelv
                                             lips-uepos
                                             sy-subrc.
      ENDIF.
* restore former xvbup
      PERFORM xvbup_lesen(sapfv50p) USING lips-vbelv
                                          lips-uepos.
      lf_upos_lfimg_new = b.           "#&
*     Unterposition reduzierte Menge neu setzen
*     IF lf_upos_lfimg_new <> ls_lips_upos-lfimg.
      lips = ls_lips_upos.
      PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
              CHANGING lf_lfimg
                       lf_lfimg_flo
                       lf_lgmng
                       lf_lgmng_flo.
      IF  lf_upos_lfimg_new   <> lf_lfimg
      AND ls_lips_upos-kcmeng  = 0.

        READ TABLE xlips INDEX lf_upos_tabix.
        lips = xlips.
        strukturpflege_rekursiv_lips = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_upos_tabix
                                                  lf_upos_lfimg_new. "#&
        strukturpflege_rekursiv_lips = space.
      ENDIF.
    ELSE.
*     Bei gleichem Material: Mengenverteilung !
*     Auftrag HPos:                  100 ST = x = lf_hpos_lsmeng
*     Auftrag UPos:                   10 ST = y = lf_upos_lsmeng
*     Lieferung Verfügbar gesamt nur  50 ST = c = lf_gesamt_lfimg    "#&
*     Liefermenge HPos soll = 45
*     Liefermenge UPos soll =  5
*       x /  y  =  a / b =  a / (c -a)  => a = c * x / x + y
*     100 / 10  =  a / b  = a / (50-a)  => a = 50 * 100 / 110 = 45,4545
      a = c * x / ( x + y ).

      PERFORM round_sign_determine
              USING    ls_lips_hpos
              CHANGING lf_round_sign_natrb_hpos.

      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING
          input         = a
          no_type_check = charx
          round_sign    = lf_round_sign_natrb_hpos
          unit_in       = lf_hpos_vrkme
          unit_out      = lf_hpos_vrkme
        IMPORTING
          output        = a
        EXCEPTIONS
          OTHERS        = 99.
      lf_hpos_lfimg_new = a.           "#&
      lf_upos_lfimg_new = lf_gesamt_lfimg - lf_hpos_lfimg_new.       "#&
*     Hauptposition Menge reduzieren, Unterposition Menge erhöhen
*     IF lf_hpos_lfimg_new < ls_lips_hpos-lfimg.
      lips = ls_lips_hpos.
      PERFORM fv50xflp_lips_lfimg_pruefen_00(sapfv50p)
              CHANGING lf_lfimg
                       lf_lfimg_flo
                       lf_lgmng
                       lf_lgmng_flo.
      IF  lf_hpos_lfimg_new   <> lf_lfimg
      AND ls_lips_upos-kcmeng  = 0
      AND ls_lips_hpos-kcmeng  = 0.

*       no batches, make sure that after the conversion the quantity of
*       the main item does not exceed its open quantity
        IF lf_hpos_lfimg_new > ls_lips_hpos-ofmng.
          lf_hpos_lfimg_new = ls_lips_hpos-ofmng.
          lf_upos_lfimg_new = lf_gesamt_lfimg - lf_hpos_lfimg_new.
        ENDIF.

        READ TABLE xlips INDEX lf_hpos_tabix.
        lips = xlips.
        strukturpflege_rekursiv_lips = charx.
        v50agl-quan_no_check = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_hpos_tabix
                                                  lf_hpos_lfimg_new. "#&
        v50agl-quan_no_check = space.
*     ENDIF.
        READ TABLE xlips INDEX lf_upos_tabix.
        lips = xlips.
        v50agl-quan_no_check = charx.
        PERFORM korr_menge_setzen(sapmv50a) USING lf_upos_tabix
                                                lf_upos_lfimg_new.   "#&
        strukturpflege_rekursiv_lips = space.
        v50agl-quan_no_check = space.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " spe_natrb_partial
*&---------------------------------------------------------------------*
*&      Form  spe_korr_vorgaenger_lsmeng
*&---------------------------------------------------------------------*
FORM spe_korr_vorgaenger_lsmeng  USING    if_vbeln  LIKE lips-vbeln
                                          if_posnr  LIKE lips-posnr
                                 CHANGING cf_lsmeng LIKE vbap-lsmeng
                                          cf_vrkme  LIKE lips-vrkme.
*  DATA ss_lips TYPE lipsvb.
*
*  IF ss_lips-vbeln <> if_vbeln OR
*     ss_lips-posnr <> if_posnr.
*    READ TABLE xlips INTO ss_lips WITH KEY vbeln = if_vbeln
*                                           posnr = if_posnr
*                       TRANSPORTING VBELN POSNR LSMENG
*                                    KWMENG VRKME.
*    IF sy-subrc <> 0.
*      CLEAR:  ss_vbap-vbeln,  ss_vbap-posnr,
*              ss_vbap-lsmeng, ss_vbap-vrkme.
*    ENDIF.
*  ENDIF.
*  IF SS_VBAP-KWMENG GT 0.
*    CF_LSMENG = SS_VBAP-KWMENG.
*    CF_VRKME  = SS_VBAP-VRKME.
*  ELSE.
*    CF_LSMENG = SS_VBAP-LSMENG.
*    CF_VRKME  = SS_VBAP-VRKME.
*  ENDIF.

ENDFORM.                    " spe_korr_vorgaenger_lsmeng
*&---------------------------------------------------------------------*
*&      Form  spe_natrb_check_uepos_included
*&---------------------------------------------------------------------*
form spe_natrb_check_uepos_included
                          USING    value(aupstab) TYPE vlkor_s_aupstab
                          CHANGING cf_incl     TYPE c.

  READ TABLE xlips WITH KEY vbelv = aupstab-vbeln
                            posnv = aupstab-uepos
                            vbeln = xlikp-vbeln
                            vgtyp = xlikp-vbtyp
                   BINARY SEARCH
                   TRANSPORTING NO FIELDS.

  IF sy-subrc = 0.
    cf_incl = charx.
  ELSE.
    cf_incl = space.
  ENDIF.

endform.                    " spe_natrb_check_uepos_included