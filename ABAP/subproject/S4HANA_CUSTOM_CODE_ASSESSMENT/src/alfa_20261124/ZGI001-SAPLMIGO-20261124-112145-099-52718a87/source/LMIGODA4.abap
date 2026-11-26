*&---------------------------------------------------------------------*
*&  Include           LMIGODA4
*   Detail tabstrip MAA-DEV
*&---------------------------------------------------------------------*
CLASS lcl_migo_detail_maa IMPLEMENTATION.

************************************************************************
* PBO: determine the maa subscreen and send data.
************************************************************************
  METHOD pbo.
    CALL METHOD super->pbo.
    CALL METHOD maa_send.
  ENDMETHOD.                    "pbo
************************************************************************
* PAI
************************************************************************
  METHOD pai.


  ENDMETHOD.                    "pai
************************************************************************
* RESET_ACC
************************************************************************
  METHOD reset_acc.

    CLEAR: pt_accounting.

  ENDMETHOD.                    "reset_acc
************************************************************************
* MAA_SEND: send data to FUGR MBAA
************************************************************************
  METHOD maa_send.

    DATA: lf_dis_val    TYPE abap_bool.

    DATA: ls_accounting TYPE accounting,
          ls_poitem     TYPE ebefu.

    DATA: lt_accounting TYPE accounting_t,
          lt_poitem     TYPE ebefu_t,
          lt_fields     TYPE ty_t_fieldname.

*-- Accounting data
    LOOP AT pt_poitem INTO ls_poitem
           WHERE ebeln = goitem-ebeln
             AND ebelp = goitem-ebelp
             AND lfbja = goitem-lfbja
             AND lfbnr = goitem-lfbnr
             AND lfpos = goitem-lfpos.
      APPEND ls_poitem TO lt_poitem.
    ENDLOOP.

    LOOP AT pt_accounting INTO ls_accounting
           WHERE ebeln = goitem-ebeln
             AND ebelp = goitem-ebelp
             AND lfbja = goitem-lfbja
             AND lfbnr = goitem-lfbnr
             AND lfpos = goitem-lfpos.
      APPEND ls_accounting TO lt_accounting.
    ENDLOOP.

*-- Fields
    lt_fields = cl_mmim_migo_move_fields=>t_gocobl1_fields.

*-- Check if value will be displayed
    IF lcl_migo_globals=>kernel->s_control-action = 'A04' AND
        lcl_migo_globals=>kernel->s_control-refdoc = 'R02'.
      lf_dis_val = abap_true.
    ELSE.
      CLEAR: lf_dis_val.
    ENDIF.

*-- Send
    CALL FUNCTION 'MB_MAA_VALUE_SET'
      EXPORTING
        iaccounting = lt_accounting
        igoitem     = goitem
        iebefu      = lt_poitem
        idispval    = lf_dis_val
        igoaction   = lcl_migo_globals=>kernel->s_control-action "note 1409605
      IMPORTING
        xdynnr      = g_maa_subscreen
        xprogn      = g_maa_progn.

  ENDMETHOD.                    "MAA_SEND
************************************************************************
* maa_disp_acc: Set '*' als ACC to item
************************************************************************
  METHOD maa_disp_acc.

    DATA: lt_all_cust_fields  TYPE ty_t_fieldname,
          lt_base_cust_fields TYPE ty_t_fieldname,
          lt_gocobl1_no_ci    TYPE ty_t_fieldname.

    DATA: lf_fieldname    TYPE migo_fieldname,
          lf_kontfeld     TYPE migo_fieldname.

    FIELD-SYMBOLS: <f> TYPE any.

    CHECK NOT cs_goitem-mulko IS INITIAL.
    CHECK NOT cl_ops_switch_check=>mm_sfws_maa( ) IS INITIAL.  "MAA switch

    lt_all_cust_fields  = cl_mmim_migo_move_fields=>t_all_cust_fields.
    lt_base_cust_fields = cl_mmim_migo_move_fields=>t_base_cust_fields.
    lt_gocobl1_no_ci    = cl_mmim_migo_move_fields=>t_gocobl1_no_ci.

*-- Add SAKTO
    lf_fieldname = 'KONTO'.
    APPEND lf_fieldname TO lt_gocobl1_no_ci.

*-- Add ABLAD                                         "MAA2
    lf_fieldname = 'ABLAD'.                           "MAA2
    APPEND lf_fieldname TO lt_gocobl1_no_ci.          "MAA2
*-- Add WEMPF                                         "MAA2
    lf_fieldname = 'WEMPF'.                           "MAA2
    APPEND lf_fieldname TO lt_gocobl1_no_ci.          "MAA2

    LOOP AT lt_gocobl1_no_ci INTO lf_fieldname.
      CONCATENATE 'CS_GOITEM-' lf_fieldname INTO lf_kontfeld.
      ASSIGN (lf_kontfeld) TO <f>.
      CHECK sy-subrc = 0.

      IF NOT <f> IS INITIAL.
        <f> = '*'.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.                   "maa_disp_acc

************************************************************************
* PO_DATA_GET
************************************************************************
  METHOD po_data_get.

    DATA: ls_accounting TYPE accounting,
          ls_acctb      TYPE accounting,
          ls_poitem     TYPE ebefu.

*-- Accounting data
    READ TABLE pt_accounting INTO ls_accounting
                  WITH KEY ebeln = i_ebeln
                           ebelp = i_ebelp.
    IF sy-subrc = 0.
    ENDIF.

    LOOP AT i_acctb INTO ls_acctb.
      READ TABLE pt_accounting INTO ls_accounting
              WITH KEY ebeln = ls_acctb-ebeln
                       ebelp = ls_acctb-ebelp
                       zekkn = ls_acctb-zekkn
                       lfbja = ls_acctb-lfbja
                       lfbnr = ls_acctb-lfbnr
                       lfpos = ls_acctb-lfpos.
      CHECK sy-subrc NE 0.

      " Funded Program. The account structure does not
      " contain the Funded Program value, so read from FMIOI
      IF ls_acctb-measure IS INITIAL.
        DATA: lv_rfknt TYPE FMIOI-RFKNT.
        lv_rfknt = ls_acctb-zekkn.
        ls_acctb-measure = CL_FM_FUNDED_PROG_UTIL_APPL=>GET_MEASURE_FROM_PO(
                                                                             IV_REFBN = ls_acctb-ebeln
                                                                             IV_RFPOS = ls_acctb-ebelp
                                                                             IV_RFKNT = lv_rfknt
                                                                           ).
      ENDIF.

      APPEND ls_acctb TO pt_accounting.
    ENDLOOP.

*-- PO data
    READ TABLE pt_poitem INTO ls_poitem
                  WITH KEY ebeln = i_ebeln
                           ebelp = i_ebelp
                           lfbja = i_lfbja
                           lfbnr = i_lfbnr
                           lfpos = i_lfpos.
    IF sy-subrc = 0.
    ELSE.
      APPEND LINES OF i_poitem TO pt_poitem.
    ENDIF.

  ENDMETHOD.                    "PO_DATA_GET

  METHOD get_xaccounting.                                   "MAA2
* pt_accounting                                             "MAA2
    BREAK-POINT id mb_maa.
  ENDMETHOD.                " get_xaccounting               "MAA2

ENDCLASS.                    "lcl_migo_detail_maa IMPLEMENTATION