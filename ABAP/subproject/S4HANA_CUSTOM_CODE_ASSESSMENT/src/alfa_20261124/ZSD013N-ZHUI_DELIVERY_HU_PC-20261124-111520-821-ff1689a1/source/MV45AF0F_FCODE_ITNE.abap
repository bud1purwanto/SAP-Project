*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ITNE                                        *
*----------------------------------------------------------------------*
*        form fcode_itne.
*---------------------------------------------------------------------*

form fcode_itne.
  data: tfill like sy-tabix.
  describe table ivbap lines tfill.
  ivbap_tabix_zeile_1 = tfill.
  clear tfill.
endform.