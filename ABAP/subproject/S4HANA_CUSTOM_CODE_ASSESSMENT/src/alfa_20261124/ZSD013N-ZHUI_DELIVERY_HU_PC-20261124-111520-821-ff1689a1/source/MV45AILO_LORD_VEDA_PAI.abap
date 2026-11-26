*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_VEDA_PAI
*&---------------------------------------------------------------------*

form veda_incompletion_check.
endform.                    "incompletion_check


*&---------------------------------------------------------------------*
*&      Form  lord_veda_pai_head
*&---------------------------------------------------------------------*
form lord_veda_pai_head.

  data: lf_dataloss type flag.

  call function 'SD_VEDA_GET_DATA'
    importing
      ef_dataloss = lf_dataloss
      es_veda     = veda.

  if not lf_dataloss is initial.
    call function 'SD_VEDA_CHECK_COMPLETENESS'
      exporting
        i_vbeln             = vbak-vbeln
        i_vposn             = posnr_null
        i_fehgr             = tvak-fehgr
      tables
        t_hvbuv             = hvbuv
        t_xvbuv             = xvbuv.
    r185d-dataloss = charx.
    perform vbak_update_from_veda(sapfv45k).
    perform veda_check_item_completeness.
    perform fplan_kopf_aktualisieren_call using space.
    perform fplan_aktualisieren using posnr_first posnr_high space.
  endif.

endform.                    "lord_veda_pai_head


*&---------------------------------------------------------------------*
*&      Form  lord_veda_pai_item
*&---------------------------------------------------------------------*
form lord_veda_pai_item.

  data: lf_dataloss type flag.

  call function 'SD_VEDA_GET_DATA'
    importing
      ef_dataloss = lf_dataloss
      es_veda     = veda.

  if not lf_dataloss is initial.
    call function 'SD_VEDA_CHECK_COMPLETENESS'
      exporting
        i_vbeln             = vbak-vbeln
        i_vposn             = vbap-posnr
        i_fehgr             = tvap-fehgr
      tables
        t_hvbuv             = hvbuv
        t_xvbuv             = xvbuv.
    r185d-dataloss = charx.
    perform vbap_fuellen(sapfv45p).
    perform vbap_bearbeiten(sapfv45p).
    vbap_ende_bearbeitung = charx.
    perform vbap_bearbeiten_ende(sapfv45p).
    move veda to xveda.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    perform fplan_aktualisieren using vbap-posnr vbap-posnr space.
  endif.

endform.                    "lord_veda_pai_item