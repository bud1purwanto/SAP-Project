*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_REPAIR_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LORD_REPAIRI_PAI_MULTI
*&---------------------------------------------------------------------*
form lord_repairi_pai_multi changing cf_dataloss.

  data: ls_headkom like v46r_headkom.
  data: lt_itemkom like v46r_itemkom  occurs 0 with header line.
  data: lt_repakom like v46r_repakom occurs 0 with header line.
  data: lt_serikom like v46r_serikom occurs 0 with header line.
  data: lf_dataloss type flag.
  data: ls_repairflags like v46r_repairflags.
  data: lv_posnr like vbap-posnr.
  data: lv_stage like tvrmav-zeitp.

  lv_posnr = vbap-posnr.

  call function 'SD_REPAIRORDER_DATA_GET'
    importing
      es_headkom  = ls_headkom
      et_itemkom  = lt_itemkom[]
      et_repakom  = lt_repakom[]
      et_serikom  = lt_serikom[]
      ef_dataloss = lf_dataloss
      ev_stage    = lv_stage.

  cf_dataloss = lf_dataloss.
  if not lf_dataloss is initial.
    perform repairitems_generate(sapfv45p) tables lt_itemkom
                                                  lt_serikom
                                           using  lv_posnr.
  endif.

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

  perform repairstatus_maintain(sapfv45p) using lv_posnr
                                                lv_stage
                                                charx
                                                ls_repairflags
                                                ls_headkom.

  perform repairorder_incompletion(sapfv45p) using lv_posnr.

endform.                    " LORD_REPAIRI_PAI_MULTI

*&---------------------------------------------------------------------*
*&      Form  LORD_REPAIR_OBJREFERENCE_WRITE
*&---------------------------------------------------------------------*
form lord_repair_objreference_write  using    iv_vbeln type vbeln
                                              iv_qmnum type qmnum.

  constants:  lc_vona      type binreltyp   value 'VONA'.
  constants:  lc_pmtyp_01  type qmtyp       value '01'.
  constants:  lc_qmtyp_02  type qmtyp       value '02'.
  constants:  lc_smtyp_03  type qmtyp       value '03'.

  data: ls_obj_rolea type borident.
  data: ls_obj_roleb type borident.
  data: lv_qmart type qmart.
  data: lv_qmtyp type qmtyp.
  data: lv_objtype type swo_objtyp.
  data: lv_system type logsys.

* get service object type
  select single qmart from viqmel into lv_qmart
               where qmnum = iv_qmnum.
  select single qmtyp from tq80 into lv_qmtyp
                where qmart = lv_qmart.
  case lv_qmtyp.
    when lc_pmtyp_01.
      lv_objtype = 'BUS2038'.
    when lc_qmtyp_02.
      lv_objtype = 'BUS2078'.
    when lc_smtyp_03.
      lv_objtype = 'BUS2080'.
  endcase.

* get logical system
  call function 'OWN_LOGICAL_SYSTEM_GET'
    importing
      own_logical_system             = lv_system
    exceptions
      own_logical_system_not_defined = 0.

* create link
  ls_obj_rolea-objkey = iv_qmnum.
  ls_obj_rolea-objtype = lv_objtype.
  ls_obj_rolea-logsys = lv_system.
  ls_obj_roleb-objkey = iv_vbeln.
  ls_obj_roleb-objtype = 'BUS2032'.
  ls_obj_roleb-logsys = lv_system.
  call function 'BINARY_RELATION_CREATE'
    exporting
      obj_rolea      = ls_obj_rolea
      obj_roleb      = ls_obj_roleb
      relationtype   = lc_vona
    exceptions
      no_model       = 1
      internal_error = 2
      unknown        = 3
      others         = 4.

endform.                    " LORD_REPAIR_OBJREFERENCE_WRITE