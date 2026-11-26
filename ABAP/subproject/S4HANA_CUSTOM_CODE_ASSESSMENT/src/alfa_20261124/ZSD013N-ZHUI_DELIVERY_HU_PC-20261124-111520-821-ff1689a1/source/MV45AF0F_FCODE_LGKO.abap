*---------------------------------------------------------------------*
*       FORM FCODE_LGKO                                               *
*---------------------------------------------------------------------*
*       Korrelation der Liefergruppen per Taste                       *
*---------------------------------------------------------------------*
FORM FCODE_LGKO.

  DATA: DA_LINES_GVBAP LIKE SY-TFILL,
        DA_GRKOR       LIKE VBAP-GRKOR.
  DATA: DA_SVBAP_TABIX LIKE SVBAP-TABIX.

  IF XVBAP_UMFANG EQ XVBAP_UMFANG_POST.
* Rückkehr vom Strukturbild
    PERFORM D301T_SELECT USING FCODE_UMFANG_POSITIONEN.

    PERFORM XVBAP_UMFANG_SETZEN(SAPFV45P)
                                USING FCODE_UMFANG_POSITIONEN.
    PERFORM IVBAP_AUFBAUEN(SAPFV45P).
    IVBAP_TABIX_ZEILE_1 = IVBAP_TABIX_ZEILE_1_POST.
    IVBAP_TABIX_ZEILE_1_POST = 1.
    CLEAR RV45A-MATNR.
  ENDIF.

  DESCRIBE TABLE GVBAP LINES DA_LINES_GVBAP.
  IF DA_LINES_GVBAP = 0.
    IF VBAK-AUTLF EQ SPACE.
      EXIT.
    ELSE.
      PERFORM GVBAP_ANLEGEN_LOOP(SAPFV45V) USING DA_GRKOR.
    ENDIF.
  ENDIF.

* sichern den alten Stand von VBAPs, also SVBAP-TABIX
  DA_SVBAP_TABIX = SVBAP-TABIX.

* Liefergruppen korrelieren
  PERFORM LIEFERGRUPPENDATUM_SETZEN(SAPFV45V) USING VERARB_HELL.

* restaurieren den alten Stand (SVBAP-TABIX)
  SVBAP-TABIX = DA_SVBAP_TABIX.

ENDFORM.