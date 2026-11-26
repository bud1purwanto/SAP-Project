*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MAT_GRP_ANZEIG_SET_LI                             *
*----------------------------------------------------------------------*

MODULE MAT_GRP_ANZEIG_SET_LINCNT INPUT.
* Dynpro >>> Liste
  mat_liste = mats_avail.
  TCTRL_MAT_GRP_ANZEIG_LINCNT = SY-LOOPC.
*  MODIFY mat_liste INDEX sy-stepl.
*  da_tabix = tctrl_mat_grp_anzeig_lin1 + sy-stepl - 1.
*  MODIFY selkz_liste INDEX da_tabix.

ENDMODULE.




















