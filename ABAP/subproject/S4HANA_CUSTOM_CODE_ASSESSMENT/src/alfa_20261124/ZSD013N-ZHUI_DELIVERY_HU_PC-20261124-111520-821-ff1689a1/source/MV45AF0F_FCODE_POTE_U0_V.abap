*---------------------------------------------------------------------*
*       FORM FCODE_POTE_U0_V                                          *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Gesamtnetzterminierung über T185V        *
*       Retten der Bildfolge wegen Montage mit Fertigungsauftrag      *
*---------------------------------------------------------------------*
FORM FCODE_POTE_U0_V USING H185F STRUCTURE T185F
                           H185  STRUCTURE T185
                           H185V STRUCTURE T185V.

  CONSTANTS: ORDCHG_TAB-MENGE_NULL LIKE ORDCHG-MENGE VALUE IS INITIAL.

  DATA: ORDCHG_TAB LIKE ORDCHG OCCURS 0 WITH HEADER LINE.
  DATA: DA_PWERT TYPE F.
* nur Dummy-Variable wegen Übergabe an KALKULATIONSWERT_UEBERNEHMEN
  DATA: DA_FWFIX  LIKE RK70SOUT-FWFIX.
  DATA: DA_MBDAT_ERSTE LIKE VBEP-MBDAT.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* prüfe, ob es markierte Positionen gibt
  LOOP AT IVBAP WHERE SELKZ EQ CHARX.
    EXIT.
  ENDLOOP.

* wenn nicht, evtl. steht der Cursor auf einer gültigen Zeile
  IF SY-SUBRC > 0.
    PERFORM XVBAP_MARKIEREN(SAPFV45P).
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
    IF SY-SUBRC > 0.
* Cursor steht auch nicht auf einer Zeile
      MESSAGE S323.
    ENDIF.
  ENDIF.

* gültige Zeile am Wickel
  IF SY-SUBRC = 0.

    PERFORM FCODE_POTE_U0.

    ORDCHG_TAB[] = ORDTAB[].
    REFRESH ORDTAB.
    LOOP AT ORDCHG_TAB.
* Positionierung weitere Position
      PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING ORDCHG_TAB-VBELP
                                                 SVBAP-TABIX.
      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

* Lesen der Bedarfsklasse, ob es erlaubt ist den Kalkulationswert
* zu übernehmen (MNTKAL).
      PERFORM T459A_SELECT(SAPMV45A) USING VBAP-BEDAE
                                           CHARX
                                           SY-SUBRC.
      PERFORM T459K_SELECT(SAPFV45V) USING T459A-BEDAR
                                           CHARX
                                           SY-SUBRC.

      PERFORM XVBEP_LESEN_ERSTE(SAPFV45E) USING SPACE.
      VBEP = XVBEP.
      DA_MBDAT_ERSTE = VBEP-MBDAT.  " Wunschliefertermin

* Kosten übernehmen, wenn der Wert > 0 und es erwünscht
* ist (Bedarfsklasse)
      IF ORDCHG_TAB-PWERT > 0 AND
         T459K-MNTKAL IS INITIAL AND
         TVAP-PRSFD EQ CHARX.
        DA_PWERT     =  ORDCHG_TAB-PWERT / ORDCHG_TAB-MENGE.
        DA_PWERT     =  DA_PWERT     * VBAP-KWMENG * VBAP-UMVKZ
                                     / VBAP-UMVKN.
        PERFORM KALKULATIONSWERT_UEBERNEHMEN(SAPFV45P)
                USING ORDCHG_TAB-WAERS
                      DA_PWERT
                      DA_FWFIX
                      VBAP-MEINS
                      SPACE.
      ENDIF.

* Fakturierungsplan aktualisieren (aus Meilensteinen)
* wenn zur Position Einteilungen mit Netzplan existieren
      IF NOT VBEP-AUFNR IS INITIAL.
        IF VBAP-FKREL EQ CON_FKREL_FPLAN OR
         ( VBAP-FKREL IS INITIAL AND   "oder Angebote
           NOT TVAP-FPART IS INITIAL ).
          PERFORM T003O_SELECT(SAPMV45A) USING T459K-AUART
                                               CHARX
                                               SY-SUBRC.
          IF T003O-AUTYP = NETZ.
            PERFORM FPLAN_AKTUALISIEREN(SAPMV45A)
                    USING VBAP-POSNR VBAP-POSNR SPACE.
          ENDIF.
        ENDIF.
      ENDIF.

* Verfügbarkeitsprüfung
      VBAP_ENDE_BEARBEITUNG = CHARX.
      IF DA_MBDAT_ERSTE GT ORDCHG_TAB-GSBTR.
        ORDCHG_TAB-GSBTR = DA_MBDAT_ERSTE.
      ENDIF.
      PERFORM ERGEBNIS_AN_VERFUEGBARKEIT(SAPFV45E)
              USING ORDCHG_TAB-MENGE
                    ORDCHG_TAB-GSBTR
                    ORDCHG_TAB-MENGE_NULL
                    VBEP-MBDAT
                    VBEP-BNFPO
                    VBEP-AUFNR
                    VBEP-PLNUM.
      PERFORM VBAP_BEARBEITEN(SAPFV45P).
      PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
    ENDLOOP.

    PERFORM XVBAP_UEBERSICHT_ANSTEUERN(SAPFV45P).

  ENDIF.

  T185F-FCODE = FCODE_ZURUECK2.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.