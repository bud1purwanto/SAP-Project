*---------------------------------------------------------------------*
*       FORM FCODE_BVFP                                               *
*---------------------------------------------------------------------*
*       Verfügbarkeitsprüfung für den Gesamt-Beleg                    *
*       Bei Product Selection nur für die Hauptpositionen, da die     *
*       Unterpositionen durch das Ergebnis der Verf.prf entstanden sind
*---------------------------------------------------------------------*
FORM FCODE_BVFP.

  DATA:
    DA_PREISFINDUNG_GESAMT,
    DA_RESTMENGE  LIKE VBAP-KWMENG,
    DA_RESTMENGEV LIKE VBAP-KWMENG.

  LOOP AT XVBAP WHERE UPDKZ <> UPDKZ_DELETE
                  AND UEPVW <> CHARA
                  AND PVPOS IS INITIAL.
    SVBAP-TABIX = SY-TABIX.

*   Rückstandsauflösung faßt fixierte Positionen nicht an, aber
*   Kreditfreigabe und -prüfung schon
    IF NOT CALL_FUNCTION IS INITIAL AND
       CALL_ACTIVITY NE GC_ACTIVITY_LORD AND
       VBUK_KREDIT_VFP   IS INITIAL      and
       call_bapi         is initial.
      CHECK XVBAP-FIXMG IS INITIAL.
    ENDIF.

*   Im Kreditfall wird die Verfügbarkeitsprüfung nur dann durchgeführt,
*   wenn die kumulierte bestätigte Menge 0 ist oder nicht groesser
*   als die Summe der gelieferten Menge ist
*   Dies gilt nicht für product selection. Hier wird immer eine VFP
*   durchgeführt (kein Tuning im Moment).
    IF NOT VBUK_KREDIT_VFP IS INITIAL.
      PERFORM USEREXIT_AVAIL_CHECK_CREDIT USING    VBAK
                                                   XVBUK
                                                   XVBAP
                                                   VBUK_FREIGABE
                                                   VBUK_RECHECK
                                          CHANGING SY-SUBRC.
      IF SY-SUBRC EQ 0.
*       Availibility check in any case
      ELSEIF SY-SUBRC EQ 4.
*       Availibility check like standard
*       no ATP if there is open (not delivered) confirmed quantity
        IF XVBAP-KBMENG NE 0
        OR XVBAP-LSMENG EQ 0.
          IF XVBAPF-VBELN NE XVBAP-VBELN
          OR XVBAPF-POSNR NE XVBAP-POSNR.
            CLEAR XVBAPF.
            READ TABLE XVBAPF WITH KEY VBELN = XVBAP-VBELN
                                       POSNR = XVBAP-POSNR
                              BINARY SEARCH.
          ENDIF.
          IF XVBAP-KZFME IS INITIAL.
            DA_RESTMENGE  = XVBAP-KBMENG * XVBAP-UMVKZ / XVBAP-UMVKN
                          - XVBAPF-ERLMENGE_L * QUAN_1.
            DA_RESTMENGEV = XVBAP-KBMENG
                          - XVBAPF-ERLMENGE_L * QUAN_1
                          * XVBAP-UMVKN / XVBAP-UMVKZ.
          ELSE.
            DA_RESTMENGEV = XVBAP-KBMENG
                          - XVBAPF-ERLMENGELV * QUAN_1.
            DA_RESTMENGE  = ( XVBAP-KBMENG
                            - XVBAPF-ERLMENGELV * QUAN_1 )
                          * XVBAP-UMVKZ / XVBAP-UMVKN.
          ENDIF.
          CHECK DA_RESTMENGE  LE 0
          OR    DA_RESTMENGEV LE 0
          OR    XVBAP-PROSA   NE SPACE
          OR    VBAK-ABDIS    NE SPACE.
        ENDIF.
      ELSEIF SY-SUBRC EQ 8.
*       Availibility check in no case
        IF NOT XVBAP-FIXMG IS INITIAL.
          CLEAR VBUK_KREDIT_VFP.
          PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
          PERFORM VBAP_FUELLEN(SAPFV45P).
          PERFORM VBAP-LSMENG_ERMITTELN(SAPFV45P).
          IF VBAP-LSMENG NE *VBAP-LSMENG.
            PERFORM VBAP_BEARBEITEN(SAPFV45P).
          ENDIF.
          VBUK_KREDIT_VFP = CHARX.
        ENDIF.
        CONTINUE.
      ENDIF.
    ENDIF.

    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

*   Bei Product Selection und Kredit muß PRICING_COMPLETE laufen,
*   um Gruppenkonditionen korrekt zu ermitteln, da NEUE UPs entstanden
*   sind. Abfrage sucht HPs, die neue UPs erzeugt, die PF-relevant sind
    IF  VBUK_KREDIT_VFP NE SPACE
    AND XVBAP-PROSA     EQ CHARA
    AND ( TVAP-PRSFD IS INITIAL OR XVBAP-KOWRR IS NOT INITIAL ).
      DA_PREISFINDUNG_GESAMT = CHARX.
    ENDIF.

*   Wenn bei Kreditfreigabe Preisfindung Position läuft wegen
*   Kalkulation oder Montage, muss danach auch PRICING_COMPLETE laufen, um alle
*   Steuern korrekt zu ermitteln.
    IF  VBUK_KREDIT_VFP NE SPACE
    AND ( T459K-AUCOST  CA AUCOST_KALKULIEREN
    OR   T459K-MNTGA = MOFAUF ).
      DA_PREISFINDUNG_GESAMT = CHARX.
    ENDIF.

    PERFORM FCODE_PORE.

  ENDLOOP.

* Ergebnisse der Gruppenverfügbarkeitsprüfung abholen
  IF ATP_GRUPPENAUFRUF EQ CHARX.
    IF ATP_BASIC_SETTING-GRP_CALL_FUN EQ CHARX AND
       CALL_FUNCTION EQ CHARX.
      PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P)
        USING VERARB_DUNKEL.
    ELSEIF ATP_BASIC_SETTING-GRP_BDC_BACK EQ CHARX AND
       SY-BATCH EQ CHARX.
      PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P)
        USING VERARB_DUNKEL.
    ELSE.
      PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P)
        USING VERARB_HELL.
    ENDIF.
  ENDIF.

  IF DA_PREISFINDUNG_GESAMT EQ CHARX.
    PERFORM PREISFINDUNG_GESAMT USING CHARA.
  ENDIF.

ENDFORM.                    "FCODE_BVFP