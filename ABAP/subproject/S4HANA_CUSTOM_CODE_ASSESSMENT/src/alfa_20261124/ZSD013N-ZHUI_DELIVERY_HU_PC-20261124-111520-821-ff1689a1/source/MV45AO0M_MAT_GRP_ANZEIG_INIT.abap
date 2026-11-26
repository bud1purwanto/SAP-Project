*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_GRP_ANZEIG_INIT                               *
*----------------------------------------------------------------------*
MODULE MAT_GRP_ANZEIG_INIT OUTPUT.
  DESCRIBE TABLE MAT_LISTE LINES TCTRL_MAT_GRP_ANZEIG-LINES.
  TCTRL_MAT_GRP_ANZEIG-TOP_LINE = TCTRL_MAT_GRP_ANZEIG_LIN1.
ENDMODULE.