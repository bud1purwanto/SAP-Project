*---------------------------------------------------------------------*
*       MODULE RV45A_MUEBS_EINGABE                                    *
*---------------------------------------------------------------------*
*       Merkmale aus Merkmalübersicht holen                           *
*---------------------------------------------------------------------*
MODULE rv45a_muebs_eingabe.

  PERFORM rv45a-muebs_lesen USING   charx
                            CHANGING sy-subrc.

ENDMODULE.