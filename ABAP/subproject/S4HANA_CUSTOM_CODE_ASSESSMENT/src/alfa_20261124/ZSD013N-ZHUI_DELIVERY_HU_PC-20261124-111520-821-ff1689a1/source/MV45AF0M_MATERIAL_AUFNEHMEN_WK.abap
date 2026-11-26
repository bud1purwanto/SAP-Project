*&--------------------------------------------------------------------*
*&      Form  MATERIAL_AUFNEHMEN_WK                                   *
*&--------------------------------------------------------------------*
*       Material in XVBAP stellen und notwendige Felder versorgen     *
*---------------------------------------------------------------------*
FORM MATERIAL_AUFNEHMEN_WK.

  DATA: DA_POSNR_HIGH LIKE VBAP-POSNR.

* Nur bei Materialänderung oder -neueingabe neu füllen
  IF ( *VBAP-MATNR NE VBAP-MATNR OR
       NOT MATNR_CHANGED IS INITIAL ) AND
     NOT VBAP-MATNR IS INITIAL.

* Höchste Positionsnummer besorgen
    IF SVBAP-TABIX = 0.
      CLEAR DA_POSNR_HIGH.
      LOOP AT XVBAP.
        IF XVBAP-POSNR > DA_POSNR_HIGH.
          DA_POSNR_HIGH = XVBAP-POSNR.
        ENDIF.
      ENDLOOP.
      DA_POSNR_HIGH   = DA_POSNR_HIGH + 1.
      VBAP-POSNR      = DA_POSNR_HIGH.
    ENDIF.
    VBAP-MATWA      = VBAP-MATNR.
    VBAP-WAERK      = RV45A-WAERS.
    VBAPD-VGPOS_WK  = RV45A-POSNR.
    VBAP-PSTYV      = RV45A-PSTYV.
    VBAPD-UPDKZ     = UPDKZ_NEW.
    VBAP-MANDT      = SY-MANDT.
    VBAP-VBELN      = VBAK-VBELN.
    VBAP-PS_PSP_PNR = RV45A-PS_PSP_PNR.
  ENDIF.

  MOVE-CORRESPONDING VBAP TO XVBAP.
  MOVE-CORRESPONDING VBAPD TO XVBAP.

  IF *VBAP-MATNR IS INITIAL AND          "Material wurde neu eingegeben
     NOT VBAP-MATNR IS INITIAL.
    APPEND XVBAP.
*   Neue Position zur Anzeige bringen
    RV45A-VBAP_SELKZ = SELEKTIERT.
    PERFORM IVBAP_ANLEGEN(SAPFV45P) USING SY-TABIX.
*   Selektionskennzeichen für neue Position löschen
    CLEAR RV45A-VBAP_SELKZ.
*   Offene Referenzmenge übernehmen
  ENDIF.

  IF VBAP-MATNR IS INITIAL AND                 "Material wurde gelöscht
     NOT *VBAP-MATNR IS INITIAL.
    XVBAP-UPDKZ = UPDKZ_DELETE.
    MODIFY XVBAP INDEX IVBAP-TABIX.
    LOOP AT IVBAP WHERE POSNR = VBAP-POSNR.
      DELETE IVBAP.
    ENDLOOP.
  ENDIF.

  IF NOT VBAP-MATNR IS INITIAL AND             "Material wurde geändert
     NOT *VBAP-MATNR IS INITIAL AND
     ( VBAP-MATNR NE *VBAP-MATNR OR
       NOT MATNR_CHANGED IS INITIAL ).
    MODIFY XVBAP INDEX IVBAP-TABIX.
    IVBAP-SELKZ = SELEKTIERT.
    LOOP AT IVBAP WHERE POSNR = VBAP-POSNR.
      MODIFY IVBAP.
    ENDLOOP.
  ENDIF.

  IF NOT VBAP-MATNR IS INITIAL AND             "Keine Materialänderung
     VBAP-MATNR EQ *VBAP-MATNR AND
     MATNR_CHANGED IS INITIAL .
    IF VBAPD-ORFMNG NE *VBAPD-ORFMNG.
      MODIFY XVBAP INDEX IVBAP-TABIX.
*     Position markieren bei Mengenänderung nivht auf 0
      IF NOT VBAPD-ORFMNG IS INITIAL.
        RV45A-VBAP_SELKZ = SELEKTIERT.
      ENDIF.
    ENDIF.
    LOOP AT IVBAP WHERE POSNR = VBAP-POSNR.
      IVBAP-SELKZ = RV45A-VBAP_SELKZ.
      MODIFY IVBAP.
    ENDLOOP.
  ENDIF.

ENDFORM.