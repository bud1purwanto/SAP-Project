*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_LORD_DOC_READ
*&---------------------------------------------------------------------*

form lord_doc_read.

  data: lt_callback type tdt_lord_callback,
        lr_callback type ref to if_lord_callback.

  if not cl_lord=>gf_loaded is initial or
     not cl_lord=>gf_inload is initial.
    lt_callback = cl_lord=>get_callback( ).
    loop at lt_callback into lr_callback.
      if not lr_callback is initial.
        try.
            call method lr_callback->document_read
              exporting
                ir_sls_data_ref = gr_sls_data_ref.
          catch cx_sy_dyn_call_illegal_method.
        endtry.
      endif.
    endloop.
  endif.

endform.                    "lord_doc_read