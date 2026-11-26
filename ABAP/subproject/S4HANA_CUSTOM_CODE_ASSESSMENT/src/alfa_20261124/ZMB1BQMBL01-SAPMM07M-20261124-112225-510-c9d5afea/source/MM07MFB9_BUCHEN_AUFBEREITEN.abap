*---------------------------------------------------------------------*
*       FORM BUCHEN_AUFBEREITEN                                       *
*---------------------------------------------------------------------*
*       Die Verbuchungstabellen werden aus dem Y-Beleg erstellt.      *
*---------------------------------------------------------------------*
FORM BUCHEN_AUFBEREITEN
            CHANGING cs_enhancement TYPE isc_buchen_aufbereiten. "#EC *

  DATA: ls_isc_f_segmente_generieren TYPE isc_f_segmente_generieren. "IS2ERP

ENHANCEMENT-POINT MM07MFB9_BUCHEN_AUFBEREITEN_01 SPOTS ES_SAPMM07M.
ENHANCEMENT-POINT BUCHEN_AUFBEREITEN_20 SPOTS ES_SAPMM07M STATIC.

  PERFORM BUCHEN_INITIALISIEREN.
ENHANCEMENT-POINT BUCHEN_AUFBEREITEN_21 SPOTS ES_SAPMM07M.
ENHANCEMENT-SECTION     MM07MFB9_BUCHEN_AUFBEREITEN_02 SPOTS ES_SAPMM07M.
  IF_FIRST.
  PERFORM UML_CHECK_BUCHEN_PRODME.
  PERFORM M-SEGMENTE_GENERIEREN.
  PERFORM M-BELEG_ERGAENZEN.
  END_FIRST.
END-ENHANCEMENT-SECTION.
  IF_SECON.
  PERFORM F-SEGMENTE_GENERIEREN
                                USING ls_isc_f_segmente_generieren. "IS2ERP
  END_SECON.
  PERFORM M-SEGMENTE_ERGAENZEN.
  IF_SECON.
  PERFORM F-BELEG_ERGAENZEN.
  END_SECON.
  PERFORM BUCHEN_FOLGEDATEN.

ENHANCEMENT-POINT BUCHEN_AUFBEREITEN_01 SPOTS ES_SAPMM07M.
ENDFORM.