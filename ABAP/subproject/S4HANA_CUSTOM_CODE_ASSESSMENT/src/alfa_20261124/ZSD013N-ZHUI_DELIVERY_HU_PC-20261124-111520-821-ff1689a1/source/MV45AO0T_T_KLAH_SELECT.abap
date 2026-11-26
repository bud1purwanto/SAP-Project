*&---------------------------------------------------------------------*
*&      Module  T_KLAH_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Lesen der texte zu den Warengruppenhierarchien
*----------------------------------------------------------------------*
MODULE T_KLAH_SELECT OUTPUT.

  PERFORM T_KLAH_SELECT USING VBAP-WGRU1
                              VBAP-WGRU2
                              SY-SUBRC.

ENDMODULE.                             " T_KLAH_SELECT  OUTPUT