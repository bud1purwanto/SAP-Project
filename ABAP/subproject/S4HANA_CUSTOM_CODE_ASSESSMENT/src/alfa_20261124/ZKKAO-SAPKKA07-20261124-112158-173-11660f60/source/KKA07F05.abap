***INCLUDE KKA07F05 .
* Enthält ausgelagerte Form-Routinen von SAPKKA07 (SchedMan)
*-------------------------------------------------------------------
* Prüfen nur über Rahmenprogramm SAPKKA07 möglich!
*-------------------------------------------------------------------

TYPE-POOLS:
  kpepw.                               "Schedule Manager

INCLUDE rbonrart.

* Ereignisse neuer Arbeitsvorrat
*INCLUDE rk_pep_wl_selinc2.
* Form-routinen neuer Arbeitsvorrat
*INCLUDE rk_pep_wl_selinc3.


CONSTANTS:
  pm VALUE ' '.

DATA:
  gd_scma_key TYPE schedman_key,
  gd_scma_worklists_active TYPE kka_yes_no,
  gt_scma_spool TYPE STANDARD TABLE OF schedman_spool,
  gd_scma_spool TYPE schedman_spool.

DEFINE move_param_tab_to_sm.
  loop at &1.
    move-corresponding &1 to &2.
    &2-optio = &1-option.
    append &2.
  endloop.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*       FORM init_record_for_scma                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM init_record_for_scma.
                                       "to be called before selection

  DATA:
    detail LIKE schedman_detail_user,
    wf_item_struc TYPE scma_witem,
    appl_spec_info TYPE schedman_specific_copc,
    selcrit_sm LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE,
    param_sm   LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE,
    param LIKE kaba00 OCCURS 0 WITH HEADER LINE,
    selcrit LIKE kaba00 OCCURS 0 WITH HEADER LINE.

* Fill parameters for schedule manager record initialization

  detail-function = 'KABG'.
  IF anzeigen EQ yes.
    detail-activity = '03'.
  ELSE.
    detail-activity = '16'.
  ENDIF.
  IF simulati EQ yes.
    detail-testflag = 'X'.
  ELSE.
    CLEAR detail-testflag.
  ENDIF.
* Beginning note 447614
  IF org_rep IS INITIAL.
    "org_rep is set by transactions and by background reports
    detail-repid = sy-repid.
  ELSE.
    detail-repid = org_rep.
  ENDIF.
  IF detail-repid = 'SAPKKA07COBG' OR detail-repid = 'SAPKKA07COWL'.
    detail-tcode = 'KKAV'.
  ELSE.
    detail-tcode = con_tcode_sa_e.
  ENDIF.
* End note 447614

  wf_item_struc-wf_witem = wf_witem.
  "global variable defined in include RKASMAWF
  wf_item_struc-wf_wlist = wf_wlist.                        "46B

  appl_spec_info-kokrs = kokrs.
  appl_spec_info-perio_from = abgrmona.
*  appl_spec_info-perio_to = ABGRMONA.
  appl_spec_info-gjahr = abgrjahr.
*  appl_spec_info-gjahr_to = ABGRJAHR.
  appl_spec_info-versn = abgrvers-low.
*  GS_PEP_ORG-WERKS = ABGRWERK-LOW.
*  GS_PEP_ORG-LMONA = GD_PEP_GJVAR.

* Füllen der Selektionskriterien-Tabelle
  PERFORM get_param_tab
    TABLES
      param.
  move_param_tab_to_sm param param_sm.

  PERFORM get_sel_tab
    TABLES
      selcrit.
* Beginning 46C: CO area now in selection table, don't display
* KASS should provide this functionality -> one seltab for
* background processing, one for display in SchedMan etc.
  DELETE selcrit WHERE field cs 'KOKRS'.
* End 46C
  move_param_tab_to_sm selcrit selcrit_sm.

  CALL FUNCTION 'KPEP_MONI_INIT_RECORD'
       EXPORTING
            ls_detail     = detail
            ls_witem      = wf_item_struc
            ls_appl       = appl_spec_info
       IMPORTING
            ls_key        = gd_scma_key
            will_be_saved = gd_save_extract
       TABLES
            lt_selkrit    = selcrit_sm.
*            lt_param         = param_sm.
* dieselben Werte wie appl_spec_info
  COMMIT WORK.
ENDFORM.

INCLUDE schedman_events.

*---------------------------------------------------------------------*
*       FORM close_record_for_scma                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM close_record_for_scma.

  DATA: message LIKE schedman_message,
        num_of_objs LIKE smmain-nr_of_objects,
        aplstat LIKE smmain-aplstat,
        scma_event LIKE scma_event.


  num_of_objs = abgr_obj_total.

* Beginning 46B
*  IF abgr_obj_not_done EQ 0 and gd_abort_error = no.  "M46B
*    aplstat = '0'.
*  ELSEIF wl_activ = 'X' and gd_abort_error = no.      "M46B
*    aplstat = '2'.
*  ELSE.
*    aplstat = '4'.
*  ENDIF.
  IF gd_abort_error = yes OR abgr_obj_not_done > 0.
    aplstat = '4'.
  ELSEIF w_msg_nr > 0.
    aplstat = '2'.
  ELSE.
    aplstat = '0'.
  ENDIF.
* End 46B

  IF NOT abgr_msg_store_nr IS INITIAL.
    message-nr        = abgr_msg_store_nr.
    message-object_id = abgr_object_id.
    message-aplid     = abgr_aplid.
  ENDIF.

  scma_event-wf_witem = wf_witem.
  scma_event-wf_okey = wf_okey.
  IF gd_scma_worklists_active = no AND aplstat = '4'.   "352714
    scma_event-wf_event = cs_wf_events-error.           "352714
  ELSE.                                                 "352714
    scma_event-wf_event = cs_wf_events-finished.
  ENDIF.                                                "352714

  CALL FUNCTION 'KPEP_MONI_CLOSE_RECORD'
       EXPORTING
            ls_key        = gd_scma_key
            ls_message    = message
            ld_objects    = num_of_objs
            ls_ext        = obj_lst_extr
            ls_rl         = base_lst_extr
            ls_scma_event = scma_event
       TABLES
            lt_spool      = gt_scma_spool
       CHANGING
            ld_aplstat    = aplstat
       EXCEPTIONS
            no_id_given   = 0
            OTHERS        = 0.

  COMMIT WORK.

ENDFORM.

TYPES:
    BEGIN OF t_aufk_key,
      aufnr TYPE aufnr,
    END OF t_aufk_key,
    t_auft_keys TYPE SORTED TABLE OF t_aufk_key WITH UNIQUE DEFAULT KEY.

*---------------------------------------------------------------------*
*       FORM SELECT_OBJECTS_KASS                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM select_objects_kass.
  TYPES:
    BEGIN OF t_pos_key,
      aufnr TYPE aufnr,
      posnr TYPE co_posnr,
      objnp TYPE ionrb,
    END OF t_pos_key,
    BEGIN OF t_pos_stamm,
      aufnr TYPE afpo-aufnr,
      posnr TYPE afpo-posnr,
      objnp TYPE afpo-objnp,
      matnr TYPE afpo-matnr,
      pwerk TYPE afpo-pwerk,
      wemng TYPE afpo-wemng,
      psmng TYPE afpo-psmng,
      amein TYPE afpo-amein,
      maktx TYPE makt-maktx,
    END OF t_pos_stamm.

  DATA:
    obj_num TYPE ionrb,
    objektart LIKE ionra-obart,
    obj_nums TYPE ionrb OCCURS 0,
    auftraege TYPE t_auft_keys,
    neue_auftraege LIKE auftraege,
    positionen TYPE SORTED TABLE OF t_pos_key
                    WITH UNIQUE KEY aufnr posnr,
    neue_positionen LIKE positionen,
    order_id TYPE aufnr,
    pos_key TYPE t_pos_key,
    objekt LIKE LINE OF t_auftrag,
    position TYPE t_pos_stamm,
    positionen_stamm TYPE TABLE OF t_pos_stamm
                          WITH KEY aufnr posnr,
    alte_aufnr TYPE aufnr,
    index LIKE sy-tabix.

*  CHECK NOT org_rep IS INITIAL.          "statement unnecessary "447614
  CHECK gd_abort_error = no OR wl_activ = yes.
* Wg. Fehler in Arbeitsvorrat Objektselektion auch bei Abbruch

  CALL FUNCTION 'K_OBJECT_SELECTION_RUN'
    EXPORTING
*      i_kokrs     = kokrs
*     I_DATE_FROM = SY-DATUM
*     I_DATE_TO   =
     i_vrgng     = 'KABG'
*     I_VERSN     =
    TABLES
      it_objnr    = obj_nums
*     IT_PERIODS  =
  .

  CHECK gd_abort_error = no.

  IF obj_nums[] IS INITIAL.
    IF GD_SCMA_WORKLISTS_ACTIVE = NO.                           "303770
    CALL FUNCTION 'CM_F_MESSAGE'
         EXPORTING
              arbgb            = 'KJ'
              msgnr            = '816'
              msgty            = 'W'
              msgv1            = space
              msgv2            = space
              msgv3            = space
              msgv4            = space
              msg_on_screen    = no
              object_dependent = no
              append_same_msg  = no.
    ENDIF.                                                      "303770
  ENDIF.

  SORT obj_nums.
* Relevanz checken
  LOOP AT obj_nums INTO obj_num.
    CALL FUNCTION 'OBJECT_NUMBER_TYPE_GET'
       EXPORTING
            objnr     = obj_num-objnr
       IMPORTING
            obart     = objektart
*                 OBART_ORG =
            .
    IF objektart <> objektart_or AND objektart <> objektart_op.
      DATA: objektart_text LIKE tbo01-txt20,
           objid TYPE j_objid_out.

      CALL FUNCTION 'OBJECT_IDENTIFICATION_GET'
           EXPORTING
                objnr       = obj_num-objnr
           IMPORTING
                ident_txt20 = objektart_text
                e_objid     = objid.

      CLEAR objekt.
      PERFORM handle_not_rel_with_msg
        USING
          obj_num-objnr
          objekt                       "initial
          'KJ' 'I' 162 objektart_text objid pm pm.

      CONTINUE.
    ENDIF.

    IF objektart = objektart_or.
      CALL FUNCTION 'OBJECT_KEY_GET_OR'
           EXPORTING
                objnr       = obj_num-objnr
           IMPORTING
                aufnr       = order_id
           EXCEPTIONS
                not_found   = 0
                wrong_obart = 0
                OTHERS      = 0.

      APPEND order_id TO auftraege.

    ELSEIF objektart = objektart_op.
      CALL FUNCTION 'OBJECT_KEY_GET_OP'
           EXPORTING
                objnr       = obj_num-objnr
           IMPORTING
                aufnr       = pos_key-aufnr
                co_posnr    = pos_key-posnr
           EXCEPTIONS
                not_found   = 0
                wrong_obart = 0
                OTHERS      = 0.
      pos_key-objnp = obj_num-objnr.
      APPEND pos_key TO positionen.
    ENDIF.
  ENDLOOP.

* AUFK-Daten auch für die Positionen lesen, für die kein
* Auftragskopf übergeben wurde. Die zugehörigen Auftragsköpfe
* dürfen nicht rückgemeldet werden. Darum in einer speziellen
* Tabelle merken.
  LOOP AT positionen INTO pos_key.
    CHECK pos_key-aufnr <> alte_aufnr.
    alte_aufnr = pos_key-aufnr.
    READ TABLE auftraege
         WITH KEY aufnr = pos_key-aufnr
         BINARY SEARCH
         TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.                  "nicht gefunden
      INSERT pos_key-aufnr INTO auftraege INDEX sy-tabix.
      APPEND pos_key-aufnr TO neue_auftraege.
    ENDIF.
  ENDLOOP.

* Auftragsstammdaten lesen und Relevanz checken.
  IF NOT auftraege IS INITIAL.
    SELECT mandt aufnr objnr autyp
           werks auart ktext
           flg_mltps bukrs zschl procnr
           loekz pkosa abgsl
           prctr
           INTO CORRESPONDING FIELDS OF objekt
           FROM aufk
           FOR ALL ENTRIES IN auftraege
           WHERE aufnr = auftraege-aufnr.

      IF objekt-abgsl = space OR objekt-pkosa <> space OR
         objekt-loekz <> space.
* Der Auftrag ist nicht relevant.
        PERFORM handle_not_relevant
          USING
            objekt
          CHANGING
            neue_auftraege.

        IF objekt-flg_mltps <> space.
* Sieh nach, ob Positionen für diesen Auftrag übergeben wurden
* (nur bei Kuppelproduktion): Auch sie sind nicht relevant.
* Für sie brauchen keine Positionsstammdaten mehr gelesen zu werden,
* da sie nicht verarbeitet werden.
          READ TABLE positionen
               WITH KEY aufnr = objekt-aufnr
               BINARY SEARCH
               INTO pos_key.
          index = sy-tabix.
          WHILE sy-subrc = 0 AND pos_key-aufnr = objekt-aufnr.
            objekt-posnr = pos_key-posnr.
            objekt-objnp = pos_key-objnp.
            PERFORM handle_not_relevant
              USING
                objekt
              CHANGING
                neue_auftraege.
            DELETE positionen INDEX index.
            READ TABLE positionen INDEX index INTO pos_key.
          ENDWHILE.
        ENDIF.
      ELSE.
* Auftrag relevant.
        APPEND objekt TO t_auftrag.

        IF objekt-flg_mltps = space.
* Position 0001 lesen für Aufträge ohne Kuppelprodukte: Position
* in Positionstabelle hinzufügen.
          pos_key-aufnr = objekt-aufnr.
          pos_key-posnr = '0001'.
          CLEAR pos_key-objnp.
          INSERT pos_key INTO TABLE positionen.
        ENDIF.
      ENDIF.
      CLEAR objekt.
      "Es wurden Werte verändert, die nicht von Select-Schleife
                                       "eingelesen werden.
    ENDSELECT.
  ENDIF.

  SORT t_auftrag.
* Positionsdaten für alle noch übrigen, relevanten Positionen einlesen:
  IF NOT positionen IS INITIAL.
    SELECT afpo~aufnr afpo~posnr afpo~objnp afpo~matnr afpo~pwerk
           afpo~wemng afpo~psmng afpo~amein
           makt~maktx
           INTO CORRESPONDING FIELDS OF TABLE positionen_stamm
           FROM afpo LEFT OUTER JOIN makt ON
                   afpo~matnr = makt~matnr AND
                   makt~spras = sy-langu
           FOR ALL ENTRIES IN positionen
           WHERE afpo~aufnr = positionen-aufnr AND
             afpo~posnr = positionen-posnr.

    DATA:
      bearbeiten TYPE kka_yes_no.

    SORT positionen_stamm.
    CLEAR alte_aufnr.

    LOOP AT positionen_stamm INTO position.
* Objekte in Auftragstabelle sortiert um Positionsdaten ergänzen
      IF alte_aufnr <> position-aufnr.
        READ TABLE t_auftrag INTO objekt
             WITH KEY aufnr = position-aufnr
             BINARY SEARCH.
        alte_aufnr = position-aufnr.
        index = sy-tabix.
      ELSE.
        CLEAR sy-subrc.
      ENDIF.
      IF sy-subrc = 0.
        "darf nicht anders sein, sonst Fehler (s. u.)
        IF objekt-flg_mltps <> space AND objekt-posnr IS INITIAL.
* Nachsehen, ob Auftragskopf bei Kuppelproduktion zu bearbeiten ist
          PERFORM check_auftrag_bearbeiten
            USING
              objekt
            CHANGING
              bearbeiten
              neue_auftraege.
        ELSE.
          bearbeiten = yes.
        ENDIF.
* Positionsdaten ergänzen
        MOVE-CORRESPONDING position TO objekt.
        IF objekt-flg_mltps = space.
* Bei Aufträgen ohne Kuppelprodukte 1:1-Abbildung zwischen Kopf und
* Position.
          MODIFY t_auftrag FROM objekt INDEX index.
        ELSE.
* Kuppelproduktion
          IF bearbeiten = no.
* Nur bei Auftragskopf: Eintrag löschen
            DELETE t_auftrag INDEX index.
          ELSE.
* Position in Tabelle der zu bearbeitenden Objekte einfügen
            index = index + 1.
            "hinter Auftragskopf bzw. letzter Position einfügen
          ENDIF.
          INSERT objekt INTO t_auftrag INDEX index.
        ENDIF.
      ELSE.
* Auftragskopfdaten fehlen

        CLEAR objekt.
        "Kopfdaten vom vorherigen Auftrag löschen
        CLEAR alte_aufnr.
        "nötig bei mehreren Positionen zu fehlendem Kopf
        MOVE-CORRESPONDING position TO objekt.

        PERFORM handle_message
          USING
            objekt
            'KJ' 'E' 815 objekt-posnr objekt-aufnr pm pm.

        IF gd_scma_worklists_active = yes.
          IF objekt-objnp IS INITIAL.
            "objnp ist initial bei Position für Nicht-Kuppel-Auftrag,
            "dann Position nicht in Arbeitsvorrat enthalten
            gd_num_msgs_old = gd_num_msgs_new.
            "Nachricht darf nicht bei Rückmeldung für nächstes Objekt
                                       "auftauchen
          ELSE.
            objekt-flg_mltps = 'X'.
            PERFORM handle_status_wl
              USING
                objekt
                kpepw_objstat-error
                no.                    "changed
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Noch möglich: Check, daß alle Aufträge und Positionen in Arbeitsvorrat
* tatsächlich bearbeitet wurden. Ist nicht der Fall, wenn keine Stamm-
* daten vorhanden sind.

  DATA num_of_objs TYPE i.
  DESCRIBE TABLE t_auftrag LINES num_of_objs.
  IF num_of_objs > 0 AND sy-batch IS INITIAL.
    gd_pi_total = num_of_objs.
    CLEAR gd_pi_text.
    WRITE gd_pi_total TO gd_pi_text(8).
    WRITE text-pi1    TO gd_pi_text+8.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
              text = gd_pi_text.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM handle_message                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  value(msgid)                                                  *
*  -->  value(msgty)                                                  *
*  -->  value(msgno)                                                  *
*  -->  value(msgv1)                                                  *
*  -->  value(msgv2)                                                  *
*  -->  value(msgv3)                                                  *
*  -->  value(msgv4)                                                  *
*---------------------------------------------------------------------*
FORM handle_message
  USING
    objekt LIKE LINE OF t_auftrag
    "value: hide changes of system variables
    value(msgid) LIKE sy-msgid
    value(msgty) LIKE sy-msgty
    value(msgno) LIKE sy-msgno
    value(msgv1) "<- not typed because of stupid compiler
                                       "errors
    value(msgv2)                       "like sy-msgv2
    value(msgv3)                       "like sy-msgv3
    value(msgv4)                       "like sy-msgv4
  .

  DATA:
    version LIKE kkapara_vs,           "immer initial
    msgnr LIKE cmimsg-msgnr.

  PERFORM cm_f_set_object
    USING
      objekt
      version.

  msgnr = msgno.
  CALL FUNCTION 'CM_F_MESSAGE'
       EXPORTING
            arbgb            = msgid
            msgnr            = msgnr
            msgty            = msgty
            msgv1            = msgv1
            msgv2            = msgv2
            msgv3            = msgv3
            msgv4            = msgv4
            msg_on_screen    = no
            object_dependent = yes
            append_same_msg  = no.

*  gd_num_msgs_new = gd_num_msgs_new + 1.                      "187150
* Wert muß immer aus Messagehandler geholt werden, da wg.
* flexibler Fehlersteuerung Meldung möglicherweise nicht
* ausgegeben wird.
  CALL FUNCTION 'CM_F_INFO'                                 "187150
       EXPORTING
            all             = 'X'
            aplid           = abgr_aplid
            object          = abgr_object_id
       IMPORTING
            msg_counter_pro = gd_num_msgs_new
       EXCEPTIONS
            wrong_object_id = 0
            OTHERS          = 0.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM check_auftrag_bearbeiten                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  auftrag                                                       *
*  -->  bearbeiten                                                   *
*  -->  auft_nicht_bearbeiten                                        *
*---------------------------------------------------------------------*
FORM check_auftrag_bearbeiten
  USING
    auftrag LIKE LINE OF t_auftrag
  CHANGING
    bearbeiten TYPE kka_yes_no
    auft_nicht_bearbeiten TYPE t_auft_keys.

* Wird für einen nicht rückzumeldenden Auftrag genau
* einmal aufgerufen.
  READ TABLE auft_nicht_bearbeiten
     WITH KEY aufnr = auftrag-aufnr
     BINARY SEARCH
     TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    bearbeiten = no.
    DELETE auft_nicht_bearbeiten INDEX sy-tabix.
                                       "Eintrag hat Schuldigkeit getan
  ELSE.
* Auftragskopf wird rückgemeldet
    bearbeiten = yes.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM handle_not_relevant                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  value(msgid)                                                  *
*  -->  value(msgty)                                                  *
*  -->  value(msgno)                                                  *
*  -->  value(msgv1)                                                  *
*  -->  value(msgv2)                                                  *
*  -->  value(msgv3)                                                  *
*  -->  value(msgv4)                                                  *
*  -->  curr_object                                                   *
*---------------------------------------------------------------------*
FORM handle_not_relevant
  USING
    objekt LIKE LINE OF t_auftrag
  CHANGING
    auft_nicht_bearbeiten TYPE t_auft_keys.

  DATA:
    bearbeiten TYPE kka_yes_no,
      objnr TYPE j_objnr,
      msgid LIKE sy-msgid,
      msgty LIKE sy-msgty,
      msgno LIKE sy-msgno,
      msgv1,
      msgv2,                           "like sy-msgv2
      msgv3,                           "like sy-msgv3
      msgv4,                           "like sy-msgv4
      version   LIKE kkapara_vs.       "immer initial

  IF objekt-flg_mltps <> space AND objekt-posnr IS INITIAL.
* Auftragskopf Kuppelproduktion
    PERFORM check_auftrag_bearbeiten
      USING
        objekt
      CHANGING
        bearbeiten
        auft_nicht_bearbeiten.

    CHECK bearbeiten = yes.
* Keine Meldung für nicht relevante Auftragsköpfe bei Kuppelproduktion
* Beginning 187150
* Jetzt wird immer KJ154 ausgegeben für Auftragsköpfe bei Kuppelprodukt.
    msgid = 'KJ'.
    msgty = 'I'.
    msgno = '154'.
* End 187150
  ELSE.
    msgid = 'KJ'.
    msgty = 'I'.

    IF objekt-abgsl = space.
      msgno = 629.
    ELSEIF objekt-pkosa <> space.
      "Autrag PKOSA zugeordnet, trägt keine Kosten
      msgno = 813.
      msgv1 = objekt-pkosa.
    ELSEIF objekt-loekz <> space.
      msgno = 103.
      msgv1 = objekt-aufnr.
    ENDIF.
  ENDIF.

  IF objekt-flg_mltps <> space AND NOT objekt-objnp IS INITIAL.
    objnr = objekt-objnp.
  ELSE.
    objnr = objekt-objnr.
  ENDIF.
  PERFORM handle_not_rel_with_msg
    USING
      objnr objekt
      msgid msgty msgno msgv1 msgv2 msgv3 msgv4.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM handle_not_rel_with_msg                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  objnr                                                         *
*  -->  objekt                                                        *
*  -->  msgid                                                         *
*  -->  msgty                                                         *
*  -->  msgno                                                         *
*  -->  msgv1                                                         *
*  -->  msgv2                                                         *
*  -->  msgv3                                                         *
*  -->  msgv4                                                         *
*---------------------------------------------------------------------*
FORM handle_not_rel_with_msg
  USING
    objnr TYPE j_objnr
    objekt LIKE LINE OF t_auftrag
    msgid LIKE sy-msgid
    msgty LIKE sy-msgty
    msgno LIKE sy-msgno
    msgv1
    msgv2                              "like sy-msgv2
    msgv3                              "like sy-msgv3
    msgv4                              "like sy-msgv4
    .

  IF NOT msgid IS INITIAL AND withimsg = yes.
    IF objekt IS INITIAL.
      objekt-objnr = objnr.
    ENDIF.

    PERFORM handle_message
      USING
        objekt
        msgid 'I' msgno msgv1 msgv2 msgv3 msgv4.
  ENDIF.

  gd_not_relevant = gd_not_relevant + 1.
  objekt-objnr = objnr.
  CLEAR objekt-objnp.
  PERFORM handle_status_wl
    USING
      objekt
      kpepw_objstat-not_relevant
      no.                              "changed
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  HANDLE_STATUS_WL
*&---------------------------------------------------------------------*
FORM handle_status_wl USING
    p_auftrag TYPE kkapara_ta
    status TYPE kpep_wl_objstat
    p_changed TYPE kka_yes_no.
* Statusrückmeldung an Schedule-Manager-Worklists

  DATA msg_tab LIKE cmfmsg OCCURS 0.
  DATA kpep_obj_id TYPE kpep_wl_objectid.

  IF p_auftrag-objnp IS INITIAL OR p_auftrag-flg_mltps IS INITIAL.
    "Bei Kuppelprod. Nummer der Position nehmen
    kpep_obj_id = p_auftrag-objnr.
  ELSE.
    kpep_obj_id = p_auftrag-objnp.
  ENDIF.

  IF gd_num_msgs_new > gd_num_msgs_old.

    CALL FUNCTION 'CM_F_MESSAGES_GET'
         EXPORTING
              aplid                  = abgr_aplid
*         OBJECT                 = ' '
*         WITH_OBJECTINDEPENDENT = 'X'
         TABLES
              e_msgprot              = msg_tab
*    EXCEPTIONS
*         NOT_ACTIVE             = 1
*         OTHERS                 = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF gd_num_msgs_old > 0.
      DELETE msg_tab TO gd_num_msgs_old.
      "Nachrichten werden in der Reihenfolge ihres Auftretens abgelegt.
    "Es werden alle Nachrichten gelöscht, die nicht zum aktuellen Objekt
                                       "gehören.
    ENDIF.
    gd_num_msgs_old = gd_num_msgs_new.
  ENDIF.

* Beginning 4.6C: Unterobjektinfo wird auch an Arbeitsvorrat gegeben
  DATA:
    subobjects TYPE kpep_wl_subobject_ref OCCURS 0 WITH HEADER LINE,
    cmf_msg TYPE cmfmsg,
    subobject TYPE cmisubobjkk_general,
    subobjnr TYPE j_objnr.
  REFRESH subobjects[].
  LOOP AT msg_tab INTO cmf_msg.
    IF NOT cmf_msg-subobj IS INITIAL.
      subobject = cmf_msg-subobj.
      CALL FUNCTION 'K_OBJECT_KEY_FROM_PCOBJ_SET'
        EXPORTING
*      PAR_PCOBJ        =
          par_subobj       = subobject
        IMPORTING
          par_objnr        = subobjnr.
      subobjects-subobject = subobjnr.
      subobjects-tabix = sy-tabix.
      APPEND subobjects.
    ENDIF.
  ENDLOOP.
* End 4.6C

  CALL FUNCTION 'KPEP_WLA_SET_OBJECT_STATUS'
       EXPORTING
          object              = kpep_obj_id
          status              = status
*           ORIGINATING_OBJECTS =
       TABLES
*           SMSG_MESSAGES       =
          cmfe_messages       = msg_tab
          cmfe_subobjects     = subobjects       "4.6C
          .

  IF p_changed = yes.
    CALL FUNCTION 'KPEP_WLA_SET_OBJECT_CHANGED'
         EXPORTING
              object = kpep_obj_id.
  ENDIF.


ENDFORM.                               " HANDLE_STATUS_WL

*---------------------------------------------------------------------*
*       FORM get_param_tab                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  tab_param                                                     *
*---------------------------------------------------------------------*
FORM get_param_tab
  TABLES
    tab_param STRUCTURE kaba00.

  CLEAR tab_param.

  tab_param-option = 'EQ'.
  tab_param-sign = 'I'.
  tab_param-structure = 'KKAE_PARAM'.
  tab_param-type = 'P'.

  tab_param-field = 'ABGRMONA'.
  tab_param-low = abgrmona.
  APPEND tab_param.
  tab_param-field = 'ABGRJAHR'.
  tab_param-low = abgrjahr.
  APPEND tab_param.

  LOOP AT abgrvers.
    tab_param-field = 'ABGRVERS'.
    tab_param-low = abgrvers-low.
    APPEND tab_param.
  ENDLOOP.

  tab_param-structure = 'KKA0100'.
  tab_param-field = 'KOKRS'.
  tab_param-low = kokrs.
  APPEND tab_param.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM get_sel_tab                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  sel_tab                                                       *
*---------------------------------------------------------------------*
FORM get_sel_tab
  TABLES
    sel_tab STRUCTURE kaba00.

  IF kass = 'X'.
    CALL FUNCTION 'K_OBJECT_SELECTION_CRIT_GET'
      EXPORTING
        transparent       = 'X'
*   IMPORTING
*     VARIANT           =
      TABLES
        it_seltab         = sel_tab
    .
    LOOP AT sel_tab.
      CHECK sel_tab-structure IS INITIAL.
      sel_tab-structure = 'CODIA'.
      MODIFY sel_tab.
    ENDLOOP.
  ELSE.
    CHECK scma = yes.
* Nur bei Sammelverarbeitung Selektionsparameter ausgeben.
* Sind für Einzelverarbeitung nicht mehr verfügbar.
    sel_tab-structure = 'KKAPARA_TA'.
    sel_tab-field     = 'WERKS'.
    sel_tab-low       = abgrwerk-low.
    sel_tab-option     = abgrwerk-option.
    sel_tab-sign      = abgrwerk-sign.
    sel_tab-high      = abgrwerk-high.
    IF sel_tab-low = '*'.              "alle Werke übergeben als 'CP *'
      CLEAR sel_tab-option.
    ENDIF.
    APPEND sel_tab.

    sel_tab-structure = 'KKA0100'.
    IF NOT abgraufn IS INITIAL.                             "46B
      sel_tab-field     = 'AUFNR'.
      sel_tab-low       = abgraufn-low.
      sel_tab-option     = abgraufn-option.
      sel_tab-sign      = abgraufn-sign.
      sel_tab-high      = abgraufn-high.
      APPEND sel_tab.
    ENDIF.                                                  "46B
*
    sel_tab-field     = 'IFAUF'.
    sel_tab-low       = incfauft.
    CLEAR sel_tab-high.
    sel_tab-option     = 'EQ'.
    sel_tab-sign      = 'I'.
    APPEND sel_tab.
*
    sel_tab-field     = 'IKOSA'.
    sel_tab-low       = incpkosa.
    CLEAR sel_tab-high.
    sel_tab-option     = 'EQ'.
    sel_tab-sign      = 'I'.
    APPEND sel_tab.
*
    sel_tab-field     = 'IPAUF'.
    sel_tab-low       = incpiauf.
    CLEAR sel_tab-high.
    sel_tab-option     = 'EQ'.
    sel_tab-sign      = 'I'.
    APPEND sel_tab.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_BASE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_BASE_LST_EXTR  text
*----------------------------------------------------------------------*
FORM save_base_list CHANGING p_base_lst_extr.
  DATA repid LIKE sy-repid.

  repid = sy-repid.
  CALL FUNCTION 'OBJ_PROCESSING_LOG_SAVE'
       EXPORTING
            i_report       = repid
            i_log_data     = grundliste_data
       IMPORTING
            e_schedman_ext = p_base_lst_extr.

ENDFORM.                               " SAVE_BASE_LIST

*&---------------------------------------------------------------------*
*&      Form  SAVE_OBJECT_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_OBJ_LST_EXTR  text
*----------------------------------------------------------------------*
FORM save_object_list CHANGING p_obj_lst_extr.
  DATA repid LIKE sy-repid.
  DATA temp_extract TYPE disextract.

  repid = sy-repid.
  CALL FUNCTION 'OBJ_EXTRACT_NAME_CALCULATE'
     EXPORTING
          i_report         = repid
*          I_HANDLE         = 'LOG'
          i_sched_fbname   = 'WIP_DISPLAY_OBJ_LIST'
          i_sched_fbdelete = 'OBJ_PROCESSING_LOG_DELETE'
     IMPORTING
          e_extract      = temp_extract
     CHANGING
          c_schedman_ext = p_obj_lst_extr.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
       EXPORTING
            i_no_message = 'X'
            is_extract   = temp_extract
            i_exp01      = gs_layout
            i_exp02      = gs_variant
            i_exp03      = gs_hide
       TABLES
            it_exp01     = gt_field
            it_exp02     = gt_sort
            it_exp03     = gt_events
            it_exp04     = t_auftlst.


ENDFORM.                               " SAVE_OBJECT_LIST

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_OBJ_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_obj_list
  USING
    extract TYPE disextract.

  DATA:
    callback_prog LIKE sy-repid,
    callback_pf_status TYPE slis_formname,
    callback_ucomm TYPE slis_formname,
    ls_print TYPE slis_print_alv.

  ls_print-no_print_selinfos = 'X'.
  IF SY-BATCH = 'X'.                                         "HW883525
     LS_PRINT-PRINT = 'X'.                                   "HW883525
  ENDIF.                                                     "HW883525

* Check authorizations for plants and valuation type         "HW550211
*  perform AUTH_CHECK_PLANT_VALUTYP.                         "HW550211


  IF extract IS INITIAL.
    callback_prog = sy-repid.
    callback_pf_status = 'PF_STATUS_SET_INLIST'.
    callback_ucomm = 'USER_COMMAND_INLIST'.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
         EXPORTING
              is_extract = extract
         TABLES
              et_exp01   = gt_field
              et_exp02   = gt_sort
              et_exp03   = gt_events
              et_exp04   = t_auftlst
         CHANGING
              c_exp01    = gs_layout
              c_exp02    = gs_variant
              c_exp03    = gs_hide
         EXCEPTIONS
              not_found  = 1.
    REFRESH gt_events.
    IF sy-subrc = 1.
      MESSAGE s001(k_obj0) RAISING not_found.
    ENDIF.
    SET TITLEBAR 'REP' OF PROGRAM 'SAPKKA07'.
  ENDIF.

* Beginning note 396282
  IF sy-binpt = 'X'.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
        EXPORTING
             i_callback_program       = callback_prog
             i_callback_pf_status_set = callback_pf_status
             i_callback_user_command  = callback_ucomm
             is_layout                = gs_layout
             it_fieldcat              = gt_field
             it_sort                  = gt_sort
             is_sel_hide              = gs_hide
             i_save                   = 'A'
             is_print                 = ls_print
             is_variant               = gs_variant
             it_events                = gt_events
        IMPORTING
             es_exit_caused_by_user   = gs_exitcause
        TABLES
             t_outtab                 = t_auftlst
        EXCEPTIONS
             OTHERS                   = 0.
  ELSE.
* End note 396282
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'  "M_46A_SCMA
        EXPORTING
             i_buffer_active = ' '                          "46C
* Keine Pufferung wg. diverser ALV-Fehler
             i_callback_program       = callback_prog
             i_callback_pf_status_set = callback_pf_status
             i_callback_user_command  = callback_ucomm
*             i_callback_top_of_page   = 'TOP_OF_PAGE_INLIST'   "event
*             i_tabname                = 'T_AUFTLST'
             is_layout                = gs_layout
             it_fieldcat              = gt_field
*             i_fctype                 = 'R'
*            i_default_status         = ' ' "eigener Status "P30K074456
             it_sort                  = gt_sort
             is_sel_hide              = gs_hide
             i_save                   = 'A'                       "I40C
             is_print                 = ls_print                 "I_46A
             is_variant               = gs_variant           "I40C_Vari
             it_events                = gt_events                 "I40C
        IMPORTING
             es_exit_caused_by_user   = gs_exitcause        "ok
        TABLES
             t_outtab                 = t_auftlst           "
*        EXCEPTIONS
*             OTHERS                   = 1
        .
  ENDIF.                                                        "396282
ENDFORM.                               " DISPLAY_OBJ_LIST
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_PLANT_VALUTYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTH_CHECK_PLANT_VALUTYP using                      "HW550211
                               auth_plant_missing type c "HW550211
                               auth_valu_missing type c. "HW550211

* Declarations
**************
* Help table to register all existing plants
  types: begin of ts_plants,
           werks type werks_d,
           auth type c,
         end of ts_plants.
  data: ls_plants type ts_plants,
        lt_plants type standard table of ts_plants.

* Help table to register all existing valuation types
  types: begin of ts_valutyp,
          valutyp type TKKAP-VALUTYP,
          auth type c,
         end of ts_valutyp.
  data: ls_valutyp type ts_valutyp,
        lt_valutyp type standard table of ts_valutyp.

* Work area for table t_auftlst
  data: s_auftlst type KKAPARA_TA.

* Work area for field catalogue
  data: s_fieldcat type SLIS_FIELDCAT_ALV.

* Help fields
  data: l_t_auftlst_modified type c,
        l_tp_auth type c,
        l_auth_plant_missing type c,
        l_auth_valu_missing type c,
        help_index type sy-tabix.



**************Processing**********************************************

*********************************
* Authorization Check for plants*
*********************************

  clear s_auftlst.
  clear l_t_auftlst_modified.

  clear l_auth_plant_missing.
  clear l_auth_valu_missing.

  loop at t_auftlst into s_auftlst.    "START OF LOOP AT T_AUFTLST


    clear ls_plants.
    read table lt_plants into ls_plants
                           with key
                           werks = s_auftlst-werks.

    if sy-subrc is initial.

      if ls_plants-auth is initial.
        s_auftlst-wrt = 0.
        s_auftlst-wrtk = 0.
        s_auftlst-wrt_upd = 0.
        s_auftlst-no_auth_plant = 'X'.

        modify t_auftlst from s_auftlst.

*.......register that authority for plant is missing
        l_auth_plant_missing = 'X'.
*.......register that table t_auftlst was modified
        l_t_auftlst_modified = 'X'.

      endif.

    else.
      AUTHORITY-CHECK OBJECT 'K_WIP'
          ID 'WERKS' FIELD s_auftlst-werks
          ID 'ACTVT' FIELD '03'.

      ls_plants-werks = s_auftlst-werks.

      if sy-subrc is initial.
        ls_plants-auth = 'X'.
      else.
        ls_plants-auth = ' '.
      endif.

      if ls_plants-auth is initial.
        s_auftlst-wrt = 0.
        s_auftlst-wrtk = 0.
        s_auftlst-wrt_upd = 0.
        s_auftlst-no_auth_plant = 'X'.


        modify t_auftlst from s_auftlst.

*.......register that authority for plant is missing
        l_auth_plant_missing = 'X'.
*.......register that table t_auftlst was modified
        l_t_auftlst_modified = 'X'.

      endif.

      append ls_plants to lt_plants.


    endif.


*****************************************
* Authorization Check for valuation type*
*****************************************


    clear ls_valutyp.
    read table lt_valutyp into ls_valutyp
                     with key
                       valutyp = s_auftlst-valutyp.

    if sy-subrc is initial.
      if ls_valutyp-auth is initial.
        s_auftlst-wrt = 0.
        s_auftlst-wrtk = 0.
        s_auftlst-wrt_upd = 0.
        s_auftlst-no_auth_valutyp = 'X'.


        modify t_auftlst from s_auftlst.

*.......register that authority for valuation type is missing
        l_auth_valu_missing = 'X'.
*.......register that table t_auftlst was modified
        l_t_auftlst_modified = 'X'.

      endif.

    else.
      CALL FUNCTION 'TP_VALUATION_AUTHORITY'
           EXPORTING
                I_VALUTYP                      = s_auftlst-valutyp
                I_WERKS                        = s_auftlst-werks
                I_ACTVT                        = '03'
           IMPORTING
                E_XAUTH                        = l_tp_auth
           EXCEPTIONS
                KOKRS_FINDING_ERROR            = 1
                VALUTYP_FINDING_ERROR          = 2
                INSUFFICIENT_INPUT_FOR_KOKRS   = 3
                INSUFFICIENT_INPUT_FOR_VALUTYP = 4
                ACTIVITY_NOT_ALLOWED           = 5
                OTHERS                         = 6.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      ls_valutyp-valutyp = s_auftlst-valutyp.

      if l_tp_auth is initial.
        ls_valutyp-auth = ' '.
      else.
        ls_valutyp-auth = 'X'.
      endif.

      if ls_valutyp-auth is initial.
        s_auftlst-wrt = 0.
        s_auftlst-wrtk = 0.
        s_auftlst-wrt_upd = 0.
        s_auftlst-no_auth_valutyp = 'X'.

        modify t_auftlst from s_auftlst.

*.......register that authority for valuation type is missing
        l_auth_valu_missing = 'X'.
*.......register that table t_auftlst was modified
        l_t_auftlst_modified = 'X'.

      endif.

      append ls_valutyp to lt_valutyp.

    endif.


  endloop.                             "END OF LOOP AT T_AUFTLST


* Check whether table t_auftlst was modified -
* if yes: -> information message will be issued
*         -> field catalogue needs to be adjusted

  if not l_t_auftlst_modified is initial.

* info message:
* "Fehlende Berechtigungen => Werte der betr. Objekte werden
*  auf 0 gesetzt"
    MESSAGE i822(kj).


* Adjust field catalogue...
*    Clear s_fieldcat.
*    Clear help_index.

*    loop at gt_field into s_fieldcat.
*
** If authority for plant is missing, field WERKS needs to be shown...
*      if s_fieldcat-fieldname = 'WERKS'
*         AND l_auth_plant_missing = 'X'.
*        clear s_fieldcat-no_out.
*
*        modify gt_field from s_fieldcat.
*
*
** If authority for plant is missing, field NO_AUTH_PLANT needs to
** be shown...
*      elseif s_fieldcat-fieldname = 'NO_AUTH_PLANT'
*         AND l_auth_plant_missing = 'X'.
*        clear s_fieldcat-no_out.
*
*        modify gt_field from s_fieldcat.
*
*
** If authority for valuation type is missing, field NO_AUTH_VALUTYP
** needs to be shown...
*      elseif s_fieldcat-fieldname = 'NO_AUTH_VALUTYP'
*         AND l_auth_valu_missing = 'X'.
*        clear s_fieldcat-no_out.
*
*
*        modify gt_field from s_fieldcat.
*        help_index = sy-tabix.
*
*
*      endif.
*
*    endloop.
*
** Field VALUTYP (Valuation type) which usually is not part of the
** fieldcatalogue (only in certain cases) needs to be shown, too,
** but only if authority for valuation type is mising
*    if l_auth_valu_missing = 'X'.
*
*    CLEAR s_fieldcat.
*    s_fieldcat-FIELDNAME     = 'VALUTYP'.
*    s_fieldcat-REF_TABNAME   = 'KKAPARA_TA'.
*    s_fieldcat-DDICTXT       = 'S'.
**    s_fieldcat-OUTPUTLEN     = 1.
*    s_fieldcat-NO_SUM        = 'X'.
*    s_fieldcat-lzero         = 'X'."without this the valuation
*                                   "type 0 would not be shown
*
*    insert s_fieldcat into gt_field index help_index.
*    endif.
*
  endif.



* Collect message for protocol that display of data for a certain
* plant is not allowed

  loop at lt_plants into ls_plants
                  where auth = ' '.

    CALL FUNCTION 'CM_F_MESSAGE'
         EXPORTING
              ARBGB = 'KJ'
              MSGNR = '823'
              MSGTY = 'I'
              MSGV1 = ls_plants-werks.

  endloop.

* Collect message for protocol that display of data for a certain
* valuation type is not allowed
  loop at lt_valutyp into ls_valutyp
                      where auth = ' '.

    CALL FUNCTION 'CM_F_MESSAGE'
         EXPORTING
              ARBGB = 'KJ'
              MSGNR = '824'
              MSGTY = 'I'
              MSGV1 = ls_valutyp-valutyp
              MSGV2 = kokrs.

  endloop.

* Filling of USING parameters                             "HW550211
auth_plant_missing = l_auth_plant_missing.                "HW550211
auth_valu_missing = l_auth_valu_missing.                  "HW550211

ENDFORM.                               " AUTH_CHECK_PLANT_VALUTYP