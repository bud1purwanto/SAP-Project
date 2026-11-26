*----------------------------------------------------------------------*
***INCLUDE MV45AO0M_MAT_CS_ANZEIG_DISPLAY .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MAT_CS_ANZEIG_DISPLAYLIST  OUTPUT
*&---------------------------------------------------------------------*
MODULE MAT_CS_ANZEIG_DISPLAYLIST OUTPUT.

  DATA: CS_TABIX LIKE SY-TABIX.

  CS_TABIX = SY-STEPL + TCTRL_MAT_CS_ANZEIG_LIN1 - 1.
  READ TABLE MAT_CS_LISTE INDEX CS_TABIX.
  IF SY-SUBRC EQ 0.
    MOVE-CORRESPONDING MAT_CS_LISTE TO MATS_CS_OV.
  ELSE.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " MAT_CS_ANZEIG_DISPLAYLIST  OUTPUT









