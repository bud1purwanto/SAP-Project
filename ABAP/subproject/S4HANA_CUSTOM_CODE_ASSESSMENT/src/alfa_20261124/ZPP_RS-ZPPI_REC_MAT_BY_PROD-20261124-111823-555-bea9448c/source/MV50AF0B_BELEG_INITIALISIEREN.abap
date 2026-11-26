*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_INITIALISIEREN                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BELEG_INITIALISIEREN                                     *
*---------------------------------------------------------------------*
*       Nach Sichern werden die Belegrelevanten Daten initialisiert.  *
*       Die Vorschlagswerte des Anforderungsbildes werden in den Kopf *
*       übernommen.                                                   *
*---------------------------------------------------------------------*
FORM BELEG_INITIALISIEREN.

  DATA: DA_TFILL LIKE SY-TFILL,
        I_DNACT LIKE RDGDNACT.

   *LIKP = LIKP.
   *RV50A = RV50A.
  PERFORM BELEG_DATEN_INIT.

  IF T180-TRTYP = CHARH.
*   bei VL01 sollen die Vorschlagswerte erhalten bleiben
    LIKP-LFART  = *LIKP-LFART.
    LIKP-VKORG  = *LIKP-VKORG.
    RV50A-VTWEG = *RV50A-VTWEG.
    RV50A-SPART = *RV50A-SPART.
  ENDIF.

* Konfiguration initalisieren
  CALL FUNCTION 'CUD0_CONFIGURATION_INITIALIZER'
    EXCEPTIONS
      OTHERS = 2.

* Gefahrgut: Template-Materialabwicklung prüfen und initialisieren
  MOVE-CORRESPONDING *LIKP TO I_DNACT.
  CALL FUNCTION 'EHS003_CHECK_TPPR_ACTIVE'
    EXPORTING
      I_DNACT     = I_DNACT
      I_VBTYP     = *LIKP-VBTYP
    EXCEPTIONS
      TPPR_ACTIVE = 1
      OTHERS      = 2.

* lines deleted n_645951

ENDFORM.                    "BELEG_INITIALISIEREN