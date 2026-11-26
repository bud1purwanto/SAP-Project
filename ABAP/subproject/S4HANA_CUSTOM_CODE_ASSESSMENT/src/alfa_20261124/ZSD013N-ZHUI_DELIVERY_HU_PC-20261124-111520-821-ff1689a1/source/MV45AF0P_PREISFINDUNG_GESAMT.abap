*----------------------------------------------------------------------*
*          FORM PREISFINDUNG_GESAMT                                    *
*----------------------------------------------------------------------*
* Es wird der gesamte Beleg bewertet                                   *
*----------------------------------------------------------------------*
FORM PREISFINDUNG_GESAMT USING PREISFINDUNGSART_KOPF.

  LOCAL: VBAP, *VBAP, SVBAP.
  DATA: DA_PRELIM(1).
  DATA: DA_ABSAGEN(1) TYPE C.
  DATA: DA_GRPOS LIKE VBAP-GRPOS.
  DATA: DA_KONTENFINDUNG(1) TYPE C.
  DATA: FM_ACTIVE.
  DATA: DA_CMPRE LIKE VBAP-CMPRE,
        DA_CMPRE_FLT LIKE VBAP-CMPRE_FLT,
        DA_MWSBP LIKE VBAP-MWSBP.

  LOCAL: VBKD, *VBKD, SVBKD,
         XVBKD-UPDKZ.

  CHECK MODIFICATION_FLAG-NO_PRICING IS INITIAL.
* Nicht bei ATP-relevanten CALL's (Neuterminierung; Rückstandsbearb.)
  IF CALL_FUNCTION NE SPACE AND
     PRODSEL_AKTIV EQ SPACE.
    CHECK CALL_ACTIVITY NE ACTIVITY_ATP_AREA.
  ENDIF.

* Nicht bei Sortimenten
  CHECK VBAK-VBTYP NE CHARD.
  IF PREISFINDUNGSART_KOPF CA 'BC'.
    DA_PRELIM = 'X'.
  ENDIF.
  IF T180-TRTYP NE CHARA.
    VBAK-NETWR = 0.
  ENDIF.
* Tabelle TKOMP aufbauen
  REFRESH TKOMP.
  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                  AND POSAR NE CHARB
                  AND PVPOS IS INITIAL.
    SVBAP-TABIX = SY-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).


ENHANCEMENT-POINT PREISFINDUNG_GESAMT_22 SPOTS ES_SAPMV45A.



    PERFORM PREISFINDUNG_VORBEREITEN(SAPFV45P) USING 'P'.
    TKOMP-IX_VBAP = SVBAP-TABIX.
    APPEND TKOMP.
  ENDLOOP.
ENHANCEMENT-POINT PREISFINDUNG_GESAMT_16 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT PREISFINDUNG_GESAMT_15 SPOTS ES_SAPMV45A.


ENHANCEMENT-POINT PREISFINDUNG_GESAMT_10 SPOTS ES_SAPMV45A.

* Preisfindung aufrufen
ENHANCEMENT-SECTION     PREISFINDUNG_GESAMT_12 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'PRICING_COMPLETE'
    EXPORTING
      CALCULATION_TYPE = PREISFINDUNGSART_KOPF
      PRELIMINARY      = DA_PRELIM
    TABLES
      TKOMV            = XKOMV
      TKOMK            = TKOMK
      TKOMP            = TKOMP
      SVBAP            = UVBAP.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT PREISFINDUNG_GESAMT_13 SPOTS ES_SAPMV45A.

* Ergebnis der Preisfindung an XVBAP zurueckgeben
  IF T180-TRTYP NE CHARA.
    LOOP AT TKOMP.
*   die zugehörige TKOMK lesen
      READ TABLE TKOMK INDEX TKOMP-IX_KOMK.
      IF TKOMP-FXMSG NE SPACE.
        R185D-DATALOSS = CHARX.
        KONV_GEAENDERT = CHARX.
      ENDIF.
      READ TABLE XVBAP INDEX TKOMP-IX_VBAP.
      SVBAP-TABIX = TKOMP-IX_VBAP.
      VBAP = XVBAP.
      PERFORM KOMPAX_FILL_FROM_KOMP(SAPLV61A)
        USING    TKOMP
                 VBAP-CMPRE_FLT
        CHANGING KOMPAX.
* correct the gross value of the item
      IF KOMPAX-BRTWR NE XVBAP-BRTWR.
         XVBAP-BRTWR = KOMPAX-BRTWR.
         MODIFY TABLE XVBAP TRANSPORTING BRTWR.
      ENDIF.
*   Hauptposition merken / für Nettowertberechnung Kopf
      HVBAP = VBAP.
      WHILE HVBAP-UEPOS > 0 AND
            HVBAP-GRPOS = 0.
        PERFORM HVBAP_LESEN(SAPFV45P) USING HVBAP-UEPOS.
      ENDWHILE.
      DA_GRPOS = HVBAP-GRPOS.
* TVAP muss nachgelesen werden falls TVAP-PSTYV NE VBAP-PSTYV
      IF TVAP-PSTYV NE VBAP-PSTYV.
        PERFORM TVAP_SELECT(SAPMV45A) USING VBAP-PSTYV
                                            SPACE
                                            SY-SUBRC.
      ENDIF.

      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
      CLEAR DA_KONTENFINDUNG.

* BADI_SD_TO_FM, set FLAG_PS_FM if T001-XFMCA is set
      CLEAR FM_ACTIVE.
      CALL FUNCTION 'GET_HANDLE_SD_TO_FM'
        IMPORTING
          ACTIVE = ACTIVE_BADI_SD_TO_FM.
      IF ACTIVE_BADI_SD_TO_FM EQ CHARX.
ENHANCEMENT-SECTION     PREISFINDUNG_GESAMT_18 SPOTS ES_SAPMV45A.
        CALL FUNCTION 'FMFK_GET_BUKRS_AKTIV_FLAGS'
          EXPORTING
            IP_BUKRS           = VBAK-BUKRS_VF
          IMPORTING
            OP_XFMCA           = FM_ACTIVE
          EXCEPTIONS
            NO_FIKRS_FOR_BUKRS = 1
            BUKRS_NOT_FOUND    = 2.
END-ENHANCEMENT-SECTION.
      ENDIF.




      IF TKOMP-FXMSG NE SPACE OR XVBAP-KZVBR      = KZVBR_P OR
                                 XVBAP-KZVBR      = KZVBR_E OR
                             NOT XVBAP-AUFNR      IS INITIAL OR
                             NOT XVBAP-PS_PSP_PNR IS INITIAL OR
* start Revenue Recognition Project
* added another or to this if statement for rev. rec. type
                             NOT XVBKD-RRREL IS INITIAL OR
* end Revenue Recognition Project
* new case for Public Sector --> Fondsmanagement
                           ( NOT FM_ACTIVE IS INITIAL
                             AND NOT TVAP-FKREL EQ CON_FKREL_NO
                             AND NOT TVAP-FKREL EQ CON_FKREL_PROFORMA ).

        DA_KONTENFINDUNG = CHARX.
        IF TKOMP-FXMSG NE SPACE OR
           NOT XVBKD-RRREL IS INITIAL.
         IF SVBKD-TABIX NE 0.
          IF VBAP-FKREL EQ CON_FKREL_FPLAN OR
             ( VBAP-FKREL IS INITIAL AND             "oder Angebote
               NOT TVAP-FPART IS INITIAL ).
*           Aufruf Aktualisieren Fakturawerte
            PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING VBAP-POSNR
                                                       SVBKD-TABIX.
            IF NOT VBKD-FPLNR IS INITIAL.
* Bereitstellen der fakturierten Termine
              DATA: BEGIN OF TFPLTS OCCURS 10.
                      INCLUDE STRUCTURE FPLTS.
              DATA: END   OF TFPLTS.
              READ TABLE XVBFA WITH KEY MANDT = SY-MANDT
                                        VBELV = VBAP-VBELN
                                       POSNV = VBAP-POSNR BINARY SEARCH.
              IF SY-SUBRC EQ 0.
                LOOP AT XVBFA FROM SY-TABIX.
                  IF XVBFA-VBELV NE VBAP-VBELN OR
                    XVBFA-POSNV NE VBAP-POSNR.
                    EXIT.
                  ENDIF.
                  IF XVBFA-FPLNR EQ VBKD-FPLNR.
                    MOVE-CORRESPONDING XVBFA TO TFPLTS.
                    APPEND TFPLTS.
                    INCLUDE BADI_SD_DPBP_FILL_TFPLTS_3.
                  ENDIF.
                ENDLOOP.
              ENDIF.
*           Wenn ein Absagegrund eingegeben wurde, der fakturarelevant
*           ist, dann muß dies dem Fakturierungsplan mitgegeben werden
              CLEAR DA_ABSAGEN.
              IF NOT VBAP-ABGRU IS INITIAL.
                PERFORM TVAG_SELECT USING VBAP-ABGRU
                                          TVAG-DRAGR
                                          SPACE
                                          SY-SUBRC.
                PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                                CHANGING DA_ABSAGEN.
              ENDIF.
*             Fuellen Anwendungsdaten
              MOVE-CORRESPONDING VBAK TO FPLAA.
              MOVE-CORRESPONDING VBAP TO FPLAA.
              MOVE VBAK-WAERK         TO FPLAA-WAERK.
              MOVE *VBAK-WAERK        TO FPLAA-WAERK_ALT.
              MOVE EURO_WAERS         TO FPLAA-EURO.
              MOVE VBAP-KWMENG        TO FPLAA-MENGE.
              IF FPLAA-MENGE IS INITIAL.
                MOVE VBAP-ZMENG       TO FPLAA-MENGE.
              ENDIF.
              IF VBAP-NETWR EQ KOMPAX-NETWR.
               DA_CMPRE = KOMPAX-CMPRE.
               DA_CMPRE_FLT = KOMPAX-CMPRE_FLT.
               DA_MWSBP = KOMPAX-MWSBP.
              ENDIF.

              CALL FUNCTION 'BILLING_SCHEDULE_INVOICE_VALUE'
                EXPORTING
                  I_FPLNR            = VBKD-FPLNR
                  I_WAERS            = VBAP-WAERK
                  I_UPD_FPLA         = UPD_FPLA
                  I_UPD_FPLT         = UPD_FPLT
                  I_KOMK             = TKOMK
                  I_KOMP             = TKOMP
                  I_KOMPAX           = KOMPAX
                  I_PREISFINDUNGSART = PREISFINDUNGSART_KOPF
                  I_ABSAGEN          = DA_ABSAGEN
                  I_NOMSG            = CHARX
                  I_FPLAA            = FPLAA
                IMPORTING
                  E_UPD_FPLA         = UPD_FPLA
                  E_UPD_FPLT         = UPD_FPLT
                  E_KOMPAX           = KOMPAX
                TABLES
                  FPLA_NEW           = XFPLA
                  FPLA_OLD           = YFPLA
                  FPLT_NEW           = XFPLT
                  FPLT_OLD           = YFPLT
                  I_KOMV             = XKOMV
                  I_TKOMK            = TKOMK
                  I_FPLTS            = TFPLTS
                  I_SVBAP            = UVBAP.
              MOVE-CORRESPONDING KOMPAX TO TKOMP.
            ENDIF.
          ENDIF.
         ENDIF.
          MOVE-CORRESPONDING KOMPAX TO VBAP.
          IF NOT DA_CMPRE IS INITIAL.
           VBAP-CMPRE = DA_CMPRE.
           VBAP-CMPRE_FLT = DA_CMPRE_FLT.
           VBAP-MWSBP = DA_MWSBP.
           CLEAR DA_CMPRE.
           CLEAR DA_CMPRE_FLT.
           CLEAR DA_MWSBP.
          ENDIF.

          PERFORM VBKD_BEARBEITEN_ZTERM(SAPFV45K)
                  USING TKOMP-ZTERM TKOMP-VALDT TKOMP-VALTG.
        ENDIF.
      ENDIF.

* call function only if pricing has been processed

ENHANCEMENT-SECTION     PREISFINDUNG_GESAMT_20 SPOTS ES_SAPMV45A.
      IF TKOMP-FXMSG NE SPACE.

* Praeferenzkennzeichen setzen

        CALL FUNCTION 'PREFERENCE_DETERMINE_SD'             " HW 379619
             EXPORTING                                      " HW 379619
                  I_DEPARTURE_COUNTRY    = TKOMK-ALAND      " HW 379619
                  I_DESTINATION_COUNTRY  = TKOMK-LAND1      " HW 379619
                  I_PREFERENCE_ZONE      = TKOMK-GZOLX      " HW 379619
                  I_MATERIAL_NUMBER      = TKOMP-MATNR      " HW 379619
                  I_PLANT                = TKOMP-WERKS      " HW 379619
                  I_PREFERENCE_VALUE     = TKOMP-PREVA      " HW 379619
                  I_NET_VALUE            = TKOMP-NETWR      " HW 379619
             CHANGING                                       " HW 379619
                  C_PREFERENCE_INDICATOR = VBAP-PREFE       " HW 379619
             EXCEPTIONS                                     " HW 379619
                  OTHERS                 = 1.               " HW 379619
      ENDIF.
END-ENHANCEMENT-SECTION.

*     LOG&TRM Integration
*     Determine TRM Relevance
      IF cl_ops_switch_check=>log_sfws_trm_int_01( ) = abap_true.
*       Logistic documents will send their commodity exposure to the
*       Treasury and Risk Management [FIN-FSCM-TRM]
        PERFORM vbap_trm_integration IN PROGRAM SAPFV45P.
      ENDIF.

      IF VBAP NE *VBAP.
        PERFORM VBAP_BEARBEITEN(SAPFV45P).
* VBAP_BEARBEITEN_ENDE wird hier nicht komplett aufgerufen
* Belegfluß und Status und Unvollständigkeit pflegen
        PERFORM VBAP_PRUEFEN_VOLLST(SAPFV45P) USING SPACE.
        PERFORM userexit_check_vbap USING space.
        PERFORM XVBFA_PFLEGEN(SAPFV45C) USING CHARV.
        PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
        PERFORM XVBUP_PFLEGEN_VORGAENGER(SAPFV45P).
      ENDIF.
      IF DA_KONTENFINDUNG = CHARX.
        PERFORM KONTENFINDUNG(SAPFV45P) USING SPACE.
      ENDIF.

      IF VBAP-KOWRR = SPACE AND
         TVAP-KOWRR IS INITIAL AND
         DA_GRPOS = 0.
        VBAK-NETWR = VBAK-NETWR + VBAP-NETWR.
      ENDIF.
    ENDLOOP.
* Wenn sich vbak-netwr geändert hat: Änderungsdatum fortschreiben
    IF T180-TRTYP EQ CHARV
      AND VBAK-NETWR NE *VBAK-NETWR.
      VBAK-AEDAT = SY-DATUM.
    ENDIF.

    IF NOT TVAK-FPART IS INITIAL.
      DATA: DA_FPLNR LIKE VBKD-FPLNR.  "Kopffakturierungsplannummer
*     Kopffakturierungsplan erwünscht
*     Kopf-VBKD lesen
      PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                                 SVBKD-TABIX.
      DA_FPLNR = XVBKD-FPLNR.
      IF NOT XVBKD-FPLNR IS INITIAL.
*       Aktualisieren Kopffakturierungsplan bzgl. Fakturawert
        PERFORM FPLAN_SUMMEN_ERMITTELN CHANGING KOMPAX.
*       Fuellen Anwendungsdaten
        MOVE-CORRESPONDING VBAK TO FPLAA.
        MOVE VBAK-WAERK         TO FPLAA-WAERK.
        MOVE *VBAK-WAERK        TO FPLAA-WAERK_ALT.
        MOVE EURO_WAERS         TO FPLAA-EURO.
        CALL FUNCTION 'BILLING_SCHEDULE_INVOICE_VALUE'
          EXPORTING
            I_FPLNR            = DA_FPLNR
            I_WAERS            = VBAK-WAERK
            I_UPD_FPLA         = UPD_FPLA
            I_UPD_FPLT         = UPD_FPLT
            I_KOMPAX           = KOMPAX
            I_PREISFINDUNGSART = PREISFINDUNGSART_KOPF
            I_KFPLAN           = CHARA
            I_NOMSG            = CHARX
            I_FPLAA            = FPLAA
          IMPORTING
            E_UPD_FPLA         = UPD_FPLA
            E_UPD_FPLT         = UPD_FPLT
          TABLES
            FPLA_NEW           = XFPLA
            FPLA_OLD           = YFPLA
            FPLT_NEW           = XFPLT
            FPLT_OLD           = YFPLT.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "PREISFINDUNG_GESAMT

*----------------------------------------------------------------------*
*          FORM PREISFINDUNG_GESAMT_BELEG_ENDE                         *
*----------------------------------------------------------------------*
* Aufruf der Gesamtpreisfindung aus der Beleg-Ende-Bearbeitung         *
*----------------------------------------------------------------------*
FORM PREISFINDUNG_GESAMT_BELEG_ENDE.

* Falls es eine Position p mit einem Konditionswert gibt,
* der vom Konditionswert einer anderen Position abhängt,
* wird die Preisfindung mit Preisfindungsart P aufgerufen,
* wenn die andere Position geändert oder gelöscht wurde,
* da in diesem Fall der Konditionswert von p aktualisiert werden muss.
  IF POS_GEAENDERT EQ CHARX.
    READ TABLE XKOMV WITH KEY KOUPD = CHARX TRANSPORTING NO FIELDS.
    IF SY-SUBRC EQ 0.
      PERFORM PREISFINDUNG_GESAMT USING CHARP.
    ELSE.
      PERFORM PREISFINDUNG_GESAMT USING CHARA.
    ENDIF.
  ELSE.
    PERFORM PREISFINDUNG_GESAMT USING CHARA.
  ENDIF.

ENDFORM.                    "PREISFINDUNG_GESAMT_BELEG_ENDE