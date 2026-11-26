*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_FV50XFWC                                *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SPE_IDOC_RET_ERP_ICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spe_idoc_ret_erp_ich.

  CONSTANTS:
*Communication of Returns Instructions
           lc_retins_msg_type   TYPE  edi_mestyp VALUE 'RETINS',
           lc_logsys_part_type  TYPE  edi_rcvprt VALUE 'LS',
           lc_retins_msg_code   TYPE edi_mescod  VALUE space,
           lc_spe_acc_app_sts_f  TYPE v50agl-spe_acc_app_sts_f value 'X',

*Communication of Cancellation of Returns ASN from ICH Dealer Portal
           lc_retcanc_msg_type  TYPE edi_mestyp  VALUE  'DELINF',
           lc_retcanc_msg_code  TYPE edi_mescod  VALUE  'CHR',
           lc_delv_idoc_type    TYPE edi_idoctp  VALUE 'DELVRY05',
           lc_skip_idoc         TYPE char1 VALUE 'X',
           lc_element           TYPE swc_elem VALUE 'OUTBOUND_OBJECT',
           lc_likp              TYPE swo_objtyp VALUE 'LIKP',
           lc_true              TYPE xfeld VALUE 'X'.
  DATA:
           lt_comm_idoc_control TYPE TABLE OF edidc,
           lt_edidc             TYPE edidc_tt,
           ls_edidc             TYPE edidc,
           lv_rc                TYPE sy-subrc,
           lt_xlips  TYPE STANDARD TABLE OF lipsvb,
           lt_xvbpa  TYPE STANDARD TABLE OF vbpavb,
           lt_xvbadr TYPE STANDARD TABLE OF sadrvb,
           lt_edidd  TYPE STANDARD TABLE OF edidd,
           lv_skip_idoc_constr TYPE char1,
           lt_bor_object TYPE  /spe/bor_object_links_t,
           ls_bor_object TYPE  /spe/bor_object_links.

  FIELD-SYMBOLS: <ls_xlips>  TYPE lipsvb,
                 <ls_xvbpa>  TYPE vbpavb,
                 <ls_xvbadr> TYPE sadrvb,
                 <fs_edidc>  TYPE edidc.

* PART I -> SEND RETURN INSTRUCTIONS  to ICH SYSTEM (once per return delivery)
* Relevant are all new returns deliveries for which accept approval is 'A' (expected)
* These are the original returns deliveries created from CRM
  LOOP AT xlikp WHERE spe_acc_app_sts EQ gc_spe_ret-acc_app_expected OR
                      spe_acc_app_sts EQ gc_spe_ret-acc_app_ich_err_expected. "V_N_1109714
    CHECK ( ( xlikp-updkz EQ updkz_new ) OR ( ( xlikp-updkz EQ updkz_update )
    AND ( v50agl-spe_acc_app_sts_f EQ lc_spe_acc_app_sts_f ) ) ).
    BREAK-POINT ID /spe/idoc_output_spe_delvry.

    REFRESH lt_edidd.
    REFRESH lt_xlips.

    LOOP AT xlips ASSIGNING <ls_xlips> WHERE vbeln EQ xlikp-vbeln
                                         AND updkz NE updkz_delete.

      IF <ls_xlips>-spe_auth_complet EQ gc_true.
        lv_skip_idoc_constr = lc_skip_idoc.
      ENDIF.
      APPEND <ls_xlips> TO lt_xlips.
    ENDLOOP.

*Do not send returns instruction if all items are marked for deletion
    IF lt_xlips IS INITIAL.
      CONTINUE.
    ENDIF.

    REFRESH lt_xvbpa.
    LOOP AT xvbpa ASSIGNING <ls_xvbpa> WHERE vbeln EQ xlikp-vbeln
                                         AND updkz NE updkz_delete.
      APPEND <ls_xvbpa> TO lt_xvbpa.
    ENDLOOP.

    REFRESH lt_xvbadr.
    LOOP AT lt_xvbpa ASSIGNING <ls_xvbpa>.
      READ TABLE xvbadr ASSIGNING <ls_xvbadr>
                        WITH KEY adrnr = <ls_xvbpa>-adrnr.
      CHECK sy-subrc EQ 0.
      READ TABLE lt_xvbadr WITH KEY adrnr = <ls_xvbpa>-adrnr
                           TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
      APPEND <ls_xvbadr> TO lt_xvbadr.
    ENDLOOP.

    ls_edidc-idoctp = lc_delv_idoc_type.

*Mapping to IDOC structures
    CALL FUNCTION 'IDOC_OUTPUT_SPE_DELVRY'
      EXPORTING
        s_likp                 = xlikp
        control_record_in      = ls_edidc
        t_lips                 = lt_xlips
        t_vbpa                 = lt_xvbpa
        t_vbadr                = lt_xvbadr
      TABLES
        int_edidd              = lt_edidd
      EXCEPTIONS
        error_message_received = 1
        OTHERS                 = 2.

    IF sy-subrc NE 0.
      cvbak-vbeln = xlikp-vbeln.
      PERFORM message_handling(sapmv50a) USING '000000'
                                               sy-msgno
                                               'I'
                                               sy-msgid
                                               sy-msgv1
                                               sy-msgv2
                                               sy-msgv3
                                               sy-msgv4.
      RETURN.
    ENDIF.

*   Get control record fields used for sending Return Instruction data to
*   ICH system
    IF NOT lt_edidd IS INITIAL.

      CLEAR lt_edidc.

      CALL FUNCTION '/SPE/RET_GET_IDOC_CTRL_RECORDS'
        EXPORTING
          iv_msg_type               = lc_retins_msg_type
          iv_idoc_type              = lc_delv_idoc_type
          iv_partner_type           = lc_logsys_part_type
          iv_msg_code               = lc_retins_msg_code
        CHANGING
          ct_edidc                  = lt_edidc
        EXCEPTIONS
          own_system_error          = 1
          ale_model_not_defined     = 2
          msg_idoc_assignment_fails = 3
          OTHERS                    = 4.
      IF sy-subrc NE 0.
*Write log, but save IDOC anyway
        cvbak-vbeln = xlikp-vbeln.
        PERFORM message_handling(sapmv50a) USING '000000'
                                                 sy-msgno
                                                 'I'
                                                 sy-msgid
                                                 sy-msgv1
                                                 sy-msgv2
                                                 sy-msgv3
                                                 sy-msgv4.
      ENDIF.

      REFRESH lt_bor_object.
*     Call Wrapper Function Module which calls MASTER_IDOC_DISTRIBUTE for
*     Idoc dispatching to all recipient systems(normally it must be one(XI))
      LOOP AT lt_edidc ASSIGNING <fs_edidc>.
        ls_bor_object-logsys = <fs_edidc>-sndprn.
        ls_bor_object-objtype = lc_likp.
        ls_bor_object-objkey  = xlikp-vbeln.
        ls_bor_object-element  = lc_element.
        APPEND ls_bor_object TO lt_bor_object.

        CALL FUNCTION '/SPE/RET_DIST_DELVRY_IDOC'
          EXPORTING
            ip_master_idoc_control         = <fs_edidc>
            ip_synchron                    = lc_true
            it_master_idoc_data            = lt_edidd
            it_bor_object                  = lt_bor_object
          CHANGING
            ct_communication_idoc_control  = lt_comm_idoc_control
          EXCEPTIONS
            error_in_idoc_control          = 1
            error_writing_idoc_status      = 2
            error_in_idoc_data             = 3
            sending_logical_system_unknown = 4
            OTHERS                         = 5.
        IF sy-subrc <> 0.
          cvbak-vbeln = xlikp-vbeln.
          PERFORM message_handling(sapmv50a) USING '000000'
                                                   sy-msgno
                                                   'I'
                                                   sy-msgid
                                                   sy-msgv1
                                                   sy-msgv2
                                                   sy-msgv3
                                                   sy-msgv4.
          RETURN.
        ENDIF.
      ENDLOOP. "loop at lt_edidc
    ENDIF. "if not lt_edidd is initial
*  ENDIF. " IF xlikp-updkz EQ updkz_new OR ( xlikp-updkz EQ updkz_update AND v50agl-spe_acc_app_sts_f EQ lc_spe_acc_app_sts_f).
  ENDLOOP. " loop at xlikp where ...

* PART II -> SEND CANCELLED ASN(s) to ICH SYSTEM
  CLEAR : lt_edidd,
          lt_xlips,
          lt_xvbpa,
          lt_xvbadr.

*only RASNS, which have to be cancelled
  LOOP AT xlikp WHERE  updkz EQ updkz_update
                 AND   spe_ret_canc EQ gc_true
                 AND   spe_acc_app_sts EQ gc_spe_ret-acc_app_received.

    BREAK-POINT ID /spe/idoc_output_spe_delvry.

    REFRESH lt_edidd.
    REFRESH lt_xlips.

    LOOP AT xlips ASSIGNING <ls_xlips> WHERE vbeln EQ xlikp-vbeln
                                         AND updkz NE updkz_delete.
      APPEND <ls_xlips> TO lt_xlips.
    ENDLOOP.

*Do not send cancellation if all items are marked for deletion
    IF lt_xlips IS INITIAL.
      CONTINUE.
    ENDIF.

    REFRESH lt_xvbpa.
    LOOP AT xvbpa ASSIGNING <ls_xvbpa> WHERE vbeln EQ xlikp-vbeln
                                         AND updkz NE updkz_delete.
      APPEND <ls_xvbpa> TO lt_xvbpa.
    ENDLOOP.

    REFRESH lt_xvbadr.
    LOOP AT lt_xvbpa ASSIGNING <ls_xvbpa>.
      READ TABLE xvbadr ASSIGNING <ls_xvbadr>
                        WITH KEY adrnr = <ls_xvbpa>-adrnr.
      CHECK sy-subrc EQ 0.
      READ TABLE lt_xvbadr WITH KEY adrnr = <ls_xvbpa>-adrnr
                           TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
      APPEND <ls_xvbadr> TO lt_xvbadr.
    ENDLOOP.

    ls_edidc-idoctp = lc_delv_idoc_type.

    CALL FUNCTION 'IDOC_OUTPUT_SPE_DELVRY'
      EXPORTING
        s_likp                 = xlikp
        control_record_in      = ls_edidc
        t_lips                 = lt_xlips
        t_vbpa                 = lt_xvbpa
        t_vbadr                = lt_xvbadr
      TABLES
        int_edidd              = lt_edidd
      EXCEPTIONS
        error_message_received = 1
        OTHERS                 = 2.

    IF sy-subrc NE 0.
      cvbak-vbeln = xlikp-vbeln.
      PERFORM message_handling(sapmv50a) USING '000000'
                                               sy-msgno
                                               'I'
                                               sy-msgid
                                               sy-msgv1
                                               sy-msgv2
                                               sy-msgv3
                                               sy-msgv4.
    ENDIF.

*   Get control record fields used for sending Return Instruction data to
*   ICH system
    IF NOT lt_edidd IS INITIAL.

      CLEAR lt_edidc.

      CALL FUNCTION '/SPE/RET_GET_IDOC_CTRL_RECORDS'
        EXPORTING
          iv_msg_type               = lc_retcanc_msg_type
          iv_idoc_type              = lc_delv_idoc_type
          iv_partner_type           = lc_logsys_part_type
          iv_msg_code               = lc_retcanc_msg_code
        CHANGING
          ct_edidc                  = lt_edidc
        EXCEPTIONS
          own_system_error          = 1
          ale_model_not_defined     = 2
          msg_idoc_assignment_fails = 3
          OTHERS                    = 4.
      IF sy-subrc NE 0.
*Write log, but save IDOC anyway
        cvbak-vbeln = xlikp-vbeln.
        PERFORM message_handling(sapmv50a) USING '000000'
                                                 sy-msgno
                                                 'I'
                                                 sy-msgid
                                                 sy-msgv1
                                                 sy-msgv2
                                                 sy-msgv3
                                                 sy-msgv4.
      ENDIF.

      REFRESH lt_bor_object.
*    Call Wrapper Function Module which calls MASTER_IDOC_DISTRIBUTE for
*    Idoc dispatching to all recipient systems(normally it must be one(XI))
      LOOP AT lt_edidc ASSIGNING <fs_edidc>.

        ls_bor_object-logsys = <fs_edidc>-sndprn.
        ls_bor_object-objtype = lc_likp.
        ls_bor_object-objkey  = xlikp-vbeln.
        ls_bor_object-element  = lc_element.
        APPEND ls_bor_object TO lt_bor_object.

        CALL FUNCTION '/SPE/RET_DIST_DELVRY_IDOC'
          EXPORTING
            ip_master_idoc_control         = <fs_edidc>
            ip_synchron                    = lc_true
            it_master_idoc_data            = lt_edidd
            it_bor_object                  = lt_bor_object
          CHANGING
            ct_communication_idoc_control  = lt_comm_idoc_control
          EXCEPTIONS
            error_in_idoc_control          = 1
            error_writing_idoc_status      = 2
            error_in_idoc_data             = 3
            sending_logical_system_unknown = 4
            OTHERS                         = 5.
        IF sy-subrc NE 0.
          cvbak-vbeln = xlikp-vbeln.
          PERFORM message_handling(sapmv50a) USING '000000'
                                                   sy-msgno
                                                   'I'
                                                   sy-msgid
                                                   sy-msgv1
                                                   sy-msgv2
                                                   sy-msgv3
                                                   sy-msgv4.
          RETURN.
        ENDIF.
      ENDLOOP. "loop at lt_edidc
    ENDIF. "if not lt_edidd is initial
  ENDLOOP. "loop at xlikp
ENDFORM.                    " SPE_IDOC_RET_ERP_ICH