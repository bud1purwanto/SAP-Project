*---------------------------------------------------------------------*
*       FORM PPS_AUFTRAG_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Der Auftrag wird gelesen.                                     *
*---------------------------------------------------------------------*
FORM pps_auftrag_pruefen USING pps_aufnr LIKE mseg-aufnr
                               pps_aufps LIKE mseg-aufps
                               pps_budat LIKE mkpf-budat.

ENHANCEMENT-POINT EHP605_MM07MPPS_PPS_AUFTRAG_02 SPOTS ES_SAPMM07M STATIC .

  REFRESH xfbefu.
  CLEAR fuss.
  DATA: autyp LIKE cobl-autyp.
*--> Bei Serienfertigung und Kanban den Auftrag mit Wait = X sperren
  DATA wait_flg TYPE c.
  IF t158-vgart = vgart_ws.
    wait_flg = x.
  ELSE.
    CLEAR wait_flg.
  ENDIF.
*--> Kennzeichen für automatishen WE setzen
  DATA auwe_flg TYPE c.
  IF t158-vgart = vgart_wr.
    auwe_flg = x.
  ELSE.
    CLEAR auwe_flg.
  ENDIF.
ENHANCEMENT-SECTION     EHP603_PPS_AUFTRAG_PRUEFEN_01 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'CO_SF_HEADER_GOODS_RECEIPT'
    EXPORTING
      aufnr      = pps_aufnr
      flg_autwe  = auwe_flg
      flg_wait   = wait_flg
      flg_extern = xmbwl
    IMPORTING
      autyp      = autyp.
END-ENHANCEMENT-SECTION.
* EhP604: Enable GR for Repetitive Manufacturing via Delivery
  IF cl_ewm_switch_check=>le_sfws_sc_ewm_man( ) = /spe/if_const=>c_false OR
     /spe/cl_ctrl=>is_ewm( i_plant = mseg-werks
                           i_stloc = mseg-lgort ) = /spe/if_const=>c_false.
    IF autyp = sa_autyp AND t158-vgart NE vgart_ws.
      MESSAGE e162 WITH pps_aufnr.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'CO_SF_ITEM_GOODS_RECEIPT'
    EXPORTING
      aufnr  = pps_aufnr
      aufps  = pps_aufps
      budat  = pps_budat
      smbln  = mseg-smbln
      smblp  = mseg-smblp
      sjahr  = mseg-sjahr
      xstbw  = vm07m-xstor
      xsobkz = mseg-sobkz
      xkzbws = mseg-kzbws
      xkdauf = mseg-mat_kdauf
      xkdpos = mseg-mat_kdpos
      xcharg = mseg-charg
      xshkzg = t156-shkzg
      xrfrsh = 'X'
    TABLES
      fbefu  = xfbefu.

ENHANCEMENT-POINT EHP605_MM07MPPS_PPS_AUFTRAG_01 SPOTS ES_SAPMM07M .

  def_break 'CO_SF_ITEM_GOODS_RECEIPT'.                     "#EC *
  BREAK-POINT ID mb_co_sf_item_goods_receipt.

* assertion, to be used in background/ update task mainly
* object might not yet be created when the form is called the first time
  IF g_assert IS BOUND.
    IF g_assert->debug_auth = x.
      g_assert->as_co_sf_item_goods_receipt(
        EXPORTING
          i_aufnr = pps_aufnr
          i_aufps = pps_aufps
          i_fbefu = xfbefu[] ).
    ENDIF.
  ENDIF.

ENDFORM.                    "PPS_AUFTRAG_PRUEFEN