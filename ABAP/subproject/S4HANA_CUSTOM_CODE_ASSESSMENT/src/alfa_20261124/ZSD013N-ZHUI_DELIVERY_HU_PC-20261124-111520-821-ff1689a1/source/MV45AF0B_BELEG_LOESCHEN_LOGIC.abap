*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_BELEG_LOESCHEN_LOGIC
*&---------------------------------------------------------------------*

form beleg_loeschen_pruefen_logic changing cv_nodel type flag.

  data: lv_tabix type sytabix.

  if not gr_logic_vbak is initial.
    lv_tabix = 1.
    gr_logic_vbak->check_delete( exporting iv_tabix = lv_tabix
                                 changing  cv_nodel = cv_nodel ).
  endif.

endform.                    "beleg_loeschen_pruefen_logic


*&---------------------------------------------------------------------*
*&      Form  beleg_loeschen_logic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form beleg_loeschen_logic.

  data: lv_tabix type sytabix.

  if not gr_logic_vbak is initial.
    lv_tabix = 1.
    gr_logic_vbak->data_delete( exporting iv_tabix = lv_tabix
                                          if_nocheck = charx ).
  endif.

endform.                    "beleg_loeschen_logic