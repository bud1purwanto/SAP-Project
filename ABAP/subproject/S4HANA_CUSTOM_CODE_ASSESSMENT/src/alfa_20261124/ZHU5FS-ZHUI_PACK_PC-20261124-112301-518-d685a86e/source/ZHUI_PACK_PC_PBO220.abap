*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACK_PC_PBO220
*&---------------------------------------------------------------------*

*&spwizard: output module for tc 'TBLPRINT'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE TBLPRINT_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_PRINTLIST LINES TBLPRINT-LINES.
ENDMODULE.                    "TBLPRINT_change_tc_attr OUTPUT

*&spwizard: output module for tc 'TBLPRINT'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TBLPRINT_GET_LINES OUTPUT.
  G_TBLPRINT_LINES = SY-LOOPC.
ENDMODULE.                    "TBLPRINT_get_lines OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_0220  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0220 OUTPUT.
  SET PF-STATUS '220'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0220  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  load_hu_print_selection  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOAD_HU_PRINT_SELECTION OUTPUT.
ENDMODULE.                 " load_hu_print_selection  OUTPUT