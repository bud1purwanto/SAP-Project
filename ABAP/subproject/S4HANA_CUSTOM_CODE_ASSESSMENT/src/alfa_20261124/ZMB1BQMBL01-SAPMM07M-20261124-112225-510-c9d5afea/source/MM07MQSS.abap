DATA: BEGIN OF g_qm_pos,
        chargestern,                   "Kz. Charge wurde mit * belegt
        lgortstern   LIKE qm00-qkz,    "Kz. LgOrt wurde mit * belegt
        menge_wkst   LIKE mseg-menge,  "Menge bei Wirkstoffabwicklung
        zwei_schritt LIKE qm00-qkz,    "Kz. Los im Zwei-Schrittverf.erz.
      END OF g_qm_pos.
TABLES: mbqss.                         "Schnittstellenstruktur
TABLES: t156q.                         "Deaktivieren Prüfabwicklung
*---------------------------------------------------------------------*
*       FORM QSS_PRUEFEN                                              *
*---------------------------------------------------------------------*
*       Es wird folgendes geprüft                                     *
*       a) ist ein Los zu erzeugen ?                                  *
*       b) darf eine Bestandsbuchung durchgeführt werden, wenn QM     *
*          nicht im Spiel ist ?                                       *
*       Anmerkung : Die Form wird beim Hinzufügen und beim Ändern     *
*                   einer Position aufgerufen                         *
*---------------------------------------------------------------------*
FORM qss_pruefen.
*
  DATA  : l_subrc             LIKE sy-subrc,
          l_flag_qstock       LIKE qals-stat01  VALUE 'X'.

*-- Lokale Variablen zur Steuerung der Check-Funktionen WE
  DATA  : l_insnc,
          l_insmk       LIKE mseg-insmk,
          l_bsart       LIKE qals-insmk,          "Bestandsart
          l_kzwes_q     LIKE qals-stat11,
          l_art         LIKE qinfinspt-insptype,  "Prüfart aus QINF
          l_qplos       LIKE vm07m-qplos,
          l_cert_req    LIKE rmqed-cert_req ,     "Zeugniseingang
          l_qinfupd     LIKE qinfinspt-qinfupd ,  "QINF zu ändern
          l_status      LIKE qinfinspt-status  .  "Status aus QINF

* lokale Variable
  DATA :  l_matnr         LIKE mseg-matnr,
          l_matnr_ur      LIKE mseg-matnr,  "Ursprüngliches Material
          l_werks         LIKE mseg-werks,
          l_werks_ur      LIKE mseg-werks,  "Ursprüngliches Werk
          l_charg         LIKE mseg-charg,
          l_charg_ur      LIKE mseg-charg,
          l_menge         LIKE mseg-menge,
          l_meins         LIKE mseg-meins,
          l_lbbsa         LIKE vm07m-lbbsa,
          l_lbbsa_ur      LIKE vm07m-lbbsa, "Ursprüngliche Bestandsart
          l_lgort         LIKE mseg-lgort,
          l_lgort_ur      LIKE mseg-lgort,
          l_sobkz         LIKE mseg-sobkz,
          l_kdauf         LIKE mseg-kdauf,
          l_kdpos         LIKE mseg-kdpos,
          l_pspnr         LIKE mseg-ps_psp_pnr,
          l_mengu         LIKE mseg-mengu,
          l_xhupf         LIKE vm07m-xhupf,
          l_xhupf_ur      LIKE vm07m-xhupf, "Ursprüngliche HUMPflicht
          l_xblnr         LIKE mkpf-xblnr.
* lokale Hilfsvariable
  DATA:   h_charg         LIKE mseg-charg.
  DATA :  L_COKZ          LIKE COBL_COKZ.

*SPM/QM control flag for external inspection
  DATA:  lv_qstock_change type qlext_qstockchange.

* QM im Anzeigen nicht aktiv
  CHECK aktyp NE a.                    "anzeigen
*
* Menge und Mengeneinheit übernehmen.
  MOVE: mseg-menge TO l_menge,
        mseg-meins TO l_meins.
*-- Materialnummer 0 nur bei Fremdbearbeitung
  IF         mseg-matnr IS INITIAL
    AND (    dm07m-aufpl_ord IS INITIAL
         AND dm07m-aplzl_ord IS INITIAL ).
    EXIT.
  ELSEIF           mseg-matnr      IS INITIAL
     AND (     NOT dm07m-aufpl_ord IS INITIAL
           AND NOT dm07m-aplzl_ord IS INITIAL ) .
* Fremdbearbeituung: Erfassungsmenge und Erfassungs-ME übernehmen.
    MOVE: mseg-erfmg TO l_menge,
          mseg-erfme TO l_meins.
  ENDIF.
  IF vm07m-kzwes EQ s .
*   Buchung zum WE-Sperrbestand
    IF mseg-shkzg EQ s.                "kein Storno
      MOVE x TO l_kzwes_q.
    ENDIF.
  ENDIF.
* Falls Buchung zu Herkunft 01, darf es keine intern VE-Buchung sein.
* -> da dies Umbuchung aus VE (BWA 103 + 105 wäre)
  IF    vm07m-qsshk EQ '01'
    AND NOT qss_aufruf IS INITIAL.
    EXIT.      "nicht QM-relevant das zweites WE-Los.
  ENDIF.
*--------------------------------------------------------------------
  IF NOT ( (   vm07m-qsshk EQ '05'
            OR vm07m-qsshk EQ '08'
            OR dm07m-kzuml NE space )
          AND mseg-shkzg   EQ h      )."Umbuchung Zeile 1 nach 2
*   keine Umlagerung
    MOVE : mseg-matnr     TO l_matnr,
           mseg-ummat     TO l_matnr_ur,
           mseg-charg     TO l_charg,
           mseg-umcha     TO l_charg_ur,
           mseg-werks     TO l_werks,
           mseg-umwrk     TO l_werks_ur,
           vm07m-lbbsa    TO l_lbbsa,
           dm07m-umlbb    TO l_lbbsa_ur,
           vm07m-xhupf    TO l_xhupf,
           dm07m-umxhupf  TO l_xhupf_ur,
           mseg-mat_kdauf TO l_kdauf,
           mseg-mat_kdpos TO l_kdpos,
           mseg-mat_pspnr TO l_pspnr,
           mseg-sobkz     TO l_sobkz,
           mseg-lgort     TO l_lgort,
           mseg-umlgo     TO l_lgort_ur.
  ELSE.
*   Umlagerung
    MOVE : mseg-ummat      TO l_matnr,
           mseg-matnr      TO l_matnr_ur,
           mseg-umcha      TO l_charg,
           mseg-charg      TO l_charg_ur,
           mseg-umwrk      TO l_werks,
           mseg-werks      TO l_werks_ur,
           mseg-kdauf      TO l_kdauf,
           mseg-kdpos      TO l_kdpos,
           mseg-ps_psp_pnr TO l_pspnr,
           mseg-umsok      TO l_sobkz,
           dm07m-umlbb     TO l_lbbsa,
           vm07m-lbbsa     TO l_lbbsa_ur,
           dm07m-umxhupf   TO l_xhupf,
           vm07m-xhupf     TO l_xhupf_ur,
           mseg-umlgo      TO l_lgort,
           mseg-lgort      TO l_lgort_ur.
  ENDIF.
* Chargenhilfsfeld füllen
  IF     vm07m-qsshk EQ '02'
     AND dm07m-kzuml NE space.
    h_charg = l_charg_ur.
  ELSE.
    h_charg = l_charg.
  ENDIF.
* Auswerten Tabelle T156Q   -> Deaktivieren QM
  PERFORM qss_aktiv_t156q USING mseg-bwart      l_sobkz
                                mseg-kzbew      mseg-kzzug
                                mseg-kzvbr      mseg-smbln
                                vm07m-xstor
                       CHANGING vm07m-qsshk.
  IF    NOT (     vm07m-qsshk IS INITIAL AND vm07m-kzwes EQ s    )
     OR     ( NOT mseg-smbln  IS INITIAL AND vm07m-xstor EQ zwei ).
* nicht falls Sperrbestand und keine Herkunft und kein echter Storno
    IF qss_aufruf IS INITIAL.
*-- ... kein Test bei Aufruf aus VE
*   Betrifft Bewegung Q-Bestand? (vgl. T156M!) ?
      IF    l_lbbsa_ur EQ '02'
*       abgebender Lagerort HUM pflichtig
        AND l_xhupf_ur IS INITIAL
*       Menge nicht initial
        AND NOT mseg-menge  IS INITIAL
*   ... und QM-relevanter Sonderbestand (normal, Konsi,Projekt,Kd-Einzl)
        AND l_sobkz CA 'EKQ '
*   ... und Umlagerung liegt vor                                     .
        AND (   dm07m-kzuml NE space
             OR l_matnr_ur NE l_matnr  "Umlagerung liegt vor !!!
             OR l_werks_ur NE l_werks )"Umlagerung liegt vor !!!
*   ... und es liegt kein echter Storno vor                          .
        AND (   mseg-smbln IS INITIAL
             OR vm07m-xstor NE zwei ).

*SPM/QM control QI stock change             -->begin change
      CALL METHOD /SPE/QSTOCK_CHANGE_CHECK=>checkposting
        EXPORTING
          ip_plant        = l_werks_ur
          ip_sloc         = l_lgort_ur
          ip_kzzug        = mseg-kzzug
          ip_mkpf         = mkpf
        IMPORTING
          EP_QSTOCKCHANGE =  lv_qstock_change.

      If lv_qstock_change is initial.
*     Umlagerung: Prüfen , ob Buchung für Ursprung möglich ist
        CALL FUNCTION 'QPWE_QSTOCK_CHANGE_ALLOWED'
          EXPORTING
            i_matnr = l_matnr_ur
            i_werks = l_werks_ur
          IMPORTING
            e_insnc = l_insnc
          EXCEPTIONS
            no_tq32 = 0.
      endif.
      clear lv_qstock_change.
*SPM/QM control QI stock change             <--- end change

*     Keine Änderung erlaubt
        IF NOT l_insnc IS INITIAL.
          MESSAGE e495(qa) WITH l_matnr_ur.
        ENDIF.
      ENDIF.
    ENDIF.
    IF l_lbbsa EQ '02'.
*   Buchen in Q-Bestand muß bei Loszusammenfassung berücksichtigt werden
      l_bsart = '2'.
    ENDIF.

* Korrektur einer Position
    IF   aktyp                EQ k     "korrigieren
      OR g_qm_pos-chargestern EQ x     "Charge = *
      OR g_qm_pos-lgortstern  EQ x     "Lagerort = *
      OR (    kzdws EQ 1               "Wirkstoffabwicklung
          AND NOT dm07m-kzwso IS INITIAL
          AND mseg-menge NE g_qm_pos-menge_wkst ) .
*----- QM-Abwicklung ------------------
      IF               l_matnr         IS INITIAL
         AND (     NOT dm07m-aufpl_ord IS INITIAL
               AND NOT dm07m-aplzl_ord IS INITIAL ).
* Bei Fremdvergabe ermitteln, ob Prüfart im Vorgang
        PERFORM fremdvergabe
                USING    dm07m-aufpl_ord
                         dm07m-aplzl_ord
                CHANGING l_matnr
                         l_art.
        IF    l_art  IS INITIAL
          OR l_matnr IS INITIAL.
*-- Für Fremdvergabe keine Prüfart im Vorgang hinterlegt
          EXIT.
        ENDIF.
*-- Menge (u.a. wg. Storno) in die ME des Materials umrechnen.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
            input                = l_menge
            kzmeinh              = 'X'
            matnr                = l_matnr
            meinh                = l_meins
          IMPORTING
            meins                = l_meins
            output               = l_menge
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
        IF NOT sy-subrc IS INITIAL.
*-- Umrechnung nicht möglich
          MESSAGE e286(qa) WITH l_meins l_matnr.
        ENDIF.

        IF l_menge IS INITIAL.
*-- Menge in Lagermengeneinheit ist Null
          MESSAGE e106(m7).
        ENDIF.

      ENDIF.
      IF NOT vm07m-qsshk IS INITIAL.
        MOVE-CORRESPONDING: vm07m TO mbqss,
                            dm07m TO mbqss,
                            mseg  TO mbqss.
* Profit center and business area must not be filled, if no account
* available. These fields are not needed in the inspection lot and also
* not during the goods movement in the usage-decision
        MOVE-CORRESPONDING VM07M TO L_COKZ.
        IF L_COKZ IS INITIAL.
          CLEAR : MBQSS-PRCTR,
                  MBQSS-GSBER.
        ENDIF.
        MOVE: MSEG-KDAUF      TO MBQSS-KONT_KDAUF,
              mseg-kdpos      TO mbqss-kont_kdpos,
              mseg-ps_psp_pnr TO mbqss-kont_pspnr.
        MOVE vm07m-licha TO mbqss-lichn.
        IF mbqss-insmk = f.
          CLEAR mbqss-insmk.
        ENDIF.
        MOVE : l_matnr TO mbqss-matnr,
               l_charg TO mbqss-charg,
               l_werks TO mbqss-werks,
               l_lgort TO mbqss-lgort,
               l_kdauf TO mbqss-mat_kdauf,
               l_kdpos TO mbqss-mat_kdpos,
               l_pspnr TO mbqss-mat_pspnr,
               l_sobkz TO mbqss-sobkz,
               l_menge TO mbqss-menge,
               l_meins TO mbqss-meins.
        IF     vm07m-qsshk EQ '02'
           AND dm07m-kzuml NE space.
*/        WA-Los zur abgebenden Zeile: Bei Umlagerung Felder korrigieren
          MOVE : l_matnr_ur TO mbqss-matnr,
                 l_charg_ur TO mbqss-charg,
                 l_werks_ur TO mbqss-werks,
                 l_lgort_ur TO mbqss-lgort.
        ENDIF.
        MOVE mkpf-budat  TO mbqss-budat.
*       Fuellen Referenzbelegnummer fuer Zeugnisabwicklung
        IF NOT vm07m-xblnr_avis IS INITIAL.
*         Bei Anlieferung wird externer Referenzbeleg genommen
          MOVE vm07m-xblnr_avis TO l_xblnr.
        ELSEIF NOT mkpf-xblnr IS INITIAL.
*         Bei normalem WE ohne Anlieferung
          MOVE mkpf-xblnr TO l_xblnr.
        ENDIF.
* determine stock relevance for lot collection
        MOVE mseg-mengu TO l_mengu.
        PERFORM pruefe_mengu_pre  USING    mseg-kzbew
                                           mseg-kzvbr
                                           l_sobkz
                                           vm07m-kzwes
                                           mseg-wertu
                                           vm07m-qsshk
                                  CHANGING l_mengu.

*     Prüfen z.B. Mengenüberschreitung im QINF
*     Aufruf auch bei MSEG-ERFMG = 0, um INSMK zu bestimmen
        IF NOT l_xhupf IS INITIAL.
*         HUM Pflicht für empfangenden Lagerort -> keine Prüflos
          CLEAR vm07m-qsshk.
        ENDIF.
ENHANCEMENT-SECTION     SAPMM07M_10 SPOTS ES_SAPMM07M.
        CALL FUNCTION 'QAAT_CHECK_QM'
          EXPORTING
            i_charg          = mbqss-charg
            i_lichn          = mbqss-lichn
            i_revlv          = dm07m-revlv
            i_aufnr          = mseg-aufnr
            i_ebeln          = mseg-ebeln
            i_ebelp          = mseg-ebelp
            i_erfmg          = l_menge
            i_insmk          = mseg-insmk
            i_kzwes          = l_kzwes_q
            i_kzbew          = rm07m-kzbew
            i_kzzug          = mseg-kzzug
            i_lifnr          = mseg-lifnr
            i_matnr          = mbqss-matnr
            i_qsshk          = vm07m-qsshk
            i_shkzg          = mseg-shkzg
            i_ssqss          = dm07m-ssqss
            i_wemng          = dm07m-wemng
            i_werks          = mbqss-werks
            i_lgort          = mbqss-lgort
            i_xzgvh          = dm07m-xzgvh
            i_zeile          = mseg-zeile
            i_zgtyp          = dm07m-zgtyp
            i_art            = l_art
            i_mprof          = dm07m-mprof
            i_ematn          = mseg-ematn
            i_mfrnr          = dm07m-mfrnr
            i_sobkz          = l_sobkz
            i_kdauf          = l_kdauf
            i_kdpos          = l_kdpos
            i_ps_psp_pnr     = l_pspnr
            i_xblnr          = l_xblnr
            i_xmbwl          = xmbwl
            i_bsart          = l_bsart
            i_global_counter = vm07m-global_counter
            i_budat          = mkpf-budat
            i_mengu          = l_mengu
            i_smbln          = mseg-smbln
            i_xstor          = vm07m-xstor
            i_anzgeb         = vm07m-anzgeb
            i_gebeh          = vm07m-gebeh
          IMPORTING
            e_art            = l_art
            e_cert_req       = l_cert_req
            e_insp_stat      = mseg-qinspst
            e_bestand        = l_insmk
            e_qmat_inakt     = dm07m-qmat_inakt
            e_qinfupd        = l_qinfupd
            e_status         = l_status
            e_prueflos       = l_qplos
            e_xzgvh          = dm07m-xzgvh
            e_two_step       = g_qm_pos-zwei_schritt.
END-ENHANCEMENT-SECTION.
        IF NOT mseg-erfmg IS INITIAL.
*         Prüfen Gebindeeingabe
          PERFORM check_anzgeb USING mseg-qinspst  mseg-werks
                                 vm07m-gebeh vm07m-anzgeb.
        ENDIF.
        IF NOT l_qplos IS INITIAL.
*         Prüflosnummer nur ändern, falls gefüllt zurückgeliefert
          MOVE l_qplos TO vm07m-qplos.
        ENDIF.
*----------------------------------------------------------------------*
        IF    mseg-qinspst     EQ '1'  "Prüflos erzeugen
          AND dm07m-qmat_inakt IS INITIAL.
*-------------
*       prüfen Kennzeichen INSMK und Bestandsrelevant
          PERFORM pruefe_mengu_insmk USING mseg
                                   CHANGING mbqss.

*       altes Prüflos löschen (aus MEMORY)  und neues erzeugen
          CALL FUNCTION 'QPL1_INIT_QSS'
            EXPORTING
              i_art           = l_art
              i_cert_required = l_cert_req
              i_qinfupd       = l_qinfupd
              i_status        = l_status
              i_prueflos      = vm07m-qplos
              mbqss           = mbqss
              i_two_step      = g_qm_pos-zwei_schritt
            IMPORTING
              subrc           = l_subrc
              e_prueflos      = vm07m-qplos.

          CASE l_subrc.
            WHEN 2.
*         Merkmale konnten nicht angelegt werden
              MESSAGE i253(qa).
            WHEN 4.
*       Plan wurde nicht zugeordnet
              MESSAGE i187(qa).
            WHEN 8.
*       Prüflos konnte nicht angelegt werden
              MESSAGE e186(qa) WITH mbqss-zeile.
          ENDCASE.
*
        ELSEIF mseg-qinspst  NE '1'.   "kein Prüflos
*         es soll nicht geprüft werden, INSMK muß passen
          IF     NOT l_insmk IS INITIAL
             AND NOT l_lbbsa IS INITIAL.
*           Bestandsart wurde gesetzt und muß passen
            IF   (     l_insmk         EQ f
                 AND (     l_lbbsa     NE '01'
                       AND l_lbbsa     NE '08' ) )
              OR (     l_insmk         EQ x
                   AND l_lbbsa         NE '02' ).
*             Gesetzte Bestandsart paßt nicht zum Beleg
              MESSAGE e066(qa) WITH l_insmk mseg-insmk.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
   ELSEIF  (       g_qm_pos-chargestern EQ y      "interne Chargennummer
                      OR ( h_charg NE mbqss-charg
                          AND NOT mbqss IS INITIAL ) )    "Los erzeugen
                   AND l_xhupf IS INITIAL"keine HUM Pflicht
                   AND NOT h_charg IS INITIAL  .
      IF mseg-qinspst EQ '6'.
*     update batch in inspection lot
        PERFORM batch_update USING vm07m-qplos
                                   mseg-zeile
                                   mseg-charg
                                   mseg-lgort.
      ELSE.
*   MBQSS ist bereits gefüllt, zusätzlich die Charge füllen
        MOVE h_charg TO mbqss-charg.
        CALL FUNCTION 'QPL1_INIT_QSS'
          EXPORTING
            mbqss      = mbqss
            i_two_step = g_qm_pos-zwei_schritt.
      ENDIF.
    ENDIF.
* INSMK ändern, da hier u.U. erst bekannt, falls Los erzeugt wurde
    IF    mseg-qinspst EQ '1'          "Prüflos erzeugt
      AND dm07m-qmat_inakt IS INITIAL.
      IF  t156m-smard IS INITIAL
      AND t156m-smslb IS INITIAL
      AND t156m-smska IS INITIAL
      AND t156m-smsku IS INITIAL
      AND t156m-smkol IS INITIAL .
        MOVE mseg-insmk TO mbqss-insmk.
*     INSMK im lokalen Gedächtnis der QPL1 korrigieren für spezielle
*     Bewegungen
        CALL FUNCTION 'QPL1_INIT_QSS'
          EXPORTING
            mbqss      = mbqss
            i_two_step = g_qm_pos-zwei_schritt.
      ENDIF.

      IF mseg-insmk IS INITIAL OR mseg-insmk EQ f.
        IF l_lbbsa EQ '02'.            "BWA bucht immer in Q-Bestand
          MOVE x TO mbqss-insmk.
*       INSMK im lokalen Gedächtnis der QPL1 korrigieren für spezielle
*       Bewegungen
          CALL FUNCTION 'QPL1_INIT_QSS'
            EXPORTING
              mbqss      = mbqss
              i_two_step = g_qm_pos-zwei_schritt.
        ENDIF.
      ENDIF.
    ENDIF.
* Beleg-Storno? (Erkannt an der Referenz-Belegnummer!)
    IF     NOT mseg-smbln  IS INITIAL
       AND     vm07m-xstor EQ zwei     "echter Storno             .
       AND     l_xhupf     IS INITIAL. "keine HUM Pflicht         .

      IF vm07m-qploa IS INITIAL.
*       mat.doc. position not yet cancelled in QM
        CALL FUNCTION 'QAAT_MATERIAL_DOCUMENT_CANCEL'
          EXPORTING
            i_mseg         = mseg
            i_dm07m        = dm07m
            i_xmbwl        = xmbwl
          IMPORTING
            e_prueflos     = vm07m-qploa
          EXCEPTIONS
            x_no_lot_found = 01.
        IF sy-subrc IS INITIAL.
          CLEAR l_flag_qstock.
        ENDIF.
      ELSE.
*       mat.doc. position already cancelled in QM
        CLEAR l_flag_qstock.
      ENDIF.
*     Remove GR data from certificate if this is needed
      CALL FUNCTION 'QCPR_CERT_INITIALIZE_GR_DATA'
        EXPORTING
          i_mseg = mseg.
    ENDIF.
* Hinzufügen einer Position
    IF AKTYP EQ H
      OR AKTYP = K.                        "note 1004325
*   Aufruf nicht aus QM heraus ...
      IF  qss_aufruf   IS INITIAL
*     keine HUM Pflicht
      AND l_xhupf IS INITIAL
*     Menge nicht initial
      AND NOT l_menge  IS INITIAL
*   ... und kein Prüflos eröffnet ...
      AND vm07m-qplos  IS INITIAL
      AND mseg-qinspst NA '16'         "Kein Los erzeugt oder zugeordnet
*   ... und QM-relevanter Sonderbestand (normal, Konsi,Projekt,Kd-Einzl)
      AND l_sobkz CA 'EKQ '
*   ... und kein erlaubter Storno ...
      AND NOT l_flag_qstock   IS INITIAL
*   ... und keine negative Inventurdifferenz
      AND NOT ( inventur NE space
                AND mseg-shkzg = h )
*   ... und betrifft Bewegung Q-Bestand? (vgl. T156M!)
      AND  (    l_lbbsa    EQ '02'        "neuer Bestand
             OR l_lbbsa_ur EQ '02' ).     "alter Bestand

*SPM/QM control QI stock change             -->begin change
      CALL METHOD /SPE/QSTOCK_CHANGE_CHECK=>checkposting
        EXPORTING
          ip_plant        = l_werks
          ip_sloc         = l_lgort
          ip_kzzug        = mseg-kzzug
          ip_mkpf         = mkpf
        IMPORTING
          EP_QSTOCKCHANGE =  lv_qstock_change.

      If lv_qstock_change is initial.
        CALL FUNCTION 'QPWE_QSTOCK_CHANGE_ALLOWED'
          EXPORTING
            i_matnr = l_matnr
            i_werks = l_werks
          IMPORTING
            e_insnc = l_insnc
          EXCEPTIONS
            no_tq32 = 0.
      endif.
      clear lv_qstock_change.
*SPM/QM control QI stock change             <--end change

*     Keine Änderung ausserhalb von QM erlaubt
        IF NOT l_insnc IS INITIAL.
          MESSAGE e495(qa) WITH l_matnr.
        ENDIF.
      ENDIF.
    ENDIF.
* Kontierung nachreichen
    PERFORM qm_kontierung.
  ENDIF.
ENDFORM.                    "QSS_PRUEFEN
*eject
*---------------------------------------------------------------------*
*       FORM QSS_SEGMENT_GENERIEREN                                   *
*---------------------------------------------------------------------*
*       Die erforderlichen Daten für die Fortschreibung der           *
*       Qualitätssicherung werden aufgebaut.                          *
*---------------------------------------------------------------------*
FORM qss_segment_generieren.

  DATA l_xzgvh LIKE dm07m-xzgvh.

  MOVE zdm07m-xzgvh TO l_xzgvh.
  IF    NOT sy-binpt IS INITIAL
    AND      l_xzgvh IS INITIAL.
*   check memory
    CALL FUNCTION 'QCPR_CHECK_MEMORY'
      IMPORTING
        e_memory_filled = l_xzgvh.
  ENDIF.
  CHECK NOT xvm07m-qplos IS INITIAL
     OR NOT l_xzgvh      IS INITIAL  "Zeugnisfortschreibung erforderlich
     OR ( NOT xvm07m-qploa IS INITIAL AND xvm07m-xstor EQ zwei )."Storno
  CLEAR xmbqssz.

  IF NOT xvm07m-qplos IS INITIAL.
*   Prüflos zur Position vorhanden
    MOVE x TO xmbqssz-kzplos.
    MOVE xmseg-charg TO xmbqssz-charg.
    MOVE xmseg-lgort TO xmbqssz-lgort.
*   Einkaufsbelegnummer versorgen (wg. automatischer Bestellung)
    MOVE xmseg-ebeln TO xmbqssz-ebeln.
    MOVE xmseg-ebelp TO xmbqssz-ebelp.
*   Lieferantencharge übernehmen
    MOVE xvm07m-licha TO xmbqssz-lichn.

*   WM-Daten aus MSEG übernehmen
    IF     NOT xmseg-xblvs  IS INITIAL
       AND     zdm07m-ubfkz IS INITIAL.
      MOVE: xmseg-lgnum     TO xmbqssz-lgnum,
            xmseg-lgtyp     TO xmbqssz-lgtyp.
      IF NOT xmseg-lgpla IS INITIAL.
*       nicht gesetzt, -> Belegnummer im Buchen füllen (Maskierung)
        MOVE xmseg-lgpla     TO xmbqssz-lgpla.
      ENDIF.
    ENDIF.
  ENDIF.
*
  IF NOT l_xzgvh IS INITIAL.
    MOVE l_xzgvh TO xmbqssz-xzgvh.
    MOVE xmseg-charg  TO xmbqssz-charg.
    MOVE xvm07m-licha TO xmbqssz-lichn.
    if not xvm07m-xblnr_avis is initial.               "note 1538653
      move xvm07m-xblnr_avis to XMBQSSZ-LFSNR.
*     Bei Anlieferung wird externer Referenzbeleg genommen
    ELSEIF NOT xmkpf-xblnr IS INITIAL.
*     Bei normalem WE ohne Anlieferung
      MOVE XMKPF-XBLNR  TO XMBQSSZ-LFSNR.
    endif.
    move xmseg-ebeln  to xmbqssz-ebeln.               "note 1344035
    move xmseg-ebelp  to xmbqssz-ebelp.               "note 1344035
  ENDIF.

* Storno
* create dummy

* Umschlüsselung Zeilennummer in Belegposition
*  xmbqssz-zeilealt = zdm07m-zeild.                         "385355
  xmbqssz-zeilealt = zmbuz-zeily.                           "385355
*  xmbqssz-zeileneu = xvm07m-zeilv.                         "385355
  xmbqssz-zeileneu = xmseg-zeile.                           "385355
*   Aufbau Tabelle für QALS Versorgung
  APPEND xmbqssz.

ENDFORM.                    "QSS_SEGMENT_GENERIEREN
*eject
*---------------------------------------------------------------------*
*       FORM QSS_TESTEN                                               *
*---------------------------------------------------------------------*
*       Es wird folgendes bestimmt                                    *
*       a) in welchen Bestand soll gebucht werden ?                   *
*       b) ist ein Los zu erzeugen ?                                  *
*       Anmerkung : Die Form wird nur beim Hinzufügen einer Position  *
*                   aufgerufen                                        *
*---------------------------------------------------------------------*
FORM qss_testen USING q_insmk LIKE mseg-insmk.

*-- Lokale Variablen zur Steuerung der Check-Funktion
  DATA :  l_qplos         LIKE vm07m-qplos,
          l_cert_req      LIKE rmqed-cert_req,   "Zeugnis fehlt
          l_insmk         LIKE mseg-insmk,
          l_insnc,
          l_bsart         LIKE qals-insmk,        "Bestandsart
          l_cnt02         LIKE t156m-cnt02,
          l_zustd         LIKE t156m-zustd,
          l_kzuml         LIKE dm07m-kzuml,
          l_xchpf         LIKE vm07m-xchpf,
          l_bwtty         LIKE dm07m-bwtty,
          l_mtcom         LIKE mtcom,
          l_mbefu         LIKE mbefu,
          l_t156m         LIKE t156m,
          l_kzwes_q       LIKE qals-stat11,       "WE-Sperrbestand
          l_matnr         LIKE mseg-matnr,
          l_werks         LIKE mseg-werks,
          l_charg         LIKE mseg-charg,
          l_lgort         LIKE mseg-lgort,
          l_menge         LIKE mseg-menge,
          l_meins         LIKE mseg-meins,
          l_kzskiplot     LIKE mseg-insmk,         "Los wird geskippt
          l_skip_to_stock LIKE mseg-insmk,         "Los wird geskippt
          l_sobkz         LIKE mseg-sobkz,
          l_kdauf         LIKE mseg-kdauf,
          l_kdpos         LIKE mseg-kdpos,
          l_pspnr         LIKE mseg-ps_psp_pnr,
          l_mengu         LIKE mseg-mengu,
          l_no_block      LIKE qm00-qkz,    "Sperrbestand nicht möglich
          l_art           LIKE qinfinspt-insptype, "Prüfart aus QINF
          l_qinfupd       LIKE qinfinspt-qinfupd , "QINF zu ändern
          l_status        LIKE qinfinspt-status  , "Status aus QINF
          l_xblnr         LIKE mkpf-xblnr,         "Referenzbeleg
          l_subrc         LIKE sy-subrc,
          l_t340d         LIKE t340d.  "WM Tabelle
  DATA :  L_COKZ          LIKE COBL_COKZ.

* Initialisierung globale Positionsbezogene Steuerungsflags
  CLEAR g_qm_pos.
* initialize MBQSS
  CLEAR mbqss.
* Lesen T156M wegen LBBSA und KZUML
  IF t156-shkzg EQ s.
    l_cnt02 = '01'.
  ELSE.
    l_cnt02 = '02'.
  ENDIF.
  IF mseg-xauto = l.
    l_zustd = l.
  ELSE.
    CLEAR l_zustd.
  ENDIF.
  l_kzuml = x.
  l_t156m = t156m.
  SELECT * FROM t156m WHERE     bustm = s156s-bustm
                            AND zustd = l_zustd.
    IF t156m-cnt02 EQ l_cnt02.
      MOVE t156m TO l_t156m.
    ENDIF.
*   transfer posting if two entries with identical bustm and zustd
    IF l_kzuml EQ x.
      CLEAR l_kzuml.
    ELSE.
      l_kzuml = x.
      EXIT.
    ENDIF.
  ENDSELECT.
  IF l_t156m-lbbsa EQ '02'.
*   Buchen in Q-Bestand muß bei Loszusammenfassung berücksichtigt werden
    MOVE '2' TO l_bsart.
  ENDIF.
* Menge und Mengeneinheit übernehmen.
  MOVE: mseg-menge TO l_menge,
        mseg-meins TO l_meins.
*-- Materialnummer 0 nur bei Fremdbearbeitung
  IF         mseg-matnr IS INITIAL
    AND (    dm07m-aufpl_ord IS INITIAL
         AND dm07m-aplzl_ord IS INITIAL ).
    EXIT.
  ELSEIF           mseg-matnr      IS INITIAL
     AND (     NOT dm07m-aufpl_ord IS INITIAL
           AND NOT dm07m-aplzl_ord IS INITIAL ) .
* Fremdbearbeituung: Menge und ME übernehmen.
    MOVE: mseg-erfmg TO l_menge,
          mseg-erfme TO l_meins.
  ENDIF.
  IF vm07m-kzwes EQ s .
*   Buchung zum WE-Sperrbestand
    IF mseg-shkzg EQ s.                "kein Storno
      MOVE x TO l_kzwes_q.
    ENDIF.
  ENDIF.
* Falls Buchung zu Herkunft 01, darf es keine intern VE-Buchung sein.
* -> da dies Umbuchung aus VE (BWA 103 + 105 wäre)
  IF    vm07m-qsshk EQ '01'
    AND NOT qss_aufruf IS INITIAL.
    EXIT.      "nicht QM-relevant das zweites WE-Los.
  ENDIF.
*----- QM-Abwicklung ------------------
* Felder für Weiterberarbeitung Vorbelegen
  MOVE mseg-matnr     TO l_matnr.
  MOVE mseg-charg     TO l_charg.
  MOVE mseg-werks     TO l_werks.
  MOVE mseg-lgort     TO l_lgort.
  MOVE mseg-sobkz     TO l_sobkz.
  MOVE mseg-mat_kdauf TO l_kdauf.
  MOVE mseg-mat_kdpos TO l_kdpos.
  MOVE mseg-mat_pspnr TO l_pspnr.

*   Mögliche Umlagerung -> mehr als eine Zeile
*   Umbuchung mit QM in zweiter Zeile, falls SHKZG = H
*   dann Umlagerfelder verwenden sonst normale Felder
  IF NOT l_kzuml IS INITIAL.
*   The old fieldselection (T156B) is not valid for a transfer posting
*   from MIGO
    IF NOT fcausw-xneup IS INITIAL AND NOT vm07m-xstor = zwei
       AND xmigo <> x.
      IF dm07m-fausw+55(1) = minus.
        CLEAR mseg-ummat.
      ENDIF.
      IF dm07m-fausw+56(1) = minus.
        CLEAR mseg-umwrk.
      ENDIF.
      IF dm07m-fausw+57(1) = minus.
        CLEAR mseg-umlgo.
      ENDIF.
      IF dm07m-fausw+64(1) = minus.
        CLEAR mseg-umcha.
      ENDIF.
    ENDIF.
    IF NOT mseg-ummat IS INITIAL.      "Umlagerungsfeld gefüllt
      IF     mseg-shkzg  = h           "keine Storno-BWA
         AND vm07m-qsshk <> '02'.      "und keine Prüfung zum WA
        MOVE mseg-ummat TO l_matnr.
      ENDIF.
    ENDIF.
*   Chargennummer
    IF NOT mseg-umcha IS INITIAL.      "Umlagerungsfeld gefüllt
      IF     mseg-shkzg  = h           "keine Storno-BWA
         AND vm07m-qsshk <> '02'.      "und keine Prüfung zum WA
        MOVE mseg-umcha TO l_charg.
      ENDIF.
    ELSE.
*     receiving batch not set, should receiving batch be identical?
      IF    mseg-shkzg  = h            "keine Storno-BWA
        AND vm07m-qsshk <> '02'.       "und keine Prüfung zum WA
*     stock transfer
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb  = 'M7'
            i_msgnr  = '199'
            i_nolog  = x
            i_output = space
          IMPORTING
            rc       = rc.
        IF rc EQ 2 AND t156-chneu CA ' ABC'.
*       internal batch number assignment
          IF l_charg CA stern.
          ELSE.
            CLEAR l_charg.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*   Sonderbestandskennzeichen
*   is set in MM, use initial value also
    IF mseg-shkzg = h.                 "keine Storno-BWA
      MOVE mseg-umsok TO l_sobkz.
    ENDIF.

*   Werk
    IF NOT mseg-umwrk IS INITIAL.      "Umlagerungsfeld gefüllt
      IF     mseg-shkzg  = h           "keine Storno-BWA
         AND vm07m-qsshk <> '02'.      "und keine Prüfung zum WA
        MOVE mseg-umwrk TO l_werks.
      ENDIF.
    ENDIF.

*   Lagerort
    IF NOT mseg-umlgo IS INITIAL.    "Umlagerungsfeld gefüllt
      IF     mseg-shkzg  = h         "keine Storno-BWA
         AND vm07m-qsshk <> '02'.    "und keine Prüfung zum WA
        MOVE mseg-umlgo TO l_lgort.
      ENDIF.
    ELSE.                                "Umlagerungsfeld nicht gefüllt
      IF     mseg-shkzg  = h             "keine Storno-BWA
         AND vm07m-qsshk <> '02'         "und keine Prüfung zum WA
         AND (   l_sobkz = v             "Kundenleihgut
              OR l_sobkz = w             "Kundenkonsi
              OR l_sobkz = o ).          "Lohnbearbeitung
        CLEAR l_lgort.                   "Sonderbestand auf Werksebene
      ENDIF.
    ENDIF.

*   Kundenauftragsnummer
    IF NOT mseg-kdauf IS INITIAL.      "Umlagerungsfeld gefüllt
      IF mseg-shkzg = h.               "keine Storno-BWA
        MOVE mseg-kdauf TO l_kdauf.
      ENDIF.
    ENDIF.
*   Kundenauftragsposition
    IF NOT mseg-kdpos IS INITIAL.      "Umlagerungsfeld gefüllt
      IF mseg-shkzg = h.               "keine Storno-BWA
        MOVE mseg-kdpos TO l_kdpos.
      ENDIF.
    ENDIF.
*   PSP-Element
    IF NOT mseg-ps_psp_pnr IS INITIAL. "Umlagerungsfeld gefüllt
      IF mseg-shkzg = h.               "keine Storno-BWA
        MOVE mseg-ps_psp_pnr TO l_pspnr.
      ENDIF.
    ENDIF.
  ENDIF.
* set local batch management requirement and split valuation
  IF     NOT l_kzuml     IS INITIAL    "stock transfer
     AND     mseg-shkzg  = h           "keine Storno-BWA
     AND     vm07m-qsshk <> '02'       "und keine Prüfung zum WA
     AND (   l_matnr     <> mseg-matnr
          OR l_werks     <> mseg-werks ).
*   batch management requirement might be different from mseg
*   check l_matnr (receiving material number) in l_werks
    MOVE 'MBEFU' TO l_mtcom-kenng.
    MOVE l_matnr TO l_mtcom-matnr.
    MOVE l_werks TO l_mtcom-werks.
    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel         = l_mtcom
      IMPORTING
        matdaten           = l_mbefu
      EXCEPTIONS
        material_not_found = 1
        plant_not_found    = 1.
    IF sy-subrc <> 0.
* IS2ERP: check option of subsequent listing as part of IS-Retail
        DATA: ls_t001w TYPE t001w,
              ls_wrf1  TYPE wrf1.

        DATA: no_subsequent_listing TYPE flag VALUE ''.

        CALL FUNCTION 'LOCATION_SELECT_PLANT'
          EXPORTING
            i_werks                   = l_werks
          IMPORTING
            o_t001w                   = ls_t001w
          EXCEPTIONS
            no_valid_plant            = 1
            plant_not_found           = 2
            more_than_one_entry_found = 3
            OTHERS                    = 4.
        IF sy-subrc <> 0.
          no_subsequent_listing = 'X'.
        ELSE.
          CALL FUNCTION 'LOCATION_WRF1_SELECT'
            EXPORTING
              i_locnr        = ls_t001w-kunnr
            IMPORTING
              a_wrf1         = ls_wrf1
            EXCEPTIONS
              no_entry_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            no_subsequent_listing = 'X'.
          ELSE.
            IF ls_wrf1-nlmatfb = '1'.
              no_subsequent_listing = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.

        IF no_subsequent_listing IS INITIAL.
          IF tcurm-mbequ IS INITIAL.
*         exklusive Sperre
            l_mtcom-kzspr = x.
          ELSE.
*         shared Sperre
            l_mtcom-kzspr = s.
          ENDIF.
          CALL FUNCTION 'MATERIAL_READ'
            EXPORTING
              schluessel         = l_mtcom
            IMPORTING
              matdaten           = l_mbefu
            EXCEPTIONS
              material_not_found = 1
              plant_not_found    = 1.
        ELSE.
*       Error bringen : Material nicht vorhanden
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF. " first call of Material_read erroneous
      MOVE l_mbefu-xchpf TO l_xchpf.
      MOVE l_mbefu-bwtty TO l_bwtty.
    ELSE.
*   batch management requirement identical to mseg
      MOVE vm07m-xchpf TO l_xchpf.
      MOVE dm07m-bwtty TO l_bwtty.
    ENDIF.
* clear batch if no batch required and no split valuation
    IF     l_xchpf IS INITIAL
       AND l_bwtty IS INITIAL.
      CLEAR l_charg.
    ENDIF.

* Auswerten Tabelle T156Q   -> Deaktivieren QM
    PERFORM qss_aktiv_t156q USING mseg-bwart      l_sobkz
                                  mseg-kzbew      mseg-kzzug
                                  mseg-kzvbr      mseg-smbln
                                  vm07m-xstor
                         CHANGING vm07m-qsshk.
    IF NOT ( vm07m-qsshk IS INITIAL AND vm07m-kzwes EQ s ).
* nicht falls Sperrbestand und keine Herkunft
      IF               l_matnr         IS INITIAL
         AND (     NOT dm07m-aufpl_ord IS INITIAL
               AND NOT dm07m-aplzl_ord IS INITIAL ).
* Bei Fremdvergabe ermitteln, ob Prüfart im Vorgang
        PERFORM fremdvergabe
                USING    dm07m-aufpl_ord
                         dm07m-aplzl_ord
                CHANGING l_matnr
                         l_art.
        IF    l_art   IS INITIAL
           OR l_matnr IS INITIAL.
*-- Für Fremdvergabe keine Prüfart im Vorgang hinterlegt
          EXIT.
        ENDIF.
*-- Menge (u.a. wg. Storno) in die ME des Materials umrechnen.
        CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
          EXPORTING
            input                = l_menge
            kzmeinh              = 'X'
            matnr                = l_matnr
            meinh                = l_meins
          IMPORTING
            meins                = l_meins
            output               = l_menge
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
        IF NOT sy-subrc IS INITIAL.
*-- Umrechnung nicht möglich
          MESSAGE e286(qa) WITH l_meins l_matnr.
        ENDIF.

        IF l_menge IS INITIAL.
*-- Menge in Lagermengeneinheit ist Null
          MESSAGE e106(m7).
        ENDIF.

      ENDIF.
*
*   Wirkstoffabwicklung aktiv -> Menge wg. Änderung sichern
      IF    kzdws EQ 1                   "Wirkstoffabwicklung
        AND NOT dm07m-kzwso IS INITIAL.
        MOVE l_menge TO g_qm_pos-menge_wkst.
      ENDIF.
*
      IF l_sobkz CN 'EKQ '.
        MOVE x TO l_no_block.
      ENDIF.
*   Fuellen Referenzbelegnummer fuer Zeugnisabwicklung
      IF NOT vm07m-xblnr_avis IS INITIAL.
*     Bei Anlieferung wird externer Referenzbeleg genommen
        MOVE vm07m-xblnr_avis TO l_xblnr.
      ELSEIF NOT mkpf-xblnr IS INITIAL.
*     Bei normalem WE ohne Anlieferung
        MOVE mkpf-xblnr TO l_xblnr.
      ENDIF.

*   determine stock relevance for lot collection
      MOVE mseg-mengu TO l_mengu.
      PERFORM pruefe_mengu_pre  USING    mseg-kzbew
                                         mseg-kzvbr
                                         l_sobkz
                                         vm07m-kzwes
                                         mseg-wertu
                                         vm07m-qsshk
                                CHANGING l_mengu.

ENHANCEMENT-SECTION     SAPMM07M_12 SPOTS ES_SAPMM07M.
      CALL FUNCTION 'QAAT_CHECK_QM'
        EXPORTING
          i_charg          = l_charg
          i_lichn          = vm07m-licha
          i_revlv          = dm07m-revlv
          i_aufnr          = mseg-aufnr
          i_ebeln          = mseg-ebeln
          i_ebelp          = mseg-ebelp
          i_erfmg          = l_menge
          i_insmk          = mseg-insmk
          i_kzwes          = l_kzwes_q
          i_kzbew          = rm07m-kzbew
          i_kzzug          = mseg-kzzug
          i_lifnr          = mseg-lifnr
          i_matnr          = l_matnr
          i_qsshk          = vm07m-qsshk
          i_shkzg          = mseg-shkzg
          i_ssqss          = dm07m-ssqss
          i_wemng          = dm07m-wemng
          i_werks          = l_werks
          i_lgort          = l_lgort
          i_no_block       = l_no_block
          i_xzgvh          = dm07m-xzgvh
          i_zeile          = mseg-zeile
          i_zgtyp          = dm07m-zgtyp
          i_art            = l_art
          i_mprof          = dm07m-mprof
          i_ematn          = mseg-ematn
          i_mfrnr          = dm07m-mfrnr
          i_sobkz          = l_sobkz
          i_kdauf          = l_kdauf
          i_kdpos          = l_kdpos
          i_ps_psp_pnr     = l_pspnr
          i_xblnr          = l_xblnr
          i_xmbwl          = xmbwl
          i_bsart          = l_bsart
          i_mengu          = l_mengu
          i_global_counter = vm07m-global_counter
          i_budat          = mkpf-budat
          i_smbln          = mseg-smbln
          i_xstor          = vm07m-xstor
          i_anzgeb         = vm07m-anzgeb
          i_gebeh          = vm07m-gebeh
        IMPORTING
          e_art            = l_art
          e_bestand        = l_insmk
          e_cert_req       = l_cert_req
          e_prueflos       = l_qplos
          e_insp_stat      = mseg-qinspst
          e_qmat_inakt     = dm07m-qmat_inakt
          e_qinfupd        = l_qinfupd
          e_status         = l_status
          e_two_step       = g_qm_pos-zwei_schritt
          e_xzgvh          = dm07m-xzgvh.
END-ENHANCEMENT-SECTION.
      IF NOT mseg-erfmg IS INITIAL.
*     Prüfen Gebindeeingabe
        PERFORM check_anzgeb USING mseg-qinspst  mseg-werks
                                   vm07m-gebeh vm07m-anzgeb.
      ENDIF.
      IF NOT l_qplos IS INITIAL.
*     Prüflosnummer nur ändern, falls gefüllt zurückgeliefert
        MOVE l_qplos TO vm07m-qplos.
      ENDIF.
*
      q_insmk = l_insmk.
*-- Falls in Sperrbestand: Nichts mehr mit QM
      IF NOT l_insmk = s .
*   es wird nicht an gesperrt gebucht

ENHANCEMENT-POINT QSS_TESTEN_01 SPOTS ES_SAPMM07M .

        IF NOT vm07m-qsshk     IS INITIAL
          AND mseg-qinspst     EQ '1'    "Prüfung aktiv
          AND dm07m-qmat_inakt IS INITIAL.
          MOVE-CORRESPONDING: vm07m TO mbqss,
                              dm07m TO mbqss,
                              mseg  TO mbqss.
* Profit center and business area must not be filled, if no account
* available. These fields are not needed in the inspection lot and also
* not during the goods movement in the usage-decision
        MOVE-CORRESPONDING VM07M TO L_COKZ.
        IF L_COKZ IS INITIAL.
          CLEAR : MBQSS-PRCTR,
                  MBQSS-GSBER.
        ENDIF.
        MOVE:  MSEG-KDAUF      TO MBQSS-KONT_KDAUF,
                 mseg-kdpos      TO mbqss-kont_kdpos,
                 mseg-ps_psp_pnr TO mbqss-kont_pspnr.
          MOVE vm07m-licha TO mbqss-lichn.
          MOVE : l_charg TO mbqss-charg,
                 l_matnr TO mbqss-matnr,
                 l_werks TO mbqss-werks,
                 l_lgort TO mbqss-lgort,
                 l_menge TO mbqss-menge,
                 l_meins TO mbqss-meins,
                 l_sobkz TO mbqss-sobkz,
                 l_kdauf TO mbqss-mat_kdauf,
                 l_kdpos TO mbqss-mat_kdpos,
                 l_pspnr TO mbqss-mat_pspnr.
          MOVE q_insmk TO mbqss-insmk.
          IF mbqss-insmk EQ f.
            CLEAR mbqss-insmk.
          ENDIF.
          MOVE mkpf-budat TO mbqss-budat.
*-------------
ENHANCEMENT-POINT EHP605_QSS_TESTEN_01 SPOTS ES_SAPMM07M .
          PERFORM pruefe_mengu_insmk USING mseg
                                  CHANGING mbqss.
*----------------------------------------------------------------------*
* Prüflos erzeugen
          CALL FUNCTION 'QPL1_INIT_QSS'
            EXPORTING
              i_art           = l_art
              i_cert_required = l_cert_req
              i_qinfupd       = l_qinfupd
              i_status        = l_status
              i_prueflos      = vm07m-qplos
              mbqss           = mbqss
              i_two_step      = g_qm_pos-zwei_schritt
            IMPORTING
              subrc           = l_subrc
              e_kzskiplot     = l_kzskiplot
              e_skip_to_stock = l_skip_to_stock
              e_prueflos      = vm07m-qplos.

          CASE l_subrc.
            WHEN 2.
*       Merkmale konnten nicht angelegt werden
              MESSAGE i253(qa).
            WHEN 4.
*     Plan wurde nicht zugeordnet
              MESSAGE i187(qa).
            WHEN 8.
*     Prüflos konnte nicht angelegt werden
              MESSAGE e186(qa) WITH mbqss-zeile.
          ENDCASE.
* Kennz., daß Sternfunktion bei Charge angegeben wurde.
* Operator CA, da auch '**' möglich (Chargensplitt beim WE)
          IF mbqss-charg CA stern.
            MOVE x TO g_qm_pos-chargestern.
*-- Falls Chargenpflicht, aber interne Nummernvergabe: QSS_PRUEFEN akt.
          ELSEIF ( NOT l_xchpf IS INITIAL
                   OR NOT l_bwtty IS INITIAL )
                   AND mbqss-charg IS INITIAL .
            MOVE y TO g_qm_pos-chargestern.
          ENDIF.
*     Kennzeichen setzen falls Lagerort maskiert ist
          IF mbqss-lgort CA stern.
            MOVE x TO g_qm_pos-lgortstern.
          ENDIF.
*
          IF    NOT l_kzskiplot     IS INITIAL
            AND l_cert_req          NE y
            AND NOT l_skip_to_stock IS INITIAL.
*     Skip-Lot --> Buchen in frei
            MOVE f TO q_insmk.
            CLEAR mbqss-insmk.
*     INSMK setzen/löschen im lokalen Gedächtnis der Gruppe QPL1
            CALL FUNCTION 'QPL1_INIT_QSS'
              EXPORTING
                mbqss      = mbqss
                i_two_step = g_qm_pos-zwei_schritt.
          ENDIF.
*   Falls Chargenpflicht, aber interne Nummernvergabe: QSS_PRUEFEN akt.
        ELSEIF     NOT vm07m-qsshk IS INITIAL
               AND mseg-qinspst     EQ '6' "Loszusammenfassung
               AND dm07m-qmat_inakt IS INITIAL
               AND (   (   NOT l_xchpf IS INITIAL
                        OR NOT l_bwtty IS INITIAL )
                    AND mbqss-charg IS INITIAL ).
          MOVE y TO g_qm_pos-chargestern.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.                    "QSS_TESTEN
*eject
*----------------------------------------------------------------------*
*       FORM qm_kontierung                                             *
*----------------------------------------------------------------------*
*  Übergabe der Kontierungsdaten an das QM-Programm                    *
*----------------------------------------------------------------------*
FORM qm_kontierung.
*
  DATA: l_cokz LIKE cobl_cokz.
* QM im Spiel
  CHECK dm07m-qmat_inakt IS INITIAL
    AND mseg-qinspst     EQ '1'        "Prüflos erzeugt
    AND mbqss-zeile      EQ mseg-zeile.
*
  MOVE-CORRESPONDING vm07m TO l_cokz.
*
  IF NOT l_cokz IS INITIAL.
*   es liegt eine Kontierung vor
*   note 922070
*   in some cases the accounting information is available here first
*   (e.g. for transfer posting). Therefore : The internal QALS-memory
*   has to be corrected here (MSEG-KDAUF, MSEG-KDPOS, MSEG-PS_PSP_PNR)
    MOVE : MSEG-KDAUF      TO MBQSS-KONT_KDAUF,
           MSEG-KDPOS      TO MBQSS-KONT_KDPOS,
           MSEG-PS_PSP_PNR TO MBQSS-KONT_PSPNR.
    CALL FUNCTION 'QPL1_INIT_QSS'
      EXPORTING
        MBQSS                 = MBQSS
        I_TWO_STEP            = G_QM_POS-ZWEI_SCHRITT
        I_KONT_CHANGE         = 'X'.                    "note 999486
*   add the costing information
    CALL FUNCTION 'QPL1_ADD_COSTING'
      EXPORTING
        i_kz_costing = l_cokz
        i_bukrs      = mseg-bukrs
        i_kokrs      = mseg-kokrs.
  ENDIF.
ENDFORM.                    "QM_KONTIERUNG
*----------------------------------------------------------------------*
*       FORM QPL1_UPDATE_MEMORY                                        *
*----------------------------------------------------------------------*
*  Sichern QM Daten im Memory                                          *
*----------------------------------------------------------------------*
FORM qpl1_update_memory.

  DATA l_upsl LIKE qalsvb-upsl.
* Beleg hinzugefügt (Modus Hinzufuegen beendet)
*
  IF NOT mseg-matnr IS INITIAL.
    CHECK NOT mseg-menge IS INITIAL.
  ELSE.
    IF     NOT dm07m-aufpl_ord IS INITIAL
       AND NOT dm07m-aplzl_ord IS INITIAL.
*-- Fremdbearbeitung.
      CHECK NOT mseg-erfmg IS INITIAL.
    ENDIF.
  ENDIF.
  CHECK mseg-qinspst     EQ '1'        "Prüflos erzeugt
    AND dm07m-qmat_inakt IS INITIAL.
*
  IF g_qm_pos-zwei_schritt IS INITIAL. "Ein-Schritt verfahren Los kompl
    MOVE i TO l_upsl.
  ELSE.
    MOVE o TO l_upsl.
  ENDIF.
  CALL FUNCTION 'QPL1_UPDATE_MEMORY'
    EXPORTING
      i_updkz = l_upsl.
*
ENDFORM.                    "QPL1_UPDATE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  PRUEFE_MENGU_INSMK
*&---------------------------------------------------------------------*
*       Überprüfung von Bestandskennzeichen und Q-Bestand
*----------------------------------------------------------------------*
*      -->P_MSEG   Belegposition                                       *
*      <--P_MBQSS  QM Daten für Loserzeugung                           *
*----------------------------------------------------------------------*
FORM pruefe_mengu_insmk USING    p_mseg   LIKE mseg
                        CHANGING p_mbqss  LIKE mbqss.
* Kennzeichen mbqss-mengu wird zurückgenommen bei Verbrauchsbuchung
* ohne Sonderbestand und Wertführung
  IF   ( ( p_mseg-kzbew EQ b OR p_mseg-kzbew EQ f )
       AND NOT p_mseg-kzvbr  IS INITIAL
       AND     p_mbqss-sobkz IS INITIAL
       AND     p_mbqss-kzwes NE s
       AND NOT p_mseg-wertu IS INITIAL )
*  + Retoure von Kunden wird nicht bestandsmäßig verwaltet
    OR  p_mbqss-qsshk  EQ '06'
*  + Warenausgangsbuchung wird nicht bestandsmäßig verwaltet
    OR  p_mbqss-qsshk  EQ '02'
*  + Sonderbestand ungleich E, K, Q und space
    OR p_mbqss-sobkz CN 'EKQ '.
    CLEAR p_mbqss-mengu.
    CLEAR p_mbqss-insmk.
* Wenn Sonderbestandskennzeichen Q oder E -> Los immer bestandsrelevant
  ELSEIF p_mbqss-sobkz CO 'QE'.
    MOVE x TO p_mbqss-mengu.
* WE in den WE-Sperrbestand -> Los immer bestandsrelevant
  ELSEIF p_mbqss-kzwes EQ s.
    MOVE x TO p_mbqss-mengu.
  ENDIF.


ENDFORM.                               " PRUEFE_MENGU_INSMK
*&---------------------------------------------------------------------*
*&      Form  QSS_AKTIV_T156Q
*&---------------------------------------------------------------------*
*       Einstellung in T156Q prüfen -> QM deaktiviert ???
*----------------------------------------------------------------------*
*      -->P_BWART  Bewegungsart                                        *
*      -->P_SOBKZ  Sonderbestandskennzeichen                           *
*      -->P_KZBEW  Bewertungsart                                       *
*      -->P_KZZUG  Zugangskenzeichen                                   *
*      -->P_KZVBR  Verbrauchskennzeichen                               *
*      <--P_QM_INAKTIV  Deaktives QM                                   *
*----------------------------------------------------------------------*
FORM qss_aktiv_t156q USING    p_bwart  LIKE   mseg-bwart
                              p_sobkz  LIKE   mseg-sobkz
                              p_kzbew  LIKE   mseg-kzbew
                              p_kzzug  LIKE   mseg-kzzug
                              p_kzvbr  LIKE   mseg-kzvbr
                              p_smbln  LIKE   mseg-smbln
                              p_xstor  LIKE   vm07m-xstor
                     CHANGING p_qsshk  LIKE   vm07m-qsshk.
  STATICS:  s_t156q  LIKE t156q.
*
  IF NOT (    s_t156q-bwart   EQ p_bwart
          AND s_t156q-sobkz   EQ p_sobkz
          AND s_t156q-kzbew   EQ p_kzbew
          AND s_t156q-kzzug   EQ p_kzzug
          AND s_t156q-kzvbr   EQ p_kzvbr ).
*   Daten im Puffer passen nicht   -> Puffer vorbelegen
    SELECT SINGLE * FROM t156q INTO s_t156q
                  WHERE  bwart   EQ p_bwart
                    AND  sobkz   EQ p_sobkz
                    AND  kzbew   EQ p_kzbew
                    AND  kzzug   EQ p_kzzug
                    AND  kzvbr   EQ p_kzvbr.
    IF NOT sy-subrc IS INITIAL.
*     Dummy Eintrag in Puffer stellen
      MOVE: p_bwart  TO   s_t156q-bwart,
            p_sobkz  TO   s_t156q-sobkz,
            p_kzbew  TO   s_t156q-kzbew,
            p_kzzug  TO   s_t156q-kzzug,
            p_kzvbr  TO   s_t156q-kzvbr.
      CLEAR s_t156q-inakt.             "Default BWA für QM aktiv
    ENDIF.
  ENDIF.
* Puffer ist IMMER gesetzt
  IF NOT s_t156q-inakt IS INITIAL
     OR (     NOT p_smbln IS INITIAL
          AND     p_xstor EQ zwei ).   "echter Storno
    CLEAR p_qsshk.
  ENDIF.

ENDFORM.                               " QSS_AKTIV_T156Q
*----------------------------------------------------------------------*
*             QSS-Prueflos anzeigen                                    *
*----------------------------------------------------------------------*
FORM qss_los_show.

  CALL FUNCTION 'QPL2_LOT_LIST_SHOW'
       EXPORTING
*           LS_POSNR    = ' '
*           LS_VBELN    = ' '
*           AUFNR       = ' '
*           ERSTELDAT   = 000000
            vorgang     = mseg-mblnr
            vorgpos     = mseg-zeile
            vorgjahr    = mseg-mjahr
*           SA_AUFNR    =
*           EBELN       =
*           EBELP       =
       EXCEPTIONS
            bad_options = 1
            no_entry    = 2
            OTHERS      = 3.

  CASE sy-subrc.
    WHEN 1.
    WHEN 2.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    WHEN 3.
  ENDCASE.
ENDFORM.                    "QSS_LOS_SHOW
*&---------------------------------------------------------------------*
*&      Form  FREMDVERGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUFPL_ORD  AUFPL (Fremdvergabe)                            *
*      -->P_APLZL_ORD  APLZL (Fremdvergabe)                            *
*      <--P_MATNR          Materialnummer der Auftragsposition         *
*      <--P_ART            Prüfart (Fremdvergabe) aus Auftragsvorgang  *
*----------------------------------------------------------------------*
FORM fremdvergabe USING    value(p_aufpl_ord)  LIKE dm07m-aufpl_ord
                           value(p_aplzl_ord)  LIKE dm07m-aplzl_ord
                  CHANGING p_matnr             LIKE qals-matnr
                           p_art               LIKE qals-art.
*-------------------------
* Lokale Datenvereinbarung
  DATA: l_pruefart LIKE qals-art,
        l_aufnr    LIKE afko-aufnr,
        l_matnr    LIKE qals-matnr,
        posnr      LIKE afpo-posnr VALUE '0001'.
*-------------------------
*-- Prüfart auf Auftragsvorgang ermitteln.
  SELECT SINGLE qpart FROM afvc
                      INTO l_pruefart
                      WHERE aufpl EQ p_aufpl_ord
                        AND aplzl EQ p_aplzl_ord.
  IF NOT sy-subrc   IS INITIAL
     OR  l_pruefart IS INITIAL.
    EXIT.
  ENDIF.
*-- Aus Auftragskopf die Auftragsnummer ermitteln.
  SELECT SINGLE aufnr FROM afko
                      INTO l_aufnr
                      WHERE aufpl EQ p_aufpl_ord.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ENDIF.
*-- Aus der Auftragsposition das Material ermitteln.
  SELECT SINGLE matnr FROM afpo
                      INTO l_matnr
                      WHERE aufnr EQ l_aufnr
                        AND posnr EQ posnr.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ENDIF.
  MOVE: l_matnr    TO p_matnr,
        l_pruefart TO p_art.
ENDFORM.                               " FREMDVERGABE

*&---------------------------------------------------------------------*
*&      Form  SICHERN_QM_DATEN
*&---------------------------------------------------------------------*
*       Sichern der Los und Zeugnisdaten
*----------------------------------------------------------------------*
*      -->  P_XMBQSSZ Materialbelgepositionsverweise
*      -->  P_MBLNR   Materialbelegnummer
*      -->  P_MJAHR   Materialbelegjahr
*----------------------------------------------------------------------*
FORM sichern_qm_daten TABLES   p_xmbqssz STRUCTURE xmbqssz
                      USING    p_mblnr   LIKE mseg-mblnr
                               p_mjahr   LIKE mseg-mjahr.
  READ TABLE p_xmbqssz INDEX 1.
  IF sy-subrc IS INITIAL.
ENHANCEMENT-POINT MM07MQSS_01 SPOTS ES_SAPMM07M.
*   Prüflose
    READ TABLE p_xmbqssz WITH KEY kzplos = x TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.

    DATA: l_memory_id_sn(50) TYPE c.                       "961864
*   Get memory id:                                         "961864
    IF NOT xbapi IS INITIAL AND xcanc IS INITIAL.          "961864
      l_memory_id_sn = 'BAPI_GOODSMVT_CREATE'.             "961864
    ELSEIF NOT xbapi IS INITIAL AND NOT xcanc IS INITIAL.  "961864
      l_memory_id_sn = 'BAPI_GOODSMVT_CANCEL'.             "961864
    ELSE.                                                  "961864
      CLEAR l_memory_id_sn.                                "961864
    ENDIF.                                                 "961864

      CALL FUNCTION 'QPBU_GOODSRECEIPT_LOT_POSTING'
       EXPORTING
         mblnr          = p_mblnr
         mjahr          = p_mjahr
         i_memory_id_sn = l_memory_id_sn                   "961864
       TABLES
         msegtab       = p_xmbqssz
       EXCEPTIONS
         error_message = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
*
    READ TABLE p_xmbqssz WITH KEY xzgvh = x TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'QCPR_CERTIFICATE_POSTING'
        EXPORTING
          mblnr         = p_mblnr
          mjahr         = p_mjahr
        TABLES
          msegtab       = p_xmbqssz
        EXCEPTIONS
          error_message = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
*   cancellation
    READ TABLE p_xmbqssz WITH KEY kzplos = ' ' xzgvh = ' '
                         TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'QPL1_MATERIAL_DOCUMENT_CANCEL'
        EXPORTING
          i_xmbwl = xmbwl.
    ENDIF.
  ENDIF.

* Post certificate table g_qcprp_tab
* E.g.: Removed GR data when material document has been cancelled
  CALL FUNCTION 'QCPR_CERT_POST_QCPRPTAB'.

ENDFORM.                               " SICHERN_QM_DATEN
*&---------------------------------------------------------------------*
*&      Form  CHECK_ANZGEB
*&---------------------------------------------------------------------*
*       Prüfen ob Eingabe der Gebindezahl erforderlich
*----------------------------------------------------------------------*
*      -->P_QINSPST  Falls '1' Prüflos wird angelegt
*      -->P_WERKS    Werk
*      -->P_GEBEH    Einheit des Gebindes
*      -->P_ANZGEB   Anzahl der Gebinde
*----------------------------------------------------------------------*
FORM check_anzgeb USING    p_qinspst   LIKE mseg-qinspst
                           p_werks     LIKE mseg-werks
                           p_gebeh    LIKE vm07m-gebeh
                           p_anzgeb   LIKE vm07m-anzgeb.

  STATICS s_tqss1 LIKE tqss1.
*
  CHECK xmbwl = ' ' OR xmigo = x.
* Warenbewegung erfolgt nicht im Hintergrund
  CHECK p_qinspst = '1'.
* Prüflos wird eröffnet
  CHECK p_gebeh IS INITIAL
     OR p_anzgeb IS INITIAL.
* Gebindefelder sind nicht gefüllt

* Nachlesen Werkseinstellung
  IF   s_tqss1-werks IS INITIAL
    OR s_tqss1-werks NE p_werks.
    CALL FUNCTION 'TQSS1_READ'
      EXPORTING
        i_werks  = p_werks
      IMPORTING
        e_tqss1  = s_tqss1
      EXCEPTIONS
        no_entry = 1.
    IF NOT sy-subrc IS INITIAL.
*     Eintrag nicht gefunden
      CLEAR s_tqss1.
    ENDIF.
  ENDIF.
  IF s_tqss1-kzgeb EQ '+'.             "Gebindepflicht
    MESSAGE e312(qy).
  ENDIF.


ENDFORM.                               " CHECK_ANZGEB
*&---------------------------------------------------------------------*
*&      Form  BATCH_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VM07M_QPLOS  text
*      -->P_MSEG_ZEILE  text
*      -->P_MSEG_CHARG  text
*----------------------------------------------------------------------*
FORM batch_update USING    p_los   LIKE vm07m-qplos
                           p_zeile LIKE mseg-zeile
                           p_charg LIKE mseg-charg
                           p_lgort LIKE mseg-lgort.
  DATA: l_qals  LIKE qals,
        l_updkz LIKE  qalsvb-upsl,
        l_rmqed LIKE rmqed,
        l_dummy LIKE rqmem-dummy.

  MOVE p_zeile TO l_dummy.

  CALL FUNCTION 'QPL1_LOT_GET'
    EXPORTING
      i_prueflos = p_los
      i_dummy    = l_dummy
    IMPORTING
      e_qals     = l_qals
      e_updkz    = l_updkz
      e_rmqed    = l_rmqed
    EXCEPTIONS
      no_lot     = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE e232(qa).
  ELSE.
    CHECK l_qals-stat18 EQ 'Y'.
    MOVE: p_charg TO l_qals-charg,
          p_lgort TO l_qals-lagortchrg,
          p_lgort TO l_qals-lagortvorg.
    CALL FUNCTION 'QPL1_UPDATE_MEMORY'
      EXPORTING
        i_qals  = l_qals
        i_updkz = l_updkz
        i_rmqed = l_rmqed.
  ENDIF.

ENDFORM.                               " BATCH_UPDATE
*&---------------------------------------------------------------------*
*&      Form  PRUEFE_MENGU_PRE
*&---------------------------------------------------------------------*
*       Überprüfung von Bestandskennzeichen vor Aufruf QAAT_CHECK_QM
*----------------------------------------------------------------------*
* if p_qsshk is initial, p_mengu is not relevant for lot collection    *
*                                                                      *
*----------------------------------------------------------------------*
FORM pruefe_mengu_pre   USING    p_kzbew   LIKE mseg-kzbew
                                 p_kzvbr   LIKE mseg-kzvbr
                                 p_sobkz   LIKE mbqss-sobkz
                                 p_kzwes   LIKE mbqss-kzwes
                                 p_wertu   LIKE mseg-wertu
                                 p_qsshk   LIKE mbqss-qsshk
                        CHANGING p_mengu   LIKE mbqss-mengu.
* Kennzeichen mengu wird zurückgenommen bei Verbrauchsbuchung
* ohne Sonderbestand und Wertführung
  IF   ( ( p_kzbew EQ b OR p_kzbew EQ f )
       AND NOT p_kzvbr  IS INITIAL
       AND     p_sobkz IS INITIAL
       AND     p_kzwes NE s
       AND NOT p_wertu IS INITIAL )
*  + Retoure von Kunden wird nicht bestandsmäßig verwaltet
    OR  p_qsshk  EQ '06'
*  + Warenausgangsbuchung wird nicht bestandsmäßig verwaltet
    OR  p_qsshk  EQ '02'
*  + Sonderbestand ungleich E, K, Q und space
    OR p_sobkz CN 'EKQ '.
    CLEAR p_mengu.
* Wenn Sonderbestandskennzeichen Q oder E -> Los immer bestandsrelevant
  ELSEIF p_sobkz CO 'QE'.
    MOVE x TO p_mengu.
* WE in den WE-Sperrbestand -> Los immer bestandsrelevant
  ELSEIF p_kzwes EQ s.
    MOVE x TO p_mengu.
  ENDIF.

ENDFORM.                               " PRUEFE_MENGU_PRE