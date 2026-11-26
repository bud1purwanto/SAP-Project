*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_PACKING_CONSISTENCY_C                   *
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&      Form  packing_consistency_check
*&--------------------------------------------------------------------*
form packing_consistency_check using is_likp like likpvb.

  data: lf_subrc like sy-subrc.

  move-corresponding xlikp to likp.                           "n_1452569
  perform hu_batchsplit_chhpv_update(sapfv50p) using    is_likp-vbeln
                                                        0
                                                        charx
                                               changing lf_subrc.
  if lf_subrc ne 0.
    perform finchdel_handling(sapfv50p) using is_likp-vbeln
                                              '06'
                                              sy-msgty
                                              sy-msgid
                                              sy-msgno
                                              sy-msgv1
                                              sy-msgv2
                                              sy-msgv3
                                              sy-msgv4
                                              gt_finchdel.
  endif.

endform.                    "packing_consistency_check