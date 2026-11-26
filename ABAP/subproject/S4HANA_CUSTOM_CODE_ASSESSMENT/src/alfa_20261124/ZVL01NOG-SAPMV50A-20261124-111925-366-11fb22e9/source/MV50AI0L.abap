************************************************************************
*                                                                      *
* PAI Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "L" beginnend             *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       MODULE LIEFERAVIS-CHECK                                       *
*---------------------------------------------------------------------*
*       Beim Verändern werden die bestellungen gesperrt und eine      *
*       Berechtigungsprüfung durchgeführt                             *
*---------------------------------------------------------------------*
MODULE lieferavis_check.

  PERFORM lieferavis_check.

ENDMODULE.                    "lieferavis_check
*eject


*---------------------------------------------------------------------*
*       MODULE LIEFERAVIS-VORBER                                      *
*---------------------------------------------------------------------*
*       Durch Referenz auf Bestellung(en) wurde ein Lieferavis        *
*       erstellt, zu seiner Bearbeitung sind Ergänzungen erforderlich *
*---------------------------------------------------------------------*
MODULE lieferavis_vorbereit.

  PERFORM lieferavis_vorbereiten.

ENDMODULE.                    "lieferavis_vorbereit
*eject


*---------------------------------------------------------------------*
*       MODULE LIEFERAVIS-eatab                                       *
*---------------------------------------------------------------------*
*       Für ein Lieferavis wird die EATAb vorbereitet                 *
*---------------------------------------------------------------------*
MODULE lieferavis_eatab.

  PERFORM lieferavis_eatab_fuellen.
*##ngr-anf
  PERFORM lips_datentransfer_in_ea.
*##ngr-end

ENDMODULE.                    "lieferavis_eatab
*eject

*---------------------------------------------------------------------*
*       MODULE LIEF_O_AUFT_ERLAUBT                                    *
*---------------------------------------------------------------------*
*       Überprüfen, ob die Erstellung eines Lieferscheins             *
*       ohne Auftragsbezug generell möglich ist.                      *
*       Dies kann über Tabelle TVLK, Auftrag erforderlich (TVLK-AUFER)*
*       gesteuert werden.                                             *
*       TVLK-AUFER = X     =>    ein Auftrag ist erforderlich         *
*       TVLK-AUFER = ' '   =>    ein Auftrag ist nicht erforderlich   *
*---------------------------------------------------------------------*
MODULE lief_o_auft_erlaubt.

  PERFORM lief_o_auft_erlaubt.

ENDMODULE.                    "lief_o_auft_erlaubt
*eject
*---------------------------------------------------------------------*
*       MODULE LIEF_O_AUFT_ERLAUBT_ND                                 *
*---------------------------------------------------------------------*
*   Check whether delivery type can be used for a delivery without
*   preceding document
* ------------------------------------------------------------------*
MODULE lief_o_auft_erlaubt_nd.

  PERFORM lief_o_auft_erlaubt_nd.

ENDMODULE.                    "lief_o_auft_erlaubt_nd
*eject


*---------------------------------------------------------------------*
*       MODULE LIKP_AUS_EA                                            *
*---------------------------------------------------------------------*
*       Lieferavis: Daten aus EATAB in LIKP transportieren            *
*---------------------------------------------------------------------*
MODULE likp_aus_ea.

ENHANCEMENT-POINT MV50AI0L_02 SPOTS ES_SAPMV50A STATIC.
  PERFORM likp_datentransfer_aus_ea.

ENDMODULE.                    "likp_aus_ea
*eject


*---------------------------------------------------------------------*
*       MODULE LIKP_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten des Kopfes der Lieferung                           *
*---------------------------------------------------------------------*
MODULE likp_bearbeiten.
ENHANCEMENT-POINT MV50AI0L_03 SPOTS ES_SAPMV50A.

  PERFORM likp_bearbeiten(sapfv50k).


ENDMODULE.                    "likp_bearbeiten
*eject

*---------------------------------------------------------------------*
*       MODULE LIKP_BEARBEITEN_ND                                     *
*---------------------------------------------------------------------*
*       Process the delivery header if global work flag has been set  *
*---------------------------------------------------------------------*
MODULE likp_bearbeiten_nd.

  CHECK gf_header_work_flag NE space.
  CLEAR gf_header_work_flag.
  PERFORM likp_bearbeiten(sapfv50k).


ENDMODULE.                    "likp_bearbeiten_nd
*eject


*---------------------------------------------------------------------*
*       MODULE LIKP_FUELLEN                                           *
*---------------------------------------------------------------------*
*       Beim Hinzufügen einer stand-alone Lieferung werden bestimmte  *
*       Daten vorgeschlagen                                           *
*---------------------------------------------------------------------*
MODULE likp_fuellen.
  IF lieferung_or EQ charx   AND
     slikp-tabix = 0.
    PERFORM auftraggeber_bereitstellen(sapmv50a).    "z.B. für Statistik
    PERFORM likp_fuellen_or(sapfv50k).
    PERFORM route_pruefen_konsistenz(sapfv50k).
  ENDIF.

ENDMODULE.                    "likp_fuellen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Kommunikations-Identifikation                 *
*---------------------------------------------------------------------*
MODULE likp-commn_pruefen.

  PERFORM tqcom_select USING likp-commn.

ENDMODULE.                    "likp-commn_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Gewichte                                      *
*---------------------------------------------------------------------*
MODULE likp_gewicht_pruefen.

* Auf allen Dynpros, auf denen nur das Gesamtgewicht gepflegt werden
* kann, wird bei Änderung der Gewichtseinheit das Nettogewicht
* automatisch in die neue Einheit umgerechnet
  PERFORM eingabe_gewicht_pruefen_neu USING    likp-btgew
                                               *likp-gewei
                                               likp-gewei
                                      CHANGING likp-ntgew.








  PERFORM likp_gewichtsgruppe_ermitteln(sapfv50k) USING chark.

ENDMODULE.                    "likp_gewicht_pruefen
*eject


*----------------------------------------------------------------------*
*  Lieferungs Modus bestimmen                                          *
*----------------------------------------------------------------------*
*  Falls beim Anlegen eines Lieferscheins keine Vertriebsbelegnummer   *
*  eingegeben wird, wird ein auftragsneutraler Lieferschein            *
*  angelegt. Gesteuert wird dies über das Kennzeichen LF_Modus.        *
*  LF_MODUS = ON  ('X') =>  Lieferschein MIT  Auftragsbezug.           *
*  LF_MODUS = OFF (' ') =>  Lieferschein OHNE Auftragsbezug.           *
*----------------------------------------------------------------------*
MODULE lf_modus_bestimmen.
  IF likp-vbeln = space.
    lf_modus = on.                     "Lieferschein MIT Auftragsbezug
  ELSE.
    lf_modus = off.                    "Lieferschein OHNE Auftragsbezug
  ENDIF.
ENDMODULE.                    "lf_modus_bestimmen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Datumsangaben                                 *
*---------------------------------------------------------------------*
MODULE likp_datum_pruefen.

* Do not check dates if rescheduling function is active
  IF fcode EQ 'NEUT_T' AND
     NOT ( tvlk-neute EQ space AND
           tvlk-aufer NE gc_aufer-sales_order ).
    EXIT.
  ENDIF.

* Discard seconds while checking shipping dates "470
  IF likp-kodat GT 0.
    IF likp-lddat GT 0          AND likp-kodat GT likp-lddat  OR
     ( likp-kodat EQ likp-lddat AND likp-kouhr(4) GT likp-lduhr(4) ).
      MESSAGE w273.
    ENDIF.
    IF likp-wadat GT 0          AND likp-kodat GT likp-wadat  OR
     ( likp-kodat EQ likp-wadat AND likp-kouhr(4) GT likp-wauhr(4) ).
      MESSAGE w274.
    ENDIF.
    IF likp-lfdat GT 0          AND likp-kodat GT likp-lfdat  OR
     ( likp-kodat EQ likp-lfdat AND likp-kouhr(4) GT likp-lfuhr(4) ).
      MESSAGE w275.
    ENDIF.
  ENDIF.

  IF likp-tddat GT 0.
    IF likp-lddat GT 0          AND likp-tddat GT likp-lddat  OR
     ( likp-tddat EQ likp-lddat AND likp-tduhr(4) GT likp-lduhr(4) ).
      MESSAGE w050.
    ENDIF.
    IF likp-wadat GT 0          AND likp-tddat GT likp-wadat  OR
     ( likp-tddat EQ likp-wadat AND likp-tduhr(4) GT likp-wauhr(4) ).
      MESSAGE w051.
    ENDIF.
    IF likp-lfdat GT 0          AND likp-tddat GT likp-lfdat  OR
     ( likp-tddat EQ likp-lfdat AND likp-tduhr(4) GT likp-lfuhr(4) ).
      MESSAGE w052.
    ENDIF.
  ENDIF.

  IF likp-lddat GT 0.
    IF likp-wadat GT 0          AND likp-lddat GT likp-wadat  OR
     ( likp-lddat EQ likp-wadat AND likp-lduhr(4) GT likp-wauhr(4) ).
      MESSAGE w053.
    ENDIF.
    IF likp-lfdat GT 0          AND likp-lddat GT likp-lfdat  OR
     ( likp-lddat EQ likp-lfdat AND likp-lduhr(4) GT likp-lfuhr(4) ).
      MESSAGE w054.
    ENDIF.
  ENDIF.

  IF likp-wadat GT 0.
    IF likp-lfdat GT 0          AND likp-wadat GT likp-lfdat  OR
     ( likp-wadat EQ likp-lfdat AND likp-wauhr(4) GT likp-lfuhr(4) ).
      MESSAGE w055.
    ENDIF.
  ENDIF.

* Recalculate billing date on changes of the shipping dates
  PERFORM likp_fakturadatum_berechnen(sapfv50k) USING likp
                                                      likp.

* Check whether material availability date is not later than delivery
* date
  IF ( likp-lfdat NE *likp-lfdat OR likp-lfuhr NE *likp-lfuhr ).
    PERFORM date_consistency_check USING    charx
                                            posnr_low
                                            '00000000'
                                            '000000'
                                   CHANGING gf_subrc.
    IF gf_subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    PERFORM mark_items_for_update.                          "n_603921
    perform set_lfdat_at_xs073.                            "n_1072322
  ENDIF.

ENDMODULE.                    "likp_datum_pruefen
*eject

*---------------------------------------------------------------------*
*       Eingabepruefung: Finanzdokumente                              *
*       Setzen des Umrechnungskurses FDWaehrung und Hauswaehrung      *
*---------------------------------------------------------------------*
MODULE likp_fdokument_pruefen.

*------- Finanzdokument-Daten uebernehmen
  CHECK likp-lcnum NE *likp-lcnum OR
        likp-akprz NE *likp-akprz.

*------- Erste Pruefung: Abschreibung nur moeglich wenn FDNummer zug.
  IF       likp-lcnum IS INITIAL AND
     NOT ( likp-akprz IS INITIAL ) .
    MESSAGE e570(ei) WITH likp-akprz.
  ENDIF.

*------- Zweite Pruefung: Abschreibung zwischen 0 % und 100 %
  IF       likp-akprz GT 10000.
    MESSAGE e579(ei) WITH likp-akprz.
  ENDIF.

*------- Relevante Daten haben sich geaendert
  IF likp-lcnum IS INITIAL.
    CLEAR: likp-akwae,
           likp-akkur.
    EXIT.
  ENDIF.

  DATA: da_kursk      LIKE likp-akkur,
        da_erdat      LIKE likp-erdat,
        da_t001_waers LIKE t001-waers.

*------- Lesen Finanzdokumentdaten
  CALL FUNCTION 'RV_LOC_DATA_READ'
    EXPORTING
      i_enqueue_necessary    = 'X'
      i_fin_doc_number       = likp-lcnum
    IMPORTING
      e_fin_doc_currency     = likp-akwae
    EXCEPTIONS
      foreign_lock           = 1
      system_failure         = 2
      fin_doc_does_not_exist = 3
      OTHERS                 = 4.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE e539(ei).
    WHEN 2.
      MESSAGE e549(ei).
    WHEN 3.
      MESSAGE e563(ei) WITH likp-lcnum.
    WHEN OTHERS.
*------- Nada
  ENDCASE.

*------ Setzen Umrechnungskurs zwischen Hauswaehrung und FDWaehrung
*------ Zuerst: Ermitteln Hauswaehrung
  CALL FUNCTION 'RV_LOC_ORDER_DATA_RETRIEVE'
    EXPORTING
      i_sd_order_comp_code    = cvbak-bukrs_vf
      i_sd_order_sales_org    = cvbak-vkorg
      i_sd_deliv_sales_org    = likp-vkorg
    IMPORTING
      e_currency_company_code = da_t001_waers.

  IF likp-akwae EQ da_t001_waers.
    da_kursk = 1.

  ELSE.
    MOVE likp-erdat TO da_erdat.

    CALL FUNCTION 'READ_EXCHANGE_RATE'
      EXPORTING
        date             = da_erdat
        foreign_currency = likp-akwae
        local_currency   = da_t001_waers
      IMPORTING
        exchange_rate    = da_kursk
      EXCEPTIONS
        no_rate_found    = 1.

    IF NOT ( sy-subrc IS INITIAL ).
      MESSAGE e571(ei) WITH likp-akwae da_t001_waers da_erdat.
      CLEAR: likp-akwae.
    ENDIF.

  ENDIF.

  IF da_kursk NE likp-akkur.
    likp-akkur = da_kursk.
  ENDIF.

ENDMODULE.                    "likp_fdokument_pruefen
*eject

*---------------------------------------------------------------------*
*       Eingabeprüfung: Fakturasperre                                 *
*---------------------------------------------------------------------*
MODULE likp-faksk_pruefen.

  PERFORM tvfsp_select USING likp-faksk
                       charx
                       sy-subrc.

ENDMODULE.                    "likp-faksk_pruefen
*eject

*---------------------------------------------------------------------*
*       Eingabeprüfung: Lieferungsart                                 *
*---------------------------------------------------------------------*
MODULE likp-lfart_pruefen.

  CHECK fcode(4) NE fcode_abbrechen                         "46A BEY
    AND fcode(4) NE fcode_ende.

  IF likp-lfart IS INITIAL
     OR likp-lfart = '?'.
    SET CURSOR FIELD likp-lfart.
    MESSAGE e068.
  ENDIF.

  PERFORM tvlk_select USING likp-lfart
                      space
                      sy-subrc.
  IF sy-subrc NE 0.
    MESSAGE e309 WITH likp-lfart.
  ENDIF.
  likp-vbtyp = tvlk-vbtyp.
  SET PARAMETER ID 'ALT' FIELD likp-lfart.                  "46A BEY

ENDMODULE.                    "likp-lfart_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Liefersperre                                  *
*---------------------------------------------------------------------*
MODULE likp-lifsk_pruefen.

  PERFORM tvls_select USING likp-lifsk
                      charx
                      sy-subrc.

ENDMODULE.                    "likp-lifsk_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Ladestelle                                    *
*---------------------------------------------------------------------*
MODULE likp-lstel_pruefen.

  PERFORM tvla_select USING likp-vstel
                            likp-lstel
                            charx
                            sy-subrc.

ENDMODULE.                    "likp-lstel_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Route                                         *
*---------------------------------------------------------------------*
MODULE likp-route_pruefen.

  PERFORM route_pruefen_eingabe(sapfv50k).

ENDMODULE.                    "likp-route_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Transporttyp                                  *
*---------------------------------------------------------------------*
MODULE likp-traty_pruefen.

  IF NOT likp-traid IS INITIAL AND
         likp-traty IS INITIAL.
    MESSAGE e145.
  ENDIF.

  PERFORM tvty_select USING likp-traty
                      charx
                      sy-subrc.

ENDMODULE.                    "likp-traty_pruefen
*eject

*---------------------------------------------------------------------*
*       Eingabeprüfung: Verkaufsorganisation                          *
*---------------------------------------------------------------------*
MODULE likp-vkorg_pruefen.

  CHECK fcode(4) NE fcode_abbrechen.                        "46A BEY

  IF likp-vkorg IS INITIAL
    OR likp-vkorg = '?'.
    MESSAGE e090.
  ELSE.
    PERFORM tvko_select USING likp-vkorg
                      charx
                      sy-subrc.
  ENDIF.
ENDMODULE.                    "likp-vkorg_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Volumen                                       *
*---------------------------------------------------------------------*
MODULE likp_volumen_pruefen.

  PERFORM eingabe_volumen_pruefen USING likp-volum
                                        likp-voleh.

ENDMODULE.                    "likp_volumen_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Versandstelle                                 *
*---------------------------------------------------------------------*
MODULE likp-vstel_pruefen.

  CHECK fcode(4) NE fcode_abbrechen.                        "46A BEY

  PERFORM tvst_select USING likp-vstel
                      charx
                      sy-subrc.

ENDMODULE.                    "likp-vstel_pruefen
*eject
*---------------------------------------------------------------------*
*       Eingabeprüfung: Versandbedingung                              *
*---------------------------------------------------------------------*
MODULE likp-vsbed_pruefen.

  DATA: lf_route_old LIKE likp-route.                       "n_530694

  PERFORM tvsb_select USING likp-vsbed
                      charx
                      sy-subrc.
  IF likp-vsbed NE *likp-vsbed AND
     tvlk-routf NE space       AND                         "v_n_1303291
     likp-grulg NE space.                                  "^_n_1303291

    lf_route_old = likp-route.                              "n_530694

    PERFORM route_ermitteln(sapfv50k) USING likp-route
                                            charx
                                            sy-subrc.


*   ggf. werden die Exportdaten neu ermittelt                "v_n_530694
    IF NOT likp-expkz IS INITIAL      AND
           likp-route NE lf_route_old    .
      PERFORM likp_export_bestimmen(sapfv50k).
    ENDIF.                                                  "^_n_530694

  ENDIF.

ENDMODULE.                    "likp-vsbed_pruefen
*eject


*---------------------------------------------------------------------*
*       MODULE LIPS_ANLEGEN_VORSCHL                                   *
*---------------------------------------------------------------------*
*       Fcode LIPS_ANLEGEN wird vorgeschlagen, wenn in die letzte     *
*       Zeile eine Position eingegeben und kein Fcode eingegeben wurde*
*---------------------------------------------------------------------*
MODULE lips_anlegen_vorschl.

  IF lips-posnr > 0 AND
     slips-tabix = 0 AND
     sy-loopc = sy-stepl.

    fcode = fcode_xlips_anlegen.
    PERFORM transform_fcode CHANGING fcode.
  ENDIF.
* Lines deleted n_583914/n_633732

ENDMODULE.                    "lips_anlegen_vorschl
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Bewertungsart                                 *
*---------------------------------------------------------------------*
MODULE lips-bwtar_pruefen.

  PERFORM lips-bwtar_pruefen(sapfv50p) USING space.

ENDMODULE.                    "lips-bwtar_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Charge                                        *
*---------------------------------------------------------------------*
MODULE lips-charg_pruefen.

  PERFORM lips-charg_pruefen(sapfv50p).
  PERFORM lips_fuellen_charge(sapfv50p).
  IF lips-kzfme CA kzfme_ws AND
     ( lips-umvkn <> *lips-umvkn OR
       lips-umvkz <> *lips-umvkz ).
    PERFORM lips-vrkme_pruefen(sapfv50p).
  ENDIF.

* Check for CBATP
  CALL FUNCTION 'VBXD_CUOBJ_CBATP_CHECK_AND_SET'
    EXPORTING
      i_material       = lips-matnr
      i_batch          = lips-charg
      i_plant          = lips-werks
    CHANGING
      c_cuobj_ch       = lips-cuobj_ch
    EXCEPTIONS
      no_plant         = 1
      unknown_cuobj_ch = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                    "lips-charg_pruefen
*---------------------------------------------------------------------*
*       MODULE LIPS-CHARG_PRUEFEN_A                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE lips-charg_pruefen_a.
  if lips-kzfme ca kzfme_ws and
     NOT lips-charg IS INITIAL AND
     *lips-charg IS INITIAL .
    PERFORM lips-charg_pruefen(sapfv50p).
    PERFORM lips_fuellen_charge(sapfv50p).
    IF ( lips-umvkn <> *lips-umvkn OR
         lips-umvkz <> *lips-umvkz ).
      PERFORM lips-vrkme_pruefen(sapfv50p).
    ENDIF.
  ENDIF.
  IF productselection NE charx OR                           "v_n_713689
  NOT lips-uecha IS INITIAL.
     IF MAAPV-MTPOS is initial.
         PERFORM MAAPV_SELECT(SAPFV50P) USING CLIPS-MATNR
                                         LIKP-VKORG
                                         CLIPS-VTWEG
                                         SY-SUBRC.
     ENDIF.
    CALL FUNCTION 'RV_LIPS_PSTYV_DETERMINE'                 "v_n_796382
         exporting
              t184l_lfart         = likp-lfart
              t184l_mtpos         = maapv-mtpos
              t184l_uepst         = clips-pstyv
              t184l_vwpos         = 'CHSP'
              lips_pstyv_i        = '    '
         importing
              lips_pstyv          = lips-pstyv
         exceptions
              eintrag_nicht_da    = 1
              pstyv_nicht_erlaubt = 2.
    IF sy-subrc <> 0.
      CALL FUNCTION 'RV_LIPS_PSTYV_DETERMINE'
              exporting
                   t184l_lfart         = likp-lfart
                   t184l_mtpos         = maapv-mtpos
                   t184l_uepst         = '    '
                   t184l_vwpos         = 'CHSP'
                   lips_pstyv_i        = '    '
              importing
                   lips_pstyv          = lips-pstyv
              exceptions
                   eintrag_nicht_da    = 1
                   pstyv_nicht_erlaubt = 2.
    ENDIF.                                                  "v_n_796382
  ENDIF.
  PERFORM tvlp_select(sapmv50a) USING lips-pstyv sy-subrc.  "^_n_713689
  check tvlp-chpkz is initial.
* get the correct sales order item                          "v_n_805263
  IF NOT clips-vgbel IS INITIAL          AND
     NOT clips-vgpos IS INITIAL          AND
         clips-vgtyp CA VBTYP_VERK       AND
       ( clips-vgbel NE cvbap-vbeln OR
         clips-vgpos NE cvbap-posnr    ) AND
         slips-tabix = 0.
    PERFORM VBAP_SELECT_SINGLE_BUFFER(SAPMV50A)             "v_n_822538
                                   USING HELP-MANDT
                                         CLIPS-VGBEL
                                         CLIPS-VGPOS.       "^_n_822538
  ENDIF.                                                    "^_n_805263
  PERFORM lips-charg_pruefen_allgemein_1(sapfv50p) USING
                                             lips-matnr
                                             lips-werks
                                             lips-charg
                                             lips-sobkz
                                             lips-eprio
                                             lips-rules
                                             lips-kzbef
                                             sy-datlo
                                             likp-lfdat
                                             charx
                                             sy-subrc.

* Check for CBATP
  CALL FUNCTION 'VBXD_CUOBJ_CBATP_CHECK_AND_SET'
    EXPORTING
      i_material       = lips-matnr
      i_batch          = lips-charg
      i_plant          = lips-werks
    CHANGING
      c_cuobj_ch       = lips-cuobj_ch
    EXCEPTIONS
      no_plant         = 1
      unknown_cuobj_ch = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                    "lips-charg_pruefen_a
*eject

*---------------------------------------------------------------------*
*       MODULE LIPSD-DOCUBATCH_CHARG_PRUEFEN                          *
*---------------------------------------------------------------------*
MODULE lipsd-docubatch_charg_pruefen.

  PERFORM docubatch_detail_open.
  PERFORM docubatch_detail_close.

ENDMODULE.                    "lipsd-docubatch_charg_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS_AUS_EA                                            *
*---------------------------------------------------------------------*
*       Lieferavis: Daten aus EATAB in LIPS transportieren            *
*---------------------------------------------------------------------*
MODULE lips_aus_ea.



  PERFORM lips_datentransfer_aus_ea.


ENDMODULE.                    "lips_aus_ea
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Fakturasperre                                 *
*---------------------------------------------------------------------*
MODULE lips-faksp_pruefen.

  PERFORM tvfsp_select USING lips-faksp
                       charx
                       sy-subrc.

ENDMODULE.                    "lips-faksp_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Gewichte                                      *
*---------------------------------------------------------------------*
MODULE lips_gewicht_pruefen.

  PERFORM eingabe_gewicht_pruefen USING lips-brgew
                                        lips-ntgew
                                        lips-gewei.

ENDMODULE.                    "lips_gewicht_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS-LFIMG_PRUEFEN                                    "#&
*---------------------------------------------------------------------*
*       Eingabeprüfung: Liefermenge                                   *
*---------------------------------------------------------------------*
MODULE lips-lfimg_pruefen.             "#&

  PERFORM lips_quan_set(sapfv50p) USING 'A' space.
  PERFORM lips-lfimg_pruefen(sapfv50p) USING 'X'.

ENDMODULE.                    "lips-lfimg_pruefen
*eject


*----------------------------------------------------------------------*
*       Module  LIPS-LFIMG_RUECK                                   "#&rm
*----------------------------------------------------------------------*
*       Rückrechnen der Liefermenge aus der Gesamtliefermenge         *
*---------------------------------------------------------------------*
MODULE lips-lfimg_rueck.

  PERFORM lips-lfimg_rueckrechnen(sapfv50p).

  IF lips-vrkme EQ *lips-vrkme.                             "HP_354692
    PERFORM lips_quan_set(sapfv50p) USING 'A' space.        "HP_339897
  ENDIF.
  rv50a-vrkm1 = lips-vrkme.

* Check whether dependend items allow a quantity change
  IF lips-lfimg NE *lips-lfimg OR
     lips-vrkme NE *lips-vrkme.
    PERFORM lips_correlation_check(sapfv50p) USING    lips
                                             CHANGING gf_subrc.
    IF gf_subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDMODULE.                             " LIPS-LFIMG_RUECK


*---------------------------------------------------------------------*
*       MODULE LIEFERDATUM_PRUEFEN                                    *
*---------------------------------------------------------------------*
*       Lieferavis: Lieferdatum wird gegen die Werkskalender geprueft *
*---------------------------------------------------------------------*

MODULE lieferdatum_pruefen.

  DATA: BEGIN OF xwerk OCCURS 10,
          werks LIKE lips-werks,
        END OF xwerk.

  REFRESH xwerk.
  LOOP AT xlips WHERE NOT werks IS INITIAL.
    xwerk-werks = xlips-werks.
    READ TABLE xwerk WITH KEY xwerk BINARY SEARCH.
    IF sy-subrc <> 0.
      INSERT xwerk INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  LOOP AT xwerk.
    PERFORM lieferavisdatum_pruefen(sapfv50k) USING rv50a-lfdat_la
                                                    xwerk-werks
                                                    sy-subrc.
  ENDLOOP.
ENHANCEMENT-POINT MV50AI0L_04 SPOTS ES_SAPMV50A.

ENDMODULE.                    "lieferdatum_pruefen


*---------------------------------------------------------------------*
*       MODULE LIPS-LGORT_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Lagerort                                      *
*---------------------------------------------------------------------*
MODULE lips-lgort_pruefen.

  PERFORM lips-hupos_check(sapfv50p).
  PERFORM lips-lgort_pruefen(sapfv50p) USING charx.

ENDMODULE.                    "lips-lgort_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS-MATNR_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Materialnummer prüfen                         *
*---------------------------------------------------------------------*
MODULE lips-matnr_pruefen.

* Beim Löschen der Materialnummer beim Anlegen der Position
* (nach einem Fehler in der Materialprüfung) wird die Position gelöscht
  IF lips-matnr CO '0 ' AND                                 "46A/45B
     lips-posar NA 'BC' AND
     slips-tabix eq 0   and
     ( ( not gf_arktx_new is initial or                        "n_829304
         not gf_arktx_old is initial )                         "n_829304
     or ( gf_arktx_new is initial and                       "v_n_1511091
          gf_arktx_old is initial and
          not gf_matnr_old is initial ) ).                  "^_n_1511091
    CLEAR: maapv.
    MOVE-CORRESPONDING maapv TO lips.
    clear lips-matwa.                                          "n_755548
    exit.
  ENDIF.

  PERFORM lips-matnr_pruefen(sapfv50p) USING sy-subrc.

ENDMODULE.                    "lips-matnr_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS-MATNR_0_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Materialnummer prüfen                         *
*---------------------------------------------------------------------*
MODULE lips-matnr_0_pruefen.

  PERFORM lips-matnr_null_pruefen(sapfv50p).

ENDMODULE.                    "lips-matnr_0_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS-POSNR_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Positionsnummer                               *
*---------------------------------------------------------------------*
MODULE lips-posnr_pruefen.

  PERFORM lips-posnr_pruefen(sapfv50p).

ENDMODULE.                    "lips-posnr_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Seriennummer                                  *
*---------------------------------------------------------------------*
MODULE lips-sernr_pruefen.

  PERFORM lips-sernr_pruefen(sapfv50p).

ENDMODULE.                    "lips-sernr_pruefen
*eject


*---------------------------------------------------------------------*
*       MODULE LIPS-VRKME_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Ermitteln bzw. Pruefen Mengeneinheit und Umrechnungsfaktoren  *
*---------------------------------------------------------------------*
MODULE lips-vrkme_pruefen.

  IF lips-matnr <> *lips-matnr OR
     lips-umvkn <> *lips-umvkn OR                           "SP_336025
     lips-umvkz <> *lips-umvkz OR                           "SP_336025
     lips-vrkme <> *lips-vrkme.
*... Uom must not be changed in POD scenario
    IF ( lips-vrkme NE *lips-vrkme   OR
         lips-umvkn NE *lips-umvkn   OR                     "SP_336025
         lips-umvkz NE *lips-umvkz   OR                     "SP_336025
         lips-meins NE *lips-meins ) AND NOT
         lips-kzpod IS INITIAL       AND
         likp-vbtyp EQ char7.
      MESSAGE e655(vl).
    ENDIF.

*   Nur bei Änderung Material oder Einheit, aber trotzdem muß Pickmenge
*   im ABAP bekannt sein. (Dynpro 220)
    PERFORM lips-vrkme_pruefen(sapfv50p).
  ENDIF.

ENDMODULE.                    "lips-vrkme_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Uebergeordnete Position                       *
*---------------------------------------------------------------------*
MODULE lips-uepos_pruefen.

  PERFORM lips-uepos_pruefen(sapfv50p).

ENDMODULE.                    "lips-uepos_pruefen
*eject


*---------------------------------------------------------------------*
*       Eingabeprüfung: Volumen                                       *
*---------------------------------------------------------------------*
MODULE lips_volumen_pruefen.

  PERFORM eingabe_volumen_pruefen USING lips-volum
                                        lips-voleh.

ENDMODULE.                    "lips_volumen_pruefen
*eject

*---------------------------------------------------------------------*
*       MODULE LIPS-WERKS_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Werk                                          *
*---------------------------------------------------------------------*
MODULE lips-werks_pruefen.

  PERFORM lips-hupos_check(sapfv50p).
  PERFORM lips-werks_pruefen(sapfv50p) USING lips-werks
                                             lips-lgort
                                             charx
                                             gf_subrc.      "n_521531

  PERFORM lips_fuellen_bedarfsart(sapfv50p).

  IF NOT ( likp-expkz IS INITIAL )
     AND *lips-werks NE lips-werks.
    PERFORM lips_fuellen_export(sapfv50p).
  ENDIF.

ENHANCEMENT-POINT LIPS_WERKS_PRUEFEN_01 SPOTS ES_SAPMV50A.

ENDMODULE.                    "lips-werks_pruefen
*&---------------------------------------------------------------------*
*&      Module  LIKP-AULWE_PRUEFEN  INPUT
*&----------------------------------------------------------------------
*       text                                                           *
*----------------------------------------------------------------------*
MODULE likp-aulwe_pruefen INPUT.

ENHANCEMENT-SECTION     MV50AI0L_01 SPOTS ES_SAPMV50A.
  PERFORM aulwe_pruefen_eingabe(sapfv50k).
END-ENHANCEMENT-SECTION.

ENDMODULE.                             " LIKP-AULWE_PRUEFEN  INPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  LIKP-XBLNR_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE likp-xblnr_check INPUT.

  PERFORM likp_xblnr_check(sapfv50k).

ENDMODULE.                             " LIKP-XBLNR_CHECK  INPUT

ENHANCEMENT-POINT MV50AI0L_05 SPOTS ES_SAPMV50A STATIC .

*&---------------------------------------------------------------------*
*&      Module  LIPS_MPN_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lips_mpn_pruefen INPUT.

  PERFORM mpn_check USING lips-matnr
                          lips-ematn
                          *lips-ematn
                          maapv-mprof
                          lips-werks.

ENDMODULE.                             " LIPS_MPN_PRUEFEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  gg_likp_proli_input_check input
*&---------------------------------------------------------------------*
MODULE gg_likp_proli_input_check INPUT.

  PERFORM gg_likp_proli_input_check USING likp-proli.

ENDMODULE.                 " gg_likp_proli_input_check  INPUT

*&---------------------------------------------------------------------*
*&      Module  lips_lfimg_setzen input                              "#&
*&      manuell eingegebene Liefermenge in alle Mengenfelder übernehmen
*&      Voraussetzung: Mengeneinheit ist gleich geblieben
*&---------------------------------------------------------------------*
MODULE lips_lfimg_setzen INPUT.        "#&

  IF lips-vrkme EQ *lips-vrkme.                             "HP_360423
    PERFORM lips_quan_set(sapfv50p) USING 'A' space.
  ENDIF.

ENDMODULE.                 " lips_lfimg_setzen INPUT                 "#&

*&---------------------------------------------------------------------*
*&      Module  LIPS-PSTYV_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       Check item category on manual changes
*----------------------------------------------------------------------*
MODULE lips-pstyv_pruefen INPUT.                            "46A BEY

  IF lips-pstyv IS INITIAL.
    CLEAR tvlp.
  ELSE.
    PERFORM tvlp_select USING lips-pstyv
                              sy-subrc.
  ENDIF.

ENDMODULE.                             " LIPS-PSTYV_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  LIKP-LFART_PRUEFEN_SO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE likp-lfart_pruefen_so INPUT.

  CHECK fcode(4) NE fcode_abbrechen                         "46A BEY
    AND fcode(4) NE fcode_ende.

  if not likp-lfart is initial.                            "n_780183

    perform tvlk_select using likp-lfart
                      charx
                      sy-subrc.
  IF tvlk-aufer NE charx.
    MESSAGE e115 WITH tvlk-lfart.
  ENDIF.

  likp-vbtyp = tvlk-vbtyp.

  endif.                                                   "n_780183

  set parameter id 'ALT' field likp-lfart.                  "46A BEY


ENDMODULE.                             " LIKP-LFART_PRUEFEN_SO  INPUT

*&---------------------------------------------------------------------*
*&      Module  lips-vfdat_pruefen  INPUT
*&---------------------------------------------------------------------*
*       Check expiration date
*----------------------------------------------------------------------*
MODULE lips-vfdat_pruefen INPUT.

  PERFORM lips-vfdat_pruefen.

ENDMODULE.                             " lips-vfdat_pruefen  INPUT
*---------------------------------------------------------------------*
*       MODULE LIKP-INCOTERMS_PRUEFEN                                 *
*---------------------------------------------------------------------*
MODULE likp-incoterms_pruefen.                              "hp_212850
  IF likp-inco1 IS INITIAL AND
     NOT likp-inco2 IS INITIAL.
    CLEAR likp-inco2.
  ENDIF.

  CALL FUNCTION 'RV_INCOTERMS_CHECK'
    EXPORTING
      inco1           = likp-inco1
      inco2           = likp-inco2
      fieldname_inco1 = 'LIKP-INCO1'
      fieldname_inco2 = 'LIKP-INCO2'.

  PERFORM PREISFINDUNG_GESAMT USING CHARH.                     "n_763383

endmodule.                    "likp-incoterms_pruefen
*&---------------------------------------------------------------------*
*&      Module  lips_quantity_synchronize  INPUT (470)
*&---------------------------------------------------------------------*
*       Synchronization of the given delivery quantity with the set
*       of quantities. Fundamental checks on the delivery quantity.
*----------------------------------------------------------------------*
MODULE lips_quantity_synchronize INPUT.

  IF lips-vrkme EQ *lips-vrkme.
    PERFORM lips_quan_set(sapfv50p) USING 'A' space.
  ENDIF.

* Check whether dependend items allow a quantity change
  IF lips-lfimg NE *lips-lfimg OR
     lips-vrkme NE *lips-vrkme.
    PERFORM lips_correlation_check(sapfv50p) USING    lips
                                             CHANGING gf_subrc.
    IF gf_subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " lips_quantity_synchronize  INPUT
*&---------------------------------------------------------------------*
*&      Module  lips-mbdat_check  INPUT
*&---------------------------------------------------------------------*
*       Check consistency of shipping dates
*----------------------------------------------------------------------*
MODULE lips-mbdat_check INPUT.

  IF ( lips-mbdat NE *lips-mbdat OR lips-mbuhr NE *lips-mbuhr ).

*   Check MBUHR already here (to keep it as 'USING'-parameter)
    IF lips-mbuhr EQ SPACE.
      CLEAR lips-mbuhr.
    ENDIF.

    PERFORM date_consistency_check USING    space
                                            lips-posnr
                                            lips-mbdat
                                            lips-mbuhr
                                   CHANGING gf_subrc.
    IF gf_subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDMODULE.                 " lips-mbdat_check  INPUT
*&---------------------------------------------------------------------*
*&      Module  lips-grund_values  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lips-grund_values INPUT.

  PERFORM lips-grund_values.

ENDMODULE.                             " lips-grund_values  INPUT
*&---------------------------------------------------------------------*
*&      Module  lips-grund_pruefen  INPUT
*&---------------------------------------------------------------------*
MODULE lips-grund_pruefen INPUT.

  PERFORM reason_code_check USING    lips-grund
                                     lips-bwart
                                     charx
                            CHANGING sy-subrc.

ENDMODULE.                 " lips-grund_pruefen  INPUT

*&---------------------------------------------------------------------*
*&      Module  lips_matnr_entered  INPUT
*&---------------------------------------------------------------------*
*       Store changes of lips-matnr and adjust *lips-matnr accordingly
*----------------------------------------------------------------------*
MODULE lips_matnr_entered INPUT.                            "v_n_695260

  PERFORM lips_matnr_entered.

ENDMODULE.                                                  "^_n_695260
*&---------------------------------------------------------------------*
*&      Module  LIPS_UMLGO_CHECK  INPUT
*&---------------------------------------------------------------------*
*       Undistributed deliveries should not allow storage location
*       changes to a dec. WMS or EWM to prevent inconsistent postings
*----------------------------------------------------------------------*
MODULE LIPS_UMLGO_CHECK INPUT.                              "v_n_1646599
  DATA: LS_T340D TYPE T340D.
  IF LIKP-VLSTK  IS INITIAL AND
   ( *LIPS-UMLGO NE LIPS-UMLGO OR
     *LIPS-UMWRK NE LIPS-UMWRK ).
    IF LIPS-UMWRK IS INITIAL.
      if LIPS-UMLGO IS INITIAL.
        CHECK 1 = 2.                 "OK => MBCGM takes over WERKS/LGORT
      else.
        MESSAGE E164(M3).            "Plant input needed for validation
      endif.
    ENDIF.
    CALL FUNCTION 'T001L_SINGLE_READ'
      EXPORTING
        T001L_WERKS = LIPS-UMWRK
        T001L_LGORT = LIPS-UMLGO
     EXCEPTIONS
       OTHERS            = 1 .
    IF SY-SUBRC <> 0.
*     Receiving storage location does not exist
      MESSAGE E103(M3) WITH LIPS-UMLGO LIPS-UMWRK.
    ELSE.
      CLEAR: LS_T340D.
      CALL FUNCTION 'L_LGORT_LGNUM_CHECK'
        EXPORTING
          I_WERKS                             = LIPS-UMWRK
          I_LGORT                             = LIPS-UMLGO
          I_LGDAT                             = CHARX
        IMPORTING
          E_T340D                             = LS_T340D
        EXCEPTIONS
          ENTRY_NOT_IN_T320             = 0  "No warehouse, no problem
          OTHERS                        = 1.
      IF NOT SY-SUBRC       IS INITIAL OR
         NOT LS_T340D-DECSY IS INITIAL.
*       Receiving storage location is not allowed
        MESSAGE E100(VLMOVE) WITH LIPS-UMWRK LIPS-UMLGO.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " LIPS_UMLGO_CHECK  INPUT         ^_n_1646599