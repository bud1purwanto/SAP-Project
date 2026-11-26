*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50ADIA_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  /spe/output_header_fields  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE /spe/output_header_fields OUTPUT.

  PERFORM /spe/output_header_fields USING    likp
                                    CHANGING /spe/ret_dia.

ENDMODULE.                 " /spe/output_header_fields  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  /spe/output_item_fields  OUTPUT
*&---------------------------------------------------------------------*
*       Get split flow + cumulate quantities + fill item fields
*----------------------------------------------------------------------*
MODULE /spe/output_item_fields OUTPUT.

  PERFORM /spe/output_item_fields  TABLES   xlips
                                            xvbup
                                            xvbapf     "n_1245044
                                   USING    likp
                                            lips
                                   CHANGING /spe/ret_dia.       .

ENDMODULE.                 " /spe/output_item_fields  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  /spe/ret_select_screen  OUTPUT
*&---------------------------------------------------------------------*
*       Determine screen for display of returns data
*----------------------------------------------------------------------*
MODULE /spe/ret_select_screen OUTPUT.

  PERFORM /spe/ret_select_screen.

ENDMODULE.                 " /spe/ret_select_screen  OUTPUT