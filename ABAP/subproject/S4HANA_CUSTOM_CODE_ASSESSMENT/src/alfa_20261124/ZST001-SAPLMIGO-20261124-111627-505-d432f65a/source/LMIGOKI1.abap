*----------------------------------------------------------------------*
*   INCLUDE LMIGOKI1                                                   *
*   Inbound delivery
*----------------------------------------------------------------------*

METHOD inbound_delivery_read.
  DATA: lt_vepwe TYPE ty_t_vepwe,
        ls_vepwe TYPE ty_s_vepwe.
  IF i_shipping_unit = x.
    CALL METHOD shippingelement_select
      EXPORTING
        i_vbeln  = i_inbound_delivery
      IMPORTING
        et_vepwe = lt_vepwe.
  ELSE.
    ls_vepwe-vbeln = i_inbound_delivery.
    APPEND ls_vepwe TO lt_vepwe.
  ENDIF.

  LOOP AT lt_vepwe INTO ls_vepwe.
    CALL METHOD confirmation_get
      EXPORTING
        i_vbeln = ls_vepwe-vbeln
        i_vbelp = ls_vepwe-posnr
        is_vepwe = ls_vepwe.
  ENDLOOP.

ENDMETHOD.