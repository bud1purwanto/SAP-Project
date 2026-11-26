*---------------------------------------------------------------------*
*       FORM BELEG_BEARBEITEN_ENDE                                    *
*---------------------------------------------------------------------*
*       Endrunde der Belegverarbeitung                                *
*       Die Routine wird vor dem Buchen aufgerufen                    *
*---------------------------------------------------------------------*
FORM BELEG_BEARBEITEN_ENDE USING DA_SUBRC.

  DATA: DA_XVBUV_BERUECKSICHTIGEN.
  DATA: DA_CHANGE.
  DATA: DA_WERT, DA_ANSWER.
  DATA: DA_LINES LIKE SY-TFILL.
  DATA: DA_POSNR LIKE VBAP-POSNR.

  clear: us_vbapkom, us_vbapkomx.

  DA_POSNR = VBAP-POSNR.

  IF XVBAK_UPDKZ NE UPDKZ_DELETE.
* Gruppenaufruf Verfuegbarkeit (Dunkel)
    PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P)
                                    USING VERARB_DUNKEL.

    IF VBAK-VGTYP CA VBTYP_LP AND
       VBAK-VBTYP CA VBTYP_RETOUR.
      PERFORM KORREKTURLIEFERUNG_HINWEIS(SAPFV45L).
    ENDIF.

    IF NOT VBAK-ABDIS IS INITIAL.
      PERFORM ABRUF_PRUEFEN_ENDE(SAPFV45L).
* Prüfen ob in Abrufeinteilungen das Wunschlieferdatum gehalten werden
* kann.
      PERFORM REQUESTED_DELIVERY_DATE_CHECK(SAPFV45E).
    ENDIF.

    ENHANCEMENT-POINT BELEG_BEARBEITEN_ENDE_10 SPOTS ES_SAPMV45A.
* Verpackungsvorschlag im Auslieferungsauftrag kopieren aus dem
* Lieferplan, wenn im Auslieferungsauftrag nicht verpackt wurde
    PERFORM PACKING_DATA_COPY_MAIS.
* Die Datenübergabe aus der Veda läuft zwar auch im Fcode-Modul, aber
* wegen Call-Function-Auftragsbearbeitung (ohne Bilder) muß sie auch
* am Schluß laufen.
    PERFORM VBAK_UPDATE_FROM_VEDA(SAPFV45K).

* Aufruf der Kalkulation, weil eventuell automatisch im Dunkeln
* kalkuliert werden muß.
    PERFORM KALKULATION_BEARBEITEN_ENDE(SAPFV45P).

    PERFORM PREISFINDUNG_GESAMT_BELEG_ENDE.
    G_PRICING_COMPLETE = 'X'.

* Prüfen Konfiguration und setzen STMAN für Bedarfsübergabe
    PERFORM CONFIGURATION_REQUIREMENT_CHK(SAPFV45S).

*--------Beginn_RV_AUSFUHRGENEHMIGUNG_PRUEFUNG-------------------------*
    IF MODIFICATION_FLAG-NO_EXPORT_CONTROL IS INITIAL.
      IF TVAK-EXCOK NE SPACE.
        PERFORM EXPORT_AUSFUHR USING ' '.
      ENDIF.
    ENDIF.
*--------Ende___RV_AUSFUHRGENEHMIGUNG_PRUEFUNG-------------------------*

* Auftragswahrscheinlichkeit des Kopfes
    PERFORM VBAK-AWAHR_ERMITTELN(SAPFV45K).
* Falls Positionen, die gemäß FaktPlan faktueriert werden sollen,
* bis jetzt noch keinen FaktPlan besitzen, wird versucht, einen zu
* erzeugen
    LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                    AND PVPOS IS INITIAL.
      SVBAP-TABIX = SY-TABIX.
      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
*     Wenn Position fakturarelvant gemäß Fakturierungsplan
      IF XVBAP-FKREL EQ CON_FKREL_FPLAN OR
        ( XVBAP-FKREL IS INITIAL AND   "oder Angebote
          NOT TVAP-FPART IS INITIAL ).
*     Für Wertkontrakt-Zielwert: Bei Konditionsänderung auf Kond.-Bild
*     und anschließendem Sichern aus Pos.-Detailbild ohne vorher auf
*     Übersicht zu gehen --> Kondition muß in VBAP-ZWERT gestellt werden
        PERFORM XKOMV_LESEN(SAPFV45P).

        PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING XVBAP-POSNR
                                                   SVBKD-TABIX.
        IF XVBKD-POSNR EQ POSNR_LOW OR "es gibt noch keine VBKD-Pos
        (  XVBKD-POSNR EQ XVBAP-POSNR AND
           XVBKD-FPLNR IS INITIAL ).   "kein FaktPlan auf Position
*         Fakturierungsplan aktualisieren
          PERFORM FPLAN_AKTUALISIEREN USING XVBAP-POSNR XVBAP-POSNR
                                         SPACE.   "XVEDA nicht aktuell
        ENDIF.
      ENDIF.
      PERFORM XVBUP_PFLEGEN_AKTUELL(SAPFV45P).
    ENDLOOP.
*   Es muß sichergestellt werden, daß bei einem wertmäßigen Kopf-
*   fakturierungsplan, der aktuelle Stand der Positionsfakturierungs-
*   pläne gesichert wird, d.h. es werden alle Werte aus dem Kopf
*   erneut verteilt werden.

    PERFORM FPLAN_POS_WERT_VERTEILEN USING CHARX.

* Prüfen des Kreditlimits
    PERFORM KREDITLIMIT_PRUEFEN(SAPFV45K) USING CHARX.
* Berechnen der Gesamtwahrscheinlichkeit
    PERFORM VBAK-AWAHR_ERMITTELN(SAPFV45K).
    PERFORM KOPFSUMMEN_BILDEN(SAPFV45K).

* Automatische Serialnummernvergabe
    PERFORM AUTOMATISCHE_SERIALNUMMERN.

* Authorisierung
* Now user can interrupt the save proc. if authorisation is failed
    PERFORM ZAHLUNGSKARTEN_AUTHORISIEREN USING DA_SUBRC.

* Automatische Kreditlimitprüfung
*   Prüfung und Setzen Status
    PERFORM CREDITCHECK USING CHARX SPACE
                        CHANGING KVBUK.
    if call_activity eq gc_activity_lord.
      if not gf_saving_abort is initial.
        clear gf_saving_abort.
        da_subrc = 4.
        exit.
      endif.
    endif.
    PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.

* Letzte Prüfungen Beschaffung (Montage, Strecke)
    IF CALL_ACTIVITY NE ACTIVITY_PURCHASE.
      PERFORM BESCHAFFUNG_PRUEFEN_ENDE(SAPFV45E).
* Leave if obligo error occured
      PERFORM obligo_protocol(sapfv45e) CHANGING da_subrc.
      IF NOT da_subrc IS INITIAL and
         call_function is initial.
            if call_activity eq gc_activity_lord.
              exit.
            endif.
             FCODE = FCODE_GLEICHE_SEITE.
             PERFORM FCODE_BEARBEITEN.
             EXIT.
          ENDIF.
* Ermitteln ALE-Positionen und zwischenspeichern in interner Tabelle
* im Änderungsfall
      IF T180-TRTYP NE CHARA.
        PERFORM ALE_POS_ERMITTELN.
      ENDIF.
    ELSE.
* Bestätigte Termine aus Bestellung in Banf uebernehmen
      PERFORM BESCHAFFUNG_FIXIEREN_ALLE(SAPFV45E).
    ENDIF.

* Liefergruppen korrelieren
    PERFORM LIEFERGRUPPENDATUM_SETZEN(SAPFV45V) USING VERARB_IMMER.
*   Verhindern von rekursiven Aufrufen bei Korrelation in KDAUF:
*   Gefahr gebannt.
    FREE MEMORY ID 'RueckBelPos1'.

* Zusagedaten aktualisieren
    PERFORM VBEP_ZUSAGE_ERMITTELN(SAPFV45E) USING VBAK-VBELN
                                                  POSNR_LOW.

* Wenn das Sperrkennzeichen sitzt, müssen evtl. Einteilungen und Bedarfe
* gelöscht werden
    PERFORM BEDARF_AENDERN_BEI_SPERRE(SAPFV45V).

* Falls zwischendurch Einzelpreisfindung lief
    IF G_PRICING_COMPLETE IS INITIAL.
      PERFORM PREISFINDUNG_GESAMT_BELEG_ENDE.
    ENDIF.

* Im Beleg Sichern werden Daten geändert, die das BAPI nicht mitbekommt.
* Wenn BAPI-Modus aktiv , dann werden die Daten gefüllt.
    IF BAPICALL = CHARB.
      PERFORM XVBPA_CORRECT.
      PERFORM BAPIDATEN_FUELLEN.
    ENDIF.

  ELSE.
   BEDARF_TRENNEN = 'X'.
  ENDIF.

* Schnittstelle APO füllen
  REFRESH X_SDFIELDS.
  PERFORM CATALOGUE_EXTRACT(SAPFV45V).

* BADI_SD_TO_FM
  INCLUDE BADI_SD_TO_FM_CALL_S008.

* Status in evtl. an Position hängendem Serviceauftrag setzen
  PERFORM STATUS_SETZEN_SERVICE(SAPFV45P).

* Kopfstatus aktueller Beleg und Vorgänger ermitteln
  IF MODIFICATION_FLAG-NO_DOCUMENT_HEADER_CHECK IS INITIAL.
    DA_XVBUV_BERUECKSICHTIGEN = CHARX.
  ENDIF.
  CALL FUNCTION 'RV_XVBUK_MAINTAIN'
    EXPORTING
      F_VBELN                  = VBAK-VBELN
      F_VBTYP                  = VBAK-VBTYP
      F_XVBUV_BERUECKSICHTIGEN = DA_XVBUV_BERUECKSICHTIGEN
      F_VBAK                   = VBAK
    IMPORTING
      E_VBUK_CHANGE            = DA_CHANGE
    TABLES
      FXVBUP                   = XVBUP
      FXVBUK                   = XVBUK
      FXVBUV                   = XVBUV
      FYVBUK                   = YVBUK.
  IF NOT DA_CHANGE IS INITIAL.
    UPD_VBUK = CHARU.
  ENDIF.

  IF XVBAK_UPDKZ = UPDKZ_DELETE.
    CALL FUNCTION 'RV_XVBUK_DELETE'
      EXPORTING
        F_VBELN = VBAK-VBELN
      TABLES
        FXVBUK  = XVBUK
        FYVBUK  = YVBUK.
  ENDIF.

  PERFORM XVBUK_LESEN(SAPFV45K) USING VBAK-VBELN.

* Unvollständigkeitsdialog für EDI Warnungssammeln
  DESCRIBE TABLE XVBUV LINES DA_LINES.

  IF DA_LINES > 0 AND
     SY-BINPT NE SPACE AND
     BI_INFO-CTU_AMODUS NA 'A' AND
     CATTAKTIV IS INITIAL.
    MESSAGE I555.
  ENDIF.

  IF MODIFICATION_FLAG-NO_OUTPUT_CONTROL IS INITIAL.
* Nachrichtenfindung für Positionen
    PERFORM NACHRICHTEN_POSITION.
* Nachrichtenfindung durchführen
    IF XVBAK_UPDKZ NE UPDKZ_DELETE.
      READ TABLE XVBKD INDEX 1.
      NA_VBKD = XVBKD.
* Get data of objectkey for output
      MOVE VBAK-VBELN TO XOBJKY.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV1'
        EXPORTING
          MSG_VBAK  = VBAK
          MSG_VBKD  = NA_VBKD
          MSG_VBUK  = VBUK
          MSG_TRTYP = T180-TRTYP
        TABLES
          TAB_PART  = PART
          TAB_VBPA  = XVBPA
          TAB_VBAP  = XVBAP.
      CALL FUNCTION 'MESSAGING'
        EXPORTING
          APPLIKATION = TVAK-KAPPL
          MSG_OBJKY   = XOBJKY
          SCHEMA      = TVAK-KALSM
          PI_OBJTYPE  = BUSINESSOBJEKT
        TABLES
          MSG_PART    = PART.
    ENDIF.
  ENDIF.

* Statistikdaten aufbereiten für Zulieferer
  IF NOT VBAK-ABDIS IS INITIAL.
    CALL FUNCTION 'SD_QUAN_VIS_DETERMINE_SUPPLIER'
      EXPORTING
        I_VBELN = VBAK-VBELN
      TABLES
        FSYVBEP = YVBEP
        FSXVBEP = XVBEP
        FSXVBAP = XVBAP
        FSVBEH  = XVBEH.
  ENDIF.

* Änderungsdatum VBAK aktualisieren
  IF T180-TRTYP EQ CHARV
     AND VBAK NE YVBAK.
    VBAK-AEDAT = SY-DATUM.
  ENDIF.

ENHANCEMENT-POINT BELEG_BEARBEITEN_ENDE_01 SPOTS ES_SAPMV45A.
  IF DA_POSNR NE VBAP-POSNR AND
     NOT DA_POSNR IS INITIAL.
    PERFORM XVBAP_LESEN_ALLGEMEIN(SAPFV45P) USING DA_POSNR
                                                  SPACE
                                               SVBAP-TABIX.
    MOVE-CORRESPONDING XVBAP TO VBAP.
    MOVE-CORRESPONDING XVBAP TO VBAPD.
  ENDIF.

* Perform last_check

  DATA:
   L_GJAHR LIKE FMIOI-GJAHR,
      BEGIN OF TRWIN OCCURS 5,
        FUNCTION LIKE TRWPR-FUNCTION,
      END OF TRWIN.
  L_GJAHR = SY-DATUM(4).

  CALL FUNCTION 'RWIN_CHECK'
    EXPORTING
      GJAHR   = L_GJAHR
      PROCESS = 'AVC     '
      EVENT   = 'PRUEFEN'
    TABLES
      TKOMP   = TRWIN
    EXCEPTIONS
      OTHERS  = 0.
  LOOP AT TRWIN.
    CALL FUNCTION TRWIN-FUNCTION
      EXPORTING
        I_AWTYP = 'VBRK'.
  ENDLOOP.


* Get the errors for SD
* Set up the error level before sending
  DATA: LT_MESG  TYPE STANDARD TABLE OF MESG INITIAL SIZE 10,
          LS_MESG  LIKE LINE OF LT_MESG,
          LF_LINES TYPE I.

* Copy messages from CO_HANDLER to application log
  CALL FUNCTION 'MESSAGES_GIVE'
    TABLES
      T_MESG = LT_MESG
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'GET_HANDLE_SD_TO_FM'
    IMPORTING
      HANDLE = INST_BADI_SD_TO_FM
      ACTIVE = ACTIVE_BADI_SD_TO_FM.

  IF ACTIVE_BADI_SD_TO_FM EQ CHARX.
    DESCRIBE TABLE LT_MESG LINES LF_LINES.
    IF LF_LINES > 0.
      LOOP AT LT_MESG INTO LS_MESG.
        IF LS_MESG-MSGTY = 'E'.
          OBLIGO_ERROR = 'E'.
* Clear out the budgetary ledger and FM tables if FM is active
          CALL FUNCTION 'FUNCTION_EXISTS'
            EXPORTING
              FUNCNAME           = 'FM_OPEN_ITEM_SO'
            EXCEPTIONS
              FUNCTION_NOT_EXIST = 1.
          IF SY-SUBRC = 0.

            IF 1 = 2.                                       "768353
              CALL FUNCTION 'FM_OPEN_ITEM_SO'.              "#EC *
            ENDIF.
            REFRESH TRWIN. CLEAR TRWIN.
            L_GJAHR = SY-DATUM(4).
            CALL FUNCTION 'RWIN_CHECK'
              EXPORTING
                GJAHR   = L_GJAHR
                PROCESS = 'SDOR    '
                EVENT   = 'OPENITEM'
              TABLES
                TKOMP   = TRWIN
              EXCEPTIONS
                OTHERS  = 0.
            LOOP AT TRWIN.
              CALL FUNCTION TRWIN-FUNCTION.
            ENDLOOP.

          ENDIF.
          EXIT.
        ENDIF.

        IF LS_MESG-MSGTY = 'W'.
          OBLIGO_ERROR = 'W'.
        ENDIF.
      ENDLOOP.

      PERFORM OBLIGO_PROTOCOL(SAPFV45E) CHANGING DA_SUBRC.
      IF NOT DA_SUBRC IS INITIAL.
      IF call_activity NE activity_purchase and
         call_function is initial.
          FCODE = FCODE_GLEICHE_SEITE.
          PERFORM FCODE_BEARBEITEN.
          EXIT.
*       In case of update from purchase order
        ELSE.
          MESSAGE E225(V2).
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    "BELEG_BEARBEITEN_ENDE