*---------------------------------------------------------------------*
*       FORM FCODE_BVFP_V                                             *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Verfügbarkeitsprüfung über T185V         *
*       Retten der Bildfolge wegen Montage mit Fertigungsauftrag      *
*---------------------------------------------------------------------*
FORM FCODE_BVFP_V USING H185F STRUCTURE T185F
                        H185  STRUCTURE T185
                        H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM FCODE_BVFP.

  PERFORM XVBAP_UEBERSICHT_ANSTEUERN(SAPFV45P).

  T185F-FCODE = FCODE_ZURUECK3.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.