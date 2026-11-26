*----------------------------------------------------------------------*
*   INCLUDE LMIGODN2                                                   *
*   Detail tabstrip output determination implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_output IMPLEMENTATION.

METHOD constructor.
  DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  APPEND 'MIGO_OK_NAST_SHOW' TO lt_okcodes.
  lif_migo_frame~class_id = 'MIGO_DETAIL_OUTPUT'.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes.
ENDMETHOD.

METHOD lif_migo_frame~okcode_handler.
  DATA: ls_goitem TYPE goitem.
  CASE i_okcode.
    WHEN 'MIGO_OK_NAST_SHOW'.
      CALL METHOD lcl_migo_globals=>kernel->line_get
                  EXPORTING i_line    = oref_detail->current_line
                  IMPORTING es_goitem = ls_goitem.
* This will work as long as we have only one material document
* in process: afterwards ZEILE has to be changed
      IF NOT ls_goitem-xlbtype = c.                             "1176516
        CALL METHOD lcl_migo_globals=>kernel->output_show       "1176516
                  EXPORTING i_mblnr = ls_goitem-mblnr
                            i_mjahr = ls_goitem-mjahr
                            i_zeile = ls_goitem-zeile.
      ELSE.                                                     "1176516
*     ZEILE shows the parent item for subcontracting components "1176516
*     -> we have to read mseg-zeile as key for NAST             "1176516
        DATA lv_zeile TYPE mseg-zeile.                          "1176516
        SELECT SINGLE zeile FROM mseg INTO lv_zeile             "1176516
          WHERE mblnr = ls_goitem-mblnr                         "1176516
            AND mjahr = ls_goitem-mjahr                         "1176516
            AND line_id = ls_goitem-global_counter.             "1176516
        IF sy-subrc = 0.                                        "1176516
          CALL METHOD lcl_migo_globals=>kernel->output_show     "1176516
                  EXPORTING i_mblnr = ls_goitem-mblnr           "1176516
                            i_mjahr = ls_goitem-mjahr           "1176516
                            i_zeile = lv_zeile.                 "1176516
        ENDIF.                                                  "1176516
      ENDIF.                                                    "1176516
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.

METHOD lif_migo_frame~message_handler.
ENDMETHOD.


ENDCLASS.