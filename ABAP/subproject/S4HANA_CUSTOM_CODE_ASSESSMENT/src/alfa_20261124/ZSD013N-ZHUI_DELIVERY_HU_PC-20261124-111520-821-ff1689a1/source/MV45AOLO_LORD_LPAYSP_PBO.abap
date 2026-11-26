*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_LPAYSP_PBO
*&---------------------------------------------------------------------*

FORM lord_lpaysp_pbo.

  DATA: ls_paysp_hl TYPE paysp_hl,
        ls_lpaysp_arch TYPE tds_paysp_hl.

  DATA: lt_lpaysp_arch TYPE tdt_paysp_hl.


  CLEAR:
    gs_lpaysp_data-ps_provider      ,
    gs_lpaysp_data-transaction_id_r ,
    gs_lpaysp_data-reference_id_r   ,
    gs_lpaysp_data-psp_txn_id_r     ,
    gs_lpaysp_data-txn_profile_r    ,
    gs_lpaysp_data-txn_status_r     ,
    gs_lpaysp_data-amount_req_r     ,
    gs_lpaysp_data-currency_req_r   .

  CHECK: vbak-sppaym EQ cv_sppaym01.

  IF data_read_from_archive IS INITIAL.
    IF NOT gr_paysp IS BOUND.
      gr_paysp = cl_sls_paysp_integration=>get_instance( ).
    ENDIF.
    IF gr_paysp IS BOUND.
*   get_data_single
      CALL METHOD gr_paysp->get_data_single
        EXPORTING
          iv_document_id = vbak-vbeln
        IMPORTING
          es_paysp_hl    = ls_paysp_hl
        EXCEPTIONS
          no_data        = 1
          invalid_data   = 2
          OTHERS         = 3.

*   do mapping
      IF sy-subrc        IS INITIAL AND
         NOT ls_paysp_hl IS INITIAL.
        gs_lpaysp_data-ps_provider      = ls_paysp_hl-ps_provider.
        gs_lpaysp_data-transaction_id_r = ls_paysp_hl-transaction_id.
        gs_lpaysp_data-reference_id_r   = ls_paysp_hl-reference_id.
        gs_lpaysp_data-psp_txn_id_r     = ls_paysp_hl-psp_txn_id.
        gs_lpaysp_data-txn_profile_r    = ls_paysp_hl-txn_profile.
        gs_lpaysp_data-txn_status_r     = ls_paysp_hl-txn_status.
        gs_lpaysp_data-amount_req_r     = ls_paysp_hl-amount_req.
        gs_lpaysp_data-currency_req_r   = ls_paysp_hl-currency_req.
      ENDIF.
    ENDIF.
  ELSE.
* read data from archive
    CALL METHOD gr_paysp->get_arch_data
      EXPORTING
        iv_document_id = vbak-vbeln
      IMPORTING
        et_lpaysp_arch = lt_lpaysp_arch.
* one table entry is expected
    READ TABLE lt_lpaysp_arch INDEX 1 INTO ls_lpaysp_arch.
    gs_lpaysp_data-ps_provider      = ls_lpaysp_arch-ps_provider.
    gs_lpaysp_data-transaction_id_r = ls_lpaysp_arch-transaction_id.
    gs_lpaysp_data-reference_id_r   = ls_lpaysp_arch-reference_id.
    gs_lpaysp_data-psp_txn_id_r     = ls_lpaysp_arch-psp_txn_id.
    gs_lpaysp_data-txn_profile_r    = ls_lpaysp_arch-txn_profile.
    gs_lpaysp_data-txn_status_r     = ls_lpaysp_arch-txn_status.
    gs_lpaysp_data-amount_req_r     = ls_lpaysp_arch-amount_req.
    gs_lpaysp_data-currency_req_r   = ls_lpaysp_arch-currency_req.
  ENDIF.

ENDFORM.                    "lord_lpaysp_pbo


*&---------------------------------------------------------------------*
*&      Form  lord_lpaysp_pbo_ro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lord_lpaysp_pbo_ro.

  CLEAR:
    gs_lpaysp_descr-ps_provider_t,
    gs_lpaysp_descr-txn_profile_t,
    gs_lpaysp_descr-txn_status_t.

  CHECK: vbak-sppaym EQ cv_sppaym01.

  IF NOT gr_paysp IS BOUND.
    gr_paysp = cl_sls_paysp_integration=>get_instance( ).
  ENDIF.
  IF gr_paysp IS BOUND.
* ps_provider_t
    IF NOT gs_lpaysp_data-ps_provider IS INITIAL.
      CALL METHOD cl_sls_paysp_integration=>get_provider_descr
        EXPORTING
          iv_provider    = gs_lpaysp_data-ps_provider
        IMPORTING
          ev_description = gs_lpaysp_descr-ps_provider_t.
    ENDIF.

* txn_profile_t
    IF NOT gs_lpaysp_data-txn_profile_r IS INITIAL.
      CALL METHOD cl_sls_paysp_integration=>get_profile_descr
        EXPORTING
          iv_status_profile = gs_lpaysp_data-txn_profile_r
        IMPORTING
          ev_status_pf_desc = gs_lpaysp_descr-txn_profile_t.
    ENDIF.

* txn_status_t
    IF NOT gs_lpaysp_data-txn_status_r IS INITIAL.
      CALL METHOD cl_sls_paysp_integration=>get_status_descr
        EXPORTING
          iv_status_profile = gs_lpaysp_data-txn_profile_r
          iv_status         = gs_lpaysp_data-txn_status_r
        IMPORTING
          ev_status_desc    = gs_lpaysp_descr-txn_status_t.
    ENDIF.
  ENDIF.

ENDFORM.                    "lord_lpaysp_pbo_ro

*&---------------------------------------------------------------------*
*&      Form  LORD_LPAYSP_CHECK_AVAILABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UF_AVAILABLE  text
*----------------------------------------------------------------------*
FORM lord_lpaysp_check_available  USING    uf_available.

  CLEAR uf_available.

  IF vbak-sppaym EQ cv_sppaym01.
    uf_available = charx.
  ENDIF.

ENDFORM.                    " LORD_LPAYSP_CHECK_AVAILABLE

*&---------------------------------------------------------------------*
*&      Form  SPPAYM_T_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UP_SPPAYM    Special Payment Method (Value)
*      -->UP_SPPAYM_T  Special Payment Method (Description)
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM sppaym_t_select  USING    up_sppaym
                               up_sppaym_t.

  CLEAR gs_lpaysp_descr-sppaym_t.
  IF NOT up_sppaym IS INITIAL.
    CALL METHOD cl_sls_paysp_integration=>get_sppaym_descr
      EXPORTING
        iv_sppaym      = up_sppaym
      IMPORTING
        ev_description = up_sppaym_t.
  ENDIF.

ENDFORM.                    " SPPAYM_T_SELECT

*&---------------------------------------------------------------------*
*&      Form  PAYSP_CHECK_FCODE_ACTIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UP_FCODE        text
*      -->UP_FCODE_PARAM  text
*      -->CF_ACTIVE       text
*      -->ENDFORM         text
*----------------------------------------------------------------------*
FORM paysp_check_fcode_active USING up_fcode
                                    up_fcode_param
                              CHANGING
                                    cp_not_active.

  CHECK: vbak-sppaym EQ cv_sppaym01.

  IF NOT gr_paysp IS BOUND.
    gr_paysp = cl_sls_paysp_integration=>get_instance( ).
  ENDIF.
  IF gr_paysp IS BOUND.
*   do fcode check
    CALL METHOD gr_paysp->get_fieldcheck_fcode
      EXPORTING
        iv_fcode       = up_fcode
        iv_fcode_param = up_fcode_param
        iv_trtyp       = t180-trtyp
        is_vbak        = vbak
        is_tvak        = tvak
        is_vbuk        = vbuk
      IMPORTING
        ev_not_allowed = cp_not_active
      EXCEPTIONS
        internal_error = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      cp_not_active = abap_true.
    ENDIF.
  ENDIF.

ENDFORM.                    "paysp_check_fcode_active