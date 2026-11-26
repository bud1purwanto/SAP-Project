*---------------------------------------------------------------------*
*       FORM FPLAN_AKTUALISIEREN                                      *
*---------------------------------------------------------------------*
*       .................................                             *
*---------------------------------------------------------------------*
FORM FPLAN_AKTUALISIEREN USING  US_POSNR_FROM US_POSNR_NEXT
                                US_FLG_CREATE_DATES.
  LOCAL: VBAP_ENDE_BEARBEITUNG,
         VBAP_ENDE_VERFUEGBARKEIT,
         *VBAP,
         *VBKD,
         VBKD,
         SVBKD,
         SVBAP.
*LOCAL: VBAP, *VBAP, TVAP, *TVAP.
*
* Nicht im Anzeigemodus
  CHECK T180-TRTYP NE CHARA.

  IF US_POSNR_FROM EQ US_POSNR_NEXT AND
     NOT US_POSNR_FROM IS INITIAL.
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING US_POSNR_FROM
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM FPLAN_AKTUALISIEREN_CALL
      USING  US_FLG_CREATE_DATES
             SPACE.
    CHECK XVBAP-POSNR = XVBKD-POSNR AND NOT XVBKD-FPLNR IS INITIAL.
    PERFORM VBAP_BEARBEITEN(SAPFV45P).
    IF VBAP NE *VBAP.
*     Wenn sich aufgrund des Fakturierungsplans etwas geändert hat,
*     muß die Prüfung für das Unvollständigkeitsprotokoll laufen
      PERFORM VBAP_PRUEFEN_ENDE(SAPFV45P).
*     Statusermittlung
      PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
    ENDIF.
  ELSE.
    LOOP AT XVBAP.
      CHECK XVBAP-POSNR GE US_POSNR_FROM AND
            XVBAP-POSNR LE US_POSNR_NEXT AND
            XVBAP-UPDKZ NE 'D'.
*     Wenn Position fakturarelvant gemäß Fakturierungsplan
      SVBAP-TABIX = SY-TABIX.
      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
      PERFORM FPLAN_AKTUALISIEREN_CALL
        USING  US_FLG_CREATE_DATES
               CHARX.
      CHECK XVBAP-POSNR = XVBKD-POSNR AND NOT XVBKD-FPLNR IS INITIAL.
      PERFORM VBAP_BEARBEITEN(SAPFV45P).
      IF VBAP NE *VBAP.
*       Wenn sich aufgrund des Fakturierungsplans etwas geändert hat,
*       muß die Prüfung für das Unvollständigkeitsprotokoll laufen
        PERFORM VBAP_PRUEFEN_ENDE(SAPFV45P).
*       Statusermittlung
        PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.