*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_MENGEN_AENDERN                               *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_MENGEN_AENDERN                                       *
*---------------------------------------------------------------------*
*       Beim Ändern der Menge einer Lieferposition werden ggf.        *
*       vorhandene abhängige Positionen mengenmäßig angepaßt falls    *
*       sie zu einer Liefergruppe zusammengefaßt sind                 *
*---------------------------------------------------------------------*
FORM korr_mengen_aendern USING value(da_posnr) LIKE lips-posnr.

  DATA:  hpos_lfimg LIKE lips-lfimg,                               "#&rm
         hpos_lgmng TYPE f.
ENHANCEMENT-POINT KORR_MENGEN_AENDERN_01 SPOTS ES_SAPMV50A STATIC.
  DATA: HPOS_KMPMG LIKE VBAP-KMPMG,
         hpos_aumng TYPE f,
         neue_menge TYPE f,
         upos_tabix LIKE sy-tabix,
         hpos_grkor LIKE lips-grkor,
         hpos_lsmng LIKE vbap-lsmeng,
         kmk_lfimg LIKE lips-lfimg,                                "#&rm
         lp_lfimg(16) TYPE c.                                      "#&rm
  DATA:  local_slips_key LIKE slips-tabix.
  DATA:  kz_strtyp LIKE tmgw2-strtp.   " Kennung Stücklistentyp strukt.
                                       " Artikel

  DATA: items    TYPE vlkor_items   WITH HEADER LINE.
  DATA: LS_SAVE_XLIPS TYPE LIPSVB,                          "v_n_939187
        LS_SAVE_XVBUP TYPE VBUP,
        LF_POSNR_PACKED_ITEM LIKE LIPS-POSNR VALUE SPACE,   "^_n_939187
        LF_POSNR_PICKED_ITEM LIKE LIPS-POSNR VALUE SPACE.     "n_990102


  CHECK v50agl-no_quantity_correlation IS INITIAL.                  "AIP

* kein rekursiver Aufruf zulässig, weil alles in einem loop ueber UVBAP
  CHECK: strukturpflege_rekursiv_lips = space.

* no correlation in case of product selection               "v_n_599392
  CHECK XLIPS-PROSA NA GC_PROSA-MAIN.                       "^_n_599392

  IF V50AGL-KOMMIRUECKMELDUNG NE CHARX.                       "n_1305630
* no correlation in case of already packed items            "v_n_939187
    LS_SAVE_XLIPS = XLIPS.
    LS_SAVE_XVBUP = XVBUP.
    LOOP AT XLIPS WHERE GRKOR EQ LS_SAVE_XLIPS-GRKOR
                  AND   UEPOS EQ LS_SAVE_XLIPS-POSNR
                  AND   UPDKZ NE UPDKZ_DELETE.               "n_1362518
      VBUPKEY-MANDT = XLIPS-MANDT.
      VBUPKEY-VBELN = XLIPS-VBELN.
      VBUPKEY-POSNR = XLIPS-POSNR.
      READ TABLE XVBUP WITH KEY VBUPKEY INTO XVBUP.
      IF XVBUP-PKSTA CA 'BC' OR SY-SUBRC NE 0.
        LF_POSNR_PACKED_ITEM = XLIPS-POSNR.
        EXIT.
      ENDIF.
    ENDLOOP.
    XLIPS = LS_SAVE_XLIPS.
    XVBUP = LS_SAVE_XVBUP.
    IF NOT LF_POSNR_PACKED_ITEM IS INITIAL.
      PERFORM MESSAGE_HANDLING(SAPMV50A) USING LF_POSNR_PACKED_ITEM
                                               '846'
                                               'E'
                                               'VL'
                                               LF_POSNR_PACKED_ITEM
                                               SPACE
                                               SPACE
                                               SPACE.
      CHECK 1 = 2.
    ENDIF.                                                  "^_n_939187
  ENDIF.                                                      "n_1305630

  IF V50AGL-KOMMIRUECKMELDUNG NE CHARX.                       "n_1088620
* no correlation in case of already picked items            "v_n_990102
    LS_SAVE_XLIPS = XLIPS.
    LS_SAVE_XVBUP = XVBUP.
    LOOP AT XLIPS WHERE GRKOR EQ LS_SAVE_XLIPS-GRKOR
                  AND   UEPOS EQ LS_SAVE_XLIPS-POSNR
                  AND   UPDKZ NE UPDKZ_DELETE.               "n_1362518
      VBUPKEY-MANDT = XLIPS-MANDT.
      VBUPKEY-VBELN = XLIPS-VBELN.
      VBUPKEY-POSNR = XLIPS-POSNR.
      READ TABLE XVBUP WITH KEY VBUPKEY INTO XVBUP.
      IF XVBUP-KOSTA CA 'BC' OR SY-SUBRC NE 0.
        LF_POSNR_PICKED_ITEM = XLIPS-POSNR.
        EXIT.
      ENDIF.
    ENDLOOP.
    XLIPS = LS_SAVE_XLIPS.
    XVBUP = LS_SAVE_XVBUP.
    IF NOT LF_POSNR_PICKED_ITEM IS INITIAL.
      PERFORM MESSAGE_HANDLING(SAPMV50A) USING LF_POSNR_PICKED_ITEM
                                               '847'
                                               'E'
                                               'VL'
                                               LF_POSNR_PICKED_ITEM
                                               SPACE
                                               SPACE
                                               SPACE.
      CHECK 1 = 2.
    ENDIF.                                                  "^_n_990102
  ENDIF.                                                      "n_1088620

* merken der neuen Liefermenge der Hauptposition
  IF xlips-kzfme CA kzfme_ws.
    neue_menge = xlips-lfimg_flo + xlips-kcmengvmef.               "#&rm
    IF xlips-umrev = 0.
      hpos_lgmng = xlips-lgmng_flo + (  xlips-kcmengvmef
                                      * xlips-umvkz / xlips-umvkn ).
    ELSE.
      hpos_lgmng = xlips-lgmng_flo + (  xlips-kcmengvmef
                                      * xlips-umrev ).
    ENDIF.
  ELSE.
    IF xlips-umrev = 0.
      neue_menge = xlips-lfimg_flo + (  xlips-kcmeng_flo       "#&rm
                                      * xlips-umvkn / xlips-umvkz ).
    ELSE.
      neue_menge = xlips-lfimg_flo + (  xlips-kcmeng_flo       "#&rm
                                      * xlips-umrev ).
    ENDIF.
    hpos_lgmng = xlips-lgmng_flo + xlips-kcmeng_flo.
  ENDIF.
  hpos_lfimg = neue_menge.                                         "#&rm
  hpos_grkor = xlips-grkor.
ENHANCEMENT-POINT KORR_MENGEN_AENDERN_02 SPOTS ES_SAPMV50A.
  vbapkey-mandt = xlips-mandt.
  vbapkey-vbeln = xlips-vgbel.
  vbapkey-posnr = xlips-vgpos.
  READ TABLE xvbap WITH KEY vbapkey.
  hpos_kmpmg = xvbap-kmpmg.
  hpos_aumng = xvbap-lsmeng * xvbap-umvkz / xvbap-umvkn.

* Aufbauen der Tabelle der Positionstruktur
  PERFORM korr_uvbap_aufbauen.

* bestimmen der abhängigen Positionen
  LOOP AT uvbap WHERE uepos = da_posnr.
    PERFORM xlips_lesen_direkt(sapfv50p) USING uvbap-posnr
                                               sy-tabix.
    CHECK xlips-grkor > 0.             "Verlegt aus uvbap_aufbauen
*   no correlation for distributed items                      v_n_881638
    CHECK V50AGL-CONFIRM_CENTRAL IS INITIAL OR
          XLIPS-LFDEZ EQ CHARX.                              "^_n_881638
    upos_tabix = sy-tabix.
    vbapkey-mandt = xlips-mandt.
    vbapkey-vbeln = xlips-vgbel.
    vbapkey-posnr = xlips-vgpos.
    READ TABLE xvbap WITH KEY vbapkey.
    IF sy-subrc NE 0.
      lips = xlips.
      PERFORM lips_referenz_lesen(sapfv50p).
    ENDIF.
*##ngr-anf
    IF NOT xvbap-stkey IS INITIAL.
      PERFORM pruefen_structart_sl CHANGING kz_strtyp
                                            xvbap-stkey.
    ENDIF.
    IF xvbap-fmeng IS INITIAL.
      IF xlips-vgtyp CA vbtyp_bestell
*      In a decentral LE system we have no order items, so we do the
*      correlation with the relation between new and old quantity
         OR NOT xlips-verurpos IS INITIAL           "ULa, 4.6c
* retail delivery can have lips-grkor without lips-vgtyp
         OR XLIPS-VGTYP IS INITIAL.                            "n_726714
* Vorgänger ist eine Bestellung --> es muß eine Leergutstückliste sein;
* Positionen werden proportional auf Basis der Liefermengen ermittelt
* (keine Umrechnung auf Basismengeneinheit, da sich die Komponenten-
* mengen bei Leergut schon auf die Ausgabemengeneinheit beziehen !)
        neue_menge = hpos_lfimg * xlips-kmpmg.                     "#&rm
*##ngr-end
*      wenn möglich Korrelation gemäß Komponentenmengen
      ELSEIF xvbap-kmpmg <> 0 AND
             hpos_kmpmg  <> 0.
**      NEUE_MENGE = HPOS_LFIMG * XVBAP-KMPMG * XVBAP-UMVKN /      "#&rm
**                   XVBAP-UMVKZ / HPOS_KMPMG.
*       LF(UV) = ( LF(HL) * KOMP(U) / KOMP(H)) * umrech
*##ngr-anf
        IF kz_strtyp = charp.
* bei Leergutstückliste beziehen sich die Komponentenmengen auf die
* Erfassungsmengeneinheit
          neue_menge = hpos_lfimg * xvbap-kmpmg / hpos_kmpmg.      "#&rm
        ELSE.
ENHANCEMENT-SECTION     KORR_MENGEN_AENDERN_03 SPOTS ES_SAPMV50A.
          neue_menge = hpos_lgmng * xvbap-kmpmg * xlips-umvkn /
                       hpos_kmpmg / xlips-umvkz.
END-ENHANCEMENT-SECTION.
        ENDIF.
*##ngr-end
*      sonst Korrelation gemäß Auftragsmengen
*      LF(UV) = ( LF(HL) * (AU(UV) * umrechn) / AU(HL) ) * umrechn
      ELSE.
        neue_menge = hpos_lgmng * xvbap-lsmeng * xvbap-umvkz *
            xlips-umvkn / xvbap-umvkn / hpos_aumng / xlips-umvkz.
      ENDIF.
      kmk_lfimg = neue_menge.                                      "#&rm
      IF NOT xlips-kzfme CA kzfme_ws.
        IF xlips-kcmeng GT 0.
          IF xlips-umrev = 0.
            neue_menge = xlips-lfimg_flo + ( xlips-kcmeng_flo      "#&rm
                                          * xlips-umvkn / xlips-umvkz ).
          ELSE.
            neue_menge = xlips-lfimg_flo + (  xlips-kcmeng_flo     "#&rm
                                            * xlips-umrev      ).
          ENDIF.
          IF kmk_lfimg NE neue_menge.                              "#&rm
            WRITE kmk_lfimg TO lp_lfimg UNIT xlips-vrkme.          "#&rm
            PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                                     '174'
                                                     'I'
                                                     'VL'
                                                     xlips-posnr
                                                     lp_lfimg        "#&
                                                     xlips-vrkme
                                                     space.
          ENDIF.
          CHECK 1 = 2.
        ENDIF.
      ELSE.
        IF xlips-kcmengvme GT 0.
          neue_menge = xlips-lfimg_flo + xlips-kcmengvmef.         "#&rm
          IF kmk_lfimg NE neue_menge.                              "#&rm
            WRITE kmk_lfimg TO lp_lfimg UNIT xlips-vrkme.          "#&rm
            PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                                     '174'
                                                     'I'
                                                     'VL'
                                                     xlips-posnr
                                                     lp_lfimg        "#&
                                                     xlips-vrkme
                                                     space.
          ENDIF.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.

ENHANCEMENT-SECTION     KORR_MENGEN_AENDERN_04 SPOTS ES_SAPMV50A.
      IF kmk_lfimg NE xlips-lfimg.                                 "#&rm
        IF NOT v50agl-dialog IS INITIAL.                     "v_n_638127
          APPEND upos_tabix TO gt_correlated.
        ENDIF.                                               "^_n_638127
        strukturpflege_rekursiv_lips = charx.
        PERFORM korr_menge_setzen USING upos_tabix
                                         kmk_lfimg.                "#&rm
        strukturpflege_rekursiv_lips = space.
      ENDIF.
END-ENHANCEMENT-SECTION.
    ELSE.
      PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                               '178'
                                               'I'
                                               'VL'
                                               xlips-posnr
                                               space
                                               space
                                               space.

    ENDIF.
  ENDLOOP.
  IF sy-subrc EQ 0.
*   Original-Positionierung wiederherstellen
    PERFORM xlips_lesen_direkt(sapfv50p) USING da_posnr
                                        local_slips_key.
*   Positionierung auch in slips wieder herstellen
    READ TABLE slips WITH KEY tabix = local_slips_key.
    lips = xlips.
    MESSAGE s177.
  ELSE.
*   Original-Positionierung wiederherstellen
    PERFORM xlips_lesen_direkt(sapfv50p) USING da_posnr
                                         local_slips_key.
*   Positionierung auch in slips wieder herstellen
    READ TABLE slips WITH KEY tabix = local_slips_key.
    lips = xlips.
    PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                             '119'
                                             'I'
                                             'VL'
                                             da_posnr
                                             hpos_grkor
                                             space
                                             space.
  ENDIF.

ENDFORM.                    "korr_mengen_aendern
*eject