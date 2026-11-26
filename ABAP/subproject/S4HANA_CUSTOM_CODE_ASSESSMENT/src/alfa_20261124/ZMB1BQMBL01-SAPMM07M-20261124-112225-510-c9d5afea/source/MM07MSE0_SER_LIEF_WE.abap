*eject
*----------------------------------------------------------------------*
*     Serialnummern kopieren aus Lieferung für WE                      *
*----------------------------------------------------------------------*
FORM ser_lief_we.
  DATA: l_delivery      TYPE vbeln_vl,                           "491680
        l_delivery_item TYPE posnr_vl.                           "491680
  data l_upd_seri type c.                                    "note333842

* XSTOR=2: The correct operation must be MMCC (copy mat.doc.)    "442081
* don't copy serial numbers from delivery (operation SDC6)       "442081
  CHECK VM07M-XSTOR <> 2.                                        "442081

* BAPI and MIGO are responsible to fill serialnumbers, no copy form
* delivery needed
  check xbapi IS INITIAL AND xmigo IS INITIAL.

* Copy serialnumbers from outbound or inbound delivery:          "491680
  IF vm07m-vbeln IS INITIAL.                                     "491680
    l_delivery      = dm07m-vbeln_vl.                            "491680
    l_delivery_item = dm07m-vbelp_vl.                            "491680
  ELSE.                                                          "491680
    l_delivery      = vm07m-vbeln.                               "491680
    l_delivery_item = vm07m-vbelp.                               "491680
  ENDIF.                                                         "491680
ENHANCEMENT-POINT MM07MSE0_SER_LIEF_WE_02 SPOTS ES_MM07MTOP STATIC .

ENHANCEMENT-POINT MM07MSE0_SER_LIEF_WE_01 SPOTS ES_SAPMM07M.
* copy serialnumbers form delivey
  CALL FUNCTION 'SERIALPROFILE_CHECK'
       EXPORTING
            operation     = op_sdc6
            mblnr         = smblnr
            mjahr         = mkpf-mjahr
            blart         = mkpf-blart
            zeile         = mseg-zeile
            document      = l_delivery                           "491680
            item          = l_delivery_item                      "491680
            bwart         = mseg-bwart
            shkzg         = mseg-shkzg
            m_werk        = mseg-werks
            m_lager       = mseg-lgort
            quantity      = xanzsn
            material      = mseg-matnr
            m_charge      = mseg-charg
            l_charge      = mseg-charg                          "1131392
            j_vorgang     = vm07m-vrgng
            snbwg         = s156s-snbwg
            bstch         = bstch
            bstup         = bstup
            budat         = mkpf-budat
       IMPORTING
            anzsn         = dm07m-anzsn
            serial_commit = l_upd_seri.                      "note333842

  if upd_seri is initial.                                    "note333842
    upd_seri = l_upd_seri.                                   "note333842
  endif.                                                     "note333842

ENDFORM.