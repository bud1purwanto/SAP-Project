*----------------------------------------------------------------------*
***INCLUDE MV45AFFE_FELDAUSWAHL_PAYSP1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_PAYSP1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM feldauswahl_paysp1 .

* Payment Service Provider
  DATA: lv_no_input TYPE xfeld,
        lv_psp_no_input TYPE xfeld,
        lv_inactive TYPE xfeld,
        lv_fieldname TYPE screen-name,
        lv_no_changes TYPE xfeld,
        lv_tabname TYPE char20.
  DATA: lv_action_id TYPE fcode.

  IF gr_paysp IS BOUND.
    SPLIT screen-name AT '-' INTO lv_tabname lv_fieldname.

    IF vbak-sppaym EQ cv_sppaym01 AND
       screen-input EQ 1 AND
       screen-active eq 1 AND
       sy-dyngr NE 'ANFO'.

      IF lv_tabname EQ 'VBAK' OR
         lv_tabname EQ 'VBAP' OR
         lv_tabname EQ 'VBKD' OR
         lv_tabname EQ 'RV45A' OR
         lv_tabname EQ 'CCDATA' OR
         lv_tabname EQ 'KUAGV' OR
         lv_tabname EQ 'CCARD_CVV' OR
         lv_tabname EQ 'TDS_KUNAG_SEARCH_TERM' OR
         lv_tabname EQ 'KOMV' OR
         lv_tabname EQ 'KUWEV' OR
         lv_tabname EQ 'SDPARTNERLIST' OR
         lv_tabname EQ 'FPLTC' OR
         lv_tabname EQ 'COBL' OR
         lv_tabname EQ 'CCDATE' OR
         lv_tabname EQ 'VBSN' OR
         lv_tabname EQ 'VBEP'.

        IF screen-name NE 'RV45A-VBAP_SELKZ' AND
           screen-name NE 'RV45A-S_ABGRU' AND
           screen-name NE 'VBEP-LIFSP' AND
           screen-name NE 'VBAK-FAKSK' AND
           screen-name NE 'VBAP-FAKSP' AND
           screen-name NE 'VBAK-LIFSK'.

          CALL METHOD gr_paysp->get_fieldcheck_general_sls
            EXPORTING
              is_vbak     = vbak
              is_tvak     = tvak
              iv_trtyp    = t180-trtyp
            IMPORTING
              ev_no_input = lv_no_input.

          IF lv_no_input IS NOT INITIAL.
            IF call_activity EQ gc_activity_lord AND
               screen-name   EQ 'VBAP-ABGRU'.
          cl_lord=>get_action_id( IMPORTING ev_action_id = lv_action_id ).
              IF NOT lv_action_id EQ 'SET_PAYSP_ABGRU'.
                screen-input = 0.
              ENDIF.
            ELSE.
              screen-input = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF t180-trtyp EQ charv AND
     screen-name EQ 'BT_STAE'.
      CALL METHOD gr_paysp->get_change_mode_group
        EXPORTING
          iv_group_id   = cl_sls_paysp_integration=>cv_group_id_istat
          iv_trtyp      = t180-trtyp
          is_vbak       = vbak
          is_vbap       = vbap
          is_vbkd       = vbkd
          is_tvak       = tvak
          is_tvap       = tvap
        IMPORTING
          ev_no_changes = lv_no_changes.
      IF lv_no_changes EQ abap_true.
        screen-input = 0.
      ENDIF.
    ENDIF.

  ENDIF. "gr_paysp IS BOUND

  IF screen-name(9) EQ 'GS_LPAYSP' OR
     screen-name EQ 'VBAK-SPPAYM'.
* Default settings for payment method
    IF screen-name EQ 'VBAK-SPPAYM'.
      screen-active = 1.
      IF t180-trtyp EQ chara.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
    ELSE.
* Default settings for provider
      IF screen-name EQ 'GS_LPAYSP_DATA-PS_PROVIDER'.
        screen-active = 1.
        screen-input = 1.
      ENDIF.
* Without instance, all fields are disabled
      IF NOT gr_paysp IS BOUND.
        screen-active = 0.
        screen-input = 0.
      ENDIF.
    ENDIF.
    IF gr_paysp IS BOUND.
      CALL METHOD gr_paysp->get_fieldcheck_psp
        EXPORTING
          is_vbak           = vbak
          iv_trtyp          = t180-trtyp
          iv_fieldname      = lv_fieldname
        IMPORTING
          ev_no_input       = lv_psp_no_input
          ev_inactive       = lv_inactive
        EXCEPTIONS
          fieldname_unknown = 1
          OTHERS            = 2.

      IF sy-subrc EQ 0.
        IF lv_psp_no_input IS NOT INITIAL.
          screen-input = 0.
        ENDIF.
        IF lv_inactive IS NOT INITIAL.
          screen-active = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " FELDAUSWAHL_PAYSP1