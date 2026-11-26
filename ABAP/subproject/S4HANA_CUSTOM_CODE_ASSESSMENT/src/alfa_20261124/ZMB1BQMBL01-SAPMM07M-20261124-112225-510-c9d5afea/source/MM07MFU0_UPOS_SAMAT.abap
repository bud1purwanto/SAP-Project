*---------------------------------------------------------------------*
*       FORM UPOS_SAMAT                                               *
*---------------------------------------------------------------------*
*       Bearbeiten Sammelartikel                                      *
*---------------------------------------------------------------------*
FORM upos_samat USING is_enhancement TYPE isu_upos_samat. "#EC *

  DATA: anz_vari LIKE sy-tabix.
  DATA: h_zeile LIKE mseg-zeile.
  DATA: h_ebelp LIKE ekpo-ebelp.
  DATA: sammat-erfmg LIKE mseg-erfmg.
  DATA: lxlaut     LIKE dm07m-xlaut.   " PPF 4.0C
  DATA: lktopl     LIKE dm07m-ktopl.   " PPF 4.0C
  DATA: lbwmod     LIKE dm07m-bwmod.   " PPF 4.0C
  DATA: lxbkng     LIKE dm07m-xbkng.   "Note: 1329842
  DATA: lxlong     LIKE dm07m-xlong.   "Note: 1329842
  DATA: lxmcng     LIKE dm07m-xmcng.   "Note: 1329842
  DATA: llfmon     LIKE vm07m-lfmon.   " PPF 4.0C
  DATA: llfgja     LIKE vm07m-lfgja.   " PPF 4.0C
  DATA: lxstau     LIKE vm07m-xstau.   " PPF 4.0C
  DATA: lmonat     LIKE vm07m-monat.   " PPF 4.0C
  DATA: fuss_index LIKE mseg-zeile.    " PPF 4.0C
  DATA: lxvkbw     LIKE vm07m-xvkbw.   " PPF 4.0C               " R45
  DATA: var_fuss_zeilen TYPE i.                           "note 137589
  DATA: ls_isu_fusszeile_wa_pruefen TYPE isu_fusszeile_wa_pruefen. "IS2ERP

ENHANCEMENT-POINT UPOS_SAMAT_01 SPOTS ES_SAPMM07M.

* automatisch gelangt man in die matrix nur bei Neuanlage
  IF matrix IS INITIAL AND
     NOT aktyp = h.
    clear fuss-line_count.                                "note 602466
    loop at ymseg transporting no fields                  "note 602466
                 where parent_id = ymseg-line_id and      "note 602466
                       not erfmg is initial.              "note 602466
      add 1 to fuss-line_count.                           "note 602466
    endloop.                                              "note 602466
    field-symbols <fs_yvm07m> type vm07m.                 "note 602466
    read table yvm07m assigning <fs_yvm07m>               "note 602466
      with key zeilv = ymseg-zeile.                       "note 602466
    <fs_yvm07m>-line_count = fuss-line_count.             "note 602466
*   in case variants got zero quantity in overview        "note 602466
*   (at this point we're coming from the matrix)          "note 602466
    EXIT.
  ENDIF.

* if reversal via mbst -> don't show matrix
  IF matrix IS INITIAL AND vm07m-xstor = zwei.            "note 137589
    clear fuss-line_count.                                "note 602466
    loop at fuss transporting no fields                   "note 602466
                 where parent_id = fuss-line_id and       "note 602466
                       not xselk is initial.              "note 602466
      add 1 to fuss-line_count.                           "note 602466
    endloop.                                              "note 602466
    read table yvm07m assigning <fs_yvm07m>               "note 602466
      with key zeilv = ymseg-zeile.                       "note 602466
    <fs_yvm07m>-line_count = fuss-line_count.             "note 602466
*   possible to cancel only some variants-> adjust line_count " 602466
    DESCRIBE TABLE var_fuss LINES var_fuss_zeilen.        "note 137589
    IF var_fuss_zeilen = 0.                               "note 137589
      EXIT.                                               "note 137589
    ENDIF.                                                "note 137589
  ENDIF.                                                  "note 137589

*                        begin note 369052
*don't show matrix when doing a reversal via MBRL
  if t156n-fcode = 'RL' and  "originally from t158 (transaktions_init)
     mseg-kzbew = b and      "movement refering to p.o.
     vm07m-xstor = eins.     "reversal
    clear fuss-line_count.                                "note 602466
    loop at fuss transporting no fields                   "note 602466
                 where parent_id = fuss-line_id and       "note 602466
                       not xselk is initial.              "note 602466
      add 1 to fuss-line_count.                           "note 602466
    endloop.                                              "note 602466
    read table yvm07m assigning <fs_yvm07m>               "note 602466
      with key zeilv = ymseg-zeile.                       "note 602466
    <fs_yvm07m>-line_count = fuss-line_count.             "note 602466
*   possible to reverse only some variants->adjust line_count " 602466
    exit.
  endif.
*                        end note 369052
*                        begin note 376966
*also don't show matrix when coming from MBSU
*otherwise we get additional positions in the material document
  if t156n-fcode = 'SU' and  "originally from t158 (transaktions_init)
     mseg-kzbew = space and
     vm07m-xstor = drei.     "transfer posting
    exit.
  endif.
*                        end   note 376966
  REFRESH zfuss.
  LOOP AT fuss.
    zfuss = fuss.
    APPEND zfuss.
  ENDLOOP.
  REFRESH fuss.

* bei Wechsel in Matrixdarstellung:
* die Daten der Varianten werden vor Aufruf der Matrix entweder aus
* YMSEG,.. entnommen oder aktueller aus FUSS (wenn im Sammelbearbei-
* tungsbild schon Änderungen bei den Varianten vorgenommen wurden)
  IF NOT matrix IS INITIAL.
    REFRESH var_fuss.
    LOOP AT ymseg WHERE urzei = mseg-zeile AND
                        NOT zeile = mseg-zeile .
      ydm07m-zeild = ymseg-zeile.
      READ TABLE ydm07m INDEX ydm07m-zeild.
      yvm07m-zeilv = ydm07m-zeild.
      READ TABLE yvm07m INDEX yvm07m-zeilv.
*     CHECK YDM07M-UPTYP = UPTYP_VAR.                        " PPF 4.0C
      CLEAR var_fuss.
      READ TABLE zfuss WITH KEY zeile = ymseg-zeile.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING zfuss TO var_fuss.
      ELSE.
        MOVE-CORRESPONDING ydm07m TO var_fuss.
        MOVE-CORRESPONDING yvm07m TO var_fuss.
        MOVE-CORRESPONDING ymseg  TO var_fuss.
      ENDIF.
      var_fuss-kopf_zeile = mseg-zeile.
      APPEND var_fuss.
    ENDLOOP.
  ENDIF.

  PERFORM varianten USING mseg-matnr a_zeile.

* Retten der Gesamtmenge des Sammelartikels
  sammat-erfmg = mseg-erfmg.
  h_zeile = a_zeile.
  h_ebelp = mseg-ebelp.
* nach Aufruf Matrixdarstellung:
  IF NOT matrix IS INITIAL.
    LOOP AT var_fuss.
      IF var_fuss-kz_neu IS INITIAL.
        MOVE-CORRESPONDING var_fuss TO fuss.
        fuss-xlaus = xlaus.
        fuss-xselk = x.
        fuss-xprue = x.
        fuss-xselp = x.
        IF t158-kzbew = o AND rm07m-kzbew IS INITIAL. "204573
          fuss-fcode = fcod-slnv.
        ELSE.
          fuss-fcode = fcod-np.
        ENDIF.
        IF NOT fcausw-xaenp IS INITIAL.
          fuss-fcode = fcod-kp.
        ENDIF.
        APPEND fuss.
      ELSE.
* neue Zeilen nach Aufruf Darstellungswechsel (Matrix)
        PERFORM fcode_lesen USING fcod-nl.
        MOVE-CORRESPONDING var_fuss TO dm07m_merken.
        MOVE-CORRESPONDING var_fuss TO vm07m_merken.
        MOVE-CORRESPONDING var_fuss TO mseg_merken.
        MOVE dm07m-xlaut TO lxlaut.    " PPF 4.0C
        MOVE dm07m-ktopl TO lktopl.    " PPF 4.0C
        MOVE dm07m-bwmod TO lbwmod.    " PPF 4.0C
        MOVE vm07m-lfmon TO llfmon.    " PPF 4.0C
        MOVE vm07m-lfgja TO llfgja.    " PPF 4.0C
        MOVE vm07m-xstau TO lxstau.    " PPF 4.0C
        MOVE vm07m-monat TO lmonat.    " PPF 4.0C
        MOVE vm07m-xvkbw TO lxvkbw.    " PPF 4.0C                  " R45
        CLEAR: mseg, dm07m, vm07m.
        MOVE-CORRESPONDING dm07m_merken TO dm07m.
        MOVE t001-xeink TO dm07m-xeink.     "Note: 1283552
        MOVE T001K-XEWRX TO DM07M-XEWRX.    "Note: 1283552
        MOVE T001K-XEFRE TO DM07M-XEFRE.    "Note: 1283552
        MOVE T001K-EFREJ TO DM07M-EFREJ.    "Note: 1283552
        MOVE T001K-X2FDO TO DM07M-X2FDO.    "Note: 1283552
        MOVE lxlaut TO dm07m-xlaut.    " PPF 4.0C
        MOVE lktopl TO dm07m-ktopl.    " PPF 4.0C
        MOVE lbwmod TO dm07m-bwmod.    " PPF 4.0C
        MOVE llfmon TO vm07m-lfmon.    " PPF 4.0C
        MOVE llfgja TO vm07m-lfgja.    " PPF 4.0C
        MOVE lxstau TO vm07m-xstau.    " PPF 4.0C
        MOVE lmonat TO vm07m-monat.    " PPF 4.0C
        MOVE lxvkbw TO vm07m-xvkbw.    " PPF 4.0C                 " R45
        MOVE-CORRESPONDING vm07m_merken TO vm07m.
        MOVE-CORRESPONDING mseg_merken  TO mseg.
        CLEAR mseg-ebeln.
        CLEAR: dm07m-wemng,            " PPF 4.0C
               dm07m-wamng.            " PPF 4.0C
        CLEAR: mseg-menge,             " PPF 4.0C
               mseg-bpmng,             " PPF 4.0C
               mseg-exvkw.             " PPF 4.0C                 " R45
        IF mseg-kzbew = b.
          PERFORM konditionssatz_suchen.
        ENDIF.
        PERFORM fusszeile_wa_pruefen USING x
                                           ls_isu_fusszeile_wa_pruefen. "IS2ERP
        fuss-xselp = x.
        f_zeile = f_zeile + 1.
        mseg-zeile = m_zeile + f_zeile.
        dm07m-uptyp = uptyp_var.
        CLEAR dm07m-upvor.             " PPF 4.0C
        dm07m-uebpo = h_ebelp.
        mseg-urzei = h_zeile.
        IF mseg-kzbew NE b.            " PPF 4.0C
          PERFORM fuss_fuellen USING space.
* PPF: begin 4.0C
        ELSE.
          DESCRIBE TABLE fuss LINES fuss_index.
          IF NOT fuss_index IS INITIAL.
            MOVE dm07m-vzbew TO fuss-vzbew.
            fuss-uptyp = uptyp_var.
            CLEAR fuss-upvor.
            READ TABLE ymseg WITH KEY zeile = mseg-urzei.
            IF sy-subrc IS INITIAL AND
               ymseg-ebeln = mseg-ebeln.
               fuss-uebpo = h_ebelp.
             ELSE.
               CLEAR fuss-uebpo.
             ENDIF.
            MODIFY fuss INDEX fuss_index
                   TRANSPORTING xselp vzbew  uptyp upvor uebpo.
          ENDIF.
        ENDIF.
* PPF: end 4.0C
      ENDIF.
    ENDLOOP.
  ELSE.
* alle direkt oder indirekt (z.B. Leergut zu einer Variante) abhängigen
* Zeilen werden in FUSS eingestreut
    PERFORM fcode_lesen USING fcod-nl.
    MOVE-CORRESPONDING mseg TO msegk.
    LOOP AT var_fuss WHERE kopf_zeile = h_zeile.
      a_zeile = a_zeile + 1.
      MOVE-CORRESPONDING var_fuss TO fuss.
      IF var_fuss-kz_neu IS INITIAL.
        fuss-zeile = a_zeile.
* die Varianten können selbst wieder Kopfzeile von Leergut- oder
* Naturalrabattzeilen sein --> Zeile merken, um URZEI zu setzen, da
* dies bei Aufbau von VAR_FUSS noch nicht erfolgen konnte
        fuss-urzei = h_zeile.
        IF NOT fuss-upvor IS INITIAL.
          h_urzei = a_zeile.
        ELSEIF fuss-uptyp CA '234'.
          fuss-urzei = h_urzei.
        ENDIF.
        IF NOT fuss-erfmg IS INITIAL.
          fuss-xselk = x.
        ENDIF.
        APPEND fuss.
      ELSE.
* neue Zeilen
        MOVE-CORRESPONDING fuss TO dm07m_merken.
        MOVE-CORRESPONDING fuss TO vm07m_merken.
        MOVE-CORRESPONDING fuss TO mseg_merken.
        MOVE dm07m-xlaut TO lxlaut.    " PPF 4.0C
        MOVE dm07m-ktopl TO lktopl.    " PPF 4.0C
        MOVE dm07m-bwmod TO lbwmod.    " PPF 4.0C
        MOVE dm07m-xbkng TO lxbkng.    " Note: 1329842
        MOVE dm07m-xlong TO lxlong.    " Note: 1329842
        MOVE dm07m-xmcng TO lxmcng.    " Note: 1329842
        MOVE vm07m-lfmon TO llfmon.    " PPF 4.0C
        MOVE vm07m-lfgja TO llfgja.    " PPF 4.0C
        MOVE vm07m-xstau TO lxstau.    " PPF 4.0C
        MOVE vm07m-monat TO lmonat.    " PPF 4.0C
        MOVE vm07m-xvkbw TO lxvkbw.    " PPF 4.0C                  " R45
        CLEAR: mseg, dm07m, vm07m.
        MOVE-CORRESPONDING dm07m_merken TO dm07m.
        MOVE t001-xeink TO dm07m-xeink.     "Note: 1283552
        MOVE T001K-XEWRX TO DM07M-XEWRX.    "Note: 1283552
        MOVE T001K-XEFRE TO DM07M-XEFRE.    "Note: 1283552
        MOVE T001K-EFREJ TO DM07M-EFREJ.    "Note: 1283552
        MOVE T001K-X2FDO TO DM07M-X2FDO.    "Note: 1283552
        MOVE lxlaut TO dm07m-xlaut.    " PPF 4.0C
        MOVE lktopl TO dm07m-ktopl.    " PPF 4.0C
        MOVE lbwmod TO dm07m-bwmod.    " PPF 4.0C
        MOVE lxbkng TO dm07m-xbkng.    " Note: 1329842
        MOVE lxlong TO dm07m-xlong.    " Note: 1329842
        MOVE lxmcng TO dm07m-xmcng.    " Note: 1329842
        MOVE llfmon TO vm07m-lfmon.    " PPF 4.0C
        MOVE llfgja TO vm07m-lfgja.    " PPF 4.0C
        MOVE lxstau TO vm07m-xstau.    " PPF 4.0C
        MOVE lmonat TO vm07m-monat.    " PPF 4.0C
        MOVE lxvkbw TO vm07m-xvkbw.    " PPF 4.0C                 " R45
        MOVE-CORRESPONDING vm07m_merken TO vm07m.
        MOVE-CORRESPONDING mseg_merken  TO mseg.
        CLEAR: mseg-ebeln,
               dm07m-wemng,
               dm07m-wamng.
        CLEAR: mseg-menge,             " PPF 4.0C
               mseg-bpmng,             " PPF 4.0C
               mseg-exvkw.             " PPF 4.0C                 " R45
        IF mseg-kzbew = b.
          PERFORM konditionssatz_suchen.
        ENDIF.
        PERFORM fusszeile_wa_pruefen USING x
                                           ls_isu_fusszeile_wa_pruefen. "IS2ERP
        fuss-xselp = x.
        mseg-zeile = a_zeile.
        dm07m-uptyp = uptyp_var.
        CLEAR dm07m-upvor.             " PPF 4.0C
        dm07m-uebpo = h_ebelp.
        mseg-urzei  = h_zeile.
        IF mseg-kzbew NE b.            " PPF 4.0C
          PERFORM fuss_fuellen USING space.
* PPF: begin 4.0C
        ELSE.
          DESCRIBE TABLE fuss LINES fuss_index.
          IF NOT fuss_index IS INITIAL.
          MOVE dm07m-vzbew TO fuss-vzbew.
*         FUSS_INDEX = A_ZEILE - 1.
          fuss-uptyp = uptyp_var.
          CLEAR fuss-upvor.
          READ TABLE ymseg WITH KEY zeile = mseg-urzei.
          IF sy-subrc IS INITIAL AND
             ymseg-ebeln = mseg-ebeln.
             fuss-uebpo = h_ebelp.
           ELSE.
             CLEAR fuss-uebpo.
           ENDIF.
*          FUSS-UEBPO = H_EBELP.
          MODIFY fuss INDEX fuss_index
                 TRANSPORTING xselp vzbew uptyp upvor uebpo.
          ENDIF.
        ENDIF.
* PPF: end 4.0C
      ENDIF.
      DELETE var_fuss.
      anz_vari = anz_vari + 1.
    ENDLOOP.

* Anpassen der Referenz-Zeilennummern im restlichen Arbeitsvorrat
* (Tabelle ZFUSS)
    READ TABLE zfuss INDEX 1.
    IF sy-subrc = 0.
      LOOP AT var_fuss WHERE kopf_zeile >= zfuss-zeile AND
                             fcode = fcod-np.
* falls die Variante auch noch Leergut/Naturalrabatt hat
        IF NOT var_fuss-urzei IS INITIAL.
          var_fuss-urzei = var_fuss-urzei + anz_vari.
        ENDIF.
        var_fuss-kopf_zeile = var_fuss-kopf_zeile + anz_vari.
        MODIFY var_fuss.
      ENDLOOP.
    ENDIF.
* ZFUSS nach FUSS übernehmen; dabei muß die Zeilennummer bei neuen
* Zeilen um die Anzahl der hinzugekommenen Variantenpositionen
* erhöht werden
    LOOP AT zfuss.
      fuss = zfuss.
      IF fuss-fcode = fcod-np.
        fuss-zeile = fuss-zeile + anz_vari.
*#vsa 4.5A anfang
        IF NOT fuss-urzei IS INITIAL.
          fuss-urzei = fuss-urzei + anz_vari.
        ENDIF.
*#vsa 4.5A ende
      ENDIF.
      APPEND fuss.
    ENDLOOP.
  ENDIF.

* in Kopfzeile Kennung setzen, daß abhängige Zeilen existieren
* außerdem Gesamtmenge in Kopfzeile übernehmen (wird sicherheits-
* halber nochmal in FUSS abgestellt)
  READ TABLE ydm07m WITH KEY zeild = h_zeile.
  IF sy-subrc IS INITIAL.
    ydm07m-upvor = uptyp_var.
    MODIFY ydm07m INDEX sy-tabix.
    ymseg-zeile = ydm07m-zeild.
    READ TABLE ymseg INDEX ymseg-zeile.
    yvm07m-zeilv = ydm07m-zeild.
    READ TABLE yvm07m INDEX yvm07m-zeilv.
    CLEAR fuss.
    MOVE-CORRESPONDING ymseg  TO fuss.
    MOVE-CORRESPONDING ydm07m TO fuss.
    MOVE-CORRESPONDING yvm07m TO fuss.
*  wird gecleart, um bei Abbrechen von Varianten zu Sammel-
*  arikeln in der WE-Detail-Verarbeitung die erfmg des SA nicht
*  updaten zu müssen
    CLEAR FUSS-ERFMG.
    fuss-xselk = x.
    fuss-xselp = x.
    fuss-xprue = x.
    fuss-fcode = fcod-kp.
    APPEND fuss.
  ENDIF.

ENDFORM.