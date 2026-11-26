*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FOREIGN_TR_ITEM_PROCE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FOREIGN_TRADE_ITEM_PROCESS
*&---------------------------------------------------------------------*
form foreign_trade_item_process
     using    value(h_posnr) like lips-posnr
     changing h_fcode        like t185-fcode
              h_expkz        like likp-expkz
              h_exnum        like likp-exnum
              h_dataloss     like r185d-dataloss.

  data: lf_dataloss like r185d-dataloss,
        lf_fcode like sy-ucomm.

*------- Uebernahme des ausgeloesten FCodes
  lf_fcode = h_fcode .

*------- Aufruf FB
  call function 'FTRADE_ITEM_DATA_MNT_TS_PAI'
       exporting
            i_ftrade_number           = h_exnum
            i_ftrade_number_line_item = h_posnr
            i_function_code           = lf_fcode
       importing
*           e_ftrade_data_complete
            e_ftrade_number_new       = h_exnum
            e_dataloss                = lf_dataloss
            e_function_code           = lf_fcode
            e_system_ucomm            = sy-ucomm .

*------- Annahme: Lieferungs-FCode wird prozessiert
  if ( not ( lf_fcode is initial ) ) .
    h_fcode = lf_fcode.
  endif.

*------- Setzen des Exportkennzeichens, Uebernahme der EXNUM
  if ( not ( h_exnum is initial ) ) .
    h_expkz = charx.
  else.
    clear: h_expkz.
  endif.

*------- Setzen des DATALOSS-Flags, falls sich AH-Daten geaendert haben
  if (       h_dataloss  is initial   ) and
     ( not ( lf_dataloss is initial ) ) .
    h_dataloss = lf_dataloss.
  endif.

* Trigger update of incompleteness log if necessary
  if not lf_dataloss is initial.                            "N_407546
    perform uc_upd_request(sapfv50u) using charx            "n_531900
                                           h_posnr
                                           posnr_low
                                           posnr_low.
  endif.

endform.