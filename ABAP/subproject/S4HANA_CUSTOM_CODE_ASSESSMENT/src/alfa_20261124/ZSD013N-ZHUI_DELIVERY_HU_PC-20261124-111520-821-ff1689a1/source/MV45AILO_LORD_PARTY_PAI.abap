*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_PARTY_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  sub_process_h
*&---------------------------------------------------------------------*
form sub_process_h.

  perform sub_process(sapmv45a) using charh.

endform.                    " sub_process_h


*&---------------------------------------------------------------------*
*&      Form  sub_process_i
*&---------------------------------------------------------------------*
form sub_process_i.

  perform sub_process(sapmv45a) using chari.

endform.                    " sub_process_i


*&---------------------------------------------------------------------*
*&      Form  partner_data_get
*&---------------------------------------------------------------------*
form partner_data_get.

  data: lv_objecttype type swo_objtyp,
        lv_objectkey type swo_typeid.

  lv_objecttype = businessobjekt.
  lv_objectkey = vbak-vbeln.

  call function 'SD_PARTNER_DATA_GET'
    exporting
      fic_objecttype   = lv_objecttype
      fic_objectkey    = lv_objectkey
      fic_xvbuv_merged = 'X'
      fic_hvbuv_merged = 'X'
    tables
      fet_xvbpa        = xvbpa[]
      fet_yvbpa        = yvbpa[]
      fet_xvbuv        = xvbuv[]
      fet_hvbuv        = hvbuv[]
      fet_xvbadr       = xvbadr[]
      fet_yvbadr       = yvbadr[]
    exceptions
      others           = 1.

endform.                    "partner_data_get