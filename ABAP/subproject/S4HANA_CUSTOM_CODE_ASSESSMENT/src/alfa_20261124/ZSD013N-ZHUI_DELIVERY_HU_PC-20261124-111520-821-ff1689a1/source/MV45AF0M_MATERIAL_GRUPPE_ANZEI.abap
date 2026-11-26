*----------------------------------------------------------------------*
*   INCLUDE FV45PF0M_MATERIAL_GRUPPE_ANZEI                             *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  FORM MATERIAL_AUSWAHLLISTE_MIT_ATP
*----------------------------------------------------------------------*
*    Bringt Popup mit uebergebenen Materialien und deren
*    Verfügbarkeit zum Wunschlieferdatum
*    Die Art der Anzeige ist steuerbar
*    Erlaubt die Auswahl eines Alternativmaterials.
*----------------------------------------------------------------------*
*    TABELLE(N)
*      t_mat_liste   Liste der alternativmaterialien mit
*                    Verkaufsmengeneinheit
*    PARAMETER
*      us_matnr      Urspruengliches Material
*      us_vrkme      Verkaufsmengeneinheit von urspruengl. Material
*      us_werk       Werk
*      us_wldat      Wunschlieferdatum
*      us_wlmeng     Wunschliefermenge
*      us_prgmodus   Programmmodus, steuert Verfuegbarkeitspruefung
*                    und Bedienelemente des Anzeigedialogs
*                    zulaessige Werte 'STANDARD', 'VARIANTEN'
*    us_anzeigetext  Text, der im Kopfbereich des Popups angezeigt
*                    wird
*      us_atp_check  Wenn initial, wird keine Verfuegbarkeitspruefung
*                    durchgefuehrt
*    us_avails_only  Nur verfuegbare Alternatrivmaterialien werden
*                    angezeigt
* us_auto_selection  Automatische Auswahl und kein Popup bei
*                    '1' wenn nur ein Material verfuegbar
*                    '2' erstes Material immer automatisch waehlen
*                    '3' wenn nur ein passendes Serviceprodukt zu einem
*                        Gerätematerial existiert
*      us_mabnr      Materialbestellnummer
*    RUECKGABE
*      ch_matnr      Ausgewaehltes Material
*      ch_vrkme      Verkaufsmengeneinheit des Materials
*      ch_autoselect Kennzeichen, Auswahl automatisch
*      ch_fcode      FCODE
*      ch_mabnr      Materialbestellnummer
*----------------------------------------------------------------------*
FORM MATERIAL_AUSWAHLLISTE_MIT_ATP
                          TABLES T_MAT_LISTE STRUCTURE MATS
                          USING  US_MATNR
                                 US_VRKME
                                 US_WERK
                                 US_WLDAT
                                 US_WLMENG
                                 US_PRGMODUS
                                 US_ANZEIGETEXT
                                 US_ATP_CHECK
                                 US_AVAILS_ONLY
                                 US_AUTO_SELECTION
                                 US_MABNR
                                 US_UEPOS
                          CHANGING
                                 CH_MATNR
                                 CH_VRKME
                                 CH_AUTOSELECTED
                                 CH_FCODE
                                 CH_MABNR.

  LOCAL: FCODE.
  DATA: DA_ARKTX LIKE MAT_LISTE-ARKTX,
        DA_NOT_AVAILABLE,
        DA_MSGNO TYPE N,
        DA_LINES LIKE SY-TABIX.

* Importdaten für Dynpro bereitstellen
  IF TVAK-ERMAT EQ CHARA.
*   es wird mit Materialbestellnummer gearbeitet
*   Materialbestellnummer anzeigen
    MAT_GRP_ANZEIG_KOPF-MATNR       = US_MABNR.
  ELSE.
    MAT_GRP_ANZEIG_KOPF-MATNR       = US_MATNR.
  ENDIF.
  MAT_GRP_ANZEIG_KOPF-VRKME       = US_VRKME.
  MAT_GRP_ANZEIG_KOPF-WERK        = US_WERK.
  MAT_GRP_ANZEIG_KOPF-WLDAT       = US_WLDAT.
  MAT_GRP_ANZEIG_KOPF-WLMENG      = US_WLMENG.
  MAT_GRP_ANZEIG_KOPF-ANZEIGETEXT = US_ANZEIGETEXT.
  PRGMODUS    = US_PRGMODUS.
  ATP_CHECK   = US_ATP_CHECK.

* Daten für TableControl bereitstellen

  REFRESH MAT_LISTE.
  CLEAR   MAT_LISTE.
  REFRESH SELKZ_LISTE.
  CLEAR   SELKZ_LISTE.
  LOOP AT T_MAT_LISTE.
    MOVE-CORRESPONDING T_MAT_LISTE TO MAT_LISTE.
* In MAT_LISTE fehlende Mengeneinheit aus Kopf ergaenzen
    IF MAT_LISTE-VRKME IS INITIAL.
      MAT_LISTE-VRKME = US_VRKME.
    ENDIF.
* Materialkurztext ergaenzen
    PERFORM MAKT_ERMITTELN(SAPLV07A) USING T_MAT_LISTE-MATNR DA_ARKTX.
    MOVE DA_ARKTX TO MAT_LISTE-ARKTX.
*   Materialbestellnummer ermitteln (falls Customizing TVAK-ERMAT = 'A')
    PERFORM RV45A_MABNR_ERMITTELN(SAPFV45P) USING    ' '
                                                     ' '
                                                     T_MAT_LISTE-MATNR
                                            CHANGING MAT_LISTE-MATWA.
* Gewuenschte Menge je Pos. fuer Verfuegbarkeitspruefung
    CASE PRGMODUS.
      WHEN 'STANDARD'.
*        move 9999999999 to mat_liste-reqqty.
        MOVE MAT_GRP_ANZEIG_KOPF-WLMENG TO MAT_LISTE-REQQTY.
      WHEN 'VARIANTEN'.
        MOVE MAT_GRP_ANZEIG_KOPF-WLMENG TO MAT_LISTE-REQQTY.
    ENDCASE.
    APPEND MAT_LISTE.
    MOVE SY-TABIX TO SELKZ_LISTE-TABIX.
    APPEND SELKZ_LISTE.
  ENDLOOP.
* Verfuegbarkeit pruefen
  IF NOT ATP_CHECK IS INITIAL.
    PERFORM CONFIGURATION_TYPE_AVAIL(SAPFV45S)
                TABLES MAT_LISTE
                USING  MAT_GRP_ANZEIG_KOPF-WLMENG
                       MAT_GRP_ANZEIG_KOPF-WLDAT
                       MAT_GRP_ANZEIG_KOPF-WERK
                       MAT_GRP_ANZEIG_KOPF-VRKME
                       US_UEPOS.

    CASE PRGMODUS.
      WHEN 'STANDARD'.
* Anzeigen der verfuegbaren Menge - auch ueber Wunschmenge hinaus
        LOOP AT MAT_LISTE.
          MOVE MAT_LISTE-FULLAVQTY TO MAT_LISTE-AVQTY.
          MODIFY MAT_LISTE.
        ENDLOOP.
    ENDCASE.
  ENDIF.

* Verfügbarkeitsergebnis verarbeiten / Steuerparameter interpretieren
* nur verfügbare
  IF NOT US_AVAILS_ONLY IS INITIAL.
    DELETE MAT_LISTE WHERE AVQTY <> US_WLMENG.
  ENDIF.

  DESCRIBE TABLE MAT_LISTE LINES DA_LINES.
  CHECK DA_LINES > 0.

* Automatische Selektion
  CASE US_AUTO_SELECTION.
    WHEN CHAR1. " automatisch wenn eine verfuegbare gefunden
      IF DA_LINES = 1.
        READ TABLE MAT_LISTE INDEX 1.
        IF MAT_LISTE-AVQTY >= US_WLMENG.
          CH_MATNR = MAT_LISTE-MATNR.
          CH_VRKME = MAT_LISTE-VRKME.
          CH_AUTOSELECTED = CHARX.
          EXIT.
        ENDIF.
      ENDIF.
    WHEN CHAR2.                        " automatisch erste verfuegbare
      IF DA_LINES > 0.
        READ TABLE MAT_LISTE INDEX 1.
        IF MAT_LISTE-AVQTY >= US_WLMENG.
          CH_MATNR = MAT_LISTE-MATNR.
          CH_VRKME = MAT_LISTE-VRKME.
          CH_AUTOSELECTED = CHARX.
          EXIT.
        ENDIF.
      ENDIF.
    WHEN CHAR3.
*   automatisch erstes Produkt, wenn nur ein passendes Serviceprodukt
*   zu einem Gerätematerial existiert
      IF ATP_CHECK IS INITIAL.
        IF DA_LINES = 1.
*       bei nur einem passenden Serviceprodukt wird dieses sofort ohne
*       Popup mit Auswahlliste übernommen
          READ TABLE MAT_LISTE INDEX 1.
          CH_MATNR = MAT_LISTE-MATNR.
          CH_VRKME = MAT_LISTE-VRKME.
          CH_AUTOSELECTED = CHARX.
          EXIT.
        ENDIF.
      ENDIF.
  ENDCASE.

* Auswahldialog anzeigen
  TCTRL_MAT_GRP_ANZEIG_LIN1 = 1.
  CALL SCREEN 0800 STARTING AT 10 2
                  ENDING   AT 111 20.

* Auswahlwerte aus Dialog zurueckgeben
  IF TVAK-ERMAT EQ CHARA OR TVAK-ERMAT EQ CHARB.
*   es wird mit Materialbestellnummer gearbeitet
*   -> es muß mit dem Material weitergearbeitet werden
    IF MAT_GRP_ANZEIG_KOPF-MATNR EQ US_MABNR.
*     PopUp wurde abgebrochen
*     -> MAT_GRP_ANZEIG_KOPF-MATNR enthält Materialbestellnr
*     -> mit ursprünglichem Material weiterarbeiten
      CH_MATNR = US_MATNR.
    ELSE.
      CH_MABNR = MAT_LISTE-MATWA.
      CH_MATNR = MAT_GRP_ANZEIG_KOPF-MATNR.
    ENDIF.
  ELSE.
    CH_MATNR = MAT_GRP_ANZEIG_KOPF-MATNR.
  ENDIF.
  CH_VRKME = MAT_GRP_ANZEIG_KOPF-VRKME.
  CH_FCODE = SY-UCOMM.

ENDFORM.