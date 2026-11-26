*---------------------------------------------------------------------*
*        PBO-Module zum Modulpool SAPMM07M                            *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE AKTIV_PRUEFEN OUTPUT                                   *
*---------------------------------------------------------------------*
*       Init auf XAKTIV, das unter PAI gesetzt wird, wenn mindenstens *
*       ein Eintrag auf einem 'FUSS-PopUp' gesetzt wird.              *
*       Ausserdem wird das KEINE_EINGABE zurückgesetzt, über das ge-  *
*       steuert wurde, ob der Lieferant im Dialogfenster 1201 eingabe-*
*       bereit ist oder nicht.                                        *
*---------------------------------------------------------------------*
MODULE aktiv_init OUTPUT.

  CLEAR xaktiv.
  CLEAR keine_eingabe.

  IF t158-kzbew = b AND anf_bild IS INITIAL AND
     ( NOT am07m-lifnr IS INITIAL OR NOT am07m-reswk IS INITIAL ).
    DATA: loc_lifnr LIKE am07m-lifnr,
          loc_reswk LIKE am07m-reswk.
    loc_lifnr = am07m-lifnr.
    loc_reswk = am07m-reswk.
  ENDIF.

  PERFORM suchfelder_init.

  am07m-lifnr = loc_lifnr.
  am07m-reswk = loc_reswk.
  CLEAR: loc_lifnr, loc_reswk.

ENDMODULE.                    "AKTIV_INIT OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE ANZAHL_PRUEFEN OUTPUT                                  *
*---------------------------------------------------------------------*
*       Bei Positionieren... wird geprüft, ob mindentens 2 Einträge   *
*       in einer Tabelle vorhanden sind. Ist dies nicht der Fall,     *
*       wird das PopUp dunkel durchlaufen.                            *
*---------------------------------------------------------------------*
MODULE anzahl_pruefen OUTPUT.

  CLEAR index_z.
  IF fcausw-xselp IS INITIAL.
    DESCRIBE TABLE ymseg LINES index_z.
  ELSE.
    DESCRIBE TABLE fuss LINES index_z.
  ENDIF.
  IF index_z = 1 AND gv_flag_kayak_active IS INITIAL.
    SUPPRESS DIALOG.
  ENDIF.

ENDMODULE.                    "ANZAHL_PRUEFEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE BELEGKOPF_VORSCHLAG OUTPUT                             *
*---------------------------------------------------------------------*
*       Defaultwerte fuer den Belegkopf ermitteln.                    *
*---------------------------------------------------------------------*
MODULE belegkopf_vorschlag OUTPUT.

  PERFORM belegkopf_vorschlag.

ENDMODULE.                    "BELEGKOPF_VORSCHLAG OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE BEWEGUNGSART_MERKEN OUTPUT                             *
*---------------------------------------------------------------------*
*       Die Bewegungsart, Sonderbestand, Werk und Lagerort werden ge- *
*       merkt, für den Fall, daß das PopUp abgebrochen wird.          *
*---------------------------------------------------------------------*
MODULE bewegungsart_merken OUTPUT.

  IF t158-kzbew IS INITIAL OR xkzbew = 1.
    IF old_bwartwa IS INITIAL.
      old_bwartwa = rm07m-bwartwa.
      old_sobkz   = rm07m-sobkz.
    ENDIF.
  ELSE.
    IF old_bwartwe IS INITIAL.
      old_bwartwe = rm07m-bwartwe.
    ENDIF.
  ENDIF.
  old_werks = rm07m-werks.
  old_lgort = rm07m-lgort.

  IF NOT sy-binpt IS INITIAL.                               "694553
    CLEAR rm07m-sobkz.                                      "694553
  ENDIF.                                                    "694553

ENDMODULE.                    "BEWEGUNGSART_MERKEN OUTPUT
*eject
*----------------------------------------------------------------------*
*     Kennzeichen für gebremste Auflösung wird gesetzt                 *
*----------------------------------------------------------------------*
MODULE brems_x_setzen OUTPUT.

  rm07m-brems = x.

ENDMODULE.                    "BREMS_X_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE CURSOR_POSITIONIEREN                                   *
*---------------------------------------------------------------------*
*       Cursor auf gewuenschtes Feld positionieren                    *
*---------------------------------------------------------------------*
MODULE cursor_positionieren OUTPUT.

  PERFORM cursor_positionieren.

ENDMODULE.                    "CURSOR_POSITIONIEREN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE DUNKEL_PRUEFEN                                         *
*---------------------------------------------------------------------*
*       Das Dynpro wird zur Kontierungsprüfung dunkel durchlaufen.    *
*---------------------------------------------------------------------*
MODULE dunkel_pruefen OUTPUT.

  IF fcode_next IS INITIAL.
    SUPPRESS DIALOG.
    fcode_next = fcod-ab(20).
  ENDIF.

ENHANCEMENT-POINT mm07mo00_02 SPOTS es_sapmm07m.
ENDMODULE.                    "DUNKEL_PRUEFEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE DUNKEL_SCHALTEN                                        *
*---------------------------------------------------------------------*
*       Das Dynpro zur Einzelposition wird dunkel abgearbeitet, wenn  *
*       im Listbild keine Selektion getroffen wurde und die Eingaben  *
*       in den einzelnen Listbildpositionen korrekt sind.             *
*---------------------------------------------------------------------*
MODULE dunkel_schalten OUTPUT.

  IF hell IS INITIAL.
    SUPPRESS DIALOG.
    hell = x.
  ENDIF.

ENDMODULE.                    "DUNKEL_SCHALTEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE DYPRO_MODIFIZ_LOOP                                     *
*---------------------------------------------------------------------*
*       Dynpro-Modifikation im SCREEN-LOOP                            *
*---------------------------------------------------------------------*
MODULE dynpro_modifiz_loop OUTPUT.

  vw = x.
  IF mseg-matnr IS INITIAL  AND
     ( mseg-xauto = l  OR  mseg-xauto = f  OR  mseg-xauto = m  OR
       mseg-xauto = w ).
    CLEAR: mseg-xauto,
           mseg-urzei.
  ENDIF.
  PERFORM dynpro_modifizieren(sapfm07m) USING vw dm07m-fausw.
  CLEAR vw.

ENDMODULE.                    "DYNPRO_MODIFIZ_LOOP OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE DYPRO_MODIFIZIEREN                                     *
*---------------------------------------------------------------------*
*       Dynpro-Modifikation ausserhalb des SCREEN-LOOP                *
*---------------------------------------------------------------------*
MODULE dynpro_modifizieren OUTPUT.

  vw = space.
  PERFORM dynpro_modifizieren(sapfm07m) USING vw dm07m-fausw.

ENDMODULE.                    "DYNPRO_MODIFIZIEREN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE DYPROFELDER_LOESCHEN                                   *
*---------------------------------------------------------------------*
*       Dynprofelder werden geloescht, wenn sie ueber die Dynpromodi- *
*       fikation ausgeblendet wurden, aber nicht initial sind.        *
*---------------------------------------------------------------------*
MODULE dynp_felder_loeschen OUTPUT.

  PERFORM dynprofelder_loeschen(sapfm07m).

ENDMODULE.                    "DYNP_FELDER_LOESCHEN OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE FRACHTLIEFERANT_LESEN                                   *
*----------------------------------------------------------------------*
MODULE f_lieferant_lesen OUTPUT.
  PERFORM f_lieferant_lesen.
ENDMODULE.                    "F_LIEFERANT_LESEN OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE FRACHTLIEFERANT_SETZEN                                  *
*----------------------------------------------------------------------*
MODULE f_lieferant_setzen OUTPUT.
  PERFORM f_lieferant_setzen.
ENDMODULE.                    "F_LIEFERANT_SETZEN OUTPUT
*eject
*----------------------------------------------------------------------*
*       Module  JV_CRP_ON_OFF  OUTPUT                                  *
*----------------------------------------------------------------------*
*       JVA PBO-Modul                                                  *
*----------------------------------------------------------------------*
MODULE jv_crp_on_off OUTPUT.

  PERFORM jv_crp_cal_on_off.

ENDMODULE.                    "JV_CRP_ON_OFF OUTPUT
*eject
*----------------------------------------------------------------------*
*       OODULE LIEFERANT_SETZEN                                        *
*----------------------------------------------------------------------*
* Lieferant setzen, sofern man sich nicht auf dem Anforderungsbild be- *
* findet.                                                              *
*----------------------------------------------------------------------*
MODULE lieferant_setzen OUTPUT.

  CHECK t158-kzbew = b.
  IF anf_bild IS INITIAL AND
     ( NOT am07m-lifnr IS INITIAL OR NOT am07m-reswk IS INITIAL ).
    keine_eingabe = x.
  ENDIF.

ENDMODULE.                    "LIEFERANT_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE KONTBLOCK_ERMITTELN                                    *
*---------------------------------------------------------------------*
*       Es werden alle Felder der Struktur COBL ermittelt, die        *
*       in der Feldauswahlleiste enthalten sind.                      *
*---------------------------------------------------------------------*
MODULE kontblock_ermitteln OUTPUT.

  PERFORM kontblock_ermitteln.

ENDMODULE.                    "KONTBLOCK_ERMITTELN OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE KONTIERUNG_INIT                                         *
*----------------------------------------------------------------------*
*       Die Daten für MSEGK werden gesetzt.                            *
*----------------------------------------------------------------------*
MODULE kontierung_init OUTPUT.

  PERFORM kontierung_init.

ENDMODULE.                    "KONTIERUNG_INIT OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE XKZBEW_STATUS_SETZEN                                    *
*----------------------------------------------------------------------*
*       Der Status unter der die Verarbeitung abläuft wird gesetzt.    *
*----------------------------------------------------------------------*
MODULE xkzbew_status_setzen OUTPUT.

  CHECK t158-kzbew = b.
  old_xkzbew = xkzbew.
  IF sy-dynnr = 1403 OR sy-dynnr = 1406.
    xkzbew = 1.
    CLEAR: rm07m-kzbew,
           mseg-kzbew.
  ELSE.
    CLEAR xkzbew.
    rm07m-kzbew = t158-kzbew.
  ENDIF.

ENDMODULE.                    "XKZBEW_STATUS_SETZEN OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE MEINS_SETZEN                                           *
*----------------------------------------------------------------------*
*       Für Verfügbarkeitsanzeige in MB11 wird Mengeneinheit gesetzt.  *
*----------------------------------------------------------------------*
MODULE meins_setzen OUTPUT.

  PERFORM meins_setzen.

ENDMODULE.                    "MEINS_SETZEN OUTPUT
*eject
*----------------------------------------------------------------------*
*       MODULE MTV_LIEFERANT_SETZEN                                    *
*----------------------------------------------------------------------*
*       Bei WE zur Bestellung und erfassen von Positionen ohne         *
*       Bestellung wird der Lieferant der Bestellung vorgeschlagen.    *
*----------------------------------------------------------------------*
MODULE mtv_lieferant_setzen OUTPUT.

  CHECK t158-kzbew = b AND aktyp = h AND mseg-xauto IS INITIAL.
  IF fcausw-xlist IS INITIAL.
    IF mseg-lifnr IS INITIAL.
      mseg-lifnr = am07m-lifnr.
    ENDIF.
  ELSE.
    IF msegk-lifnr IS INITIAL.
      msegk-lifnr = am07m-lifnr.
    ENDIF.
  ENDIF.

ENDMODULE.                    "MTV_LIEFERANT_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE PFSTATUS_SETZEN                                        *
*---------------------------------------------------------------------*
*       Der PF-Status wird gesetzt.                                   *
*---------------------------------------------------------------------*
MODULE pfstatus_setzen OUTPUT.

  PERFORM pfstatus_setzen.

ENDMODULE.                    "PFSTATUS_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE PFSTATUS_POP_SETZEN                                    *
*---------------------------------------------------------------------*
*       Der PF-Status für ein PopUp wird gesetzt.                     *
*---------------------------------------------------------------------*
MODULE pfstatus_pop_setzen OUTPUT.
  CLEAR ok-code.
  pfsta = t063c-pfsta.
  tit   = t063c-title.
  REFRESH excl.
  IF t156-xnebe IS INITIAL.
    excl-funktion = 'NEBE'.
    APPEND excl.
  ENDIF.
  IF NOT old_pfsta IS INITIAL AND t063c-pfsta IS INITIAL.
    SET PF-STATUS old_pfsta.
    SET TITLEBAR old_tit.
    pfsta = old_pfsta.
    tit   = old_tit.
    CLEAR: old_pfsta, old_tit.
  ELSE.
    SET PF-STATUS pfsta EXCLUDING excl.
    SET TITLEBAR tit.
  ENDIF.
  IF t158-kzbew = o AND pfsta = 'POPU'.
    pfsta = 'POPO'.
    SET PF-STATUS pfsta.
  ENDIF.
ENDMODULE.                    "PFSTATUS_POP_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE PICKUP_INIT                                            *
*---------------------------------------------------------------------*
*       Zuruecksetzen des Feldes XPF02.                               *
*---------------------------------------------------------------------*
MODULE pickup_init OUTPUT.

  CLEAR aufsetzen.
  CLEAR xmate.
  IF xpf02 = b AND fcausw-xlist IS INITIAL.
    READ TABLE old INDEX 1.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING old TO mseg.
    ENDIF.
  ENDIF.
  CLEAR: xpf02,
         old.
  REFRESH old.

ENDMODULE.                    "PICKUP_INIT OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE POSITION_SETZEN                                        *
*---------------------------------------------------------------------*
*       Positionsnummer setzen bei Erfassen Warenbewegung             *
*       Pruefung gegen die maximale Zahl Positionen, die im           *
*       MM07MCOM im Standard mit 200 definiert sind.                  *
*---------------------------------------------------------------------*
MODULE position_setzen OUTPUT.

  PERFORM position_setzen.
  IF fcausw-xlist IS INITIAL.
    IF dm07m-btext IS INITIAL.
      PERFORM bewegungstext_lesen(sapfm07m) USING  mseg-bwart
                                                   mseg-sobkz
                                                   mseg-kzbew
                                                   mseg-kzzug
                                                   mseg-kzvbr
                                                  dm07m-btext.
    ENDIF.
    IF dm07m-maktx IS INITIAL AND NOT mseg-matnr IS INITIAL.
      DATA: mbefu2 LIKE mbefu.
      mbefu2 = mbefu.
      PERFORM kurztext_lesen(sapfm07m) USING mseg-matnr.
      IF NOT  mtcor-rmakt IS INITIAL.
        mbefu = mbefu2.
      ENDIF.
      dm07m-maktx = mbefu-maktx.
    ENDIF.
  ENDIF.
  PERFORM fill_erfme_erfmg_menge(sapfm07m) USING x.    "ALRK SW
ENDMODULE.                    "POSITION_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE SEND_PBO                                               *
*---------------------------------------------------------------------*
*       Entsprechen der Bildsteuerung der Felder für den              *
*       Kontierungsblock (Tabellen T156B und TCOBX) wird              *
*       ein geeigneter Subscreen gesucht.                             *
*---------------------------------------------------------------------*
MODULE send_pbo OUTPUT.

  PERFORM kontierungsblock_send_pbo.

ENDMODULE.                    "SEND_PBO OUTPUT
*eject
*----------------------------------------------------------------------*
*       Module  SUBSCREEN_ERMITTELN  OUTPUT
*----------------------------------------------------------------------*
*       Das Module ermittelt die gültige Subscreen Nummer in           *
*       Abhängigkeit vom Sonderbestandskennzeichen                     *
*----------------------------------------------------------------------*
MODULE subscreen_ermitteln OUTPUT.

  DATA: sobkz LIKE mseg-sobkz,
        umsok LIKE mseg-umsok,
        dynnr_u LIKE tcobl-dynnr VALUE   2400.    "Subscreens Umlag.
  IF sy-dynnr EQ 410 OR sy-dynnr EQ 421 OR sy-dynnr EQ 231
     OR sy-dynnr EQ 1406 .
    CLEAR sobkz.
    CLEAR umsok.
    IF t158-trtyp EQ a OR fcausw-xlist IS INITIAL.
      sobkz = mseg-sobkz.
      IF sobkz IS INITIAL.
        sobkz = rm07m-sobkz.
      ENDIF.
      umsok = mseg-umsok.
      IF umsok IS INITIAL.
        umsok = mseg-sobkz.
        IF umsok IS INITIAL.
          umsok = rm07m-sobkz.
        ENDIF.
      ENDIF.
    ELSE.
      sobkz = msegk-sobkz.
*     umsok = msegk-umsok.
*     umsok = msegk-sobkz.
    ENDIF.
*   if ( mseg-umsok eq e or mseg-umsok eq q ) .
*     if sobkz is initial.
*       sobkz = mseg-umsok.
*     elseif ( sobkz eq e or sobkz eq q ) and
*           sobkz ne mseg-umsok.
*       message e015.
*     endif.
*   endif.
ENHANCEMENT-SECTION     mm07mo00_03 SPOTS es_sapmm07m.
    IF fcausw-xlist IS INITIAL.
      CASE sobkz.
        WHEN e.
          dynnr = 2403.
        WHEN q.
          dynnr = 2404.
        WHEN t.              "SIT
          dynnr = 2406.
        WHEN OTHERS.
          dynnr = 2400.
      ENDCASE.
      CASE umsok.
        WHEN e.
          dynnr_u = 2401.
        WHEN q.
          dynnr_u = 2402.
        WHEN t.               "SIT
          dynnr_u = 2405.
        WHEN OTHERS.
          dynnr_u = 2400.
      ENDCASE.
      IF t156-bustr = '559'.  "SIT    "1657162
         dynnr = 2406.                "1657162
      ENDIF.                          "1657162
    ELSE.
      CASE sobkz.
        WHEN e.
*         dynnr = 2421.
          dynnr = 2423.
        WHEN q.
*         dynnr = 2422.
          dynnr = 2424.
        WHEN t.                "SIT
*         dynnr = 2421.
          dynnr = 2425.
        WHEN OTHERS.
         dynnr = 2400.
      ENDCASE.
*     case umsok.
*       when e.
*         dynnr_u = 2421.
*       when q.
*         dynnr_u = 2422.
*       when others.
*         dynnr_u = 2400.
*   endcase.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ELSEIF sy-dynnr EQ 210.
    IF vm07m-pstyp EQ sieben.
      dynnr = 2202.
    ELSE.
      dynnr = 2201.
ENHANCEMENT-POINT mm07mo00_04 SPOTS es_sapmm07m.
    ENDIF.
  ENDIF.
  CLEAR: sobkz, umsok.

ENDMODULE.                    "SUBSCREEN_ERMITTELN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE TRANSAKTIONS_INIT                                      *
*---------------------------------------------------------------------*
*       Pruefung, ob Transaktion in der Tabelle 158 vorhanden ist.    *
*       Wenn ja, ermitteln des Transaktionstextes aus Tabelle STCT.   *
*---------------------------------------------------------------------*
MODULE transaktions_init OUTPUT.

  def_break 'TRANSAKTIONS_INIT (Module)'.                   "#EC *
  BREAK-POINT ID mb_transaktions_init.

  IF sy-calld IS INITIAL.
    GET PARAMETER ID 'POS' FIELD rm07m-zeile.
    IF NOT rm07m-zeile IS INITIAL.
      CLEAR rm07m-zeile.
      SET PARAMETER ID 'POS' FIELD rm07m-zeile.
    ENDIF.
  ENDIF.
  PERFORM transaktions_init.

ENDMODULE.                    "TRANSAKTIONS_INIT OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE VERFUEG_ANZEIGEN                                       *
*---------------------------------------------------------------------*
*       Der Verfuegbarkeitsblock wird angezeigt.                      *
*---------------------------------------------------------------------*
MODULE verfueg_anzeigen OUTPUT.
  DATA: ls_isu_verfuegbarkeit_anzeigen TYPE isu_verfuegbarkeit_anzeigen.
                                                            "IS2ERP

  IF NOT dm07m-anzre IS INITIAL.
    PERFORM verfuegbarkeit_anzeigen
                           USING ls_isu_verfuegbarkeit_anzeigen."IS2ERP
  ENDIF.

ENDMODULE.                    "VERFUEG_ANZEIGEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE VERFUEG_UEBERNEHMEN                                    *
*---------------------------------------------------------------------*
*       Die Daten fuer die Verfuegbarkeitsanzeige werden ermittelt.   *
*---------------------------------------------------------------------*
MODULE verfueg_uebernehmen OUTPUT.

  PERFORM verfuegbarkeit_uebernehmen.

ENDMODULE.                    "VERFUEG_UEBERNEHMEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE XKZBW_SETZEN                                           *
*---------------------------------------------------------------------*
*       Kennzeichen, das T156-KZBWA relevant ist, wird gesetzt.       *
*---------------------------------------------------------------------*
MODULE xkzbw_setzen OUTPUT.

  xkzbw = x.
  xbcode = x.

ENDMODULE.                    "XKZBW_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE XKZBW_N_SETZEN                                         *
*---------------------------------------------------------------------*
*       Kennzeichen, daß T156-KZBWA nicht erlaubt wird, wird gesetzt. *
*---------------------------------------------------------------------*
MODULE xkzbw_n_setzen OUTPUT.

  xkzbw  = n.
  xbcode = x.

ENDMODULE.                    "XKZBW_N_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE XKZBEW_1_SETZEN                                        *
*---------------------------------------------------------------------*
*       Kennzeichnet Dynpro SAPMM07M/0231...                          *
*---------------------------------------------------------------------*
MODULE xkzbew_1_setzen OUTPUT.

  xkzbew = 1.

ENDMODULE.                    "XKZBEW_1_SETZEN OUTPUT
*eject
*---------------------------------------------------------------------*
*       MODULE XKZBEW_3_SETZEN                                        *
*---------------------------------------------------------------------*
*       Kennzeichnet Dynpro SAPMM07M/0241...                          *
*---------------------------------------------------------------------*
MODULE xkzbew_3_setzen OUTPUT.

  xkzbew = 3.

ENDMODULE.                    "XKZBEW_3_SETZEN OUTPUT
*eject

*&---------------------------------------------------------------------*

*&      Module  ME2O_SET_DEFAULT_VALUES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* Batch-Management in Subcontracting (components)
MODULE me2o_set_default_values OUTPUT.                        " SC-batch
* Set default value of "MAT" used in the matchcodes of the dynpro
  SET PARAMETER ID 'MAT' FIELD mseg-matnr.                    " SC-batch
* Set default value of "WRK" used in the matchcodes of the dynpro
  SET PARAMETER ID 'WRK' FIELD mseg-werks.                   " SC-batch
ENDMODULE.                 " ME2O_SET_DEFAULT_VALUES  OUTPUT

*---------------------------------------------------------------------*
*       MODULE MAP_MSEG_MSEGK_TO_GOITEM                               *
*---------------------------------------------------------------------*
*       Dynpro-Modifikation ausserhalb des SCREEN-LOOP                *
*---------------------------------------------------------------------*
MODULE MAP_MSEG_MSEGK_TO_GOITEM OUTPUT.

  IF mseg-sobkz = t.
    dm07m-vbeln_vl = msegk-mat_kdauf.
    dm07m-vbelp_vl = msegk-mat_kdpos.
  ELSEIF mseg-umsok = t.
    dm07m-vbeln_vl = mseg-kdauf.
    dm07m-vbelp_vl = mseg-kdpos.
  ENDIF.

ENDMODULE.                    "DYNPRO_MODIFIZIEREN OUTPUT

ENHANCEMENT-POINT mm07mo00_05 SPOTS es_sapmm07m STATIC .