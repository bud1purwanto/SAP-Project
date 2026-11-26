*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_VEDA_PBO
*&---------------------------------------------------------------------*

form lord_veda_pbo using uv_level type c.

  data: lv_vbeln type veda-vbeln,
        lv_vposn type veda-vposn,
        lv_fehgr type fehgr.

  move vbak-vbeln to lv_vbeln.
  move posnr_low to veda_posnr_low.
  if uv_level eq charh.
    lv_vposn = posnr_low.
    lv_fehgr = tvak-fehgr.
  else.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    lv_vposn = vbap-posnr.
    lv_fehgr = tvap-fehgr.
  endif.

  call function 'SD_VEDA_PUT_DATA'
    exporting
      i_document_number = lv_vbeln
      i_position_number = lv_vposn
      i_posnr_low       = veda_posnr_low
      i_profile         = tvak-vprof
*     i_fehgr           = lv_fehgr
      i_vbak            = vbak
      i_tvak            = tvak.

endform.                    "lord_veda_pbo