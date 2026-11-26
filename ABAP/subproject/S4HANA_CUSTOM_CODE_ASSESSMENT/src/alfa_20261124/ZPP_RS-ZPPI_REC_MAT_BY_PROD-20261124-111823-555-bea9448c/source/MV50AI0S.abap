************************************************************************
*                                                                      *
* PAI Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "S" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE SAMMELGANG_KOMMUNIK(ATION)                             *
*---------------------------------------------------------------------*
*       Aus VL04 aufgerufen, werden die selektierten VG-Indizes       *
*       bearbeitet.                                                   *
*---------------------------------------------------------------------*
module sammelgang_kommunik.

* PERFORM VG_INDEX_BEARBEITEN(SAPFV50C).

endmodule.                    "sammelgang_kommunik
*eject

*&---------------------------------------------------------------------*
*&      Module  SHIPMENT_INFO_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module shipment_info_check input.                           "46A BEY

  perform shipment_info_check using    likp-trmtyp
                                       charx
                              changing likp-traty           "HP_323165
                                       sy-subrc.

endmodule.                             " SHIPMENT_INFO_CHECK  INPUT
*eject

*&---------------------------------------------------------------------*
*&      Module  SHIPMENT_VSART_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module shipment_vsart_check input.

  perform shipment_vsart_check using    likp-vsart
                                        likp-route
                                        charx
                               changing sy-subrc.

endmodule.                             " SHIPMENT_VSART_CHECK  INPUT
*eject

*&---------------------------------------------------------------------*
*&      Module  SET_ITEM_WORK_FLAG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_item_work_flag input.                            "46A BEY

* This flag indicates that LIPS_BEARBEITEN must be processed at the end
* of PAI
  gf_item_work_flag = charx.

ENHANCEMENT-POINT SET_ITEM_WORK_FLAG_01 SPOTS ES_SAPMV50A.
endmodule.                             " SET_ITEM_WORK_FLAG  INPUT
*eject

*&---------------------------------------------------------------------*
*&      Module  SET_HEADER_WORK_FLAG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_header_work_flag input.                          "46A BEY

* This flag indicates that LIKP_BEARBEITEN must be processed at the end
* of PAI
  gf_header_work_flag = charx.

endmodule.                             " SET_HEADER_WORK_FLAG  INPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  SET_DATA_FROM_EHS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_data_from_ehs input.

  call function 'EHS003_GET_DATA_EHS'
    importing
      e_shp_cursor_line = gs_get_cursor-line
    tables
      e_xvbuvtab        = xvbuv
      e_dvbuvtab        = dvbuv
      e_hvbuvtab        = hvbuv
    changing
      x_dataloss        = r185d-dataloss
    exceptions
      others_           = 1.

*delete entries in ilips
  loop at ilips.
    clear ilips-selkz.
    modify ilips.
  endloop.

  perform uc_upd_request(sapfv50u) using charx posnr_low    "n_531900
                                         posnr_low posnr_low.

endmodule.                 " SET_DATA_FROM_EHS  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_fcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_fcode input.

  call function 'EHS003_SET_FCODE'
    importing
      e_fcode = fcode
    exceptions
      others_ = 1.

endmodule.                 " set_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  sales_area_shippoint_check  INPUT (n_606000)
*&---------------------------------------------------------------------*
module sales_area_shippoint_check input.

  perform sales_area_shippoint_check using    likp-vstel
                                              likp-vkorg
                                              rv50a-vtweg
                                              rv50a-spart
                                     changing gf_subrc.
  if gf_subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endmodule.                 " sales_area_shippoint_check  INPUT