*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_GRP_ANZEIG_DISPLA                             *
*----------------------------------------------------------------------*
MODULE MAT_GRP_ANZEIG_DISPLAYLIST OUTPUT.
  SY-TABIX = SY-STEPL + TCTRL_MAT_GRP_ANZEIG_LIN1 - 1.
  READ TABLE MAT_LISTE INDEX SY-TABIX.
  if sy-subrc = 0.
*  Listdaten >>> Dynpro
    mats_avail = mat_liste.
  endif.
ENDMODULE.


























