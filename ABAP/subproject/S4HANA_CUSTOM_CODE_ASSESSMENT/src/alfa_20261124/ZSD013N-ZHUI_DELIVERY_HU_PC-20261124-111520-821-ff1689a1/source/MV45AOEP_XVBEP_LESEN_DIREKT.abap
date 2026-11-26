*---------------------------------------------------------------------*
*       MODULE XVBEP_LESEN_DIREKT                                     *
*---------------------------------------------------------------------*
*       Tabelle XVBEP mit Position und Einteilung lesen               *
*       Dies Modul ist für Einteilungsdetailbilder zu verwenden       *
*---------------------------------------------------------------------*
MODULE XVBEP_LESEN_DIREKT OUTPUT.

* Sonst gibt es einen Abbruch beim Ansprung des Bildes
  CHECK NOT VBEP-POSNR IS INITIAL AND NOT VBEP-ETENR IS INITIAL.
  PERFORM XVBEP_DELETED_CHECK(SAPFV45E) USING VBEP-POSNR
                                              VBEP-ETENR
                                              SVBEP-TABIX.
  PERFORM XVBEP_LESEN_DIREKT(SAPFV45E) USING VBEP-POSNR
                                             VBEP-ETENR
                                             SVBEP-TABIX.
  PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING VBEP-POSNR
                                             SVBAP-TABIX.

ENDMODULE.