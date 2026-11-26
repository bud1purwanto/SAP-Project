*---------------------------------------------------------------------*
*       MODULE ANGEBOT_VON_BIS_PR                                     *
*---------------------------------------------------------------------*
*       Der Angebotsgültigkeitszeitraum wird geprüft                  *
*---------------------------------------------------------------------*
MODULE ANGEBOT_VON_BIS_PR.

  PERFORM DATUM_VON_BIS_PRUEFEN USING VBAK-ANGDT
                                      VBAK-BNDDT.
ENDMODULE.