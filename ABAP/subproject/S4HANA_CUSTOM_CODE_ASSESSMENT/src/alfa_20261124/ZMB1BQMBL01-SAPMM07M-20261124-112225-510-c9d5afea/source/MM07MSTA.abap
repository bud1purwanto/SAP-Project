DATA: g_t156 LIKE t156 OCCURS 0 WITH HEADER LINE.

*---------------------------------------------------------------------*
*       FORM STATISTIK_GENERIEREN                                     *
*---------------------------------------------------------------------*
*       Die Statistikdatei für das Bestandscontrolling wird aufgebaut.*
*       Filter: Statistikrelevanzkennzeichen aus T156
*---------------------------------------------------------------------*
FORM statistik_generieren.

  DATA: shkzg       LIKE mseg-shkzg,
        ls_mcmseg_l LIKE mcmseg,       " l für Light-Buchung
        ls_mcmseg_k LIKE mcmseg.       " k für Komplementärbuchung



* No call to statictics for dummy lines from cross-system goods
* movements, as the external plant has no stocks in this system.
* Furthermore it might happen that some code within this routine
* tries to access T001W with this plant and issues errors.
  CHECK cl_mmim_cross_system=>plant_in_own_system( xmseg-werks ) "sdp462
             = abap_true.                                   "sdp462

* Statistikrelevanz prüfen: KZSTR = '2' oder '3'
  CHECK NOT xmseg-kzstr IS INITIAL AND NOT xmseg-kzstr = eins.

* Kommunikationsstrukturen initialisieren
  CLEAR xmcbest.
  CLEAR xmcmseg.

* Prüfen, ob Artikeltyp Sammelartikel ist: retailspezifisch
  CHECK xvm07m-attyp NE attyp-sam.

* Attribute zur Bewegungsart einlesen
  READ TABLE g_t156 INDEX 1.
  IF sy-subrc NE 0 OR xmseg-bwart NE g_t156-bwart.
    SELECT * FROM t156 INTO TABLE g_t156
      WHERE bwart = xmseg-bwart.
  ENDIF.

* pro Belegzeile wird eine Zeile für die Kommunikationsstruktur
* aufgebaut;bei einer Komplementärbuchung wird eine 2.Zeile erzeugt
  CALL FUNCTION 'MCB_MCMSEG_FILL'
    EXPORTING
      i_mseg     = xmseg         "Materialbelegposition
      i_vm07m    = xvm07m        "Felder Verbuchungssteuerung
      i_dm07m    = zdm07m        "Felder Dialogsteuerung
    IMPORTING
      e_mcmseg_l = ls_mcmseg_l   "Kommunikationsstruktur
      e_mcmseg_k = ls_mcmseg_k   "Kommunikationsstruktur
    TABLES
      yt156      = g_t156        "Bewegungsart: Attribute
      ymkpf      = xmkpf         "Materialbelegkopf
      ymseg      = xmseg.

* Die Kommunikationsstruktur für Bestand wird aufgebaut
  DO 2 TIMES.
ENHANCEMENT-SECTION     STATISTIK_GENERIEREN_01 SPOTS ES_SAPMM07M.
    IF sy-index EQ 1.
      MOVE ls_mcmseg_l TO xmcmseg.
    ELSE.
      MOVE ls_mcmseg_k TO xmcmseg.
    ENDIF.
END-ENHANCEMENT-SECTION.
    CHECK NOT xmcmseg IS INITIAL.
ENHANCEMENT-POINT STATISTIK_GENERIEREN_02 SPOTS ES_SAPMM07M.
    IF NOT xmcmseg-xglgmg IS INITIAL.
* Gebundener Leergutbestand
      PERFORM sta_bestand_marc.
    ELSEIF NOT xmcmseg-xlabst IS INITIAL.
* Frei verwendbarer Lagerortbestand
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xeinme IS INITIAL.
* Eingeschränkt verwendbarer Bestand
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xinsme IS INITIAL.
* Qualitätsprüfbestand
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xspeme IS INITIAL.
* Gesperrter Bestand
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xretme IS INITIAL.
* Retourensperrbestand
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xklabs IS INITIAL.
* Lieferantenkonsi frei verwendbar
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xkinsm IS INITIAL.
* Lieferantenkonsi in Qualitätsprüfung
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xkspem IS INITIAL.
* Lieferantenkonsi gesperrt
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xkeinm IS INITIAL.
* Lieferantenkonsi eingeschränkt verwendbar
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xumlme IS INITIAL.
* Umlagerbestand Lagerort an Lagerort
      PERFORM sta_bestand_mard.
    ELSEIF NOT xmcmseg-xumlmc IS INITIAL.
* Umlagerbestand Werk an Werk
      PERFORM sta_bestand_marc.
    ELSEIF NOT xmcmseg-xtrame IS INITIAL.
* Transitbestand
      PERFORM sta_bestand_marc.
    ELSEIF NOT xmcmseg-xmklkk IS INITIAL.
* Kundenkonsi frei verwendbar
      PERFORM sta_bestand_msku.
* Kundenkonsignation in Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmkqkk IS INITIAL.
      PERFORM sta_bestand_msku.
* Kundenkonsi nicht frei
    ELSEIF NOT xmcmseg-xmkekk IS INITIAL.
      PERFORM sta_bestand_msku.
* Kundenleihgut frei verwendbar
    ELSEIF NOT xmcmseg-xmklkl IS INITIAL.
      PERFORM sta_bestand_msku.
* Kundenleihgut in Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmkqkl IS INITIAL.
      PERFORM sta_bestand_msku.
* Kundenleihgut nicht frei
    ELSEIF NOT xmcmseg-xmkekl IS INITIAL.
      PERFORM sta_bestand_msku.
* Lieferantenbeistellung frei verwendbar
    ELSEIF NOT xmcmseg-xmslbo IS INITIAL.
      PERFORM sta_bestand_mslb.
* Lieferantenbeistellung in Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmsqbo IS INITIAL.
      PERFORM sta_bestand_mslb.
* Lieferantenbeistellung nicht frei
    ELSEIF NOT xmcmseg-xmsebo IS INITIAL.
      PERFORM sta_bestand_mslb.
* Kundenauftragsbestand frei verwendbar
    ELSEIF NOT xmcmseg-xmeikl IS INITIAL.
      PERFORM sta_bestand_mska.
* Kundenauftragsbestand in Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmeikq IS INITIAL.
      PERFORM sta_bestand_mska.
* Kundenauftragsbestand gesperrt
    ELSEIF NOT xmcmseg-xmeiks IS INITIAL.
      PERFORM sta_bestand_mska.
* Kundenauftragsbestand nicht frei
    ELSEIF NOT xmcmseg-xmeike IS INITIAL.
      PERFORM sta_bestand_mska.
* Umlagerbestand bei Kundenauftragsbestand
    ELSEIF NOT xmcmseg-xsatra IS INITIAL.
      PERFORM sta_bestand_mska.
* Projektbestand frei verwendbar
    ELSEIF NOT xmcmseg-xmsprl IS INITIAL.
      PERFORM sta_bestand_mspr.
* Projektbestand in Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmsprq IS INITIAL.
      PERFORM sta_bestand_mspr.
* Projektbestand gesperrt
    ELSEIF NOT xmcmseg-xmsprs IS INITIAL.
      PERFORM sta_bestand_mspr.
* Projektbestand nicht frei
    ELSEIF NOT xmcmseg-xmspre IS INITIAL.
      PERFORM sta_bestand_mspr.
* Umlagerbestand bei Projekten
    ELSEIF NOT xmcmseg-xsqtra IS INITIAL.
      PERFORM sta_bestand_mspr.
    ELSEIF NOT xmcmseg-xmtvla IS INITIAL.
      PERFORM sta_bestand_mkol.
* MTV Qualitätsprüfung
    ELSEIF NOT xmcmseg-xmtvqu IS INITIAL.
      PERFORM sta_bestand_mkol.
* MTV nicht frei
    ELSEIF NOT xmcmseg-xmtvei IS INITIAL.
      PERFORM sta_bestand_mkol.
* MTV gesperrt
    ELSEIF NOT xmcmseg-xmtvsp IS INITIAL.
      PERFORM sta_bestand_mkol.
* bewerteter WE-Speerbestand (Hinweis 1123866)
*    ELSEIF NOT xmcmseg-xbwesb IS INITIAL.
*      PERFORM sta_bestand_marc.

*/// SIT
* If xchpf or bwtty is not filled, then the following tables
* are filled with movement: MARC+MSTB, MSTE+MSSA, MSTQ+MSSQ
* (depending on SOBKZ)
* If xchpf AND bwtty is filled, then only MSTB or MSTE or MSTQ
* is filled.

* bewerteter WE-Sperrbestand, Transit
    ELSEIF ( NOT xmcmseg-xbwesb IS INITIAL
             OR NOT xmcmseg-xcwesb IS INITIAL ).
      IF NOT xvm07m-xchpf IS INITIAL OR
         NOT  dm07m-bwtty IS INITIAL.
        PERFORM sta_bestand_mstb.
      ELSE.
        PERFORM sta_bestand_marc.
      ENDIF.

* bewerteter WE-Sperrbestand, Kundenauftrag, Transit
    ELSEIF ( NOT xmcmseg-xsabwe IS INITIAL
             OR NOT xmcmseg-xewesb IS INITIAL ).
      IF NOT xvm07m-xchpf IS INITIAL OR
         NOT  dm07m-bwtty IS INITIAL.
        PERFORM sta_bestand_mste.
      ELSE.
        PERFORM sta_bestand_mssa.
      ENDIF.

* bewerteter WE-Sperrbestand, Projekt, Transit
    ELSEIF ( NOT xmcmseg-xsqbwe IS INITIAL
             OR NOT xmcmseg-xqwesb IS INITIAL ).
      IF NOT xvm07m-xchpf IS INITIAL OR
         NOT  dm07m-bwtty IS INITIAL.
        PERFORM sta_bestand_mstq.
      ELSE.
        PERFORM sta_bestand_mssq.
      ENDIF.
*\\\ SIT

* Wareneingang direkt in den Verbrauch -> nicht bestandswirksam
    ELSE.
      xmcmseg-bsttyp = v.
      xmcmseg-bstaus = v.
    ENDIF.
    APPEND xmcmseg.
* Prüfen, ob Dummyzeilen für XMCBEST erzeugt werden müssen
* wenn kein XMCBEST-Eintrag existiert
    PERFORM check_xmcbest.
* Lesen Sicherheitsbestand
    PERFORM update_eisbe.
  ENDDO.

* Materialbeleg enthält Umbewertungsbetrag
  PERFORM revaluation_amount.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM STA_BESTAND_MARC                                         *
*---------------------------------------------------------------------*
*       Der Bestand aus der Sperrtabelle wird in die interne          *
*       Tabelle XMCBEST übernommen.                                   *
*---------------------------------------------------------------------*
FORM sta_bestand_marc.
* Schlüssel der MCBEST wird gefüllt
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

* Prüfe, ob schon ein Satz existiert
  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
    xmcmseg-dispo = xmcbest-dispo.     " Hinweis 610113
  ELSE.
* Noch kein Eintrag vorhanden: Einfügen
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmarc_key.
* Bestandstabelle wird gelesen
    READ TABLE xmarc WITH KEY xmarc_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmarc TO xmcbest.
      PERFORM read_mslb_msku.
* MCBEST wird gefüllt
      PERFORM sta_mcbest_fuellen.
      INSERT xmcbest INDEX index_l.
      mcbest_flg = x.
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM STA_BESTAND_MARD                                         *
*---------------------------------------------------------------------*
*       Lagerortbestände lesen                                        *
*---------------------------------------------------------------------*
FORM sta_bestand_mard.
  CLEAR: xmcbest_key, xmcbest.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmard_key.
    READ TABLE xmard WITH KEY xmard_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmard TO xmcbest.
    ENDIF.
    IF NOT xmcbest_key-charg IS INITIAL.
      MOVE-CORRESPONDING xmcbest_key TO xmchb_key.
      READ TABLE xmchb WITH KEY xmchb_key BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING xmchb TO xmcbest.
      ENDIF.
      MOVE-CORRESPONDING xmcbest_key TO xmkol_key.
      READ TABLE xmkol WITH KEY xmkol_key BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING xmkol TO xmcbest.
      ENDIF.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM STA_BESTAND_MSLB                                         *
*---------------------------------------------------------------------*
*       Lesen der Lohnbearbeitungsbestände                            *
*---------------------------------------------------------------------*
FORM sta_bestand_mslb.
  CLEAR: xmcbest, xmcbest_key.

* Lieferant, an den geliefert wird
  IF NOT xmseg-emlif IS INITIAL.
    xmcmseg-lifnr = xmseg-emlif.
  ENDIF.

  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmslb_key.
*   Lohnbearbeitungsbestand lesen
    READ TABLE xmslb WITH KEY xmslb_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmslb TO xmcbest.
      PERFORM read_msku_marc.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM STA_BESTAND_MSKU                                         *
*---------------------------------------------------------------------*
*       Lesen der Kundensonderbestände                                *
*---------------------------------------------------------------------*
FORM sta_bestand_msku.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmsku_key.
*     Kundensonderbestände lesen
    READ TABLE xmsku WITH KEY xmsku_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmsku TO xmcbest.
      PERFORM read_mslb_marc.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM STA_MCBEST_FUELLEN                                       *
*---------------------------------------------------------------------*
*       Die Tabelle MCBEST wird gefüllt.                              *
*---------------------------------------------------------------------*
FORM sta_mcbest_fuellen.

  MOVE-CORRESPONDING xmcmseg TO xmcbest.

  MOVE-CORRESPONDING xvm07m TO xmcbest.

* Kundenauftragsnummer zuweisen
  MOVE xmcmseg-kdauf TO xmcbest-vbeln.
  MOVE xmcmseg-kdpos TO xmcbest-posnr.

* PSP-Element zuweisen
  MOVE xmcmseg-ps_psp_pnr TO xmcbest-pspnr.

* Bewertungsklasse zuordnen
  IF NOT ( zdm07m-kzuml IS INITIAL ) AND
     NOT ( xmseg-xauto  IS INITIAL ) AND
          zdm07m-umbkl  NE zdm07m-bklas.
    MOVE zdm07m-umbkl TO xmcbest-bklas.
    MOVE zdm07m-umbkl TO xmcmseg-bklas.
  ELSE.
    MOVE zdm07m-bklas TO xmcbest-bklas.
    MOVE zdm07m-bklas TO xmcmseg-bklas.
  ENDIF.

* Materialstamm nachlesen
  PERFORM material_read.

  IF xmcmseg-sobkz = e.
* Bewerteter Kundenauftragsbestand
    PERFORM wert_ermitteln_ebew.
  ELSEIF xmcmseg-sobkz = q.
* Bewerteter Projektbestand
    PERFORM wert_ermitteln_qbew.
  ELSE.
* Bewerteter Bestand (Buchhaltungssicht)
    PERFORM wert_ermitteln USING xmcbest-salk3
                                 xmcbest-lbkum
                                 xmcbest-cwbwbest
                                 xmcbest-salk3_vz
                                 xmcbest-lbkum_vz
                                 xmcbest-bwtty.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM STA_T156C_LESEN                                          *
*---------------------------------------------------------------------*
*       Die Tabelle T156C wird gelesen.                               *
*---------------------------------------------------------------------*
FORM sta_t156c_lesen USING lbbsa LIKE t156c-lbbsa.
  SELECT SINGLE * FROM t156c WHERE lbbsa = lbbsa
                             AND   sobkz = xmseg-sobkz.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '156C' lbbsa xmseg-sobkz.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM WERT_ERMITTELN                                           *
*---------------------------------------------------------------------*
*       SALK3 und LBKUM und deren Vorzeichen werden gesetzt.          *
*---------------------------------------------------------------------*
FORM wert_ermitteln USING i_salk3    LIKE mcbest-salk3
                          i_lbkum    LIKE mcbest-lbkum
                          i_salk_ch  LIKE mcbest-cwbwbest
                          i_salk3_vz LIKE mcbest-salk3_vz
                          i_lbkum_vz LIKE mcbest-lbkum_vz
                          i_bwtty    LIKE mcbest-bwtty.
  IF NOT xmseg-wertu IS INITIAL.
    IF xmseg-bwtar IS INITIAL.
      CLEAR xmbew_key.
      xmbew_key-matnr = xmseg-matnr.
      xmbew_key-bwkey = xvm07m-bwkey.
      xmbew_key-curtp = curtp10.
      READ TABLE xmbew WITH KEY xmbew_key BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        xmcbest-bklas = xmbew-bklas.
        xmcmseg-bklas = xmbew-bklas.
        xmcbest-salk3 = xmbew-salk3.
        xmcbest-lbkum = xmbew-lbkum.
        xmcbest-bwtty = xmbew-bwtty.
      ELSE.
        LOOP AT zmseg WHERE matnr = xmseg-matnr
                        AND werks = xmseg-werks.
          EXIT.
        ENDLOOP.
        IF sy-subrc = 0.
* Sofern die Bewegung ohne Wert gebucht wird (z. B. 311...), werden
* die alten Werte aus DM07M gesetzt.
          i_salk3 = zmseg-salk3.
          i_lbkum = zmseg-lbkum.
        ENDIF.
      ENDIF.
    ELSE.
      REFRESH: xmcmbew. CLEAR xmcmbew.
      LOOP AT xmbew WHERE matnr = xmseg-matnr
                    AND   bwkey = xvm07m-bwkey.
        MOVE-CORRESPONDING xmbew TO xmcmbew.
        COLLECT xmcmbew.
      ENDLOOP.
      READ TABLE xmcmbew INDEX 1.
      IF sy-subrc IS INITIAL.
*       Hier wird der Deltawert für SALK3 und LBKUM in die
*       MCBEST übernommen.
        MOVE zdm07m-bwtty TO i_bwtty.
        IF xmcmbew-salk3 > xmcmbew-salk3_old.
          i_salk3    = xmcmbew-salk3 - xmcmbew-salk3_old.
          i_salk_ch  = xmcmbew-salk3.
          i_salk3_vz = plus.
        ELSE.
          IF xmcmbew-salk3 < xmcmbew-salk3_old.
            i_salk3    = xmcmbew-salk3_old - xmcmbew-salk3.
            i_salk_ch  = xmcmbew-salk3.
            i_salk3_vz = minus.
          ELSE.
            CLEAR: i_salk3, i_salk3_vz.
          ENDIF.
        ENDIF.
        IF xmcmbew-lbkum > xmcmbew-lbkum_old.
          i_lbkum = xmcmbew-lbkum - xmcmbew-lbkum_old.
          i_lbkum_vz = plus.
        ELSE.
          IF xmcmbew-lbkum < xmcmbew-lbkum_old.
            i_lbkum    = xmcmbew-lbkum_old - xmcmbew-lbkum.
            i_lbkum_vz = minus.
          ELSE.
            CLEAR: i_lbkum, i_lbkum_vz.
          ENDIF.
        ENDIF.
      ELSE.
        i_bwtty = zdm07m-bwtty.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_MSLB_MSKU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_mslb_msku.
*----------------------------------------------------------------------*
* select stock quantity on plantage level when update type
* "data transfer"
*----------------------------------------------------------------------*

*--KundenKonsi und Kundenleihgut
  SELECT * FROM msku WHERE matnr = xmcmseg-matnr
                       AND werks = xmcmseg-werks
                       AND ( sobkz = w OR sobkz = v ).
    xmcbest-kulab = xmcbest-kulab + msku-kulab.
    xmcbest-kuins = xmcbest-kuins + msku-kuins.
  ENDSELECT.
*--Lieferantenbeistellung
  SELECT * FROM mslb WHERE matnr = xmcmseg-matnr
                       AND werks = xmcmseg-werks
                       AND sobkz = o.
    xmcbest-lblab = xmcbest-lblab + mslb-lblab.
    xmcbest-lbins = xmcbest-lbins + mslb-lbins.
  ENDSELECT.

ENDFORM.                               " READ_MSLB_MSKU

*&---------------------------------------------------------------------*
*&      Form  READ_MSLB_MARC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_mslb_marc.
*----------------------------------------------------------------------*
* select stock quantity on plantage level when update type
* "data transfer"
*----------------------------------------------------------------------*

*--Umlagerungsbestände auf Werksebene
  READ TABLE xmarc WITH KEY matnr = xmcmseg-matnr
                            werks = xmcmseg-werks
                            BINARY SEARCH.
  IF sy-subrc = 0.
    xmcbest-trame = xmarc-trame.
    xmcbest-umlmc = xmarc-umlmc.
    xmcbest-glgmg = xmarc-glgmg.
  ENDIF.
*--Lieferantenbeistellung
  SELECT * FROM mslb WHERE matnr = xmcmseg-matnr
                       AND werks = xmcmseg-werks
                       AND sobkz = o.
    xmcbest-lblab = xmcbest-lblab + mslb-lblab.
    xmcbest-lbins = xmcbest-lbins + mslb-lbins.
  ENDSELECT.

ENDFORM.                               " READ_MSLB_MARC

*&---------------------------------------------------------------------*
*&      Form  READ_MSKU_MARC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_msku_marc.
*----------------------------------------------------------------------*
* select stock quantity on plantage level when update type
* "data transfer"
*----------------------------------------------------------------------*

*--Umlagerungsbestände auf Werksebene
  READ TABLE xmarc WITH KEY matnr = xmcmseg-matnr
                            werks = xmcmseg-werks
                            BINARY SEARCH.
  IF sy-subrc = 0.
    xmcbest-trame = xmarc-trame.
    xmcbest-umlmc = xmarc-umlmc.
    xmcbest-glgmg = xmarc-glgmg.
  ENDIF.

*--KundenKonsi und Kundenleihgut
  SELECT * FROM msku WHERE matnr = xmcmseg-matnr
                       AND werks = xmcmseg-werks
                       AND ( sobkz = w OR sobkz = v ).
    xmcbest-kulab = xmcbest-kulab + msku-kulab.
    xmcbest-kuins = xmcbest-kuins + msku-kuins.
  ENDSELECT.

ENDFORM.                               " READ_MSKU_MARC

*&---------------------------------------------------------------------*
*&      Form  MATERIAL_READ
*&---------------------------------------------------------------------*
*       Bei bestimmten Buchungen in der Bestandsführung müssen die
*       Materialstammattribute f.d. Bestandscontrolling nachgelesen    *
*       werden.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM material_read.

  CALL FUNCTION 'MARA_SINGLE_READ'
    EXPORTING
      matnr             = xmseg-matnr
    IMPORTING
      wmara             = mc_mara
    EXCEPTIONS
      lock_on_material  = 1
      lock_system_error = 2
      wrong_call        = 3
      not_found         = 4
      OTHERS            = 5.

  IF sy-subrc = 0.
    xmcmseg-matkl = xmcbest-matkl = mc_mara-matkl.
    xmcmseg-mtart = xmcbest-mtart = mc_mara-mtart.
    xmcmseg-prdha = xmcbest-prdha = mc_mara-prdha.
    xmcbest-spart = mc_mara-spart.
  ENDIF.

  CALL FUNCTION 'MARC_SINGLE_READ'
    EXPORTING
      matnr             = xmseg-matnr
      werks             = xmseg-werks
    IMPORTING
      wmarc             = mc_marc
    EXCEPTIONS
      lock_on_marc      = 1
      lock_system_error = 2
      wrong_call        = 3
      not_found         = 4
      OTHERS            = 5.

  IF sy-subrc = 0.
    xmcbest-dismm = mc_marc-dismm.
    xmcmseg-prctr = xmcbest-prctr = mc_marc-prctr.
    xmcmseg-dispo = xmcbest-dispo = mc_marc-dispo.
    xmcbest-eisbe = mc_marc-eisbe.
    IF NOT xmcbest-lgort IS INITIAL.
      CLEAR xmcbest-eisbe.
    ENDIF.
  ENDIF.

ENDFORM.                               " MATERIAL_READ


*&---------------------------------------------------------------------*
*&      Form  REVALUATION_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  Wenn ein Materialbeleg in die Vorperiode gebucht wird und der
*  Preis der Vorperiode ein anderer war, schreibt die Bestands-
*  führung in das Feld DMBUM den sog. Umbewertungsbetrag, d.h. daß
*  sich der Bestandswert der Vorperiode auch noch ändert.
*----------------------------------------------------------------------*
FORM revaluation_amount.
  IF xmseg-dmbum <> 0.
* Rückbuchen in Vorperiode ==> Umbewertung im laufenden Monat
    CLEAR: xmcmseg, xmcbest.
    MOVE-CORRESPONDING xmseg  TO xmcmseg.
    MOVE-CORRESPONDING xvm07m TO xmcmseg.
    MOVE-CORRESPONDING zdm07m TO xmcmseg.

    IF NOT zdm07m-kzuml IS INITIAL AND
       NOT xmseg-xauto IS INITIAL.
      xmcmseg-bklas = zdm07m-umbkl.
    ENDIF.

* Zuweisung Projektnummer (HW 769656)
    IF  xmseg-mat_pspnr NE xmseg-ps_psp_pnr
    AND NOT ( xmseg-mat_pspnr IS INITIAL ).
      MOVE xmseg-mat_pspnr TO xmcmseg-ps_psp_pnr.
    ENDIF.

* Zuweisung Kundeauftragsnummer und -position (HW 769656)
    IF  ( xmseg-mat_kdauf NE xmseg-kdauf
      AND NOT ( xmseg-mat_kdauf IS INITIAL ) )
    OR ( xmseg-mat_kdpos NE xmseg-kdpos
      AND NOT ( xmseg-mat_kdpos IS INITIAL ) ).
      MOVE xmseg-mat_kdauf TO xmcmseg-kdauf.
      MOVE xmseg-mat_kdpos TO xmcmseg-kdpos.
    ENDIF.

    xmcmseg-shkzg = xmseg-shkum.
    IF xmcmseg-shkzg = s.
      xmcmseg-xlabst = '+'.
    ELSE.
      xmcmseg-xlabst = '-'.
    ENDIF.
    CLEAR: xmcmseg-menge, xmcmseg-mgvbr, xmcmseg-muvbr, xmcmseg-erfmg.
*   Clear all sales price value fields for retailers to avoid double
*   stock values in the information system
    CLEAR: XMCMSEG-VKWRA, XMCMSEG-VKWRT.
    xmcmseg-dmbtr = xmcmseg-dmbum.
    xmcmseg-xumbew = x.
    APPEND xmcmseg.
* Prüfen, ob Dummyzeilen für XMCBEST erzeugt werden müssen
    PERFORM check_xmcbest.
  ENDIF.

ENDFORM.                               " REVALUATION_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  NO_MATERIAL
*&---------------------------------------------------------------------*
*       Bestellung ohne Material mit Kontierung und Buchung auf
*       Warengruppe direkt in den Verbrauch. Das Feld "Menge" ist
*       nicht gefüllt. Es wird mit der Erfassungsmenge gearbeitet
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM no_material.
*  Erfassungsmenge wird als Verbrauch interpretiert
  xmcmseg-mgvbr = xmseg-erfmg.
* Kein Bezug zur Reservierung ===> Ungeplanter Verbrauch
  IF xmseg-rsnum IS INITIAL.
    xmcmseg-muvbr = xmseg-erfmg.
  ENDIF.
* Stornobewegungsart: Verbrauch mit umgekehrtem Vorzeichen
  SELECT SINGLE * FROM t156 WHERE bwart = xmseg-bwart.
  IF sy-subrc = 0 AND NOT t156-xstbw IS INITIAL.
    xmcmseg-mgvbr = - xmcmseg-mgvbr.
    xmcmseg-muvbr = - xmcmseg-muvbr.
  ENDIF.
* Für BCO Kennzeichen Wert-und Mengenfortschreibung aktiv
  xmcmseg-menge = xmseg-erfmg.
  xmcmseg-mengu = x.
  xmcmseg-wertu = x.
* Erfassungsmengeneinheit wird als Basismengeneinheit verwendet
  xmcmseg-meins = xmseg-erfme.
  xmcmseg-bsttyp = v.
  xmcmseg-bstaus = v.
  APPEND xmcmseg.
ENDFORM.                               " NO_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  CHECK_XMCBEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_xmcbest.

  DATA: cx_tabix LIKE sy-tabix,
        cx_matnr LIKE mara-matnr,
        cx_waart TYPE c.

  IF mcbest_flg IS INITIAL.
    MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

    MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
    MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
    MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

    READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
    IF sy-subrc NE 0.
      cx_tabix = sy-tabix.
      PERFORM material_read.
      MOVE-CORRESPONDING xmcbest_key TO xmcbest.
      INSERT xmcbest INDEX cx_tabix.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'VALUE_ARTICLE_FIND'
    EXPORTING
      i_matnr                = xmcbest-matnr
      i_werks                = xmcbest-werks
    IMPORTING
      e_matnr                = cx_matnr
      e_waart                = cx_waart
    EXCEPTIONS
      entry_not_found        = 1
      wertm_bf_nicht_erlaubt = 2
      buchung_nicht_erlaubt  = 3
      material_not_found     = 4
      OTHERS                 = 5.
  IF sy-subrc      EQ 0       AND
     NOT cx_waart  IS INITIAL AND
     xmcbest-matnr NE cx_matnr.
    xmcbest_key-matnr = cx_matnr.
    READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
    IF sy-subrc NE 0.
      cx_tabix = sy-tabix.
      PERFORM material_read.
      MOVE-CORRESPONDING xmcbest_key TO xmcbest.
      INSERT xmcbest INDEX cx_tabix.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_XMCBEST

*&---------------------------------------------------------------------*
*&      Form  UPDATE_EISBE
*&---------------------------------------------------------------------*
*       Für die Kennzahl Sicherheitsbestand muß in der XMCBEST ein     *
*       Eintrag mit Lagerort = ' ' erzeugt werden.                     *
*       Wenn der Materialbeleg einen Lagerort hat, muß sichergestellt
*       werden, daß in der MCBEST-Zeile mit Lagerort kein Sicherheits-
*       bestand steht.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_eisbe.
  DATA ue_tabix LIKE sy-tabix.

  IF NOT xmcmseg-lgort IS INITIAL.
    CLEAR: xmcbest, xmcbest_key.
    MOVE xmcmseg-mandt TO xmcbest_key-mandt.
    MOVE xmcmseg-matnr TO xmcbest_key-matnr.
    MOVE xmcmseg-werks TO xmcbest_key-werks.

    READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
    IF sy-subrc NE 0.
      ue_tabix = sy-tabix.
      MOVE-CORRESPONDING xmseg TO xmcbest.
      MOVE-CORRESPONDING xvm07m  TO xmcbest.
      MOVE-CORRESPONDING zdm07m  TO xmcbest.
      MOVE-CORRESPONDING xmcbest_key TO xmcbest.
      READ TABLE xmarc WITH KEY matnr = xmcbest-matnr
                                werks = xmcbest-werks
                                BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING xmarc TO xmcbest.
      ENDIF.
      xmcbest-xchar = xmcmseg-xchar.

      PERFORM material_read.
      IF xmcbest-sobkz = e.
        PERFORM wert_ermitteln_ebew.
      ELSEIF xmcbest-sobkz = q.
        PERFORM wert_ermitteln_qbew.
      ELSE.
        PERFORM wert_ermitteln USING xmcbest-salk3
                                     xmcbest-lbkum
                                     xmcbest-cwbwbest
                                     xmcbest-salk3_vz
                                     xmcbest-lbkum_vz
                                     xmcbest-bwtty.
      ENDIF.
      INSERT xmcbest INDEX ue_tabix.
    ENDIF.
  ENDIF.
ENDFORM.                               " UPDATE_EISBE

*&---------------------------------------------------------------------*
*&      Form  STA_BESTAND_MSPR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sta_bestand_mspr.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmspr_key.
    MOVE xmcmseg-ps_psp_pnr TO xmspr_key-pspnr.
*   Projektbestand lesen
    READ TABLE xmspr WITH KEY xmspr_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmspr TO xmcbest.
* anonym bewerteter Kundenauftragsbestand
      IF xmcmseg-kzbws EQ 'A'.
        xmcbest-labst = xmcbest-prlab.
        xmcbest-insme = xmcbest-prins.
        xmcbest-speme = xmcbest-prspe.
        xmcbest-einme = xmcbest-prein.
      ENDIF.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.

ENDFORM.                               " STA_BESTAND_MSPR

*&---------------------------------------------------------------------*
*&      Form  sta_bestand_mkol
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sta_bestand_mkol.
  CHECK xmcmseg-sobkz = m.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmkol_key.
*   MTV-Bestand lesen aus MKOL mit Sobkz = 'M'
    READ TABLE xmkol WITH KEY xmkol_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmkol TO xmcbest.
      MOVE xmkol-slabs TO xmcbest-mtv_l.
      MOVE xmkol-sinsm TO xmcbest-mtv_i.
      MOVE xmkol-sspem TO xmcbest-mtv_s.
      MOVE xmkol-seinm TO xmcbest-mtv_e.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.

ENDFORM.                               " sta_bestand_mkol

*&---------------------------------------------------------------------*
*&      Form  sta_bestand_mska
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sta_bestand_mska.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmska_key.
    MOVE xmcmseg-kdauf TO xmska_key-vbeln.
    MOVE xmcmseg-kdpos TO xmska_key-posnr.
*   Kundenauftragsbestand
    READ TABLE xmska WITH KEY xmska_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmska TO xmcbest.
* anonym bewerteter Kundenauftragsbestand
      IF xmcmseg-kzbws EQ 'A'.
        xmcbest-labst = xmcbest-kalab.
        xmcbest-insme = xmcbest-kains.
        xmcbest-speme = xmcbest-kaspe.
        xmcbest-einme = xmcbest-kaein.
      ENDIF.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x. .
  ENDIF.

ENDFORM.                               " sta_bestand_mska
*&---------------------------------------------------------------------*
*&      Form  WERT_ERMITTELN_EBEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM wert_ermitteln_ebew.

  READ TABLE xebew WITH KEY matnr = xmcbest-matnr
                            bwkey = xmcmseg-bwkey
                            bwtar = space
                            sobkz = xmcbest-sobkz
                            vbeln = xmcbest-vbeln
                            posnr = xmcbest-posnr
                            curtp = curtp10.
  IF sy-subrc = 0.
    MOVE xebew-sobkz TO xmcbest-sobkz.
    MOVE xebew-bwtty TO xmcbest-bwtty.
    MOVE xebew-bklas TO xmcbest-eklas.
    MOVE xebew-salk3 TO xmcbest-salk3_e.
    MOVE xebew-lbkum TO xmcbest-lbkum_e.
  ELSE.
    READ TABLE xmbew WITH KEY matnr = xmcbest-matnr
                              bwkey = xmcmseg-bwkey
                              bwtar = space
                              sobkz = space
                              curtp = curtp10.
    IF sy-subrc EQ 0.
      MOVE 'E'         TO xmcbest-sobkz.
      MOVE xmbew-bwtty TO xmcbest-bwtty.
      MOVE xmbew-bklas TO xmcbest-eklas.
      MOVE xmbew-salk3 TO xmcbest-salk3.
      MOVE xmbew-lbkum TO xmcbest-lbkum.
    ENDIF.
  ENDIF.

ENDFORM.                               " WERT_ERMITTELN_EBEW

*&---------------------------------------------------------------------*
*&      Form  WERT_ERMITTELN_QBEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM wert_ermitteln_qbew.
  READ TABLE xqbew WITH KEY matnr = xmcbest-matnr
                            bwkey = xmcmseg-bwkey
                            bwtar = space
                            sobkz = xmcbest-sobkz
                            pspnr = xmcbest-pspnr
                            curtp = curtp10.
  IF sy-subrc = 0.
    MOVE xqbew-sobkz TO xmcbest-sobkz.
    MOVE xqbew-bwtty TO xmcbest-bwtty.
    MOVE xqbew-bklas TO xmcbest-qklas.
    MOVE xqbew-salk3 TO xmcbest-salk3_q.
    MOVE xqbew-lbkum TO xmcbest-lbkum_q.
  ELSE.
    READ TABLE xmbew WITH KEY matnr = xmcbest-matnr
                              bwkey = xmcmseg-bwkey
                              bwtar = space
                              sobkz = space
                              curtp = curtp10.
    IF sy-subrc EQ 0.
      MOVE 'Q'         TO xmcbest-sobkz.
      MOVE xmbew-bwtty TO xmcbest-bwtty.
      MOVE xmbew-bklas TO xmcbest-qklas.
      MOVE xmbew-salk3 TO xmcbest-salk3.
      MOVE xmbew-lbkum TO xmcbest-lbkum.
    ENDIF.
  ENDIF.

ENDFORM.                               " WERT_ERMITTELN_QBEW
*                                                                     *
*       FORM STA_BESTAND_MSTB                                         *
*                                                                     *
*       Lesen der Kundensonderbestände                                *
*                                                                     *
FORM sta_bestand_mstb.
  CLEAR: xmcbest, xmcbest_key, xmcmseg-lgort.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmstb_key.
*     Kundensonderbestände lesen
    READ TABLE xmstb WITH KEY xmstb_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmstb TO xmcbest.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.                    "sta_bestand_mstb
*
*       FORM STA_BESTAND_MSTE
*
*       bewerteter WE-Sperrbestand, Kundenauftrag, Transit
*
FORM sta_bestand_mste.
  CLEAR: xmcbest, xmcbest_key, xmcmseg-lgort.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmste_key.
*     Kundensonderbestände lesen
    READ TABLE xmste WITH KEY xmste_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmste TO xmcbest.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.                    "sta_bestand_mste
*
*       FORM STA_BESTAND_MSSA
*
*       bewerteter WE-Sperrbestand, Kundenauftrag, Transit
*
FORM sta_bestand_mssa.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.              " Hinweis 323638
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmssa_key.
*     Kundensonderbestände lesen
    READ TABLE xmste WITH KEY xmssa_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmssa TO xmcbest.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.                    "sta_bestand_mssa
*                                                                     *
*       FORM STA_BESTAND_MSSQ                                         *
*                                                                     *
*       bewerteter WE-Sperrbestand, Projekt, Transit                  *
*                                                                     *
FORM sta_bestand_mssq.
  CLEAR: xmcbest, xmcbest_key.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.
   READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
   IF sy-subrc IS INITIAL.              " Hinweis 323638
     xmcmseg-matkl = xmcbest-matkl.
     xmcmseg-bklas = xmcbest-bklas.
   ELSE.
     index_l = sy-tabix.
     MOVE-CORRESPONDING xmcmseg TO xmssq_key.
*     Kundensonderbestände lesen
     READ TABLE xmste WITH KEY xmssq_key BINARY SEARCH.
     IF sy-subrc IS INITIAL.
       MOVE-CORRESPONDING xmssq TO xmcbest.
     ENDIF.
     PERFORM sta_mcbest_fuellen.
     INSERT xmcbest INDEX index_l.
     mcbest_flg = x.
   ENDIF.
 ENDFORM.                    "sta_bestand_mssq
*                                                                     *
*       FORM STA_BESTAND_MSTQ                                         *
*                                                                     *
*       bewerteter WE-Sperrbestand, Projekt, Transit                  *
*                                                                     *
FORM sta_bestand_mstq.
  CLEAR: xmcbest, xmcbest_key, xmcmseg-lgort.
  MOVE-CORRESPONDING xmcmseg TO xmcbest_key.

  MOVE xmcmseg-ps_psp_pnr TO xmcbest_key-pspnr.
  MOVE xmcmseg-kdauf      TO xmcbest_key-vbeln.
  MOVE xmcmseg-kdpos      TO xmcbest_key-posnr.

  READ TABLE xmcbest WITH KEY xmcbest_key BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    xmcmseg-matkl = xmcbest-matkl.
    xmcmseg-bklas = xmcbest-bklas.
  ELSE.
    index_l = sy-tabix.
    MOVE-CORRESPONDING xmcmseg TO xmstq_key.
*     Kundensonderbestände lesen
    READ TABLE xmstq WITH KEY xmstq_key BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING xmstq TO xmcbest.
    ENDIF.
    PERFORM sta_mcbest_fuellen.
    INSERT xmcbest INDEX index_l.
    mcbest_flg = x.
  ENDIF.
ENDFORM.                    "sta_bestand_mstq
