*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_FPLA_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LORD_FPLA_HEAD_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM lord_fpla_head_pai USING uv_dataloss TYPE flag.

  DATA: lv_dataloss LIKE r185d-dataloss.
  DATA: lf_wert TYPE flag.
  DATA: lf_upd_posfakt TYPE flag.

  CALL FUNCTION 'SD_FPLA_DATA_GET'
    EXPORTING
      iv_fplnr       = vbkd-fplnr
    IMPORTING
      ev_fplnr       = xvbkd-fplnr
      ef_dataloss    = lv_dataloss
      ef_upd_fpla    = upd_fpla
      ef_upd_fplt    = upd_fplt
      es_kompax      = kompax
      ef_upd_posfakt = lf_upd_posfakt
      et_xfpla       = xfpla[]
      et_yfpla       = yfpla[]
      et_xfplt       = xfplt[]
      et_yfplt       = yfplt[].

* Referenz zum Gruppenkontrakt prüfen beim verlassen des Kopfbildes
  PERFORM gruppenreferenz_pruefen(sapfv45k).

  uv_dataloss = lv_dataloss.

  IF     lv_dataloss   NE space
     AND r185d-dataloss EQ space.
    r185d-dataloss = lv_dataloss.
  ENDIF.
*
  IF xvbkd-fplnr NE vbkd-fplnr.
    MOVE xvbkd-fplnr TO vbkd-fplnr.
    IF svbkd-tabix = 0.
      PERFORM vbkd_bearbeiten(sapfv45k) USING vbkd-posnr.
    ELSE.
*       Aufruf wegen Unvollständigkeit
      PERFORM vbkd_pruefen(sapfv45k) USING vbkd-posnr.
      PERFORM xvbkd_aendern(sapfv45k).
    ENDIF.
    uv_dataloss = charx.
  ENDIF.

* Prüfen, ob es sich um einen wertmäßigen Kopffakturierungsplan handelt
  CALL FUNCTION 'BILL_SCHED_VALUE_BASED_CHECK'
    EXPORTING
      i_kfplnr       = vbkd-fplnr
    TABLES
      fplt_new       = xfplt
    EXCEPTIONS
      value_based_ok = 1
      OTHERS         = 2.

  IF sy-subrc = 1.
    MOVE charx TO lf_wert.
  ELSE.
    CLEAR lf_wert.
  ENDIF.

  IF lv_dataloss NE space OR
     NOT lf_upd_posfakt IS INITIAL OR
     NOT lf_wert IS INITIAL.
*   Positionsfakturierungspläne aus Kopf aktualisieren
    PERFORM fplan_aktualisieren(sapmv45a)
      USING posnr_first posnr_high
            space.

    IF NOT lf_wert IS INITIAL.
*       Möglicherweise müssen noch Differenzen verteilt werden, wenn es
*       sich um einen wertmäßigen Kopffakturierungsplan handelt.
      PERFORM fplan_kopf_wert_verteilen.
    ENDIF.
    uv_dataloss = charx.
  ENDIF.

ENDFORM.                    " LORD_FPLA_HEAD_PAI

*&---------------------------------------------------------------------*
*&      Form  lord_fpla_item_pai
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lord_fpla_item_pai USING uv_dataloss TYPE flag.

  DATA: da_fplnr    LIKE vbkd-fplnr.
  DATA: lv_dataloss LIKE r185d-dataloss.

* Fakturierungsplannummer initialisieren, wenn eine Pos-VBKD noch
* nicht existiert, da sonst Änderungsmodus unterstellt wird
  MOVE vbkd-fplnr TO da_fplnr.
  IF vbkd-posnr EQ posnr_low AND
     NOT vbkd-fplnr IS INITIAL.
    CLEAR da_fplnr.
  ENDIF.

  CALL FUNCTION 'SD_FPLA_DATA_GET'
    EXPORTING
      iv_fplnr    = da_fplnr
    IMPORTING
      ev_fplnr    = xvbkd-fplnr
      ef_dataloss = lv_dataloss
      ef_upd_fpla = upd_fpla
      ef_upd_fplt = upd_fplt
      es_kompax   = kompax
      et_xfpla    = xfpla[]
      et_yfpla    = yfpla[]
      et_xfplt    = xfplt[]
      et_yfplt    = yfplt[].

  MOVE-CORRESPONDING kompax TO vbap.

  uv_dataloss = lv_dataloss.

  IF lv_dataloss   NE space AND
    r185d-dataloss EQ space.
    r185d-dataloss = lv_dataloss.
  ENDIF.

* war nur lokal deklariert?
*  refresh tfplts. clear tfplts.
*  refresh tfpltnp. clear tfpltnp.

  IF xvbkd-fplnr NE vbkd-fplnr.
    IF vbkd-posnr EQ posnr_low.
      svbkd-tabix = 0.
      MOVE vbap-posnr TO vbkd-posnr.
    ENDIF.
    MOVE xvbkd-fplnr TO vbkd-fplnr.
    IF svbkd-tabix = 0.
      PERFORM vbkd_bearbeiten(sapfv45k) USING vbkd-posnr.
    ELSE.
      PERFORM xvbkd_aendern(sapfv45k).
    ENDIF.
    r185d-dataloss = charx.
    uv_dataloss = charx.
  ENDIF.
  PERFORM vbap_bearbeiten(sapfv45p).
  PERFORM vbap_bearbeiten_ende(sapfv45p).

ENDFORM.                    "lord_fpla_item_pai