*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PACKFLUSS_UEBERNEHMEN                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM PACKFLUSS_UEBERNEHMEN                                    *
*---------------------------------------------------------------------*
*       Die von der Verpackung erstellten Flußsätze werden in die     *
*       allgemeine Flußtabelle übernommen un der Status der           *
*       betroffenen Positionen neu ermittelt                          *
*---------------------------------------------------------------------*
* FORM PACKFLUSS_UEBERNEHMEN .                 "del note 134119
form packfluss_uebernehmen using if_vbeln like likp-vbeln   "<<i 134119
                                 if_verp  like lips-xchpf.  "<<i 134119

* Form renovated with n_1338547
  types: begin of ts_item,
           posnr type posnr_vl,
         end   of ts_item.

  data lt_item_upd type sorted table of ts_item with unique key posnr.
  data ls_item_upd type ts_item.
  data lt_packpos type sorted table of ts_item with unique key posnr.
  data ls_packpos type ts_item.
  data lf_delete_vbfa type xfeld.

  if not if_verp is initial.
    loop at xvbup where vbeln eq if_vbeln and
                  pksta ca 'BC' and updkz ne updkz_delete.
      ls_packpos-posnr = xvbup-posnr.
      insert ls_packpos into table lt_packpos.
    endloop.
  endif.

  loop at xpackvbfa where vbelv eq if_vbeln and
                          updkz ne updkz_delete.

    move-corresponding xpackvbfa to vbfa.
    call function 'RV_XVBFA_MAINTAIN'
      exporting
        f_vorgang              = charv
        fvbfa                  = vbfa
        i_do_not_rebuild_vbapf = charx
      tables
        fxvbfa                 = xvbfa
        fyvbfa                 = yvbfa.

    if vbfa-posnv is not initial.
      delete table lt_packpos with table key posnr = vbfa-posnv.
      read table lt_item_upd with table key posnr = vbfa-posnv
                             transporting no fields.
      if sy-subrc ne 0.
        ls_item_upd-posnr = vbfa-posnv.
        insert ls_item_upd into table lt_item_upd.
      endif.
    endif.
  endloop.

* If a newly created HU is being deleted immediately it is not
* visible in YVBFA and YPACKVBFA. Thus it needs to be added here.
  loop at xvbfa where vbelv eq if_vbeln
                  and vbtyp_n eq vbtyp_versand
                  and updkz eq updkz_new.
*   XVPACKVBFA is created from sorted XVBFA and can thus also be
*   accessed with BINARY SEARCH
    read table xpackvbfa with key vbelv = xvbfa-vbelv
                                  posnv = xvbfa-posnv
                                  vbeln = xvbfa-vbeln
                                  posnn = xvbfa-posnn
                                  vbtyp_n = vbtyp_versand
                         binary search
                         transporting no fields.
    if sy-subrc ne 0.
      ypackvbfa = xvbfa.
      ypackvbfa-updkz = updkz_delete.
      append ypackvbfa.
    endif.
  endloop.

  loop at ypackvbfa where vbelv eq if_vbeln and
                          updkz eq updkz_delete.

    clear lf_delete_vbfa.
    if ypackvbfa-posnv is not initial.
      loop at xlips transporting no fields
                    where vbeln eq ypackvbfa-vbelv
                      and posnr eq ypackvbfa-posnv
                      and updkz ne updkz_delete.
        lf_delete_vbfa = charx.
        exit.
      endloop.
    else.
      lf_delete_vbfa = charx.
    endif.
    if lf_delete_vbfa eq charx.
      move-corresponding ypackvbfa to vbfa.
      call function 'RV_XVBFA_MAINTAIN'
        exporting
          f_vorgang              = charl
          fvbfa                  = vbfa
          i_do_not_rebuild_vbapf = charx
        tables
          fxvbfa                 = xvbfa
          fyvbfa                 = yvbfa.
      if vbfa-posnv is not initial.
        read table lt_item_upd with table key posnr = vbfa-posnv
                               transporting no fields.
        if sy-subrc ne 0.
          ls_item_upd-posnr = vbfa-posnv.
          insert ls_item_upd into table lt_item_upd.
        endif.
      endif.
*     Cross-delivery handling units / multiple confirmations (IBGI):
*     Document flow entry needs to stay in document flow
*     Prevent repetitive deletion in next call after 're-creation'
      delete ypackvbfa.
    endif.
  endloop.

  loop at lt_packpos into ls_packpos.
    read table xvbfa with key vbelv = if_vbeln
                              posnv = ls_packpos-posnr
                     binary search
                     transporting no fields.
    if sy-subrc eq 0.
      loop at xvbfa from sy-tabix.
        if xvbfa-vbelv ne if_vbeln or
           xvbfa-posnv ne ls_packpos-posnr.
          exit.
        endif.
        if xvbfa-vbtyp_n ne vbtyp_versand.
          continue.
        endif.
        move-corresponding xvbfa to vbfa.
        call function 'RV_XVBFA_MAINTAIN'
          exporting
            f_vorgang              = charl
            fvbfa                  = vbfa
            i_do_not_rebuild_vbapf = charx
          tables
            fxvbfa                 = xvbfa
            fyvbfa                 = yvbfa.
        if vbfa-posnv is not initial.
          read table lt_item_upd with table key posnr = vbfa-posnv
                                 transporting no fields.
          if sy-subrc ne 0.
            ls_item_upd-posnr = vbfa-posnv.
            insert ls_item_upd into table lt_item_upd.
          endif.
        endif.
      endloop.
    endif.
  endloop.
  free lt_packpos.

enhancement-section     mv50af0p_packfluss_uebern_01 spots es_sapmv50a.
* Creation of cumulated document flow and status update is only done
* once after all document flow updates and only if delivery items are
* affected
  if lt_item_upd is not initial.
    call function 'RV_XVBAPF_CREATE'
      exporting
        vbeln   = if_vbeln
      tables
        fxvbapf = xvbapf
        fxvbfa  = xvbfa.
  endif.
end-enhancement-section.

  loop at lt_item_upd into ls_item_upd.
    call function 'LIPS_STATUS_MAINTAIN'
      exporting
        f_posnr = ls_item_upd-posnr
        f_likp  = likp
      tables
        fxlips  = xlips
        fxvbapf = xvbapf
        fxvbup  = xvbup
        fyvbup  = yvbup
        fxvbfa  = xvbfa.                                      "XAN-SPE
  endloop.

  if sy-subrc eq 0.
    call function 'RV_XVBUK_MAINTAIN'
      exporting
        f_vbeln                  = if_vbeln
        f_vbtyp                  = likp-vbtyp
        f_xvbuv_beruecksichtigen = space
        f_likp                   = likp
        tvlk_wa                  = tvlk
      tables
        fxvbuk                   = xvbuk
        fxvbup                   = xvbup
        fxvbuv                   = xvbuv
        fyvbuk                   = yvbuk
        fxvbfa                   = xvbfa
        fxlikp                   = xlikp.
  endif.

* Ensure correct positioning of the header line of XVBUK
  read table xvbuk with key vbeln = if_vbeln
                   binary search.                           "n_1338547

endform.                    "packfluss_uebernehmen
*eject