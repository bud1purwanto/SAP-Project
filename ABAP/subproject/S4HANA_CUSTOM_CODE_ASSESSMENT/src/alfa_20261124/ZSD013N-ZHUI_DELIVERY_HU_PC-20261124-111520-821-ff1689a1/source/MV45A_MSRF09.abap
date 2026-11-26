*&---------------------------------------------------------------------*
*&  Include           MV45A_MSRF09
*&---------------------------------------------------------------------*

form msr_set_msr_id using uv_msr_id type msr_process_id.

  vbak-msr_id = uv_msr_id.

endform.                    "msr_set_msr_id


*&---------------------------------------------------------------------*
*&      Form  msr_verify_save_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UT_ITEM_REF  text
*----------------------------------------------------------------------*
form msr_verify_save_create using ut_item_ref type msr_t_item_posnr.

  data: lr_trc_controller type ref to if_msr_trc_ro_no_ui.
  data: lt_item_posnr type msr_t_item_posnr.
  data: lt_messages type bapirettab.


  cl_msr_trc_factory=>init( ).
  lr_trc_controller = cl_msr_trc_factory=>get_instance_ro_no_ui( ).
  if not lr_trc_controller is initial.
    lt_item_posnr = ut_item_ref.
    try.
        call method lr_trc_controller->verify
          exporting
            is_vbak       = vbak
            it_vbap       = xvbap[]
            it_vbap_db    = yvbap[]
            it_vbuk       = xvbuk[]
            it_vbuk_db    = yvbuk[]
            it_vbuv       = xvbuv[]
            it_vbep       = xvbep[]
            it_item_posnr = lt_item_posnr
          importing
            et_messages   = lt_messages.
      catch cx_msr_trc.
        message a000(cx_msr_trc).
    endtry.
    lr_trc_controller->save( ).
  endif.

endform.                    "msr_verify_save_create


*&---------------------------------------------------------------------*
*&      Form  msr_verify_save_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form msr_verify_save_change.

  data: lr_trc_controller type ref to if_msr_trc_ro_no_ui.
  data: lt_messages type bapirettab.

  if not vbak-msr_id is initial and
     t180-trtyp eq charv.
    cl_msr_trc_factory=>init( ).
    lr_trc_controller = cl_msr_trc_factory=>get_instance_ro_no_ui( ).
    if not lr_trc_controller is initial.
      try.
          call method lr_trc_controller->verify
            exporting
              is_vbak     = vbak
              it_vbap     = xvbap[]
              it_vbap_db  = yvbap[]
              it_vbuk     = xvbuk[]
              it_vbuk_db  = yvbuk[]
              it_vbuv     = xvbuv[]
              it_vbep     = xvbep[]
            importing
              et_messages = lt_messages.
        catch cx_msr_trc.
          message a000(cx_msr_trc).
      endtry.
      lr_trc_controller->save( ).
    endif.
  endif.

endform.                    "msr_verify_save_change