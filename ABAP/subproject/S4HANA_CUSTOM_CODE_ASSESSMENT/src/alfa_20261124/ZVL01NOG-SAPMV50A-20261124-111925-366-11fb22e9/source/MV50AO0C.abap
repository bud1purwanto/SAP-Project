
************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Versand                             *
*     Module alphabetisch geordnet; hier beginnend mit "C"             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE CUA_SETZEN                                             *
*---------------------------------------------------------------------*
*       CUA-Status aufbauen und damit die Uberschrift und den         *
*       Actionbar setzen.                                             *
*---------------------------------------------------------------------*
module cua_setzen output.
  perform cua_setzen.
endmodule.
*eject

*---------------------------------------------------------------------*
*       MODULE CUA_SETZEN_R                                           *
*---------------------------------------------------------------------*
*       CUA-Status aufbauen und damit die Uberschrift und den         *
*       Actionbar setzen. Der Status R wird gesetzt                   *
*---------------------------------------------------------------------*
module cua_setzen_r output.
  perform cua_setzen.
  set pf-status charr.
  set titlebar 'R01 '.
endmodule.
*eject

*---------------------------------------------------------------------*
*       MODULE CUA_SETZEN_O                                           *
*---------------------------------------------------------------------*
*       CUA-Status aufbauen und damit die Uberschrift und den         *
*       Actionbar setzen. Der Status O wird gesetzt                   *
*---------------------------------------------------------------------*
module cua_setzen_o output.
  perform cua_setzen.
  set pf-status charo.
endmodule.
*eject
*&---------------------------------------------------------------------*
*&      Module  COBL_SEND_PBO_LIPS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module cobl_send_pbo_lips output.
  perform cobl_send_pbo_lips(sapfv50p).
endmodule.                             " COBL_SEND_PBO_LIPS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR_HEADER_WORK_FLAG  OUTPUT
*&---------------------------------------------------------------------*
module clear_header_work_flag output.

* This flag indicates that LIKP_BEARBEITEN must be processed at the end
* of PAI. It must be refreshed in PBO of the carrier dynpro
  clear gf_header_work_flag.

endmodule.                             " CLEAR_HEADER_WORK_FLAG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CLEAR_ITEM_WORK_FLAG  OUTPUT
*&---------------------------------------------------------------------*
module clear_item_work_flag output.

* This flag indicates that LIPS_BEARBEITEN must be processed at the end
* of PAI. It must be refreshed in PBO of the carrier dynpro
  clear gf_item_work_flag.

endmodule.                             " CLEAR_ITEM_WORK_FLAG  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHOOSE_DYNP_PRECEDE  OUTPUT
*&---------------------------------------------------------------------*
*       Select dynpro to be shown on the detail screen for the
*       preceding document
*----------------------------------------------------------------------*
module choose_dynp_precede output.

  if lips-vgtyp ca vbtyp_auft.         "sales order
    gf_dyn_precede = '3302'.
  elseif lips-vgtyp eq vbtyp_bestell.  "purchase order
    gf_dyn_precede = '3304'.
  elseif not likp-verursys is initial. "reference data WMS
    if lips-rfvgtyp ca vbtyp_auft.                          "HP_318968
      gf_dyn_precede = '3312'.
    else.
      gf_dyn_precede = '3314'.
    endif.
  else.
    case tvlk-aufer.
      when gc_aufer-project.           "project
        gf_dyn_precede = '3306'.
      when gc_aufer-lohnbei.           "subcontract
        gf_dyn_precede = '3308'.
      when others.                     "no known preceding document
        gf_dyn_precede = '3310'.
    endcase.
  endif.

endmodule.                             " CHOOSE_DYNP_PRECEDE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR_DUMMY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       Clear output fields on dummy batch split screen
*----------------------------------------------------------------------*
module clear_dummy_screen output.

  clear: rv50a-lfimg, rv50a-kcmeng_vme, rv50a-vrkm2, rv50a-umvkn,
         rv50a-umvkz, rv50a-vrkme, rv50a-mein1.

endmodule.                             " CLEAR_DUMMY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  cust_head_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_head_set_data output.

  perform cust_head_set_data.

endmodule.                 " cust_head_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_item_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_item_set_data output.

  perform cust_item_set_data.

endmodule.                 " cust_item_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_glti_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_glti_set_data output.

  perform cust_glti_set_data.

endmodule.                 " cust_glti_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_over_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_over_set_data output.

  perform cust_over_set_data.

endmodule.                 " cust_over_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_scem_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_scem_set_data output.

  perform cust_scem_set_data.

endmodule.                 " cust_scem_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_gltr_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_gltr_set_data output.

  perform cust_gltr_set_data.

endmodule.                 " cust_gltr_set_data  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  cust_auid_set_data  OUTPUT
*&---------------------------------------------------------------------*
module cust_auid_set_data output.

  perform cust_auid_set_data.

endmodule.                 " cust_gltr_set_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  screen_input_initial_screen  OUTPUT
*&---------------------------------------------------------------------*
module screen_input_initial_screen output.

  perform screen_input_initial_screen.

endmodule.