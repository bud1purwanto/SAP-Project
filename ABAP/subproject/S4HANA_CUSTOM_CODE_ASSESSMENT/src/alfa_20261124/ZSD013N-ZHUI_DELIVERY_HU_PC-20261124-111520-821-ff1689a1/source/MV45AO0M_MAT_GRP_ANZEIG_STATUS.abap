*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_GRP_ANZEIG_STATUS                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MAT_GRP_ANZEIG_STATUS OUTPUT
*&---------------------------------------------------------------------*
MODULE MAT_GRP_ANZEIG_STATUS OUTPUT.

  CASE PRGMODUS.
    WHEN 'STANDARD'.
      SET PF-STATUS 'MAT_GRP_ANZEIG_STD'.
      SET TITLEBAR  'MAT_GRP_ANZEIG_STD'
                     WITH MAT_GRP_ANZEIG_KOPF-MATNR.
    WHEN 'VARIANTEN'.
      SET PF-STATUS 'MAT_GRP_ANZEIG_VAR'.
      SET TITLEBAR  'MAT_GRP_ANZEIG_VAR'
                     WITH MAT_GRP_ANZEIG_KOPF-MATNR.
  ENDCASE.

ENDMODULE.                             " mat_grp_anzeig_status OUTPUT