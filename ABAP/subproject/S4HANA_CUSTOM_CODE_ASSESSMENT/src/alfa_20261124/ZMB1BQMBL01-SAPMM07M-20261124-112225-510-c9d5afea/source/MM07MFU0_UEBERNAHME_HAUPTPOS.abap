*eject
*---------------------------------------------------------------------*
*       FORM UEBERNAHME_HAUPTPOS                                      *
*---------------------------------------------------------------------*
*       Bei Leergut und Naturalrabatt werden werden verschiedene      *
*       Daten grundsätzlich von der Hauptposition übernommen          *
*---------------------------------------------------------------------*
FORM uebernahme_hauptpos.
  DATA: h_fuss LIKE fuss.
  DATA: h_erfmg LIKE mseg-erfmg,
        h_lsmng LIKE mseg-erfmg.
  h_fuss = fuss.
* Lesen Hauptposition
  READ TABLE fuss WITH KEY zeile = fuss-urzei.
  IF sy-subrc IS INITIAL.
* Übernahme von Lagerort, Bestandsart, Endlieferungskennzeichen,
* Selektionskennzeichen und Anpassen der Menge
    mseg-lgort = fuss-lgort.
    mseg-insmk = fuss-insmk.
    mseg-elikz = fuss-elikz.
    dm07m-elikz_input = fuss-elikz_input.
    mseg-charg = fuss-charg.
    rm07m-xselk = fuss-xselk.
* Mengenkorrelation: Bestellmenge UP * Menge HP / Bestellmenge HP
*   Temporary correct KZBEW
    DATA: l_kzbew_temp LIKE mseg-kzbew.
    l_kzbew_temp = h_fuss-kzbew.
    IF l_kzbew_temp IS INITIAL AND im_process = l.
      l_kzbew_temp = l.
    ENDIF.
    CASE l_kzbew_temp.
      WHEN space.
        IF h_fuss-vermg = 0.
          PERFORM leerg_stueli_lesen USING fuss-matnr fuss-erfme.
          LOOP AT slcomp WHERE idnrk = h_fuss-matnr.
            h_erfmg = slcomp-menge * fuss-erfmg / 1000.
            EXIT.
          ENDLOOP.
        ELSE.
          h_erfmg = h_fuss-vermg * fuss-erfmg / fuss-vermg.
        ENDIF.
      WHEN b.
*keine Korrelation beim Storno eines Materialbeleges       "note 310493
        IF fuss-xstor = '2'.                               "note 310493
          h_erfmg = h_fuss-erfmg.                          "note 310493
          h_lsmng = h_fuss-erfmg.                          "note 310493
        ELSE.                                              "note 310493
          h_erfmg = h_fuss-bsmng * fuss-erfmg / fuss-bsmng.
          h_lsmng = h_fuss-bsmng * fuss-lsmng / fuss-bsmng.
        ENDIF.                                             "note 310493
    ENDCASE.
    mseg-erfmg = h_erfmg.
    mseg-lsmng = h_lsmng.
  ENDIF.
  fuss = h_fuss.
ENDFORM.