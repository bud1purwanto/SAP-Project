*eject
*---------------------------------------------------------------------*
*       FORM AUTOMATISCHE_ZEILEN                                      *
*---------------------------------------------------------------------*
*       Automatisch zu erzeugende Zeilen werden vorbereitet.          *
*---------------------------------------------------------------------*

* Error AAPO 153 not justified for goods receipt for assets    "n1646357

FORM AUTOMATISCHE_ZEILEN USING S_AKTYP LIKE AKTYP
                               S_TABIX LIKE SY-TABIX
                               S_AZEIL LIKE FUSS-AZEIL
                               is_enhancement TYPE isu_automatische_zeilen."IS2ERP

  DATA: ls_isu_lohnbearbeitung TYPE isu_lohnbearbeitung,    "IS2ERP
        ls_isu_upos_generieren TYPE isu_upos_generieren.    "IS2ERP

ENHANCEMENT-POINT AUTOMATISCHE_ZEILEN_01 SPOTS ES_SAPMM07M.

  PERFORM upos_generieren
                          USING ls_isu_upos_generieren.     "IS2ERP
  CHECK xdeliv IS INITIAL OR xdeliv = '1'.
  PERFORM lohnbearbeitung
                           USING ls_isu_lohnbearbeitung.    "IS2ERP
  DATA ftabix LIKE fuss-tabix. CLEAR ftabix.
  DATA fazeil LIKE fuss-azeil. CLEAR fazeil.
  PERFORM STRUKT_MATERIAL USING S_AKTYP
                                S_TABIX
                                S_AZEIL.

  IF mseg-xmacc = 'V'.   "MAA2 item to split                "MAA2
    IF go_mmim_maa_2 IS NOT BOUND.
*     create an object and get the reference
      go_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( ).
    ENDIF.

    CALL METHOD go_mmim_maa_2->append_new_entry_to_fuss
      EXPORTING
        is_mkpf        = mkpf
        is_dm07m       = dm07m
        is_vm07m       = vm07m                                 "n1646357
      CHANGING
        cs_fuss        = fuss
        ct_fuss        = fuss[]
        cs_mseg        = mseg
        cv_m_zeile     = m_zeile
        cv_y_zeile     = y_zeile
        cv_f_zeile     = f_zeile
        cv_s_zeile     = s_zeile
        cv_flag_error  = gv_flag_error
        ct_message_log = gt_message_log.

    IF gv_flag_error = abap_true.
      PERFORM              send_maa_error_message.
    ENDIF.
  ENDIF.                                                    "MAA2
ENDFORM.