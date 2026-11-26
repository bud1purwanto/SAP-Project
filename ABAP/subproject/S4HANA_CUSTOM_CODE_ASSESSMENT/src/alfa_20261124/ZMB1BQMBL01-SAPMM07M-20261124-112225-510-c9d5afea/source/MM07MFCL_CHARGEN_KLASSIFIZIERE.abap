*eject
*---------------------------------------------------------------------*
*       FORM CHARGEN_KLASSIFIZIEREN                                   *
*---------------------------------------------------------------------*
*       Initialisierung der Chargendefinition (TCUCH)                 *
*       und feststellen der Klassenart für die Chargen.               *
*---------------------------------------------------------------------*
*       Für ein Release > 3.0, wenn automatische Nummernvergabe       *
*       eingebaut wird:                                               *
*       Es muß am Ende (wenn die vorläufigen Chargennummern in die    *
*       endgültigen umgesetzt worden sind, ein FB-Stein               *
*       'CLFM_SET_OBJECTS' aufgerufen werden, dem in der Schnitt-     *
*       stelle die Zuordnung alte - neue Nummer mitzugeben ist.       *
*---------------------------------------------------------------------*
FORM chargen_klassifizieren USING loc_aktyp             "MOD note 129128
                                  loc_feld.             "INS note 129128

  DATA: ls_t340d LIKE t340d.                            "1557609

* Gerufener Korrekturmodus feststellen
  IF ccode EQ ccod-clas.
    CLEAR ccode.
    IF sy-datar IS INITIAL.
      cl_modif = x.
    ELSE.
      cl_modif_before_clas = x.
      EXIT.
    ENDIF.
  ELSEIF NOT cl_modif_before_clas IS INITIAL.
    cl_modif = x.
  ELSE.
    cl_modif = space.
  ENDIF.
  IF mseg-xmacc CA 'BLUX'.                                         "MAA2
    RETURN.                                                        "MAA2
  ENDIF.                                                           "MAA2
  CLEAR cl_modif_before_clas.

* Nur wenn Klassenart definiert ist
  CHECK NOT cl_klart IS INITIAL.

* Felder zurücksetzen
  CLEAR: cl_batch_new,
         cl_batch,
         cl_no_display,
         cl_umshk,
         cl_class,
         cl_class_org,
         cl_kzcla,
         cl_status,
         cl_exist,
         cl_exist_org,
         cl_objecttab,
         cl_refobj,
         cl_object,
         cl_other_object,
         cl_cfc_done.

  REFRESH cl_objecttab.

* Check if WIP batch is active
  CALL FUNCTION 'CO_WIPB_TCUWIPB_READ'
    IMPORTING
      e_wipbatch_active = gv_wipbatch_active
    EXCEPTIONS
      not_found         = 1.

* Prüfung chargenpflicht
  IF dm07m-kzuml IS INITIAL.
    IF t158-trtyp EQ h.
      CHECK NOT vm07m-xchpf IS INITIAL.
      CHECK NOT mseg-charg IS INITIAL.
    ELSE.
      CHECK NOT ( mseg-charg IS INITIAL AND mseg-umcha IS INITIAL ).
    ENDIF.
    CHECK mseg-sobkz NE p.
    CHECK mseg-sobkz NE m.
* Begin of change to handle movement types not relevant for WM (1557609)
    IF NOT dm07m-rblvs = '999' AND mkpf-bfwms NE '2'.
      CALL FUNCTION 'L_LGORT_LGNUM_CHECK'
        EXPORTING
          i_werks = mseg-werks
          i_lgort = mseg-lgort
          i_lgdat = x
        IMPORTING
          e_t340d = ls_t340d
        EXCEPTIONS
           OTHERS  = 0.
* decentral WMS = 'X', decentral EWM = 'E'
      IF ls_t340d-decsy CA 'XE'.
        EXIT.
      ENDIF.
    ENDIF.                                  "1557609
  ELSE.
    IF mseg-shkzg = s.
      IF t158-trtyp EQ h.
        CHECK NOT vm07m-xchpf IS INITIAL.
      ENDIF.
      CHECK NOT mseg-charg IS INITIAL.
      CHECK mseg-sobkz NE p.
      CHECK mseg-sobkz NE m.
      cl_umshk = h.
    ELSE.
      IF t158-trtyp EQ h.
        CHECK NOT dm07m-umxch IS INITIAL.
      ENDIF.
      CHECK NOT mseg-umcha IS INITIAL.
      CHECK mseg-sobkz NE p.
      CHECK mseg-sobkz NE m.
      cl_umshk = s.
    ENDIF.
* Begin of change to handle movement types not relevant for WM (1557609)
    IF NOT dm07m-umrbl = '999' AND mkpf-bfwms NE '2'.
      CALL FUNCTION 'L_LGORT_LGNUM_CHECK'
        EXPORTING
          i_werks = mseg-umwrk
          i_lgort = mseg-umlgo
        i_lgdat = x
      IMPORTING
        e_t340d = ls_t340d
      EXCEPTIONS
        OTHERS  = 0.
* decentral WMS = 'X', decentral EWM = 'E'
    IF ls_t340d-decsy CA 'XE'.
      EXIT.
    ENDIF.
    ENDIF.                                  "1557609
  ENDIF.


* Gerufener Korrekturmodus wird immer hell aufgerufen
  IF loc_aktyp NE h AND NOT cl_modif IS INITIAL.

*-- Wenn Umlagerungscharge gesetzt ist, schauen wo der Cursor steht
    DATA: feld(11) TYPE c.
    IF t158-trtyp EQ h.
      IF NOT dm07m-kzuml IS INITIAL.
        IF loc_feld IS INITIAL.        "INS note 129128
          GET CURSOR FIELD feld.
        ELSE.                          "INS note 129128
          feld = loc_feld.             "INS note 129128
        ENDIF.                         "INS note 129128
        IF feld = 'MSEG-CHARG'.
          cl_status = drei.
          CLEAR cl_umshk.
        ELSEIF feld = 'MSEG-UMCHA' OR feld = 'RM07M-TUCHA'.
          cl_umshk = s.
        ELSE.
          MESSAGE i141.
          EXIT.
        ENDIF.
      ENDIF.
    ELSE.
      IF NOT mseg-charg IS INITIAL AND NOT mseg-umcha IS INITIAL.
        GET CURSOR FIELD feld.
        IF feld = 'MSEG-CHARG'.
          CLEAR cl_umshk.
        ELSEIF feld = 'MSEG-UMCHA' OR feld = 'RM07M-TUCHA'.
          cl_umshk = s.
        ELSE.
          MESSAGE i141.
          EXIT.
        ENDIF.
      ELSEIF NOT mseg-charg IS INITIAL.
        CLEAR cl_umshk.
      ELSE.
        cl_umshk = s.
      ENDIF.
    ENDIF.
    cl_kzcla = '3'.

*-- Nur Anzeige
    IF NOT t158-trtyp EQ h.
      cl_status = drei.
    ENDIF.
  ELSE.
*- CL_KZCLA further determined in CHARGEN_KLASSE_ERMITTELN
    cl_kzcla = dm07m-kzcla.
  ENDIF.

* Falls Mengenumrechnung auf Chargenebene darf beim Storno nicht
* klassifiziert werden
  IF NOT mbefu-matnr IS INITIAL AND mseg-matnr EQ mbefu-matnr. "ALRK74852
    dm07m-kzwso = mbefu-kzwsm.
  ENDIF.
  IF NOT dm07m-kzwso IS INITIAL AND kzdws EQ eins AND       "P40K045016
     NOT mseg-mblnr IS INITIAL AND NOT mseg-mjahr IS INITIAL. "P40K045016
    CHECK vm07m-xstor NE 2.
  ENDIF.

* Chargendefinition MCHA
  IF kzdch EQ charge_auf_werk.
    IF cl_umshk IS INITIAL OR cl_umshk = h.
      PERFORM chargen_klasse_ermitteln USING dm07m-class
                                             mseg-matnr
                                             mseg-charg
                                             mseg-werks
                                             cl_class
                                             cl_exist.
      CHECK NOT cl_kzcla IS INITIAL.
*     Wirkstoff-Nachverrechnung: Chargendaten lesen             "1005414
      IF t156-bustr = '141'.                                "1005414
        PERFORM charge_original_mcha USING mseg-matnr       "1005414
                                           mseg-werks       "1005414
                                           mseg-charg.      "1005414
        IF mseg-vfdat IS INITIAL AND NOT omcha-vfdat IS INITIAL. "1005414
          MOVE omcha-vfdat TO mseg-vfdat.                   "1005414
        ENDIF.                                              "1005414
        IF mseg-hsdat IS INITIAL AND NOT omcha-hsdat IS INITIAL. "1005414
          MOVE omcha-hsdat TO mseg-hsdat.                   "1005414
        ENDIF.                                              "1005414
        IF vm07m-lwedt IS INITIAL AND NOT omcha-lwedt IS INITIAL. "1005414
          MOVE omcha-lwedt TO vm07m-lwedt.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-qndat IS INITIAL AND NOT omcha-qndat IS INITIAL. "1005414
          MOVE omcha-qndat TO vm07m-qndat.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-licha IS INITIAL AND NOT omcha-licha IS INITIAL. "1005414
          MOVE omcha-licha TO vm07m-licha.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-lifch IS INITIAL AND NOT omcha-lifnr IS INITIAL. "1005414
          MOVE omcha-lifnr TO vm07m-lifch.                  "1005414
        ENDIF.                                              "1005414
      ENDIF.                                                "1005414
      PERFORM chargendaten_setzen USING mseg-matnr
                                        mseg-werks
                                        mseg-charg
                                        space.

*---- Klassifizierungsobjekt setzen
      cl_object = xmcha_key.
      CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
        EXPORTING
          i_workarea = cl_mcha
          i_tabname  = cl_ptable
        IMPORTING
          e_object   = cl_objecttab.
      APPEND cl_objecttab.

*---- Referenzobjekt setzen
      IF NOT cl_batch_new IS INITIAL AND cl_exist IS INITIAL
                                     AND NOT mseg-umcha IS INITIAL.
        IF loc_aktyp = h.
          cl_org_batch = mseg-umcha.
          cl_tar_batch = mseg-charg.
          IF xmcha_key-matnr NE mseg-ummat OR
             xmcha_key-werks NE mseg-umwrk.
            cl_other_object = x.
          ENDIF.
          xmcha_key-matnr = mseg-ummat.
          xmcha_key-werks = mseg-umwrk.
          xmcha_key-charg = mseg-umcha.
          cl_refobj = xmcha_key.

*-------- Hat die neue Charge keine Klasse zieht die der abgebenden nur,
*         wenn die Charge selbst klassifiziert ist
          PERFORM chargen_klasse_ermitteln USING dm07m-class
                                                 mseg-ummat
                                                 mseg-umcha
                                                 mseg-umwrk
                                                 cl_class_org
                                                 cl_exist_org.
          IF cl_class IS INITIAL.

*---------- Es erfolgt eine Referenz mit Möglichkeit des Klassenwechs.
            IF NOT cl_class_org IS INITIAL AND
               NOT cl_exist_org IS INITIAL.

*------------ Klasse der abgebenden Charge setzen
              cl_class = cl_class_org.

*------------ Die Klasse kann geändert werden
              IF cl_other_object IS INITIAL.
                cl_confirm_class = space.
              ELSE.
                cl_confirm_class = x.
              ENDIF.

*---------- Keine Referenz
            ELSE.
              CLEAR cl_refobj.
            ENDIF.

*-------- Bei Referenz muß diese auch klassifiziert sein
          ELSEIF cl_exist_org IS INITIAL.
            CLEAR cl_refobj.
          ENDIF.
        ENDIF.
        IF NOT cl_refobj IS INITIAL.
          MESSAGE s669(m7) WITH cl_tar_batch cl_org_batch.
        ENDIF.
        cl_status = eins.
      ENDIF.

*-- Umlagerzeile ist die empfangende Stelle
    ELSE.
      IF mseg-ummat = mseg-matnr AND
         mseg-umcha = mseg-charg AND
         mseg-umwrk = mseg-werks.
        CHECK NOT cl_kzcla IS INITIAL.
      ENDIF.
      PERFORM chargen_klasse_ermitteln USING dm07m-umcla
                                             mseg-ummat
                                             mseg-umcha
                                             mseg-umwrk
                                             cl_class
                                             cl_exist.
      CHECK NOT cl_kzcla IS INITIAL.
      PERFORM chargendaten_setzen USING mseg-ummat
                                        mseg-umwrk
                                        mseg-umcha
                                        x.
*---- Klassifizierungsobjekt setzen
      cl_object = xmcha_key.
      CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
        EXPORTING
          i_workarea = cl_mcha
          i_tabname  = cl_ptable
        IMPORTING
          e_object   = cl_objecttab.
      APPEND cl_objecttab.

*---- Referenzobjekt setzen
      IF NOT cl_batch_new IS INITIAL AND cl_exist IS INITIAL
                                     AND NOT mseg-charg IS INITIAL.
        IF loc_aktyp = h.
          cl_org_batch = mseg-charg.
          cl_tar_batch = xmcha_key-charg.
          IF xmcha_key-matnr NE mseg-matnr OR
             xmcha_key-werks NE mseg-werks.
            cl_other_object = x.
          ENDIF.
          xmcha_key-matnr = mseg-matnr.
          xmcha_key-werks = mseg-werks.
          xmcha_key-charg = mseg-charg.
          cl_refobj = xmcha_key.

*-------- Hat die neue Charge keine Klasse zieht die der abgebenden nur,
*         wenn die Charge selbst klassifiziert ist
          PERFORM chargen_klasse_ermitteln USING dm07m-class
                                                 mseg-matnr
                                                 mseg-charg
                                                 mseg-werks
                                                 cl_class_org
                                                 cl_exist_org.
          IF cl_class IS INITIAL.

*---------- Es erfolgt eine Referenz mit Möglichkeit des Klassenwechs.
            IF NOT cl_class_org IS INITIAL AND
               NOT cl_exist_org IS INITIAL.

*------------ Klasse der abgebenden Charge setzen
              cl_class = cl_class_org.

*------------ Die Klasse kann geändert werden
              IF cl_other_object IS INITIAL.
                cl_confirm_class = space.
              ELSE.
                cl_confirm_class = x.
              ENDIF.

*---------- Keine Referenz
            ELSE.
              CLEAR cl_refobj.
            ENDIF.

*-------- Bei Referenz muß diese auch klassifiziert sein
          ELSEIF cl_exist_org IS INITIAL.
            CLEAR cl_refobj.
          ENDIF.
        ENDIF.
        IF NOT cl_refobj IS INITIAL.
          MESSAGE s669(m7) WITH cl_tar_batch cl_org_batch.
        ENDIF.
        cl_status = eins.
      ENDIF.
    ENDIF.

* Chargendefinition MCH1
  ELSE.
    IF cl_umshk IS INITIAL OR cl_umshk = h.
      PERFORM chargen_klasse_ermitteln USING dm07m-class
                                             mseg-matnr
                                             mseg-charg
                                             mseg-werks
                                             cl_class
                                             cl_exist.
      CHECK NOT cl_kzcla IS INITIAL.
*     Wirkstoff-Nachverrechnung: Chargendaten lesen             "1005414
      IF t156-bustr = '141'.                                "1005414
        PERFORM charge_original_mch1 USING mseg-matnr       "1005414
                                           mseg-charg.      "1005414
        IF mseg-vfdat IS INITIAL AND NOT omch1-vfdat IS INITIAL. "1005414
          MOVE omch1-vfdat TO mseg-vfdat.                   "1005414
        ENDIF.                                              "1005414
        IF mseg-hsdat IS INITIAL AND NOT omch1-hsdat IS INITIAL. "1005414
          MOVE omch1-hsdat TO mseg-hsdat.                   "1005414
        ENDIF.                                              "1005414
        IF vm07m-lwedt IS INITIAL AND NOT omch1-lwedt IS INITIAL. "1005414
          MOVE omch1-lwedt TO vm07m-lwedt.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-qndat IS INITIAL AND NOT omch1-qndat IS INITIAL. "1005414
          MOVE omch1-qndat TO vm07m-qndat.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-licha IS INITIAL AND NOT omch1-licha IS INITIAL. "1005414
          MOVE omch1-licha TO vm07m-licha.                  "1005414
        ENDIF.                                              "1005414
        IF vm07m-lifch IS INITIAL AND NOT omch1-lifnr IS INITIAL. "1005414
          MOVE omch1-lifnr TO vm07m-lifch.                  "1005414
        ENDIF.                                              "1005414
      ENDIF.                                                "1005414
      PERFORM chargendaten_setzen USING mseg-matnr
                                        mseg-werks
                                        mseg-charg
                                        space.
*---- Klassifizierungsobjekt setzen
      cl_object = xmch1_key.
      CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
        EXPORTING
          i_workarea = cl_mch1
          i_tabname  = cl_ptable
        IMPORTING
          e_object   = cl_objecttab.
      APPEND cl_objecttab.

*---- Referenzobjekt setzen
      IF NOT cl_batch_new IS INITIAL AND cl_exist IS INITIAL
                                     AND NOT mseg-umcha IS INITIAL.
        IF loc_aktyp = h.
          cl_org_batch = mseg-umcha.
          cl_tar_batch = mseg-charg.
          IF xmch1_key-matnr NE mseg-ummat.
            cl_other_object = x.
          ENDIF.
          xmch1_key-matnr = mseg-ummat.
          xmch1_key-charg = mseg-umcha.
          cl_refobj = xmch1_key.

*-------- Hat die neue Charge keine Klasse zieht die der abgebenden nur,
*         wenn die Charge selbst klassifiziert ist
          PERFORM chargen_klasse_ermitteln USING dm07m-class
                                                 mseg-ummat
                                                 mseg-umcha
                                                 mseg-umwrk
                                                 cl_class_org
                                                 cl_exist_org.
          IF cl_class IS INITIAL.

*---------- Es erfolgt eine Referenz mit Möglichkeit des Klassenwechs.
            IF NOT cl_class_org IS INITIAL AND
               NOT cl_exist_org IS INITIAL.

*------------ Klasse der abgebenden Charge setzen
              cl_class = cl_class_org.

*------------ Die Klasse kann geändert werden
              IF cl_other_object IS INITIAL.
                cl_confirm_class = space.
              ELSE.
                cl_confirm_class = x.
              ENDIF.

*---------- Keine Referenz
            ELSE.
              CLEAR cl_refobj.
            ENDIF.

*-------- Bei Referenz muß diese auch klassifiziert sein
          ELSEIF cl_exist_org IS INITIAL.
            CLEAR cl_refobj.
          ENDIF.
        ENDIF.
        IF NOT cl_refobj IS INITIAL.
          MESSAGE s669(m7) WITH cl_tar_batch cl_org_batch.
        ENDIF.
        cl_status = eins.
      ENDIF.
*-- Umlagerzeile ist die empfangende Stelle
    ELSE.
      IF mseg-ummat = mseg-matnr AND
         mseg-umcha = mseg-charg.
        CHECK NOT cl_kzcla IS INITIAL.
      ENDIF.
      PERFORM chargen_klasse_ermitteln USING dm07m-umcla
                                             mseg-ummat
                                             mseg-umcha
                                             mseg-umwrk
                                             cl_class
                                             cl_exist.
      CHECK NOT cl_kzcla IS INITIAL.
      PERFORM chargendaten_setzen USING mseg-ummat
                                        mseg-umwrk
                                        mseg-umcha
                                        x.
*---- Klassifizierungsobjekt setzen
      cl_object = xmch1_key.
      CALL FUNCTION 'CLUC_CONVERT_STRUCTURE'
        EXPORTING
          i_workarea = cl_mch1
          i_tabname  = cl_ptable
        IMPORTING
          e_object   = cl_objecttab.
      APPEND cl_objecttab.

*---- Referenzobjekt setzen
      IF NOT cl_batch_new IS INITIAL AND cl_exist IS INITIAL
                                     AND NOT mseg-charg IS INITIAL.
        IF loc_aktyp = h.
          cl_org_batch = mseg-charg.
          cl_tar_batch = xmch1_key-charg.
          IF xmch1_key-matnr NE mseg-matnr.
            cl_other_object = x.
          ENDIF.
          xmch1_key-matnr = mseg-matnr.
          xmch1_key-charg = mseg-charg.
          cl_refobj = xmch1_key.

*-------- Hat die neue Charge keine Klasse zieht die der abgebenden nur,
*         wenn die Charge selbst klassifiziert ist
          PERFORM chargen_klasse_ermitteln USING dm07m-class
                                                 mseg-matnr
                                                 mseg-charg
                                                 mseg-werks
                                                 cl_class_org
                                                 cl_exist_org.
          IF cl_class IS INITIAL.

*---------- Es erfolgt eine Referenz mit Möglichkeit des Klassenwechs.
            IF NOT cl_class_org IS INITIAL AND
               NOT cl_exist_org IS INITIAL.

*------------ Klasse der abgebenden Charge setzen
              cl_class = cl_class_org.

*------------ Die Klasse kann geändert werden
              IF cl_other_object IS INITIAL.
                cl_confirm_class = space.
              ELSE.
                cl_confirm_class = x.
              ENDIF.

*---------- Keine Referenz
            ELSE.
              CLEAR cl_refobj.
            ENDIF.

*-------- Bei Referenz muß diese auch klassifiziert sein
          ELSEIF cl_exist_org IS INITIAL.
            CLEAR cl_refobj.
          ENDIF.
        ENDIF.
        IF NOT cl_refobj IS INITIAL.
          MESSAGE s669(m7) WITH cl_tar_batch cl_org_batch.
        ENDIF.
        cl_status = eins.
      ENDIF.
    ENDIF.
  ENDIF.

* Prüfung, ob Charge überhaupt klassifiziert werden kann.
* Prüfung erfolgt bei:
* 1) Aufruf über Funktionsbaustein MB_CREATE_GOODS_MOVEMENT
* 2) Batch Input

* Dialog
  IF xmbwl IS INITIAL AND ( sy-binpt IS INITIAL OR NOT
                            cattaktiv IS INITIAL ).

*-- Korrekturmodus
    IF loc_aktyp NE h.

*---- Aus Menü in Klassifizierung
      IF NOT cl_modif IS INITIAL.
        cl_kzcla = '3'.

*---- Normale Prüfposition - wird zu '2' wenn zuvor hell
      ELSEIF cl_kzcla EQ '3' OR cl_kzcla EQ '4'.
        IF cl_umshk IS INITIAL OR cl_umshk = h.
          IF NOT dm07m-class IS INITIAL.
            cl_kzcla = '2'.
          ENDIF.
        ELSE.
          IF NOT dm07m-umcla IS INITIAL.
            cl_kzcla = '2'.
          ENDIF.
        ENDIF.
      ENDIF.

*-- Hinzufügen
    ELSE.

*---- Wurde Charge bereits klassifiziert ?
      IF NOT cl_exist IS INITIAL AND cl_kzcla EQ '4'.
        cl_kzcla = '2'.
      ENDIF.
    ENDIF.
  ELSE.

*-- Batch-Input/FB-Aufruf -> Klasse muß bekannt sein
    cl_kzcla = eins.
  ENDIF.

* Überprüfen, ob Klasse bekannt
  IF cl_class IS INITIAL.
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb  = 'M7'
        i_msgnr  = '207'
        i_nolog  = x
        i_output = space
      IMPORTING
        rc       = rc.
    CASE rc.
      WHEN 0.
      WHEN 2.
        IF kzdch EQ charge_auf_werk.
          MESSAGE e207(m7) WITH xmcha_key-charg xmcha_key-matnr
                                                xmcha_key-werks.
        ELSE.
          MESSAGE e207(m7) WITH xmch1_key-charg xmch1_key-matnr.
        ENDIF.
      WHEN 1.
        IF kzdch EQ charge_auf_werk.
          MESSAGE w207(m7) WITH xmcha_key-charg xmcha_key-matnr"ok
                                                xmcha_key-werks.
          PERFORM naco_log(sapfm07m) USING  'W' 'M7' '207'
             xmcha_key-charg xmcha_key-matnr xmcha_key-werks space.
        ELSE.
          MESSAGE w207(m7) WITH xmch1_key-charg xmch1_key-matnr.
          PERFORM naco_log(sapfm07m) USING  'W' 'M7' '207'
                 xmch1_key-charg xmch1_key-matnr space space.
        ENDIF.
      WHEN OTHERS.
        IF kzdch EQ charge_auf_werk.
          MESSAGE s207(m7) WITH xmcha_key-charg xmcha_key-matnr
                                                xmcha_key-werks.
        ELSE.
          MESSAGE s207(m7) WITH xmch1_key-charg xmch1_key-matnr.
        ENDIF.
    ENDCASE.
    CHECK NOT cl_class IS INITIAL.
  ENDIF.

* Die Art der Klassifizierung wird festgelegt
  IF cl_kzcla = '1'.
    cl_batch      = x.
    cl_no_display = x.
  ELSEIF cl_kzcla = '2'.
    cl_batch      = space.
    cl_no_display = x.
  ELSE.
    cl_batch      = space.
    cl_no_display = space.
  ENDIF.

* Zusätzliche alternative Mengeneinheiten im Merkmal (Stahl/Wirkstoff)
  IF kzdws EQ eins.
    DATA: l_umwso LIKE dm07m-kzwso.
    PERFORM read_kzwso(sapfm07m) CHANGING dm07m-kzwso
                                          l_umwso.
  ENDIF.
  IF ( NOT dm07m-kzwso IS INITIAL AND  cl_umshk IS INITIAL ) OR
     ( NOT dm07m-kzwso IS INITIAL AND  cl_umshk EQ h       ) OR
     ( NOT l_umwso     IS INITIAL AND  cl_umshk EQ s ).

*-- Prüfen, ob Charge bereits im Beleg enthalten
    DATA: pos_nr LIKE mseg-zeile,
          l_matnr LIKE mseg-matnr,
          l_charg LIKE mseg-charg,
          l_werks LIKE mseg-werks.

*-- Bei Umlagerung muß die empfangende Charge geprüft werden
    IF cl_umshk IS INITIAL OR cl_umshk EQ h.                "ALRK221457
      "   IF DM07M-KZUML IS INITIAL.
      l_matnr = mseg-matnr.
      l_charg = mseg-charg.
      l_werks = mseg-werks.
    ELSE.
      l_matnr = mseg-ummat.
      l_charg = mseg-umcha.
      l_werks = mseg-umwrk.
    ENDIF.

    PERFORM check_exist_charge_with_pos(sapfm07m)
                                 USING l_matnr
                                       l_charg
                                       l_werks
                                       dm07m-kzuml
                                       mseg-zeile
                              CHANGING pos_nr.

*---Charge im Beleg gefunden ---> nur Anzeige
    IF sy-subrc = 0.

*---- Es wird auf 'Anzeigen' geschaltet
      cl_status = drei.

*---- Meldung nur im Dialogfall und Aufruf über Menü
      IF     xmbwl IS INITIAL AND ( sy-binpt IS INITIAL OR NOT
                                    cattaktiv IS INITIAL ) AND
         NOT cl_modif IS INITIAL AND
             t158-trtyp EQ h.
        MESSAGE i004(xu) WITH l_charg l_matnr.
      ENDIF.

*---Weiter prüfen: Wurde die Charge bereits bebucht
    ELSE.
      DATA x_already_posted.
      PERFORM check_batch_posted USING    l_matnr
                                          l_werks
                                          l_charg
                                 CHANGING x_already_posted.
      IF NOT x_already_posted IS INITIAL.
        cl_status = drei.
*------- Meldung nur im Dialogfall und Aufruf über Menü
        IF     xmbwl IS INITIAL AND ( sy-binpt IS INITIAL OR NOT
                                      cattaktiv IS INITIAL ) AND
           NOT cl_modif IS INITIAL AND
               t158-trtyp EQ h.
          MESSAGE i004(xu) WITH l_charg l_matnr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* Keine Änderung der Klassifikation, wenn Charge wirkstoffbewertet
* und Bewertungssatz existiert
  IF t158-trtyp EQ h.
    IF dm07m-kzuml IS INITIAL.
      IF NOT dm07m-xbewm IS INITIAL AND dm07m-rmbew IS INITIAL.
        IF cl_status NE drei.
          IF cl_modif IS INITIAL.
            IF cl_batch IS INITIAL AND cl_no_display IS INITIAL.
              MESSAGE i081(lb).
            ELSE.
*             no message, because class-dialog is not performed
            ENDIF.
          ELSE.
            MESSAGE i081(lb).
          ENDIF.
        ENDIF.
        cl_status = drei.
      ENDIF.
    ELSE.
      IF NOT dm07m-umxbewm IS INITIAL AND dm07m-umrmb IS INITIAL.
        IF cl_status NE drei.
          IF cl_modif IS INITIAL.
            IF cl_batch IS INITIAL AND cl_no_display IS INITIAL.
              MESSAGE i081(lb).
            ELSE.
*             no message, because class-dialog is not performed
            ENDIF.
          ELSE.
            MESSAGE i081(lb).
          ENDIF.
        ENDIF.
        cl_status = drei.
      ENDIF.
    ENDIF.
  ENDIF.

* Kein Ansprung der Klassifizierung, wenn dies nicht explizit gewünscht
* (CL_MODIF = X) und Anzeigemodus der Klassifizierung (CL_STATUS = 3).
* Jedoch: - Update der Objektmerkmale
*         - setzen der CUOBJ_BM

  IF cl_modif IS INITIAL AND cl_status EQ drei.

* Export cl_object to memory ID NO_CFC for EXIT_SAPLCLFM_*.
    DATA:
      lv_batch_no_cfc TYPE objnum.
    MOVE cl_object TO lv_batch_no_cfc.
    EXPORT lv_batch_no_cfc TO MEMORY ID 'BATCH_NO_CFC'.

* when CUOBJ_BM (cl_cuobj) is initial try to find out
*  batch is classified and set the correct CUOBJ_BM
    IF cl_cuobj IS INITIAL.
      CALL FUNCTION 'CUOB_GET_NUMBER'
        EXPORTING
          class_type       = cl_klart
          object_id        = cl_object
          table            = cl_ptable
        IMPORTING
          object_number    = cl_cuobj
        EXCEPTIONS
          lock_problem     = 1
          object_not_found = 2
          OTHERS           = 3.
      IF sy-subrc = 2.
        CLEAR cl_cuobj.
      ENDIF.

      IF NOT cl_cuobj IS INITIAL.
        CALL FUNCTION 'VB_BATCH_WRITE_CLOG_BUFFER'
          EXPORTING
            batch_cuobj = cl_cuobj
            batch_objek = cl_object
            batch_class = cl_class.

      ENDIF. " not cl_cuobj is initial.
    ENDIF. " cl_cuobj is initial

*  object characteristics
    PERFORM charge_vererbende_objekte.
    CALL FUNCTION 'CTMS_OBJECT_AREA'
      TABLES
        objects = cl_objecttab.

    CALL FUNCTION 'CLO0_DDB_OBJ_VALUATION_OPEN'
      EXPORTING
        classtype_imp     = cl_klart
        class_imp         = cl_class
        object_imp        = cl_object
        obj_structure_imp = cl_ptable
      EXCEPTIONS
        OTHERS            = 99.

    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

    CALL FUNCTION 'CLO0_DDB_OBJ_VALUATION_CLOSE'
      EXCEPTIONS
        OTHERS = 99.

    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

    CALL FUNCTION 'CLO0_DDB_SAVE'
      EXCEPTIONS
        OTHERS = 99.

    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

    EXIT.
  ENDIF.

* Wenn Charge bereits klassifiziert wurde -> keine neue Referenz
  CALL FUNCTION 'VB_BATCH_READ_CLOG_BUFFER'
    EXPORTING
      imp_object       = cl_object
    EXCEPTIONS
      object_not_found = 1.
  IF cl_status = eins AND sy-subrc IS INITIAL.
    cl_status = zwei.
    CLEAR cl_refobj.
    MESSAGE s895(m7) WITH space.
  ENDIF.

* Mindestens einen Status setzen
  IF cl_status IS INITIAL.
    cl_status = zwei.
  ENDIF.

* Objektarea setzten
  PERFORM charge_vererbende_objekte.
  CALL FUNCTION 'CTMS_OBJECT_AREA'
    TABLES
      objects = cl_objecttab.

* Klassifizierung ausführen
  DO.

*-- Es wird eine Referenzbewertung bei vorhandener Klasse vorgenommen
    IF cl_status = eins AND NOT cl_class IS INITIAL.
      CALL FUNCTION 'CLFM_OBJECT_CLASSIFICATION'
        EXPORTING
          batch                    = x
          class                    = cl_class
          classtype                = cl_klart
          no_display               = x
          no_change_type           = x
          no_f11                   = x
          no_f8                    = x
          object                   = cl_object

* Begin of note 1146687.
        objtxt                     = cl_makt-maktx
*  End  of note 1146687.

          ref_object               = cl_refobj
          ptable                   = cl_ptable
          status                   = cl_status
          table                    = cl_table
          typetext                 = cl_artxt
          bi_dialog                = x
        IMPORTING
          ok_code                  = cl_okcode
          internal_obj_number      = xinob-cuobj
        EXCEPTIONS
          classification_not_found = 01
          foreign_lock             = 02
          system_failure           = 03
          no_auth_klart            = 04
          no_multi_classif         = 05.                      "n1317593
      IF NOT sy-subrc IS INITIAL.
        CASE sy-subrc.
          WHEN 1.
            MESSAGE e570(cl).
          WHEN 2.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno  "1616217
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          WHEN 3.
            MESSAGE e519(cl).
          WHEN 4.
            MESSAGE e545(cl) WITH cl_klart.
          WHEN 5.                                             "n1317593
            MESSAGE e528(cl).                                 "n1317593
        ENDCASE.
      ENDIF.
      IF NOT xinob-cuobj IS INITIAL AND sy-subrc IS INITIAL.
        xinob-objek = cl_object.
        COLLECT xinob.
      ENDIF.
      cl_status = zwei.
    ELSE.
      cl_confirm_class = space.
    ENDIF.
*-- Klassendialog kommt nicht, wenn Bewertung im Hintergrund
    IF cl_kzcla NE '3' OR cl_kzcla NE '4'.
      cl_confirm_class = space.
    ENDIF.

* Aufruf des CFCs für zusätzliche freie Merkmale - nur wenn Klasse bek.
* und bei neuer Position
    CLEAR cl_cfc_done.

    IF gv_wipbatch_active EQ x.                  "WIP batch active
ENHANCEMENT-SECTION     EHP4_MM07MFCL_CHARGEN_KLASS_01 SPOTS ES_MM07MFB1_BELEG_LESEN.
      IF NOT dm07m-xkcfc IS INITIAL AND NOT cl_class IS INITIAL
                                    AND loc_aktyp = h
                                    AND cl_status NE drei.
        PERFORM charge_klassifizieren_cfc.
        cl_cfc_done = x.
      ENDIF.
END-ENHANCEMENT-SECTION.
    ELSE.                                         "WIP batch inactive
ENHANCEMENT-SECTION     chargen_klassifizieren_01 SPOTS es_sapmm07m.
      IF NOT dm07m-xkcfc IS INITIAL AND NOT cl_class IS INITIAL
                                    AND loc_aktyp = h
                                    AND cl_status NE drei.
        PERFORM charge_klassifizieren_cfc.
        cl_cfc_done = x.
      ENDIF.
END-ENHANCEMENT-SECTION.
    ENDIF.

*-- Klassifizieren
    CALL FUNCTION 'CLFM_OBJECT_CLASSIFICATION'
      EXPORTING
        batch                    = cl_batch
        class                    = cl_class
        classtype                = cl_klart
        no_display               = cl_no_display
        no_change_type           = x
        no_f11                   = x
        no_f8                    = x
        object                   = cl_object

* Begin of note 1146687.
        objtxt                   = cl_makt-maktx
*  End  of note 1146687.

        ptable                   = cl_ptable
        status                   = cl_status
        table                    = cl_table
        typetext                 = cl_artxt
        confirm_class            = cl_confirm_class
        bi_dialog                = x
      IMPORTING
        ok_code                  = cl_okcode
        internal_obj_number      = cl_cuobj
      EXCEPTIONS
        classification_not_found = 01
        foreign_lock             = 02
        system_failure           = 03
        no_auth_klart            = 04
        no_multi_classif         = 05.                        "n1317593
    IF NOT sy-subrc IS INITIAL.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE e570(cl).
        WHEN 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno  "1616217
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN 3.
          MESSAGE e519(cl).
        WHEN 4.
          MESSAGE e545(cl) WITH cl_klart.
        WHEN 5.                                               "n1317593
          MESSAGE e528(cl).                                   "n1317593
      ENDCASE.
    ELSEIF NOT cl_cuobj IS INITIAL.
      CALL FUNCTION 'VB_BATCH_WRITE_CLOG_BUFFER'
        EXPORTING
          batch_cuobj = cl_cuobj
          batch_objek = cl_object
          batch_class = cl_class.
    ENDIF.
    IF cl_okcode NE 'WECH'.
      IF NOT dm07m-kzcla IS INITIAL.
        CALL FUNCTION 'CTMS_DDB_CHECK'
          EXPORTING
            free          = 'X'
          EXCEPTIONS
            inconsistency = 1
            incomplete    = 2
            not_assigned  = 4
            OTHERS        = 0.
        IF NOT sy-subrc IS INITIAL.
          CALL FUNCTION 'MB_CHECK_T160M'
            EXPORTING
              i_arbgb  = 'LB'
              i_msgnr  = '045'
              i_msgv1  = cl_class
              i_output = x.
        ENDIF.
        EXIT.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.

* Objektarea zurücksetzten
  REFRESH cl_objecttab.
  CLEAR cl_objecttab.
  CALL FUNCTION 'CTMS_OBJECT_AREA'
    TABLES
      objects = cl_objecttab.

* Strukturdaten übernehmen
  IF NOT xmbwl IS INITIAL.
    IF cl_umshk IS INITIAL OR cl_umshk = h.
      dm07m-xclas = x.
    ELSE.
      dm07m-umxcl = x.
    ENDIF.
  ELSE.
    IF cl_umshk IS INITIAL OR cl_umshk = h.
      IF dm07m-class IS INITIAL.
        dm07m-class = cl_class.
      ENDIF.
    ELSE.
      IF dm07m-umcla IS INITIAL.
        dm07m-umcla = cl_class.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHARGEN_KLASSIFIZIEREN