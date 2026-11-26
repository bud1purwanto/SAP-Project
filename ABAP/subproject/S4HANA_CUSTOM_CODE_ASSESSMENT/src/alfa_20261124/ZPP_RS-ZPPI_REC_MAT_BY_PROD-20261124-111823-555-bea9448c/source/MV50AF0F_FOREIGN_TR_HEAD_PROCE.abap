*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FOREIGN_TR_HEAD_PROCE                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FOREIGN_TRADE_HEAD_PROCESS
*&---------------------------------------------------------------------*
FORM foreign_trade_head_process
     CHANGING h_fcode    LIKE t185-fcode
              h_expkz    LIKE likp-expkz
              h_exnum    LIKE likp-exnum
              h_dataloss LIKE r185d-dataloss.

  DATA: lf_dataloss LIKE r185d-dataloss,
        lf_fcode    LIKE sy-ucomm.

*------- Uebernahme des ausgeloesten FCodes
  lf_fcode = h_fcode .

*------- Aufruf FB
  CALL FUNCTION 'FTRADE_HEADER_DATA_MNT_TS_PAI'
       EXPORTING
            i_ftrade_number         = h_exnum
            i_function_code         = lf_fcode
       IMPORTING
*            e_ftrade_data_complete  =
            e_ftrade_number_new     = h_exnum
            e_dataloss              = lf_dataloss
            e_function_code         = lf_fcode
            e_system_ucomm          = sy-ucomm .

*------- Annahme: Lieferungs-FCode wird prozessiert
  IF ( NOT ( lf_fcode IS INITIAL ) ) .
    h_fcode = lf_fcode.
  ENDIF.

*------- Setzen des Exportkennzeichens, Uebernahme der EXNUM
  IF ( NOT ( h_exnum IS INITIAL ) ) .
    h_expkz = charx.
  ELSE.
    CLEAR: h_expkz.
  ENDIF.

*------- Setzen des DATALOSS-Flags, falls sich AH-Daten geaendert haben
  IF (       h_dataloss  IS INITIAL   ) AND
     ( NOT ( lf_dataloss IS INITIAL ) ) .
    h_dataloss = lf_dataloss.
  ENDIF.

* Trigger update of incompleteness log if necessary
  if not lf_dataloss is initial.                            "N_407546
    perform uc_upd_request(sapfv50u) using charx            "n_531900
                                           posnr_low
                                           posnr_low
                                           posnr_low.
  endif.

ENDFORM.                               " FOREIGN_TRADE_HEAD_PROCESS