*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSAKTION_INIT                                  *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TRANSAKTION_INIT                                         *
*---------------------------------------------------------------------*
*   Startwerte der Transaktion auf dem Anforderungsbild setzen.       *
*---------------------------------------------------------------------*
FORM transaktion_init USING us_tcode LIKE sy-tcode.

  DATA: ti_error,
        ti_lines LIKE sy-tfill,
        lf_datbi LIKE lv50c-datbi,
        lf_subrc LIKE sy-subrc,
        lf_tcode LIKE sy-tcode.

  DATA: lf_already_shown TYPE c.

*---------------------------------------------------------------------*
*     globalen Transaktionscode setzen                                *
*---------------------------------------------------------------------*
  tcode = us_tcode.

ENHANCEMENT-POINT MV50AF0T_TRANSAKTION_INIT_01 SPOTS ES_SAPMV50A.

*---------------------------------------------------------------------*
*     Warn users about using an old transaction  (4.6)                *
*     (once per transaction call)                                     *
*---------------------------------------------------------------------*
  IF sy-tcode EQ 'VL01' OR
     sy-tcode EQ 'VL02' OR
     sy-tcode EQ 'VL03' OR
     sy-tcode EQ 'VL31' OR
     sy-tcode EQ 'VL32' OR
     sy-tcode EQ 'VL33'.
    GET PARAMETER ID 'VL02_OLD_TRANSACTION'
                  FIELD lf_already_shown.
    IF lf_already_shown EQ space.
      MESSAGE s258 WITH us_tcode.
      lf_already_shown = charx.
      SET PARAMETER ID 'VL02_OLD_TRANSACTION'
                    FIELD lf_already_shown.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------*
*     Bei Rückkehr aus Fehlerprotokoll neu aufsetzen                  *
*---------------------------------------------------------------------*
  IF fcode(4) EQ fcode_fehlerprotokoll.
    DESCRIBE TABLE cvbfs LINES ti_lines.
    IF ti_lines NE 0.
      LEAVE TO TRANSACTION sy-tcode.
    ENDIF.
  ENDIF.

* Create global instances of BAdI classes
  PERFORM create_badi_instance.                             "470

* If the transaction has just been started the document initialization
* can be skipped. This is controlled by the flag SUPPRESS_INIT
  IF v50agl-suppress_init EQ space.
    PERFORM beleg_initialisieren.
  ELSE.
    CLEAR v50agl-suppress_init.
    CALL FUNCTION 'VB_SET_STATUS_INIT_DONE'.
  ENDIF.
*---------------------------------------------------------------------*
*     Aufrufen der gekoppelten Modulpools wegen der Adressen          *
*---------------------------------------------------------------------*
  PERFORM programm_laden(sapfv50p).
  PERFORM programm_laden(sapfv50v).
  PERFORM dummy(sapfv50c).

*---------------------------------------------------------------------*
*   Bei allen Datenbankzugriffen wird mit den Feldern LIKP-MANDT
*   und LIKP-VBELN gearbeitet.
*---------------------------------------------------------------------*
  likp-mandt = sy-mandt.
  SELECT SINGLE * FROM tvshp.
*---------------------------------------------------------------------*
*   Defaultwerte aus T180 lesen und interpretieren
*   Je nach Transaktionstyp gewisse Fcodes deaktivieren: Tabelle füllen
*---------------------------------------------------------------------*
  PERFORM t180_interpretieren USING us_tcode.
  REFRESH cua_exclude.
  PERFORM exclude_function_trtyp.
  PERFORM cua_fcode_tcode.
  PERFORM global_data_init(sapmv50a).
*SPE INB ST
  IF v50agl-no_text_init IS INITIAL.
* The text memory has to refreshed in any case
    IF t180-trtyp NE chara.
      CALL FUNCTION 'DELETE_TEXT_FROM_CATALOG'
        EXPORTING
          object    = 'VBBK'
          name      = '*'
          id        = '*'
          language  = '*'
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      CALL FUNCTION 'DELETE_TEXT_FROM_CATALOG'
        EXPORTING
          object    = 'VBBP'
          name      = '*'
          id        = '*'
          language  = '*'
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------*
*   Unter PBO stehen die GPA-Werte noch nicht zur Verfuegung
*   Bei Bedarf werden die Parameter aus dem Memory geholt
*---------------------------------------------------------------------*

  IF t180-trtyp EQ charh.
    GET PARAMETER ID 'VST' FIELD likp-vstel.
  ENDIF.

  CASE t180-trvog.
    WHEN chard.
      GET PARAMETER ID 'VLM' FIELD likp-vbeln.
    WHEN charg.
      GET PARAMETER ID 'VLG' FIELD likp-vbeln.
  ENDCASE.

*---------------------------------------------------------------------*
*   Beim Hinzufügen wird ferner:
*   - die Tabelle TVST + TVSTT gelesen
*   - das Erstellungsdatum der Lieferung gesetzt
*   - der Default für das Selektionsdatum ist heute
*---------------------------------------------------------------------*
  IF t180-trtyp EQ charh.

    IF likp-vstel NE space.
      PERFORM tvst_select USING likp-vstel space sy-subrc.
    ENDIF.

    GET PARAMETER ID 'LEDAT' FIELD lv50c-datbi.             "46A BEY
    IF lv50c-datbi IS INITIAL.
      lv50c-datbi = sy-datlo.
    ENDIF.
    IF sy-calld = 'X'.
      IMPORT likp-vstel                FROM MEMORY ID 'VSTEL'.
      IMPORT lv50c-datbi TO lf_datbi   FROM MEMORY ID 'LEDAT'.
      IMPORT d_tcode     TO lf_tcode   FROM MEMORY ID 'CALLING_TCODE'.
      IF lf_datbi    > sy-datlo  OR    " (A)
         lf_tcode(4) = 'VL10'     .    " (B)
* (A)   Bisheriger  Standard, datbi in die Zukunft verlegen für
*       Einzellieferung aus der VL04
* (B)   Zusätzlich darf die VL10 auch in Vergangenheheit begrenzen, um
*       gezielt Teilmengen zu beliefern (Auftrag im Rückstand
*       teilbeliefern)
*       Manuelle Veränderungen des Liefererstellungsdatum soll sich
*       das System merken (VL01)
        lv50c-datbi = lf_datbi.
      ENDIF.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
*   Definition von Parametern für die Bildfolgesteuerung:
*   - Standardfunktionscodes: ENT1: auf Dynpro bleiben
*   - Verarbeitungsortes
*   - Arbeitsgebiet und Aktivitaetsklassifizierung
*   - CUA-Parameter fuer Action-Bar und Titel holen
*---------------------------------------------------------------------*
  fcode = fcode_anforderung.
  IF t180-bldgr EQ gc_new_dialog_outb
     OR t180-bldgr EQ gc_new_dialog_inb.
    PERFORM transform_fcode CHANGING fcode.
    PERFORM taxi_screen_groups_init.
*   SPE INB RG 17.11.2004 HOLD Status in item level
    BREAK-POINT ID /spe/inb_hold.
*   Check the old Hold status
    IF xvbuk-hdall IS INITIAL AND xvbuk-hdals IS INITIAL.
      v50agl-new_del_mode = charx.                     "n_521409/550349
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
*   Default: es handelt sich um eine Lieferung mit Referenz
*---------------------------------------------------------------------*
  lieferung_or = space.

* Dynamische Schlüsselwörter und Texte setzen
  CASE t180-trvog.
    WHEN char6.
      rv50a-txt_lfart = text-001.      "Lieferung
      rv50a-txt_vbeln = text-002.
      r185d-titel     = text-006.      "Lieferbearbeitung
    WHEN chard.
      rv50a-txt_lfart = text-001.      "Lieferung
      rv50a-txt_vbeln = text-002.
      r185d-titel     = text-006.      "Lieferbearbeitung
  ENDCASE.

* Für VL07 werden Default-Datumsangagben gesetzt
  rv50a-bldat = sy-datlo.
  rv50a-budat = sy-datlo.

  ENHANCEMENT-POINT transaktion_init_01 SPOTS es_sapmv50a.
* Aussenhandel: Dokumentengeschaeft: Initialisieren Protokoll
  CALL FUNCTION 'RV_FOR_TRADE_PROTOCOL_INIT'
    EXCEPTIONS
      OTHERS = 1.

* Aussenhandel: Gesetzliche Kontrolle: Initialisieren SLS-Daten
  CALL FUNCTION 'FT_SLS_PARTNER_ADDR_MEM_INIT'
    EXPORTING
      i_base_document = '2LI'.

* Check whether transaction variant is active
  CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'                   "HP_211201
       IMPORTING
            tcvariant = gf_tcvariant
            rc        = lf_subrc.
  IF lf_subrc EQ 4.
    CLEAR gf_tcvariant.
  ELSE.                                                     "v_n_532957
    CALL FUNCTION 'RS_HDSYS_GET_TCODE'
      IMPORTING
        param_tcode = gf_param_tcode
        rc          = lf_subrc.

    IF lf_subrc NE 0.
      CLEAR gf_param_tcode.
    ENDIF.                                                  "^_n_532957

  ENDIF.

* batch data & batch selection criteria
  CALL FUNCTION 'VB_INIT'.

* initialize log for x-, y-tables                             "n_1636529
  PERFORM transaction_init_logxy_init.

ENDFORM.                    "transaktion_init


*&---------------------------------------------------------------------*
*&      Form  TRANSACTION_INIT_LOGXY_INIT
*&---------------------------------------------------------------------*
form TRANSACTION_INIT_LOGXY_INIT .                            "n_1636529

* refresh internal tables
  CALL FUNCTION 'SD_DELIVERY_REFRESH_XYTAB'.

* read log settings
  CALL FUNCTION 'SD_READ_TPARAMS_SD'
    EXPORTING
      I_PARKEY                 = 'XYTAB_ANA'
      I_PARNAME1               = 'SHIPPING'
    EXCEPTIONS
      INVALID_PARAMETERS       = 1
      NOT_FOUND                = 2
      OFF                      = 3
      OTHERS                   = 4
            .
  IF sy-subrc <> 0.
*   ignore errors ...
  ENDIF.

endform.                    " TRANSACTION_INIT_LOGXY_INIT