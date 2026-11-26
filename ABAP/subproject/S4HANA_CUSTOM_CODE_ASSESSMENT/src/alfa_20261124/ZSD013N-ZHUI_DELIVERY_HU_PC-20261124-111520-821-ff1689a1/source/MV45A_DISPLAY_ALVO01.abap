*----------------------------------------------------------------------*
***INCLUDE MV45A_DISPLAY_ALVO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_ALV  OUTPUT
*&---------------------------------------------------------------------*

MODULE display_alv OUTPUT.
  PERFORM display_alv.
ENDMODULE.                 " DISPLAY_ALV  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CS_READ_FROM_ALV
*&---------------------------------------------------------------------*
*       Reads the selected row from the ALV GRID
*----------------------------------------------------------------------*
FORM cs_read_from_alv .

  CLEAR: gs_sold_to_party-kunnr,
         gv_kunnr_from_search,
         gv_set_kunnr,
         gs_row_table.

*get number of selected row in selection popup
  CALL METHOD grid1->get_selected_rows
    IMPORTING
      et_index_rows = row_table.

*get index of selected row
  READ TABLE row_table INDEX 1 INTO gs_row_table.
  IF gs_row_table-index IS INITIAL.
*no row selected, take first line as selected
    gs_row_table-index = 1.
  ENDIF.
*read data of selected  customer
  READ TABLE gt_sold_to_party INDEX gs_row_table-index INTO gs_sold_to_party.
  gv_kunnr_from_search = gs_sold_to_party-kunnr.
  gv_set_kunnr = 'X'.

  FREE row_table.

ENDFORM.                    " CS_READ_FROM_ALV