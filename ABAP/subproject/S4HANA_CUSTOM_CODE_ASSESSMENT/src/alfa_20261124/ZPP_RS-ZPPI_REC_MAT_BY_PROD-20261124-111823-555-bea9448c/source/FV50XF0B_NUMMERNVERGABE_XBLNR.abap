***INCLUDE FV50XF0B_NUMMERNVERGABE_XBLNR .
*---------------------------------------------------------------------*
*       FORM NUMMERNVERGABE_XBLNR                                     *
*---------------------------------------------------------------------*
*  -->  IF_KOPF_TABIX                                                 *
*---------------------------------------------------------------------*
form nummernvergabe_xblnr using if_kopf_tabix like sy-tabix.

* Nummernvergabe für XBLNR durchführen
  data: lf_xblnr like vbrk-xblnr.

  check likp-vbtyp ca vbtyp_lief.
  clear fin1_param.
  fin1_param-appli = 'W'.
  if v50agl-sammelgang ne charx.
    fin1_param-aktyp = t180-aktyp.
  else.
    fin1_param-aktyp = charh.
  endif.
  likp = xlikp.
  fin1_param-blgar = likp-lfart.
  fin1_param-xblnr = likp-xblnr.
  perform xvbuk_lesen(sapfv50k) using xlikp-vbeln.
  call function 'OFF_NUMBER_GLOBAL_NUMBERING'
    exporting
      i_fin1_param = fin1_param
      i_likp       = likp
      i_vbuk       = vbuk
    importing
      o_xblnr      = lf_xblnr.
  xlikp-xblnr = lf_xblnr.
  modify xlikp index if_kopf_tabix.

endform.                    "NUMMERNVERGABE_XBLNR