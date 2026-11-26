************************************************************************
*                                                                      *
* PAI Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "C" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE COBL_RECEIVE_LIPS                                      *
*---------------------------------------------------------------------*
*       Kontierungsdaten in die Lieferposition übernehmen             *
*---------------------------------------------------------------------*
module cobl_receive_lips.

  perform cobl_receive_lips(sapfv50p).
  perform subscreen_fcode_filter changing fcode.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  cust_head_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_head_pass_fcode input.

  perform cust_head_pass_fcode.

endmodule.                 " cust_head_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_head_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_head_get_data input.

  perform cust_head_get_data.

endmodule.                 " cust_head_get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  cust_item_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_item_pass_fcode input.

  perform cust_item_pass_fcode.

endmodule.                 " cust_item_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_item_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_item_get_data input.

  perform cust_item_get_data.

endmodule.                 " cust_item_get_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_glti_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_glti_pass_fcode input.

  perform cust_glti_pass_fcode.

endmodule.                 " cust_glti_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_glti_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_glti_get_data input.

  perform cust_glti_get_data.

endmodule.                 " cust_glti_get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  cust_over_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_over_pass_fcode input.

  perform cust_over_pass_fcode.

endmodule.                 " cust_over_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_over_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_over_get_data input.

  perform cust_over_get_data.

endmodule.                 " cust_over_get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  cust_scem_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_scem_pass_fcode input.

  perform cust_scem_pass_fcode.

endmodule.                 " cust_scem_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_scem_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_scem_get_data input.

  perform cust_scem_get_data.

endmodule.                 " cust_scem_get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  cust_gltr_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_gltr_pass_fcode input.

  perform cust_gltr_pass_fcode.

endmodule.                 " cust_gltr_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_gltr_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_gltr_get_data input.

  perform cust_gltr_get_data.

endmodule.                 " cust_gltr_get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  cust_auid_pass_fcode  INPUT
*&---------------------------------------------------------------------*
module cust_auid_pass_fcode input.

  perform cust_auid_pass_fcode.

endmodule.                 " cust_auid_pass_fcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  cust_auid_get_data  INPUT
*&---------------------------------------------------------------------*
module cust_auid_get_data input.

  perform cust_auid_get_data.

endmodule.                 " cust_auid_get_data  INPUT