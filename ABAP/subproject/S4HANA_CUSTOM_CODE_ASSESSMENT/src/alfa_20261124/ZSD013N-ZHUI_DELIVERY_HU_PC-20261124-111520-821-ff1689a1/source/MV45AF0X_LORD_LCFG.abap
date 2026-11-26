*&---------------------------------------------------------------------*
*&  Include           MV45AF0X_LORD_LCFG
*&---------------------------------------------------------------------*

form set_characteristic_view using uv_muebs
                                   uv_posnr.

  data: ls_vbmuet type vbmuet.
  data: ls_vbmuez type vbmuez,
        lt_vbmuez type standard table of vbmuez.
  data: ls_cabn type cabn,
        ls_cabnt type cabnt.
  data: lt_characteristic type standard table of tgs_characteristic.
  data: lv_msg type string.
  data: lv_index type sy-tabix.


  if uv_muebs is initial.
*   delete view entries.
    delete gt_characteristic where posnr eq uv_posnr.
  else.
*   does characteristiv view exist?
    select single *
           from vbmuet
           into ls_vbmuet
           where muebs = uv_muebs
             and spras = sy-langu.
    if sy-subrc <> 0.
      select single *
             from vbmuet
             into ls_vbmuet
             where muebs = uv_muebs.
      if sy-subrc <> 0.
        message w214(v2) with uv_muebs into lv_msg.
        message_collect_lord.
        exit.
      endif.
    endif.

*   delete previous view entries.
    delete gt_characteristic where posnr eq uv_posnr.

    select *
           from vbmuez
           into table lt_vbmuez
           where muebs = uv_muebs.
    sort lt_vbmuez by muebs folge.

    lv_index = 0.
    loop at lt_vbmuez into ls_vbmuez.
      select single *
             from cabn
             into ls_cabn
             where atnam = ls_vbmuez-atnam.
      if sy-subrc = 0.
        lv_index = lv_index + 1.
        clear gs_characteristic.
        gs_characteristic-posnr = uv_posnr.
        gs_characteristic-index = lv_index.
        gs_characteristic-cleng = ls_vbmuez-cleng.
        move-corresponding ls_cabn to gs_characteristic.
        select single *
               from cabnt
               into ls_cabnt
               where atinn = ls_cabn-atinn
                 and spras = sy-langu.
        if sy-subrc = 0.
          gs_characteristic-atbez = ls_cabnt-atbez.
        else.
          gs_characteristic-atbez = gs_characteristic-atnam.
        endif.
        read table gt_characteristic
             transporting no fields
             with key posnr = gs_characteristic-posnr
                      index = gs_characteristic-index
                      binary search.
        insert gs_characteristic into gt_characteristic index sy-tabix.
      endif.
    endloop.
  endif.

endform.                    "set_characteristic_view


*&---------------------------------------------------------------------*
*&      Form  fill_characteristic_wa
*&---------------------------------------------------------------------*
form fill_characteristic_wa using uv_posnr.

  data: lv_numc2 type numc2.
  data: lv_fieldname type fieldname.
  data: lv_index type sy-tabix.
  data: lv_posnr type posnr.
  data: lf_head_data type flag.

  field-symbols:
        <lv_field_mnam> type data,
        <lv_field_mbez> type data,
        <lv_field_mwrt> type data.


  lv_posnr = uv_posnr.
  do.
    lv_index = sy-index.
    lv_numc2 = sy-index.
    clear lv_fieldname.
    concatenate 'RV45A-MNAM' lv_numc2 into lv_fieldname.
    assign (lv_fieldname) to <lv_field_mnam>.
    if sy-subrc <> 0.
      exit.
    endif.
    clear <lv_field_mnam>.
    clear lv_fieldname.
    concatenate 'RV45A-MBEZ' lv_numc2 into lv_fieldname.
    assign (lv_fieldname) to <lv_field_mbez>.
    clear <lv_field_mbez>.
    clear lv_fieldname.
    concatenate 'RV45A-MWERT' lv_numc2 into lv_fieldname.
    assign (lv_fieldname) to <lv_field_mwrt>.
    clear <lv_field_mwrt>.
    clear gs_characteristic.
    read table gt_characteristic
         into gs_characteristic
         with key posnr = lv_posnr
                  index = lv_index
                  binary search.
    if sy-subrc <> 0.
      if lv_posnr ne posnr_null and
         lv_index = 1.
        lv_posnr = posnr_null.
        clear gs_characteristic.
        read table gt_characteristic
             into gs_characteristic
             with key posnr = lv_posnr
                      index = lv_index
                      binary search.
      endif.
    endif.
    if not gs_characteristic is initial.
      <lv_field_mnam> = gs_characteristic-atnam.
      <lv_field_mbez> = gs_characteristic-atbez.
    endif.
  enddo.

endform.                    "fill_characteristic_wa


*&---------------------------------------------------------------------*
*&      Form  read_configuration
*&---------------------------------------------------------------------*
form read_configuration using uv_cuobj.

  data: ls_configuration type conf_out,
        lt_configuration type standard table of conf_out.
  data: lv_numc2 type numc2,
        lv_fieldname type fieldname,
        lv_characteristic type char100,
        lv_strlen type i.

  field-symbols:
        <lv_field_mnam> type data,
        <lv_field_mwrt> type data.

  check not uv_cuobj is initial.

  call function 'VC_I_GET_CONFIGURATION_IBASE'
    exporting
      instance      = uv_cuobj
      language      = sy-langu
    tables
      configuration = lt_configuration
    exceptions
      others        = 4.


  loop at lt_configuration into ls_configuration.
    do.
      lv_numc2 = sy-index.
      clear lv_fieldname.
      concatenate 'RV45A-MNAM' lv_numc2 into lv_fieldname.
      assign (lv_fieldname) to <lv_field_mnam>.
      if sy-subrc <> 0.
        exit.
      endif.
      if <lv_field_mnam> = ls_configuration-atnam .
        clear lv_fieldname.
        concatenate 'RV45A-MWERT' lv_numc2 into lv_fieldname.
        assign (lv_fieldname) to <lv_field_mwrt>.
        if sy-subrc <> 0.
          exit.
        endif.
        if <lv_field_mwrt> is initial.
          <lv_field_mwrt> = ls_configuration-atwtb.
        else.
          clear lv_characteristic.
          concatenate <lv_field_mwrt> '; ' into lv_characteristic.
          concatenate lv_characteristic ls_configuration-atwtb
                      into lv_characteristic separated by space.
          lv_strlen = strlen( lv_characteristic ).
          if lv_strlen > 30.
            lv_characteristic+27(3) = '...'.
          endif.
          <lv_field_mwrt> = lv_characteristic.
        endif.
      endif.
    enddo.
  endloop.

endform.                    "read_configuration


*&---------------------------------------------------------------------*
*&      Form  lord_lcfg_pbo
*&---------------------------------------------------------------------*
form lord_lcfg_pbo.

  perform fill_characteristic_wa using vbap-posnr.
  perform read_configuration using vbap-cuobj.

endform.                    "lord_lcfg_pbo


*&---------------------------------------------------------------------*
*&      Form  collect_char_request
*&---------------------------------------------------------------------*
form collect_char_request using uv_count.

  data: lv_count type numc2.
  data: lv_fieldname type fieldname.
  data: lv_posnr type posnr.

  field-symbols:
        <lv_field_mnam> type data,
        <lv_field_mwrt> type data.


  lv_count = uv_count.

  clear lv_fieldname.
  concatenate 'RV45A-MNAM' lv_count into lv_fieldname.
  assign (lv_fieldname) to <lv_field_mnam>.
  if sy-subrc <> 0.
    exit.
  endif.
  clear lv_fieldname.
  concatenate 'RV45A-MWERT' lv_count into lv_fieldname.
  assign (lv_fieldname) to <lv_field_mwrt>.
  if sy-subrc <> 0.
    exit.
  endif.

  lv_posnr = vbap-posnr.

  clear gs_characteristic.
  read table gt_characteristic
       into gs_characteristic
       with key posnr = lv_posnr
                index = 1
                binary search.
  if sy-subrc = 0.
    clear gs_characteristic.
    read table gt_characteristic
         into gs_characteristic
         with key posnr = lv_posnr
                  index = lv_count
                  binary search.
    if sy-subrc = 0.
      clear gs_char_request.
      gs_char_request-atwtb = <lv_field_mwrt>.
      gs_char_request-atinn = gs_characteristic-atinn.
      append gs_char_request to gt_char_request.
    endif.
  else.
    lv_posnr = posnr_null.
    clear gs_characteristic.
    read table gt_characteristic
         into gs_characteristic
         with key posnr = lv_posnr
                  index = lv_count
                  binary search.
    if sy-subrc = 0.
      clear gs_char_request.
      gs_char_request-atwtb = <lv_field_mwrt>.
      gs_char_request-atinn = gs_characteristic-atinn.
      append gs_char_request to gt_char_request.
    endif.
  endif.

endform.                    "collect_char_request