*---------------------------------------------------------------------*
*       FORM UPOS_STUELI                                              *
*---------------------------------------------------------------------*
*       Bearbeiten Stücklistenauflösung (Leergut)                     *
*---------------------------------------------------------------------*
FORM upos_stueli using is_enhancement TYPE isu_upos_stueli. "#EC *

  DATA: h_urzei LIKE mseg-zeile.
  DATA: h_uebpo LIKE ekpo-uebpo.
  DATA: h_erfmg LIKE mseg-erfmg.
  DATA: anz_comp LIKE sy-tfill.
  DATA: BEGIN OF zdbefu OCCURS 0.
          INCLUDE STRUCTURE dbefu.
  DATA: END OF zdbefu.
  DATA: ls_top_id TYPE document_structure.
  DATA: ls_isu_fusszeile_wa_pruefen TYPE isu_fusszeile_wa_pruefen. "IS2ERP

ENHANCEMENT-POINT UPOS_STUELI_01 SPOTS ES_SAPMM07M.

  CHECK vm07m-xnebe = x OR NOT mseg-kzbew = b.
* Auflösung nur für einstufige Leergut-Stücklisten (wird derzeit noch
* nicht von der Artikelstammpflege abgefangen)
  CHECK NOT mbefu-mlgut IS INITIAL.
  CHECK NOT dm07m-uptyp = uptyp_lg.
* Ermitteln der Stücklisten-Komponenten
  PERFORM leerg_stueli_lesen USING mseg-matnr mseg-erfme.
  CHECK sy-subrc IS INITIAL.
* Prüfen, ob Kennung bzgl. Stücklistenauflösung schon sitzt
  READ TABLE ydm07m WITH KEY zeild = a_zeile.
  IF sy-subrc IS INITIAL.
    IF NOT ydm07m-upvor IS INITIAL.
      EXIT.
    ENDIF.
  ENDIF.
  describe table slcomp lines anz_comp.                    "note 544663
  field-symbols <fs_yvm07m> like vm07m.                    "note 544663
  read table yvm07m assigning <fs_yvm07m>                  "note 544663
    with key zeilv = a_zeile.                              "note 544663
  if sy-subrc is initial.                                  "note 544663
    <fs_yvm07m>-line_count = anz_comp.                     "note 544663
  endif.                                                   "note 544663
* Retten aktueller Inhalt FUSS; nach Auflösung wird FUSS neuaufgebaut
* aus YFUSS (erzeugte Unterpositionen) und ZFUSS (alter Inhalt von FUSS)
  REFRESH zfuss.
  LOOP AT fuss.
    zfuss = fuss.
    APPEND zfuss.
  ENDLOOP.
* refresh fuss.
* Abarbeiten der Komponenten und Aufnahme in FUSS
  PERFORM fcode_lesen USING fcod-nl.
  h_urzei = a_zeile.
  h_uebpo = mseg-ebelp.
  DESCRIBE TABLE slcomp LINES anz_comp.
* Kontierungsfelder müssen in Unterpositionen übernommen werden
  IF dm07m_merken IS INITIAL.
    MOVE-CORRESPONDING ymseg TO msegk.
  ELSE.
    MOVE-CORRESPONDING mseg TO msegk.
  ENDIF.
* Prüfungen pro Unterposition, falls Auto-Bestellung
  IF vm07m-xnebe = x AND
     mseg-kzbew = b.
    REFRESH zdbefu.
    LOOP AT slcomp.
      h_erfmg = mseg-erfmg * slcomp-menge / 1000.
      CALL FUNCTION 'ME_CHECK_ITEM'
           EXPORTING
                pi_matnr          = slcomp-idnrk
                pi_menge          = h_erfmg
                pi_meins          = slcomp-meins
                pi_werks          = mseg-werks
                pi_lgort          = mseg-lgort
           IMPORTING
                po_dbefu          = dbefu
           TABLES
*            ito_ekbnk         =
*            ito_ekbnk_cr      =
             ito_ebefu_cr      = xebefu_cr
           EXCEPTIONS
                err_create_head   = 1
                err_create_item   = 2
                err_call_sequence = 3
                OTHERS            = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e250 WITH mseg-zeile.
      ELSE.
        zdbefu = dbefu.
        APPEND zdbefu.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Verarbeiten der Komponenten
  REFRESH yfuss.
* Keep structure data from the parent MSEG-line
  MOVE-CORRESPONDING mseg TO ls_top_id.
  LOOP AT slcomp.
    CLEAR: dm07m, vm07m, mseg, mbefu.
* falls mit Bezug auf Materialbeleg oder Reservierung, sind die
* Belegspositionen gelesen und es werden die relevanten Felder über-
* nommen; ansonsten werden sie aus der eingegebenen Kopfzeile über-
* nommen
    IF dm07m_merken IS INITIAL OR
       yvm07m-xnebe = x.
      MOVE-CORRESPONDING ydm07m TO dm07m_merken.
      MOVE-CORRESPONDING yvm07m TO vm07m_merken.
      MOVE-CORRESPONDING ymseg  TO mseg_merken.
    ENDIF.
    MOVE-CORRESPONDING dm07m_merken TO dm07m.
    MOVE-CORRESPONDING vm07m_merken TO vm07m.
    MOVE-CORRESPONDING mseg_merken  TO mseg.
    CLEAR: mseg-exbwr, mseg-exvkw.

    CLEAR dm07m-upvor.
    mseg-xauto = l.
    dm07m-mekor = x.
    mseg-urzei  = h_urzei.
    dm07m-uebpo = h_uebpo.
    dm07m-uptyp = uptyp_lg.
    mseg-matnr = slcomp-idnrk.
    mseg-erfmg = mseg-erfmg * slcomp-menge / 1000.
    mseg-erfme = slcomp-meins.
* Initialisieren KZ Buchung LVS
    CLEAR: mseg-xblvs.
    IF vm07m-xnebe = x AND
       mseg-kzbew = b.
      READ TABLE zdbefu INDEX sy-tabix.
* vsa_lg start
* check whether full product is managed on a value-only basis
      IF sy-subrc IS INITIAL.
        IF mseg_merken-matnr <> mseg_merken-matbf  AND
           mseg_merken-mengu IS INITIAL            AND
           mseg_merken-wertu = x.
* goods receipt with automatic po?
* if so -> important to store ebelp because of availability check;
* otherwise mb_fill_ekpo_enqueue_table gets the XEKPO of the full
* product when processing the empty - especially XEKPO-BSMNG -> avail.
* check fails
          IF mseg-ebeln = auto_best.
            mseg-ebelp = zdbefu-ebelp.
          ENDIF.
        ENDIF.
      ENDIF.
* vsa_lg end

* damit EBELP in FUSS_FUELLEN addiert wird !
      CLEAR mseg-ebeln.
      mseg-kzvbr = zdbefu-kzvbr.
      mseg-insmk = zdbefu-insmk.
      mseg-bstmg = zdbefu-bstmg.
      mseg-bstme = zdbefu-bstme.
      mseg-bprme = zdbefu-bprme.
      vm07m-webre = zdbefu-webre.
      vm07m-bumrz = zdbefu-umrez.
      vm07m-bumrn = zdbefu-umren.
      dm07m-umrez = zdbefu-umrez.
      dm07m-umren = zdbefu-umren.
      dm07m-bpumz = zdbefu-bpumz.
      dm07m-bpumn = zdbefu-bpumn.
    ENDIF.
    PERFORM fusszeile_wa_pruefen USING x
                                       ls_isu_fusszeile_wa_pruefen. "IS2ERP
    fuss-xselp = x.
    a_zeile = a_zeile + 1.
    mseg-zeile = a_zeile.
* on a GR the line_id is filled at this point with the     "note 331850
* line_id of the parent, in this case the following        "note 331850
* method doesn't change the line_id                        "note 331850
    clear mseg-line_id.                                    "note 331850
    CALL METHOD cl_mmim_line_id_manager=>line_id_get
      CHANGING c_line_id = mseg-line_id.
    mseg-parent_id  = ls_top_id-line_id.
    mseg-line_depth = ls_top_id-line_depth + 1.
    PERFORM fuss_fuellen USING x.

ENHANCEMENT-POINT UPOS_STUELI_02 SPOTS ES_SAPMM07M.
  ENDLOOP.
* FUSS neu aufbauen aus generierten Unterpositionen (YFUSS) und
* altem Inhalt (ZFUSS)
  REFRESH fuss.
  LOOP AT yfuss.
    fuss = yfuss.
    APPEND fuss.
  ENDLOOP.
  LOOP AT zfuss.
    fuss = zfuss.
    IF fuss-fcode = fcod-np.
* wenn eine Sammelartikelzeile 'verschoben' wird bzgl. Zeilennummer,
* müssen auch die Referenzen in VAR_FUSS angepaßt werden
      IF fuss-attyp = attyp-sam.
        LOOP AT var_fuss WHERE kopf_zeile = fuss-zeile.
          var_fuss-kopf_zeile = var_fuss-kopf_zeile + anz_comp.
          MODIFY var_fuss.
        ENDLOOP.
      ENDIF.
      fuss-zeild = fuss-zeild + anz_comp.
      fuss-zeilv = fuss-zeilv + anz_comp.
      fuss-zeile = fuss-zeile + anz_comp.
    ENDIF.
    APPEND fuss.
  ENDLOOP.
* in Kopfzeile Kennung setzen, daß abhängige Zeilen existieren
  READ TABLE ydm07m WITH KEY zeild = h_urzei.
  IF sy-subrc IS INITIAL.
    ydm07m-upvor = uptyp_lg.
*   ydm07m-uptyp = uptyp_lg.
    MODIFY ydm07m INDEX sy-tabix.
  ENDIF.

ENDFORM.