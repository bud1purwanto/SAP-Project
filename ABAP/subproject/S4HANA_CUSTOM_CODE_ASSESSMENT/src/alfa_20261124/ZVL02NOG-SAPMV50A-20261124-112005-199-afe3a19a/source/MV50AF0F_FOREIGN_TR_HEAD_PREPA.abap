*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FOREIGN_TR_HEAD_PREPA                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FOREIGN_TRADE_HEAD_PREPARE
*&---------------------------------------------------------------------*
FORM foreign_trade_head_prepare
     TABLES h_tab_xlips    STRUCTURE xlips
     USING  value(h_fcode) LIKE      t185-fcode
            value(h_trtyp) LIKE      t180-trtyp
            value(h_hland) LIKE      tvst-aland
            value(h_vbtyp) LIKE      likp-vbtyp
            value(h_exnum) LIKE      likp-exnum
            value(h_lifnr) LIKE      likp-lifnr
            value(h_fkstk) LIKE      vbuk-fkstk
            value(h_kunnr) like      kuwev-kunnr
            value(h_land1) like      kuwev-land1
            value(h_name1) like      kuwev-name1.

  DATA: lf_merk_ahbas       LIKE eikp-ahbas,
        lf_fcode            LIKE sy-ucomm .

  FIELD-SYMBOLS: <ls_xlips> TYPE lipsvb.

*------- ANZEIGE-Modus, falls Lieferung bereits fakturiert
  IF ( NOT ( h_trtyp EQ chara ) ) AND
     (       h_fkstk CA 'BC'    ) .
    h_trtyp = chara.
    MESSAGE s131.
  ENDIF.

*------- Setzen des Außenhandelsbasisbelegflags
*------- Im Fall von Anlieferungen:
*------- Partner Lieferant statt Warenempfaenger
*------- Land des belieferten Werks als Hausland
  IF ( h_vbtyp CA vbtyp_mmli ) .
    lf_merk_ahbas = '1LA'.
    h_kunnr       = h_lifnr.
    READ TABLE h_tab_xlips ASSIGNING <ls_xlips>
                           INDEX 1.
    IF ( sy-subrc is initial ) .
      PERFORM t001w_select USING <ls_xlips>-werks
                                 space
                                 sy-subrc.
      IF ( sy-subrc is initial ) .
        h_hland = t001w-land1.
      ENDIF.
    ENDIF.
  ELSE.
    lf_merk_ahbas = '2LI'.
  ENDIF.

*------- Uebernehmen des ausgeloesten FCodes
  lf_fcode = h_fcode .

*------- Aufruf FB
  CALL FUNCTION 'FTRADE_HEADER_DATA_MNT_TS_PBO'
    EXPORTING
      i_ftrade_number         = h_exnum
      i_home_country          = h_hland
      i_partner_country       = h_land1
      i_partner_name          = h_name1
      i_partner_number        = h_kunnr
      i_ft_basis              = lf_merk_ahbas
      i_transaction_type      = h_trtyp
      i_function_code         = lf_fcode
      i_function_code_default = 'ENT1'
      I_SD_DOC_CAT_dl         = h_vbtyp.

ENDFORM.                               " FOREIGN_TRADE_HEAD_PREPARE