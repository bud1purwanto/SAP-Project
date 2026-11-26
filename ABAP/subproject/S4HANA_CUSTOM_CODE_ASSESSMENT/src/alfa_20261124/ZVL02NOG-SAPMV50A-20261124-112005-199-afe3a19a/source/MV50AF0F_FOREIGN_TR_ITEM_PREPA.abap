*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FOREIGN_TR_ITEM_PREPA                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FOREIGN_TRADE_ITEM_PREPARE
*&---------------------------------------------------------------------*
FORM foreign_trade_item_prepare
     USING  value(h_fcode) LIKE t185-fcode
            value(h_trtyp) LIKE t180-trtyp
            value(h_hland) LIKE tvst-aland
            value(h_vbtyp) LIKE likp-vbtyp
            value(h_land1) LIKE kuwev-land1
            value(h_exnum) LIKE likp-exnum
            value(h_posnr) LIKE lips-posnr
            value(h_werks) LIKE lips-werks
            value(h_matnr) LIKE lips-matnr
            value(h_arktx) LIKE lips-arktx
            value(h_charg) LIKE lips-charg
            value(h_fksta) LIKE xvbup-fksta.

  DATA: lf_merk_ahbas LIKE eikp-ahbas,
        lf_fcode LIKE sy-ucomm.

*------- ANZEIGE-Modus falls Lieferpositions bereits fakturiert
  IF ( NOT ( h_trtyp EQ chara ) ) AND
     (       h_fksta CA 'BC'    ) .
    h_trtyp = chara.
    MESSAGE s131.
  ENDIF.

*------- Setzen des Außenhandelsbasisbelegflags
*------- Im Fall von Anlieferungen:
*------- Partner Lieferant statt Warenempfaenger
*------- Land des belieferten Werks als Hausland
  IF ( h_vbtyp CA vbtyp_mmli ) .
    lf_merk_ahbas = '1LA'.
    PERFORM t001w_select USING h_werks
                               space
                               sy-subrc.
    h_hland = t001w-land1.
  ELSE.
    lf_merk_ahbas = '2LI'.
  ENDIF.

*------- Uebernahme des ausgeloesten FCodes
  lf_fcode = fcode.

*------- Aufruf FB
  CALL FUNCTION 'FTRADE_ITEM_DATA_MNT_TS_PBO'
       EXPORTING
            i_partner_country         = h_land1
            i_material_text           = h_arktx
            i_batch_number            = h_charg
            i_ftrade_number           = h_exnum
            i_ftrade_number_line_item = h_posnr
            i_home_country            = h_hland
            i_material_number         = h_matnr
*           I_MANUFACTURER_NUMBER     = ' '
            i_ft_basis                = lf_merk_ahbas
            i_stat_complete_mandatory = ' '
            i_transaction_type        = h_trtyp
            i_function_code           = lf_fcode
            i_function_code_default   = 'ENT1'.
*            i_function_code_default   = 'T\06'.

ENDFORM.