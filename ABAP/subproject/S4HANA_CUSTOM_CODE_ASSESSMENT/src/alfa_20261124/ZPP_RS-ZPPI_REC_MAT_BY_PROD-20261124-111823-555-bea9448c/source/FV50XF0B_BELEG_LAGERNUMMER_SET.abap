***INCLUDE FV50XF0B_BELEG_LAGERNUMMER_SET .
*---------------------------------------------------------------------*
*  FORM BELEG_LAGERNUMMER_SETZEN
*---------------------------------------------------------------------*
*  Die WM-Lagernummer im Lieferkopf wird aus den Positionen
*  versorgt:   space - falls dort unterschiedliche vorkommen
*              LGNUM - falls alle Positionen demselben Lager
*                      zugeordnet sind
*  Der aktuelle Kopf steht in CS_LIKP.
*  In der Tabelle XLIPS wird der Lagerplatz mit der Liefernummer
*  versorgt, falls er dynamisch und initial ist.
*---------------------------------------------------------------------*
form delivery_set_lgnum_and_vlstk using    if_send_mess type c
                                  changing cs_likp structure likp
                                           cf_subrc like sy-subrc.

  data:  lf_subrc like sy-subrc,
         lf_lgnum_save like likp-lgnum,                     "HP_384526
         lf_vlstk      like likp-vlstk,                     "n_577746
         lf_flag_lgnum_cleared type c.                      "HP_311836
  statics: sf_lfart like tvlk-lfart.                        "n_577746

  field-symbols: <ls_xlips> like line of xlips.

  lf_lgnum_save = cs_likp-lgnum.
  cf_subrc = 0.

  check cs_likp-stge_loc_change ne gc_stge_loc_change-requested. "n_1302686

  if cs_likp-lfart ne tvlk-lfart.                           "v_n_551608
    data: modified like leshpmd-splidl.
    perform tvlk_select(sapmv50a) using cs_likp-lfart
                              space
                              lf_subrc.
  endif.

  if not cs_likp-verursys is initial.
*   Decentralized warehouse management system
*   Determine warehouse number only once (can not be changed in the
*   decentralized scenario)
    if cs_likp-lgnum is initial.
      perform likp_set_lgnum_lispl(sapfv50k)
              using      cs_likp-vbeln
              changing   cs_likp-lgnum
                         cs_likp-lispl
                         lf_subrc.
    else.
*     Determine dynamic storage bin if required
      loop at xlips assigning <ls_xlips>
                    where vbeln eq cs_likp-vbeln and
                          updkz ne updkz_delete.
        if <ls_xlips>-kzdlg eq charx and
           ( <ls_xlips>-lgpla co '0 ' or <ls_xlips>-lgpla(1) eq '$' ).
          if cs_likp-vbeln(1) ne '$'.
            <ls_xlips>-lgpla = cs_likp-vbeln.
          endif.
        endif.
      endloop.
    endif.
    if cs_likp-vlstk is initial.
      cs_likp-vlstk = chara.
    endif.
  elseif likp-vlstk ca ' AD'.                                 "n_711949
*   Central system or dec. WMS not active
    clear: cs_likp-lgnum.
    if tvlk-lnspl eq charx.
      perform likp_set_lgnum_lispl(sapfv50k)
              using      cs_likp-vbeln
              changing   cs_likp-lgnum
                         cs_likp-lispl
                         lf_subrc.
*     Send message if LGNUM had to be deleted
      if lf_subrc = 1 and
         not *likp-lgnum   is initial and
         not lf_lgnum_save is initial.
        cf_subrc = lf_subrc.
        if if_send_mess eq charx.
          perform message_handling(sapmv50a) using cvbap-posnr
                                                         '410'
                                                         'I'
                                                         'VL'
                                                         cs_likp-lgnum
                                                         space
                                                         space
                                                         space.
        endif.
      endif.
*     Determine distribution status
      perform beleg_verteilung_pruefen using cs_likp-lgnum
                                             cs_likp-verursys
                                             tvlk-dbtch
* SPE MP 14.01.2005 Control distribution of returns deliveries
                                             cs_likp-vbtyp
                                             cs_likp-spe_acc_app_sts
                                             cs_likp-spe_shp_inf_sts
                                    changing cs_likp-vlstk.
    else.
*     No delivery split by warehouse number: determine warehouse number
*     and dynamic storage bin
      loop at xlips assigning <ls_xlips>
                    where vbeln eq cs_likp-vbeln and
                          updkz ne updkz_delete.
        if not <ls_xlips>-lgnum is initial and
           lf_flag_lgnum_cleared eq space.
          if cs_likp-lgnum is initial.
            cs_likp-lgnum = <ls_xlips>-lgnum.
*           Check for wrong customizing settings            "v_n_577746
            perform beleg_verteilung_pruefen using cs_likp-lgnum
                                                   cs_likp-verursys
                                                   tvlk-dbtch
* SPE MP 14.01.2005 Control distribution of returns deliveries
                                                 cs_likp-vbtyp
                                                 cs_likp-spe_acc_app_sts
                                                 cs_likp-spe_shp_inf_sts
                                             changing lf_vlstk.
*           Delivery is relevant for distribution but flag "Delivery
*           split by warehouse number" is not set
            if lf_vlstk ne space and
               tvlk-lfart ne sf_lfart.
              perform message_handling(sapmv50a)
                      using cvbap-posnr
                            '575'
                            'I'
                            'VL'
                            tvlk-lfart
                            cs_likp-lgnum
                            space
                            space.
              sf_lfart = tvlk-lfart.
            endif.                                          "^_n_577746
          else.
            if cs_likp-lgnum ne <ls_xlips>-lgnum.
              clear cs_likp-lgnum.
              lf_flag_lgnum_cleared = charx.
            endif.
          endif.
        endif.                           "xlips-lgnum is initial
        if <ls_xlips>-kzdlg eq charx and
           ( <ls_xlips>-lgpla co '0 ' or <ls_xlips>-lgpla(1) eq '$' ).
          if cs_likp-vbeln(1) ne '$'.
            <ls_xlips>-lgpla = cs_likp-vbeln.
          endif.
        endif.
      endloop.
    endif.
  endif.                                                    "^_n_551608

endform.