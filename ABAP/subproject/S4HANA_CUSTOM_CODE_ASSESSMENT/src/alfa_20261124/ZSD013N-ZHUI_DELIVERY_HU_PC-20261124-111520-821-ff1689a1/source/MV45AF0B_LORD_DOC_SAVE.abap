*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_LORD_DOC_SAVE
*&---------------------------------------------------------------------*

form lord_doc_save_prepare.

  data: lt_callback type tdt_lord_callback,
        lr_callback type ref to if_lord_callback.
  data: lv_abort_save type char1.

  if not cl_lord=>gf_loaded is initial.
    lt_callback = cl_lord=>get_callback( ).
    clear lv_abort_save.
    clear gf_saving_abort.
    loop at lt_callback into lr_callback.
      if not lr_callback is initial.
        try.
            call method lr_callback->document_save_prepare
              exporting
                ir_sls_data_ref = gr_sls_data_ref
              importing
                ev_abort_save   = lv_abort_save.
            if not lv_abort_save is initial.
              gf_saving_abort = charx.
              exit.
            endif.
          catch cx_sy_dyn_call_illegal_method.
        endtry.
      endif.
    endloop.
  endif.

endform.                    "lord_doc_save_prepare


*&---------------------------------------------------------------------*
*&      Form  lord_doc_save_prepare_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_doc_save_prepare_2.

  data: lt_callback type tdt_lord_callback,
        lr_callback type ref to if_lord_callback.

  if not cl_lord=>gf_loaded is initial.
    lt_callback = cl_lord=>get_callback( ).
    loop at lt_callback into lr_callback.
      if not lr_callback is initial.
        try.
            call method lr_callback->document_save_prepare_2
              exporting
                ir_sls_data_ref = gr_sls_data_ref.
          catch cx_sy_dyn_call_illegal_method.
        endtry.
      endif.
    endloop.
  endif.

endform.                    "lord_doc_save_prepare_2


*&---------------------------------------------------------------------*
*&      Form  lord_doc_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_doc_save.

  data: lt_callback type tdt_lord_callback,
        lr_callback type ref to if_lord_callback.

  if not cl_lord=>gf_loaded is initial.
    lt_callback = cl_lord=>get_callback( ).
    loop at lt_callback into lr_callback.
      if not lr_callback is initial.
        try.
            call method lr_callback->document_save
              exporting
                ir_sls_data_ref = gr_sls_data_ref.
          catch cx_sy_dyn_call_illegal_method.
        endtry.
      endif.
    endloop.
  endif.

endform.                    "lord_doc_save