*---------------------------------------------------------------------*
*       MODULE GUELTIG_VON_BIS_PR                                     *
*---------------------------------------------------------------------*
*       Der Gültigkeitszeitraum wird geprüft                          *
*---------------------------------------------------------------------*
MODULE GUELTIG_VON_BIS_PR.

  PERFORM DATUM_VON_BIS_PRUEFEN USING VBAK-GUEBG
                                      VBAK-GUEEN.
ENHANCEMENT-POINT GUELTIG_VON_BIS_PR_10 SPOTS ES_SAPMV45A.
ENDMODULE.