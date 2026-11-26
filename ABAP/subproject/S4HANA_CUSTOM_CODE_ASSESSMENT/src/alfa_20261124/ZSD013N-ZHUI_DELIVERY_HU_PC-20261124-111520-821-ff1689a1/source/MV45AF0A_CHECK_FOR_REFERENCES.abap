
*&---------------------------------------------------------------------*
*&  Include           MV45AF0A_CHECK_FOR_REFERENCES
*&---------------------------------------------------------------------*

form check_for_references.

  data: ls_vbeln_posnr type tds_vbeln_posnr,
        lt_vbeln_posnr type tdt_vbeln_posnr,
        lt_posnr type standard table of posnr.
  data: lr_badi_ref type ref to badi_sd_sales_check_ref,
        lr_badi_ref_int type ref to badi_sd_sales_check_ref_int.
  data: lf_no_dialog type flag.
  data: lv_vbeln type vbeln_va,
        lv_posnr type posnr_va.


* verify conditions
  check kopieren eq space and
        svbak-tabix eq 0.

* determine dialog mode
  clear lf_no_dialog.
  if call_bapi eq charx or
     call_function eq charx or
     call_activity eq gc_activity_lord.
    lf_no_dialog = charx.
  else.
    call function 'DIALOG_GET_STATUS'
      importing
        dialog_status = lf_no_dialog.
  endif.

* call internal BAdI
  refresh: lt_vbeln_posnr.
  try.
      get badi lr_badi_ref_int.
      if lr_badi_ref_int is bound.
        call badi lr_badi_ref_int->get_refdocs
          exporting
            is_vbak        = vbak
            is_vbkd        = vbkd
            is_tvak        = tvak
            if_no_dialog   = lf_no_dialog
          changing
            ct_vbeln_posnr = lt_vbeln_posnr.
      endif.
    catch cx_badi.
  endtry.

  if not lt_vbeln_posnr is initial.
    sort lt_vbeln_posnr by vbeln posnr.
    clear lv_vbeln.
    refresh lt_posnr.
    loop at lt_vbeln_posnr into ls_vbeln_posnr.
      if ls_vbeln_posnr-vbeln is initial.
        delete lt_vbeln_posnr.
        continue.
      endif.
      if lv_vbeln ne ls_vbeln_posnr-vbeln.
        if not lv_vbeln is initial.
          perform execute_copy using lv_vbeln lt_posnr.
        endif.
        lv_vbeln = ls_vbeln_posnr-vbeln.
        refresh lt_posnr.
      endif.
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = ls_vbeln_posnr-posnr
        importing
          output = lv_posnr.
      append lv_posnr to lt_posnr.
    endloop.
    if not lv_vbeln is initial.
      perform execute_copy using lv_vbeln lt_posnr.
    endif.
  endif.

* call external BAdI
  refresh: lt_vbeln_posnr.
  try.
      get badi lr_badi_ref.
      if lr_badi_ref is bound.
        call badi lr_badi_ref->get_refdocs
          exporting
            is_vbak        = vbak
            is_vbkd        = vbkd
            is_tvak        = tvak
            if_no_dialog   = lf_no_dialog
          changing
            ct_vbeln_posnr = lt_vbeln_posnr.
      endif.
    catch cx_badi.
  endtry.

  if not lt_vbeln_posnr is initial.
    sort lt_vbeln_posnr by vbeln posnr.
    clear lv_vbeln.
    refresh lt_posnr.
    loop at lt_vbeln_posnr into ls_vbeln_posnr.
      if ls_vbeln_posnr-vbeln is initial.
        delete lt_vbeln_posnr.
        continue.
      endif.
      if lv_vbeln ne ls_vbeln_posnr-vbeln.
        if not lv_vbeln is initial.
          perform execute_copy using lv_vbeln lt_posnr.
        endif.
        lv_vbeln = ls_vbeln_posnr-vbeln.
        refresh lt_posnr.
      endif.
      call function 'CONVERSION_EXIT_ALPHA_INPUT'
        exporting
          input  = ls_vbeln_posnr-posnr
        importing
          output = lv_posnr.
      append lv_posnr to lt_posnr.
    endloop.
    if not lv_vbeln is initial.
      perform execute_copy using lv_vbeln lt_posnr.
    endif.
  endif.

endform.                    " CHECK_FOR_REFERENCES



*&---------------------------------------------------------------------*
*&      Form  execute_copy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_VBELN_REF  text
*      -->UT_POSNR_REF  text
*----------------------------------------------------------------------*
form execute_copy using uv_vbeln_ref type vbeln
                        ut_posnr_ref type tdt_posnr.

  data: lf_no_items type flag.
  data: lv_vbeln_ref type vbeln,
        lt_posnr_ref type tdt_posnr,
        lv_posnr_ref type posnr.


  lv_vbeln_ref = uv_vbeln_ref.
  lt_posnr_ref = ut_posnr_ref.

  if lines( lt_posnr_ref ) eq 1.
    read table lt_posnr_ref
         transporting no fields
         with key table_line = '000000'.
    if sy-subrc is initial.
      lf_no_items = 'X'.
      refresh lt_posnr_ref.
    endif.
  endif.

  perform beleg_kopieren_vorbereiten(sapfv45c) using vbak-auart.

  refresh cvbfa.
  append lines of xvbfa to cvbfa.

  refresh cvbup.
  append lines of xvbup to cvbup.

  call function 'RV_DOCUMENT_COPY_NO_POPUP'
    exporting
      fvak          = tvak
      fvbak         = vbak
      fvbpa         = vbpa
      i_vbeln       = lv_vbeln_ref
      i_no_items    = lf_no_items
      iv_kunnr      = kuagv-kunnr
    importing
      fvbak         = cvbak
      fvbuk         = cvbuk
      fvcpa         = tvcpa
      fvbrk         = cvbrk
    tables
      fxvbap        = cvbap
      fxvbep        = cvbep
      fxvbfa        = cvbfa
      fxvbkd        = cvbkd
      fxvbpa        = cvbpa
      fxvbuk        = xvbuk
      fxvbup        = cvbup
      fxvbuv        = xvbuv
      fxfpla        = cfpla
      fxfplt        = cfplt
      fxvbsn        = cvbsn
      fxvbrp        = cvbrp
    exceptions
      error_message = 1.

  if sy-subrc <> 0.
    message id sy-msgid type 'W' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    message_collect_lord.
    perform beleg_entsperren using lv_vbeln_ref.
    return.
  endif.

  if not lf_no_items is initial.
    refresh: cvbap[],
             cvbrp[].
  endif.

* sales document
  if not cvbap[] is initial.
    if not lt_posnr_ref[] is initial.
      sort lt_posnr_ref.
      loop at cvbap.
        read table lt_posnr_ref
             into lv_posnr_ref
             from cvbap-posnr.
        if sy-subrc <> 0.
          cvbap-updkz = 'D'.
          modify cvbap.
        endif.
      endloop.
    endif.
  endif.

* billing document
  if not cvbrp[] is initial.
    if not lt_posnr_ref[] is initial.
      sort lt_posnr_ref.
      loop at cvbrp.
        read table lt_posnr_ref
             into lv_posnr_ref
             from cvbrp-posnr.
        if sy-subrc <> 0.
          cvbrp-updkz = 'D'.
          modify cvbrp.
        endif.
      endloop.
    endif.
  endif.

* copy
  gesperrt = charx.
  perform vorlage_kopieren(sapfv45c).

endform.                    "execute_copy



*&---------------------------------------------------------------------*
*&      Form  check_item_copy_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->US_TVCPA   text
*      -->US_XVBAP   text
*      -->US_XVBUP   text
*      -->UV_SUBRC   text
*----------------------------------------------------------------------*
form check_item_copy_single using us_tvcpa type tvcpa
                                  us_xvbap type vbapvb
                                  us_xvbup type vbupvb
                                  uv_subrc type sy-subrc.

  local: tvcpa.

  data: ls_vbap type vbap,
        ls_vbup type vbup,
        ls_vbrp type vbrp.

  uv_subrc = 0.

  tvcpa = us_tvcpa.
  check: tvcpa-auarn ne space.
  perform tvcpa_select(sapmv45a) using tvcpa-auarn
                                       tvcpa-auarv
                                       space
                                       us_xvbap-pstyv
                                       space
                                       space
                                       sy-subrc.
  check sy-subrc = 0.

  if tvcpa-grbed > 0.
    ls_vbap = us_xvbap.
    ls_vbup = us_xvbup.
    call function 'RV_DOCUMENT_COPY_ITEM_CHECK'
      exporting
        fvcpa          = tvcpa
        fvbap          = ls_vbap
        fvbrp          = ls_vbrp
        fvbup          = ls_vbup
      exceptions
        nicht_kopieren = 1.
    if sy-subrc ne 0.
      uv_subrc = 2.
    endif.
  endif.

endform.                    "check_item_copy_single