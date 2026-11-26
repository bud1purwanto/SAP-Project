* ALRK021105/4.0 : Aufruf Erklärungskompontente
* P30K049339/3.0D: Include neu für Exit-Routinen des List-Tools
* P30K090659/3.0F: I-Meldung bei Berichtsaufruf aus Testlauf-Liste
* 4.0C: Listenkopf nur am Anfang, falls ausgedruckt + Aufbau verbessert
*-------------------------------------------------------------------
***INCLUDE KKA07F02 .
*-------------------------------------------------------------------

* Beginning 46C: neue Grundliste in OO
CLASS my_obj_processing_log DEFINITION
    INHERITING FROM cl_obj_processing_log.
  PUBLIC SECTION.
    METHODS:
      event_message_clicked REDEFINITION,
      event_pbo REDEFINITION,
      event_pai REDEFINITION.

ENDCLASS.                    "my_obj_processing_log  DEFINITIO


*---------------------------------------------------------------------*
*       CLASS lcl_My_OBJ_PROCESSING_LOG IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS my_obj_processing_log IMPLEMENTATION.
  METHOD event_message_clicked.
    SET TITLEBAR 'PRO'.
    CALL FUNCTION 'CM_F_DISPLAY_LOG'
      EXPORTING
        aplid            = abgr_aplid
        grid_display     = 'X'
        only_msgtyp      = im_only_msgtyp
        no_statistic     = 'X'
        skip_info_screen = 'X'
      EXCEPTIONS
        not_active       = 0.
*    SET TITLEBAR 'GRU'.
  ENDMETHOD.                    "event_message_clicked
  METHOD event_pbo.
    DATA extab TYPE slis_t_extab.
    SET TITLEBAR 'GRU'.
    IF msg_nr = 0.
      APPEND 'PROT' TO extab.
    ENDIF.
    SET PF-STATUS 'GRUNDLISTE' EXCLUDING extab.
  ENDMETHOD.                    "event_pbo
  METHOD event_pai.
    IF sy-ucomm = 'PROT'.
      SET TITLEBAR 'PRO'.
      CALL FUNCTION 'CM_F_DISPLAY_LOG'
        EXPORTING
          aplid            = abgr_aplid
          grid_display     = 'X'
          skip_info_screen = 'X'
        EXCEPTIONS
          not_active       = 0.
    ELSE.
      CALL METHOD super->event_pai.
    ENDIF.
  ENDMETHOD.                    "event_pai
ENDCLASS.                    "my_obj_processing_log IMPLEMENTATION
* End 46C

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_INLIST
*&---------------------------------------------------------------------*
* Exit-Routine, vom List-FB zum Zeitpunkt TOP-OF-PAGE aufgerufen       *
* Zu 4.0C: Nur TOP_OF_LIST aufgerufen!
*----------------------------------------------------------------------*
FORM top_of_page_inlist.

  DATA:  ld_valutext(25)   TYPE c.
  DATA:  gd_alv_listheader TYPE slis_t_listheader.
  DATA:  wa_line           TYPE slis_listheader.
  DATA:  header            TYPE slis_listheader-info,
         content           TYPE slis_listheader-info.

  CLEAR: header, content, wa_line.
  REFRESH gd_alv_listheader.

  CONCATENATE text-wip text-grl INTO header SEPARATED BY space.

  wa_line-typ  = 'H'.
  wa_line-info = header.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR wa_line.

  CONCATENATE abgrmona abgrjahr INTO content SEPARATED BY space.

  wa_line-typ  = 'S'.
  wa_line-key  = text-per.
  wa_line-info = content.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR: content, wa_line.

*  FORMAT INTENSIFIED.
*  NEW-LINE NO-SCROLLING.
*  write:   text-wip color col_heading, text-grl color col_heading.
*  WRITE: (30) text-per, abgrmona INTENSIFIED OFF LEFT-JUSTIFIED,
*                        abgrjahr INTENSIFIED OFF LEFT-JUSTIFIED.
*  NEW-LINE.
** Ausgabe der Version im Kopf, plus mögl. referenzierender Versionen
  IF gd_nr_opvers EQ 1.
**   Über eine Version eingestiegen
*    WRITE: (30) text-vrs, abgrvers-low INTENSIFIED OFF LEFT-JUSTIFIED.

    IF NOT gd_cvact IS INITIAL.
**     operativ dazuschreiben
*      WRITE: (14) text-bwo INTENSIFIED OFF LEFT-JUSTIFIED.
      CONCATENATE abgrvers-low text-bwo
                  INTO content SEPARATED BY space.
**     Parallele Bewertung, Bewertung anzeigen
      LOOP AT abgr_vsn.
        IF abgr_vsn-versa EQ abgrvers-low.
          PERFORM get_valutext
             USING abgr_vsn-valutyp ld_valutext.
*         WRITE: ld_valutext INTENSIFIED OFF LEFT-JUSTIFIED.
          CONCATENATE content ld_valutext
                   INTO content SEPARATED BY space.
        ENDIF.
      ENDLOOP.
      wa_line-typ  = 'S'.
      wa_line-key  = text-vrs.
      wa_line-info = content.
      APPEND wa_line TO gd_alv_listheader.
      CLEAR: content, wa_line.

      LOOP AT abgr_vsn.
        IF abgr_vsn-versa NE abgrvers-low.
*         NEW-LINE NO-SCROLLING.
*         WRITE: (30) text-vrz, abgr_vsn-versa
*         INTENSIFIED OFF LEFT-JUSTIFIED.
          PERFORM get_valutext
             USING abgr_vsn-valutyp ld_valutext.
*         WRITE: (14) ' ', ld_valutext INTENSIFIED OFF LEFT-JUSTIFIED.
          CONCATENATE abgr_vsn-versa ld_valutext
                   INTO content SEPARATED BY space.
          wa_line-typ  = 'S'.
          wa_line-key  = text-vrz.
          wa_line-info = content.
          APPEND wa_line TO gd_alv_listheader.
          CLEAR: content, wa_line.
        ENDIF.
      ENDLOOP.
**    abgr_vsn = abgr_vsn.
    ENDIF.
  ENDIF.
** Ausgabe Nachrichten-Zahl und Maximale Fehlerschwere
  IF anzeigen IS INITIAL.
**  Keine Nachrichten im Anzeige-Modus vorhanden
*   SKIP.
*   NEW-LINE NO-SCROLLING.
*   WRITE:  (30) text-mnr,
*           msg_nr HOTSPOT INTENSIFIED OFF LEFT-JUSTIFIED.
    wa_line-typ  = 'S'.
    wa_line-key  = text-mnr.
    WRITE msg_nr TO wa_line-info LEFT-JUSTIFIED.
    APPEND wa_line TO gd_alv_listheader.
    CLEAR: wa_line.
    IF msg_nr GT 0.
      NEW-LINE NO-SCROLLING.
      PERFORM get_msgtyp_text
         USING max_msg
               gd_msgtyptext.
*      WRITE:  (30) text-mmx,
*              max_msg HOTSPOT INTENSIFIED OFF LEFT-JUSTIFIED,
*              gd_msgtyptext HOTSPOT INTENSIFIED OFF LEFT-JUSTIFIED.
      CONCATENATE max_msg gd_msgtyptext
                  INTO content SEPARATED BY space.
      wa_line-typ  = 'S'.
      wa_line-key  = text-mmx.
      wa_line-info = content.
      APPEND wa_line TO gd_alv_listheader.
      CLEAR: content, wa_line.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gd_alv_listheader[].

* FORMAT INTENSIFIED OFF.
* SKIP.
ENDFORM.                               " TOP_OF_PAGE_INLIST


DATA: gd_custom_container TYPE REF TO cl_gui_custom_container."46C

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_INLIST
*&---------------------------------------------------------------------*
*  Exit-Routine, vom List-FB zum Zeitpunkt USER-COMMAND aufgerufen     *
*----------------------------------------------------------------------*
*  -->  ucomm     Ausgelöster Funktionscode
*  -->  selfield  Struktur mit Infos zur Cursorposition
*----------------------------------------------------------------------*
FORM display_grundliste.
* Beginning modification note 387070
  IF sy-batch = yes.
*...Begin of note 626249 ...............................................
*   if sy-cprog = 'SAPKKA07'.                                   "H679133
    IF current_source_id = s_id_sapkka07.                   "H679133
      DATA valid(1) TYPE c.
      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          report                 = 'SAPKKA07'               "H679133
          no_dialog              = 'X'
          mode                   = 'CURRENT'                "H679133
        IMPORTING
          out_parameters         = pri_para
          out_archive_parameters = arc_para
          valid                  = valid.
*.....Begin of note 679133 .............................................
      IF NOT valid = 'X'.
        CALL FUNCTION 'GET_PRINT_PARAMETERS'
          EXPORTING
            report                 = 'SAPKKA07'
            no_dialog              = 'X'
          IMPORTING
            out_parameters         = pri_para
            out_archive_parameters = arc_para
            valid                  = valid.
      ENDIF.
*.....End of note 679133 ...............................................
      CHECK valid = 'X'.
    ENDIF.
*...End of note 626249 .................................................
    IF NOT ( pri_para IS INITIAL AND arc_para IS INITIAL ).
*     SAPKKA07 called via "SUBMIT" (SAPKKA07BG, SAPKKA07COBG, ...)
      NEW-PAGE PRINT ON
                        PARAMETERS         pri_para
                        ARCHIVE PARAMETERS arc_para
                        NO DIALOG.
    ENDIF.
    PERFORM write_log(saplobj1_processing_log) USING grundliste_data.
*   Begin note 805868
    IF NOT ( pri_para IS INITIAL AND arc_para IS INITIAL ).
      NEW-PAGE PRINT OFF .
    ENDIF.
*   End of note 805868
    IF sy-primm = 'X'.
      MESSAGE s374(sy) WITH sy-spono sy-pdest.
    ELSE.
      MESSAGE s355(sy) WITH sy-spono.
    ENDIF.
  ELSE.
*   Container erzeugen
    CREATE OBJECT gd_custom_container
      EXPORTING
        container_name = 'OBJ_LOG_CONTAINER'. "don't change!

*   Grundliste erstellen
    DATA: grundliste TYPE REF TO my_obj_processing_log.
    CREATE OBJECT grundliste
      EXPORTING
        im_parent  = gd_custom_container
        im_log_data = grundliste_data.

    CALL FUNCTION 'OBJ_PROCESSING_LOG_DYNPRO'
      EXPORTING
        im_container = gd_custom_container.
  ENDIF.
* End modification note 387070
ENDFORM.                    "display_grundliste

*---------------------------------------------------------------------*
*       FORM USER_COMMAND_INLIST                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  UCOMM                                                         *
*  -->  SELFIELD                                                      *
*---------------------------------------------------------------------*
FORM user_command_inlist
          USING ucomm    LIKE sy-ucomm
                selfield TYPE slis_selfield.
*                selfield type kkblo_selfield.

  DATA  BEGIN OF t_kv012 OCCURS 1.                          "ALRK021105
          INCLUDE STRUCTURE kv012.                          "ALRK021105
  DATA: END OF t_kv012.                                     "ALRK021105
  DATA  BEGIN OF t_kpzp1 OCCURS 1.                          "ALRK021105
          INCLUDE STRUCTURE kpzp1.                          "ALRK021105
  DATA: END OF t_kpzp1.                                     "ALRK021105
  DATA: kv014 LIKE kv014.                                   "ALRK021105

  DATA: ld_auftlst TYPE kkapara_ta,      "BADI WIP at Actual Costs (ML)
        ld_gjahr TYPE gjahr,
        ld_perio TYPE co_perio,
        ld_message TYPE xfeld.

* Hotspot behandeln
*  IF UCOMM EQ '&IC1'.                                             "46B
*    IF SELFIELD-SEL_TAB_FIELD EQ 'MSG_NR' OR                      "46B
*       SELFIELD-SEL_TAB_FIELD EQ 'MAX_MSG' OR                     "46B
*       SELFIELD-SEL_TAB_FIELD EQ 'GD_MSGTYPTEXT'.                 "46B
*     Protokoll-Aufruf
*      UCOMM = 'PROT'.                                             "46B
*    ENDIF.                                                        "46B
*  ENDIF.                                                          "46B
  CASE ucomm.
    WHEN 'GRUND'.
      CLEAR ucomm.                                          "I_46A_SCMA
      PERFORM display_grundliste.
    WHEN 'PROT'.
      CLEAR ucomm.
      SET TITLEBAR  'PRO'.
      CALL FUNCTION 'CM_F_DISPLAY_LOG'                      "M_46A
           EXPORTING
                grid_display = 'X'                          "I_46A
                aplid = abgr_aplid.
*               HEADLINE           = ' '
*               OCS_ACTIV          = ' '
*               OCS_SEND_IMMEDIATE = ' '
*          exceptions
*               not_active         = 01.
    WHEN 'PROTO'.
      DATA: filter LIKE cmiobjkka OCCURS 1 WITH HEADER LINE.

      CLEAR ucomm.
      CHECK msg_nr > 0.
      "Wenn keine Meldungen da, Doppelklick ignorieren.
      READ TABLE t_auftlst INDEX selfield-tabindex.
      IF sy-subrc <> 0.
        MESSAGE e039(0k).
      ENDIF.
      SET TITLEBAR  'PRO'.
      MOVE-CORRESPONDING t_auftlst TO filter.
      filter-aufnr = t_auftlst-objid.
      filter-versa = t_auftlst-versn.
      APPEND filter.
      CALL FUNCTION 'CM_F_DISPLAY_LOG'
        EXPORTING
          aplid                  = abgr_aplid
          skip_info_screen       = 'X'
          with_objectindependent = ' '
          object                 = 'X'
          grid_display           = 'X'
        TABLES
          i_object_filter        = filter.
    WHEN 'KRKS'.
      CALL FUNCTION 'K_KOKRS_SET'
        EXPORTING
          display  = ' '
          i_kokrs  = kokrs
          popup    = '1'         "Popup immer anzeigen
        IMPORTING
          e_kokrs  = kokrs
          e_action = aktion.
*            EXCEPTIONS NOT_FOUND = 01.
      IF aktion EQ 'E'.
        LEAVE.
      ENDIF.
* Beginning 46C: Neuer WIP-Bericht
    WHEN 'REPO'.
      IF NOT simulati IS INITIAL.
        MESSAGE i801(kj).
*    Daten des Berichts können von dem im Testlauf erm. Daten abweichen
      ENDIF.
      READ TABLE t_auftlst INDEX selfield-tabindex.
      IF sy-subrc = 0.

        IF t_auftlst-no_auth_plant = 'X' OR                 "HW584600
           t_auftlst-no_auth_valutyp = 'X'.                 "HW584600
          MESSAGE i825(kj).                                 "HW584600
          EXIT.                                             "HW584600
        ENDIF.                                              "HW584600

        DATA:
          periods TYPE kkb_time_range,
          kkb_posnr(4) TYPE c.

        DATA: l_cc_curr_in_obj_curr,                        "H548147
              l_pivot TYPE kkb_pivot.                       "H548147

* Pass default currency of WIP calculation to WIP report       "H548147
********************************************************       "H548147
        CLEAR: l_pivot,                                     "H548147
               l_cc_curr_in_obj_curr.                       "H548147

*       Default currency is controlling area curr. -> 'K' is   "H548147
*       passed to Report                                       "H548147
        IF p_cccurr IS INITIAL.                             "H548147
          l_pivot-currency_type = 'K'.                      "H548147

*       Default currency is comp. code currency                "H548147
        ELSE.                                               "H548147

*       Since the comp. code curr. can be found either in the  "H548147
*       controlling area fields or in the object curr. fields  "H548147
*       in dependence of settings in the controlling area, the "H548147
*       proper source needs to be determined:                  "H548147

          CALL FUNCTION 'KKA_CHECK_CC_CURR_IN_OBJ_CURR'     "H548147
            EXPORTING                                       "H548147
              i_co_area               = kokrs               "H548147
           IMPORTING                                        "H548147
              cc_curr_in_obj_curr     = l_cc_curr_in_obj_curr."H548147

*          l_cc_curr_in_obj_curr is intial ->                  "H548147
*          comp.code curr. needs to be read from contr.        "H548147
*          area crr. fields                                    "H548147
          IF l_cc_curr_in_obj_curr IS INITIAL.              "H548147
            l_pivot-currency_type = 'K'.                    "H548147
          ELSE.                                             "H548147
            l_pivot-currency_type = 'O'.                    "H548147
          ENDIF.                                            "H548147

        ENDIF.                                              "H548147

        periods-perio1 = von_per.
        periods-perio2 = bis_per.
        periods-gjahr1 = von_jahr.
        periods-gjahr2 = bis_jahr.
        periods-kumul = 'X'.
        IF t_auftlst-posnr = 0.
          CLEAR kkb_posnr.
        ELSE.
          kkb_posnr = t_auftlst-posnr.
        ENDIF.
        CALL FUNCTION 'K_KKB_KKBCS_ORDER_REPORT'
          EXPORTING
            i_aufnr                = t_auftlst-aufnr
*           I_CONTAINER            =
            i_time_range           = periods
            i_pivot                = l_pivot                "H548147
*           I_ROLLD                =
            i_posnr                = kkb_posnr
*           I_NINCL                =
*           I_VARIA                = '&SAP03' "Variante für WIP-Bericht
            i_wip                  = 'X'
          EXCEPTIONS
            object_not_found       = 1
            no_data                = 2
            no_authority           = 3
            OTHERS                 = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ELSE.
        MESSAGE e039(0k).
      ENDIF.
* End 46C
    WHEN '3BEB'.  "Aufruf der Bericht-Bericht-Schnittstelle (int.Fcode)
      IF NOT simulati IS INITIAL.
        MESSAGE i801(kj).
*    Daten des Berichts können von dem im Testlauf erm. Daten abweichen
      ENDIF.
*     ucomm = 'BEB3'.  "auf dem Listtool bekannten Fcode umsetzen
      ucomm = '&EB3'.  "Fcode umsetzen (nach Umstellung auf REUSE-ALV)
    WHEN 'ZWIP'.
      READ TABLE t_auftlst INDEX selfield-tabindex.
      IF sy-subrc IS INITIAL.

        IF t_auftlst-no_auth_plant = 'X' OR                 "HW584600
          t_auftlst-no_auth_valutyp = 'X'.                  "HW584600
          MESSAGE i825(kj).                                 "HW584600
          EXIT.                                             "HW584600
        ENDIF.                                              "HW584600

        IF t_auftlst-abart EQ 'S'.
*         Erklärungs-Tool nur für Sollkosten-WIP
          CALL FUNCTION 'K_WIP_OBJECT_CALC'
            EXPORTING
              par_gjahr              = abgrjahr
              par_knach              = ' '
              par_kokrs              = kokrs
              par_objnr              = t_auftlst-objnr
              par_poper              = abgrmona
              par_safnr              = ' '
              par_auflo              = t_auftlst-par_auflo
              par_awbva              = t_auftlst-bwvar
              par_plako              = 'X'
              par_awvsb              = t_auftlst-versn"40C
            IMPORTING
              par_kv014              = kv014
            TABLES
              pta_kv012              = t_kv012
              pta_kpzp1              = t_kpzp1
            EXCEPTIONS
              targetcosts_impossible = 01             "46A
              system_error           = 02             "46A
              OTHERS                 = 03.            "46A
          IF sy-subrc <> 0.                                 "46A
            MESSAGE e814(kj) WITH t_auftlst-objid.          "46A  "M46B
          ELSE.                                             "46A
            CALL FUNCTION 'K_WIP_EXPLAIN'
              EXPORTING
                kkapara_ta = t_auftlst
                abgrjahr   = abgrjahr
                abgrmona   = abgrmona
                abgrkokr   = kokrs
                kv014      = kv014
                curr_bukrs = p_cccurr
              TABLES
                t_kv012    = t_kv012
                t_kpzp1    = t_kpzp1.
          ENDIF.
        ELSEIF t_auftlst-abart EQ 'F'.
          MESSAGE e806(kj) WITH t_auftlst-objid.            "M46B
*         WIP-Erklärung ist nur bei Bewertung zu Sollkosten verfügbar
        ELSE.
          MESSAGE e807(kj) WITH t_auftlst-objid.            "M46B
*         WIP wurde aufgelöst.                                     "M46B
        ENDIF.
      ELSE.
*        MESSAGE E004(0K).                                          "46B
*       Cursor auf Listkörper pos.
        MESSAGE e039(0k).                                   "46B
      ENDIF.
    WHEN 'ZMLWIPDOC'.
*     BADI WIP at Actual Costs (ML)
      IF badi_act_active = 'X'.
        READ TABLE t_auftlst INDEX selfield-tabindex INTO ld_auftlst.
        IF NOT ld_auftlst-objnr IS INITIAL.
          IF NOT simulati IS INITIAL.
            LOOP AT t_auftlst TRANSPORTING NO FIELDS
              WHERE objnr <> ld_auftlst-objnr.
            ENDLOOP.
            IF sy-subrc = 0.
              ld_message = 'X'.
            ENDIF.
          ENDIF.
          IF ld_message = 'X'.
            MESSAGE s850(kj).
          ELSE.
            ld_perio = abgr_period-m.
            ld_gjahr = abgr_period-j.
            CALL METHOD badi_act_instance->co_wip_document_show
              EXPORTING
                objnr              = ld_auftlst-objnr
                gjahr              = ld_gjahr
                perio              = ld_perio
                test               = simulati
              EXCEPTIONS
                document_not_found = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                               " USER_COMMAND_INLIST
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET_INLIST
*&---------------------------------------------------------------------*
*  Exit-Routine, vom List-FB gerufen, wenn Standard-Ofl gesetzt würde  *
*----------------------------------------------------------------------*
*  -->  extab    Tabelle der Funktionscode, die in der Standard-Ofl
*                ausgeblendet würden.
*----------------------------------------------------------------------*
FORM pf_status_set_inlist
         USING extab TYPE slis_t_extab.
*         using extab type kkblo_t_extab.

  DATA:
    ld_pfkey LIKE sy-pfkey,
    lt_extab TYPE slis_t_extab.

  MOVE extab TO lt_extab.

  IF anzeigen IS INITIAL.
    ld_pfkey = 'OBJEKTLISTE'.
    SET TITLEBAR 'ERM'.
    IF msg_nr = 0.
      APPEND 'PROT' TO lt_extab.
      APPEND '&IC1' TO lt_extab.                            "46B
    ENDIF.
  ELSE.
    ld_pfkey = 'WIP_ANZ'.
    SET TITLEBAR 'ANZ'.
  ENDIF.
  IF badi_act_active IS INITIAL.
    APPEND 'ZMLWIPDOC' TO lt_extab.
  ENDIF.
  SET PF-STATUS ld_pfkey EXCLUDING lt_extab.
ENDFORM.                               " PF_STATUS_SET_INLIST


*---------------------------------------------------------------------*
*       FORM create_grundliste                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  sel_params                                                    *
*  -->  testlauf                                                      *
*  -->  kass_active                                                   *
*  -->  num_ok                                                        *
*  -->  num_error                                                     *
*  -->  num_not_relevant                                              *
*---------------------------------------------------------------------*
FORM create_grundliste
  TABLES
    sel_params STRUCTURE kaba00
  USING
    anzeigen TYPE kka_yes_no                                "378155
    testlauf TYPE kka_yes_no
    kass_active TYPE kka_yes_no
    num_ok TYPE i
    num_error TYPE i
    num_not_relevant TYPE i.

  DATA:
    test_flag(2) TYPE c VALUE '99',
    verarb_art_datel LIKE dcobjdef-name,
    result_text_datel TYPE doku_obj.

  IF testlauf = yes AND anzeigen = no.                      "378155
    test_flag = yes.
  ELSE.
    test_flag = no.
  ENDIF.

  IF anzeigen = yes.                                        "378155
    verarb_art_datel = 'OBJ_LOG_MODE_WIP_SHOW'.             "378155
  ELSE.                                                     "378155
    verarb_art_datel = 'OBJ_LOG_MODE_WIP'.
  ENDIF.                                                    "378155

  IF num_error > 0.
    result_text_datel = 'OBJ_LOG_WITH_ERRORS'.
  ENDIF.

  CALL FUNCTION 'OBJ_PROCESSING_SET_PARAMETERS'
       EXPORTING
            i_kass_import                = kass_active
            i_mode_rollname              = verarb_art_datel
            i_test                       = test_flag
*           MSG_COUNTER_I                =
*           MSG_COUNTER_W                =
*           MSG_COUNTER_E                =
*           MSG_COUNTER_A                =
            msg_applid                   = abgr_aplid
            result_text_name             = result_text_datel
            stat_ok                      = num_ok
            stat_not_relevant            = num_not_relevant
*           STAT_MINOR_ERROR             = 99999999
*           STAT_FOLLOWUP_ERROR          = 99999999
*           STAT_HIERARCHY_ERROR         = 99999999
            stat_error                   = num_error
*           STAT_OK_ZERO_ROLL            =
*           STAT_NOT_RELEVANT_ROLL       =
*           STAT_NOT_RELEVANT_STATE_ROLL =
*           STAT_NOT_PROCESSED_ROLL      =
*           STAT_MINOR_ERROR_ROLL        =
*           STAT_FOLLOWUP_ERROR_ROLL     =
*           STAT_HIERARCHY_ERROR_ROLL    =
*           STAT_ERROR_ROLL              =
       CHANGING
            log_data                     = grundliste_data
            .

  CALL FUNCTION 'OBJ_PROCESSING_SET_SELECTION'
    TABLES
      sel_tab  = sel_params
    CHANGING
      log_data = grundliste_data.
  grundliste_data-set_pf_key_individual = yes.
ENDFORM.                    "create_grundliste

* 46C: Form callback_grundliste deleted.