*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_MENGEN_KOMPLETT                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_MENGEN_KOMPLETT                                      *
*---------------------------------------------------------------------*
*       Beim Erstellen einer Lieferung werden die Mengen korreliert   *
*       falls die Positionen eine Struktur haben und zu einer         *
*       Liefergruppe zusammengefaßt sind.
*---------------------------------------------------------------------*
form korr_mengen_komplett.

  data: korrtab        type vlkor_korrtab       with header line,
        korrtab_uepos  type vlkor_korrtab_uepos with header line,
        lt_items       type vlkor_t_items       with header line,
        kverh_err      type f,
        kmk_lfimg      like lips-lfimg,                              "#&
        local_menge1   like lips-lfimg,                              "#&
        local_menge2   like lips-lfimg,                              "#&
        ls_lips_natrb  type vlips_lipsvb_s,
        lf_natgr       like lips-grkor,
        lf_xlips_tabix like sy-tabix,
        lf_hpos_tabix  like sy-tabix,
        upos_tabix     like sy-tabix,
        lf_lfgsa       like vbup-lfgsa,
        lf_vbeln       like likp-vbeln,
        lf_posnr       like lips-posnr,
        LF_LSMENG      LIKE VBAP-LSMENG,
        LF_VRKME       LIKE VBAP-VRKME,
        lf_msgty       like sy-msgty  .
data: ls_lips01 like lipsvb,
      lf_delete_grkor_mng0.                           "Menge 0 zulassen
DATA: LF_UEPOS LIKE LIPS-UEPOS.


  check v50agl-no_quantity_correlation is initial.                 "AIP

  check xlikp-vbtyp na vbtyp_mmli. "Keine Korrelation bei Anlieferungen

* refresh xekpo.                                              "n_1529376
  clear xvbap.

* Rundungs-Information zur LFGruppen-Haupt- und NR-Hauptposition sammeln
  loop at xlips where vbeln = xlikp-vbeln   and   "Rundungsdaten sammeln
                      updkz ne updkz_delete and
                 (    grkor > 0        and
                      uepos IS INITIAL         ) AND
                      NOT vgpos IS INITIAL.                    "n_617331
    lf_xlips_tabix = sy-tabix.
* Not for free goods and product selection                   "v_n_596127
    IF xlips-uepvw NA naturalrabatt AND   "Kein NR, sondern Liefergruppe
       xlips-prosa NA GC_PROSA-MAIN.                         "^_n_596127
      korrtab_uepos-vbeln = xlips-vbeln.
      korrtab_uepos-posnr = xlips-posnr.
      korrtab_uepos-vrkme = xlips-vrkme.
      if xlips-vgsys is initial.                                    "AIP
        perform korr_vorgaenger_lsmeng tables xvbap
                                       using xlips-vgtyp
                                             xlips-vgbel
                                             xlips-vgpos
                                       changing korrtab_uepos-lsmeng
                                                korrtab_uepos-vrkme.
      else.                                                         "AIP
        perform korr_xlipsref_lsmeng using    xlips                 "AIP
                                     changing korrtab_uepos-lsmeng  "AIP
                                              korrtab_uepos-vrkme.  "AIP
      endif.                                                        "AIP
      append korrtab_uepos.
    else.                              "Naturalrabatt im FV50XF0G
    endif.
  endloop.

* Aufbauen der Tabelle der Positionstruktur
  perform korr_uvbap_aufbauen.

* korreliert werden Positionen mit GRKOR und Stuli-Struktur
  loop at xlips where vbeln = xlikp-vbeln   and             "Korrelation
                      updkz <> updkz_delete and
                      posar <> charb        and
                      uecha is initial      and
                      uepvw NA PRODUKTSELEKTION AND          "v_n_596127
                      prosa NA GC_PROSA-MAIN    AND          "^_n_596127
                  (   grkor > 0                          ) AND
                      NOT vgpos IS INITIAL.                    "n_617331
*   nicht für bereits ex. Positionen
    read table alips with key xlips-posnr binary search.
    check sy-subrc <> 0.
*   Hauptpositionen ohne Unterpositionen ignorieren
    if xlips-uepos is initial.         "HPos ohne UPos ignorieren
      read table uvbap with key uepos = xlips-posnr
                       transporting no fields.
      check sy-subrc = 0.
    endif.

*   minimales Verhältnis von Liefermenge zu Planmenge je Korrgruppe
    perform korr_vorgaenger_lsmeng tables   xvbap
                                   using    xlips-vgtyp
                                            xlips-vgbel
                                            xlips-vgpos
                                   CHANGING LF_LSMENG
                                            LF_VRKME.
    IF NOT XLIPS-KZFME CA KZFME_WS.    "Korrelationsfaktor
      IF XLIPS-UMREV = 0.
            KVERH_ERR = ( XLIPS-LFIMG_FLO  +
                          XLIPS-KCMENG_FLO * XLIPS-UMVKN / XLIPS-UMVKZ )
                        / LF_LSMENG.
      ELSE. KVERH_ERR = ( XLIPS-LFIMG_FLO  +
                          XLIPS-KCMENG_FLO * XLIPS-UMREV )
                        / LF_LSMENG.
      ENDIF.
    ELSE.   KVERH_ERR =       ( XLIPS-LFIMG +
                                XLIPS-KCMENGVME )
                              / LF_LSMENG.
    endif.

*   Abrunden für ganzzahlige Mengeneinheiten
    if not xlips-uepos is initial.     "Zugehörige Hauptposition
      lf_posnr = xlips-uepos.
    else.
      lf_posnr = xlips-posnr.
    endif.
    read table korrtab_uepos with key vbeln = xlips-vbeln
                                      posnr = lf_posnr
                             binary search.
    if sy-subrc = 0.
      local_menge1 = korrtab_uepos-lsmeng * kverh_err.
      call function 'UNIT_CONVERSION_SIMPLE'
           exporting
                input         = local_menge1
                no_type_check = charx
                round_sign    = char-
                unit_in       = korrtab_uepos-vrkme
                unit_out      = korrtab_uepos-vrkme
           importing
                output        = local_menge2
           exceptions
                others        = 99.
      if sy-subrc = 0 and local_menge1 ne local_menge2.          "Runden
        kverh_err = local_menge2 / korrtab_uepos-lsmeng.
      endif.
    endif.
*   Minimales Korrelationsverhältnis setzen, wenn kleiner geworden
    PERFORM KORR_GET_UEPOS USING    XLIPS-POSNR
                           CHANGING LF_UEPOS.
    LOOP AT KORRTAB WHERE VGBEL = XLIPS-VGBEL  AND
                          GRKOR = XLIPS-GRKOR  AND
                          UEPOS = LF_UEPOS.
      if korrtab-kverh_min gt kverh_err.
        korrtab-kverh_min =  kverh_err.
        korrtab-posnr = xlips-posnr.
        modify korrtab.
      endif.
      exit.
    endloop.
    if sy-subrc > 0.              "1. Korrtab-Eintrag pro Gruppe anlegen
      korrtab-vgbel = xlips-vgbel.
      korrtab-grkor = xlips-grkor.
      korrtab-posnr = xlips-posnr.
      korrtab-kverh_min = kverh_err.
      KORRTAB-UEPOS = LF_UEPOS.
      append korrtab.
    endif.
  endloop.

* verändern der Mengen der Lieferpositionen gemäß minimalem Verhältnis
  loop at korrtab.
    if korrtab-kverh_min eq 0.
*     Liefergruppe mit Menge 0 ablehnen, sobald eine Hauptpositon
*     Menge 0 auschließt.
      clear lf_delete_grkor_mng0.

      loop at xlips into ls_lips01 where grkor =  korrtab-grkor
                                   and   vgbel =  korrtab-vgbel
                                   and   uepos is initial
                                   and   updkz <> updkz_delete.

        perform tvlp_select(sapmv50a) using ls_lips01-pstyv
                                            sy-subrc.
        if   tvlp-mng0p  = 'B'    or
           ( tvlp-mng0p  = 'C' and
             ls_lips01-updkz = UPDKZ_NEW ).                   "n_804026
          lf_delete_grkor_mng0 = charx.     "Eine Hauptpos. läßt 0 nicht
          exit.                             "zu -> Liefergruppe löschen
        else.
          continue.                         "Weitersuchen
        endif.
      endloop.
    endif.

    if korrtab-kverh_min eq 0 and
       lf_delete_grkor_mng0 = 'X'.
       if v50agl-sammelgang ne charx.
         lf_msgty = charw.
       else.
         lf_msgty = chare.
       endif.
       perform message_handling           using posnr_low
                                            '176'
                                            lf_msgty
                                            'VL'
                                            korrtab-grkor
                                            korrtab-vgbel
                                            space
                                            space.
    endif.


    loop at xlips where vbeln =  xlikp-vbeln    and
                        updkz <> updkz_delete   and
                        vgbel =  korrtab-vgbel  and
                        uecha is initial        and
                        grkor =  korrtab-grkor.
      upos_tabix = sy-tabix.
      PERFORM KORR_GET_UEPOS USING    XLIPS-POSNR
                             CHANGING LF_UEPOS.
      CHECK LF_UEPOS EQ KORRTAB-UEPOS.
*     nicht für bereits ex. Positionen
      read table alips with key xlips-posnr binary search.
      check sy-subrc <> 0.

      if korrtab-kverh_min eq 0 and
         lf_delete_grkor_mng0 = 'X'.
*       ChargenHauptPosition merken für späteres gemeinsames löschen
        perform korr_check_chp_collect tables lt_items
                                       using  xlips.
        sy-tabix = upos_tabix.
        strukturpflege_rekursiv_lips = charx.
        perform xlips_loeschen(sapfv50p) using charx upos_tabix.
        strukturpflege_rekursiv_lips = space.
      else.
        if xlips-uepos is initial.
*         Korrelation von Nicht-Stücklisten-Positionen unterbinden
          read table uvbap with key uepos = xlips-posnr
                           transporting no fields.
          check sy-subrc = 0.
        endif.
        READ TABLE XVBAP WITH KEY VBELN = XLIPS-VGBEL
                                  POSNR = XLIPS-VGPOS.
        IF XVBAP-KWMENG GT 0.
          LF_LSMENG = XVBAP-KWMENG.
        ELSE.
          LF_LSMENG = XVBAP-LSMENG.
        ENDIF.
        if xvbap-fmeng is initial or
           xlips-lstanr = 'E'     or
           xlips-vgtyp = vbtyp_bestell.
          if xlips-vgtyp = vbtyp_bestell.
            perform bestellmenge_lesen using    xlips-vgbel
                                                xlips-vgpos
                                       CHANGING LF_LSMENG.
          ENDIF.
          KMK_LFIMG = LF_LSMENG * KORRTAB-KVERH_MIN.
          if xlips-kcmeng > 0.
            perform korr_chargensplit using xlips-posnr kmk_lfimg.   "#&
          else.
            if xlips-lfimg <> kmk_lfimg.                             "#&
              perform message_handling(sapmv50a) using posnr_low
                                                 '175' 'W' 'VL'
                                                 xlips-grkor
                                                 xlips-vgbel
                                                 xlips-posnr space.
              strukturpflege_rekursiv_lips = charx.
              perform korr_menge_setzen using upos_tabix
                                              kmk_lfimg.             "#&
              strukturpflege_rekursiv_lips = space.
            endif.
          endif.
        endif.
      endif.
    endloop.
  endloop.
  perform korr_dependent_items_delete tables lt_items
                                      using  xlikp-vbeln.
  move-corresponding likp to xlikp.
  if v50agl-sammelgang = charx. modify xlikp. endif.

endform.