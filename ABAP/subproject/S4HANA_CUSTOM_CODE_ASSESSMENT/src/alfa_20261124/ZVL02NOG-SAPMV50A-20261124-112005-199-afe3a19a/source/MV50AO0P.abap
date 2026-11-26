*----------------------------------------------------------------------*
***INCLUDE MV50AO0P .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  POD_SEGMENT_AUFBEREIT  OUTPUT
*&---------------------------------------------------------------------*
*       POD Segmente aufbereiten
*----------------------------------------------------------------------*
module pod_segment_aufbereit output.

  data: gf_fcode like sy-ucomm.
  clear gf_fcode.
  export gf_fcode to memory id 'GF_FCODE'.

  check gf_error_pod is initial.
  clear:   gf_anz_pod,
           gt_tvpod.

  refresh: gt_tvpod.

  call function 'LE_POD_TVPOD_READ'
    tables
      it_lips  = xlips
      et_tvpod = gt_tvpod.

endmodule.                             " POD_SEGMENT_AUFBEREIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PREPARE_PARTNER_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
module prepare_partner_screen output.

  perform prepare_partner_screen.

endmodule.                             " PREPARE_PARTNER_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_SUBSCREEN_SET_HEAD  OUTPUT
*&---------------------------------------------------------------------*
module pricing_subscreen_set_head output.

  perform pricing_subscreen_set_head.

endmodule.                 " PRICING_SUBSCREEN_SET_HEAD  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_SUBSCREEN_SET_ITEM  OUTPUT
*&---------------------------------------------------------------------*
module pricing_subscreen_set_item output.

  perform pricing_subscreen_set_item.

endmodule.                 " PRICING_SUBSCREEN_SET_ITEM  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PREPARE_DEADLINE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
module prepare_deadline_screen output.

  perform prepare_deadline_screen.

endmodule.                             " PREPARE_DEADLINE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POD_ERROR_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*       Error handling for POD split screen
*----------------------------------------------------------------------*
module pod_error_message output.
  if not gf_error_pod is initial.
    perform pod_message_handling using gf_error_pod
                                       t185v-panel.
  endif.

endmodule.                             " POD_ERROR_MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_PREPARE_HEAD  OUTPUT
*&---------------------------------------------------------------------*
module pricing_prepare_head output.

  perform pricing_prepare_head.

endmodule.                             " PRICING_PREPARE_HEAD  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PRICING_PREPARE_ITEM  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module pricing_prepare_item output.

  perform pricing_prepare_item.

endmodule.                             " PRICING_PREPARE_ITEM  OUTPUT