*&---------------------------------------------------------------------*
*&  Include           MV45AI0V_VBAP_IUID_PRUEFEN
*&---------------------------------------------------------------------*
MODULE vbap-iuid_pruefen.                     "EHP603 IUID

  PERFORM vbap_iuid_pruefen(sapfv45p) USING vbap-matnr
                                            vbap-werks
                                   CHANGING vbap-iuid_relevant
                                            sy-subrc.

ENDMODULE.                    "VBAP-IUID_PRUEFEN