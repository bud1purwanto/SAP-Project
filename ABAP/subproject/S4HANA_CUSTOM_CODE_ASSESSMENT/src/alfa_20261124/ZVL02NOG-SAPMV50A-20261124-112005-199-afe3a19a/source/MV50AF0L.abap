***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe L:                                                       *
*                                                                     *
***********************************************************************


*---------------------------------------------------------------------*
*       FORM LIEFERAVIS-CHECK                                         *
*---------------------------------------------------------------------*
*       Berechtigungsprüfung und sperren für die Bestellungen  des    *
*       Lieferavis                                                    *
*---------------------------------------------------------------------*
FORM lieferavis_check.

  IF t180-aktyp EQ chara.
    EXIT.
  ENDIF.

  IF likp-spe_orig_sys EQ '1'.                                      "n_v_1379874
    MESSAGE e019(/spe/id_handling).
  ENDIF.                                                            "n_^_1379874

* Lines deleted n_1017222

ENHANCEMENT-SECTION     MV50AF0L_01 SPOTS ES_SAPMV50A.
  IF xvbuk-hdall IS NOT INITIAL OR xvbuk-hdals IS NOT INITIAL.
*   Inbound delivery is on hold an can only be displayed
    MESSAGE e609(borgr).
  ENDIF.
END-ENHANCEMENT-SECTION.

  CLEAR wueb.
  REFRESH wueb.

  LOOP AT xlips WHERE vgtyp = charv.
    wueb-ebeln = xlips-vgbel.
    wueb-ebelp = xlips-vgpos.
    APPEND wueb.
  ENDLOOP.

  CALL FUNCTION 'ME_CONFIRMATION_LOCK_AVIS'
    TABLES
      t_wueb = wueb.

  CALL FUNCTION 'ME_CONFIRMATION_AUTH_AVIS'
    TABLES
      t_wueb = wueb.

  READ TABLE wueb INDEX 1.
  IF sy-subrc EQ 0.
    MESSAGE e149 WITH wueb-ebeln.
  ENDIF.

ENDFORM.                    "lieferavis_check
*eject


*---------------------------------------------------------------------*
*       FORM LIEFERAVIS-VORBEREITEN                                   *
*---------------------------------------------------------------------*
*       Durch Referenz auf eine Bestellung wurde ein Lieferavis       *
*       erzeugt, für seine Bearbeitung sind Vorarbeiten erforderlich  *
*---------------------------------------------------------------------*
FORM lieferavis_vorbereiten.

  DATA: likp_lines  LIKE sy-tfill.
  DATA: h_vbeln LIKE likp-vbeln.
  DATA: anz_ve  LIKE sy-tabix.
  DATA: lf_xlikp_tabix LIKE sy-tabix,
        lf_subrc LIKE sy-subrc,
        lf_local_sammelgang LIKE v50agl-sammelgang.

  CHECK fcode(4) NE fcode_fehlerprotokoll                   "46A BEY
    AND fcode(4) NE fcode_abbrechen
    AND fcode(4) NE fcode_ende.

* For inbound deliveries automatic packing and text determination has to
* be done in the same roll area as the dialog processing.
  LOOP AT xlikp.                                            "50A
    likp = xlikp.
    lf_xlikp_tabix = sy-tabix.
    PERFORM tvlk_select(sapmv50a) USING xlikp-lfart
                                        charx
                                        lf_subrc.
    IF tvlk-averp EQ charx.
      lf_local_sammelgang = v50agl-sammelgang.
      v50agl-sammelgang = charx.
      PERFORM automatic_packing_delivery USING xlikp.
      MOVE-CORRESPONDING likp TO xlikp.
      MODIFY xlikp INDEX lf_xlikp_tabix.
      v50agl-sammelgang = lf_local_sammelgang.
    ENDIF.

* EhP4 - Serial Number transfer from PO to Inbound Delivery
    IF cl_ops_switch_check=>mm_sfws_serno( ) EQ 'X'.
      PERFORM copy_serial_numbers_from_po USING xlikp.
    ENDIF.

    PERFORM likp_fuellen_texte_sammelgang(sapfv50k).
    PERFORM lips_fuellen_texte_sammelgang(sapfv50p).
  ENDLOOP.

* Kopf bereitstellen
  READ TABLE xlikp INDEX 1.
  MOVE-CORRESPONDING xlikp TO likp.                         "n_618883
  MOVE-CORRESPONDING xlikp TO likpd.
   *likp = likp.
  ylikp = likp.
  slikp-tabix = 1.
  xlikp_updkz = xlikp-updkz.

* Importieren der Exportdaten
  CALL FUNCTION 'EXPIMP_TABLES_IMPORT'.

* Buchungsstring lesen
  PERFORM tvlk_select(sapmv50a) USING likp-lfart
                                      charx
                                      lf_subrc.

* EATAB fuellen
  PERFORM lieferavis_eatab_fuellen.
* Positionsdaten werden getrennt übernommen, da je nach Transaktions-
* einstieg Positionstabelle erst später aufgebaut wird
  PERFORM lips_datentransfer_in_ea.

  LOOP AT xlips WHERE vbeln EQ likp-vbeln.
    lips = xlips.
    PERFORM ilips_anlegen(sapfv50p) USING sy-tabix.
  ENDLOOP.

  ilips_tabix_zeile_1 = 1.

  r185d-dataloss = charx.

  DESCRIBE TABLE xlikp LINES likp_lines.
  IF likp_lines GT 1.
    IF tvlk-vbtyp = vbtyp_grwe.
      MESSAGE w234 WITH likp_lines.
    ELSE.
      MESSAGE s142 WITH likp_lines.                         "46B
    ENDIF.
    v50agl-mult = charx.                                    "n_520457
  ENDIF.
*##ngr-anf
* falls ein Grob-WE mit Bezug zu einem Lieferavis angelegt werden soll,
* wurden im SAPMV50B die Strukturen VERKO und VERPO mit den Versand-
* elementen des Lieferavis versorgt, falls welche vorhanden waren
* es erfolgt aber erst hier der Aufruf der Verpackungsfunktionen, damit
* die Datenkommunikation geregelt ist (Beachte: call dialog in SAPMV50B;
  DESCRIBE TABLE tverko LINES anz_ve.
  IF anz_ve NE 0.
* Übernehmen der temporären Belegnummer in VERPO (wird später in den
* Verpackungsroutinen benötigt).
* Achtung: funktioniert so nur, wenn es sich um eine einzige Lieferung
* handelt; das sollte aber schon gewährleistet sein, da der Bezug
* ebenfalls nur auf ein einzelnes Avis erfolgen kann
    LOOP AT cvbls.
      h_vbeln = cvbls-vbeln_lif.
      EXIT.
    ENDLOOP.
    LOOP AT tverpo.
      tverpo-vbeln = h_vbeln.
      MODIFY tverpo.
    ENDLOOP.
* Aufruf der Verpackungsfunktionsbausteine
    DATA: ls_likp LIKE likpvb, lf_rcode TYPE sysubrc.
    ls_likp = likp.
* Nur übergangsweise:                                            "HUM
    DATA: lt_hu_sernr TYPE vsep_t_husernr.                  "HUM
    PERFORM delivery_packing(sapmv50a) USING space ls_likp  "HUM
                                 CHANGING    tverko[]  tverpo[]"HUM
                                             lt_hu_sernr lf_rcode."HUM
  ENDIF.

ENDFORM.                    "lieferavis_vorbereiten
*eject


*---------------------------------------------------------------------*
*       FORM LIEFERAVIS_EATAB_FUELLEN                                 *
*---------------------------------------------------------------------*
*       Für ein lieferavis wird die EATAB versorgt                    *
*---------------------------------------------------------------------*
FORM lieferavis_eatab_fuellen.

* Datentransfer
  PERFORM likp_datentransfer_in_ea.

* Lieferantenname bereitstellen
  LOOP AT xvbpa WHERE vbeln EQ likp-vbeln AND
                      parvw EQ 'LF'.
    kuwev-name1 = xvbpa-name1.
    kuwev-land1 = xvbpa-land1.
*   Lines deleted n_532800
  ENDLOOP.

ENDFORM.                    "lieferavis_eatab_fuellen
*eject


*---------------------------------------------------------------------*
*       FORM LIEFERUNG_ENTSPERREN                                     *
*---------------------------------------------------------------------*
*       Die Lieferung wird entsperrt                                  *
*---------------------------------------------------------------------*
FORM lieferung_entsperren USING us_vbeln.

  CHECK: t180-trtyp NE chara,
         NOT us_vbeln IS INITIAL.
  CHECK: nicht_sperren = space.

  CALL FUNCTION 'DEQUEUE_EVVBLKE'
    EXPORTING
      vbeln = us_vbeln.

ENDFORM.                    "lieferung_entsperren
*eject


*---------------------------------------------------------------------*
*       FORM LIEFERUNG_SPERREN                                        *
*---------------------------------------------------------------------*
*       Die Lieferung wird komplett und exkusiv gesperrt              *
*---------------------------------------------------------------------*
FORM lieferung_sperren USING us_vbeln LIKE likp-vbeln.

  DATA: lf_delivnumber(10) TYPE c,
        lf_user  TYPE symsgv.                               "n_557750.

  CHECK: t180-trtyp NE chara,
         NOT us_vbeln IS INITIAL.
  CHECK: nicht_sperren = space.
  CHECK: fcode(4) NE 'VL01',                                "46A BEY
         fcode(4) NE 'VL03',
         fcode(4) NE 'VL04',
         fcode(4) NE 'VL06',
         fcode(4) NE fcode_ende.

  CALL FUNCTION 'ENQUEUE_EVVBLKE'
    EXPORTING
      vbeln          = us_vbeln
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.

  CASE sy-subrc.
    WHEN 2.
      WRITE us_vbeln TO lf_delivnumber NO-ZERO.
      WRITE sy-msgv1 TO lf_user.
      MESSAGE e046 WITH lf_delivnumber lf_user.
    WHEN 3.
      MESSAGE e047.
  ENDCASE.

ENDFORM.                    "lieferung_sperren
*eject


*---------------------------------------------------------------------*
*       FORM LIEF_O_AUFT_INIT                                         *
*---------------------------------------------------------------------*
*       Defaultwerte bereitstellen                                    *
*---------------------------------------------------------------------*
FORM lief_o_auft_init.

  DATA: ti_error.

  PERFORM t180_interpretieren USING sy-tcode.

* Unter PBO stehen die GPA-Werte noch nicht zur Verfuegung
* Beim Anlegen werden die Parameter aus dem Memory geholt.
  IF t180-trtyp EQ charh.

    GET PARAMETER ID 'ALT' FIELD likp-lfart.
    GET PARAMETER ID 'VST' FIELD likp-vstel.
    GET PARAMETER ID 'VKO' FIELD likp-vkorg.
    GET PARAMETER ID 'VTW' FIELD rv50a-vtweg.
    GET PARAMETER ID 'SPA' FIELD rv50a-spart.

* Tabelle TVLK + TVLKT lesen
    IF likp-lfart NE space.
      PERFORM tvlk_select USING likp-lfart
                                  ti_error
                                  sy-subrc.
    ENDIF.

* Tabelle TVST + TVSTT lesen
    IF likp-vstel NE space.
      PERFORM tvst_select USING likp-vstel
                                space
                                sy-subrc.
    ENDIF.

* Default Text zur Verkaufsorganisation lesen

    IF likp-vkorg NE space.
      PERFORM tvko_select USING likp-vkorg
                                ti_error
                                sy-subrc.
    ENDIF.

* Default Text zum Vertriebsweg lesen
    IF rv50a-vtweg NE space.
      PERFORM tvtw_select USING rv50a-vtweg
                                  ti_error
                                  sy-subrc.
    ENDIF.

* Default Text zur Sparte lesen
    IF rv50a-spart NE space.
      PERFORM tspa_select USING rv50a-spart
                                  ti_error
                                  sy-subrc.
    ENDIF.
  ENDIF.


* Lieferung ohne Auftragsreferenz
  IF lv50c-vbeln EQ space.
    lieferung_or = charx.
    or_erste_position = charx.
    old_fcode = fcode.
  ENDIF.

ENDFORM.                    "lief_o_auft_init
*eject

*---------------------------------------------------------------------*
*       FORM LIEF_O_AUFT_ERLAUBT                                      *
*---------------------------------------------------------------------*
*       Check whether creation of delivery without preceding document
*       is allowed.
*---------------------------------------------------------------------*
FORM lief_o_auft_erlaubt_nd.

  CASE tvlk-aufer.
    WHEN charx.                        "sales order
      MESSAGE e012 WITH tvlk-lfart.
    WHEN charl.                        "subcontrator delivery
      MESSAGE e300 WITH tvlk-lfart.
    WHEN charp.                                             "project
      MESSAGE e301 WITH tvlk-lfart.
    WHEN charo.                                             "MB11
      MESSAGE e298 WITH tvlk-lfart.
    WHEN charh.                        "MB11/VLMOVE         "n_900410
      MESSAGE e298 WITH tvlk-lfart.                         "n_900410
    WHEN charr.                        "return delivery to vendor
      MESSAGE e297 WITH tvlk-lfart.
    WHEN charb.                        "purchase order
      MESSAGE e613.
  ENDCASE.

ENDFORM.                    "lief_o_auft_erlaubt_nd
*eject
*---------------------------------------------------------------------*
*       FORM LIEF_O_AUFT_ERLAUBT                                      *
*---------------------------------------------------------------------*
*       Überprüfen, ob die Erstellung eines Lieferscheins             *
*       ohne Auftragsbezug generell möglich ist.                      *
*       Dies kann über Tabelle TVLK, Vorgänger erforderlich           *
*       (TVLK-AUFER) gesteuert werden.                                *
*       TVLK-AUFER = X     =>    ein Auftrag ist erforderlich         *
*       TVLK-AUFER = ' '   =>    ein Auftrag ist nicht erforderlich   *
*       TVLK-AUFER = P     =>    ein Projekt ist erforderlich         *
*       TVLK-AUFER = L     =>    eine Lohnbeistellung ist erforderlich*
*       TVLK-AUFER = O     =>    Anlegen über MB11 erforderlich       *
*       TVLK-AUFER = R     =>    Anlegen über MBRL erforderlich       *
*---------------------------------------------------------------------*
FORM lief_o_auft_erlaubt.

  CHECK fcode(4) NE fcode_zurueck                           "46A BEY
    AND fcode(4) NE fcode_abbrechen
    AND fcode(4) NE fcode_ende.

  IF lv50c-vbeln IS INITIAL AND
     tvlk-aufer EQ charx.
* Hier Auswahlmöglichkeit anbieten an Lieferscheinarten
*    CALL SCREEN 104
*         STARTING AT 40 09
*         ENDING   AT 78 20.
    MESSAGE e012 WITH tvlk-lfart.
    fcode = 'VL01'.
  ELSEIF lv50c-vbeln IS INITIAL AND
     tvlk-aufer EQ charl.              "Lieferung in Lohnbeist.
    MESSAGE e300 WITH tvlk-lfart.
    fcode = 'VL01'.
  ELSEIF lv50c-vbeln IS INITIAL AND
     tvlk-aufer EQ charp.              "Lieferung aus Projekten
    MESSAGE e301 WITH tvlk-lfart.
    fcode = 'VL01'.
  ELSEIF lv50c-vbeln IS INITIAL AND    "An-/Auslieferung MB11
     tvlk-aufer EQ charo.
    MESSAGE e298 WITH tvlk-lfart.
    fcode = 'VL01'.
  ELSEIF lv50c-vbeln IS INITIAL AND    "Rücklieferung MBRL
     tvlk-aufer EQ charr.
    MESSAGE e297 WITH tvlk-lfart.
    fcode = 'VL01'.
  ELSEIF lv50c-vbeln IS INITIAL AND    "PP-Lieferung
     tvlk-aufer EQ charw.
    MESSAGE e307 WITH tvlk-lfart.
    fcode = 'VL01'.
  ENDIF.
  IF NOT lv50c-vbeln IS INITIAL AND
     ( tvlk-aufer IS INITIAL OR tvlk-aufer EQ charu ).
    MESSAGE e115 WITH tvlk-lfart.
    fcode = 'VL01'.
  ENDIF.

  IF tvlk-aufer EQ charb.
    MESSAGE e613.
  ENDIF.

ENDFORM.                    "lief_o_auft_erlaubt
*eject

*---------------------------------------------------------------------*
*       FORM LIEFERART_POPUP                                          *
*---------------------------------------------------------------------*
FORM lieferart_popup.

  fcode = fcode_uebersicht_einzeilig.
  IF NOT lv50c-vbeln IS INITIAL.
    CALL SCREEN 103
         STARTING AT 10 05
         ENDING   AT 65 13.
  ELSE.
    fcode = fcode_gleiche_seite.
    MESSAGE s116.
  ENDIF.
  PERFORM fcode_bearbeiten.

ENDFORM.                    "lieferart_popup


*---------------------------------------------------------------------*
*       FORM LIKP_DATENTRANSFER_AUS_EA                                *
*---------------------------------------------------------------------*
*       Für das Lieferavis werden einige spezielle Felder auf den     *
*       Bildern verwendet, um eine geeignete Doku zu erreichen        *
*---------------------------------------------------------------------*
FORM likp_datentransfer_aus_ea.

  CONSTANTS: lc_lifex_len TYPE i VALUE 16.
  DATA: lf_len TYPE i.

* für Grob-WE
  IF likp-vbtyp CA vbtyp_grwe.
    likp-verur = rv50a-verur_gw.
    likp-lifex = rv50a-verur_gw. "LIFEX wird ebenfalls versorgt 45A
    likp-lfdat = rv50a-lfdat_gw.
    likp-lfuhr = rv50a-lfuhr_gw.
* für Lieferavis
  ELSEIF likp-vbtyp CA vbtyp_liav.
*   Das Feld für die externe Lieferungsidentifikation wird nun in dem
*   eigentlich dafür vorgesehenen LIFEX abgespeichert (45A)
*   Im zentralen System wird VERUR mitversorgt; im WMS darf es nicht
*   versorgt werden, da hier die Belegnummer für die Rückmeldung
*   drinsteht
    likp-lifex =  rv50a-verur_la.
    IF likp-verursys IS INITIAL.
      likp-verur = rv50a-verur_la.
    ENDIF.
    likp-lfdat = rv50a-lfdat_la.
    likp-lfuhr = rv50a-lfuhr_la.
    likp-wadat_ist = rv50a-wadat_ist_la.                    "45A
ENHANCEMENT-POINT EHP_LIKP_DATENTRANSFER_EA_01 SPOTS ES_SAPMV50A.

    lf_len = strlen( rv50a-verur_la ).
    IF lf_len GT lc_lifex_len.
      MESSAGE w840.
    ENDIF.
  ENDIF.

ENDFORM.                    "likp_datentransfer_aus_ea

*&---------------------------------------------------------------------*
*&      FORM  LIPS_DATENTRANSFER_AUS_EA
*&---------------------------------------------------------------------*
*       Für Lieferavis und Grob-WE werden einige spezielle Felder auf  *
*       den Bildern verwendet, um eine geeignete Doku zu erreichen     *
*----------------------------------------------------------------------*
FORM lips_datentransfer_aus_ea.

  lips-kdmat = rv50a-kdmat_la.

  IF likp-vbtyp CA vbtyp_grwe.
    lips-lfimg = rv50a-menge_gw.       "#&rm
    lips-vrkme = rv50a-meins_gw.
  ENDIF.

ENDFORM.                               " LIPS_DATENTRANSFER_AUS_EA

*---------------------------------------------------------------------*
*       FORM LIKP_DATENTRANSFER_IN_EA                                 *
*---------------------------------------------------------------------*
*       Für das Lieferavis werden einige spezielle Felder auf den     *
*       Bildern verwendet, um eine geeignete Doku zu erreichen        *
*---------------------------------------------------------------------*
FORM likp_datentransfer_in_ea.

  IF likp-vbtyp CA vbtyp_grwe.
*   Das Feld für die externe Lieferungsidentifikation wird vorzugsweise
*   aus dem eigentlich dafür vorgesehenen LIFEX versorgt, nur aus
*   Kompatibilitätsgründen wird noch aus VERUR gefüllt (45A)
    IF NOT likp-lifex IS INITIAL.
      rv50a-verur_gw = likp-lifex.
    ELSE.
      rv50a-verur_gw = likp-verur.
    ENDIF.
    rv50a-lfdat_gw = likp-lfdat.
    rv50a-lfuhr_gw = likp-lfuhr.
  ELSE.
*   Im dezentralen System darf LIFEX nicht aus VERUR gefüllt werden
    IF NOT likp-lifex IS INITIAL OR NOT likp-verursys IS INITIAL.
      rv50a-verur_la = likp-lifex.
    ELSE.
      rv50a-verur_la = likp-verur.
    ENDIF.
    rv50a-lfdat_la = likp-lfdat.
    rv50a-lfuhr_la = likp-lfuhr.
    rv50a-wadat_ist_la = likp-wadat_ist.                    "45A

ENHANCEMENT-POINT EHP_LIKP_DATENTRANSFER_EA_02 SPOTS ES_SAPMV50A.

  ENDIF.

ENDFORM.                    "likp_datentransfer_in_ea

*&---------------------------------------------------------------------*
*&      FORM LIPS_DATENTRANSFER_IN_EA
*&---------------------------------------------------------------------*
*       Für den Grob-WE ist das Werk Kopfinformation; muß aber dennoch *
*       aus dem Zeileneintrag der Lieferung ermittelt werden (es wird  *
*       einfach der 1. Eintrag genommen)                               *
*----------------------------------------------------------------------*
FORM lips_datentransfer_in_ea.

  IF likp-vbtyp CA vbtyp_grwe.
    READ TABLE xlips INDEX 1.
    rv50a-werks = xlips-werks.
    CALL FUNCTION 'LOCATION_SELECT_PLANT'
      EXPORTING
        i_werks         = xlips-werks
      IMPORTING
        o_t001w         = t001w
      EXCEPTIONS
        no_valid_plant  = 01
        plant_not_found = 02.
    IF sy-subrc NE 0.
      MESSAGE e662 WITH xlips-werks.
*   DB-Inkonsistenz: Werk & nicht mehr gefunden (T001W)
    ENDIF.
  ENDIF.

ENDFORM.                               " LIPS_DATENTRANSFER_IN_EA

*---------------------------------------------------------------------*
*       FORM LIKP_FUELLEN_TEXTE_SIMUL                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM likp_fuellen_texte_simul.
  PERFORM tvcom_fill_simulmode USING 'LIKP'.
ENDFORM.                    "likp_fuellen_texte_simul
*---------------------------------------------------------------------*
*       FORM LIPS_FUELLEN_TEXTE_SIMUL                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM lips_fuellen_texte_simul.
  PERFORM tvcom_fill_simulmode USING 'LIPS'.
ENDFORM.                    "lips_fuellen_texte_simul
*eject

FORM lieferungsupdate_extern_init.

* Initialisierung bei Kommirückmeldung und Packdatenrückmeldung
  v50agl-no_commit = charx.
  v50agl-kommirueckmeldung = charx.
  xlips_chsp_rueckmeldung = charx.
  gs_mhpar-glomd = gc_glomd-background.

ENDFORM.                    "lieferungsupdate_extern_init
*eject
*&---------------------------------------------------------------------*
*&      Form  LFART_VALUES
*&---------------------------------------------------------------------*
*       Search help for delivery types
*----------------------------------------------------------------------*
FORM lfart_values USING if_aufer LIKE tvlk-aufer
                  CHANGING cf_lfart LIKE likp-lfart.

  DATA: BEGIN OF lt_deltype OCCURS 0,
          lfart LIKE tvlk-lfart,
          vtext LIKE tvlkt-vtext,
        END OF lt_deltype,
        lt_fields LIKE help_value OCCURS 1 WITH HEADER LINE,
        ls_select LIKE help_info-fldvalue.

* Read delivery types suitable for a delivery without reference
  IF if_aufer NE space.
    SELECT l~lfart t~vtext
                   APPENDING CORRESPONDING FIELDS OF TABLE lt_deltype
                   FROM tvlk AS l INNER JOIN tvlkt AS t
                       ON    l~lfart = t~lfart
                       WHERE l~aufer = if_aufer
                         AND l~vbtyp IN (vbtyp_lino, vbtyp_lire)
                         AND t~spras = sy-langu.       "#EC CI_BUFFJOIN
  ELSE.
    SELECT l~lfart t~vtext
                   APPENDING CORRESPONDING FIELDS OF TABLE lt_deltype
                   FROM tvlk AS l INNER JOIN tvlkt AS t
                       ON    l~lfart = t~lfart
                       WHERE ( l~aufer = ' ' OR l~aufer = 'U' )
                         AND l~vbtyp IN (vbtyp_lino, vbtyp_lire)
                         AND t~spras = sy-langu.       "#EC CI_BUFFJOIN
  ENDIF.

* Assign fields of help pop up to data dictionary
  lt_fields-tabname = 'TVLK'.
  lt_fields-fieldname = 'LFART'.
  lt_fields-selectflag = charx.
  APPEND lt_fields.

  lt_fields-tabname = 'TVLKT'.
  lt_fields-fieldname = 'VTEXT'.
  lt_fields-selectflag = space.
  APPEND lt_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = 'LT_DELTYPE-LFART'
      no_pers_help_select          = 'X'
      write_selectfield_in_colours = 'X'
      reduced_status_only          = 'X'
    IMPORTING
      select_value                 = ls_select
    TABLES
      fields                       = lt_fields
      full_table                   = lt_deltype
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.
  IF sy-subrc EQ 0.
    MOVE ls_select TO cf_lfart.
  ENDIF.


ENDFORM.                               " LFART_VALUES

*&---------------------------------------------------------------------*
*&      Form  LIPS-CHARG_VALUES
*&---------------------------------------------------------------------*
*       Search help for batch values
*----------------------------------------------------------------------*
FORM lips-charg_values.

  DATA: mc_object LIKE dd23l-mconame,
        mc_id LIKE dd23l-mcid,
        da_kunnr LIKE vbpa-kunnr,
        da_sobkz LIKE lips-sobkz,
        da_lips LIKE lips,
        da_charx VALUE charx,
        help_tabix LIKE sy-tabix,
        help_f(10) TYPE c,
        help_lips LIKE lips,
        lf_tabix LIKE sy-tabix,                             "n_1238649
        mchs_sobkz(3) VALUE 'KVW'.

  DATA: lf_programname LIKE sy-repid,
        lf_dynpro LIKE sy-dynnr,
        lt_dynpread LIKE dynpread OCCURS 10 WITH HEADER LINE,
        dseltab LIKE dselc OCCURS 10 WITH HEADER LINE.

  DATA: lf_shlpname LIKE dd30v-shlpname,
        lx_shlp TYPE shlp_descr_t,
        ls_interface LIKE ddshiface,
        lf_rc LIKE sy-subrc,
        lt_retvalues LIKE ddshretval OCCURS 0,
        ls_retvalue LIKE ddshretval.
ENHANCEMENT-POINT SAPMV50A_20 SPOTS ES_SAPMV50A STATIC .

*   Read input values from dynpro if ENTER not yet pressed
*   (not necessary for batch split screen)
  IF v50agl-chargensplitbild IS INITIAL.
    lf_programname = sy-repid.
    lf_dynpro = sy-dynnr.
    CALL FUNCTION 'DYNP_GET_STEPL'
      IMPORTING
        povstepl        = help_tabix
      EXCEPTIONS
        stepl_not_found = 1
        OTHERS          = 2.
    lf_tabix = help_tabix.                                  "n_1238649
    CLEAR lt_dynpread.
    REFRESH lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-MATNR'.
    lt_dynpread-stepl = help_tabix.
    APPEND lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-WERKS'.
    lt_dynpread-stepl = help_tabix.
    APPEND lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-CHARG'.
    lt_dynpread-stepl = help_tabix.
    APPEND lt_dynpread.

    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = lf_programname
        dynumb               = lf_dynpro
      TABLES
        dynpfields           = lt_dynpread
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        invalid_parameter    = 7
        undefind_error       = 8
        double_conversion    = 9
        OTHERS               = 10.

    LOOP AT lt_dynpread WHERE stepl = help_tabix.
      CASE lt_dynpread-fieldname.
        WHEN 'LIPS-MATNR'.
ENHANCEMENT-SECTION     SAPMV50A_21 SPOTS ES_SAPMV50A.
          MOVE lt_dynpread-fieldvalue TO da_lips-matnr.     "n_1238649
END-ENHANCEMENT-SECTION.
          CONTINUE.
        WHEN 'LIPS-WERKS'.
          MOVE lt_dynpread-fieldvalue TO da_lips-werks.     "n_1238649
          CONTINUE.
        WHEN 'LIPS-CHARG'.
          MOVE lt_dynpread-fieldvalue TO da_lips-charg.     "n_1238649
          CONTINUE.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*In case of empty line, no input help displayed
  IF ( da_lips-charg IS INITIAL AND                         "v_n_1238649
       da_lips-matnr IS INITIAL AND
       da_lips-werks IS INITIAL AND
       v50agl-chargensplitbild  IS INITIAL ).
    EXIT.
  ENDIF.                                                    "^_n_1238649

  IF sy-stepl = 0.
    GET CURSOR FIELD help_f LINE help_tabix.
  ELSE.
    help_tabix = sy-stepl.
    lf_tabix = help_tabix.                                    "n_1564844
  ENDIF.
  IF help_tabix > 0.
    READ TABLE slips INDEX help_tabix.
    IF sy-subrc = 0.
      READ TABLE xlips INDEX slips-tabix.
      help_lips = xlips.
    ELSE.
      help_lips = da_lips.                                  "n_1238649
    ENDIF.
  ELSE.
    help_lips = da_lips.                                    "n_1238649
  ENDIF.

  IF NOT help_lips-lgort IS INITIAL.
    SET PARAMETER ID 'LAG' FIELD help_lips-lgort.
  ELSEIF NOT v50agl-chargensplitbild IS INITIAL.
    SET PARAMETER ID 'LAG' FIELD clips-lgort.
  ENDIF.

  IF NOT v50agl-chargensplitbild IS INITIAL.
    help_lips = clips.
  ENDIF.

  IF NOT help_lips-matnr IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = help_lips-matnr
      IMPORTING
        output       = help_lips-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
*     exit.                        "Ignore conversion errors "50A
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'MAT' FIELD help_lips-matnr.
  SET PARAMETER ID 'WRK' FIELD help_lips-werks.

*note 53993 enable batch selection for special stocks:
  da_sobkz = help_lips-sobkz.
  IF help_lips-sobkz NA gc_sobkz-direct AND
     NOT help_lips-bwart IS INITIAL.
    da_lips = lips.
    lips = help_lips.

    DATA atp_type TYPE les_atp_type.
    CALL FUNCTION 'LE_ATP_GET_VERSION'
      IMPORTING
        atp_type = atp_type.

    IF atp_type EQ charo.
      PERFORM sonderbestand_bestimmen(sapfv50v)
                 USING da_sobkz da_kunnr da_charx
                       lips-pstyv lips-bwart.
    ELSE.
      PERFORM sonderbestand_bestimmen_neu(sapfv50p)
                 USING da_sobkz da_kunnr da_charx.
    ENDIF.

    lips = da_lips.
  ENDIF.

  IF da_sobkz CA mchs_sobkz.
    mc_object = 'MCHS'.
    mc_id = da_sobkz.
    SET PARAMETER ID 'KUN' FIELD da_kunnr.
  ELSE.
    mc_object = 'MCH1'.
  ENDIF.

*   Export parameters to memory to enable search help via classes
  CLEAR dseltab.
  REFRESH dseltab.
  dseltab-fldname = 'MANDT'.
  MOVE sy-mandt TO dseltab-fldinh.
  APPEND dseltab.
  dseltab-fldname = 'MATNR'.
  MOVE help_lips-matnr TO dseltab-fldinh.
  APPEND dseltab.
  dseltab-fldname = 'WERKS'.
  MOVE help_lips-werks TO dseltab-fldinh.
  APPEND dseltab.
  dseltab-fldname = 'CHARG'.
  MOVE help_lips-charg TO dseltab-fldinh.
  APPEND dseltab.
  EXPORT dseltab TO MEMORY ID 'DSELTAB'.

*   Get description for search help
  lf_shlpname = mc_object.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = lf_shlpname
      shlptype = 'SH'
    IMPORTING
      shlp     = lx_shlp
    EXCEPTIONS
      OTHERS   = 1.

*   Enable value copy from search help to dynpro field
  READ TABLE lx_shlp-interface INTO ls_interface
                               WITH KEY shlpfield = 'CHARG'.
  ls_interface-valfield = 'X'.
  MODIFY lx_shlp-interface FROM ls_interface INDEX sy-tabix.

*   Start search help dialog
  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = lx_shlp
    TABLES
      return_values = lt_retvalues
    EXCEPTIONS
      OTHERS        = 1.

  IF sy-subrc EQ 0.
    READ TABLE lt_retvalues INTO ls_retvalue
                            WITH KEY fieldname = 'CHARG'.
    IF sy-subrc EQ 0 AND
      ( help_tabix EQ lf_tabix                              "n_1238649
        OR v50agl-chargensplitbild EQ charx ).              "n_1238649
      lips-charg = ls_retvalue-fieldval.
    ENDIF.
  ENDIF.



ENDFORM.                               " LIPS-CHARG_VALUES

*&---------------------------------------------------------------------*
*&      Form  LIPS-PSTYP_VALUES
*&---------------------------------------------------------------------*
*       Displays allowed item types for a given material
*----------------------------------------------------------------------*
FORM lips-pstyp_values USING cf_pstyv TYPE pstyv.

  DATA: lf_programname LIKE sy-repid,
        lf_dynpro LIKE sy-dynnr,
        lt_dynpread LIKE dynpread OCCURS 10 WITH HEADER LINE,
        lf_stepl TYPE systepl,
        lf_mtpos LIKE maapv-mtpos,
        lf_matnr LIKE lips-matnr,
        lf_pstyv LIKE lips-pstyv.


ENHANCEMENT-POINT LIPS-PSTYP_VALUES_04 SPOTS ES_SAPMV50A STATIC .
  lf_programname = sy-repid.
  lf_dynpro = sy-dynnr.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = lf_stepl
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  CLEAR lt_dynpread.
  REFRESH lt_dynpread.
  lt_dynpread-fieldname = 'LIPS-MATNR'.
  lt_dynpread-stepl = lf_stepl.
  APPEND lt_dynpread.
  lt_dynpread-fieldname = 'LIPS-PSTYV'.
  lt_dynpread-stepl = lf_stepl.
  APPEND lt_dynpread.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = lf_programname
      dynumb               = lf_dynpro
    TABLES
      dynpfields           = lt_dynpread
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      OTHERS               = 10.

  LOOP AT lt_dynpread WHERE stepl = lf_stepl.
    IF lt_dynpread-fieldname EQ 'LIPS-MATNR'.
ENHANCEMENT-SECTION LIPS-PSTYP_VALUES_02 SPOTS ES_SAPMV50A .
      MOVE lt_dynpread-fieldvalue TO lf_matnr.
END-ENHANCEMENT-SECTION.
      CONTINUE.
    ELSEIF lt_dynpread-fieldname EQ 'LIPS-PSTYV'.
      MOVE lt_dynpread-fieldvalue TO lf_pstyv.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENHANCEMENT-SECTION LIPS-PSTYP_VALUES_03 SPOTS ES_SAPMV50A .
  IF lf_matnr IS INITIAL.
    t184_vwpos = 'TEXT'.
    CLEAR lf_mtpos.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = lf_matnr
      IMPORTING
        output       = lf_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    PERFORM maapv_select(sapfv50p) USING lf_matnr
                                         likp-vkorg
                                         rv50a-vtweg
                                         sy-subrc.
    t184_vwpos = space.
    lf_mtpos = maapv-mtpos.
  ENDIF.
END-ENHANCEMENT-SECTION.

  CALL FUNCTION 'RV_HELP'
    EXPORTING
      key            = tvlk-lfart
      key2           = lf_mtpos
      key3           = t184_vwpos
      key4           = ' '
      number         = 'L06'
      trtyp          = t180-trtyp
      field_in       = lf_pstyv
      description_in = tvapt-vtext
    IMPORTING
      field          = lips-pstyv
      description    = tvapt-vtext.

  CLEAR gv_event_pov.

ENDFORM.                               " LIPS-PSTYP_VALUES

*&---------------------------------------------------------------------*
*&      Form  LIPS-LGORT_VALUES
*&---------------------------------------------------------------------*
*       Search help for storage location
*----------------------------------------------------------------------*
FORM lips-lgort_values.

  DATA: lf_programname LIKE sy-repid,
        lf_dynpro LIKE sy-dynnr,
        lt_dynpread LIKE dynpread OCCURS 10 WITH HEADER LINE,
        lf_stepl LIKE sy-stepl,
        lf_itemnum LIKE sy-tabix,
        lf_matnr LIKE lips-matnr,
        lf_lgort LIKE lips-lgort,
        lf_sobkz LIKE lips-sobkz,
        lf_werks LIKE lips-werks,
        lf_vgbel LIKE lips-vgbel,
        lf_charg LIKE lips-charg,
        ls_xlips LIKE xlips,
        ls_slips LIKE slips.

  lf_programname = sy-repid.
  lf_dynpro = sy-dynnr.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = lf_stepl
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.

* lines deleted                                               "n_945509

* Check whether ENTER has already been pressed. If so, item is already
* created and data can be read from xlips directly. Otherwise, the data
* are taken from the dynpro.
  DESCRIBE TABLE slips LINES lf_itemnum.
  IF lf_stepl LE lf_itemnum.
*   if lf_stepl is zero, we are on a item detail screen
*   in case we are on a item detial screen it is not necessary to read
*   SLIPS and XLIPS
    IF lf_stepl EQ 0.                                       "v_n_945509
      MOVE-CORRESPONDING slips TO ls_slips.
      MOVE-CORRESPONDING xlips TO ls_xlips.                 "^_n_945509
    ELSE.
      READ TABLE slips INTO ls_slips INDEX lf_stepl.
      READ TABLE xlips INTO ls_xlips INDEX ls_slips-tabix.
    ENDIF.
    lf_matnr = ls_xlips-matnr.
    lf_werks = ls_xlips-werks.
    lf_lgort = ls_xlips-lgort.
    lf_sobkz = ls_xlips-sobkz.
    lf_charg = ls_xlips-charg.
    IF ls_xlips-vgtyp CA vbtyp_verk.
      lf_vgbel = ls_xlips-vgbel.
    ENDIF.
  ELSE.
    CLEAR lt_dynpread.
    REFRESH lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-MATNR'.
    lt_dynpread-stepl = lf_stepl.
    APPEND lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-WERKS'.
    lt_dynpread-stepl = lf_stepl.
    APPEND lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-LGORT'.
    lt_dynpread-stepl = lf_stepl.
    APPEND lt_dynpread.
    lt_dynpread-fieldname = 'LIPS-CHARG'.
    lt_dynpread-stepl = lf_stepl.
    APPEND lt_dynpread.


    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname               = lf_programname
        dynumb               = lf_dynpro
      TABLES
        dynpfields           = lt_dynpread
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        invalid_parameter    = 7
        undefind_error       = 8
        double_conversion    = 9
        OTHERS               = 10.

    LOOP AT lt_dynpread WHERE stepl = lf_stepl.
      IF lt_dynpread-fieldname EQ 'LIPS-MATNR'.
        MOVE lt_dynpread-fieldvalue TO lf_matnr.
        CONTINUE.
      ELSEIF lt_dynpread-fieldname EQ 'LIPS-WERKS'.
        MOVE lt_dynpread-fieldvalue TO lf_werks.
        CONTINUE.
      ELSEIF lt_dynpread-fieldname EQ 'LIPS-LGORT'.
        MOVE lt_dynpread-fieldvalue TO lf_lgort.
        CONTINUE.
      ELSEIF lt_dynpread-fieldname EQ 'LIPS-CHARG'.
        MOVE lt_dynpread-fieldvalue TO lf_charg.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = lf_matnr
      IMPORTING
        output       = lf_matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'RV_HELP'
    EXPORTING
      key            = lf_matnr
      key2           = lf_werks
      key3           = lf_vgbel
      key4           = lf_charg
      key5           = lf_sobkz
      number         = '011'
      trtyp          = t180-trtyp
      field_in       = lf_lgort
      description_in = t001l-lgobe
    IMPORTING
      field          = lips-lgort
      description    = t001l-lgobe.

ENDFORM.                               " LIPS-LGORT_VALUES

*&---------------------------------------------------------------------*
*&      Form  LIKP-TRMTYP_VALUES
*&---------------------------------------------------------------------*
*       Search help for the field means of transport
*----------------------------------------------------------------------*
FORM likp-trmtyp_values TABLES   it_xlips STRUCTURE lipsvb
                        CHANGING cf_trmtyp LIKE likp-trmtyp.

  DATA: lf_programname LIKE sy-repid,
        lf_dynpro LIKE sy-dynnr,
        lt_dynpread LIKE dynpread OCCURS 10 WITH HEADER LINE,
        lf_traty LIKE likp-traty.

  DATA: lt_matnr_hu TYPE vsep_t_matnr_maktx,
        ls_matnr_hu TYPE v_matnr_hu,
        lt_matnr TYPE vsep_t_matnr_maktx,
        ls_matnr TYPE v_matnr_hu.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

* Read TRATY from dynpro if input is not yet confirmed
  lf_programname = sy-repid.
  lf_dynpro = sy-dynnr.

  lt_dynpread-fieldname = 'LIKP-TRATY'.
  APPEND lt_dynpread.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = lf_programname
      dynumb               = lf_dynpro
    TABLES
      dynpfields           = lt_dynpread
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      OTHERS               = 10.

  LOOP AT lt_dynpread.
    IF lt_dynpread-fieldname EQ 'LIKP-TRATY'.
      MOVE lt_dynpread-fieldvalue TO lf_traty.
      EXIT.
    ENDIF.
  ENDLOOP.

  LOOP AT xlips ASSIGNING <ls_xlips>
                WHERE updkz NE updkz_delete.
    CHECK NOT <ls_xlips>-matnr IS INITIAL.
    ls_matnr_hu-mandt = sy-mandt.
    ls_matnr_hu-matnr = <ls_xlips>-matnr.
    ls_matnr_hu-spras = sy-langu.
    COLLECT ls_matnr_hu INTO lt_matnr_hu.
  ENDLOOP.

  CALL FUNCTION 'HU_ALLOWED_PACKING_MATERIAL'
    EXPORTING
      if_dialog     = 'X'
      if_pmart      = lf_traty
      if_trmtyp     = 'X'
*     IS_MATNR_HU   =
      it_matnr_hu   = lt_matnr_hu
    IMPORTING
      es_matnr_hu   = ls_matnr
      et_matnr      = lt_matnr
    EXCEPTIONS
      magrv_missing = 1
      nothing_found = 2
      no_common     = 3
      abbr          = 4
      fatal_error   = 5
      OTHERS        = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
  IF t180-trtyp NE chara.                                   "n_1227756
    READ TABLE lt_matnr INTO ls_matnr INDEX 1.
    cf_trmtyp = ls_matnr-matnr.
  ENDIF.                                                    "n_1227756

ENDFORM.                               " LIKP-TRMTYP_VALUES

*&---------------------------------------------------------------------*
*&      Form  lips-vfdat_pruefen
*&---------------------------------------------------------------------*
*       Check expiration date
*----------------------------------------------------------------------*
FORM lips-vfdat_pruefen.

  DATA: ls_mtcom LIKE mtcom,
        ls_mara  LIKE mara,
        ls_bncom LIKE bncom,                                "n_747981
        ls_mchar like mchar,                                  "n_1487990
        lf_checkdate  LIKE lips-hsdat,
        lf_vfdat     LIKE lips-vfdat,                       "n_820792
        lf_mhdrz_late  LIKE dm07m-mhdlg,                    "v_819832
        lf_vfdat_late  LIKE dm07m-mhdlg,
        lf_msgtext(10) TYPE c,                              "^_819832
        lf_matnr_text LIKE sy-msgv1,
        lf_hsdat_text(10) TYPE c,
        lf_vfdat_text(10) TYPE c.

  DATA:   lf_msgty LIKE sy-msgty,                           "n_819832
          lf_rcode LIKE sy-subrc.                           "n_819832

  ls_mtcom-kenng = 'MARA'.
  ls_mtcom-matnr = lips-matnr.

  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      schluessel           = ls_mtcom
    IMPORTING
      matdaten             = ls_mara
    EXCEPTIONS
      account_not_found    = 1
      batch_not_found      = 2
      forecast_not_found   = 3
      lock_on_account      = 4
      lock_on_material     = 5
      lock_on_plant        = 6
      lock_on_sales        = 7
      lock_on_sloc         = 8
      lock_on_batch        = 9
      lock_system_error    = 10
      material_not_found   = 11
      plant_not_found      = 12
      sales_not_found      = 13
      sloc_not_found       = 14
      slocnumber_not_found = 15
      sloctype_not_found   = 16
      text_not_found       = 17
      unit_not_found       = 18
      invalid_mch1_matnr   = 19
      invalid_mtcom        = 20
      sa_material          = 21
      wv_material          = 22
      waart_error          = 23
      t134m_not_found      = 24
      OTHERS               = 25.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Pruefung ob Gesamthaltbarkeit für Material gepflegt
  IF ls_mara-mhdhb NE 0.

* Herstelldatum unbekannt, es muss das Mindesthaltbarkeits-
* datum vorgeben werden
    IF     lips-hsdat IS INITIAL AND
       NOT lips-vfdat IS INITIAL.

*... Errechnung des Herstelldatums
      CALL FUNCTION 'SUBTRACT_TIME_FROM_DATE'
        EXPORTING
          i_idate               = lips-vfdat
          i_time                = ls_mara-mhdhb
          i_iprkz               = ls_mara-iprkz
        IMPORTING
          o_idate               = lips-hsdat
        EXCEPTIONS
          invalid_period        = 1
          invalid_round_up_rule = 2
          internal_error        = 3
          OTHERS                = 4.

      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      WRITE lips-hsdat TO lf_hsdat_text DD/MM/YYYY.
      WRITE lips-vfdat TO lf_vfdat_text DD/MM/YYYY.
      WRITE lips-matnr TO lf_matnr_text.
      MESSAGE s348 WITH lf_hsdat_text lf_vfdat_text
                        lf_matnr_text ls_mara-mhdhb.

* Herstelldatum vorgegeben aber MHD nicht bekannt
    ELSEIF NOT lips-hsdat IS INITIAL AND
               lips-vfdat IS INITIAL.

      MOVE-CORRESPONDING lips TO ls_bncom.                  "v_n_747981
      ls_bncom-licha = lips-lichn.
      ls_bncom-lfbel = lips-vbeln.
      ls_bncom-lfpos = lips-posnr.                          "^_n_747981

*... Errechnung des Mindesthaltbarkeitsdatum
      CALL FUNCTION 'VB_MAINTAIN_MHD'
        EXPORTING
          i_bezdt                  = likp-lfdat             "n_819832
          i_iprkz_hbd              = ls_mara-iprkz
          i_iprkz_rlz              = ls_mara-iprkz          "n_522248
          i_geshb                  = ls_mara-mhdhb
          i_rstlz                  = ls_mara-mhdrz          "n_819832
          i_rdmhd                  = ls_mara-rdmhd          "n_522248
          i_hsdat                  = lips-hsdat
          i_bncom                  = ls_bncom               "n_747981
          calc                     = 'X'
          check                    = 'X'                    "n_819832
        IMPORTING
          o_mhdat                  = lf_vfdat               "n_820792
          o_days_in_rem_sl         = lf_mhdrz_late          "n_819832
          o_days_after_sled        = lf_vfdat_late          "n_819832
        EXCEPTIONS
          sled_le_production_date  = 1
          ref_date_lower_prod_date = 2
          OTHERS                   = 3.

      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

* check minimum remaining shelf life                           "v_819832
      IF lf_mhdrz_late > 0.
        WRITE lf_mhdrz_late TO lf_msgtext LEFT-JUSTIFIED NO-ZERO.
        PERFORM message_handling_variabel USING cvbap-posnr
                                                '451'
                                                'W'
                                                'VL'
                                                 lf_msgtext
                                                 space
                                                 space
                                                 space
                                                 gs_mhpar
                                                 v50agl-msgvs
                                        CHANGING lf_msgty
                                                 lf_rcode.
      ENDIF.

* check total shelf life
      IF lf_vfdat_late > 0.
        WRITE lf_vfdat_late TO lf_msgtext LEFT-JUSTIFIED NO-ZERO.
        PERFORM message_handling_variabel USING cvbap-posnr
                                                '450'
                                                'W'
                                                'VL'
                                                 lf_msgtext
                                                 space
                                                 space
                                                 space
                                                 gs_mhpar
                                                 v50agl-msgvs
                                        CHANGING lf_msgty
                                                 lf_rcode.
      ENDIF.                                                "^_819832

      lips-vfdat = lf_vfdat.                                "n_820792

      WRITE lips-hsdat TO lf_hsdat_text DD/MM/YYYY.
      WRITE lips-vfdat TO lf_vfdat_text DD/MM/YYYY.
      WRITE lips-matnr TO lf_matnr_text.
      MESSAGE s349 WITH lf_hsdat_text lf_vfdat_text
                        lf_matnr_text ls_mara-mhdhb.
    ELSE.
      lf_checkdate = lips-vfdat - ls_mara-mhdhb.
      IF lips-hsdat NE lf_checkdate.
        WRITE lips-hsdat TO lf_hsdat_text DD/MM/YYYY.
        WRITE lips-vfdat TO lf_vfdat_text DD/MM/YYYY.
        WRITE lips-matnr TO lf_matnr_text.
        MESSAGE s350 WITH lf_hsdat_text lf_vfdat_text
                          lf_matnr_text ls_mara-mhdhb.
      ENDIF.
    ENDIF.
  ELSE.
    IF NOT lips-hsdat IS INITIAL AND
       NOT lips-vfdat IS INITIAL AND
       lips-vfdat LT lips-hsdat.
      MESSAGE w352.
    ENDIF.
  ENDIF.

* check remaining shelf life                                "v_1111547
  IF NOT lips-vfdat IS INITIAL AND NOT ls_mara-mhdrz IS INITIAL.
    PERFORM lips-mhd_check(sapfv50p) USING lips-matnr
                                           likp-lfdat
                                           lips-vfdat.
  ENDIF.                                                    "^_1111547

* SLED shall not be in past                                  "v_819832
  IF lips-vfdat < likp-lfdat AND NOT lf_vfdat_late > 0.
    PERFORM message_handling_variabel USING cvbap-posnr     "v_820792
                                            '210'
                                            'W'
                                            'M7'
                                             space
                                             space
                                             space
                                             space
                                             gs_mhpar
                                             v50agl-msgvs
                                    CHANGING lf_msgty
                                             lf_rcode.      "^_820792
  ENDIF.

* DOM shall not be in future
  IF lips-hsdat > likp-lfdat.
    PERFORM message_handling_variabel USING cvbap-posnr     "v_820792
                                            '211'
                                            'W'
                                            'M7'
                                             space
                                             space
                                             space
                                             space
                                             gs_mhpar
                                             v50agl-msgvs
                                    CHANGING lf_msgty
                                             lf_rcode.      "^_820792
  ENDIF.                                                    "^_819832

* Check if shelf life expiration date defined in batch      "n_v_1487990
* for outbound deliveries
  if ( likp-vbtyp eq vbtyp_lino and
       lips-xchar eq charx and
       lips-xchpf eq charx and
       lips-charg is not initial ).
*   Read batch master
    clear ls_mtcom.
    ls_mtcom-kenng = 'MCHAR'.
    ls_mtcom-matnr = lips-matnr.
    ls_mtcom-werks = lips-werks.
    ls_mtcom-lgort = lips-lgort.
    ls_mtcom-charg = lips-charg.
    ls_mtcom-maxtz = 100.

    call function 'MATERIAL_READ'
      exporting
        schluessel         = ls_mtcom
      importing
        matdaten           = ls_mchar
      exceptions
        material_not_found = 1
        batch_not_found    = 2
        others             = 99.

    if sy-subrc eq 0.
      if ls_mchar-vfdat ne lips-vfdat.
        write ls_mchar-vfdat to lf_vfdat_text dd/mm/yyyy.
        if 1 = 2. message w898(vl) with lf_vfdat_text lips-charg. endif.
        perform message_handling_variabel
          using
              lips-posnr
              '898'
              space
              'VL'
              lf_vfdat_text
              lips-charg
              space
              space
              gs_mhpar
              v50agl-msgvs
          changing
              lf_msgty
              lf_rcode
              .
      endif.
    endif.
  endif.                                                    "n_^_1487990


ENDFORM.                               " lips-vfdat_pruefen
*&---------------------------------------------------------------------*
*&      Form  lips-grund_values
*&---------------------------------------------------------------------*
*       The search help for LIPS-GRUND has to be started explictely
*       because there is no value table defined for the field
*       LIPS-GRUND. Furthermore, the value of the movement type assigned
*       to the delivery item has to be taken into account.
*&---------------------------------------------------------------------*
FORM lips-grund_values.

  DATA: lf_dynprog LIKE sy-repid,
        lf_dynprnr LIKE sy-dynnr.

  lf_dynprog = sy-repid.
  lf_dynprnr = sy-dynnr.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = 'LIPS'
      fieldname         = 'GRUND'
      searchhelp        = 'H_T157D'
      shlpparam         = 'GRUND'
      dynpprog          = lf_dynprog
      dynpnr            = lf_dynprnr
      dynprofield       = 'LIPS-GRUND'
      callback_program  = 'SAPMV50A'
      callback_form     = 'LIPS-GRUND_VALUES_RESTR'
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

ENDFORM.                               " lips-grund_values
*&---------------------------------------------------------------------*
*&      Form  lips-grund_values
*&---------------------------------------------------------------------*
*       This routine is called via callback from the search help
*       processing. The value of the movement type assigned to the
*       delivery item is transfered to the search help parameters which
*       are already known when this callback is processed. If the
*       movement type is given the search help provides only values for
*       the reason codes that are allowed in table T157D.
*&---------------------------------------------------------------------*
FORM lips-grund_values_restr TABLES it_record_tab STRUCTURE seahlpres
                             CHANGING cx_shlp_top TYPE shlp_descr_t
                                      cf_callcontrol LIKE ddshf4ctrl.

  DATA: ls_interface LIKE ddshiface.

  ls_interface-value = lips-bwart.
  MODIFY cx_shlp_top-interface FROM ls_interface
                               TRANSPORTING value
                               WHERE shlpfield EQ 'BWART'.

ENDFORM.                               " lips-grund_values_restr



*&---------------------------------------------------------------------*
*&      Form lips_matnr_entered
*&---------------------------------------------------------------------*
FORM lips_matnr_entered.                                    "v_n_695260

  STATICS: sf_matnr LIKE lips-matnr,
           sf_vbeln LIKE lips-vbeln,
           sf_posnr LIKE lips-posnr.

  PERFORM get_old_arktx.                                    "n_774742

* new item => clear memory and leave
  IF slips-tabix EQ 0.
    CLEAR sf_matnr.
    CLEAR sf_vbeln.
    CLEAR sf_posnr.
    EXIT.
  ENDIF.

* different item => keep new item in mind and leave
  IF NOT sf_vbeln IS INITIAL AND
     NOT sf_posnr IS INITIAL AND
     (  sf_vbeln NE lips-vbeln OR
        sf_posnr NE lips-posnr    ).
    sf_matnr = lips-matnr.
    sf_vbeln = lips-vbeln.
    sf_posnr = lips-posnr.
    EXIT.
  ENDIF.

* same item, matnr changed  => keep new matnr in mind and
* more than once               ensure *lips-matr <> lips-matnr
  IF NOT sf_posnr IS INITIAL AND
     NOT sf_matnr IS INITIAL AND
     sf_vbeln EQ lips-vbeln  AND
     sf_posnr EQ lips-posnr.

    IF *lips-matnr EQ lips-matnr.
       *lips-matnr = sf_matnr.
    ENDIF.

    sf_matnr = lips-matnr.
    EXIT.

  ENDIF.

* first change of an item => keep new matnr and item in mind
  IF sf_matnr IS INITIAL AND
     sf_vbeln IS INITIAL AND
     sf_posnr IS INITIAL.
    sf_matnr = lips-matnr.
    sf_vbeln = lips-vbeln.
    sf_posnr = lips-posnr.
    EXIT.
  ENDIF.

ENDFORM.                                                    "^_n_69526

*&---------------------------------------------------------------------*
*&      Form get_old_arktx
*&
*& *LIPS-ARKTX = ARKTX of last successful(!) entry. In error processing
*& *LIPS is not updated and changes in ARKTX are incorrectly detected
*& in FV50XFLP_LIPS_FUELLEN_MAAPV. Same for MATNR.
*&
*& Result:
*& gf_matnr_old and gf_arktx_old contain the old dynpro values if last
*& lips_bearbeiten failed or are initial otherwise.
*&---------------------------------------------------------------------*
FORM get_old_arktx.                                         "v_n_774742
  gf_arktx_old = gf_arktx_new.
  gf_matnr_old = gf_matnr_new.
  gf_arktx_new = lips-arktx.
  gf_matnr_new = lips-matnr.
ENDFORM.                                                    "^_n_774742
*&---------------------------------------------------------------------*
*&      Form  F_AULWE_ANZEIGEN_CORE
*&---------------------------------------------------------------------*
*       Search help for the field Route Schedule
*----------------------------------------------------------------------*
FORM f_aulwe_anzeigen_core CHANGING p_f_aulwe LIKE likp-aulwe. "1275015

  DATA: lf_programname LIKE sy-repid,
        lf_dynpro LIKE sy-dynnr,
        lt_dynpread LIKE dynpread OCCURS 10 WITH HEADER LINE,
        lf_aulwe LIKE likp-aulwe.
  DATA: BEGIN OF lt_aulwe OCCURS 0,
          aulwe LIKE valw-aulwe,
          bezei LIKE valwt-bezei,
        END OF lt_aulwe,
        lt_fields LIKE help_value OCCURS 1 WITH HEADER LINE,
        ls_select LIKE help_info-fldvalue.

  SELECT l~aulwe t~bezei
                   APPENDING CORRESPONDING FIELDS OF TABLE lt_aulwe
                   FROM valw AS l INNER JOIN valwt AS t
                       ON    l~aulwe = t~aulwe
                         AND t~spras = sy-langu.       "#EC CI_BUFFJOIN

* Assign fields of help pop up to data dictionary
  lt_fields-tabname = 'VALW'.
  lt_fields-fieldname = 'AULWE'.
  lt_fields-selectflag = charx.
  APPEND lt_fields.

  lt_fields-tabname = 'VALWT'.
  lt_fields-fieldname = 'BEZEI'.
  lt_fields-selectflag = space.
  APPEND lt_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = 'LT_AULWE-AULWE'
      no_pers_help_select          = 'X'
      write_selectfield_in_colours = 'X'
      reduced_status_only          = 'X'
    IMPORTING
      select_value                 = ls_select
    TABLES
      fields                       = lt_fields
      full_table                   = lt_aulwe
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.
  IF sy-subrc EQ 0.
    MOVE ls_select TO p_f_aulwe.
  ENDIF.

ENDFORM.                    " F_AULWE_ANZEIGEN_CORE