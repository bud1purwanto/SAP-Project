*----------------------------------------------------------------------*
*   INCLUDE MM07MFBC                                                   *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       Form  ALTERNATIVE_MENGEN
*----------------------------------------------------------------------*
* Erweiterte Mengenumrechnung mit Anzeige und Fehlerprüfung            *
* Voraussetzung: Materialkennzeichen KZWSO: A/B aus Matstamm           *
*                Customizingschalter KZDWS aktiviert                   *
*----------------------------------------------------------------------*
FORM alternative_mengen  USING i_no_dialog TYPE c
                               IS_ENHANCEMENT TYPE ISU_ALTERNATIVE_MENGEN."IS2ERP

ENHANCEMENT-POINT ALTERNATIVE_MENGEN_10 SPOTS ES_SAPMM07M STATIC .

ENHANCEMENT-POINT ALTERNATIVE_MENGEN_01 SPOTS ES_SAPMM07M.

*-No conversion and no checks if goods movement is called via MB_Create
* with XNOCON
  CHECK dm07m-xnocon IS INITIAL.

*-Anteils-/variable Mengeneinheiten aktiv?
  DATA: LS_ISU_MENGE_UMRECHNEN TYPE ISU_MENGE_UMRECHNEN.    "IS2ERP
  DATA: L_UMWSO LIKE DM07M-KZWSO.
  PERFORM read_kzwso(sapfm07m) CHANGING dm07m-kzwso
                                        l_umwso.
  IF NOT mbefu-matnr IS INITIAL AND mseg-matnr EQ mbefu-matnr."ALRK74852
    dm07m-kzwso = mbefu-kzwsm.
  ENDIF.
*-Ausstieg falls nicht gleichzeitig im Customizing und am Material aktiv
  IF kzdws NE eins OR
   ( dm07m-kzwso IS INITIAL AND l_umwso IS INITIAL ).       "ALRK115218
    IF t063o-ok_code EQ ccod-mgum.                          "ALRK074852
      MESSAGE i008(xu).
*       Mengenumr. nur mgl., wenn Anteils-/variable Mengenumr. aktiviert
    ENDIF.
    EXIT.
  ENDIF.

* Lokale Daten
  DATA: l_menge LIKE mseg-menge,
        loc_feld(11),                                      "note 129198
        l_error_meinh LIKE mseg-meins, "UOM where error occurred
        l_kzcla_save LIKE dm07m-kzcla,
        l_xkcfc_save LIKE dm07m-xkcfc,
        l_aktyp_k TYPE c VALUE 'K',
        l_trtyp LIKE t158-trtyp,
        l_matnr LIKE mseg-matnr,
        l_charg LIKE mseg-charg,
        l_werks LIKE mseg-werks,
        l_posnr LIKE mseg-zeile,
        xhell,                   "X: Popup "unit conv" called by menu
        xhell_charg,             "X: Display Popup "unit conv" for CHARG
        xhell_umcha,             "X: Display Popup "unit conv" for UMCHA
        x_no_dialog,             "X: Only E-Messages, no popups
        x_no_classif,            "X: Do not show classif. in error hand-
                                 "   ling with transfer posting
        l_kzwso,
        xklassifizierung TYPE c, "X: Display of classif. possible in Pop
        xvalues_keep TYPE c,     "X: Use amount in base UOM from documen
        x_round_error,           "X: Rounding_error occured
        x_batch_exist,           "X: Batch exists already on DB
        x_already_posted,        "X: Batch was already posted
        x_chargenpflicht,        "X: Batch management for material&plant
        x_read_error,
        textmeinh(3),
        feld(11),
        l_menge_umcha LIKE mseg-menge,
        bwart_303 LIKE t156-bwart VALUE '303',
        okcode_abbr LIKE sy-ucomm VALUE 'ABBR'.             "ALRK074852
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_02 SPOTS ES_SAPMM07M.

*-Mengenumrechnung macht nur Sinn, wenn eine Menge erfaßt wurde
  CHECK NOT mseg-erfmg IS INITIAL.

*-Kennzeichen, ob Stahl oder Wirkstoffmaterial setzen
  l_kzwso = dm07m-kzwso.     "  xkzwso = 'A'.            "--> Wirkstoffe
  "  xkzwso = 'B'.            "--> Stahl

* Bei Batch-Input oder Aufruf von dialogfreiem FB --> kein Fehlerdialog
  IF NOT sy-binpt IS INITIAL OR NOT i_no_dialog IS INITIAL.
    x_no_dialog = x.
  ENDIF.

*   Schreiben in die Klassifikation im Korrekturmodus f. Paralleleingabe
  IF NOT fcausw-xaenp IS INITIAL.
    READ TABLE ymseg INDEX mseg-zeile.
    IF ymseg-menge NE mseg-menge OR
       ymseg-erfmg NE mseg-erfmg OR
       sy-subrc NE 0.
      PERFORM mengen_bewertung USING mseg.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_03 SPOTS ES_SAPMM07M.

*-Falls Mengenumr. über Menü gerufen --> Popup kommt immer
  IF t063o-ok_code = ccod-mgum.                             "ALRK074852
    xhell = x.
    CLEAR t063o-ok_code.                                    "ALRK074852
  ENDIF.

*-Transaktionstyp entweder Anzeigen oder Hinzufügen
  l_trtyp = t158-trtyp.
  IF l_trtyp NE h.
    l_trtyp = a.
  ENDIF.

* Im Beleg-Ändernkeine Mengenumrechnung, außer bei direktem Aufruf;
* Lagermenge sichern im Beleg-Ändern (darf nicht umgeschossen werden)
  IF t158-tcode EQ tcod-mb02.
    l_menge = mseg-menge.
    CHECK NOT xhell IS INITIAL.
    l_trtyp = a.                        "Umrechnung nur Anzeige
  ENDIF.

* Bei WE zur Bestellung wird Umrez/Umren aus Bestellung ignoriert
  IF mseg-kzbew EQ b.
    CLEAR: dm07m-umrez,
           dm07m-umren.
  ENDIF.

* Bei Umlagerung über Umlagerungsbuchung im Zweischrittverfahren werden
* Umren und Umrez gelöscht und die Nachkommaprüfung ist abgeschalten
* Grund: Die Charegnnr. und -klassifizierung sind hier nicht vorhanden,
* trotz Chargenpflicht); = Bewegungsart 303
  IF mseg-bwart EQ bwart_303.
    xvalues_keep = a.
  ENDIF.

* Bei Stornierung eines Materialbelegs darf nichts eingabebereit sein
ENHANCEMENT-SECTION     ALTERNATIVE_MENGEN_SUB_CANCEL SPOTS ES_SAPMM07M.
  IF  NOT mseg-mblnr IS INITIAL  AND
      vm07m-xstor = 2.        "Nur bei Belegstorno, nicht bei Ruecklief.
    l_trtyp = a.             "113514 and 360813
  ENDIF.
END-ENHANCEMENT-SECTION.

* Bei Inventurdifferenzbuchungen sollen keine Prüfungen erfolgen
* --> setze lokalen Transaktionstyp auf 'Anzeigen'
ENHANCEMENT-SECTION ALTERNATIVE_MENGEN_SUB_INV SPOTS ES_SAPMM07M .
  IF NOT inventur IS INITIAL OR
     NOT vm07m-xinvb IS INITIAL. "TA LI21  Note 506131
    l_trtyp = a.
  ENDIF.
END-ENHANCEMENT-SECTION.

* Bei Umlagerung muß die Cursor-Position gemerkt werden (für Prüfung
* der Klassifikation und zur Unterscheidung bei hellem Aufruf des Popup)
  IF NOT dm07m-kzuml IS INITIAL AND
     NOT mseg-umcha IS INITIAL.
    GET CURSOR FIELD feld.
  ENDIF.

* Bei Prüfungen Umlagerung und Prüfung der Klassifikation wird im
* Fehlerfall im Hellen aufs Bewertungsbild gesprungen. Das soll aber nur
* erfolgen, wenn die Bewertung auch erlaubt ist (=eingabebereit)
  IF x_no_dialog IS INITIAL.
    IF dm07m-kzuml IS INITIAL.
      l_matnr = mseg-matnr.
      l_charg = mseg-charg.
      l_werks = mseg-werks.
    ELSE.
      l_matnr = mseg-ummat.
      l_charg = mseg-umcha.
      l_werks = mseg-umwrk.
    ENDIF.
    PERFORM check_exist_charge_with_pos(sapfm07m)
                            USING    l_matnr
                                     l_charg
                                     l_werks
                                     dm07m-kzuml
                                     mseg-zeile
                            CHANGING l_posnr.
    IF sy-subrc = 0.
      x_no_classif = x.      "Charge schon im Beleg enthalten
    ENDIF.

    IF x_no_classif IS INITIAL.
      PERFORM check_batch_posted USING    l_matnr
                                          l_werks
                                          l_charg
                                 CHANGING x_already_posted.
      IF NOT x_already_posted IS INITIAL.
        x_no_classif = x.   "Charge schon bebucht
      ENDIF.
    ENDIF.

    IF x_no_classif IS INITIAL.
      IF ( dm07m-kzuml IS INITIAL AND
           NOT dm07m-xbewm IS INITIAL AND dm07m-rmbew IS INITIAL ) OR
         ( NOT dm07m-kzuml IS INITIAL AND
           NOT dm07m-umxbewm IS INITIAL AND dm07m-umrmb IS INITIAL ).
        x_no_classif = x.
      ENDIF.

    ENDIF.
  ENDIF.

*-Prüfen, ob Bewertung aus Klassifikation als Umren/Umrez darstellbar
  IF l_trtyp NE a.
    PERFORM check_classification
           USING    l_umwso                               "SW ALRK219273
           CHANGING x_round_error
                    l_error_meinh.
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_11 SPOTS ES_SAPMM07M .

*---Nicht bei Batch-Input oder Aufruf von außen (dann ist nicht sicher,
*---ob Dialog möglich) oder wenn Klassif. nicht erlaubt
    IF x_no_dialog IS INITIAL AND x_no_classif IS INITIAL.
      "Bei Rundungsproblem aus Klassif. -> Rücksprung zur Klassifik.
      l_kzcla_save = dm07m-kzcla.
      dm07m-kzcla = drei.
      l_xkcfc_save = dm07m-xkcfc.
      CLEAR dm07m-xkcfc.               "Sonst wird Puffer initialisiert

*----- Neuaufruf der Klassifikation bis Werte als Umz/Umren darstellbar
      WHILE NOT x_round_error IS INITIAL.

*------- Bei Chargenumlagerung muß der Cursor auf die empfangende Charge
*------- gestellt werden, damit Klassifikation funktioniert
        IF NOT dm07m-kzuml IS INITIAL AND
           NOT mseg-umcha  IS INITIAL.
          loc_feld = 'MSEG-UMCHA'.                        "note 129198
        ELSE.                                              "note 129198
          loc_feld = 'MSEG-CHARG'.                        "note 129198
        ENDIF.

        cl_modif_before_clas = abap_true.
        textmeinh = l_error_meinh.
        IF sy-index GT 1 AND cl_okcode EQ okcode_abbr AND   "ALRK074852
           aktyp EQ h.                                      "ALRK074852
          MESSAGE e033(xu) WITH textmeinh.                  "ALRK074852
        ELSE.                                               "ALRK074852
          MESSAGE i033(xu) WITH textmeinh.                  "ALRK074852
        ENDIF.                                              "ALRK074852
*------- Wenn Umlag.charge gesetzt ist, wird bei Neuaufruf der Klass.
*------- erneut zur abgebenden Charge klassifiziert --> Inkonsistenz
*------- Damit dies nicht geschieht, wird mit lok. Aktyp 'K' gerufen
        PERFORM chargen_klassifizieren USING l_aktyp_k     "note 129198
                                             loc_feld.     "note 129198
        PERFORM check_classification
              USING    l_umwso                           "SW ALRK219273
              CHANGING x_round_error
                       l_error_meinh.

      ENDWHILE.

*----- Zurücksetzen der Werte auf Stand vor Prüfung Klassifikation
      IF NOT dm07m-kzuml IS INITIAL AND
         NOT mseg-umcha  IS INITIAL.
        SET CURSOR FIELD feld.
      ENDIF.
      dm07m-kzcla = l_kzcla_save.
      dm07m-xkcfc = l_xkcfc_save.

    ELSE."kein Dialog
      IF NOT x_round_error IS INITIAL.
        textmeinh = l_error_meinh.
        MESSAGE e033(xu) WITH textmeinh.
        "Bewertung des Merkmals liefert Rundungsungenauigkeit
      ENDIF.
    ENDIF.
  ENDIF.

*-Im Anzeigen nur weiter, wenn über Menü gerufen
  IF l_trtyp EQ a.
    CHECK NOT xhell IS INITIAL.
  ENDIF.

*- Anzeige der Klassifizierung im Mengenpopup erlauben
  xklassifizierung = x.

* Bei Umlagerung auf eine andere Charge und hellem Aufruf des Popups muß
* der Cursor entweder auf der abgebenden oder der empfangenden Charge
* stehen
  IF NOT xhell IS INITIAL.
    IF NOT dm07m-kzuml IS INITIAL AND
       NOT mseg-umcha IS INITIAL.
      IF feld EQ     'MSEG-CHARG'.
        xhell_charg = xhell.
      ELSEIF feld EQ 'MSEG-UMCHA'.
        xhell_umcha = xhell.
      ELSE.
        MESSAGE i141(m7).
      ENDIF.
    ELSE.
      xhell_charg = xhell.
    ENDIF.
  ENDIF.

*** Einschub Inkonsistenzproblem
*  IF AKTYP EQ K AND SY-UNAME EQ 'WEISENBERGER'.
*      CCODE = CCOD-CLAS.
*      CLEAR DM07M-XKCFC.
*      DM07M-KZCLA = DREI.
*      PERFORM CHARGEN_KLASSIFIZIEREN USING AKTYP
*                                           LOC_FELD.
*      DM07M-KZCLA = L_KZCLA_SAVE.
*      DM07M-XKCFC = L_XKCFC_SAVE.
*      CLEAR CCODE.
*  ENDIF.
*** Einschub Inkonsistenzproblem
* Modification Note 666645
  PERFORM set_global_data_buffer(saplmurc)
        TABLES xmchb
               xmska
               xmsku
               xmkol
               xmspr
               xmslb
        USING  mseg
               vm07m
               dm07m.

* Bei Umlagerung wird nicht auf Nachkommafehler bzgl. abgebender Charge
* geprüft. Die Prüfung erfolgt beim Aufruf Buchen_Aufbereiten.
* (Zusatzentwicklung: Umlagerung mit abweichendem Faktor)
* Ausnahmefall: Zweischrittumlagerung ohne MSEG-UMCHA
  IF dm07m-kzuml IS INITIAL OR                              "ALRK115218
     ( NOT dm07m-kzuml IS INITIAL                           "P45K052066
       AND mseg-umcha IS INITIAL )  OR                      "P45K052066
*     If the receiving material is w/ product quantities  the checks
*     are processed in the UML_CALC_REST-routines. If the receiving mat.
*     is w/o product quantities we need to check here
     ( NOT dm07m-kzuml IS INITIAL
       AND l_umwso NE b ).

ENHANCEMENT-SECTION     ALTERNATIVE_MENGEN_04 SPOTS ES_SAPMM07M.
    CALL FUNCTION 'MURC_MENGENUMRECHNUNG'
      EXPORTING
        matnr                = mseg-matnr
        werks                = mseg-werks
        lgort                = mseg-lgort
        charg                = mseg-charg
        menge                = mseg-menge
        meins                = mseg-meins
        erfmg                = mseg-erfmg
        erfme                = mseg-erfme
        trtyp                = l_trtyp
        kzwso                = l_kzwso
        hell                 = xhell_charg
        no_dialog            = x_no_dialog
        umrez                = dm07m-umrez
        umren                = dm07m-umren
        klassifizierung      = xklassifizierung
        values_keep          = xvalues_keep
      IMPORTING
        o_menge              = mseg-menge
        o_erfmg              = mseg-erfmg
        o_erfme              = mseg-erfme
        o_umrez              = dm07m-umrez
        o_umren              = dm07m-umren
      TABLES
        objecttab            = cl_objecttab
      EXCEPTIONS
        calculation_wrong    = 1
        batch_not_classified = 2
        OTHERS               = 3.
END-ENHANCEMENT-SECTION.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.                                                    "ALRK115218
*----------------------------------------------------------------------*
*-Umlagerung
  IF NOT dm07m-kzuml IS INITIAL.                            "ALRK115218
*--- Nur-Anzeige des Mengenumrechnungspopup bei Menüauswahl
*--- (ohne Prüfungen)
    IF dm07m-kzwso EQ b.
      IF NOT xhell_charg IS INITIAL.                        "ALRK115218
        CALL FUNCTION 'MURC_MENGENUMRECHNUNG'
          EXPORTING
            matnr                = mseg-matnr               "ALRK115218
            werks                = mseg-werks               "ALRK115218
            lgort                = mseg-lgort               "ALRK115218
            charg                = mseg-charg               "ALRK115218
            menge                = mseg-menge
            meins                = mseg-meins
            erfmg                = mseg-erfmg
            erfme                = mseg-erfme
            trtyp                = a
            kzwso                = l_kzwso
            hell                 = xhell_charg
            no_dialog            = x_no_dialog
            umrez                = dm07m-umrez
            umren                = dm07m-umren
            klassifizierung      = xklassifizierung
          TABLES
            objecttab            = cl_objecttab
          EXCEPTIONS
            calculation_wrong    = 1
            batch_not_classified = 2
            OTHERS               = 3.

      ENDIF.
    ENDIF.
    IF l_umwso EQ b.
*----- Prüfung der empfangenden Charge ohne Dialog.
      IF NOT mseg-umcha IS INITIAL.                         "P45K025066
        DO.
*---------Schleife zur Prüfung bzgl. empfangender Charge
ENHANCEMENT-SECTION     ALTERNATIVE_MENGEN_05 SPOTS ES_SAPMM07M.
          CALL FUNCTION 'MURC_MENGENUMRECHNUNG'
            EXPORTING
              matnr           = mseg-ummat
              werks           = mseg-umwrk
              lgort           = mseg-umlgo
              charg           = mseg-umcha
              menge           = mseg-menge
              meins           = mseg-meins
              erfmg           = mseg-erfmg
              erfme           = mseg-erfme
              trtyp           = l_trtyp
              kzwso           = l_kzwso
              hell            = xhell_umcha                 "ALRK115218
              no_dialog       = x_no_dialog
              klassifizierung = xklassifizierung
            IMPORTING
              o_erfmg         = mseg-erfmg                  "ALRK115218
              o_erfme         = mseg-erfme                  "376007
              o_umrez         = dm07m-umrez                 "376007
              o_umren         = dm07m-umren                 "376007
              o_menge         = mseg-menge                  "ALRK115218
            TABLES
              objecttab       = cl_objecttab
            EXCEPTIONS
              OTHERS          = 4.
END-ENHANCEMENT-SECTION.

*-------- Exit-Bedingung
          IF sy-subrc EQ 0.
            EXIT.
          ENDIF.
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDDO.

*       Umlagerung mit abw. Faktor umcha-charg                "ALRK11521
        PERFORM uml_calc_rest USING x_no_dialog.            "ALRK11521
      ENDIF.                                                "P45K05206
    ENDIF."Prüfungen für ProduktME bei Umlagerung

*---Rücksetzen der Steuerkennzeichen und des Cursors
    dm07m-kzcla = l_kzcla_save.
    dm07m-xkcfc = l_xkcfc_save.
    CLEAR ccode.
    SET CURSOR FIELD feld.
  ENDIF.

ENHANCEMENT-POINT ALTERNATIVE_MENGEN_09 SPOTS ES_SAPMM07M.

* Bei Aktivitaetstyp 'H' muss noch die Bestellmenge etc. aktualisiert
* werden (im anderen Fall erfolgt dies im Menge_Pruefen)
  IF aktyp EQ h.
    PERFORM menge_umrechnen(sapfm07m) USING mseg-matbf
                                            LS_ISU_MENGE_UMRECHNEN. "IS2ERP
  ENDIF.

* Rückschreiben der gemerkten LagerME bei BELEG-ÄNDERN
  IF t158-tcode EQ tcod-mb02.
    mseg-menge = l_menge.
  ENDIF.

ENDFORM.                    "ALTERNATIVE_MENGEN
*eject
*----------------------------------------------------------------------*
*       Form  CHECK_CLASSIFICATION                                     *
*----------------------------------------------------------------------*
*  It must be possible to convert the characteristic values
*  used in the batch unit conversion to a fraction with five digit
*  numerator and denumerator. If not, the conversion factor cannot be
*  stored in the material document.
*----------------------------------------------------------------------*
FORM check_classification
            USING    i_umwso                          "SW ALRK219273
            CHANGING o_round_error
                     o_meinh.


* Local Data
  DATA: l_marm        LIKE marm OCCURS 0 WITH HEADER LINE,
        l_charvalue   LIKE ausp-atflv,
        l_result(2)   TYPE c,
        l_matnr       LIKE mseg-matnr,
        l_werks       LIKE mseg-werks,
        l_charg       LIKE mseg-charg,
        l_kzwso       LIKE dm07m-kzwso.               "SW ALRK219273


* Only if Variable Units of measure are active
  CHECK  kzdws EQ eins.
  CLEAR: o_round_error, o_meinh.

* Bei Umlagerungen muß die Klassifizierung der empfangenden Charge
* geprueft werden
  IF NOT dm07m-kzuml IS INITIAL AND
     NOT mseg-umcha  IS INITIAL.
    l_matnr = mseg-ummat.
    l_charg = mseg-umcha.
    l_werks = mseg-umwrk.
    l_kzwso = i_umwso.                              "SW ALRK219273
  ELSE.                                           "Begin ALRK066341
    l_charg = mseg-charg.
    l_kzwso = dm07m-kzwso.                          "SW ALRK219273
  ENDIF.
  IF l_werks IS INITIAL.
    l_werks = mseg-werks.
  ENDIF.
  IF l_matnr IS INITIAL.
    l_matnr = mseg-matnr.
  ENDIF.                                          "END ALRK066341
* Get T160M for active ingredients to determine whether error message
* and check is necessary                   "Begin of SW ALRK219273
  IF l_kzwso EQ a OR l_kzwso EQ b.                          "435144
    CALL FUNCTION 'ME_CHECK_T160M'
      EXPORTING
        i_arbgb     = 'XU'
        i_msgnr     = '033'
        i_msgvs     = msgvs
      EXCEPTIONS
        error       = 1
        nothing     = 2
        warning     = 3
        success     = 4
        popup       = 5
        information = 6
        OTHERS      = 7.

    CHECK sy-subrc EQ 1.

  ENDIF.                                    "End of SW ALRK219273

* Classification check is not necessary for extended conversion
  DATA: lf_fract5_conversion TYPE c.
  CALL FUNCTION 'MURC_GET_CONVERSION_TYPE'
    IMPORTING
      ef_fract5_conversion = lf_fract5_conversion.
  CHECK lf_fract5_conversion = abap_true.

* Read Units of product/active ingredient unit of measure
  CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
    EXPORTING
      i_matnr          = l_matnr
    TABLES
      ws_marm_tab      = l_marm
    EXCEPTIONS
      wrong_call       = 1
      no_units         = 2
      units_not_active = 3
      OTHERS           = 4.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
  CLEAR l_result.

* Check classification for all UOMs that are linked with a characterist.
  LOOP AT l_marm.

*-----Get characteristic value from AUSP or buffer
    CALL FUNCTION 'BATCH_CONVERSION_FACTOR'
         EXPORTING
              i_charg                      = l_charg
*               I_CHARG_CUOBJ                = ' '
              i_werks                      = l_werks
              i_matnr                      = l_matnr
              i_meins                      = mseg-meins
              i_meinh                      = l_marm-meinh
              i_kzmeinh                    = space
              i_marm                       = l_marm
              i_kzdch                      = kzdch
              i_kzdws                      = kzdws
         IMPORTING
              o_char_value                 = l_charvalue
         EXCEPTIONS
              OTHERS                       = 4. "not classified or
    "classified with 0
    CHECK sy-subrc = 0.
    CHECK l_charvalue <> 0.
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_06 SPOTS ES_SAPMM07M.

*---Central Function module to check for fract5ability
    CALL FUNCTION 'VBWS_VALUE_CHECK'
      EXPORTING
        i_value                   = l_charvalue
        i_msehi                   = l_marm-msehi
        i_meinh                   = l_marm-meinh
        i_meins                   = mseg-meins
      EXCEPTIONS
        value_not_valid           = 1
        improper_input_parameters = 2
        no_unit                   = 3
        material_not_found        = 4
        conversion_not_found      = 6
        input_le_zero             = 7
        msehi_not_defined         = 8
        meinh_not_defined         = 9
        conversion_not_allowed    = 10
        OTHERS                    = 11.

    IF sy-subrc NE 0.
      o_round_error = x.
      o_meinh       = l_marm-meinh.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "CHECK_CLASSIFICATION
*eject
*----------------------------------------------------------------------*
*       Form CHECK_BATCH_POSTED
*----------------------------------------------------------------------*
* Im Stahl-Wirkstoffall darf die Klassifikation einer Charge, die schon
* einmal bebucht wurde, nicht mehr geändert werden
* Grund: mögliche Retouren oder Storno
*----------------------------------------------------------------------*
FORM check_batch_posted USING    i_matnr
                                 i_werks
                                 i_charg
                        CHANGING o_already_posted.

* Anteils-/variable Mengeneinheiten aktiv?
  CHECK kzdws EQ eins.
  DATA: l_umwso       LIKE dm07m-kzwso.
  PERFORM read_kzwso(sapfm07m) CHANGING dm07m-kzwso
                                        l_umwso.
  IF i_matnr EQ mseg-matnr.
    CHECK dm07m-kzwso EQ b.
  ELSE.
    CHECK l_umwso EQ b.
  ENDIF.

* Local Data
  DATA: wa_mbefu LIKE mbefu,
        loc_werks LIKE mseg-werks,
        loc_matnr LIKE mseg-matnr,
        loc_charg LIKE mseg-matnr.

* Umlagerung
  loc_matnr = i_matnr.
  loc_werks = i_werks.
  loc_charg = i_charg.

* Read date of last goods receipt of this batch
* Deletion due to note 311815: MBEFU-LWEDT is not reliable. Previous
* routines could have filled this field e.g.CHARGEN_DATEN_MAT_SETZEN
* from the batch buffer
* Therefore we always call MATERIAL_READ and do not need L_KZUML
  mtcom-kenng = 'MBEFU'.
  mtcom-matnr = loc_matnr.
  mtcom-charg = loc_charg.
  mtcom-werks = loc_werks.

  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      schluessel = mtcom
    IMPORTING
      matdaten   = wa_mbefu
    EXCEPTIONS
      OTHERS     = 4.
  CHECK sy-subrc EQ 0.                                      "ALRK074852

  IF NOT wa_mbefu-lwedt IS INITIAL.                         "311815
    o_already_posted = x. "Batch has already been posted!
  ENDIF.                   "--> classification cannot be changed anymore

ENDFORM.  "CHECK_BATCH_POSTED
*eject
*----------------------------------------------------------------------*
*       Form  MENGEN_BEWERTUNG
*----------------------------------------------------------------------*
* Bewerten des Merkmals zur Erfassungsmengeneinheit mit dem Quotienten
* aus Erfassungs- und Lagermenge (bei Chargenneuanlage)
*----------------------------------------------------------------------*
FORM mengen_bewertung USING i_mseg LIKE mseg.

* Lokale Daten
  DATA: dm07mkzcla_save LIKE dm07m-kzcla,
        loc_feld(11),                                       "note 129198
        l_mtcor LIKE mtcor,
        l_mtcom LIKE mtcom,
        x_no_dialog LIKE am07m-xselk,
        allowed TYPE c.

  PERFORM mengen_bewertung_checks(sapfm07m)
              USING    i_mseg
              CHANGING allowed.

  CHECK NOT allowed IS INITIAL.

* Early read kzuml and temporary set
  DATA: l_kzuml LIKE dm07m-kzuml,
        l_dm07m_kzuml_save LIKE dm07m-kzuml.
  PERFORM menge_parallel_read_kzuml(sapfm07m)
                                    CHANGING l_kzuml.

* Automatische Chargennummernvergabe
  IF inventur IS INITIAL AND
    ( ( i_mseg-charg IS INITIAL AND l_kzuml IS INITIAL ) OR
      ( i_mseg-umcha IS INITIAL AND NOT l_kzuml IS INITIAL ) ).
    PERFORM chargennummernvergabe(sapfm07m) USING i_mseg
                                                  i_mseg-shkzg
                                                  i_mseg-matnr
                                                  i_mseg-werks
                                         CHANGING i_mseg-charg.
  ENDIF.
  IF NOT l_kzuml IS INITIAL AND mseg-umcha IS INITIAL AND
*     No error message because the batch number will be assigned later
      NOT allowed EQ u.   "Note 323236 SW
    PERFORM no_input(sapfm07m) USING 'MSEG' 'UMCHA'.
  ELSEIF l_kzuml IS INITIAL AND mseg-charg IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'MSEG' 'CHARG'.
  ENDIF.

* Ausstieg bei Umlagerung, sofern Umlagerung noch nicht durchlaufen
  IF allowed EQ u AND                                       "ALRK115218
    ( dm07m-umxch IS INITIAL ). "OR dm07m-umwso IS INITIAL )."ALRK115218
    EXIT.                                                   "ALRK115218
  ENDIF.                                                    "ALRK115218
  l_dm07m_kzuml_save = dm07m-kzuml.
  dm07m-kzuml = l_kzuml.

*-Dunkles Klassifizieren
  IF dm07m-class IS INITIAL.
*---Bei bewerteten AnteilsME muß der Returncode des MBEW-Satzes nachge-
*---lesen werden, damit die dunkle Klassifikation möglich ist
    IF NOT dm07m-xbewm IS INITIAL.                          "430924
      CLEAR l_mtcom.
      l_mtcom-kenng = 'MBEW'.
      l_mtcom-matnr = mseg-matnr.
      l_mtcom-bwkey = mseg-bukrs.
      l_mtcom-bwtar = mseg-charg.
      l_mtcom-werks = mseg-werks.
      l_mtcom-lgort = mseg-lgort.
      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel = l_mtcom
        IMPORTING
          return     = l_mtcor
        EXCEPTIONS
          OTHERS     = 4.
      IF sy-subrc = 0.
        dm07m-rmbew = l_mtcor-rmbew.
      ENDIF.
    ENDIF.
    dm07mkzcla_save = dm07m-kzcla.
    dm07m-kzcla = eins.
    PERFORM chargen_klassifizieren USING aktyp             "note 129198
                                         loc_feld.         "note 129198
    dm07m-kzcla = dm07mkzcla_save.
  ENDIF.
  IF pfsta IS INITIAL AND tit IS INITIAL OR NOT sy-binpt IS INITIAL.
    x_no_dialog = x.
  ENDIF.
  PERFORM mengen_bewertung_schreiben(sapfm07m) USING x_no_dialog
                                                     mseg.
  dm07m-kzuml = l_dm07m_kzuml_save.
ENDFORM.                    "MENGEN_BEWERTUNG
*eject
*----------------------------------------------------------------------*
*       Form  PF4HELP_ME
*----------------------------------------------------------------------*
* Help for UOM that are in MARM
*----------------------------------------------------------------------*
FORM pf4help_me USING mseg-matnr
                CHANGING mseg-erfme.
* Local Data
  DATA: dynumb LIKE sy-dynnr,
        dyname LIKE sy-repid,
        cursorfield(30),
        matnr LIKE mara-matnr,
        l_werks LIKE mseg-werks,                           "Note 316455
        mengeneinheit LIKE mseg-meins,
        povstepl LIKE sy-stepl,
        save_tabix LIKE sy-tabix.
  DATA: BEGIN OF scr_fields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END OF scr_fields.
  DATA: lv_display TYPE ddbool_d.
  DATA: con_matnr type matnr.                                    "867192

* Initialize local data
  REFRESH scr_fields.
  dyname = sy-repid.
  dynumb = sy-dynnr.

* Read line in Steploop
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = povstepl
    EXCEPTIONS
      stepl_not_found = 1
      OTHERS          = 2.
  scr_fields-stepl = povstepl.
  GET CURSOR FIELD cursorfield.
  scr_fields-fieldname = cursorfield.
  APPEND scr_fields.
  scr_fields-fieldname = 'MSEG-MATNR'.
  APPEND scr_fields.
  scr_fields-fieldname = 'MSEG-WERKS'.                     "Note 316455
  APPEND scr_fields.                                       "Note 316455

* Read Names of Screen-Fields
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = dyname
      dynumb     = dynumb
    TABLES
      dynpfields = scr_fields
    EXCEPTIONS
      OTHERS     = 1.
  READ TABLE scr_fields WITH KEY fieldname = 'MSEG-MATNR'.
  matnr = scr_fields-fieldvalue.
  READ TABLE scr_fields WITH KEY fieldname = 'MSEG-WERKS'. "Note 316455
  l_werks = scr_fields-fieldvalue.                         "Note 316455

* ERFME must not be changed in display or cancel mode (Note 499745)
  IF t158-trtyp <> h.
    lv_display = x.
  ENDIF.
  IF  NOT mseg-mblnr IS INITIAL  AND
      vm07m-xstor = 2.        "Nur bei Belegstorno, nicht bei Ruecklief.
    lv_display = x.
  ENDIF.

* Call for Popup to choose UOM from MARM-UOMs
*   First convert the material mumber for MARM-select            "867192
  call function 'CONVERSION_EXIT_MATN1_INPUT'                    "867192
    exporting                                                    "867192
      input              = matnr                                 "867192
    importing                                                    "867192
      output             = con_matnr                             "867192
    exceptions                                                   "867192
      others             = 2.                                    "867192
  IF NOT sy-subrc = 0.                                           "867192
    MOVE matnr TO con_matnr.                                     "867192
  ENDIF.                                                         "867192
*   Now call the popup
  call function 'MURC_SELECT_ERFME_F4'
       exporting
            matnr         = con_matnr                            "867192
      i_werks       = l_werks                        "Note 316455
      i_display     = lv_display                     "Note 499745
    IMPORTING
      mengeneinheit = mengeneinheit
    EXCEPTIONS
      no_me_found   = 1
      OTHERS        = 2.

* Abbruch auf dem Popup
  READ TABLE scr_fields WITH KEY fieldname = cursorfield.
  CHECK sy-subrc EQ 0.
  save_tabix = sy-tabix.
  CHECK NOT mengeneinheit IS INITIAL.

  scr_fields-fieldvalue = mengeneinheit.
  MODIFY scr_fields INDEX save_tabix.

* Werte zurück ans Dynpro
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = dyname
      dynumb     = dynumb
    TABLES
      dynpfields = scr_fields
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.                                                    "PF4HELP_ME
*eject
*----------------------------------------------------------------------*
*       Form  READ_KZWSO
*----------------------------------------------------------------------*
* Liest das Materialkennzeichen Verwendung Mengeneinheiten
*----------------------------------------------------------------------*
FORM read_kzwso CHANGING o_kzwso.

  DATA: wa_mbefu LIKE mbefu,
        BEGIN OF dummy OCCURS 0,
           dummy,
        END OF dummy.

* KZWSO only relevant if activated in Customizing
  CLEAR o_kzwso.
  CHECK kzdws EQ eins.

* Read from View if flag is filled there
  IF NOT mbefu-matnr IS INITIAL AND mseg-matnr EQ mbefu-matnr."ALRK74852
    o_kzwso = mbefu-kzwsm.
  ENDIF.

* Read from Table MARA
  IF o_kzwso IS INITIAL.
    CHECK NOT mseg-matnr IS INITIAL.                        "ALRK074852
    CLEAR: mtcom, wa_mbefu.
    mtcom-kenng = 'MBEFU'.
    mtcom-matnr = mseg-matnr.
    mtcom-werks = mseg-werks.

    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel = mtcom
      IMPORTING
        matdaten   = wa_mbefu
      TABLES
        seqmat01   = dummy
      EXCEPTIONS
        OTHERS     = 4.

    IF sy-subrc = 0.
      o_kzwso = wa_mbefu-kzwsm.
    ENDIF.
  ENDIF.

ENDFORM.                    "READ_KZWSO
*eject
*&---------------------------------------------------------------------*
*&      Form  UML_CALC_REST                               "ALRK115218
*&---------------------------------------------------------------------*
FORM uml_calc_rest USING i_no_dialog.
* Local Data Declarations
  DATA: loc_x_mng       LIKE mseg-menge,
        loc_menge       LIKE mseg-menge,
        loc_altmg       LIKE mseg-erfmg,
        loc_ymseg_zeile LIKE mseg-zeile,
        loc_tabix       LIKE sy-tabix,
        loc_text1(20),
        loc_text2(20),
        loc_text3(20),
        io_marm_ws      LIKE marm OCCURS 0 WITH HEADER LINE.

* Prüfung ob Umrechnung der abgebenden und empf. Charge gleich
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_07 SPOTS ES_SAPMM07M.
  PERFORM check_conv_equal_uml.
  IF meinh_abw[] IS INITIAL.
*    Umrechung abgebende und empf. Charge gleich -> Eintrag aus UMSEG
*    muss entfernt werden, falls vorhanden
    READ TABLE umseg WITH KEY zeile = mseg-zeile.
    IF sy-subrc EQ 0.
      DELETE umseg WHERE zeile = mseg-zeile.
    ENDIF.
    EXIT.
  ENDIF.

* Save old line of YMSEG
  loc_ymseg_zeile = ymseg-zeile.

* Beginn Hinweis 728103
* Die UMSEG wird nur für die abgebenden Positionen aufgebaut, da für die
* Zugangsbuchungen bereits immer auf Ganzzahligkeit geprüft wird
* Sperrtabellen enthalten die einigermaßen zuverlässige Information, ob
* die Buchung auf 0-Bestand führt
  IF dm07m-kzuml = abap_true AND
     mseg-shkzg = 'S'.
*   Die abgebende Charge ist in den UM-Felder
    seg_tab-matnr      = mseg-ummat.
    seg_tab-werks      = mseg-umwrk.
    seg_tab-lgort      = mseg-umlgo.
    seg_tab-charg      = mseg-umcha.
    seg_tab-sobkz      = mseg-umsok.
    seg_tab-kdauf      = mseg-kdauf.
    seg_tab-kdpos      = mseg-kdpos.
    seg_tab-lifnr      = mseg-lifnr.
    seg_tab-ps_psp_pnr = mseg-ps_psp_pnr.
    seg_tab-kunnr      = mseg-kunnr.
    seg_tab-lbbsa      = vm07m-lbbsa.
  ELSE.
*   Die abgebende Charge ist in den "normalen" MSEG-Feldern
    seg_tab-matnr      = mseg-matnr.
    seg_tab-werks      = mseg-werks.
    seg_tab-lgort      = mseg-lgort.
    seg_tab-charg      = mseg-charg.
    seg_tab-sobkz      = mseg-sobkz.
    seg_tab-kdauf      = mseg-kdauf.
    seg_tab-kdpos      = mseg-kdpos.
    seg_tab-lifnr      = mseg-lifnr.
    seg_tab-ps_psp_pnr = mseg-ps_psp_pnr.
    seg_tab-kunnr      = mseg-kunnr.
    seg_tab-lbbsa      = vm07m-lbbsa.
  ENDIF.
* Ende Hinweis 728103

ENHANCEMENT-POINT UML_CALC_REST_01 SPOTS ES_SAPMM07M.
* Nachlesen des Bestands aus Sperrserver
  PERFORM uml_read_enq_stock USING    seg_tab
                             CHANGING loc_x_mng.

* Nachlesen ProduktME
  PERFORM uml_read_marm_ws TABLES io_marm_ws
                           USING  mseg-matnr.

*-Aufbau/Nachlesen der UMSEG-Tabelle (Umlagerungen mit abw. Umrechn.)***
  READ TABLE umseg WITH KEY zeile = mseg-zeile.
  CLEAR: ws_meng_wa.
  IF aktyp EQ h OR sy-subrc NE 0.
    IF sy-subrc EQ 0.                                         "1105069
      DELETE umseg INDEX sy-tabix.                            "1105069
    ENDIF.                                                    "1105069
*--- Neuen UMSEG-Eintrag anlegen im Hinzufügen oder wenn die Pos. bisher
*    keine Umlagerung mit abw. Umrechnung war
    CLEAR umseg. CLEAR umseg-ws_meng_tab.
    MOVE-CORRESPONDING seg_tab TO umseg.
*    Unabhängig von der Feldbezeichnung in der MSEG: In den   "728103
*    UMSEG-UM-Felder steckt die empfangende Charge
    IF dm07m-kzuml = abap_true AND
       mseg-shkzg = 'S'.
      umseg-ummat = mseg-matnr.
      umseg-umwrk = mseg-werks.
      umseg-umcha = mseg-charg.
    ELSE.
      umseg-ummat = mseg-ummat.
      umseg-umwrk = mseg-umwrk.
      umseg-umcha = mseg-umcha.
    ENDIF.
    umseg-zeile  = mseg-zeile.
    umseg-menge  = mseg-menge.
    umseg-erfme  = mseg-erfme.
    umseg-erfmg  = mseg-erfmg.

*--- Füllen der UMSEG-komplexen Struktur (keine Einträge vorhanden)
    LOOP AT io_marm_ws.
      ws_meng_wa-meinh = io_marm_ws-meinh.
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input  = umseg-menge
          matnr  = umseg-ummat
          meinh  = io_marm_ws-meinh
          meins  = mseg-meins
          charge = umseg-umcha
          werks  = umseg-umwrk
        IMPORTING
          output = ws_meng_wa-altmg
        EXCEPTIONS
          OTHERS = 4.

      APPEND ws_meng_wa TO umseg-ws_meng_tab.
    ENDLOOP.
    APPEND umseg.
  ELSE.
*-- Übernehmen der Erfassungsmenge bei Änderung, falls ProdME
    loc_tabix = sy-tabix.
    IF mseg-erfme NE umseg-erfme OR
       mseg-erfmg NE umseg-erfmg.
      READ TABLE umseg-ws_meng_tab INTO ws_meng_wa
                 WITH KEY meinh = mseg-erfme.
      IF sy-subrc EQ 0 AND ws_meng_wa-altmg NE mseg-erfmg.
        ws_meng_wa-altmg = mseg-erfmg.
        MODIFY umseg-ws_meng_tab FROM ws_meng_wa INDEX sy-tabix.
      ENDIF.
    ENDIF.
*-- Neuberechnen aller ProdME außer ErfME mit empfangender Pos
    IF mseg-menge NE umseg-menge.
      umseg-menge = mseg-menge.
      LOOP AT io_marm_ws.
        CLEAR ws_meng_wa.
        ws_meng_wa-meinh = io_marm_ws-meinh.
        IF io_marm_ws-meinh EQ mseg-erfme.
          ws_meng_wa-altmg = mseg-erfmg.
        ELSE.
          CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
            EXPORTING
              input  = umseg-menge
              matnr  = umseg-ummat
              meinh  = io_marm_ws-meinh
              meins  = mseg-meins
              charge = umseg-umcha
              werks  = umseg-umwrk
            IMPORTING
              output = ws_meng_wa-altmg
            EXCEPTIONS
              OTHERS = 4.
        ENDIF.
        READ TABLE umseg-ws_meng_tab INTO ws_meng_wa
               WITH KEY meinh = io_marm_ws-meinh.
        IF sy-subrc EQ 0.
          MODIFY umseg-ws_meng_tab FROM ws_meng_wa INDEX sy-tabix.
        ELSE.
          APPEND ws_meng_wa TO umseg-ws_meng_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
    MODIFY umseg INDEX loc_tabix.
  ENDIF.
* Ende Aufbau/Nachlesen der UMSEG-Tabelle (Umlagerungen mit abw. Umrechn

* Korrigieren der Sperrmenge in Abh. von Aktivitaetstyp
  IF aktyp EQ k AND sy-subrc EQ 0. "Im Verbucher existiert YMSEG nicht
    READ TABLE ymseg WITH KEY zeile = mseg-zeile.
    loc_x_mng = loc_x_mng + ymseg-menge - mseg-menge.
  ELSEIF aktyp EQ h.
    loc_x_mng = loc_x_mng - mseg-menge.
  ENDIF.

* Ausstieg, falls vollstaendige Ausbuchung
  CHECK NOT loc_x_mng EQ 0.

  CLEAR:   transf_qty, rest_qty, ws_meng_wa.
  REFRESH: transf_qty, rest_qty.

* Kumulieren der urspr. Lagermenge und der Transfermenge in ProdME
  loc_menge = loc_x_mng.
  PERFORM uml_cumulate_quantities
                        TABLES   transf_qty
                        USING    seg_tab
                        CHANGING loc_menge.

* Bestimmung der Restmenge
  CLEAR loc_altmg.
  SORT io_marm_ws BY xfhdw DESCENDING meinh.
  LOOP AT io_marm_ws.
    READ TABLE transf_qty WITH KEY meinh = io_marm_ws-meinh.
*----- Umrechnen der urspruengl. vorhandenen Menge in alle ProdME
    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = loc_menge
        matnr                = seg_tab-matnr
        meinh                = io_marm_ws-meinh
        charge               = seg_tab-charg
        werks                = seg_tab-werks
      IMPORTING
        output               = loc_altmg
      EXCEPTIONS
        conversion_not_found = 1
        input_invalid        = 2
        material_not_found   = 3
        meinh_not_found      = 4
        meins_missing        = 5
        no_meinh             = 6
        output_invalid       = 7
        overflow             = 8
        OTHERS               = 9.

*----- Berechung des Umref für den Restbestand für die aktuelle MEINH
    rest_qty-altmg = loc_altmg - transf_qty-altmg.
    rest_qty-meinh = io_marm_ws-meinh.
    APPEND rest_qty.
  ENDLOOP."loc_marm_ws

* Meldung innerhalb der Position (im Form Alternative_Mengen)
  CLEAR: loc_text1, loc_text2, loc_text3.
  PERFORM fill_textfield USING    loc_x_mng
                                  mseg-meins
                         CHANGING loc_text1.
  READ TABLE rest_qty INDEX 1.
  PERFORM fill_textfield USING    rest_qty-altmg
                                  rest_qty-meinh
                         CHANGING loc_text2.
  READ TABLE rest_qty INDEX 2.
  IF sy-subrc EQ 0.
    PERFORM fill_textfield USING    rest_qty-altmg
                                    rest_qty-meinh
                           CHANGING loc_text3.
  ENDIF.
* PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'XU' '053'.
* Nachrichtencode gibt die Nachricht selber aus => geändert auf FB
  CALL FUNCTION 'MB_CHECK_T160M'
    EXPORTING
      i_arbgb  = 'XU'
      i_msgnr  = '053'
      i_msgv1  = loc_text1
      i_msgv2  = loc_text2
      i_msgv3  = loc_text3
      i_output = space
    IMPORTING
      rc       = rc.
  .
  IF rc EQ 1 AND i_no_dialog IS INITIAL.
*---- Warnung nur im Dialogfall
    MESSAGE w053(xu) WITH loc_text1 loc_text2 loc_text3.
*     Umbuchung auf Charge mit anderem Umrechnungsfaktor --> Langtext
  ELSEIF rc EQ 2.
    MESSAGE e053(xu) WITH loc_text1 loc_text2 loc_text3.
  ENDIF.

ENDFORM.                    " UML_CALC_REST
*&---------------------------------------------------------------------*
*&      Form  CHECK_CONV_EQUAL_UML                          "ALRK115218
*&---------------------------------------------------------------------*
FORM check_conv_equal_uml.

  DATA: loc_marm_tab LIKE marm OCCURS 0 WITH HEADER LINE,
        loc_umref_charg TYPE f,
        loc_umref_umcha TYPE f,
        loc_result(2).
  DATA: loc_marm_tab_um LIKE marm OCCURS 0 WITH HEADER LINE."451102
* Initialisierung
  CLEAR:   meinh_abw.
  REFRESH: meinh_abw.

* Lesen aller ProduktME (4.0 hat eigenen Baustein VBWS...)
  CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
    EXPORTING
      i_matnr          = mseg-matnr
    TABLES
      ws_marm_tab      = loc_marm_tab
    EXCEPTIONS
      wrong_call       = 1
      no_units         = 2
      units_not_active = 3
      OTHERS           = 4.
* Lesen aller ProduktME und Merkmale dazu (UMMAT)              "451102
* Motivation: Gleiche ME aber unterschiedliches Merkmal
  IF mseg-matnr <> mseg-ummat.
    CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
      EXPORTING
        i_matnr          = mseg-ummat
      TABLES
        ws_marm_tab      = loc_marm_tab_um
      EXCEPTIONS
        wrong_call       = 1
        no_units         = 2
        units_not_active = 3
        OTHERS           = 4.
  ENDIF.
  LOOP AT loc_marm_tab.
    CALL FUNCTION 'BATCH_CONVERSION_FACTOR'
         EXPORTING
             i_charg                     = mseg-charg
*             I_CHARG_CUOBJ               = ' '
             i_werks                     = mseg-werks
             i_matnr                     = mseg-matnr
             i_meins                     = mseg-meins
             i_meinh                     = loc_marm_tab-meinh
             i_kzmeinh                   = space
             i_marm                      = loc_marm_tab
             i_kzdch                     = kzdch
        IMPORTING
             o_char_value                = loc_umref_charg
        EXCEPTIONS
             batch_not_classified        = 1
             characteristic_with_value_0 = 2
             new_batch_not_classified    = 3
             not_found                   = 4
             lock_problem                = 5
             OTHERS                      = 6.

*   Merkmal zur Mengeneinheit für UMMAT nachlesen
    CLEAR loc_marm_tab_um.
    IF mseg-matnr <> mseg-ummat.
      READ TABLE loc_marm_tab_um
                 WITH KEY meinh = loc_marm_tab-meinh.
      IF sy-subrc <> 0.
        continue.                                               "1023202
      ENDIF.
    ELSE.
*     Gleiches Material
      loc_marm_tab_um = loc_marm_tab.
    ENDIF.

    CALL FUNCTION 'BATCH_CONVERSION_FACTOR'
         EXPORTING
              i_charg                     = mseg-umcha
*             I_CHARG_CUOBJ               = ' '
              i_werks                     = mseg-umwrk
              i_matnr                     = mseg-ummat
              i_meins                     = mseg-meins
              i_meinh                     = loc_marm_tab_um-meinh
              i_kzmeinh                   = space
              i_marm                      = loc_marm_tab_um
              i_kzdch                     = kzdch
         IMPORTING
              o_char_value                = loc_umref_umcha
         EXCEPTIONS
              batch_not_classified        = 1
              characteristic_with_value_0 = 2
              new_batch_not_classified    = 3
              not_found                   = 4
              lock_problem                = 5
              OTHERS                      = 6.

    PERFORM float_compare USING    loc_umref_charg
                                   loc_umref_umcha
                          CHANGING loc_result.

    IF loc_result EQ 'NE'.
      meinh_abw-meinh = loc_marm_tab-meinh.
      meinh_abw-zeilu = mseg-zeile.
      APPEND meinh_abw.
    ENDIF.
  ENDLOOP.



ENDFORM.                    " CHECK_CONV_EQUAL_UML

*&---------------------------------------------------------------------*
*&      Form  FLOAT_COMPARE                                 "ALRK115218
*&---------------------------------------------------------------------*
FORM float_compare USING    i_float_1 TYPE f
                            i_float_2 TYPE f
                   CHANGING o_result.
  DATA: small_number TYPE f,
        difference   TYPE f.

  CLEAR o_result.
  small_number = 10 ** ( -15 ).

* Beide Werte sehr klein
  IF i_float_1 LE small_number AND
     i_float_2 LE small_number.
    o_result = 'EQ'.
* Nur ein Wert sehr klein
  ELSEIF i_float_1 LT small_number AND
         i_float_2 GE small_number.
    o_result = 'NE'.
  ELSEIF i_float_1 GE small_number AND
         i_float_2 LT small_number.
    o_result = 'NE'.
* Beide Wert groß
  ELSE.
    difference = ABS( ( i_float_1 - i_float_2 ) / i_float_1 ).
    IF difference LT small_number.
      o_result = 'EQ'.
    ELSE.
      o_result = 'NE'.
    ENDIF.

  ENDIF.

ENDFORM.                    " FLOAT_COMPARE

*&---------------------------------------------------------------------*
*&      Form  UML_READ_ENQ_STOCK                            "ALRK115218
*&---------------------------------------------------------------------*
FORM uml_read_enq_stock USING    l_segtab  TYPE seg_typ
                        CHANGING o_x_mng.

* Lokale Daten
  DATA: yzeile_save LIKE mseg-zeile.

* Nachlesen Bestandsart
  SELECT SINGLE * FROM t156c WHERE lbbsa = l_segtab-lbbsa AND
                                   sobkz = l_segtab-sobkz.

* Nachlesen Segment mit obiger Bestandsart und Setzen des Segmentstrings
  CASE l_segtab-sobkz.                                      "728103

    WHEN space.
*-----Chargenbestand
      READ TABLE xmchb WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                lgort = l_segtab-lgort
                                charg = l_segtab-charg.
      IF     t156c-xlabst EQ x.
        o_x_mng = xmchb-clabs.
      ELSEIF t156c-xinsme EQ x.
        o_x_mng = xmchb-cinsm.
      ELSEIF t156c-xeinme EQ x.
        o_x_mng = xmchb-ceinm.
      ELSEIF t156c-xspeme EQ x.
        o_x_mng = xmchb-cspem.
      ELSEIF t156c-xretme EQ x.
        o_x_mng = xmchb-cretm.
      ELSEIF t156c-xumlme EQ x.
        o_x_mng = xmchb-cumlm.
      ENDIF.

    WHEN e.
*-----Kundenauftragsbestand
      READ TABLE xmska WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                lgort = l_segtab-lgort
                                charg = l_segtab-charg
                                sobkz = e
                                vbeln = l_segtab-kdauf
                                posnr = l_segtab-kdpos.
      IF     t156c-xmeikl EQ x.
        o_x_mng = xmska-kalab.
      ELSEIF t156c-xmeikq EQ x.
        o_x_mng = xmska-kains.
      ELSEIF t156c-xmeiks EQ x.
        o_x_mng = xmska-kaspe.
      ELSEIF t156c-xmeike EQ x.
        o_x_mng = xmska-kaein.
      ENDIF.

    WHEN k.
*-----Sonderbestände vom Lieferanten
      READ TABLE xmkol WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                lgort = l_segtab-lgort
                                charg = l_segtab-charg
                                sobkz = k
                                lifnr = l_segtab-lifnr.
      IF     t156c-xklabs EQ x.
        o_x_mng = xmkol-slabs.
      ELSEIF t156c-xkinsm EQ x.
        o_x_mng = xmkol-sinsm.
      ELSEIF t156c-xkspem EQ x.
        o_x_mng = xmkol-sspem.
      ELSEIF t156c-xkeinm EQ x.
        o_x_mng = xmkol-seinm.
      ENDIF.

    WHEN m.
*-----Sonderbestände vom Lieferanten
      READ TABLE xmkol WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                lgort = l_segtab-lgort
                                charg = l_segtab-charg
                                sobkz = m
                                lifnr = l_segtab-lifnr.
      IF     t156c-xmtvla EQ x.
        o_x_mng = xmkol-slabs.
      ELSEIF t156c-xmtvei EQ x.
        o_x_mng = xmkol-seinm.
      ENDIF.

    WHEN o.
*-----Sonderbestände beim Lieferanten
      READ TABLE xmslb WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                charg = l_segtab-charg
                                sobkz = o
                                lifnr = l_segtab-lifnr.
      IF     t156c-xmslbo EQ x.
        o_x_mng = xmslb-lblab.
      ELSEIF t156c-xmsqbo EQ x.
        o_x_mng = xmslb-lbins.
      ELSEIF t156c-xmsebo EQ x.
        o_x_mng = xmslb-lbein.
      ENDIF.

    WHEN q.
*-----Projektbestand
      READ TABLE xmspr WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                lgort = l_segtab-lgort
                                charg = l_segtab-charg
                                sobkz = q
                                pspnr = l_segtab-ps_psp_pnr.
      IF     t156c-xmsprl EQ x.
        o_x_mng = xmspr-prlab.
      ELSEIF t156c-xmsprq EQ x.
        o_x_mng = xmspr-prins.
      ELSEIF t156c-xmsprs EQ x.
        o_x_mng = xmspr-prspe.
      ELSEIF t156c-xmspre EQ x.
        o_x_mng = xmspr-prein.
      ENDIF.

    WHEN v.
*-----Sonderbestände beim Kunden
      READ TABLE xmsku WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                charg = l_segtab-charg
                                sobkz = v
                                kunnr = l_segtab-kunnr.
      IF     t156c-xmklkl EQ x.
        o_x_mng = xmsku-kulab.
      ELSEIF t156c-xmkqkl EQ x.
        o_x_mng = xmsku-kuins.
      ELSEIF t156c-xmkekl EQ x.
        o_x_mng = xmsku-kuein.
      ENDIF.

    WHEN w.
*-----Sonderbestände beim Kunden
      READ TABLE xmsku WITH KEY matnr = l_segtab-matnr
                                werks = l_segtab-werks
                                charg = l_segtab-charg
                                sobkz = w
                                kunnr = l_segtab-kunnr.
      IF     t156c-xmklkk EQ x.
        o_x_mng = xmsku-kulab.
      ELSEIF t156c-xmkqkk EQ x.
        o_x_mng = xmsku-kuins.
      ELSEIF t156c-xmkekk EQ x.
        o_x_mng = xmsku-kuein.
      ENDIF.

    WHEN OTHERS.
ENHANCEMENT-POINT UML_READ_ENQ_STOCK_01 SPOTS ES_SAPMM07M.

  ENDCASE.



ENDFORM.                    " UML_READ_ENQ_STOCK
*&---------------------------------------------------------------------*
*&      Form  UML_READ_MARM_WS                              "ALRK115218
*&---------------------------------------------------------------------*
FORM uml_read_marm_ws TABLES o_marm_ws STRUCTURE marm
                      USING  i_matnr.

  CALL FUNCTION 'VBWS_UNITS_OF_MATERIAL'
    EXPORTING
      i_matnr          = i_matnr
    TABLES
      ws_marm_tab      = o_marm_ws
    EXCEPTIONS
      wrong_call       = 1
      no_units         = 2
      units_not_active = 3
      OTHERS           = 4.


ENDFORM.                    " UML_READ_MARM_WS

*&---------------------------------------------------------------------*
*&      Form  UML_CUMULATE_QUANTITIES                       "ALRK115218
*&---------------------------------------------------------------------*
FORM uml_cumulate_quantities TABLES   o_transf_qty LIKE transf_qty[]
                             USING    i_seg_tab    TYPE seg_typ
                             CHANGING io_menge     LIKE mseg-menge.

* Korrigieren der abgebenden Menge um die mit abw. Faktor ausgebuchten
* Umlagerungen dieses Segments/Bestandsart
  LOOP AT umseg WHERE matnr      EQ i_seg_tab-matnr
                AND   werks      EQ i_seg_tab-werks
                AND   lgort      EQ i_seg_tab-lgort
                AND   charg      EQ i_seg_tab-charg
                AND   sobkz      EQ i_seg_tab-sobkz
                AND   kdauf      EQ i_seg_tab-kdauf
                AND   kdpos      EQ i_seg_tab-kdpos
                AND   lifnr      EQ i_seg_tab-lifnr
                AND   ps_psp_pnr EQ i_seg_tab-ps_psp_pnr
                AND   kunnr      EQ i_seg_tab-kunnr
                AND   lbbsa      EQ i_seg_tab-lbbsa.
*----- Bestimmung der urspruengl. vorhandenen Menge, die fuer die
*----- Auslagerung mit abw. Faktor zur Verfuegung steht
    io_menge = io_menge + umseg-menge.

*----- Kumulieren der Umlagermenge in allen ProdME
    LOOP AT umseg-ws_meng_tab INTO ws_meng_wa.
      READ TABLE o_transf_qty WITH KEY meinh = ws_meng_wa-meinh.
      IF sy-subrc EQ 0.
        o_transf_qty-altmg = o_transf_qty-altmg +
                           ws_meng_wa-altmg.
        MODIFY o_transf_qty INDEX sy-tabix.
      ELSE.
        o_transf_qty-meinh = ws_meng_wa-meinh.
        o_transf_qty-altmg = ws_meng_wa-altmg.
        APPEND o_transf_qty.
      ENDIF.
    ENDLOOP. "UMSEG-WS_MENG_Tab

  ENDLOOP. "umseg


ENDFORM.                    " UML_CUMULATE_QUANTITIES
*&---------------------------------------------------------------------*
*&      Form  UML_CHECK_BUCHEN_PRODME                       "ALRK115218
*&---------------------------------------------------------------------*
FORM uml_check_buchen_prodme.
ENHANCEMENT-POINT ALTERNATIVE_MENGEN_08 SPOTS ES_SAPMM07M.

* Nur bei Abwicklung mit ProduktME ist die Tabelle gefüllt
  CHECK NOT umseg[] IS INITIAL.

* Lokale Deklarationen
  DATA: loc_x_mng LIKE mseg-menge,   "Sperrmenge aus Enqeue-Tabelle
        loc_menge LIKE mseg-menge,   "Mengenfeld zum Kumulieren
        loc_altmg LIKE mseg-menge,   "Mengenfeld zum Kumulieren
        loc_umren LIKE dm07m-umren,
        loc_umrez LIKE dm07m-umrez,
        loc_marm_ws LIKE marm OCCURS 0 WITH HEADER LINE,
        loc_umref_rest  TYPE f,      "Umrechn. des Restbestands
        loc_umref_charg TYPE f,      "Umrechn. der abgebenden Charge
        loc_result(2) TYPE c.     "Ergebnis des Vergleichs zweier Zahlen

* Aufbau der Seg_Tab (kann u.U. auch in der Position bereits erfolgen)
* Diese Tabelle ist eine Liste der Segmente aus denen mit abw. Umref
* umgelagert wird.
  CLEAR: seg_tab, transf_qty.
  REFRESH: seg_tab, transf_qty.
  LOOP AT umseg.
ENHANCEMENT-SECTION     UML_CHECK_BUCHEN_PRODME_01 SPOTS ES_SAPMM07M.
    READ TABLE seg_tab WITH KEY matnr      = umseg-matnr
                                werks      = umseg-werks
                                lgort      = umseg-lgort
                                charg      = umseg-charg
                                sobkz      = umseg-sobkz
                                kdauf      = umseg-kdauf
                                kdpos      = umseg-kdpos
                                lifnr      = umseg-lifnr
                                ps_psp_pnr = umseg-ps_psp_pnr
                                kunnr      = umseg-kunnr.
END-ENHANCEMENT-SECTION.
    IF NOT sy-subrc EQ 0.
      MOVE-CORRESPONDING umseg TO seg_tab.
      APPEND seg_tab.
    ENDIF.
  ENDLOOP.

* Produktmengenabwicklung: Umlagerung mit abw. Faktor
* (Tabelle ist initial in allen anderen Fällen)
  CHECK NOT seg_tab[] IS INITIAL.

  LOOP AT seg_tab.
*--- Nachlesen des Sperrtabelleneintrags für das entsprechende Segment
    PERFORM uml_read_enq_stock USING    seg_tab
                               CHANGING loc_x_mng.

*--- Überprüfung nicht noetig bei vollst. Ausbuchung des Segments
    CHECK loc_x_mng NE 0.

*--- Überprüfen der Nachkommastellen für alle abgebenden Segmente,
*--- falls Restbestände vorhanden sind
    READ TABLE zmseg WITH KEY matnr = seg_tab-matnr.
    CALL FUNCTION 'MURC_MENGENUMRECHNUNG'
      EXPORTING
        matnr                = seg_tab-matnr
        werks                = seg_tab-werks
        charg                = seg_tab-charg
        menge                = loc_x_mng
        erfmg                = loc_x_mng
        erfme                = zmseg-meins
        trtyp                = t158-trtyp
        no_dialog            = 'A'
        values_keep          = 'A'
      EXCEPTIONS
        calculation_wrong    = 1
        batch_not_classified = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE e054(xu).
*       Fehler b Umbuchung auf eine Charge mit anderem Umrechnungsfaktor
    ENDIF.

*--- Auf der abgebenden Charge darf kein Restbestand verbleiben
*    oder der Umrechnungsfaktor der sich aus Menge Restbestand in
*    BasisME und Menge Restbestand in ProdME ergibt, muß genau dem
*    Umrechnungsfaktor dieser Charge in entsprechen. Ist dies in
*    allen ProdME erfüllt, die in der Abweichungstabelle enthalten
*    sind, dann darf auch mit Restbestand gebucht werden.
    loc_menge = loc_x_mng.

*--- Nachlesen der ProdME für jedes Material neu
    PERFORM uml_read_marm_ws TABLES loc_marm_ws
                             USING  seg_tab-matnr.
*--- Kumulieren der urspr. Lagermenge und der Transfermenge in ProdME
    PERFORM uml_cumulate_quantities
                       TABLES   transf_qty
                       USING    seg_tab
                       CHANGING loc_menge.

*--- Prüfen, ob Umrefs der Restmenge den Chargen-Umrefs enstprechen
    CLEAR loc_altmg.
    LOOP AT loc_marm_ws.
      READ TABLE transf_qty WITH KEY meinh = loc_marm_ws-meinh.
*------ Umrechnen der urspruengl. vorhandenen Menge in alle ProdME
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input                = loc_menge
          matnr                = seg_tab-matnr
          meinh                = loc_marm_ws-meinh
          charge               = seg_tab-charg
          werks                = seg_tab-werks
        IMPORTING
          output               = loc_altmg
          umren                = loc_umren
          umrez                = loc_umrez
        EXCEPTIONS
          conversion_not_found = 1
          input_invalid        = 2
          material_not_found   = 3
          meinh_not_found      = 4
          meins_missing        = 5
          no_meinh             = 6
          output_invalid       = 7
          overflow             = 8
          OTHERS               = 9.

*------ Berechung des Umref für den Restbestand für die aktuelle MEINH
      loc_umref_rest  = ( loc_altmg - transf_qty-altmg ) / loc_x_mng.
      loc_umref_charg = loc_umren / loc_umrez.
      PERFORM float_compare USING    loc_umref_rest
                                     loc_umref_charg
                            CHANGING loc_result.
      IF loc_result EQ 'NE'.
        MESSAGE e055(xu).
*          MUR-Fehler bei Umlagerung. Buchen unmgl.
      ENDIF.
    ENDLOOP."loc_marm_ws

  ENDLOOP. "seg_tab

  REFRESH UMSEG.

ENDFORM.                    " UML_CHECK_BUCHEN_PRODME
*&---------------------------------------------------------------------*
*&      Form  FILL_TEXTFIELD
*&---------------------------------------------------------------------*
FORM fill_textfield USING    i_menge
                             i_meins
                    CHANGING o_text.

* Local Declarations
  DATA: loc_textmeinh(3),
        loc_text(20).

  WRITE i_menge TO loc_text UNIT i_meins.
  SHIFT loc_text LEFT DELETING LEADING space.
  WRITE i_meins TO loc_textmeinh.
  CONCATENATE loc_text loc_textmeinh
             INTO o_text SEPARATED BY space.

ENDFORM.                    " FILL_TEXTFIELD