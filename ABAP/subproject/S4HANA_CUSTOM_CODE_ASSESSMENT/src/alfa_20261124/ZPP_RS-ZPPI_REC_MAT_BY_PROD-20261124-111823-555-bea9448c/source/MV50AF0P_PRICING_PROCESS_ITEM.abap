*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRICING_PROCESS_ITEM                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PRICING_PROCESS_ITEM
*&---------------------------------------------------------------------*
form pricing_process_item.

  if tkomp-fxmsg ne space.
    lips-netwr = tkomp-netwr.
    lips-netpr = tkomp-netpr.
    lips-kpein = tkomp-kpein.
    lips-kmein = tkomp-kmein.
    lips-wavwr = tkomp-wavwr.
    lips-kzwi1 = tkomp-kzwi1.
    lips-kzwi2 = tkomp-kzwi2.
    lips-kzwi3 = tkomp-kzwi3.
    lips-kzwi4 = tkomp-kzwi4.
    lips-kzwi5 = tkomp-kzwi5.
    lips-kzwi6 = tkomp-kzwi6.
    gf_item_work_flag = charx.
  endif.

  perform uc_upd_request(sapfv50u) using charx              "n_531900
                                         lips-posnr         "HP_369514
                                         lips-uepos
                                         lips-uecha.

endform.                               " PRICING_PROCESS_ITEM