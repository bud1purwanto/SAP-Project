*eject
*---------------------------------------------------------------------*
*       FORM BERECHTIGUNG_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Die Verkaufsbelegberechtigungen werden geprüft                *
*           -Berechtigung je Verkaufsorganisation                     *
*           -Berechtigung auf Belegarten                              *
*           -Berechtigung für diverse Transaktionen                   *
*---------------------------------------------------------------------*
FORM BERECHTIGUNG_PRUEFEN USING    US_ACTVT
                                   US_AUART
                                   US_CUA_EXCLUDE_ONLY
                          CHANGING VALUE(CH_SUBRC).

  DATA: DA_ACTVT(2),
        DA_CALL_TRANS_SUBRC LIKE SY-SUBRC.

  CLEAR CH_SUBRC.

ENHANCEMENT-POINT PRS_VA02_AUTH_CHK SPOTS ES_MV45ATOP.
* die folgenden Prüfungen nur durchführen, wenn US_CUA_EXCLUDE_ONLY
* nicht gesetzt ist, da in diesem Fall nicht nur abhängig von den
* Ergebnissen der Prüfungen der CUA-Status modifiziert werden soll
  IF US_CUA_EXCLUDE_ONLY IS INITIAL.
* Nicht bei Update vom z.B. Rechnungseingang
    CHECK NO_AUTHORITY_CHECK IS INITIAL.
* Aktivität für Berechtigung setzen
    IF US_ACTVT = SPACE.
      CASE T180-TRTYP.
        WHEN CHARH.
* Anlegen
          DA_ACTVT = ACTVT_01.
        WHEN CHARV.
* Ändern
          DA_ACTVT = ACTVT_02.
        WHEN CHARA.
* Anzeigen
          DA_ACTVT = ACTVT_03.
      ENDCASE.
    ELSE.
      DA_ACTVT = US_ACTVT.
    ENDIF.
    IF NOT VBAK-VKORG IS INITIAL AND
       NOT VBAK-VTWEG IS INITIAL AND
       NOT VBAK-SPART IS INITIAL.
* Berechtigung auf Verkaufsorganisation
      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
           ID 'VKORG' FIELD VBAK-VKORG
           ID 'VTWEG' FIELD VBAK-VTWEG
           ID 'SPART' FIELD VBAK-SPART
           ID 'ACTVT' FIELD DA_ACTVT.

      IF SY-SUBRC NE 0.
        CH_SUBRC = SY-SUBRC.
        CASE DA_ACTVT.
          WHEN ACTVT_01.
* Keine Pflegeberechtigung
            MESSAGE E515 WITH VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.
          WHEN ACTVT_02.
* Keine Pflegeberechtigung
            PERFORM BELEG_ENTSPERREN USING VBAK-VBELN.
            MESSAGE E515 WITH VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.
          WHEN ACTVT_03.
* Keine Anzeigeberechtigung
            MESSAGE E514 WITH VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.
          WHEN ACTVT_06.
* Keine Löschbefugnis
            MESSAGE S520 WITH VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.
            message_collect_lord.
        ENDCASE.
      ENDIF.
    ENDIF.

    CHECK CH_SUBRC = 0.

* Berechtigung auf Verkaufsbelegarten
    AUTHORITY-CHECK OBJECT 'V_VBAK_AAT'
         ID 'AUART' FIELD US_AUART
         ID 'ACTVT' FIELD DA_ACTVT.

    IF SY-SUBRC NE 0.
      CH_SUBRC = SY-SUBRC.
      CASE DA_ACTVT.
        WHEN ACTVT_01.
* Keine Pflegeberechtigung
          MESSAGE E517 WITH US_AUART.
        WHEN ACTVT_02.
* Keine Pflegeberechtigung
          PERFORM BELEG_ENTSPERREN USING VBAK-VBELN.
          MESSAGE E517 WITH US_AUART.
        WHEN ACTVT_03.
* Keine Anzeigeberechtigung
          MESSAGE E516 WITH US_AUART.
        WHEN ACTVT_06.
* Keine Löschbefugnis
          MESSAGE S521 WITH US_AUART.
          message_collect_lord.
      ENDCASE.
    ENDIF.
* Berechtigung auf Verkaufsbelegarten (Sperren)
    BERECHTIGUNG_BLOCK = CHARX.
    DA_ACTVT = '05'.
    AUTHORITY-CHECK OBJECT 'V_VBAK_AAT'
         ID 'AUART' FIELD US_AUART
         ID 'ACTVT' FIELD DA_ACTVT.
    IF SY-SUBRC > 0.
      BERECHTIGUNG_BLOCK = SPACE.
    ENDIF.
* Berechtigung auf Verkaufsbelegarten (Sperren)
    BERECHTIGUNG_UNBLOCK = CHARX.
    DA_ACTVT = '43'.
    AUTHORITY-CHECK OBJECT 'V_VBAK_AAT'
         ID 'AUART' FIELD US_AUART
         ID 'ACTVT' FIELD DA_ACTVT.
    IF SY-SUBRC > 0.
      BERECHTIGUNG_UNBLOCK = SPACE.
    ENDIF.
* Berechtigung auf Zahlungskarten                    CCARD
    CASE T180-TRTYP.
      WHEN CHARH.
* Pflegen
        DA_ACTVT = ACTVT_C1.
      WHEN CHARV.
* Pflegen
        DA_ACTVT = ACTVT_C1.
      WHEN CHARA.
* Anzeigen
        DA_ACTVT = ACTVT_C2.
    ENDCASE.
    BERECHTIGUNG_CCARD = CHARX.
    CALL FUNCTION 'SD_CCARD_SALES_AUTHORITY_CHECK'
         EXPORTING
              I_AUART      = US_AUART
              I_ACTVT      = DA_ACTVT
         EXCEPTIONS
              NO_AUTHORITY = 4.
    IF SY-SUBRC > 0.
      BERECHTIGUNG_CCARD = SPACE.
    ENDIF.
  ELSE.
* Berechtigungsprüfung für Verkaufsbeleg-Listen + Kundenstammblatt.
    IF AUTHORITY_CHECK_CUA_EXCLUDE IS INITIAL.
      AUTHORITY_LISTE_ANFRAGE = CHARX.
      AUTHORITY_LISTE_ANGEBOT = CHARX.
      AUTHORITY_LISTE_AUFTRAG = CHARX.
      AUTHORITY_LISTE_KONTRAKT = CHARX.
      AUTHORITY_LISTE_LIEFERPLAN = CHARX.
      AUTHORITY_LISTE_POSVORSCHLAG = CHARX.
      AUTHORITY_KUNDENSTAMMBLATT = CHARX.

      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_ANFRAGE
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_ANFRAGE.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_ANGEBOT
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_ANGEBOT.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_AUFTRAG
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_AUFTRAG.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_KONTRAKT
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_KONTRAKT.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_LIEFERPLAN
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_LIEFERPLAN.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_LISTE_POSVORSCHLAG
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_LISTE_POSVORSCHLAG.
      ENDIF.
      PERFORM CHECK_AUTHORITY_TRANS USING FCODE_KUNDENSTAMMBLATT_TRANS
                                    CHANGING DA_CALL_TRANS_SUBRC.
      IF DA_CALL_TRANS_SUBRC > 0.
        CLEAR AUTHORITY_KUNDENSTAMMBLATT.
      ENDIF.
      AUTHORITY_CHECK_CUA_EXCLUDE = CHARX.
    ENDIF.
  ENDIF.

ENDFORM.