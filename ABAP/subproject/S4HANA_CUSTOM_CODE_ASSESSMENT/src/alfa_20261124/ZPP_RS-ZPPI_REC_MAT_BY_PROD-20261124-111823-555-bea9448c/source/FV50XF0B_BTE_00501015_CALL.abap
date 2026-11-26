***INCLUDE FV50XF0B_BTE_00501015_CALL .
*---------------------------------------------------------------------*
*       FORM FV50XF0B_BTE_00501015_CALL                               *
*---------------------------------------------------------------------*
*       Call of BTE 00501015
*---------------------------------------------------------------------*
form bte_00501015_call tables it_hu_header type hum_hu_header_t
                              it_hu_item   type hum_hu_item_t.

  data: fmtab  like fmrfc   occurs 0 with header line,
        xtvpod like tvpodvb occurs 0 with header line,
        xeikp  like eikp    occurs 0 with header line,
        p_true type char1.

* Billing of Replenishment Deliveries
* Local table for conditions
  data: lt_tkomv type standard table of komv with header line.

  check v50agl-no_crm_order_update eq space.


  call function 'BF_FUNCTIONS_FIND'
    exporting
      i_event       = '00501015'
    tables
      t_fmrfc       = fmtab
    exceptions
      nothing_found = 4
      others        = 8.
  check sy-subrc = 0.

  loop at xvbuk where vbtyp ca vbtyp_delv
                  and not pdstk is initial.
    exit.
  endloop.
  if sy-subrc eq 0.
    call function 'LE_POD_TVPOD_READ'
      tables
        it_lips  = xlips
        et_tvpod = xtvpod.
  endif.


  if xlikp-exnum is not initial.
    call function '/SPE/EXPIMP_SET_XEIKP'
      tables
        t_eikp = xeikp.
  endif.

  if xlikp-vbtyp ca vbtyp_mmli.

    loop at xlips transporting no fields
                  where fkrel ca gc_fkrel_crm_billing.
      p_true = gc_true.
    endloop.
    if p_true eq gc_true.
*     Billing of Inbound Deliveries
*     Read and add conditions from PO
      lt_tkomv[] = tkomv[].
      call function '/SPE/INBOUND_CONDITIONS_ADD'
        exporting
          it_likp = xlikp[]
          it_lips = xlips[]
          it_konv = tkomv[]
        importing
          et_konv = lt_tkomv[].
    endif.

  else.
*call for outbound deliveries
*Billing of Replenishment Deliveries
* Read and add conditions from PO
    lt_tkomv[] = tkomv[].
    call function '/SPE/STO_CONDITIONS_ADD'
      exporting
        it_likp = xlikp[]
        it_lips = xlips[]
        it_konv = tkomv[]
      importing
        et_konv = lt_tkomv[].

  endif.

  if v50agl-synchron eq charx .
    call function 'OUTBOUND_CALL_00501015_E'
      tables
        fmtab         = fmtab
        xlikp         = xlikp
        ylikp         = ylikp
        xlips         = xlips
        ylips         = ylips
        xvbuk         = xvbuk
        yvbuk         = yvbuk
        xvbup         = xvbup
        yvbup         = yvbup
        xvbpa         = xvbpa
        yvbpa         = yvbpa
        xvbfa         = xvbfa
        yvbfa         = yvbfa
        hu_header     = it_hu_header
        hu_dlvry_item = it_hu_item
        tkomv         = lt_tkomv
        xtvpod        = xtvpod
        xeikp         = xeikp.
  else.
    call function 'OUTBOUND_CALL_00501015_E' in update task
      tables
        fmtab         = fmtab
        xlikp         = xlikp
        ylikp         = ylikp
        xlips         = xlips
        ylips         = ylips
        xvbuk         = xvbuk
        yvbuk         = yvbuk
        xvbup         = xvbup
        yvbup         = yvbup
        xvbpa         = xvbpa
        yvbpa         = yvbpa
        xvbfa         = xvbfa
        yvbfa         = yvbfa
        hu_header     = it_hu_header
        hu_dlvry_item = it_hu_item
        tkomv         = lt_tkomv
        xtvpod        = xtvpod.
  endif.

endform.                    "bte_00501015_call