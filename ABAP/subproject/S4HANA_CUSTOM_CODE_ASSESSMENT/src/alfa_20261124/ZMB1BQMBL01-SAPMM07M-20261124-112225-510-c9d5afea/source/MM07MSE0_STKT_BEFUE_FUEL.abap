*eject.
**---------------------------------------------------------------------*
**    Best.fortschreibungsstrukturen werden für                        *
**    die Serialnummern gefüllt                                        *
**---------------------------------------------------------------------*
FORM stkt_befue_fuel USING bustm LIKE t156sy-bustm.

  DATA serial156m LIKE t156m OCCURS 5 WITH HEADER LINE.
  DATA l_lifnr LIKE mseg-lifnr.                             "note325319
  DATA: ls_st156s LIKE st156s,                              "note325547
        l_bustm LIKE t156s-bustm.                           "note325547
  DATA: lv_ownls TYPE abap_bool.
  STATICS: sv_called TYPE c,
           sr_badi TYPE REF TO mb_cross_system_check_sap.
  FIELD-SYMBOLS <bst1> LIKE bsinf.
  FIELD-SYMBOLS <bst2> LIKE bsinf.

  CHECK NOT t156 IS INITIAL.           "Dump when mb03->show sern.
  CLEAR: bstup, bstch.
  bstch-b_relev = bstup-b_relev = x.

  IF bustm IS INITIAL.                                      "note325547
* in case that there is no quantity string in mseg it has to be
* read from t156s
    CALL FUNCTION 'MB_CONTROL_MOVETYPE_GET_SINGLE'          "note325547
         EXPORTING                                          "note325547
              i_mandt              = sy-mandt               "note325547
              i_bwart              = mseg-bwart             "note325547
              i_wertu              = mseg-wertu             "note325547
              i_mengu              = mseg-mengu             "note325547
              i_sobkz              = mseg-sobkz             "note325547
              i_kzbew              = mseg-kzbew             "note325547
              i_kzzug              = mseg-kzzug             "note325547
              i_kzvbr              = mseg-kzvbr             "note325547
         IMPORTING                                          "note325547
              e_st156s             = ls_st156s              "note325547
         EXCEPTIONS                                         "note325547
              no_entry_found       = 1                      "note325547
              inconsistent_entries = 2                      "note325547
              OTHERS               = 3.                     "note325547
    IF sy-subrc <> 0.                                       "note325547
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno     "note325547
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.     "note325547
    ENDIF.                                                  "note325547
    l_bustm = ls_st156s-bustm.                              "note325547
  ELSE.                                                     "note325547
    l_bustm = bustm.                                        "note325547
  ENDIF.                                                    "note325547


  CALL FUNCTION 'MB_T156M_GET'
    EXPORTING
      i_xchpf          = vm07m-xchpf
      i_qm_zustd       = dm07m-qm_zustd
      i_zustd          = mseg-zustd
      i_insmk          = mseg-insmk
      i_attyp          = vm07m-attyp
      i_bustm          = l_bustm
      i_kzdzv          = kzdzv
      i_mseg           = mseg
    TABLES
      et_t156m         = serial156m
    EXCEPTIONS
      no_entries_found = 1.
  IF sy-subrc = 1.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT dm07m-kzuml IS INITIAL AND NOT dm07m-umxch IS INITIAL. "331195
    CALL FUNCTION 'MB_TRANSFER_STRING_CHECK'                "note331195
        EXPORTING                                           "note331195
              i_bustm           = l_bustm                   "note331195
              is_mseg           = mseg                      "note331195
              is_dm07m          = dm07m                     "note331195
              i_kzdch           = kzdch                     "note331195
              i_attyp           = dm07m-umatt               "note331195
              dont_change_dm07m = x                         "note331195
         TABLES                                             "note331195
              ct_t156m          = serial156m                "note331195
         CHANGING                                           "note331195
              cs_t156m          = t156m                     "note331195
         EXCEPTIONS                                         "note331195
              internal_error    = 1                         "note331195
              OTHERS            = 2.                        "note331195
                                                            "note331195
    IF sy-subrc <> 0.                                       "note331195
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno     "note331195
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.     "note331195
    ENDIF.                                                  "note331195
  ENDIF.                                                    "note331195

  IF mseg-emlif <> mseg-lifnr AND NOT mseg-emlif IS INITIAL. "note325319
    l_lifnr = mseg-emlif.                                   "note325319
  ELSE.                                                     "note325319
    l_lifnr = mseg-lifnr.                                   "note325319
  ENDIF.                                                    "note325319
  IF mseg-sobkz = 'T' AND
     ( mseg-bustm = 'MAUT' OR mseg-bustm = 'MAIT' ).
    CASE mseg-umsok.
      WHEN space.
        DELETE serial156m WHERE cnt02 = 3 OR cnt02 = 4.
      WHEN e.
        DELETE serial156m WHERE cnt02 = 2 OR cnt02 = 4.
      WHEN q.
        DELETE serial156m WHERE cnt02 = 2 OR cnt02 = 3.
      WHEN OTHERS.
    ENDCASE.
    LOOP AT serial156m WHERE bustm = l_bustm.
      CHECK serial156m-cnt02 > 1.
      serial156m-cnt02 = 2.
      MODIFY serial156m.
    ENDLOOP.
  ENDIF.
* If you do changes within this LOOP please also consider   "n1388999
* to adjust FM SERIAL_CHECK_STRUCTURE_FILL accordingly!!!   "n1388999
  LOOP AT serial156m WHERE bustm = l_bustm.
    IF mseg-shkzg = h AND serial156m-cnt02 = 1.
      ASSIGN bstch TO <bst1>.
      ASSIGN bstup TO <bst2>.
    ELSEIF mseg-shkzg = h AND serial156m-cnt02 = 2.
      ASSIGN bstup TO <bst2>.
    ELSEIF mseg-shkzg = s AND serial156m-cnt02 = 1.
      ASSIGN bstup TO <bst1>.
      ASSIGN bstch TO <bst2>.
    ELSEIF mseg-shkzg = s AND serial156m-cnt02 = 2.
      ASSIGN bstch TO <bst2>.
    ENDIF.
    IF serial156m-cnt02 = 1.
      <bst1>-lbbsa = serial156m-lbbsa.
      IF NOT serial156m-smarc IS INITIAL.
        <bst2>-b_werk  = mseg-werks.
        <bst2>-lbbsa   = serial156m-kbbsa.
        IF serial156m-smarc = 'WU5' OR                            "SIT
           serial156m-smarc = 'WU6'.                              "SIT
          <bst1>-b_werk    = mseg-werks.                          "SIT
        ENDIF.                                                    "SIT
      ENDIF.
      IF NOT serial156m-smard IS INITIAL.
        <bst1>-b_werk    = mseg-werks.
        <bst1>-b_lager   = mseg-lgort.
        IF serial156m-smard  = 'LU2' OR                     "681315
           serial156m-smard  = 'LU3'.                       "681315
          <bst2>-b_werk  = mseg-werks.
          <bst2>-b_lager = mseg-lgort.
          <bst2>-lbbsa   = serial156m-kbbsa.
        ENDIF.
      ENDIF.
      IF NOT serial156m-smchb IS INITIAL.
        <bst1>-b_werk     = mseg-werks.
        <bst1>-b_lager    = mseg-lgort.
        <bst1>-b_charge   = mseg-charg.
        IF serial156m-smchb   = 'CU2' OR                    "681315
           serial156m-smchb   = 'CU3'.                      "681315
          <bst2>-b_werk   = mseg-werks.
          <bst2>-b_lager  = mseg-lgort.
          <bst2>-b_charge = mseg-charg.
          <bst2>-lbbsa    = serial156m-kbbsa.
        ENDIF.
      ENDIF.
ENHANCEMENT-POINT STKT_BEFUE_FUEL_01 SPOTS ES_SAPMM07M STATIC.
ENHANCEMENT-POINT STKT_BEFUE_FUEL_02 SPOTS ES_SAPMM07M.
      IF NOT serial156m-smkol IS INITIAL.
        <bst1>-b_werk   = mseg-werks.
        <bst1>-b_lager  = mseg-lgort.
        <bst1>-b_charge = mseg-charg.
ENHANCEMENT-SECTION     STKT_BEFUE_FUEL_03 SPOTS ES_SAPMM07M.
        <bst1>-lifnr    = mseg-lifnr.
END-ENHANCEMENT-SECTION.
        <bst1>-sobkz    = mseg-sobkz.
      ENDIF.
      IF NOT serial156m-smsku IS INITIAL.
        <bst1>-b_werk   = mseg-werks.
        <bst1>-b_lager  = mseg-lgort.
        <bst1>-b_charge = mseg-charg.
        <bst1>-kunnr    = mseg-kunnr.
        <bst1>-sobkz    = mseg-sobkz.
*--- OM EhP 604
        IF serial156m-smsku = 'V0B'.
          <bst2>-b_werk   = mseg-werks.
          <bst2>-lbbsa    = serial156m-kbbsa.
          <bst2>-b_charge = mseg-charg.
          <bst2>-kunnr    = mseg-kunnr.
          <bst2>-sobkz    = mseg-sobkz.
        ENDIF.
*--- OM EhP 604
      ENDIF.
      IF NOT serial156m-smslb IS INITIAL.
        <bst1>-b_werk   = mseg-werks.
        <bst1>-b_charge = mseg-charg.
        <bst1>-lifnr = l_lifnr.                             "note325319
        <bst1>-sobkz = mseg-sobkz.
*--- OM EhP 604
        IF serial156m-smslb = 'O0V'.
          <bst2>-b_werk   = mseg-werks.
          <bst2>-lbbsa    = serial156m-kbbsa.
          <bst2>-b_charge = mseg-charg.
          <bst2>-lifnr    = l_lifnr.
          <bst2>-sobkz    = mseg-sobkz.
        ENDIF.
*--- OM EhP 604
      ENDIF.
      IF NOT serial156m-smska IS INITIAL OR
             serial156m-smste = 'AS2'.                            "SIT
        <bst1>-b_werk   = mseg-werks.
        <bst1>-b_lager  = mseg-lgort.
        <bst1>-b_charge = mseg-charg.
        <bst1>-kdauf    = mseg-mat_kdauf.
        <bst1>-kdpos    = mseg-mat_kdpos.
        <bst1>-sobkz    = mseg-sobkz.
ENHANCEMENT-POINT STKT_BEFUE_FUEL_04 SPOTS ES_SAPMM07M.
        IF serial156m-smssa = 'AU4' OR                      "684326
           serial156m-smssa = 'AUC' OR                      "805489
           serial156m-smssa = 'AUQ' OR                      "684326
           serial156m-smssa = 'AU6'.                              "SIT
          <bst2>-b_werk   = mseg-werks.                    "note 316342
          <bst2>-kdauf    = mseg-mat_kdauf.                "note 316342
          <bst2>-kdpos    = mseg-mat_kdpos.                "note 316342
          <bst2>-sobkz    = mseg-sobkz.                    "note 316342
          <bst2>-lbbsa    = serial156m-kbbsa.              "note 316342
        ENDIF.                                             "note 316342
      ENDIF.
      IF serial156m-smssa = 'AU5'.                                "SIT
          <bst2>-b_werk   = mseg-werks.                           "SIT
          <bst2>-kdauf    = mseg-mat_kdauf.                       "SIT
          <bst2>-kdpos    = mseg-mat_kdpos.                       "SIT
          <bst2>-sobkz    = mseg-sobkz.                           "SIT
          <bst2>-lbbsa    = serial156m-kbbsa.                     "SIT
      ENDIF.                                                      "SIT
ENHANCEMENT-POINT STKT_BEFUE_FUEL_05 SPOTS ES_SAPMM07M.
      IF NOT serial156m-smspr IS INITIAL OR
             serial156m-smstq = 'QS2'.                            "SIT
        <bst1>-b_werk     = mseg-werks.
        <bst1>-b_lager    = mseg-lgort.
        <bst1>-b_charge   = mseg-charg.
        <bst1>-ps_psp_pnr = mseg-mat_pspnr.
        <bst1>-sobkz      = mseg-sobkz.
ENHANCEMENT-POINT STKT_BEFUE_FUEL_06 SPOTS ES_SAPMM07M.
        IF serial156m-smssp = 'QUL' OR                     "note 679770
           serial156m-smssp = 'QUC' OR                      "805489
           serial156m-smssp = 'QUQ' OR                     "note 679770
           serial156m-smssp = 'QU6'.                              "SIT
          <bst2>-b_werk     = mseg-werks.                  "note 316342
          <bst2>-ps_psp_pnr = mseg-mat_pspnr.              "note 316342
          <bst2>-sobkz      = mseg-sobkz.                  "note 316342
          <bst2>-lbbsa      = serial156m-kbbsa.            "note 316342
        ENDIF.                                             "note 316342
      ENDIF.
      IF serial156m-smssp = 'QU5'.                                "SIT
          <bst2>-b_werk     = mseg-werks.                         "SIT
          <bst2>-ps_psp_pnr = mseg-mat_pspnr.                     "SIT
          <bst2>-sobkz      = mseg-sobkz.                         "SIT
          <bst2>-lbbsa      = serial156m-kbbsa.                   "SIT
      ENDIF.                                                      "SIT
    ENDIF.
    IF serial156m-cnt02 = 2.
      <bst2>-lbbsa = serial156m-lbbsa.
      IF NOT serial156m-smarc IS INITIAL.
        <bst2>-b_werk = mseg-umwrk.
      ENDIF.
      IF NOT serial156m-smard IS INITIAL.
        <bst2>-b_werk  = mseg-umwrk.
        <bst2>-b_lager = mseg-umlgo.
      ENDIF.
      IF NOT serial156m-smchb IS INITIAL.
        <bst2>-b_werk   = mseg-umwrk.
        <bst2>-b_lager  = mseg-umlgo.
        <bst2>-b_charge = mseg-umcha.
      ENDIF.
      IF NOT serial156m-smkol IS INITIAL.
        <bst2>-b_werk   = mseg-umwrk.
        <bst2>-b_lager  = mseg-umlgo.
        <bst2>-b_charge = mseg-umcha.
ENHANCEMENT-SECTION     STKT_BEFUE_FUEL_07 SPOTS ES_SAPMM07M.
        <bst2>-lifnr    = mseg-lifnr.
END-ENHANCEMENT-SECTION.
        <bst2>-sobkz    = mseg-umsok.
      ENDIF.
      IF NOT serial156m-smsku IS INITIAL.
        <bst2>-b_werk   = mseg-umwrk.
        <bst2>-b_lager  = mseg-umlgo.  "für shkzg H initial
        <bst2>-b_charge = mseg-umcha.
        <bst2>-kunnr    = mseg-kunnr.
        <bst2>-sobkz    = mseg-umsok.
      ENDIF.
      IF NOT serial156m-smslb IS INITIAL.
        <bst2>-b_werk   = mseg-umwrk.
        <bst2>-b_charge = mseg-umcha.
        <bst2>-lifnr    = l_lifnr.                          "note325319
        <bst2>-sobkz    = mseg-umsok.
      ENDIF.
      IF NOT serial156m-smska IS INITIAL.
        <bst2>-b_werk   = mseg-umwrk.
        <bst2>-b_lager  = mseg-umlgo.
        <bst2>-b_charge = mseg-umcha.
        <bst2>-kdauf = mseg-kdauf.
        <bst2>-kdpos = mseg-kdpos.
        <bst2>-sobkz = mseg-umsok.
      ENDIF.
ENHANCEMENT-POINT STKT_BEFUE_FUEL_08 SPOTS ES_SAPMM07M.
      IF NOT serial156m-smssa IS INITIAL.                  "note 316342
        <bst2>-b_werk   = mseg-umwrk.                      "note 316342
        <bst2>-kdauf    = mseg-kdauf.                      "note 316342
        <bst2>-kdpos    = mseg-kdpos.                      "note 316342
        <bst2>-sobkz    = mseg-umsok.                      "note 316342
      ENDIF.                                               "note 316342
ENHANCEMENT-POINT STKT_BEFUE_FUEL_10 SPOTS ES_MM07MTOP STATIC .

ENHANCEMENT-POINT STKT_BEFUE_FUEL_09 SPOTS ES_SAPMM07M.
      IF NOT serial156m-smspr IS INITIAL.
        <bst2>-b_werk       = mseg-umwrk.
        <bst2>-b_lager      = mseg-umlgo.
        <bst2>-b_charge     = mseg-umcha.
        <bst2>-ps_psp_pnr   = mseg-ps_psp_pnr.
        <bst2>-sobkz        = mseg-umsok.
      ENDIF.
      IF NOT serial156m-smssp IS INITIAL.                  "note 316342
        <bst2>-b_werk       = mseg-umwrk.                  "note 316342
        <bst2>-ps_psp_pnr   = mseg-ps_psp_pnr.             "note 316342
        <bst2>-sobkz        = mseg-umsok.                  "note 316342
      ENDIF.                                               "note 316342
    ENDIF.
  ENDLOOP.

* For the special case of goods receipt for cross-system
* stock transfer order the serial number cannot be found
* in the transit stock. Therefore I have to remove the line
* with LBBSA = 06.
  IF NOT dm07m-reswk IS INITIAL.                            "sdp462
    lv_ownls = cl_mmim_cross_system=>plant_in_own_system( dm07m-reswk ).
*   Call BAdI to check logical system:
    IF sv_called IS INITIAL.
      TRY.
          GET BADI sr_badi.
        CATCH cx_badi_not_implemented.
          CLEAR: sr_badi.
      ENDTRY.
      sv_called = 'X'.
    ENDIF.
    IF sr_badi IS NOT INITIAL.
      CALL BADI sr_badi->check_goods_receipt
        EXPORTING
          im_mseg  = mseg
          im_dm07m = dm07m
        CHANGING
          ch_ownls = lv_ownls.
    ENDIF.

    IF lv_ownls = abap_false.                               "sdp462
      IF bstch-lbbsa = '06'.                                "sdp462
        CLEAR bstch.                                        "sdp462
        bstch-b_relev = x.                                  "sdp462
      ENDIF.                                                "sdp462
      IF bstup-lbbsa = '06'.                                "sdp462
        CLEAR bstup.                                        "sdp462
        bstup-b_relev = x.                                  "sdp462
      ENDIF.                                                "sdp462
    ENDIF.                                                  "sdp462
  ENDIF.                                                    "sdp462

ENDFORM.                    "stkt_befue_fuel