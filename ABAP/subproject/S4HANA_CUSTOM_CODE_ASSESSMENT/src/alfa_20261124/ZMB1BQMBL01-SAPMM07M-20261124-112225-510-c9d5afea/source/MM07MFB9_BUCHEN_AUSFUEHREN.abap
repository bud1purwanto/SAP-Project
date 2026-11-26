*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_AUSFUEHREN                                        *
*---------------------------------------------------------------------*
*       Die Verbuchungstabellen werden verbucht.                      *
*---------------------------------------------------------------------*

* consider the tables XEKBE_MA and XEKBZ_MA for the         "MAA EhP4
* PO history of postings with multi accunt assignment       "MAA EhP4

ENHANCEMENT-POINT MM07MFB9_BUCHEN_AUSFUEHREN_006 SPOTS ES_SAPMM07M STATIC .

*&---------------------------------------------------------------------*
*&      Form  buchen_ausfuehren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM buchen_ausfuehren.

  DATA:
    ls_dm07m            TYPE dm07m,
    ls_vm07m            TYPE vm07m,
    l_comp_cons         TYPE boole VALUE abap_false.

  DATA lo_factory TYPE REF TO if_mmpur_compcons_post.       "1464821

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_005 SPOTS es_sapmm07m STATIC.
  STATICS: statics_lock TYPE char1.

  DATA:ls_isc_me_post_history TYPE isc_me_post_history.

  def_break 'BUCHEN_AUSFUEHREN'.                            "#EC *
  BREAK-POINT ID mb_buchen_ausfuehren.

* --- begin ----------------------------------------------- MAA2
* if business function multi account assignment is active
  IF go_mmim_maa_2 is bound.

*   refresh the global static tables which contain the MAA data
*   of this MM document
    CALL METHOD go_mmim_maa_2->po_buffer_refresh.

*   clear the global buffer table with the PO data
    refresh                  cl_mmim_maa_2=>gt_po_data.

*   refresh the global working table for original reference documents
*   only here
    REFRESH :                cl_mmim_maa_2=>gt_mseg_refdoc.
  ENDIF.
* --- end   ----------------------------------------------- MAA2

* statics_lock secures that BUCHEN_AUSFUEHREN is only processed once!
  IF statics_lock = x.
    MESSAGE x372(m7).
  ENDIF.
  statics_lock = x.

ENHANCEMENT-POINT buchen_ausfuehren_09 SPOTS es_sapmm07m.

* Consistency check
  DATA: l_switch_off TYPE char1.
  GET PARAMETER ID 'M7373_DISABLE' FIELD l_switch_off.
  IF l_switch_off IS INITIAL.
    CALL FUNCTION 'MB_CONSISTENCY_CHECK'
      EXPORTING
        it_xmseg            = xmseg[]
        it_xvm07m           = xvm07m[]
      EXCEPTIONS
        missing_zustd_t156m = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      MESSAGE a373 WITH sy-subrc.
    ENDIF.
  ENDIF.

  if_secon.                                                "note 151672
  CALL FUNCTION 'MB_SET_MATERIAL_VALUES_ENQUEUE'           "note 151672
       EXPORTING                                           "note 151672
            mbequ         = tcurm-mbequ                    "note 151672
       TABLES                                              "note 151672
            xmbew         = xmbew                          "note 151672
            xebew         = xebew                          "note 151672
            xqbew         = xqbew                          "note 151672
            xobew         = xobew                          "note 151672
       EXCEPTIONS                                          "note 151672
            error_message = 4.                             "note 151672
  IF NOT sy-subrc IS INITIAL.                              "note 151672
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH        "note 151672
               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.        "note 151672
  ENDIF.                                                   "note 151672
  end_secon.   "note 151672

* Suppress unwanted initialization of docu batches
  CALL FUNCTION 'VBDBDM_INIT_SUPPRESS'.                     "1357398

* Erster Schritt
  if_first.
  IF NOT mbval IS INITIAL AND xower IS INITIAL.
    CALL FUNCTION 'MB_PUT_SINGLE_MWOFF_INTERFACE' IN UPDATE TASK
      TABLES
        xmkpf  = xmkpf
        zmseg  = zmseg
        zvm07m = zvm07m
        zdm07m = zdm07m
        xmseg  = xmseg
        xvm07m = xvm07m
        ymbuz  = ymbuz.
*       zmbuz  = zmbuz.
  ENDIF.
  IF NOT xower IS INITIAL.
    CLEAR xmseg.
    READ TABLE xmseg INDEX 1.
    IF NOT xmseg-smbln IS INITIAL AND NOT xmseg-sjahr IS INITIAL.
      CALL FUNCTION 'MB_DEL_SINGLE_MWOFF_INTERFACE' IN UPDATE TASK
        EXPORTING
          mblnr = xmseg-smbln
          mjahr = xmseg-sjahr.
    ENDIF.
  ENDIF.
  DATA: l_komv_we LIKE komv  OCCURS 0,
* BELEGKONDITION BEI PREISFINDUNG WE
        l_ekbev   LIKE ekbev OCCURS 0.
* BESTELLENTWICKLUNG (MIT NUMMER BELEGKONDITION BEI PREISFINDUNG WE)

  IF NOT xnebe IS INITIAL.
    CALL FUNCTION 'ME_POST_DOC'
      EXCEPTIONS
        err_call_sequence = 1
        OTHERS            = 2.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENHANCEMENT-SECTION     buchen_ausfuehren_04 SPOTS es_sapmm07m.
* call function 'MB_SET_MATERIAL_VALUES_ENQUEUE'
*      exporting mbequ = tcurm-mbequ
*      tables    xmbew = xmbew.
END-ENHANCEMENT-SECTION.

*------ Materialstamm Verbräuche -------------------------------------*
* 'MB_UPDATE_MATERIAL_CONSUMPTION' is now called in MB_UPDATE_TASKS
* see note 354212

*------ Aufteiler                -------------------------------------*
* @vsa_cd anfang
*    read table xauwei index 1.
*    if sy-subrc is initial.
*      call function 'WWEA_INDEX_ALLOCATION_CREATE' in update task
*           tables
*                im_auwei = xauwei.
*    endif.
  IF cd_vorgang_aktiv EQ x  OR  vas_vorgang_aktiv EQ x.
    CLEAR cd_vorgang_aktiv.
    CALL FUNCTION 'W_FRM_GR_ASSIGNMENT_CORRECT'
      TABLES
        t_mseg          = cd_mseg_eingemischt
        t_mseg_subitems = vas_mseg_eingemischt.

    REFRESH: cd_mseg_eingemischt, vas_mseg_eingemischt.

    DATA: BEGIN OF cd_mseg_adjust OCCURS 0.
            INCLUDE STRUCTURE mseg.
    DATA: END OF cd_mseg_adjust.
    DATA: BEGIN OF vas_adjust OCCURS 50.
            INCLUDE STRUCTURE rfrmmseg.
    DATA: END OF vas_adjust.
* cd: elikz must be set in every cd-position
    PERFORM lgort_cd_elikz_pflegen TABLES xmseg
                                          cd_mseg_adjust.
* vas: get the right subitems to hand over to frm
    PERFORM vas_subitems_uebergeben TABLES cd_mseg_adjust
                                           vas_adjust.
    CALL FUNCTION 'W_FRM_GR_ASSIGNMENT_ADJUST'
      TABLES
        t_mseg          = cd_mseg_adjust
        t_mseg_subitems = vas_adjust.
  ENDIF.
* @vsa_cd ende

*------------------ Rename für Serialnummern hier wg QM ---------------*
  IF NOT upd_seri IS INITIAL.
* Prod.order with serialnumbers using MB_CREATE (TCODE: COWBHUWE/WE)
* already called RENUMBER and COMPLETE_CHECK.
    IF ( NOT xmbwl IS INITIAL AND t158-vgart = vgart_wf ) AND
       ( xbapi IS INITIAL AND xmigo IS INITIAL ).
*     only update for serialnumbers, later in this form.
    ELSE.
*     lt_sermbuz shows association between ymseg-zeile and xmseg-zeile
*     including corrections regarding subsequent adjustment. Its used
*     during the "renumber"- step of serialnumberhandling only!
      DATA: BEGIN OF lt_sermbuz OCCURS 20.                  "note158555
              INCLUDE STRUCTURE mbuz.                       "note158555
      DATA: END OF lt_sermbuz.                              "note158555
      lt_sermbuz[] = ymbuz[].                               "note158555
      IF xmigo IS INITIAL.                                "734758 start
        LOOP AT lt_sermbuz.
          READ TABLE zmbuz INDEX lt_sermbuz-zeilz.
          IF sy-subrc IS INITIAL.
            lt_sermbuz-zeilz = zmbuz-zeily.
            MODIFY lt_sermbuz.
          ENDIF.
        ENDLOOP.
        IF xbapi = x.                                       "924222
          PERFORM bapi_mbuz_adjustment CHANGING lt_sermbuz[]. "1305085
        ENDIF.                                              "924222
      ELSE.
        PERFORM migo_mbuz_adjustment CHANGING lt_sermbuz[].
      ENDIF.                                                "734758 end
      CALL FUNCTION 'SERIALPROFILE_CHECK'
        EXPORTING
          operation     = op_mmrn
          mblnr_old     = smblnr
          mblnr         = xmkpf-mblnr
        TABLES
          ymbuz         = lt_sermbuz                        "note158555
        EXCEPTIONS
          error_message = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
* MB_Create und MB_cancel haben eigenen serial_liste_complete_check
      IF ( xcanc IS INITIAL AND xmbwl IS INITIAL )          "879518
         OR xmigo = x OR xbapi = x.                         "1153281
        LOOP AT xmseg.
          READ TABLE ymbuz INDEX sy-tabix.
          READ TABLE zdm07m WITH KEY ymbuz-zeilz.
          PERFORM serial_liste_complete_check.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
*------ Qualitätssicherung       -------------------------------------*
  PERFORM sichern_qm_daten
               TABLES
                  xmbqssz
               USING
                  xmkpf-mblnr
                  xmkpf-mjahr.
ENHANCEMENT-POINT buchen_ausfuehren_11 SPOTS es_sapmm07m.
*------ Reservierungen           -------------------------------------*
  READ TABLE xmres INDEX 1.
  IF sy-subrc IS INITIAL.
*     Fangschaltung zur Ermittlung der fehlerhaften Fortschreibung der
*     Entnahmemenge in der Reservierung:
    PERFORM reservierung_fangschaltung.
*     Ende Fangschaltung
    FREE zmres.
    zmres[] = xmres[].
    PERFORM buchen_reservierung ON COMMIT LEVEL level_resb.
  ENDIF.
*---------------- Serialnummern Update -------------------------------*
  IF NOT upd_seri IS INITIAL.
    DATA: l_memory_id_status(60) TYPE c.
*   Get memory id:
    IF NOT xbapi IS INITIAL AND xcanc IS INITIAL.
      l_memory_id_status = 'BAPI_GOODSMVT_CREATE'.
    ELSEIF NOT xbapi IS INITIAL AND NOT xcanc IS INITIAL.
      l_memory_id_status = 'BAPI_GOODSMVT_CANCEL'.
    ELSE.
      CLEAR l_memory_id_status.
    ENDIF.
    CALL FUNCTION 'SERIAL_LISTE_POST_MM'
      EXPORTING
        memory_id_status = l_memory_id_status
      EXCEPTIONS
        error_message    = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ Lagerverwaltung          -------------------------------------*
  READ TABLE xlk01 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'L_LK01_VERARBEITEN' IN UPDATE TASK
      EXPORTING
        i_datlo = sy-datlo
        i_timlo = sy-timlo
      TABLES
        xlk01   = xlk01.
  ENDIF.
  READ TABLE xlk02 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'L_LK02_VERARBEITEN' IN UPDATE TASK
      EXPORTING
        i_datlo = sy-datlo
        i_timlo = sy-timlo
      TABLES
        xlk02   = xlk02.
  ENDIF.
  IF NOT ( xlk01[] IS INITIAL AND xlk02[] IS INITIAL ).
    CALL FUNCTION 'L_VERME_LQUA_CREATE_IM'
      TABLES
        t_lk01 = xlk01
        t_lk02 = xlk02.
  ENDIF.
*------ Disposition              -------------------------------------*
  READ TABLE xmdcp INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'DISPSATZ_BESTANDSFUEHRUNG' IN UPDATE TASK
      TABLES
        xmard = xmard
        xmssl = xmssl
        xmdcp = xmdcp.
  ENDIF.
*----------- Kanban-Behälter fortschreiben ----------------------------*
ENHANCEMENT-SECTION     sapmm07m_11 SPOTS es_sapmm07m.
  IF NOT kanba IS INITIAL.
    CALL FUNCTION 'PK_ITEM_STATUS_POST'
      EXPORTING
        e_mblnr       = xmkpf-mblnr
      TABLES
        it_vm07m      = xvm07m
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT buchen_ausfuehren_10 SPOTS es_sapmm07m.
*------ Primärbedarfsabbau       -------------------------------------*
  READ TABLE xpbat INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'REQUIREMENTS_REDUCTION'
      EXPORTING
        vgart         = xmkpf-vgart
      TABLES
        fxpbat        = xpbat
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* Änderungsbelege für neue Chargen
  PERFORM charge_change_document.

*------ Materialstamm Mengen     -------------------------------------*
* 'MB_UPDATE_MATERIAL_STOCKS' is now called in MB_UPDATE_TASKS
* see note 354212
*------ Materialstamm EAN-Nummern ------------------------------------*
  IF NOT upd_ean11 IS INITIAL.
    CALL FUNCTION 'EAN_PRESAVE_AFTER_CHECK'
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ Importdaten --------------------------------------------------*
*------- Verbuchung nicht bei Wareneingang aus Lieferung (MSEG-KZBEW=L),
*------- da Importdaten bereits in Lieferung angelegt
  LOOP AT xmseg TRANSPORTING NO FIELDS
                WHERE kzbew EQ 'L' .
    EXIT.
  ENDLOOP.
  IF NOT ( sy-subrc IS INITIAL ) .
*------ Nur fuer WE-Belege mit Bezug zur Bestellung (MSEG-KZBEW=B)
    LOOP AT xmseg TRANSPORTING NO FIELDS
                  WHERE kzbew EQ 'B' .
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
* Move to standard table is necessary because of TABLES parameter
      DATA: lt_ftrade TYPE STANDARD TABLE OF ftkey.
      lt_ftrade = gt_ftrade.
      CALL FUNCTION 'EXPIMP_POSTING_TRIGGER'
        EXPORTING
          i_ahbas       = '1WE'
          i_mkpf        = xmkpf
        TABLES
          i_t_ftkey     = lt_ftrade
        EXCEPTIONS
          error_message = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDIF.

* Aufruf SLL
  PERFORM sll_document_transfer USING 'V'.

*------ SD-Belegfluß -------------------------------------------------*
  READ TABLE xvbfa INDEX 1.

ENHANCEMENT-SECTION     mm07mfb9_buchen_ausfuehren_06 SPOTS es_sapmm07m.
  IF sy-subrc IS INITIAL.
    xvbfa-aedat = mkpf-budat.                              "n_1675991
    MODIFY xvbfa INDEX 1.                                  "n_1675991

* --- begin ----------------------------------------------- MAA2
*   If this is a GR posting with MAA items for an inbound delivery
*   condense the resolved MAA entries for the document flow
*
  IF     go_mmim_maa_2 IS BOUND    AND  " MAA is active
     NOT xekbe_ma[]    IS INITIAL.      " MM doc contains MAA items

    CALL METHOD go_mmim_maa_2->condense_xvbfa
      EXPORTING
        it_mseg = xmseg[]
      CHANGING
        ct_vbfa = xvbfa[].
  ENDIF.
* --- end   ----------------------------------------------- MAA2

    CALL FUNCTION 'SD_DELIVERY_WE_FLOW_UPDATE'              "n_941879
      EXPORTING
*SPE ST 28.01.2005 VL-MM consistency
        i_vbtyp       = g_vbtyp_v
      TABLES
        tvbfa         = xvbfa
      EXCEPTIONS
        error_message = 4.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
END-ENHANCEMENT-SECTION.

*------ Handling-Unit -------------------------------------------------*
  DATA: hum_post LIKE hum_object.                           "HUM
  "HUM
  hum_post-objkey = xmkpf-mblnr.                            "HUM
  hum_post-objkey+10(4) = xmkpf-mjahr.                      "HUM
  hum_post-object = 'MM'.                                   "HUM
  "HUM
  CALL FUNCTION 'HU_POST'                                   "HUM
     EXPORTING                                              "HUM
*         IF_SYNCHRON    = ' '                                      "HUM
          if_no_messages = 'X'                              "HUM
          is_object      = hum_post.                        "HUM

ENHANCEMENT-POINT buchen_ausfuehren_02 SPOTS es_sapmm07m.

*----------------------------------------------------------------------*
*   Optische Archivierung                                              *
*   Spaete Erfassung mit Barcode
*----------------------------------------------------------------------*

  IF xmbwl = space.
    PERFORM barcode_update USING xmkpf-mblnr
                                 xmkpf-mjahr
                                 barcode.
  ENDIF.


*----------------------------------------------------------------------*
*   Optische Archivierung                                              *
*   Fruehes erfassen
*----------------------------------------------------------------------*

  DATA: BEGIN OF object OCCURS 0.
          INCLUDE STRUCTURE wfas2.
  DATA: END OF object.
*  OBJECT-ASGTP       =  'MKPF'.
  object-asgtp       =  'BUS2017'.
  object-asgky       =  xmkpf-mblnr.
  object-asgky+10(4) =  xmkpf-mjahr.
  object-action      =  'I'.
  APPEND object.

  CALL FUNCTION 'WF_COMMIT'
       EXPORTING
            in_update_task     = 'X'
*       IMPORTING                       "note 354212
*            CALLED_BY_WORKFLOW = MKPF  "note 354212
       TABLES
            assignments        = object
       EXCEPTIONS
            assignment_error   = 01
            db_error           = 02
            error_message      = 04.
  CASE sy-subrc.
    WHEN 0.
    WHEN 4.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

*----------------------------------------------------------------------*

  nast_key-mblnr = xmseg-mblnr.
  nast_key-mjahr = xmseg-mjahr.
  nast_key-zeile = xmseg-zeile.
  msg_objky = nast_key.
  CALL FUNCTION 'RV_MESSAGES_GET'
    EXPORTING
      msg_kappl     = 'ME'
    TABLES
      tab_xnast     = xnast
      tab_ynast     = ynast
    EXCEPTIONS
      error_message = 4.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
               sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  DESCRIBE TABLE xnast LINES index_x.
  IF NOT index_x IS INITIAL.
    CALL FUNCTION 'MB_MESSAGE_UPDATE'                       "qla
         EXPORTING                                          "qla
              m_kappl = 'ME'                                "qla
*             M_OBJKY = MSG_OBJKY                           "qla
         EXCEPTIONS                                         "qla
              error_message = 4.                            "qla
*   call function 'RV_MESSAGES_UPDATE'
*        exporting
*             msg_kappl = 'ME'
*             msg_objky = msg_objky
*        exceptions
*             others    = 1.
*             error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ Inflation                -------------------------------------*
  CALL FUNCTION 'SET_GOODS_ISSUE_INFL_RELEVANCE'
    TABLES
      t_mseg = xmseg.

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_04 SPOTS es_sapmm07m STATIC.

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_05 SPOTS es_sapmm07m.

*------ Materialbeleg            -------------------------------------*

* BEGIN trapdoor for incomplete document structure.
  DATA: l_deactive TYPE char1.
  GET PARAMETER ID 'M7358_DISABLE' FIELD l_deactive.
  IF l_deactive IS INITIAL.
    CALL METHOD cl_mmim_line_id_manager=>consistency_check
      EXPORTING
        it_mseg                    = xmseg[]
      EXCEPTIONS
        toplevel_depth_not_initial = 1
        unlinked_entries           = 2
        illegal_line_id            = 3
        duplicate_line_id          = 4
        depth_range_illegal        = 5
        OTHERS                     = 6.
    IF sy-subrc <> 0.
      MESSAGE a358 WITH sy-subrc.                           "339202
    ENDIF.
  ENDIF.
* end trapdoor

* 'MB_POST_DOCUMENT' is now called in MB_UPDATE_TASKS
* see note 354212
*------ Tickets & Additionals    -------------------------------------*
* Belegnummer später in MSEG aufnehmen !
*  data: addibelnr like wtadab-addibelnr.
*  call function 'WTAD_GM_SUCCESSION_ACTIVITY'
*       exporting
*            mkpf      = xmkpf
*            addibelnr = addibelnr
*       tables
*            imseg     = xmseg
*       exceptions
*            others    = 0.
  CALL FUNCTION 'WTAD_ADDIS_IN_GOODS_MOVEMENTS'
    TABLES
      fit_mkpf         = xmkpf
      fit_mseg         = xmseg
      fit_vm07m        = xvm07m
    EXCEPTIONS
      addis_not_active = 1
      addis_irrelevant = 2
      general_error    = 3
      OTHERS           = 4.

  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'WTAD_ADDIS_IN_GM_POST'
      TABLES
        fit_mkpf      = xmkpf
        fit_mseg      = xmseg
      EXCEPTIONS
        general_error = 1
        OTHERS        = 2.
  ENDIF.
*------ Aufträge                 -------------------------------------*
  READ TABLE xfabe INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'CO_SF_RECEIPT_ITEM_UPDATE'
      EXPORTING
        mblnr         = xmkpf-mblnr
        mjahr         = xmkpf-mjahr
        xlisu         = int_xlisu
      TABLES
        fabe_tab      = xfabe
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
ENHANCEMENT-POINT buchen_ausfuehren_03 SPOTS es_sapmm07m.
  ENDIF.
*------ Bewegungen zum Auftrag   -------------------------------------*
  READ TABLE xaufm INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'AUFM_POST' IN UPDATE TASK
      TABLES
        aufm_tab = xaufm
        it_vm07m = zvm07m.
  ENDIF.
*------ Fortschreibung Fremdbearbeitung ------------------------------*
  IF NOT xexop[] IS INITIAL.
    CALL FUNCTION 'CO_VB_EXT_OPERATION_UPDATE' IN UPDATE TASK
      TABLES
        exop_tab = xexop.
  ENDIF.
*------ Lagercontrolling         -------------------------"note 0181695

  READ TABLE xmcwmit INDEX 1.                             "note 0181695
  IF sy-subrc IS INITIAL.                                 "note 0181695
    CALL FUNCTION 'L_MCWM_STATISTICS_LIS'                 "note 0181695
         EXPORTING                                        "note 0181695
              zeitp                 = 'TE'  "Zeitpunkt Transport extern
         TABLES                                           "note 0181695
              xmcwmhd               = xmcwmhd             "note 0181695
              xmcwmit               = xmcwmit             "note 0181695
         EXCEPTIONS                                       "note 0181695
              transfer_not_relevant = 01                  "note 0181695
              error_message         = 04.                 "note 0181695
    CASE sy-subrc.                                        "note 0181695
      WHEN 0.                                             "note 0181695
      WHEN 1.                                             "note 0181695
      WHEN 4.                                             "note 0181695
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH   "note 0181695
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.   "note 0181695
    ENDCASE.                                              "note 0181695
  ENDIF.                                                  "note 0181695
  end_first.
* Ende erster Schritt
  DATA: xekes LIKE uekes OCCURS 0 WITH HEADER LINE.
  READ TABLE xekbe INDEX 1.
  IF sy-subrc IS INITIAL.
ENHANCEMENT-SECTION     mm07mfb9_buchen_ausfuehren_007 SPOTS es_sapmm07m.
    CALL FUNCTION 'ME_CONFIRMATION_MAINTAIN_GR'
      TABLES
        t_ekbe        = xekbe
        t_ekes        = xekes
        zmseg         = zmseg                               "491785
        zvm07m        = zvm07m                              "491785
      EXCEPTIONS
        error_message = 4.
END-ENHANCEMENT-SECTION.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ Bestellentwicklung       -------------------------------------*
  READ TABLE xekbe INDEX 1.
  IF sy-subrc IS INITIAL.
    IF NOT vas_vorgang_aktiv IS INITIAL.
* add po history of subitems
      DATA: BEGIN OF h_xekbe OCCURS 10.
              INCLUDE STRUCTURE ekbe.
      DATA: END OF h_xekbe.
      APPEND LINES OF xekbe TO h_xekbe.
      APPEND LINES OF vas_ekbe TO xekbe.
    ENDIF.
* begin of Outsourced Manufacturing EhP 604
    IF cl_ops_switch_check=>mm_om1_sfws_sc( )
       EQ cl_ops_switch_check=>switch_active_true.
      CALL FUNCTION 'MMPUR_COMPCONS_GET_FACTORY'            "1464821
        IMPORTING
          eo_factory = lo_factory.
      l_comp_cons = lo_factory->post_data( it_ebefu = xebefu[]
                                           it_mseg  = xmseg[]
                                           it_dm07m = zdm07m[]
                                           it_ekbe  = xekbe[]
                                           is_vm07m = vm07m ).
    ENDIF.
* End of Outsourced Manufacturing EhP 604
ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_01 SPOTS es_sapmm07m.

* Start of note 1591297
* Updating the xblnr field of purchase order history table
* using the value of xblnr in material document table
DATA : wa_bukrs TYPE bukrs.
* Check if return delivery                                      "Note 1637001
    IF NOT vm07m-XSTOR IS INITIAL.                              "Note 1637001
      IF mseg-kzbew = 'B'.                                      "Note 1637001
* By looping at xmseg using material document number and year ,
* the value of company code is moved to wa_bukrs
        LOOP AT xmseg WHERE mblnr = xmkpf-mblnr AND mjahr = xmkpf-mjahr.
          MOVE xmseg-bukrs TO wa_bukrs.
          IF wa_bukrs IS NOT INITIAL.
            EXIT.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'   "Component Active check for Argentina
           EXPORTING
           bukrs                   = wa_bukrs
           component               = 'AR'
         EXCEPTIONS
           component_not_active = 02.

* xekbe contains PO history details.So once xmkpf-xblnr is updated, the same has to be filled
* in xekbe-xblnr by looping at this table using material document number and year
        IF sy-subrc = 0 AND NOT xmkpf-xblnr IS INITIAL.
          LOOP AT xekbe WHERE belnr = xmkpf-mblnr AND gjahr = xmkpf-mjahr.
            MOVE xmkpf-xblnr TO xekbe-xblnr.
            MODIFY xekbe.
          ENDLOOP.
        ENDIF.
      ENDIF.
* End of note 1591297
* Start of note 1637001
    ELSEIF vm07m-XSTOR IS INITIAL AND mseg-kzbew = 'B'.
* By looping at xmseg using material document number and year ,
* the value of company code is moved to wa_bukrs
  LOOP AT xmseg WHERE mblnr = xmkpf-mblnr AND mjahr = xmkpf-mjahr.
    MOVE xmseg-bukrs TO wa_bukrs.
    IF wa_bukrs IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'   "Component Active check for Argentina
     EXPORTING
     bukrs                   = wa_bukrs
     component               = 'AR'
   EXCEPTIONS
     component_not_active = 02.

* xekbe contains PO history details.So once xmkpf-xblnr is updated, the same has to be filled
* in xekbe-xblnr by looping at this table using material document number and year
  IF sy-subrc = 0 AND NOT xmkpf-xblnr IS INITIAL.
    LOOP AT xekbe WHERE belnr = xmkpf-mblnr AND gjahr = xmkpf-mjahr.
      MOVE xmkpf-xblnr TO xekbe-xblnr.
      MODIFY xekbe.
    ENDLOOP.
  ENDIF.
ENDIF.
* End of note 1637001

* consider the tables XEKBE_MA and XEKBZ_MA for the         "MAA EhP4
* PO history of postings with multi accunt assignment       "MAA EhP4

    CALL FUNCTION 'ME_POST_HISTORY'
      EXPORTING
        i_mbval          = mbval
        i_xwert          = xwert
        iv_comp_cons     = l_comp_cons
      TABLES
        v_ekbe           = xekbe
        v_ekbz           = xekbz
        v_ekbe_cr        = xekbe_cr
        v_ekbz_cr        = xekbz_cr
        v_ekbe_ma        = xekbe_ma                         "MAA EhP4
        v_ekbz_ma        = xekbz_ma                         "MAA EhP4
        e_ekbev          = l_ekbev
        e_komv_we        = l_komv_we
      CHANGING
        cs_1_enhancement = ls_isc_me_post_history           "IS2ERP
      EXCEPTIONS
        error_message    = 4.

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_02 SPOTS es_sapmm07m.

    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*   call function 'ME_STATISTICS_RKO_POST'.                   "624127
    CALL FUNCTION 'ME_CONFIRMATION_EKET_UPD' IN UPDATE TASK "491785
         TABLES  xekbe = xekbe.                             "491785
    IF  NOT vas_vorgang_aktiv IS INITIAL.
* continue with 'normal' po history (without vas subitems)
      REFRESH xekbe.
      APPEND LINES OF h_xekbe TO xekbe.
      REFRESH h_xekbe.
      CLEAR vas_vorgang_aktiv.
    ENDIF.
    CALL FUNCTION 'ME_STATISTICS_WE_EKBE_LIS'
      EXPORTING
        it_mkpf       = xmkpf[]
        it_mseg       = xmseg[]
      TABLES
        t_ekbe        = xekbe
        t_ekbz        = xekbz
        t_ekbev       = l_ekbev
        t_komv_we     = l_komv_we
        t_ekes        = xekes
        t_ekbe_ma     = xekbe_ma                            "MAA EhP4
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'MM_ARRANG_INDEX_CREATE_WE'
      EXPORTING
        i_refresh_partners = space
        i_refresh_buffers  = space
      TABLES
        t_ekbev            = l_ekbev
      EXCEPTIONS
        error_message      = 4.
* create S111 entries in case of pricing goods receipt
* (subsequent settlement)
    IF sy-subrc <> 0.
* cancel DB posting if any error message has occured, otherwise the
* financial document could have been posted
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* begin of Outsourced Manufacturing EhP 4
  IF xekbe_sc[] IS NOT INITIAL.
    CALL FUNCTION 'MMPUR_COMPCONS_POST' IN UPDATE TASK
      EXPORTING
        it_comp_cons_insert = xekbe_sc[].
  ENDIF.
* end of Outsourced Manufacturing EhP 4

*------ Inventurbeleg            -------------------------------------*
  IF inventur IS INITIAL.
    READ TABLE zikpf INDEX 1.
    IF sy-subrc IS INITIAL.
      PERFORM i-segmente_buchen.
    ENDIF.
  ENDIF.
* ----- Auftragsentwicklung     -------------------------------------*
  READ TABLE xaufbe INDEX 1.
  IF sy-subrc IS INITIAL.
    DATA: update_task.
    CALL FUNCTION 'CKMO_CREATE_ORDER_HISTORY_MMIM'
      EXPORTING
        s_not_use_update_task = update_task
        mbval                 = mbval
        xwert                 = xwert
        xower                 = xower
      TABLES
        it_aufbe              = xaufbe
        it_aufbe_cr           = xaufbe_cr
        it_accit              = xaccit      "note 382951
        it_acccr              = xacccr.     "note 382951
  ENDIF.
* ----- Notify SRM in case of Extended Classic Purchase Order ---------*
  DATA: lv_funcname LIKE rs38l-name VALUE 'BBP_NOTIFY_MATERIAL_DOC'.
* Check whether SRM Extended PO is involved at all (EKKO-STATU = 'K')
  LOOP AT xvm07m TRANSPORTING NO FIELDS WHERE statuk = 'K'.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
*   Make sure that the R/3 Plugin function module exists
*   (The module will not be shipped in Plugin releases < 2004.1)
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = lv_funcname
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc = 0.
*     Trigger notification of SRM
      CALL FUNCTION lv_funcname
        EXPORTING
          it_vm07m = xvm07m[]
          it_mseg  = xmseg[]
        EXCEPTIONS
          OTHERS   = 1.
    ENDIF.
  ENDIF.

****************** Collective update Task ****************************
* MB_UPDATE_TASKS calls:
* - MB_UPDATE_MATERIAL_CONSUMPTION
* - MB_UPDATE_MATERIAL_STOCKS
* - MB_UPDATE_MATERIAL_VALUES
* - MB_POST_DOCUMENT
* see note 354212

  DATA: l_first, l_secon TYPE xfeld.
  if_first.
  l_first = x.
  end_first.
  if_secon.
  l_secon = x.
  end_secon.

* Begin of New Dimension Exit Coding: APO Material Document
* Note 663137
  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
    EXCEPTIONS
      exits_not_active = 1
      OTHERS           = 2.
  IF sy-subrc = 0.
* SPE STO fill table with Timestamps and Planning Trigger
    DATA: lt_plantrigger_timestamp TYPE /spe/plantrigger_timestamp_tab.
    CALL FUNCTION '/SPE/PLANTRIGGER_TIMESTAMP'
      EXPORTING
        it_mseg                  = xmseg[]
        it_vm07m                 = xvm07m[]
      IMPORTING
        et_plantrigger_timestamp = lt_plantrigger_timestamp[].

    CALL FUNCTION 'OUTBOUND_CALL_01000011_E' IN UPDATE TASK
      TABLES
        xmseg  = xmseg
* New table for Timestamps and Planning Trigger
        /spe/plantrigger_timestamp = lt_plantrigger_timestamp
      exceptions
        OTHERS = 1.
  ENDIF.
* Cat-Ford Release 2: Redirection of scheduling agreements
* User CMD - Transport AC0K049219
* Trigger APO along statistical GR
  IF g_f_redirsa_necessary IS NOT INITIAL.
    CALL FUNCTION 'MB_STAT_GR_REDIR_SA'
      TABLES
        xekbe  = xekbe
      EXCEPTIONS
        OTHERS = 1.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* End of New Dimension Exit Coding: APO Material Document

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_03 SPOTS es_sapmm07m.

ENHANCEMENT-SECTION     buchen_ausfuehren_08 SPOTS es_sapmm07m.
  CALL FUNCTION 'MB_UPDATE_TASKS' IN UPDATE TASK
    EXPORTING
      i_upd_um03b = upd_um03b
      i_first     = l_first
      i_secon     = l_secon
      i_budat     = mkpf-budat
      i_usnam     = mkpf-usnam
    TABLES
      xvstat      = xvstat
      xmarc       = xmarc
      xmard       = xmard
      xmch1       = xmch1
      xmcha       = xmcha
      xmchb       = xmchb
      xmkol       = xmkol
      xmska       = xmska
      xmsku       = xmsku
      xmslb       = xmslb
      xmspr       = xmspr
      xmssa       = xmssa
      xmssl       = xmssl
      xmssq       = xmssq
      xmarv       = xmarv
      xxiseg      = xxiseg
      zmkpf       = xmkpf
      zmseg       = xmseg
      zvm07m      = xvm07m
      zmbew       = xmbew
      zebew       = xebew
      zqbew       = xqbew
      zobew       = xobew          "kaz ??
      xmstb       = xmstb          "SIT
      xmste       = xmste          "SIT
      xmstq       = xmstq.         "SIT
END-ENHANCEMENT-SECTION.
  DATA lv_mm_sfws_p2pse_active TYPE xfeld.
  DATA ls_mkpf LIKE LINE OF xmkpf.
  DATA ls_mseg LIKE LINE OF xmseg.
  DATA lt_changed_objects TYPE esh_t_if_changed_objects.
  DATA lv_changed_object LIKE LINE OF lt_changed_objects.

* Check on Activation of UI Switch MM_SFWS_P2PSE (6.04)
  lv_mm_sfws_p2pse_active = cl_ops_switch_check=>mm_sfws_p2pse( ).

  IF lv_mm_sfws_p2pse_active EQ abap_true.

* Update GR header indexes.
    LOOP AT xmkpf INTO ls_mkpf.
      CONCATENATE ls_mkpf-mblnr ls_mkpf-mjahr INTO lv_changed_object-object_id.
      lv_changed_object-created = 'X'.
      APPEND lv_changed_object TO lt_changed_objects.
    ENDLOOP.

    IF lt_changed_objects IS NOT INITIAL.
      CALL FUNCTION 'MB_TREX_TRIGGER_GR' IN UPDATE TASK
        EXPORTING
          it_changed_gr = lt_changed_objects.
    ENDIF.

* Update GR item indexes.
    CLEAR : lt_changed_objects, lv_changed_object.
    LOOP AT xmseg INTO ls_mseg.
      CONCATENATE ls_mseg-mblnr ls_mseg-mjahr ls_mseg-zeile INTO lv_changed_object-object_id.
      lv_changed_object-created = 'X'.
      APPEND lv_changed_object TO lt_changed_objects.
    ENDLOOP.

    IF lt_changed_objects IS NOT INITIAL.
      CALL FUNCTION 'MB_TREX_TRIGGER_GRITEM' IN UPDATE TASK
        EXPORTING
          it_changed_gritems = lt_changed_objects.
    ENDIF.
  ENDIF.


********************************************************
ENHANCEMENT-POINT buchen_ausfuehren_05 SPOTS es_sapmm07m.

* Copy XMSEG and retrieve data.
* XVM07M is needed to find out about batch indicator XCHPF to send
* batch data to the other system.
  CALL METHOD cl_mmim_cross_system=>fetch_xmseg             "sdp462
    EXPORTING                                               "sdp462
      it_xmseg  = xmseg[]                                   "sdp462
      it_xvm07m = xvm07m[].                                 "sdp462

* Trigger cross-system movements. The check for late valuation
* is done using the flag at this point as it reflects the status
* which has been used to control the valuation process.
* Even if the check might be done earlier to avoid the A-message,
* this check must stay here!
  CALL METHOD cl_mmim_cross_system=>data_send_to_receiver   "sdp462
    EXPORTING                                               "sdp462
      i_mbval = tcurm-mbval.                                "sdp462

* Ende beide Schritte
* Zweiter Schritt
  if_secon.
*------ Materialbeleg            -------------------------------------*

  IF NOT mbval IS INITIAL.
    CALL FUNCTION 'MB_CHANGE_DOCUMENT' IN UPDATE TASK
      TABLES
        zmkpf = xmkpf
        zmseg = xmseg.

* Check on Activation of UI Switch MM_SFWS_P2PSE (6.04)
    lv_mm_sfws_p2pse_active = cl_ops_switch_check=>mm_sfws_p2pse( ).

    IF lv_mm_sfws_p2pse_active EQ abap_true.

* Update GR header indexes.
      LOOP AT xmkpf INTO ls_mkpf.
        CONCATENATE ls_mkpf-mblnr ls_mkpf-mjahr INTO lv_changed_object-object_id.
        lv_changed_object-modified = 'X'.
        APPEND lv_changed_object TO lt_changed_objects.
      ENDLOOP.

      IF lt_changed_objects IS NOT INITIAL.
        CALL FUNCTION 'MB_TREX_TRIGGER_GR' IN UPDATE TASK
          EXPORTING
            it_changed_gr = lt_changed_objects.
      ENDIF.

* Update GR item indexes.
      CLEAR : lt_changed_objects, lv_changed_object.
      LOOP AT xmseg INTO ls_mseg.
        CONCATENATE ls_mseg-mblnr ls_mseg-mjahr ls_mseg-zeile INTO lv_changed_object-object_id.
        lv_changed_object-modified = 'X'.
        APPEND lv_changed_object TO lt_changed_objects.
      ENDLOOP.

      IF lt_changed_objects IS NOT INITIAL.
        CALL FUNCTION 'MB_TREX_TRIGGER_GRITEM' IN UPDATE TASK
          EXPORTING
            it_changed_gritems = lt_changed_objects.
      ENDIF.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_008 SPOTS es_sapmm07m.


*------ Bestandscontrolling      -------------------------------------*
  READ TABLE xmcmseg INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MCB_STATISTICS_LIS'
      TABLES
        xmcmseg       = xmcmseg
        xmcmres       = xmcmres
        xmcbest       = xmcbest
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ LIFO-Bewertung           -------------------------------------*
  IF NOT upd_xlifo IS INITIAL.
    CALL FUNCTION 'LIFO_UPDATE_STOCK'
      TABLES
        xslifo        = xlifo
      EXCEPTIONS
        error_message = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*------ Verkaufspreisumbewertung -------------------------------------*
  CALL FUNCTION 'WB_REVAL_DOC_CREATE'
    EXPORTING
      pi_mblnr = xmkpf-mblnr.
*------ Konsignationsentwicklung --------------------- 4.0konsi ------*
  READ TABLE xrkwa INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MR_RKWA_UPDATE' IN UPDATE TASK
      EXPORTING
        i_updkz       = i
      TABLES
        t_rkwa        = xrkwa
      exceptions
        ERROR_MESSAGE = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

*------ Obewentwicklung ----------------------------------------------*
  READ TABLE xrowa INDEX 1.                                 "kaz
  IF sy-subrc IS INITIAL.                                   "kaz
    CALL FUNCTION 'MO_ROWA_UPDATE' IN UPDATE TASK           "kaz
         EXPORTING                                          "kaz
              i_updkz       = i                             "kaz
         TABLES                                             "kaz
              t_rowa        = xrowa                         "kaz
         exceptions                                         "kaz
              ERROR_MESSAGE = 4.                            "kaz
    IF NOT sy-subrc IS INITIAL.                             "kaz
      MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH       "kaz
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.       "kaz
    ENDIF.                                                  "kaz
  ENDIF.                                                    "kaz

*------ Materialstamm Werte      -------------------------------------*
* 'MB_UPDATE_MATERIAL_VALUES' is now called in MB_UPDATE_TASKS
* see note 354212

*       Joint Venture Accounting CRP
  PERFORM jv_crp_post.

*------ BADI before update: MB_DOCUMENT_BEFORE_UPDATE
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_DOCUMENT_BADI'           "541292
      null_instance_accepted = x                            "541292
    CHANGING
      instance               = mb_document_badi.
  IF NOT mb_document_badi IS INITIAL.                       "541292
    CALL METHOD mb_document_badi->mb_document_before_update
      EXPORTING
        xmkpf  = xmkpf[]
        xmseg  = xmseg[]
        xvm07m = xvm07m[].
  ENDIF.                                                    "541292

*------ internal BADI before update: MB_DOCUMENT_BEFORE_UPDATE
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_DOCUMENT_BADI_SAP'
      null_instance_accepted = x
    CHANGING
      instance               = if_mb_document_badi_sap.

  IF NOT if_mb_document_badi_sap IS INITIAL.
    CALL METHOD if_mb_document_badi_sap->mb_document_before_update
      EXPORTING
        xmkpf  = xmkpf[]
        xmseg  = xmseg[]
        xvm07m = xvm07m[].
  ENDIF.

*------ documentary batch ---------------------------------------------*
  IF g_docubatch_active = x.
    CALL FUNCTION 'VBDBDM_INIT_SUPPRESS_RESET'.             "1357398
    CALL FUNCTION 'VBDBDM_DATA_POST_IM'
      EXPORTING
        i_mkpf        = xmkpf
        it_mseg       = xmseg[]
        it_vm07m      = xvm07m[]
        it_dm07m      = zdm07m[]
        it_mbuz       = ymbuz[]
        i_buffer_only = xmigo.
  ENDIF.
*------ Batch Where-Used List ----------------------------------------*
* fill VBELN POSNR for deliveries and stock transfer orders
  DATA:
      lv_xblnr1 LIKE mkpf-xblnr,
      lv_xblnr2 LIKE mkpf-xblnr,
      lv_vbeln  LIKE likp-vbeln,
      lv_vbtyp  LIKE likp-vbtyp,
      lv_belnr  LIKE ekbe-belnr.
      FIELD-SYMBOLS:
        <fs_vbeln>        TYPE vbeln_vl,
        <fs_vbtyp>        TYPE vbtyp.
      CONSTANTS:
        lc_poker_vbeln    TYPE string VALUE '(SAPMV50A)LIKP-VBELN',
        lc_poker_vbtyp    TYPE string VALUE '(SAPMV50A)LIKP-VBTYP'.

  IF NOT xmkpf-xblnr IS INITIAL.
    LOOP AT xchvw.
      CASE xmkpf-vgart.
* goods receipt for purchase order
        WHEN 'WE'.
          READ TABLE zdm07m
            INTO ls_dm07m
            WITH KEY zeild = xchvw-zeile.
* only for stock transfer orders
          CHECK ls_dm07m-reswk IS NOT INITIAL.
* determine VBTYP
      IF lv_vbtyp IS INITIAL.
        lv_xblnr1 = xmkpf-xblnr.
        SHIFT lv_xblnr1 LEFT
          DELETING LEADING space.
        lv_xblnr2 = lv_xblnr1.
        CONDENSE lv_xblnr2 NO-GAPS.
        IF lv_xblnr2 EQ lv_xblnr1 AND
           lv_xblnr2 CO ' 0123456789'.
          UNPACK lv_xblnr2 TO lv_vbeln.
          SELECT SINGLE vbtyp
            INTO lv_vbtyp
            FROM likp
            WHERE vbeln EQ lv_vbeln.
* look into buffer
          IF NOT sy-subrc IS INITIAL.
            ASSIGN (lc_poker_vbeln) TO <fs_vbeln>.
            ASSIGN (lc_poker_vbtyp) TO <fs_vbtyp>.
            IF <fs_vbeln> IS ASSIGNED AND
               <fs_vbeln> EQ lv_vbeln.
              lv_vbtyp = <fs_vbtyp>.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_vbtyp NE 'J' AND              " outbound delivery
         lv_vbtyp NE 'T'.                 " returns delivery 1488347
        EXIT.
      ELSE.
        IF xmkpf-vgart EQ 'WE'.
          CLEAR lv_belnr.
          SELECT SINGLE belnr
            INTO  lv_belnr
            FROM  ekbe
            WHERE ebeln EQ xchvw-ebeln
              AND ebelp EQ xchvw-ebelp
              AND belnr EQ lv_vbeln.
          IF lv_belnr NE lv_vbeln.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
* goods issue for delivery
        WHEN 'WL'.
          IF NOT xmkpf-xblnr IS INITIAL.
            IF xmkpf-xblnr CO ' 0123456789'.
              UNPACK xmkpf-xblnr to lv_vbeln.
            ELSE.
              lv_vbeln = xmkpf-xblnr.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          EXIT.
      ENDCASE.

      xchvw-vbeln = lv_vbeln.       " delivery number
      READ TABLE xvm07m
        INTO ls_vm07m
        WITH KEY zeilv = xchvw-zeile.
      xchvw-posnr = ls_vm07m-vbelp.
      MODIFY xchvw
        TRANSPORTING vbeln posnr.
    ENDLOOP.
  ENDIF.

  IF NOT xchvw[] IS INITIAL.
*--> n:m batch relationship for purchase order: EHP5
    IF cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) = cl_ops_switch_check=>switch_active_true.
      CALL FUNCTION 'N2M_PUR_UPDATE_MM'
        EXPORTING
          it_mseg          = xmseg[]
          it_vm07m         = xvm07m[]
          iv_stbw          = zdm07m-xstbw
        EXCEPTIONS
          class_copy_error = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                     sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'VB_BATCH_WHERE_USED_LIST'
      IN UPDATE TASK
      TABLES
        xchvw = xchvw.

    CALL FUNCTION 'PRE_RELATION_ADJUST'
      EXPORTING
        it_chvw = xchvw[].
  ENDIF.
*------ Raise BOR-event for A2A communication by enterprise SOA-------*
  GET BADI lo_mb_doc_raise_a2a.
  CALL BADI lo_mb_doc_raise_a2a->raise_bor_event
    EXPORTING
      is_mkpf = xmkpf
      it_mseg = xmseg[].

*------ Rechnungswesen           -------------------------------------*
ENHANCEMENT-POINT buchen_ausfuehren_12 SPOTS es_sapmm07m.
* do not call accounting interface and commitments,
* if LOG-FIN decoupling is active

* Obsolete
* The coding within this switch check is not in use
  IF cl_log_dcfl_switch_check=>log_dcfl_swfs_01_rs( ) = abap_false.
    IF NOT upd_rw IS INITIAL.
      awref = xmkpf-mblnr.
      aworg(4) = xmkpf-mjahr.
      CALL FUNCTION 'CKMV_AC_DOCUMENT_POST'
        EXPORTING
          i_awsys       = awsys
          i_awtyp       = rw_awtyp
          i_awref       = awref
          i_aworg       = aworg
        EXCEPTIONS
          error_message = 4.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
*------ Aufträge (ohne Wert für CO )----------------------------------*
      READ TABLE zfabe INDEX 1.
      IF sy-subrc IS INITIAL.
        awref = xmkpf-mblnr.
        aworg(4) = xmkpf-mjahr.
        CALL FUNCTION 'CO_DOCUMENT_POST'
          EXPORTING
            i_awsys       = awsys
            i_awtyp       = rw_awtyp
            i_awref       = awref
            i_aworg       = aworg
          EXCEPTIONS
            error_message = 4.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE ID sy-msgid TYPE a NUMBER sy-msgno WITH
                     sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.

* post po commitments -> has to be done AFTER CKMV_AC_DOCUMENT_POST!!!!
    READ TABLE xekbe INDEX 1.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'ME_STATISTICS_RKO_POST'.
    ENDIF.                                                  "624127
  ENDIF.

* BAdI: MB_DOC_BADI_INTERNAL (SAP-internal). BAdI is called after
* function module 'CKMV_AC_DOCUMENT_POST' (requested by country version
* India).
* Caution: the FI-document number has already been created. If a message
* is issued in this BAdI there will be a gap in the FI-document numbers.
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = 'MB_DOC_BADI_INTERNAL'       "541292
      null_instance_accepted = x                            "541292
    CHANGING
      instance               = mb_doc_badi_internal.
  IF NOT mb_doc_badi_internal IS INITIAL.                   "541292
    CALL METHOD mb_doc_badi_internal->mb_document_before_update
      EXPORTING
        xmkpf  = xmkpf[]
        xmseg  = xmseg[]
        xvm07m = xvm07m[].
  ENDIF.                                                    "541292

*------ Nota Fiscal ---------------------------------------------------*
  PERFORM j_1b_nf_document_save.       "localization Brazil

ENHANCEMENT-POINT buchen_ausfuehren_06 SPOTS es_sapmm07m.

* Aufruf SLL
  PERFORM sll_document_activate.

  end_secon.
* Ende Zweiter Schritt

ENHANCEMENT-POINT buchen_ausfuehren_07 SPOTS es_sapmm07m.

* ---------------------------------------------------------------------
* This CLEAR MUST always be the last statement. DO NOT insert code
* after this line.
  CLEAR: statics_lock.

ENDFORM.                    "buchen_ausfuehren

* begin of note 434093
*----------------------------------------------------------------------*
*      Form XAB_NUMMER                                                 *
*----------------------------------------------------------------------*
* Move the access of XAB Number from FORM BUCHEN_NUMMERNVERGABE        *
* into the new function MB_XAB_NUMBER_GET.                             *
* ---> note 434093                                                     *
*----------------------------------------------------------------------*
FORM xab_nummer USING mkpf_xabln LIKE mkpf-xabln.
  READ TABLE xmkpf INDEX 1.
  PERFORM xab-nummer_vergeben(sapmm07m).
  MODIFY xmkpf INDEX 1 TRANSPORTING xabln.
  mkpf_xabln = xmkpf-xabln.
ENDFORM.                    "xab_nummer
* end of note 434093


ENHANCEMENT-POINT mm07mfb9_buchen_ausfuehren_009 SPOTS es_sapmm07m STATIC .

*&---------------------------------------------------------------------*
*&      Form  migo_mbuz_adjustment
*&---------------------------------------------------------------------*
*  MIGO: correction of lt_sermbuz for subcontracting and subsequent
*  adjustment.
*  Serial number management asks three times for the line numbers or
*  the item sequence of the material document:
*  Function                    interface          called by
*  DOCUMENT_SERIALNOS_IMPORT   pt_goserial_post   SAPLMIGO
*  SERNR_ADD_BAPI_MM           dm07m-serial_glc   SAPMM07M
*  SERIALPROFILE_CHECK (MMRN)  lt_sermbuz         SAPMM07M
*  lt_sermbuz needs to tally the information passed over by the two
*  previous calls of serial number management
*  added by note 734758
*----------------------------------------------------------------------*
FORM migo_mbuz_adjustment CHANGING ct_sermbuz TYPE ty_t_mbuz.
* correction is only necessary for subcontracting or subsequet
* adjustment in MIGO -> check content of gt_subcon_parent.
  DATA: ls_sb_parent TYPE ty_subcon_parent.
  READ TABLE gt_subcon_parent INTO ls_sb_parent
                              INDEX 1.
  CHECK sy-subrc IS INITIAL.

  FIELD-SYMBOLS: <mseg> TYPE mseg.
  DATA: l_sertabix      TYPE mbuz,
        l_tabix         TYPE sy-tabix,
        l_nc_count      TYPE sy-tabix,
        l_new_comp      TYPE c,
        l_itemseq       TYPE c,                             "1041122
        ls_comp         TYPE gocomp,
        ls_sermbuz      TYPE mbuz.

  IF ls_sb_parent-kzbew = o.
* Rearrangement of lt_sermbuz in case of subsequent adjustment is
* necessary because the item sequence of MIGO is changed in
* mb_create_goods_movement
    LOOP AT xmseg ASSIGNING <mseg>.
      l_tabix = sy-tabix.
      READ TABLE ct_sermbuz INTO ls_sermbuz INDEX l_tabix.
      IF NOT <mseg>-parent_id IS INITIAL.
        READ TABLE gt_gocomp INTO ls_comp
                             WITH KEY global_counter = <mseg>-line_id.
        ls_sermbuz-zeilz = ls_comp-serial_glc.
      ELSE.
        ls_sermbuz-zeilz = 0.
      ENDIF.
      MODIFY ct_sermbuz FROM ls_sermbuz INDEX l_tabix.
    ENDLOOP.
  ELSEIF ls_sb_parent-kzbew = b.
*  Correction of lt_sermbuz for subcontracting components that
*  were expanded automatically in MB_CREATE_GOODS_MOVMENT.
*  lt_sermbuz contains the line number that was published to serial
*  number management by FUNCTION SERNR_ADD_BAPI_MM. But components
*  expanded by lmbwlu14 did not exist when SERNR_ADD_BAPI_MM was called.
*  Therefore for them lt_sermbuz-zeilz is set to 0. For all items
*  following such a component lt_sermbuz-zeilz needs to be reduced by
*  one
    LOOP AT xmseg ASSIGNING <mseg>.
      l_tabix = sy-tabix.
      CLEAR l_new_comp.
      IF NOT <mseg>-parent_id IS INITIAL.
        READ TABLE gt_gocomp INTO ls_comp
                             WITH KEY global_counter = <mseg>-line_id.
        IF sy-subrc <> 0.
*       this component must have been expanded by lmbwlu14.
          l_new_comp = x.
          l_nc_count = l_nc_count + 1.
        ELSEIF NOT ls_comp-serial_glc = <mseg>-zeile        "1041122
*       sequence changed by item split                          "1041122
           AND NOT ls_comp-serial_glc IS INITIAL.           "1041122
          l_itemseq = x.                                    "1041122
        ENDIF.
      ELSEIF   xmigo = x                                    "1098491
       AND     <mseg>-line_id = ls_sb_parent-line_id        "1098491
       AND NOT <mseg>-zeile = ls_sb_parent-serial_glc       "1098491
       AND NOT ls_sb_parent-serial_glc IS INITIAL.          "1098491
*       header line sequence changed  by MIGO sort              "1098491
        READ TABLE ct_sermbuz INTO ls_sermbuz INDEX l_tabix. "1098491
        IF sy-subrc = 0.                                    "1098491
*         replace item by SERIAL_GLC. The same information had  "1098491
*         been used on calling SERNR_ADD_BAPI_MM (n734758)      "1098491
          ls_sermbuz-zeilz = ls_sb_parent-serial_glc.       "1098491
          MODIFY ct_sermbuz FROM ls_sermbuz INDEX l_tabix.  "1098491
        ENDIF.                                              "1098491
      ENDIF.
      IF NOT l_nc_count IS INITIAL.
        READ TABLE ct_sermbuz INTO ls_sermbuz INDEX l_tabix.
        IF l_new_comp IS INITIAL.
          ls_sermbuz-zeilz = ls_sermbuz-zeilz - l_nc_count.
        ELSE.
          ls_sermbuz-zeilz = 0.
        ENDIF.
        MODIFY ct_sermbuz FROM ls_sermbuz INDEX l_tabix.
      ELSEIF NOT l_itemseq IS INITIAL.                      "1041122
*       replace item by SERIAL_GLC. The same information had    "1041122
*       been used on calling SERNR_ADD_BAPI_MM (n734758)        "1041122
        READ TABLE ct_sermbuz INTO ls_sermbuz INDEX l_tabix. "1041122
        ls_sermbuz-zeilz = ls_comp-serial_glc.              "1041122
        MODIFY ct_sermbuz FROM ls_sermbuz INDEX l_tabix.    "1041122
        CLEAR l_itemseq.                                    "1041122
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " migo_mbuz_adjustment

*&------------------------------------------------------------------ *
*&      Form  barcode_update
*&*
*  Redesign of barcode handling -> note 780365
**&------------------------------------------------------------------*
*&      Form  barcode_update
*&-------------------------------------------------------------------*
*  Redesign of barcode handling -> note 780365
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
FORM barcode_update USING iv_mblnr   TYPE mkpf-mblnr
                          iv_mjahr   TYPE mkpf-mjahr
                          iv_barcode TYPE saebarcode.

  DATA:
    lv_object   TYPE saeobjid,
    lv_no_popup TYPE saearstat.

  CHECK xoarc = x.
  lv_object       = iv_mblnr.
  lv_object+10(4) = iv_mjahr.
  IF iv_barcode IS INITIAL.
    lv_no_popup = space.
  ELSE.
    lv_no_popup = 'X'.
  ENDIF.
  CALL FUNCTION 'ARCHIV_BARCODE_GLOBAL'
    EXPORTING
      ar_object             = 'MMIDELNTOR'
*     no_doc_change         = space
      object_id             = lv_object
      sap_object            = 'BUS2017'
      updatetask            = 'X'
*     no_check              = space
      no_popup              = lv_no_popup
      barcode               = iv_barcode
    EXCEPTIONS
      error_connectiontable = 1
      no_barcode            = 2
      user_exit             = 3
      no_authority          = 4
      OTHERS                = 5.
  CASE sy-subrc.
    WHEN 0.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

ENDFORM.                    "barcode_update*
*&---------------------------------------------------------------------*
*&      Form  bapi_mbuz_adjustment
*&---------------------------------------------------------------------*
*  Hint 924222
*  Subcontractor components (maybe other components)        [='SUB']
*  There are no IMSEG's for SUB! Serialno-coding reads with 'old'
*  ZEILZ in YMBUZ -> SY-TABIX will be 'final' mat.doc. position.
*  => Order of ZEILZ has to changed, or the 'final' pos. is wrong!
*  added by note 1305085, 1153281, 1227771
*----------------------------------------------------------------------*
FORM bapi_mbuz_adjustment CHANGING ct_sermbuz TYPE ty_t_mbuz.
*     Replaced note 924222 by 1153281
*     Expanded solution for subsequent adjustment
*     If we have a subsequent adjustment there is no mother
*     segment in table ydm07m, this must be considered
  FIELD-SYMBOLS: <fs_mseg>    TYPE mseg,
                 <fs_sermbuz> TYPE mbuz,
                 <fs_ydm07m>  TYPE dm07m.

  DATA:          l_tabix      TYPE sy-tabix,
                 ls_mseg      TYPE mseg.

  LOOP AT xmseg ASSIGNING <fs_mseg>.
    l_tabix = sy-tabix.
    CLEAR: ls_mseg.
*        it seems that some applications calling our BAPI with "1341262
*        the LINE_ID filled for other purposes than we expected"1341262
*        if mother segment has no daughter segment, this       "1341262
*        position is defined as not relevant for re-assigning. "1341262
*        relevant for re-assigning is subcon and transfer      "1341262
    IF <fs_mseg>-parent_id IS INITIAL AND                   "1341262
       <fs_mseg>-line_id   IS NOT INITIAL.                  "1341262
      READ TABLE xmseg                                      "1341262
           WITH KEY parent_id = <fs_mseg>-line_id           "1341262
           TRANSPORTING NO FIELDS.                          "1341262
      IF sy-subrc IS NOT INITIAL.                           "1495903
*           mother segment has no daughter                     "1495903
        READ TABLE zvm07m                                   "1495903
             WITH KEY pstyp = '3'                           "1495903
             TRANSPORTING NO FIELDS.                        "1495903
*             at least one SC position is contained in the     "1495903
*             MM document, all items have to be re-assigned    "1495903
        CHECK sy-subrc = 0.                                 "1495903
      ENDIF.                                                "1495903
    ENDIF.                                                  "1341262

    READ TABLE ct_sermbuz ASSIGNING <fs_sermbuz>
              INDEX l_tabix.
    IF sy-subrc <> 0.
*         No entry - skip operation
      CONTINUE.
    ENDIF.
    IF NOT <fs_mseg>-parent_id IS INITIAL.
*         ******* Take over Line ID for daugther segment *****
      IF vm07m-xstor <> '2'.
*           Normal subcontracting case, both goods receipt
*           and subsequent adjustment
        READ TABLE ydm07m ASSIGNING <fs_ydm07m>
             WITH KEY serial_glc = <fs_mseg>-line_id.
        IF sy-subrc <> 0.
          IF <fs_mseg>-ummat IS INITIAL.                    "1305085
*                     clear zeilz to avoid error               "1305085
            <fs_sermbuz>-zeilz = 0.                         "1305085
          ENDIF.                                            "1305085
          CONTINUE.
        ENDIF.
        <fs_sermbuz>-zeilz = <fs_ydm07m>-serial_glc.
      ELSE.
*           In cancel case takeover from mseg
*           unfortunately this coding is also processded by    "1227771
*           other GMs, e.g. transfer postings                  "1227771
        IF <fs_mseg>-ummat IS INITIAL.                      "1227771
*               posting is no transfer                         "1227771
*               Get parent to determine if child is subs adj   "1305085
          READ TABLE xmseg INTO ls_mseg                     "1305085
               WITH KEY line_id = <fs_mseg>-parent_id.      "1305085
          IF ls_mseg-menge IS INITIAL                       "1305085
             AND vm07m-pstyp = '3'.                         "1305085
            <fs_sermbuz>-zeilz = <fs_mseg>-line_id.
          ELSE.                                             "1305085
*                    normal reversal, leave original           "1305085
            CONTINUE.                                       "1305085
          ENDIF.                                            "1305085
        ELSE.                                               "1227771
*               posting is a transfer                          "1227771
          READ TABLE ydm07m ASSIGNING <fs_ydm07m>           "1227771
          INDEX <fs_sermbuz>-zeile.                         "1227771
          IF sy-subrc <> 0.
*               No entry - skip operation
            CONTINUE.
          ENDIF.
          <fs_sermbuz>-zeilz =                              "1227771
                       <fs_ydm07m>-imseg_original.          "1227771
        ENDIF.                                              "1227771
      ENDIF.
    ELSE.
*         ******* Take over Line ID for mother segment *******
      IF vm07m-xstor <> '2'.                                "1227771
*               no reversal                                    "1227771
        IF <fs_mseg>-ummat IS INITIAL.                      "1659875
          <fs_sermbuz>-zeilz = <fs_mseg>-line_id.
*       stock transfer                                      "1659875
        ELSE.                                               "1659875
          CONTINUE.                                         "1659875
        ENDIF.                                              "1659875

      ELSE.                                                 "1227771
        IF <fs_mseg>-ummat IS INITIAL.                      "1227771
*                no transfer reversal                          "1227771
*                check for subs adj - is mother a subs adj?    "1305085
          IF <fs_mseg>-menge IS INITIAL                     "1305085
             AND vm07m-pstyp = '3'.                         "1305085
            <fs_sermbuz>-zeilz = <fs_mseg>-line_id.
          ELSE.                                             "1305085
*                     normal reversal, leave original          "1305085
            CONTINUE.                                       "1305085
          ENDIF.                                            "1305085
        ELSE.                                               "1227771
*                transfer reversal                             "1227771
          READ TABLE ydm07m ASSIGNING <fs_ydm07m>           "1227771
          INDEX <fs_sermbuz>-zeile.                         "1227771
          IF sy-subrc <> 0.
*                No entry - skip operation
            CONTINUE.
          ENDIF.
          <fs_sermbuz>-zeilz =                              "1227771
                        <fs_ydm07m>-imseg_original.         "1227771
        ENDIF.                                              "1227771
      ENDIF.                                                "1227771
    ENDIF.
  ENDLOOP.
ENDFORM.                    " bapi_mbuz_adjustment