*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MAT_CS_LISTE_FUELLEN                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MAT_CS_LISTE_FUELLEN  INPUT
*&---------------------------------------------------------------------*
MODULE MAT_CS_LISTE_FUELLEN INPUT.

  CS_TABIX = TCTRL_MAT_CS_ANZEIG_LIN1 + SY-STEPL - 1.
  READ TABLE MAT_CS_LISTE INDEX CS_TABIX.
  MAT_CS_LISTE-KWMENG = MATS_CS_OV-KWMENG.
  MAT_CS_LISTE-LSTACS = MATS_CS_OV-LSTACS.
  MODIFY MAT_CS_LISTE INDEX CS_TABIX.

ENDMODULE.                             " MAT_CS_LISTE_FUELLEN  INPUT













