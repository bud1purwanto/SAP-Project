*&---------------------------------------------------------------------*
*&  Include           MV45AFOB_LORD_HEAD_PBO
*&---------------------------------------------------------------------*

form lord_head_pbo.

  clear xvbak.
  perform kuagv_select_xvbpa(sapmv45a).
  perform ag_vorschlagen(sapmv45a).
  perform kuwev_select_xvbpa(sapmv45a).

* Warenempfänger merken
  if not save-we = '0000000000'.
    save-we = kuwev-kunnr.
  endif.

  perform vbak_bearbeiten_vorbereiten.
  perform rv45a-kedatu_ausgabe.
  perform xvbuk_update.

  perform t001w_select using rv45a-dwerk
                                   space
                                   sy-subrc.

* Verkaufsorganisationstext ermitteln
  perform tvkot_select using vbak-vkorg
                             space
                             sy-subrc.
* Vertriebsweg-Text ermitteln
  perform tvtwt_select using vbak-vtweg
                             space
                             sy-subrc.
* Spartentext ermitteln
  perform tspat_select using vbak-spart
                             space
                             sy-subrc.
* Texte zusammenfügen
  perform txt_vtrber_zusammenfuegen.

  perform tvgrt_select using vbak-vkgrp
                             space
                             sy-subrc.

  perform tvkbt_select using vbak-vkbur
                             space
                             sy-subrc.

  perform tvzbt_select using vbkd-zterm
                             space
                             sy-subrc.

  perform t042z_select using vbkd-zlsch
                             rv45a-bukrsl
                             space
                             sy-subrc.

* contract data
  perform veda_lesen_kopf_lord(saplv45w).
  perform veda_bearbeiten_vorbereiten(saplv45w).

  perform kopfsummen_bilden(sapfv45k).

endform.                    "lord_head_pbo


*&---------------------------------------------------------------------*
*&      Form  lord_head_pbo_single
*&---------------------------------------------------------------------*
form lord_head_pbo_single.

  clear xvbak.
  perform kuagv_select_xvbpa.
  perform ag_vorschlagen.
  perform kuwev_select_xvbpa.

* Warenempfänger merken
  if not save-we = '0000000000'.
    save-we = kuwev-kunnr.
  endif.

  perform vbak_bearbeiten_vorbereiten.
  clear vbap.
  perform vbak-ktext_lesen(sapfv45k).
  perform rv45a-kedatu_ausgabe.

  call function 'CCARD_DATE_CONVERT_OUTPUT'
    exporting
      ccins_i         = ccdata-ccins
      internal_date_i = ccdata-datbi
    importing
      external_date_e = ccdate-exdatbi.

  perform xvbuk_update.

  perform t001w_select using rv45a-dwerk
                                   space
                                   sy-subrc.

* contract data
  perform veda_lesen_kopf_lord(saplv45w).
  perform veda_bearbeiten_vorbereiten(saplv45w).

  perform kopfsummen_bilden(sapfv45k).

  if vbak-kunnr is initial.
*   UVALL = C despite STP is missing due to empty incompletion log:
*   Fill INCLOG in this case
    perform set_inclog_no_stp.
  endif.

endform.                    "lord_head_pbo_single


*&---------------------------------------------------------------------*
*&      Form  lord_head_pbo_ro
*&---------------------------------------------------------------------*
form lord_head_pbo_ro.

* Verkaufsorganisationstext ermitteln
  perform tvkot_select using vbak-vkorg
                             space
                             sy-subrc.
* Vertriebsweg-Text ermitteln
  perform tvtwt_select using vbak-vtweg
                             space
                             sy-subrc.
* Spartentext ermitteln
  perform tspat_select using vbak-spart
                             space
                             sy-subrc.
* Texte zusammenfügen
  perform txt_vtrber_zusammenfuegen.

  perform tvgrt_select using vbak-vkgrp
                             space
                             sy-subrc.

  perform tvkbt_select using vbak-vkbur
                             space
                             sy-subrc.

  perform tvzbt_select using vbkd-zterm
                             space
                             sy-subrc.

  perform t042z_select using vbkd-zlsch
                             rv45a-bukrsl
                             space
                             sy-subrc.

  perform tvlst_select using vbak-lifsk
                             space
                             sy-subrc.

  perform tvfsp_select using vbak-faksk
                             space
                             sy-subrc.

  perform t189t_select using vbkd-pltyp
                             space
                             sy-subrc.

  perform t188t_select using vbkd-konda
                             space
                             sy-subrc.

  perform t151t_select using vbkd-kdgrp
                             space
                             sy-subrc.

  perform t171t_select using vbkd-bzirk
                             space
                             sy-subrc.

  perform t176t_select using vbkd-bsark
                             space
                             sy-subrc
                             t176t-vtext_k.

  perform t173t_select using vbkd-vsart
                             space
                             sy-subrc.

  perform t683u_select using 'A'
                             'V'
                             vbak-kalsm
                             sy-subrc.

  perform tvsbt_select using vbak-vsbed
                             space
                             sy-subrc.

  if not tvta-afind is initial.
    perform wakt_select(sapfv45k) using rv45a-waktion
                                        sy-subrc.
  endif.

  perform tvaut_select using vbak-augru
                             space
                             sy-subrc.

  if cl_ops_switch_check=>sd_sfws_sc2( ) eq abap_true.
    perform fill_head_read_only
            in program saplsls_lord
            using vbak.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
* Special Payment Methode
    perform sppaym_t_select using vbak-sppaym
                                  gs_lpaysp_descr-sppaym_t.

* Master Contracts
    perform tvgrpt_select using vbak-scheme_grp
                                space
                                sy-subrc.
  endif.

endform.                    "lord_head_pbo_ro


*&--------------------------------------------------------------------*
*&      Form  vbak_bearbeiten_vorbereiten
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form vbak_bearbeiten_vorbereiten.

  perform vbak_bearbeiten_vorbereiten(sapfv45k).
  data: lv_lcnum type vbkd-lcnum.
  if not fcode_ifdh_activated is initial and
    vbkd-lcnum is initial.
    get parameter id 'AKN' field lv_lcnum.
    if not lv_lcnum is initial.
      vbkd-lcnum = lv_lcnum.
      perform vbkd_kopf_bearbeiten(sapfv45k).
    endif.
    clear fcode_ifdh_activated.
  endif.
  clear vbap.

endform.                    " vbak_bearbeiten_vorbereiten


*&--------------------------------------------------------------------*
*&      Form  rv45a-kedatu_ausgabe
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form rv45a-kedatu_ausgabe.

  if vbak-vprgr = space.
    vbak-vprgr = char1.
  endif.
  call function 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    exporting
      internal_date   = vbak-vdatu
      internal_period = vbak-vprgr
    importing
      external_date   = rv45a-ketdat
      external_period = rv45a-kprgbz.

endform.                    " rv45a-kedatu_ausgabe


*&--------------------------------------------------------------------*
*&      Form  xvbuk_update
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form xvbuk_update.

  check t180-trtyp eq charv.
  perform xvbuk_update(sapfv45k).

endform.                    " xvbuk_update

*&--------------------------------------------------------------------*
*&      Form  set_inclog_no_stp
*&--------------------------------------------------------------------*
*       Fill the incompletion log in case of missing sold-to party
*---------------------------------------------------------------------*
form set_inclog_no_stp.

  data:
    ls_vbpa type vbpa,
    ls_tpar type tpar.

* Get check group of partner function AG
  call function 'TPAR_SINGLE_READ'
    exporting
      i_parvw = 'AG'
    importing
      o_tpar  = ls_tpar
    exceptions
      others  = 1.
  if not sy-subrc      is initial or
         ls_tpar-fehgr is initial.
*   Nothing to incomplete check
    return.
  endif.

* Prepare empty VBPA
  ls_vbpa-mandt = sy-mandt.
  ls_vbpa-vbeln = vbak-vbeln.
  ls_vbpa-posnr = posnr_low.
  ls_vbpa-parvw = ls_tpar-parvw.

* Do the partner incompletion check
  call function 'RV_CHECK_DOCUMENT_INPUT'
    exporting
      fehgr     = ls_tpar-fehgr
      vbxx_wa   = ls_vbpa
      tbnam     = 'VBPA      '
    tables
      vbuv_tab  = xvbuv
      vbuv_last = hvbuv.

endform.                    "set_inclog_no_stp