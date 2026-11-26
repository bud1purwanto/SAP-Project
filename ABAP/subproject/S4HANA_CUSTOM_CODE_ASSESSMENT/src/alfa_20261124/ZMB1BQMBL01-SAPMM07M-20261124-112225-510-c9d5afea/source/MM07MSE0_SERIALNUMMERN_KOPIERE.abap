*eject.
*----------------------------------------------------------------------*
*          Serialnummern kopieren                                      *
*----------------------------------------------------------------------*
FORM serialnummern_kopieren USING i-matnr LIKE mseg-matnr
                                  i-ummat LIKE mseg-matnr
                                  i-sernp LIKE dm07m-sernp
                                  i-anzsn LIKE dm07m-anzsn
                                  i-mblnr LIKE mseg-mblnr
                                  i-mblnr_old LIKE mseg-mblnr
                                  i-mjahr LIKE mkpf-mjahr
                                  i-mjahr_new LIKE mkpf-mjahr
                                  i-zeile LIKE mseg-zeile
                                  i-zeile_new LIKE mseg-zeile
                                  i-blart LIKE mkpf-blart
                                  i-bwart LIKE mseg-bwart
                                  i-shkzg LIKE mseg-shkzg
                                  i-werks LIKE mseg-werks
                                  i-lgort LIKE mseg-lgort
                                  i-charg LIKE mseg-charg
                                  i-cuobj LIKE dm07m-cuobj
                                  i-vrgng LIKE st156s-vrgng
                                  i-snbwg LIKE t156q-snbwg
                                  i-stdpd LIKE dm07m-stdpd
                                  i-lchar LIKE mseg-charg.      "1131392

  DATA: l_xbapi TYPE c,
        l_t_mesg LIKE smesg OCCURS 0,                            "910987
        l_s_mesg LIKE smesg,                                     "910987
        l_error_exist TYPE c,                                    "910987
        l_msgno LIKE sy-msgno.                                   "910987
  l_xbapi = xbapi.
  IF l_xbapi IS INITIAL.
    l_xbapi = xmigo.           "same serialnumber-functionality for MIGO
  ENDIF.


ENHANCEMENT-POINT SERIALNUMMERN_KOPIERREN_01 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     SERIALNUMMERN_KOPIERREN_02 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'SERIALPROFILE_CHECK'
       EXPORTING
            material  = i-matnr
            r_material = i-ummat
            operation = op_mmmc
            profile   = i-sernp
            quantity  = i-anzsn
            mblnr     = i-mblnr
            mjahr     = i-mjahr
            mblnr_old = i-mblnr_old
            mjahr_new = i-mjahr_new
            zeile     = i-zeile
            zeile_new = i-zeile_new
            blart     = i-blart
            bwart     = i-bwart
            shkzg     = i-shkzg
            m_werk    = i-werks
            m_lager   = i-lgort
            m_charge  = i-charg
            l_charge  = i-lchar                                 "1131392
            cuobj     = i-cuobj
            kmatnr    = i-stdpd
            j_vorgang = i-vrgng
            snbwg     = i-snbwg
            bstch     = bstch
            bstup     = bstup
            bapi      = l_xbapi
            budat     = mkpf-budat
       IMPORTING
            anzsn     = dm07m-anzsn
*               Start of correction for note 910987                    *
*Following correction is done in order to capture the exception
*'general_serial_error' thrown by serial-number function module and
*populate the errors in table l_t_mesg to MIGO application log.
       CHANGING
              T_SMESG = l_t_mesg
       EXCEPTIONS
              GENERAL_SERIAL_ERROR = 4.     "#EC ARGCHECKED
 IF SY-SUBRC = 4.
  LOOP AT l_t_mesg into l_s_mesg.
    IF l_s_mesg-msgty = 'E' AND l_error_exist IS INITIAL.
      l_error_exist = 'X'.
    ENDIF.
    IF xmigo = x.
       l_msgno = l_s_mesg-txtnr.
       PERFORM naco_log(sapfm07m) USING l_s_mesg-msgty
                                l_s_mesg-arbgb
                                l_msgno
                                l_s_mesg-msgv1
                                l_s_mesg-msgv2
                                l_s_mesg-msgv3
                                l_s_mesg-msgv4.
    ENDIF.
  ENDLOOP.
  IF l_error_exist = 'X'.
    MESSAGE ID 'IO' TYPE 'E' NUMBER '232'.
  ENDIF.
 ENDIF.
*                End of correction for note 910987                     *
END-ENHANCEMENT-SECTION.

ENDFORM.