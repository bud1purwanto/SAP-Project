*eject
*---------------------------------------------------------------------*
*       FORM   TRANSAKTION_INITIALISIEREN                             *
*---------------------------------------------------------------------*
*       Die Transaktion wird initialisiert.                           *
*---------------------------------------------------------------------*
FORM transaktion_initialisieren.

  REFRESH xmarv. CLEAR xmarv.                               "note 208117
  FREE: xmkpf.
  FREE: ymseg, yvm07m, ydm07m, ymsegk, ylgort, fuss,
        old, bild, biwe, xeksel, xfabe, zfabe, xrbefu, xstpox,
        xebefu, xebefu_cr, xekbnk, xekbnk_cr,
        yebefu_cr, yekbnk, yekbnk_cr, yfbefu_cr,
        xekbnk_kdm,                                         "N1027899
        yekbnk_kdm,                                         "N1520698
        xaccounting, xaccounting_dc,                          "MAA-DEV
        xaccounting_cr, xaccounting_dc_cr,                    "MAA-DEV
        xmarc, xmard, xmcha, xmch1, xmchb,
        xmkol, xmsku, xmslb, xmssl, xmska, xmssa, xmspr, xmssq,
        xekpo, xfaup, xmres, xpbat, xekpk, xekla,
        xebew, xqbew, xobew,
        xmstb, xmste, xmstq,                                  "SIT
        xmbew, xekws, xekwv, xekbn, xekbv, xfaws,
        xxiseg,
        xekbe_sc,                                               "Outsourced Manufacturing EhP 4
        omseg, ovm07m, odm07m.
  CLEAR: a_zeile, f_zeile, l_zeile, m_zeile, o_zeile, s_zeile,abbruch,
         aufsetzen, aufsetzen_1, kbefu, km07r, save_mblnr, save_xabln,
         marv, vgart_old.
  CLEAR: upd_seri.                                          "note333842
  CLEAR: pre_werks.                                         "170353
ENHANCEMENT-POINT TRANSAKTION_INITIALISIEREN_01 SPOTS ES_SAPMM07M.
  CLEAR: rm07m, h_liefk.                                    "201369
  CLEAR: inventur, tm07i, inv_shared, zikpf.                "315940
  REFRESH zikpf.                                            "315940
  CLEAR: xtfmat.                                            "331690
  REFRESH: xtfmat.                                          "331690
  CLEAR: ytfehl.                                            "418622
  REFRESH: ytfehl.                                          "418622
  CLEAR: prev_expd, akt_expd.                               "439705
  CLEAR x_mulko.                                            "442706
  CLEAR xekls. REFRESH xekls.                               "488949
  CLEAR: status.                                            "510574
  CLEAR: xnumke, xnumki.                                    "782817
  REFRESH: x_lips.                                          "1660570

* refresh messages
  CLEAR:   xnast.                                           "354033
  REFRESH: xnast.                                           "354033
  CLEAR:   msg_objky.                                       "354033
  CLEAR:   nast_key.                                        "354033
  CALL METHOD cl_mmim_line_id_manager=>reset.
  CALL FUNCTION 'VB_INIT'.
  CLEAR gv_order_push.                                      "1143399

* MAA2 Begin
* if business function multi account assignment is active
  IF cl_ops_switch_check=>mm_sfws_maa( ) IS NOT INITIAL AND
      NOT go_mmim_maa_2 IS BOUND.
* get instance of class CL_MMIM_MAA_2
    go_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( ).
  ENDIF.
* MAA2 End

ENDFORM.                    "transaktion_initialisieren