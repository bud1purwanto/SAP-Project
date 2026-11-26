*----------------------------------------------------------------------*
*   FORM Chargenverwendungsnachweis.                                   *
*----------------------------------------------------------------------*
*   Anhand verschiedener Kriterien (Chargenpflicht, Chargennummer,     *
*   Chargenpfl.des Umlagermaterials, Fortschreibung aktiv für Werk     *
*   und Umlagerungswerk, nur Zustandsänderung od. Umbuchung zw.        *
*   Lagerorten) wird entschieden, ob eine Fortschreibung erfolgt!      *
*   Falls ja, wird ein CHVW-Satz erstellt und abgelegt!                *
*----------------------------------------------------------------------*
ENHANCEMENT-POINT mm07mfc9_01 SPOTS es_sapmm07m STATIC.
*&--------------------------------------------------------------------*
*&      Form  chargenverwendungsnachweis
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM chargenverwendungsnachweis.

  TABLES:
    aufk,
    ekkn.

  STATICS:
    xchpf_local         LIKE xvm07m-xchpf,
    zeild_local         LIKE zdm07m-zeild,
    kzuml               LIKE dm07m-kzuml.

*--- EhP 604 - No batch where used list for WiP Batches
  DATA:
    ls_mcha             TYPE smcha,
    ls_mch1             TYPE smch1.
*--- EhP 604

  CLEAR xchvw.

* Zustandsänderungen nicht protokollieren:
  CHECK xmseg-bwart NE bwart_341.
  CHECK xmseg-bwart NE bwart_342.

* Nachverrechnungssätze sind zur Chargenverfolgung nicht relevant:
  CHECK xmseg-kzbew NE 'O'.

* Prüfen, ob Matnr / Werks / Charge gefüllt ist:
  CHECK NOT ( xmseg-matnr IS INITIAL OR
              xmseg-werks IS INITIAL OR
              xmseg-charg IS INITIAL ).

* Für Umbuchungen Chargenpflicht von Buchungssatz(1) merken:
  IF zeild_local NE zdm07m-zeild.
    MOVE xvm07m-xchpf TO xchpf_local.
    MOVE zdm07m-zeild TO zeild_local.
  ENDIF.

* Ist Material chargenpflichtig?
  CHECK NOT xvm07m-xchpf IS INITIAL.

* Umbuchungskennzeichen übernehmen:
  kzuml = zdm07m-kzuml.

  IF kzuml IS INITIAL.
* Buchung ist keine Umlagerung
* Sicherheitshalber alle UM...-Felder löschen:
    CLEAR: xmseg-umwrk, xmseg-ummat, xmseg-umcha.

* Lese Werkseinstellung zur CHVW (Synchr.Buchen / CHVW deaktiv):
* T159L-XCHVW: Synchrones Buchen von Chargenverwendungssätzen
* T159L-XCHVA: Chargenverwendungsnachweis deaktiviert
    CASE t159l-werks.
      WHEN xmseg-werks.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
      WHEN OTHERS.
        SELECT SINGLE * FROM t159l WHERE werks = xmseg-werks.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
    ENDCASE.

* Prüfungen, falls Vorgang eine Umbuchung ist:
  ELSE.
* check whether the transfer posting is relevant for BWUL
    CHECK xmseg-matnr NE xmseg-ummat OR
          xmseg-werks NE xmseg-umwrk OR
          xmseg-charg NE xmseg-umcha.
* Im folgenden soll CHVW fortgeschrieben werden, wenn WERKS oder UMWRK
* für Chargenverwendungsnachweis aktiv ist!
* Lese Werkseinstellungen zur CHVW (Synchr.Buchen / CHVW deaktiv):
    CASE t159l-werks.
      WHEN xmseg-werks.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
        SELECT SINGLE * FROM t159l WHERE werks = xmseg-umwrk.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
      WHEN xmseg-umwrk.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
        SELECT SINGLE * FROM t159l WHERE werks = xmseg-werks.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
      WHEN OTHERS.
        SELECT SINGLE * FROM t159l WHERE werks = xmseg-werks.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
        SELECT SINGLE * FROM t159l WHERE werks = xmseg-umwrk.
        CHECK NOT t159l-xchvw IS INITIAL AND t159l-xchva IS INITIAL.
    ENDCASE.
  ENDIF.

* No batch where-used list for WiP-Batches.
  IF gv_wipbatch_active = abap_true.
    READ TABLE xmcha INTO ls_mcha
      WITH KEY matnr = xmseg-matnr
               werks = xmseg-werks
               charg = xmseg-charg
      TRANSPORTING batch_type.

    READ TABLE xmch1 INTO ls_mch1
      WITH KEY matnr = xmseg-matnr
               charg = xmseg-charg
      TRANSPORTING batch_type.

    IF ls_mch1-batch_type = 1 OR ls_mcha-batch_type = 1.
      RETURN.
    ENDIF.
  ENDIF.

* Alle Bedingungen erfüllt! CHVW soll gefüllt werden:
  MOVE-CORRESPONDING xmseg TO xchvw.

  xchvw-xstbw = zdm07m-xstbw.
  xchvw-vfdat = xmseg-vfdat.
  xchvw-verab = xvm07m-verab.
  xchvw-lifnr = xvm07m-lifch.
  xchvw-licha = xvm07m-licha.
  IF NOT xvm07m-kdauf_sd IS INITIAL.                        "1480172
    xchvw-kdauf = xvm07m-kdauf_sd.                          "1130423
    xchvw-kdpos = xvm07m-kdpos_sd.                          "1130423
  ENDIF.

* In case of assembly processing check for order number
  IF     xchvw-aufnr     IS INITIAL AND
     NOT xmseg-mat_kdauf IS INITIAL AND
     NOT xmseg-rsnum     IS INITIAL.
    SELECT SINGLE aufnr
      INTO xchvw-aufnr
      FROM resb
      WHERE rsnum EQ xmseg-rsnum
        AND rspos EQ xmseg-rspos
        AND rsart EQ xmseg-rsart.
  ENDIF.

* For networks either the field MSEG-AUFNR or MSEG-NPLNR filled
* (1235378)

  IF xchvw-aufnr IS INITIAL AND NOT mseg-nplnr IS INITIAL.
    xchvw-aufnr = mseg-nplnr.
  ENDIF.

* Bei der Fortschreibung zum Verwendungsentscheid muss Auftrags- und
* Bestellnummer entfernt werden, damit es nicht zur Rekursivität kommt
  IF xmkpf-vgart EQ 'WQ'.
* In the case of return delivery and scrapping do not clear reference
* (note 1123361)
    DATA: lv_bustr TYPE bustr.                           "1633070
    SELECT SINGLE bustr FROM t156
                        INTO lv_bustr
                       WHERE bwart = xchvw-bwart.
    IF sy-subrc IS INITIAL.
      IF lv_bustr NE '101' AND lv_bustr NE '551' .       "1633070
* Verbindung zum Auftrag bzw. Bestellung lösen:
      CLEAR: xchvw-kzbew.
* Einkaufsbelegnummer und -position löschen
      CLEAR: xchvw-ebeln, xchvw-ebelp.
* Auftragsnummer und -position löschen
      CLEAR: xchvw-aufnr, xchvw-aufps.
      ENDIF.
    ENDIF.
  ENDIF.

* Nachlesen des Auftragstyps:
  IF NOT xchvw-aufnr IS INITIAL.
    SELECT SINGLE * FROM  aufk WHERE aufnr EQ xchvw-aufnr.
    IF sy-subrc IS INITIAL.
      MOVE aufk-autyp TO xchvw-autyp.
    ENDIF.
  ENDIF.

* check for subcontracting subsequent adjustment
  READ TABLE xmseg
    TRANSPORTING NO FIELDS
    WITH KEY
      kzbew = 'O'.
  IF sy-subrc IS INITIAL.
    xchvw-kzbew = 'O'.
  ENDIF.

* Buchungen mit Bezug zu Bestellungen, Lieferungen und Fertigung
* werden mit festem Zugangskennzeichen abgelegt (->Kumulierung!)
  CASE xchvw-kzbew.
    WHEN f OR b.
* Bezüge zu Fertigung und Bestellungen werden immer mit XZUGA = ' '
* abgelegt:
      PERFORM zugang.
    WHEN OTHERS.
      CASE xchvw-shkzg.
        WHEN s.
          IF zdm07m-xstbw IS INITIAL.
            PERFORM zugang.
          ELSE.
            PERFORM abgang.
          ENDIF.
        WHEN h.
          IF zdm07m-xstbw IS INITIAL.
            PERFORM abgang.
          ELSE.
            PERFORM zugang.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENHANCEMENT-POINT chargenverwendungsnachweis_02 SPOTS es_sapmm07m STATIC.
ENHANCEMENT-POINT chargenverwendungsnachweis_01 SPOTS es_sapmm07m.
* movement indicator for goods movements for rSTO have to be switched
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) EQ abap_true.
    IF xmkpf-msr_active EQ abap_true.
      IF xchvw-xstbw IS INITIAL.
        xchvw-xstbw = 'X'.
      ELSE.
        CLEAR xchvw-xstbw.
      ENDIF.
    ENDIF.
  ENDIF.

  APPEND xchvw.

ENDFORM.                    "chargenverwendungsnachweis
*eject
*----------------------------------------------------------------------*
* Form ZUGANG                                                          *
* Fuer einen Wareneingang , Eingangsstorno und Umlagerungen            *
* wird eine Zuganssatz erstellt.                                       *
* Das Kennzeichen XZUGA sitzt auf ' '.                                 *
* Für WE's auf Auftrag kontierte Bestellungen werden zwei CHVW-Sätze   *
* erzeugt.                                                             *
*----------------------------------------------------------------------*
FORM zugang.

  DATA: lv_ebeln TYPE ebeln,
        lv_ebelp TYPE ebelp.

  IF xchvw-sobkz = e AND xchvw-kdauf IS INITIAL.
    xchvw-kdauf = xmseg-mat_kdauf.
    xchvw-kdpos = xmseg-mat_kdpos.
  ENDIF.
  IF NOT xvm07m-xinvb IS INITIAL       "Inventurbewegungsart
     OR  xmkpf-vgart EQ 'WI'.
    CLEAR: xchvw-aufnr, xchvw-aufps.
  ENDIF.
  IF xchvw-lifnr IS INITIAL.
    MOVE xvm07m-lifch TO xchvw-lifnr.  "Lieferantenummer
  ENDIF.
  CLEAR xchvw-xzuga.
  IF xmseg-kzbew = b.
* Bestellung mit Kontierungstyp F
    IF xmseg-kzvbr = v AND ( zdm07m-knttp = f OR zdm07m-knttp = n )
                       AND ( xchvw-autyp EQ '05' OR
                             xchvw-autyp EQ '10' OR
                             xchvw-autyp EQ '20' OR
                             xchvw-autyp EQ '40' ).
  IF  cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) IS INITIAL.
* 1.) Erzeugen eines 'WA-Beleges' für die Zuordnung zum Auftrag
      MOVE: 'X' TO xchvw-xzuga.

      APPEND xchvw.
  ENDIF.
* 2.) Erzeugen eines 'WE-Beleges' für die Zuordnung zum Materialeingang
      CLEAR: xchvw-xzuga, xchvw-aufnr, xchvw-aufps.

    ENDIF.
    IF xmseg-sobkz NE 'O'.
* Positionstyp in Bestellung nachlesen:
      PERFORM get_po_data.
    ELSE.
      MOVE xvm07m-pstyp  TO xchvw-pstyp.
    ENDIF.
  ENDIF.

* Remove KZBEW = L for inbound deliveries -> 521 movement
  IF xchvw-kzbew = l.
    CLEAR xchvw-kzbew.
  ENDIF.

* By-products from subcontracting
  IF xmseg-sobkz EQ 'O'.
    MOVE xvm07m-pstyp  TO xchvw-pstyp.
  ENDIF.

ENDFORM.                    "zugang

*----------------------------------------------------------------------*
* Form ABGANG                                                          *
* Fuer einen Warenabgang , Abgangsstorno und Umlagerungen              *
* wird eine Abgangssatz erstellt.                                      *
* Das Kennzeichen XZUGA sitzt auf 'X'.                                 *
*----------------------------------------------------------------------*
FORM abgang.
  IF NOT xvm07m-xinvb IS INITIAL       "Inventurbewegungsart
     OR  xmkpf-vgart EQ 'WI'.
    CLEAR: xchvw-aufnr, xchvw-aufps.
  ENDIF.
  IF xchvw-lifnr IS INITIAL.
    MOVE xvm07m-lifch TO xchvw-lifnr.  "Lieferantenummer
  ENDIF.
  xchvw-xzuga = x.
  IF xmseg-sobkz = o.                  "LB-Bestellung
    IF xmseg-kzvbr = v.                "Verbrauch
* Nachlesen der Bestellposition:
      SELECT SINGLE * FROM ekpo WHERE ebeln EQ xmseg-ebeln
                                AND   ebelp EQ xmseg-ebelp.
* Ist die Bestellung auf einen Auftrag kontiert?
      IF sy-subrc IS INITIAL AND ( ekpo-knttp = f OR ekpo-knttp = n ).
* Nachlesen der Kontierung (Mehrfachkontierung kann hier nicht
* berücksichtigt werden! Bei Mehrfachkontierung wird die Zuweisung
* i.a.R. erst beim Rechnungseingang (Bewertung) getroffen!
        SELECT SINGLE * FROM ekkn WHERE ebeln EQ xmseg-ebeln
                                  AND   ebelp EQ xmseg-ebelp
                                  AND   zekkn EQ '01'.
        IF sy-subrc IS INITIAL.
* EKKN-AUFNR liefert den Kontierungsauftrag
          MOVE ekkn-aufnr TO xchvw-aufnr.
        ENDIF.
* For components of a subcontracting order the GR item is checked
* whether it deals with a service (outside shop)
        IF zdm07m-xstbw IS INITIAL.
          READ TABLE xmseg
            WITH KEY matnr = ' '
                     shkzg = 'S'
                     kzbew = 'B'.
          IF sy-subrc IS INITIAL.
            CLEAR: xchvw-ebeln, xchvw-ebelp.
          ENDIF.
* reversal for a subcontracting order (outside shop)
        ELSE.
          READ TABLE xmseg
            WITH KEY matnr = ' '
                     shkzg = 'H'
                     kzbew = 'B'.
          IF sy-subrc IS INITIAL.
            CLEAR: xchvw-ebeln, xchvw-ebelp.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF xchvw-sobkz EQ e.                  "Kundenauftragsbestand
    IF xchvw-kdauf IS INITIAL.
      xchvw-kdauf = xmseg-mat_kdauf.
      xchvw-kdpos = xmseg-mat_kdpos.
    ENDIF.
  ENDIF.
  IF xmseg-sobkz NE 'O'.
* Positionstyp in Bestellung nachlesen:
    PERFORM get_po_data.
  ELSE.
    MOVE xvm07m-pstyp  TO xchvw-pstyp.
  ENDIF.

ENDFORM.                    "abgang
*eject
*&---------------------------------------------------------------------*
*&      Form  GET_PO_DATA
*&---------------------------------------------------------------------*
*       Lesen der Bestellposition
*----------------------------------------------------------------------*
FORM get_po_data.
  DATA reswk LIKE ekko-reswk.
  IF xvm07m-pstyp EQ '0' OR xvm07m-pstyp EQ '3'.
    SELECT SINGLE reswk INTO reswk FROM ekko
                        WHERE ebeln EQ xchvw-ebeln.
    IF NOT reswk IS INITIAL.
      xchvw-pstyp = '7'.
    ELSE.
      xchvw-pstyp = xvm07m-pstyp.
    ENDIF.
  ELSE.
    xchvw-pstyp = xvm07m-pstyp.
  ENDIF.
ENDFORM.                    " GET_PO_DATA
*eject
*----------------------------------------------------------------------*
*     Pruefen der extern vergegebenen Warenbegleitscheinnummer         *
*----------------------------------------------------------------------*
FORM check_exab_number USING w-bwart LIKE mseg-bwart
                             w-werks LIKE mseg-werks
                             w-lgort LIKE mseg-lgort
                             w-xabln LIKE mkpf-xabln
                             w-kzxab LIKE t159l-kzxab.
  IF NOT pre_werks IS INITIAL.
    IF w-kzxab NE pre_kzxab.
      MESSAGE e135.
    ENDIF.
  ELSE.
    pre_werks = w-werks.
    pre_kzxab = w-kzxab.
    IF w-kzxab IS INITIAL.
      CLEAR rm07m-xabln.
      EXIT.
    ENDIF.
    CALL FUNCTION 'REFRESH_XAB_NUMBER'.
  ENDIF.
  CHECK NOT w-kzxab IS INITIAL.                             "170353
  CLEAR flag1.
  CALL FUNCTION 'CHECK_XAB_NUMBER'
    EXPORTING
      xbwart               = w-bwart
      xwerks               = w-werks
      xlgort               = w-lgort
      xkzxab               = w-kzxab
    IMPORTING
      xnumke               = xnumke
      xnumki               = xnumki
    EXCEPTIONS
      number_different     = 01
      number_not_found     = 02
      number_not_necessary = 03.
  IF sy-subrc = 01.
    MESSAGE e136.
  ELSEIF sy-subrc = 02.
    MESSAGE e137.
  ELSEIF sy-subrc = 03.
    MESSAGE e138.
  ENDIF.

  CALL FUNCTION 'NUMBER_CHECK'
    EXPORTING
      nr_range_nr = xnumke
      number      = w-xabln
      object      = 'XABBELEGNR'
      toyear      = mkpf-mjahr
    IMPORTING
      returncode  = flag1.
  IF NOT flag1 IS INITIAL.
    MESSAGE e139 WITH rm07m-xabln.
  ENDIF.
ENDFORM.                    "check_exab_number
*----------------------------------------------------------------------*
*            Vergabe der XAB-Nummer                                    *
*----------------------------------------------------------------------*
FORM xab-nummer_vergeben.
  CHECK NOT xnumki IS INITIAL.
  CHECK mkpf-xabln IS INITIAL.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = xnumki
      object                  = 'XABBELEGNR'
      toyear                  = xmkpf-mjahr
    IMPORTING
      number                  = xmkpf-xabln
      returncode              = vw
    EXCEPTIONS
      interval_not_found      = 01
      number_range_not_intern = 02
      object_not_found        = 03
      quantity_is_0           = 04
      quantity_is_not_1       = 05
      interval_overflow       = 06
      error_message           = 07.                         "HW 407326

  IF sy-subrc <> 0.
* Need to change the message type to 'A', so that if there is
* any error message encountered during the accessing of the Number
* Range, the updating processing in FORM BUCHEN_AUSFUEHREN will be
* rollback.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno              "HW 407326
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CASE vw.
    WHEN 1.
* Change the message to 'I' just to make sure that if there is
* any 'I' or 'W' message, user has the choice to continue or
* abandon the update processing.
*     MESSAGE w560.                                     "HW 407326
      MESSAGE i560.                                         "HW 407326
    WHEN 2.
*     MESSAGE w561.                                     "HW 407326
      MESSAGE i561.                                         "HW 407326
  ENDCASE.
ENDFORM.                    "xab-nummer_vergeben
*eject
*----------------------------------------------------------------------*
*            Prüfung der Position bzgl. XAB-Zugehörigkeit
*----------------------------------------------------------------------*
FORM check_exab_position USING w-bwart LIKE mseg-bwart
                               w-werks LIKE mseg-werks
                               w-lgort LIKE mseg-lgort
                               w-kzxab LIKE t159l-kzxab.
*- Problem bei Umlagebestellung --------------------       "note128688
  IF NOT pre_werks IS INITIAL.
    IF w-kzxab NE pre_kzxab.                                "note128688
      MESSAGE e135.
    ENDIF.
  ELSE.
    pre_werks = w-werks.                                    "note128688
    pre_kzxab = w-kzxab.                                    "note128688
    CHECK NOT w-kzxab IS INITIAL.                           "note128688
    CALL FUNCTION 'REFRESH_XAB_NUMBER'.
  ENDIF.
  IF w-kzxab IS INITIAL.
    EXIT.
  ENDIF.
  CALL FUNCTION 'CHECK_XAB_NUMBER'
    EXPORTING
      xbwart               = w-bwart
      xwerks               = w-werks
      xlgort               = w-lgort
    IMPORTING
      xnumke               = xnumke
      xnumki               = xnumki
    EXCEPTIONS
      number_different     = 01
      number_not_found     = 02
      number_not_necessary = 03.
  IF sy-subrc = 01.
    MESSAGE e136.
  ELSEIF sy-subrc = 02.
    MESSAGE e137.
  ELSEIF sy-subrc = 03.
    MESSAGE e138.
  ENDIF.
ENDFORM.                    "check_exab_position
*----------------------------------------------------------------------*
* Hier wird der Nummernkreis für die XAB-Nummer ermittelt und seine    *
* Zulässigkeit in Bezug auf die Vorangegangenen Positionen geprüft.    *
*----------------------------------------------------------------------*
FORM check_ixab_number USING w-bwart LIKE mseg-bwart
                             w-werks LIKE mseg-werks
                             w-lgort LIKE mseg-lgort
                             w-kzxab LIKE t159l-kzxab.

* Im anderen Werk keine XAB-pflicht, dann darf im Beleg bisher keine
* XAB - Nummer vergeben sein.
  IF NOT pre_werks IS INITIAL.
    IF w-kzxab NE pre_kzxab.
      MESSAGE e135.
    ENDIF.
  ELSE.
    pre_werks = w-werks.                                    "note128688
    pre_kzxab = w-kzxab.                                    "note128688
    CALL FUNCTION 'REFRESH_XAB_NUMBER'.
  ENDIF.
  IF w-kzxab IS INITIAL.
    EXIT.
  ENDIF.
  CALL FUNCTION 'CHECK_XAB_NUMBER'
    EXPORTING
      xbwart               = w-bwart
      xwerks               = w-werks
      xlgort               = w-lgort
      xkzxab               = w-kzxab
    IMPORTING
      xnumke               = xnumke
      xnumki               = xnumki
    EXCEPTIONS
      number_different     = 01
      number_not_found     = 02
      number_not_necessary = 03.
  IF sy-subrc = 01.
    MESSAGE e136.
  ELSEIF sy-subrc = 02.
    MESSAGE e137.
  ELSEIF sy-subrc = 03.
    MESSAGE e138.
  ENDIF.
ENDFORM.                    "check_ixab_number
*eject