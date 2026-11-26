*---------------------------------------------------------------------*
*       FORM LIEFERUNG_ERZEUGEN                                       *
*---------------------------------------------------------------------*
*       Am Ende der Belegverabeitung wird eine Sofortlieferung erzeugt*
*       Die Routine wird vor dem Buchen aufgerufen                    *
*---------------------------------------------------------------------*
FORM LIEFERUNG_ERZEUGEN
     TABLES   CT_XVBAP_MODIFY_REQUIREMENTS STRUCTURE VBAPVB
              CT_YVBAP_MODIFY_REQUIREMENTS STRUCTURE VBAPVB
     CHANGING CV_SUBRC_LF LIKE SY-SUBRC.
* SUBRC_LF values: See definition in calling subprogram BELEG_SICHERN

  DATA:
    CVBLS LIKE VBLS OCCURS 0 WITH HEADER LINE,
    CVBFS LIKE VBFS OCCURS 0 WITH HEADER LINE,
    ZVBAK LIKE VBAK OCCURS 0 WITH HEADER LINE,
    ZVBUK LIKE VBUKVB OCCURS 0 WITH HEADER LINE,
    ZVBAP LIKE VBAPVB OCCURS 0 WITH HEADER LINE,
    ZVBUP LIKE VBUPVB OCCURS 0 WITH HEADER LINE,
    ZVBEP LIKE VBEPVB OCCURS 0 WITH HEADER LINE,
    ZVBFA LIKE VBFAVB OCCURS 0 WITH HEADER LINE,
    ZVBADR LIKE SADRVB OCCURS 0 WITH HEADER LINE,
    DA_VBSK LIKE VBSK,
    DA_SELDT LIKE SY-DATLO,
    LS_HEADER51 TYPE HEADER51.

* Initialisieren
  CV_SUBRC_LF = 4.
  NO_RV_DELIVERY_INIT = CHARX.
* Status nachlesen (beim Anlegen noch ohne Belegnummer)
  IF XVBUK-VBELN NE *VBAK-VBELN.
    PERFORM XVBUK_LESEN(SAPFV45K) USING *VBAK-VBELN.
  ENDIF.

* Nicht beim Löschen
  CHECK XVBAK_UPDKZ NE UPDKZ_DELETE.
* Nicht bei Auslieferungsauftrag-Korrektur
  CHECK VBAK-VBKLT NE VBKLT_AUSL_AUFT_KORR.

* Sofortauftrag
  IF VBAP_KORLI IS INITIAL.

* Auftragsart, Liefervollständigkeit, Bestätigung prüfen
    CHECK:
      TVAK-LISOF NE SPACE,
      CALL_ACTIVITY NE 'CRRC',
      CALL_ACTIVITY NE 'CRRE',
      XVBUK-UVVLK EQ CHARC,
      XVBUK-UVVLS EQ CHARC OR XVBUK-UVVLS EQ CHARB,
      XVBUK-BESTK NE SPACE.
* Der Beleg darf noch nicht beliefert sein.
    IF XVBUK-LFSTK EQ CHARB OR XVBUK-LFSTK EQ CHARC.
      CV_SUBRC_LF = 1.
      EXIT.
    ENDIF.
* Bei Komplettlieferung müssen alle Positionen bestätigt sein
    IF NOT VBAK-AUTLF IS INITIAL AND XVBUK-BESTK NE CHARC.
      CV_SUBRC_LF = 12.
      EXIT.
    ENDIF.

* Pruefen, ob Packvorschlag gelesen (bei VA02 nicht unbedingt der Fall)
    IF MODIFICATION_FLAG-NO_PACKING IS INITIAL.
      CALL FUNCTION 'V51P_GET_HEADER_DATA'
           IMPORTING
                ES_HEADER51 = LS_HEADER51.
      IF LS_HEADER51 IS INITIAL.
        CALL FUNCTION 'HU_PACKING_SALES_PROPOSAL'
             EXPORTING
                  IF_ANZEIGEMODUS = T180-TRTYP
                  IF_DUNKEL       = 'X'
                  IF_PROFILE      = '0012'
                  IS_VBAK         = VBAK
                  IT_XVBAP        = XVBAP[]
                  IT_XVBPA        = XVBPA[]
             CHANGING
                  CT_XVBFA        = XVBFA[]
                  CT_YVBFA        = YVBFA[]
                  CT_XVBAPF       = XVBAPF[].
      ENDIF.
    ENDIF.

* Auftagskopf ist Tabellenparameter
    ZVBAK = VBAK.
    ZVBAK-VBELN = *VBAK-VBELN.
    APPEND ZVBAK.
* Diverse Belegdaten werden bei der Lieferung geändert
    LOOP AT XVBUK INTO ZVBUK.
      CLEAR ZVBUK-UPDKZ.
      APPEND ZVBUK.
    ENDLOOP.
    LOOP AT XVBUP INTO ZVBUP.
      CLEAR ZVBUP-UPDKZ.
      APPEND ZVBUP.
    ENDLOOP.
    LOOP AT XVBFA INTO ZVBFA.
      CLEAR ZVBFA-UPDKZ.
      APPEND ZVBFA.
    ENDLOOP.
    LOOP AT XVBADR INTO ZVBADR.    "Adressübernahme CPD-Kunde
      CLEAR ZVBADR-UPDKZ.
      APPEND ZVBADR.
    ENDLOOP.
ENHANCEMENT-SECTION     LIEFERUNG_ERZEUGEN_12 SPOTS ES_SAPMV45A.
    IF TVAK-LISOF EQ CHARX.
      DA_SELDT = SY-DATLO.
    ELSE.
      DA_SELDT = '99990101'.
    ENDIF.
END-ENHANCEMENT-SECTION.
    CV_SUBRC_LF = 0.
    CLEAR NO_RV_DELIVERY_INIT.
ENHANCEMENT-POINT LIEFERUNG_ERZEUGEN_10 SPOTS ES_SAPMV45A.

* Lieferungsbeleg aufbauen
ENHANCEMENT-SECTION     LIEFERUNG_ERZEUGEN_01 SPOTS ES_SAPMV45A.
    CALL FUNCTION 'RV_DELIVERY_CREATE_SINGLE'
         EXPORTING
              SELEKTIONSDATUM   = DA_SELDT
              IV_VBELN_SOFAUF   = VBAK-VBELN
              I_CALL_ACTIVITY   = CALL_ACTIVITY
              IF_DO_FINAL_CHECK = CHARX
         IMPORTING
              VBSK_E            = DA_VBSK
         TABLES
              LVBAK             = ZVBAK
              LVBAP             = XVBAP
              LVBEP             = XVBEP
              LVBFA             = ZVBFA
              LVBFS             = CVBFS
              LVBKD             = XVBKD
              LVBLS             = CVBLS
              LVBPA             = XVBPA
              LVBUK             = ZVBUK
              LVBUP             = ZVBUP
              LVBADR            = ZVBADR
              LFPLA             = XFPLA        "CCARD
              LFPLT             = XFPLT.       "CCARD
END-ENHANCEMENT-SECTION.

* Keine Lieferung erzeugt
    IF CVBLS[] IS INITIAL..
      CV_SUBRC_LF = 12.
      EXIT.
    ENDIF.

    SORT CVBLS BY POSNR.
    DELETE ADJACENT DUPLICATES FROM CVBLS COMPARING POSNR.

* Determine requirements modify and/or no delivery create for new items
    LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE.
      READ TABLE CVBLS WITH KEY POSNR = XVBAP-POSNR
                       BINARY SEARCH TRANSPORTING NO FIELDS.
* Undelivered or delivery irrelevant item: Modify sales requirements
      IF SY-SUBRC NE 0.
        APPEND XVBAP TO CT_XVBAP_MODIFY_REQUIREMENTS.
        PERFORM XVBUP_LESEN(SAPFV45P) USING XVBAP-VBELN XVBAP-POSNR.
* Undelivered but delivery relevant item: Set corresponding returncode
        IF XVBUP-LFSTA EQ CHARA.
          CV_SUBRC_LF = 16.
        ENDIF.
* RBA main item: Create pseudo sales requirements
      ELSEIF XVBAP-SRCPS EQ SRCPS_MAINITEM.
        DELETE CVBLS INDEX SY-TABIX.
        APPEND XVBAP TO CT_XVBAP_MODIFY_REQUIREMENTS.
      ENDIF.
    ENDLOOP.

* Determine requirements modify for old (especially deleted) items
    LOOP AT YVBAP.
      IF YVBAP-UPDKZ EQ UPDKZ_DELETE.
        APPEND YVBAP TO CT_YVBAP_MODIFY_REQUIREMENTS.
      ELSE.
        READ TABLE CVBLS WITH KEY POSNR = YVBAP-POSNR
                         BINARY SEARCH TRANSPORTING NO FIELDS.
        IF SY-SUBRC NE 0.
          APPEND YVBAP TO CT_YVBAP_MODIFY_REQUIREMENTS.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Clear global flag BEDARF_TRENNEN if need be => No requirements modify
    IF  CT_XVBAP_MODIFY_REQUIREMENTS[] IS INITIAL
    AND CT_YVBAP_MODIFY_REQUIREMENTS[] IS INITIAL.
      CLEAR BEDARF_TRENNEN.
    ENDIF.

* Korrekturlieferung
  ELSE.

* Auftagskopf ist Tabellenparameter
    ZVBAK = VBAK.
    ZVBAK-VBELN = *VBAK-VBELN.
    CLEAR ZVBAK-ABDIS.
    APPEND ZVBAK.
* Diverse Belegdaten werden bei der Lieferung geändert
    LOOP AT XVBUK INTO ZVBUK.
      CLEAR ZVBUK-UPDKZ.
      APPEND ZVBUK.
    ENDLOOP.
    LOOP AT XVBUP INTO ZVBUP.
* Lieferstatus werden = A gesetzt, damit eine Korrekturlieferung
* auch für Positionen ohne offene Mengen erzeugt werden kann
      ZVBUP-LFSTA = CHARA.
      ZVBUP-LFGSA = CHARA.
      CLEAR ZVBUP-UPDKZ.
      APPEND ZVBUP.
    ENDLOOP.
    LOOP AT XVBFA INTO ZVBFA.
      CLEAR ZVBFA-UPDKZ.
      APPEND ZVBFA.
    ENDLOOP.
    DA_SELDT = SY-DATLO.
    LOOP AT XVBAP INTO ZVBAP.
* KWMENG wird unverändert zur Berechnung der offenen Menge in FV50CF0L
* benötigt, da LSMENG mit der positiven Korrekturmenge gefüllt wird,
* und somit nicht mit der ELMENGE_L verrechnet werden kann
      CLEAR ZVBEP.
      MOVE-CORRESPONDING ZVBAP TO ZVBEP.
      CLEAR ZVBAP-UPDKZ.
      CLEAR ZVBAP-BEDAE.
      CLEAR ZVBAP-FKREL.
      CLEAR ZVBAP-ABLFZ.
      IF ZVBAP-KORDT GT DA_SELDT.
        DA_SELDT = ZVBAP-KORDT.
      ENDIF.
      ZVBEP-ETENR = '0001'.
      ZVBEP-LFREL = CHARX.
      ZVBEP-EDATU = ZVBAP-KORDT.
      ZVBEP-PRGRS = CHAR1.
      ZVBEP-LDDAT = ZVBAP-KORDT.
      ZVBEP-MBDAT = ZVBAP-KORDT.
      ZVBEP-TDDAT = ZVBAP-KORDT.
      ZVBEP-BDDAT = ZVBAP-KORDT.
      ZVBEP-WADAT = ZVBAP-KORDT.
      IF ZVBAP-KORMNG LE 0.
        ZVBAP-KORMNG = - ZVBAP-KORMNG.
        ZVBAP-SHKZG = CHARX.
      ENDIF.
      ZVBEP-WMENG = ZVBAP-KORMNG.
      ZVBEP-CMENG = ZVBEP-WMENG.
      ZVBEP-LMENG = ZVBEP-WMENG  * ZVBAP-UMVKZ / ZVBAP-UMVKN.
* Kumulierte Liefersoll-/bestätigte Menge = positive Korrekturmenge
      ZVBAP-LSMENG = ZVBEP-WMENG.
      ZVBAP-KLMENG = ZVBEP-LMENG.
      APPEND ZVBEP.
      APPEND ZVBAP.
    ENDLOOP.
    CLEAR NO_RV_DELIVERY_INIT.

* Lieferungsbeleg aufbauen
ENHANCEMENT-SECTION     LIEFERUNG_ERZEUGEN_02 SPOTS ES_SAPMV45A.
    CALL FUNCTION 'RV_DELIVERY_CREATE_SINGLE'
         EXPORTING
              SELEKTIONSDATUM   = DA_SELDT
              I_LIEFERART       = TVAK-KORLI
              IV_VBELN_SOFAUF   = VBAK-VBELN
              I_CALL_ACTIVITY   = CALL_ACTIVITY
              IF_DO_FINAL_CHECK = CHARX
         IMPORTING
              VBSK_E            = DA_VBSK
         TABLES
              LVBAK             = ZVBAK
              LVBAP             = ZVBAP
              LVBEP             = ZVBEP
              LVBFA             = ZVBFA
              LVBFS             = CVBFS
              LVBKD             = XVBKD
              LVBLS             = CVBLS
              LVBPA             = XVBPA
              LVBUK             = ZVBUK
              LVBUP             = ZVBUP.
END-ENHANCEMENT-SECTION.

* Keine Lieferung erzeugt
    IF CVBLS[] IS INITIAL.
      CV_SUBRC_LF = 12.
* Korrekturlieferung (Merken für Abbau Planprimärbedarf)
    ELSE.
      CV_SUBRC_LF = 90.
    ENDIF.

  ENDIF.

ENDFORM.