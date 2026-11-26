***INCLUDE MV45AO0P_PH_VTEXT_GET .
*&---------------------------------------------------------------------*
*&      Module  PH_VTEXT_GET  OUTPUT
*&---------------------------------------------------------------------*
*       Produkthierarchietext besorgen                                *
*---------------------------------------------------------------------*
MODULE PH_VTEXT_GET OUTPUT.
* Produkthierarchie
  PERFORM PH_VTEXT_GET USING VBAP-PRODH
                             SPACE
                             SY-SUBRC.

ENDMODULE.                 " PH_VTEXT_GET  OUTPUT