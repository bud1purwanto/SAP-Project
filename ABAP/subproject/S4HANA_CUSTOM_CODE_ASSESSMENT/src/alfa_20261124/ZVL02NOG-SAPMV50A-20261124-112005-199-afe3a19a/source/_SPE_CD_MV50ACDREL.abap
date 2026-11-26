*&---------------------------------------------------------------------*
*&  Include           /SPE/CD_MV50ACDREL
*&---------------------------------------------------------------------*
* Check CD relevance from global data data XLIKP and XVBPA :
* Cross docking for outboud deliveries is relevant in the following
* cases:
*
* (1) Outbound delivery from Source Warehouse to CD warehouse
*     XLIKP-UPDKZ = 'U'
*     XLIKP-SPE_INITIASTOR_PROCESS = SPACE
*     XVBPA-PARVW  = 'EC'    Receiving Warehouse
*
* (2) Outbound delivery from intermediate Warehouse
*     XLIKP-UPDKZ = 'U'
*     XLIKP-SPE_INITIASTOR_PROCESS = 'TCD'
*     XVBPA-PARVW  = 'EC'    Receiving Warehouse
*
* The lv_cdrel flag will hand over the following values to the caller :
*     'S' = Outbound deivery from Source Warehouse to the next
*           Cross Docking Warehouse
*     'I' = intermediate Outbound delivery from Cross Docking
*           Ware house to the next Cross Docking Ware House
*----------------------------------------------------------------------*
form cd_relevance_check  using  lv_vbeln    type vbeln_vl
                                lv_cdrel    type c
                                lv_noitem   type c.

  data : ls_likp       type likpvb.
  field-symbols: <fs_xlips>   type lipsvb.

  clear lv_cdrel.
  clear lv_noitem.

* Determine whether at least on item has a quantity > 0.
  loop at xlips assigning <fs_xlips>
                where lgmng > 0 or
                      lfimg > 0.
    exit.
  endloop.
  if sy-subrc ne 0.
* No item with a deliver quantity !
* -> Delivery was completely split -> no subsequent inbound delivery for this one
    lv_noitem = 'X'.
  endif.

* Cross Docking receiving partner found
  read table xvbpa transporting no fields
             with key vbeln = lv_vbeln
                      posnr = posnr_low
                      parvw = gc_parvw-crssdockto
             binary search.

* Now check Initiator_process value
  if sy-subrc is initial.
*   Note 1168180 - In dialog (VL02N) only the header area of   "v_n_1168180
*                  XLIKP is filled, not the table part
    if xlikp-vbeln eq lv_vbeln.
      ls_likp = xlikp.
    else.
      read table xlikp into ls_likp
            with key vbeln = lv_vbeln.
    endif.                                                     "^_n_1168180

    if sy-subrc is initial.
      if ls_likp-spe_initiator_process = gc_initiator_process-tcrossdock.
        lv_cdrel = 'I'.
      else.
        lv_cdrel = 'S'.
      endif.
    endif.
  endif.

endform.                    "cd_relevance_check