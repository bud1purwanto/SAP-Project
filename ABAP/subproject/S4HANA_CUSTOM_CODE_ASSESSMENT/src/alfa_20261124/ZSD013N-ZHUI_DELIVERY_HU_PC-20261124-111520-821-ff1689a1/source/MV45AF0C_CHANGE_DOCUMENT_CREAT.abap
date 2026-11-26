*---------------------------------------------------------------------*
*       FORM CHANGE_DOCUMENT_CREATE                                   *
*---------------------------------------------------------------------*
*       Änderungsbelege im Ändern erzeugen                            *
*---------------------------------------------------------------------*
FORM change_document_create.

  CHECK: t180-trtyp = charv.
  CHECK modification_flag-no_change_document IS INITIAL.
* Keine Änderungsbelege bei Neuaufbau Kreditdaten (RFDKLI20)
  CHECK: call_activity NE activity_credit_recreate.

  DATA: upd_icdtxt_verkbeleg  TYPE c.
  DATA: BEGIN OF icdtxt_verkbeleg  OCCURS 1.
          INCLUDE STRUCTURE cdtxt.
  DATA: END OF icdtxt_verkbeleg .
  DATA: us_posnr_low LIKE veda-vposn.
  DATA: upd_konvc.
  DATA: da_objectid LIKE cdhdr-objectid.

* Payment Service Provider
  DATA:   BEGIN OF xpaysp_hl OCCURS 0.
          INCLUDE STRUCTURE upaysp_hl.
  DATA:   END OF xpaysp_hl.
  DATA:   BEGIN OF ypaysp_hl OCCURS 0.
          INCLUDE STRUCTURE upaysp_hl.
  DATA:   END OF ypaysp_hl.
  DATA:   upd_paysp_hl.

  data: lt_xvbap type standard table of vbapvb,
        lt_yvbap type standard table of vbapvb,
        lt_xvbkd type standard table of vbkdvb,
        lt_yvbkd type standard table of vbkdvb,
        lt_xvbpa type standard table of vbpavb,
        lt_yvbpa type standard table of vbpavb,
        lt_xvbep type standard table of vbepvb,
        lt_yvbep type standard table of vbepvb,
        lt_xveda type standard table of vedavb,
        lt_yveda type standard table of vedavb,
        lt_xfpla type standard table of fplavb,
        lt_yfpla type standard table of fplavb,
        lt_xfplt type standard table of fpltvb,
        lt_yfplt type standard table of fpltvb.


* save x-tables
  if call_activity eq gc_activity_lord and
     not gf_no_init is initial.
    lt_xvbap = xvbap[].
    lt_yvbap = yvbap[].
    lt_xvbkd = xvbkd[].
    lt_yvbkd = yvbkd[].
    lt_xvbpa = xvbpa[].
    lt_yvbpa = yvbpa[].
    lt_xvbep = xvbep[].
    lt_yvbep = yvbep[].
    lt_xveda = xveda[].
    lt_yveda = yveda[].
    lt_xfplt = xfplt[].
    lt_yfplt = yfplt[].
  endif.

* Kopf
* Änderungsdatum nicht protokollieren
  yvbak-aedat = vbak-aedat.
  IF xvbak_updkz NE space.
    upd_vbak = xvbak_updkz.
  ENDIF.
* Kopfstati
  PERFORM xvbuk_lesen(sapfv45k) USING vbak-vbeln.
  vbuk = xvbuk.
  IF xvbuk-updkz NE space.
    upd_vbuk = charu.
    vbukkey-mandt = vbak-mandt.
    vbukkey-vbeln = vbak-vbeln.
    SORT yvbuk BY mandt vbeln.
    READ TABLE yvbuk WITH KEY vbukkey BINARY SEARCH.
     *vbuk = yvbuk.
  ENDIF.
* Positionen
  IF upd_vbap = charu.
    LOOP AT xvbap WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xvbap.
    ENDLOOP.
    SORT xvbap BY posnr.
    SORT yvbap BY posnr.
  ENDIF.
* Änderungsstände
  IF upd_vbsn = charu.
    LOOP AT xvbsn WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xvbsn.
    ENDLOOP.
    SORT xvbsn BY posnr.
    SORT yvbsn BY posnr.
  ENDIF.
* Einteilungen
  IF upd_vbep = charu.
* Bei Lieferplänen mit Abrufen keine Einteilungshistorie
    IF vbak-abdis NE space.
      REFRESH: xvbep, yvbep.
      CLEAR: upd_vbep.
    ENDIF.
* Normale Aufräge
    LOOP AT xvbep WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xvbep.
    ENDLOOP.
    SORT xvbep BY posnr etenr.
    SORT yvbep BY posnr etenr.
  ENDIF.
* Partner
  LOOP AT xvbpa WHERE updkz = space OR
                      updkz = updkz_delete.
    DELETE xvbpa.
  ENDLOOP.
  SORT yvbpa BY posnr parvw.
* Tabellensplitt für Mehrdeutige Partnerrollen
  CONSTANTS: cntpa_low LIKE vbpa2-cntpa VALUE '000000'.
  DATA: xvbpa_ch TYPE uvbpa OCCURS 0 WITH HEADER LINE,
        yvbpa_ch TYPE uvbpa OCCURS 0 WITH HEADER LINE,
        xvbpa2_ch TYPE uvbpa2 OCCURS 0 WITH HEADER LINE,
        yvbpa2_ch TYPE uvbpa2 OCCURS 0 WITH HEADER LINE.
  xvbpa_ch[] = xvbpa[].
  yvbpa_ch[] = yvbpa[].
  LOOP AT xvbpa_ch WHERE cntpa NE cntpa_low AND
                         cntpa NE space.
    MOVE-CORRESPONDING xvbpa_ch TO xvbpa2_ch.
    MOVE xvbpa_ch-kunnr TO xvbpa2_ch-partner.
    APPEND xvbpa2_ch.
    DELETE xvbpa_ch.
  ENDLOOP.
  LOOP AT yvbpa_ch WHERE cntpa NE cntpa_low AND
                         cntpa NE space.
    MOVE-CORRESPONDING yvbpa_ch TO yvbpa2_ch.
    MOVE yvbpa_ch-kunnr TO yvbpa2_ch-partner.
    APPEND yvbpa2_ch.
    DELETE yvbpa_ch.
  ENDLOOP.
* Kaufmännische Daten
  IF upd_vbkd = charu.
    SORT xvbkd BY posnr.
    READ TABLE xvbkd INDEX 1.
    vbkd = xvbkd.
    LOOP AT xvbkd WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xvbkd.
    ENDLOOP.
    LOOP AT xvbkd WHERE posnr > 0.
      PERFORM yvbkd_lesen(sapfv45k) USING xvbkd-posnr
                                          sy-tabix
                                          space.
      IF sy-subrc > 0.
        yvbkd = vbkd.
        yvbkd-posnr = xvbkd-posnr.
        yvbkd-updkz = space.
        APPEND yvbkd.
      ENDIF.
      IF xvbkd-updkz = updkz_new.
        xvbkd-updkz = updkz_update.
        MODIFY xvbkd.
      ENDIF.
    ENDLOOP.
    SORT yvbkd BY posnr.
  ENDIF.
* Fakturierungsplan
  IF upd_fpla = charu.
    LOOP AT xfpla WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xfpla.
    ENDLOOP.
  ENDIF.
  SORT xfpla BY fplnr.
  IF upd_fplt = charu.
    LOOP AT xfplt WHERE updkz = space OR
                        updkz = updkz_delete.
      DELETE xfplt.
    ENDLOOP.
  ENDIF.
  SORT xfplt BY fplnr fpltr.
* Konditionen, keine Übernahme von Konditionen bei neuen Positionen
  IF konv_geaendert NE space.
    upd_konvc = charu.
    LOOP AT xkomv.
      MOVE-CORRESPONDING xkomv TO xkonvc.
      IF xkonvc-waers = space.
        xkonvc-waers = char3.
      ENDIF.
      APPEND xkonvc.
    ENDLOOP.
    IF upd_vbap = charu.
      LOOP AT xvbap WHERE updkz = updkz_new.
        LOOP AT xkonvc WHERE kposn = xvbap-posnr.
          DELETE xkonvc.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
    SORT ykonvc BY kposn
                   stunr
                   zaehk.
  ENDIF.
* Änderungen von Lieferabrufdaten
  CALL FUNCTION 'SD_XVBLB_CHANGES'
    TABLES
      fxvblb = xvblb
      fyvblb = yvblb.

* Änderungen von Vertragsdaten
  IF NOT tvak-vterl IS INITIAL.
    MOVE posnr_low TO us_posnr_low.
    CALL FUNCTION 'SD_XVEDA_CHANGES'
      EXPORTING
        i_document_number = veda-vbeln
        i_posnr_low       = us_posnr_low
      TABLES
        fxveda            = xveda
        fyveda            = yveda.
  ENDIF.

  MOVE vbak-vbeln TO da_objectid.
* Änderungsbelege auch für VBUK wg. Kreditstatus 'Freigegeben' !

  DATA: da_changenumber LIKE cdhdr-planchngnr.

  DATA:   BEGIN OF xfpltc OCCURS 5.
          INCLUDE STRUCTURE ufpltc.
  DATA:   END OF xfpltc.
  DATA:   BEGIN OF yfpltc OCCURS 3.
          INCLUDE STRUCTURE ufpltc.
  DATA:   END OF yfpltc.
  DATA:   result TYPE xfeld.

  LOOP AT xfplt.
    CHECK xfplt-typzm EQ '0'.       " CON_TYPZM_CREDITCARD.
    MOVE-CORRESPONDING xfplt TO xfpltc.
    MOVE xfplt-updkz TO xfpltc-kz.
    IF xfplt-ccard_guid IS INITIAL.
      CALL FUNCTION 'CCARDEC_DO_ENVELOPE'
        EXPORTING
          im_ccins  = xfpltc-ccins
        IMPORTING
          ex_result = result.
      IF result = charx.
        CALL FUNCTION 'CCARDEC_MASK'
          EXPORTING
            im_ccnum = xfpltc-ccnum
*           IM_CCINS =
          IMPORTING
            ex_ccnum = xfpltc-ccnum.
      ENDIF.
    ENDIF.
    APPEND xfpltc.
  ENDLOOP.
  LOOP AT yfplt.
    CHECK yfplt-typzm EQ '0'.       " CON_TYPZM_CREDITCARD.
    MOVE-CORRESPONDING yfplt TO yfpltc.
    MOVE yfplt-updkz TO yfpltc-kz.
    APPEND yfpltc.
  ENDLOOP.

* Payment Service Provider
  FIELD-SYMBOLS:
        <paysp_hl> LIKE LINE OF gt_paysp_hl,
        <paysp_hl_old> LIKE LINE OF gt_paysp_hl_old.
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    IF ( vbak-sppaym EQ cv_sppaym01 OR yvbak-sppaym EQ cv_sppaym01 ).
      LOOP AT gt_paysp_hl ASSIGNING <paysp_hl>.
        READ TABLE gt_paysp_hl_old ASSIGNING <paysp_hl_old>
            WITH KEY document_id = <paysp_hl>-document_id.
        IF sy-subrc IS INITIAL AND
           <paysp_hl> NE <paysp_hl_old>.
          MOVE-CORRESPONDING <paysp_hl> TO xpaysp_hl.
          MOVE-CORRESPONDING <paysp_hl_old> TO ypaysp_hl.
          IF <paysp_hl> IS NOT INITIAL
            AND <paysp_hl_old> IS NOT INITIAL.
            xpaysp_hl-kz = charu.
            ypaysp_hl-kz = ' '.
            upd_paysp_hl = charu.
          ELSEIF <paysp_hl> IS INITIAL
             AND <paysp_hl_old> IS NOT INITIAL.
            xpaysp_hl-kz = chard.
            ypaysp_hl-kz = chard.
            upd_paysp_hl = chard.
          ENDIF.
          APPEND xpaysp_hl.
          APPEND ypaysp_hl.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* Unicode-Korrektur
  DATA:   BEGIN OF uc_xfpla OCCURS 0.
          INCLUDE STRUCTURE ufpla.
  DATA:   END OF uc_xfpla.

  DATA:   BEGIN OF uc_yfpla OCCURS 0.
          INCLUDE STRUCTURE ufpla.
  DATA:   END OF uc_yfpla.

  DATA:   BEGIN OF uc_xfplt OCCURS 0.
          INCLUDE STRUCTURE ufplt.
  DATA:   END OF uc_xfplt.

  DATA:   BEGIN OF uc_yfplt OCCURS 0.
          INCLUDE STRUCTURE ufplt.
  DATA:   END OF uc_yfplt.

  uc_xfpla[] = xfpla[].
  uc_yfpla[] = yfpla[].
  uc_xfplt[] = xfplt[].
  uc_yfplt[] = yfplt[].
* Ende Unincode-Korrektur

  CALL FUNCTION 'VERKBELEG_WRITE_DOCUMENT      ' IN UPDATE TASK
    EXPORTING
      planned_change_number = da_changenumber
      objectid              = da_objectid
      tcode                 = sy-tcode
      utime                 = sy-uzeit
      udate                 = sy-datum
      username              = sy-uname
      o_yvbak               = yvbak
      n_vbak                = vbak
      o_yvbuk               = *vbuk
      n_vbuk                = vbuk
      upd_vbak              = upd_vbak
      upd_vbuk              = upd_vbuk
      upd_vbap              = upd_vbap
      upd_vbep              = upd_vbep
      upd_vbsn              = upd_vbsn
      upd_vblb              = charu
      upd_vbkd              = upd_vbkd
      upd_vbpa              = charu
      upd_vbpa2             = charu
      upd_veda              = charu
      upd_fpla              = upd_fpla
      upd_fplt              = upd_fplt
      upd_fpltc             = upd_fplt
      upd_konvc             = upd_konvc
      upd_icdtxt_verkbeleg  = upd_icdtxt_verkbeleg
      upd_paysp_hl          = upd_paysp_hl
    TABLES
      icdtxt_verkbeleg      = icdtxt_verkbeleg
      xkonvc                = xkonvc
      ykonvc                = ykonvc
      xvbap                 = xvbap
      yvbap                 = yvbap
      xvbep                 = xvbep
      yvbep                 = yvbep
      xvbsn                 = xvbsn
      yvbsn                 = yvbsn
      xvbkd                 = xvbkd
      yvbkd                 = yvbkd
      xvblb                 = xvblb
      yvblb                 = yvblb
      xvbpa                 = xvbpa_ch
      xvbpa2                = xvbpa2_ch
      yvbpa                 = yvbpa_ch
      yvbpa2                = yvbpa2_ch
      xveda                 = xveda
      yveda                 = yveda
      xfpla                 = uc_xfpla
      yfpla                 = uc_yfpla
      xfpltc                = xfpltc
      yfpltc                = yfpltc
      xfplt                 = uc_xfplt
      yfplt                 = uc_yfplt
      xpaysp_hl             = xpaysp_hl
      ypaysp_hl             = ypaysp_hl.

*------- Aufruf der Aenderungsbelege fuer die Ausfuhrkontrolldaten
  CALL FUNCTION 'RV_EXPORT_CONTROL_CDOC_UPDATE'
    EXPORTING
      i_trans_type = t180-trtyp
    EXCEPTIONS
      OTHERS       = 1.

* restore x-tables
  if call_activity eq gc_activity_lord and
     not gf_no_init is initial.
    xvbap[] = lt_xvbap.
    yvbap[] = lt_yvbap.
    xvbkd[] = lt_xvbkd.
    yvbkd[] = lt_yvbkd.
    xvbpa[] = lt_xvbpa.
    yvbpa[] = lt_yvbpa.
    xvbep[] = lt_xvbep.
    yvbep[] = lt_yvbep.
    xveda[] = lt_xveda.
    yveda[] = lt_yveda.
    xfplt[] = lt_xfplt.
    yfplt[] = lt_yfplt.
  endif.

ENDFORM.                    "CHANGE_DOCUMENT_CREATE