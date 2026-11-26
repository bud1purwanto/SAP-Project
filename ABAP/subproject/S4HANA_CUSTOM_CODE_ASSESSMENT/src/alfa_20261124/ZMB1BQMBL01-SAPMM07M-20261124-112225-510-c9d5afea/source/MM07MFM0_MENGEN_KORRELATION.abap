*---------------------------------------------------------------------*
*       FORM MENGEN_KORRELATION                                       *
*---------------------------------------------------------------------*
*       Bei strukturierten Artikeln (z.B. Leergut) erfolgt Mengen-    *
*       anpassung der Komponenten, falls Kopfzeile geändert wurde     *
*       bei Varianten erfolgt Anpassung der Sammelartikelzeile        *
*---------------------------------------------------------------------*
FORM mengen_korrelation.

  DATA: h_weiter(1).
  DATA: BEGIN OF komptab OCCURS 0,
           zeile LIKE mseg-zeile.
  DATA: END OF komptab.
  DATA: h_erfmg LIKE mseg-menge,       " neu berechnete Erfassungs-Menge
        h_lsmng LIKE mseg-lsmng.       " neu berechnete Liefers.Menge
  DATA: h_fuss_ergaenzt(1).
  FIELD-SYMBOLS <fuss_empty> TYPE fuss_mb.   "<LG>

  IF NOT dm07m-upvor IS INITIAL.
* Prüfen, ob Menge geändert
    LOOP AT fuss WHERE urzei = mseg-zeile AND
                       NOT zeile = mseg-zeile AND
                       mekor = x.
      h_erfmg = fuss-erfmg.
      h_lsmng = fuss-lsmng.
* Berechnung der neuen Menge auf Basis Verhältnis ursprgl. Komponenten-
* menge zu ursprünglicher Kopfmenge; falls ursprüngliche Menge 0 war,
* Nachlesen der Stückliste, falls ohne Belegbezug (bzw. neue Bestellung)
      IF ( rm07m-kzbew IS INITIAL AND im_process IS INITIAL )
      OR vm07m-xnebe = x.
* Warenbewegungen ohne Belegbezug
        IF fuss-vermg = 0 OR vm07m-xnebe = x.
          PERFORM leerg_stueli_lesen USING mseg-matnr mseg-erfme.
          LOOP AT slcomp WHERE idnrk = fuss-matnr.
            h_erfmg = slcomp-menge * mseg-erfmg / 1000.
            EXIT.
          ENDLOOP.
        ELSE.
          h_erfmg = fuss-vermg * mseg-erfmg / dm07m-vermg.
        ENDIF.
      ELSE.
* Warenbewegungen mit Bestellbezug
* Im Falle eines Stornos keine Mengenkorrelation, sonst fehlerhafte
* Menge bei Umbruch über POS wenn andere Mengeneinheit als bestellt
* note 310493
        IF NOT fuss-xstor = '2'.                           "note 310493
          h_erfmg = fuss-bsmng * mseg-erfmg / dm07m-bsmng.
          h_lsmng = fuss-bsmng * mseg-lsmng / dm07m-bsmng.
        ENDIF.                                             "note 310493
      ENDIF.
      fuss-erfmg = h_erfmg.
      fuss-lsmng = h_lsmng.
* bei Leergut und Naturalrabatt werden die Felder Endlieferungs-
* kennzeichen, Lagerort und Bestandsart aus der Hauptposition übernommen
      fuss-elikz = mseg-elikz.
      fuss-lgort = mseg-lgort.
      fuss-insmk = mseg-insmk.
      MODIFY fuss.
    ENDLOOP.
*   goods mvmt w. ref. to po and posting via mb_create..; mekor is not
*   populated for tied empty -> failure of loop above -> ELIKZ of tied
*   empty doesn't get changed; do it now; <LG>
*    IF NOT xmbwl IS INITIAL.
    IF  NOT xmbwl IS INITIAL and                             "460054
        not (     im_process =  'L' and                      "460054
              dm07m-vbeln_vl is initial ).                   "460054
*       exclude outbound delivery                            "460054
      LOOP AT fuss ASSIGNING <fuss_empty>
         WHERE urzei = mseg-zeile  AND
               uptyp = uptyp_lg.
        <fuss_empty>-elikz = mseg-elikz.
      ENDLOOP.
    ENDIF.
* falls es weitere Komponenten gibt, müssen die enstprechenden Zeilen in
* YMSEG schon vorhanden sein; daher YMSEG abarbeiten und neuer Eintrag
* in FUSS, falls nicht schon vorhanden
    LOOP AT ymseg WHERE urzei = mseg-zeile AND
                        NOT zeile = mseg-zeile .
* falls Eintrag in FUSS schon vorhanden, fertig
      LOOP AT fuss WHERE zeile = ymseg-zeile.
        EXIT.
      ENDLOOP.
      IF NOT sy-subrc IS INITIAL.
        ydm07m-zeild = ymseg-zeile.
        READ TABLE ydm07m INDEX ydm07m-zeild.
        yvm07m-zeilv = ydm07m-zeild.
        READ TABLE yvm07m INDEX yvm07m-zeilv.
        CHECK ydm07m-mekor = x.
        CLEAR fuss.
        MOVE-CORRESPONDING ymseg  TO fuss.
        MOVE-CORRESPONDING ydm07m TO fuss.
        MOVE-CORRESPONDING yvm07m TO fuss.
* Berechnung der neuen Menge auf Basis Verhältnis ursprgl. Komponenten-
* menge zu ursprünglicher Kopfmenge; falls ursprüngliche Menge 0 war,
* Nachlesen der Stückliste, falls ohne Belegbezug (bzw. neue Bestellung)
        h_erfmg = ymseg-erfmg.
        h_lsmng = ymseg-lsmng.
        IF ( rm07m-kzbew IS INITIAL AND im_process IS INITIAL )
        OR vm07m-xnebe = x.
* Warenbewegungen ohne Belegbezug
          IF ydm07m-vermg = 0 OR vm07m-xnebe = x.
            PERFORM leerg_stueli_lesen USING mseg-matnr mseg-erfme.
            LOOP AT slcomp WHERE idnrk = fuss-matnr.
              h_erfmg = slcomp-menge * mseg-erfmg / 1000.
              EXIT.
            ENDLOOP.
          ELSE.
            h_erfmg = fuss-vermg * mseg-erfmg / dm07m-vermg.
          ENDIF.
        ELSE.
* Warenbewegungen mit Bestellbezug
         IF NOT fuss-xstor = '2'.                          "note 310493
            h_erfmg = fuss-bsmng * mseg-erfmg / dm07m-bsmng.
            h_lsmng = fuss-bsmng * mseg-lsmng / dm07m-bsmng.
         ENDIF.                                            "note 310493
        ENDIF.
        fuss-erfmg = h_erfmg.
        fuss-lsmng = h_lsmng.
* bei Leergut und Naturalrabatt werden die Felder Endlieferungs-
* kennzeichen, Lagerort und Bestandsart aus der Hauptposition übernommen
        fuss-elikz = mseg-elikz.
        fuss-lgort = mseg-lgort.
        fuss-insmk = mseg-insmk.
        fuss-xhell = space.
        fuss-xlaus = xlaus.
        fuss-xselk = x.
        fuss-xselp = x.
        fuss-xprue = x.
        fuss-fcode = fcod-kp.
        h_fuss_ergaenzt = x.
        APPEND fuss.
        IF fcode_next = fcod-kp.
          fcode_next = fcod-ab.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Anpassen der Sammelartikelzeile (die Anpassung erfolgt dann, wenn
* keine weitere Variante mehr in FUSS vorhanden ist; auf Basis von
* YMSEG aller Varianten und der Menge der aktuellen Zeile kann die
* Gesamtmenge des Sammelartikels ermittelt werden und dieser wird dann
* auch nochmal in FUSS abgestellt
  IF dm07m-uptyp = uptyp_var AND
     NOT mseg-urzei IS INITIAL.
*   loop at fuss where urzei = mseg-urzei.
*     exit.
*   endloop.
*   if sy-subrc = 0.
*     exit.
*   endif.
    DATA: sammat-erfmg LIKE mseg-erfmg.
    sammat-erfmg = mseg-erfmg.
*   LOOP AT YMSEG WHERE URZEI = MSEG-URZEI AND               " PPF 4.0C
*                       URZEI NE YMSEG-ZEILE.                " PPF 4.0C
    LOOP AT ymseg WHERE urzei = mseg-urzei.                  " PPF 4.0C
      CHECK ymseg-urzei NE ymseg-zeile.
      IF NOT ymseg-zeile = mseg-zeile.
        sammat-erfmg = sammat-erfmg + ymseg-erfmg.
      ENDIF.
    ENDLOOP.
    READ TABLE fuss WITH KEY zeile = mseg-urzei.
    IF NOT sy-subrc IS INITIAL.
      ydm07m-zeild = mseg-urzei.
      READ TABLE ydm07m INDEX ydm07m-zeild.
      CHECK sy-subrc IS INITIAL.
      ymseg-zeile = mseg-urzei.
      READ TABLE ymseg INDEX ymseg-zeile.
      yvm07m-zeilv = mseg-urzei.
      READ TABLE yvm07m INDEX yvm07m-zeilv.
      CLEAR fuss.
      MOVE-CORRESPONDING ymseg  TO fuss.
      MOVE-CORRESPONDING ydm07m TO fuss.
      MOVE-CORRESPONDING yvm07m TO fuss.
      IF fuss-erfmg NE sammat-erfmg.
        fuss-erfmg = sammat-erfmg.
        fuss-xselk = x.
        fuss-xselp = x.
        fuss-xprue = x.
        fuss-fcode = fcod-kp.
        APPEND fuss.
      ENDIF.
    ELSE.
      fuss-erfmg = sammat-erfmg.
      MODIFY fuss INDEX sy-tabix.
    ENDIF.
  ENDIF.

ENDFORM.