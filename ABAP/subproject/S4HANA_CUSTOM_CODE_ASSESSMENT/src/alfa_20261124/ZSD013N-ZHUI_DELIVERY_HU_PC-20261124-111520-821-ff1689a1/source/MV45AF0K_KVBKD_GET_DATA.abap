*---------------------------------------------------------------------*
*       FORM KVBKD_GET_DATA                                           *
*---------------------------------------------------------------------*
*       compare old values for header business data with actual item  *
*       business data                                                 *
*---------------------------------------------------------------------*
form kvbkd_get_data.


  local: *kvbkd, kvbkd.
  local: xvbkd,
         svbkd-tabix.

  types: begin of tredvbkd,
           zterm like vbkd-zterm,
           konda like vbkd-konda,
           kdgrp like vbkd-kdgrp,
           kdkg1 like vbkd-kdkg1,
           kdkg2 like vbkd-kdkg2,
           kdkg3 like vbkd-kdkg3,
           kdkg4 like vbkd-kdkg4,
           kdkg5 like vbkd-kdkg5,
           bzirk like vbkd-bzirk,
           pltyp like vbkd-pltyp,
           inco1 like vbkd-inco1,
           inco2 like vbkd-inco2,
           kzazu like vbkd-kzazu,
           perfk like vbkd-perfk,
           perrl like vbkd-perrl,
           mrnkz like vbkd-mrnkz,
           kurrf like vbkd-kurrf,
           valtg like vbkd-valtg,
           fkdat like vbkd-fkdat,
           ktgrd like vbkd-ktgrd,
           fbuda like vbkd-fbuda,
           gjahr like vbkd-gjahr,
           poper like vbkd-poper,
           mschl like vbkd-mschl,
           mansp like vbkd-mansp,
           zlsch like vbkd-zlsch,
           stcur like vbkd-stcur,
           prsdt like vbkd-prsdt,
           kursk_dat like vbkd-kursk_dat,
           kurrf_dat like vbkd-kurrf_dat,
           kursk like vbkd-kursk,
           abssc like vbkd-abssc,
           lcnum like vbkd-lcnum,
           akprz like vbkd-akprz,
           empst like vbkd-empst,
           abtnr like vbkd-abtnr,
           bstkd like vbkd-bstkd,
           bstdk like vbkd-bstdk,
           bsark like vbkd-bsark,
           ihrez like vbkd-ihrez,
           bstkd_e like vbkd-bstkd_e,
           bsark_e like vbkd-bsark_e,
           delco like vbkd-delco,
           traty like vbkd-traty,
           vsart like vbkd-vsart,
           trmtyp like vbkd-trmtyp,
           sdabw like vbkd-sdabw,
           wminr like vbkd-wminr.
  types: end of tredvbkd.

  data: ls_vbkd type tredvbkd,
        ls_kvbkd type tredvbkd,
        ls_*kvbkd type tredvbkd,
        da_ag_changed type char1,
        da_vbkd_modified.

  field-symbols: <fs_vbkd_comp> type any,
                 <fs_kvbkd_comp> type any,
                 <fs_*kvbkd_comp> type any.

  perform xvbkd_kopf_lesen(sapfv45k).

  check not svbkd-tabix is initial.

  kvbkd = xvbkd.

  call function 'SD_KVBKD_GET_DATA'
       importing
            e_kvbkd      = *kvbkd
            e_ag_changed = da_ag_changed.

  move-corresponding vbkd to ls_vbkd.
  move-corresponding kvbkd to ls_kvbkd.
  move-corresponding *kvbkd to ls_*kvbkd.

  check: ls_kvbkd ne ls_*kvbkd.

  if ls_vbkd eq ls_*kvbkd.
    ls_vbkd = ls_kvbkd.
    da_vbkd_modified = charx.
  else.
    do.
      assign component sy-index
        of structure ls_vbkd to <fs_vbkd_comp>.
      if sy-subrc <> 0.
        exit.
      endif.
      assign component sy-index
        of structure ls_kvbkd to <fs_kvbkd_comp>.
      if sy-subrc <> 0.
        exit.
      endif.
      assign component sy-index
        of structure ls_*kvbkd to <fs_*kvbkd_comp>.
      if sy-subrc <> 0.
        exit.
      endif.
      if <fs_vbkd_comp> eq <fs_*kvbkd_comp> and
         <fs_kvbkd_comp> ne <fs_*kvbkd_comp>.
        <fs_vbkd_comp> = <fs_kvbkd_comp>.
        da_vbkd_modified = charx.
      endif.
    enddo.
  endif.

  if da_vbkd_modified eq charx.
    move-corresponding ls_vbkd to vbkd.
  endif.

endform.
***INCLUDE MV45AF0K_KVBKD_GET_DATA .