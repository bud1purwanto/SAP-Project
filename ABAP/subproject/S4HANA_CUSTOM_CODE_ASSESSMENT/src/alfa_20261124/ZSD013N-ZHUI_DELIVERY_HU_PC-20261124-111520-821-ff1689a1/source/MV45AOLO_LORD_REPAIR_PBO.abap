*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_REPAIR_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  lord_repair_check_available
*&---------------------------------------------------------------------*
form lord_repair_check_available using    iv_object type tabname
                                 changing uv_fpla_available type flag
                                          uv_avail_warning  type flag.

  constants: lc_vbklt type string value 'FG'.

  data: lv_msg type string.

  clear uv_fpla_available.
  if vbap-vkgru ne vkgru_rep_reparaturanfo or not
    ( tvak-vbklt ca lc_vbklt and
     tvak-vbtyp ca vbtyp_auftr ).

    if uv_avail_warning is initial.
      uv_avail_warning = abap_true.
    endif.
    message w155(SLS_LORD) into lv_msg.
    message_collect_lord.
  else.
    uv_fpla_available = abap_true.
  endif.

endform.                    "lord_repair_check_available


*&---------------------------------------------------------------------*
*&      Form  lord_repair_pbo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_repair_pbo.

  data: lv_posnr like vbap-posnr.
  data: ls_headkom like v46r_headkom.
  data: ls_repairflags like v46r_repairflags.
  data: lt_itemkom like v46r_itemkom occurs 0 with header line.
  data: lt_repakom like v46r_repakom occurs 0 with header line.
  data: lt_serikom like v46r_serikom occurs 0 with header line.
  data: lv_stage like tvrmav-zeitp.
  data: lv_activity type char4.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).

  lv_posnr = vbap-posnr.

  perform repairitems_prepare(sapfv45p) tables   lt_itemkom
                                                 lt_serikom
                                        using    lv_posnr
                                        changing ls_headkom.

  perform repairitems_prep_status(sapfv45p)
    using    lv_posnr
    changing ls_repairflags
             ls_headkom.

  perform repairitems_prep_stage(sapfv45p)
    tables   lt_itemkom
    using    lv_posnr
             ls_repairflags
    changing lv_stage
             ls_headkom.

  if lv_stage eq reparaturannahme and
     ls_repairflags-flg_kzen is initial and
     ls_repairflags-flg_kent is initial.
    perform repairstatus_setfirst(sapfv45p) using lv_posnr
                                         changing ls_repairflags-flg_kzen
                                                  ls_headkom.
  endif.

  perform repairitems_confirmation_pull(sapfv45p)
    tables   lt_itemkom
             lt_repakom
             lt_serikom
    using    lv_posnr
             ls_repairflags
             lv_stage
             ls_headkom
    changing lv_activity.

  call function 'SD_REPAIRORDER_DATA_PUT'
    exporting
      iv_trtyp    = t180-trtyp
      iv_stage    = lv_stage
      iv_activity = lv_activity
      is_headkom  = ls_headkom
      it_itemkom  = lt_itemkom[]
      it_repakom  = lt_repakom[]
      it_serikom  = lt_serikom[].

endform.                    "lord_repair_pbo