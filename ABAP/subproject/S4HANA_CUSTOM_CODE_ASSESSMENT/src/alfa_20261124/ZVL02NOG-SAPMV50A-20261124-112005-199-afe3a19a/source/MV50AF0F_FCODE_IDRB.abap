*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FCODE_IDRB (n_574894)                   *
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  fcode_idrb
*&--------------------------------------------------------------------*
form fcode_idrb using is_t185f structure t185f
                      is_t185  structure t185
                      is_t185v structure t185v.


  data: lf_objtype  like nast-objtype,
        ls_borident like borident.

  call function 'SD_OBJECT_TYPE_DETERMINE'
    exporting
      i_document_type   = likp-vbtyp
      i_tvlk            = tvlk
    importing
      e_business_object = lf_objtype
    exceptions
      others            = 0.

  ls_borident-objtype = lf_objtype.
  ls_borident-objkey  = likp-vbeln.

  call function 'ASH_HIERARCHY_SHOW'
    exporting
      i_borident = ls_borident.

  leave to list-processing.

endform.                    "fcode_idrb