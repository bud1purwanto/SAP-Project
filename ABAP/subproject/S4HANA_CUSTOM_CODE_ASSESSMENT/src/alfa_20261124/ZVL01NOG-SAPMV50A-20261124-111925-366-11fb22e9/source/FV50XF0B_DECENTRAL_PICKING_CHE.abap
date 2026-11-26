*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_DECENTRAL_PICKING_CHE                   *
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&      Form  decentral_picking_check
*&--------------------------------------------------------------------*
*       Simulation mode: The change of the delivery distributed to the
*       decentral WMS system can be refused if the picking process
*       has already started.
*---------------------------------------------------------------------*

form decentral_picking_check using is_xlikp like likpvb.


  data: lf_subrc like sy-subrc,
        lf_rcode like sy-subrc,
        ls_xvbuk like line of xvbuk,
        lf_msgty like sy-msgty value 'E'.

  field-symbols: <ls_xlips> like line of xlips,
                 <ls_ylips> like line of ylips.

* Only relevant if
* - document is located in the decentral WMS
* - change management is active
* - simulation mode is active (changability of the document is tested
*   via RFC from the central system)
  check not is_xlikp-verursys is initial and
        v50agl-dlv_change ne space       and
        v50agl-no_rmsys_dlv_chg ne space.

* Further checks are necessary only if picking process has been started
  read table xvbuk into ls_xvbuk
                   with key vbeln = is_xlikp-vbeln
                   binary search.

  check ls_xvbuk-kostk ca 'BC'.

  lf_subrc = 0.
  loop at xlips assigning <ls_xlips>
                where vbeln eq is_xlikp-vbeln.
    if <ls_xlips>-updkz eq updkz_old.
      continue.
    endif.
*   Item has been deleted
    if <ls_xlips>-updkz eq updkz_delete.
      if lf_subrc eq 8.
        lf_subrc = 12.
        exit.
      else.
        lf_subrc = 4.
      endif.
    endif.
*   Item has been changed
    read table ylips assigning <ls_ylips>
                     with key vbeln = <ls_xlips>-vbeln
                              posnr = <ls_xlips>-posnr.
    if <ls_ylips>-lfimg lt <ls_xlips>-lfimg or
       <ls_ylips>-lgmng lt <ls_xlips>-lgmng.
      if lf_subrc eq 4.
        lf_subrc = 12.
        exit.
      else.
        lf_subrc = 8.
      endif.
    endif.
ENHANCEMENT-POINT FV50XF0B_DECENTRAL_PICKING_C01 SPOTS ES_FV50XF0B_DECENTRAL_PICKING INCLUDE BOUND .

ENHANCEMENT-POINT FV50X0B_DECENTRAL_PICKING_C001 SPOTS ES_FV50XF0B_DECENTRAL_PICKING INCLUDE BOUND.

  endloop.

  case lf_subrc.
    when 0.
*     At least send a warning to the user about the start of the picking
*     process
      clear lf_msgty.
      perform message_steuerung using  gs_mhpar
                                       v50agl-msgvs
                                       'VL'
                                       '474'
                              changing lf_msgty
                                       lf_rcode.
      if lf_msgty ne space.
        perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '07' lf_msgty 'VL' '474'
                                    space space space space gt_finchdel.
      endif.
    when 4.
      clear lf_msgty.
      perform message_steuerung using  gs_mhpar
                                       v50agl-msgvs
                                       'VL'
                                       '460'
                              changing lf_msgty
                                       lf_rcode.
      if lf_msgty ne space.
        perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '07' lf_msgty 'VL' '460'
                                    space space space space gt_finchdel.
      endif.
    when 8.
      clear lf_msgty.
      perform message_steuerung using  gs_mhpar
                                       v50agl-msgvs
                                       'VL'
                                       '470'
                              changing lf_msgty
                                       lf_rcode.
      if lf_msgty ne space.
        perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '07' lf_msgty 'VL' '470'
                                    space space space space gt_finchdel.
      endif.
    when 12. "both: quantity increased and item deleted
      clear lf_msgty.
      perform message_steuerung using  gs_mhpar
                                       v50agl-msgvs
                                       'VL'
                                       '460'
                              changing lf_msgty
                                       lf_rcode.
      if lf_msgty ne space.
        perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '07' lf_msgty 'VL' '460'
                                    space space space space gt_finchdel.
      endif.
      clear lf_msgty.
      perform message_steuerung using  gs_mhpar
                                       v50agl-msgvs
                                       'VL'
                                       '470'
                              changing lf_msgty
                                       lf_rcode.
      if lf_msgty ne space.
        perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '07' lf_msgty 'VL' '470'
                                    space space space space gt_finchdel.
      endif.
  endcase.

endform.                    "decentral_picking_check