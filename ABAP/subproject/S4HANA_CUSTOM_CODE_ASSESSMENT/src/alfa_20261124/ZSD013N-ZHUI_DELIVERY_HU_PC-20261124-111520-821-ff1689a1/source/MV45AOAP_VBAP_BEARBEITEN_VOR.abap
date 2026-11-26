*---------------------------------------------------------------------*
*       MODULE VBAP_BEARBEITEN_VOR(bereiten)                          *
*---------------------------------------------------------------------*
*       Bearbeiten der Auftragsposition                               *
*---------------------------------------------------------------------*
MODULE VBAP_BEARBEITEN_VOR OUTPUT.

  IF SVBAP-TABIX > 0.
    READ TABLE XVBAP INDEX SVBAP-TABIX.
    IF SY-SUBRC NE 0.
      MESSAGE A325 WITH SVBAP-TABIX.
    ENDIF.
  ENDIF.
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

ENDMODULE.