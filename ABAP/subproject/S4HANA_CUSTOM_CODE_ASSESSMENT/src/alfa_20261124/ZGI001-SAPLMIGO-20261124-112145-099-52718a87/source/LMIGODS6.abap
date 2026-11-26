*----------------------------------------------------------------------*
*   INCLUDE LMIGODS6                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_determine_stock IMPLEMENTATION.

************************************************************************
* Constructor
************************************************************************
  METHOD constructor.
    DATA: lt_sending     TYPE lif_migo_frame=>ty_t_message_ids,
          lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids.
    lif_migo_frame~class_id = 'MIGO_DETERMINE_STOCK'.
    APPEND 'DETERMINE_SINGLE'       TO lt_receiving.
    APPEND 'DETERMINE_SINGLE_RIGHT' TO lt_receiving.
    APPEND 'DETERMINE_ALL'          TO lt_receiving.
    APPEND 'MODEL_CHANGE_BEGIN'     TO lt_sending.
    APPEND 'MODEL_CHANGE_COMPLETE'  TO lt_sending.
    APPEND 'MIGO_TIP_REQUEST'       TO lt_sending.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_receiving  = lt_receiving
        it_sending    = lt_sending.
  ENDMETHOD.                    "constructor
************************************************************************
* Message handler
************************************************************************
  METHOD lif_migo_frame~message_handler.
    DATA: l_line TYPE sytabix.
    CASE i_message_id.
      WHEN 'DETERMINE_SINGLE'.
        l_line = is_message-data1.
        CALL METHOD determine_single( i_line = l_line ).
      WHEN 'DETERMINE_SINGLE_RIGHT'.
        l_line = is_message-data1.
        CALL METHOD determine_single
          EXPORTING
            i_line     = l_line
            i_transdet = abap_true.
      WHEN 'DETERMINE_ALL'.
        CALL METHOD determine_all.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~message_handler
* Empy OK-code-handler
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler
************************************************************************
* Determine stock for a single line
************************************************************************
  METHOD determine_single.
    DATA: lt_cdstock         TYPE STANDARD TABLE OF cdstock,
          ls_cdstock         TYPE cdstock,
          ls_cdcom           TYPE cdcom,
          ls_goitem_original TYPE goitem,
          l_umren            TYPE umren,
          l_umrez            TYPE umrez,
          l_rc_t160m_check   TYPE sy-subrc,                 "554870
          l_quantity_det     TYPE erfmg,                    "554870
          l_quantity_sum     TYPE erfmg,                    "554870
          l_text1(20)        TYPE c,                        "554870
          l_text2(20)        TYPE c,                        "554870
          l_string1          TYPE string,                   "554870
          l_string2          TYPE string,                   "554870
          ls_ekko            TYPE ekko,
          ls_ekpo            TYPE ekpo.

    DATA: ls_available       TYPE atpcs,                    "666463
          lt_available       TYPE TABLE OF atpcs.           "562898
    DATA: l_bwart            TYPE bwart,                    "672905
          l_status_charg     TYPE migo_fs_status,           "1032729
          l_bmonat           TYPE bkpf-monat,               "1034506
          l_bgjahr           TYPE bkpf-gjahr,               "1034506
          ls_marv            TYPE marv.                     "1034506


    FIELD-SYMBOLS: <ls_cdstock> TYPE cdstock.
    CHECK i_line <> 0.
* Get the original line
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING
        i_line    = i_line
      IMPORTING
        es_goitem = ls_goitem_original.
* Only operate on lines which allow stock determination.
* In theory, this method cannot be called for other lines as
* either there should be no button to press or the "determine all"
* method evaluates it. But we learned that theory is not
* the correct approach to R/3.
    CHECK ( ls_goitem_original-xdetermination = abap_true
            AND i_transdet = abap_false ) OR
          ( ls_goitem_original-xumdetermination = abap_true
            AND i_transdet = abap_true ).
* no batch determination for bwart 352                          "810352
    IF NOT ls_goitem_original-ebeln IS INITIAL AND
       NOT ls_goitem_original-kzzug IS INITIAL AND
       ls_goitem_original-kzbew IS INITIAL.
      CHECK ls_goitem_original-shkzg = 'H'.
    ENDIF.
* Fill data for stock determination function module
    MOVE-CORRESPONDING ls_goitem_original TO ls_cdcom.
* Fill vendor for batch determination                            "711136
    IF ls_cdcom-lifnr IS INITIAL
       AND NOT ls_cdcom-xchpf IS INITIAL
       AND ( ls_cdcom-sobkz = 'K' OR ls_cdcom-sobkz = 'M'
             OR ls_cdcom-sobkz = 'O' ).
      MOVE ls_goitem_original-mat_lifnr TO ls_cdcom-lifnr.
    ENDIF.
* Fill customer for batch determination                         "1596851
    IF ls_cdcom-kunnr IS INITIAL                                "1596851
       AND NOT ls_cdcom-xchpf IS INITIAL                        "1596851
       AND ( ls_cdcom-sobkz = 'W' OR ls_cdcom-sobkz = 'V' ).    "1596851
      MOVE ls_goitem_original-mat_kunnr TO ls_cdcom-kunnr.      "1596851
    ENDIF.                                                      "1596851
* Get insmk for batch selection                                  "650835
    IF ls_goitem_original-xstock_type_mvt = x.
      CALL METHOD oref_determine_stock->determine_insmk
        EXPORTING
          ls_goitem_original = ls_goitem_original
        CHANGING
          ls_cdcom           = ls_cdcom.
    ENDIF.
* Save UMREN/UMREZ
    l_umren = ls_goitem_original-umren.
    l_umrez = ls_goitem_original-umrez.
* UMREN/UMREZ is not necessary to call stock determination function.
    CLEAR: ls_cdcom-umren,
           ls_cdcom-umrez.
* Fill special fields for stock determination function module
* with transfer fields.
    IF i_transdet = abap_true.
      CASE ls_goitem_original-shkzg_migo.
        WHEN '+'.
          ls_cdcom-shkzg_migo = '-'.
        WHEN '-'.
          ls_cdcom-shkzg_migo = '+'.
      ENDCASE.
      CASE ls_goitem_original-shkzg.
        WHEN s.
          ls_cdcom-shkzg = h.
        WHEN h.
          ls_cdcom-shkzg = s.
      ENDCASE.
      ls_cdcom-matnr = ls_goitem_original-ummat.
      ls_cdcom-maktx = ls_goitem_original-ummaktx.
      ls_cdcom-werks = ls_goitem_original-umwrk.
      ls_cdcom-charg = ls_goitem_original-umcha.
      ls_cdcom-lgort = ls_goitem_original-umlgo.
      ls_cdcom-sobkz = ls_goitem_original-umsok.
      ls_cdcom-sotxt = ls_goitem_original-umsotxt.
      ls_cdcom-vbeln = ls_goitem_original-ummat_kdauf.
      ls_cdcom-posnr = ls_goitem_original-ummat_kdpos.
      ls_cdcom-pspnr = ls_goitem_original-ummat_pspnr.
      ls_cdcom-kunnr = ls_goitem_original-ummat_kunnr.
      ls_cdcom-lifnr = ls_goitem_original-ummat_lifnr.
      ls_cdcom-bwtar = ls_goitem_original-umbar.
      ls_cdcom-bwtty = ls_goitem_original-umbwtty.
      ls_cdcom-xchpf = ls_goitem_original-umxchpf.
      ls_cdcom-eprio = ls_goitem_original-umeprio.
      ls_cdcom-umwrk = ls_goitem_original-werks.
      ls_cdcom-umlgo = ls_goitem_original-lgort.
*   In MIGO no UMINSMK, UMLBBSA exists because T156M table is not
*   analyzed.

*    CLEAR: ls_cdcom-insmk,
*           ls_cdcom-lbbsa.
* Fill special fields for stock determination function module
* with original fields.
    ELSE.
      ls_cdcom-pspnr = ls_goitem_original-mat_pspnr.
      ls_cdcom-vbeln = ls_goitem_original-mat_kdauf.
      ls_cdcom-posnr = ls_goitem_original-mat_kdpos.
*   Consignment stock should not be called during a goods receipt
*   except for reservations or GR w/o reference.
      IF ls_goitem_original-sobkz IS INITIAL AND NOT
         ( lcl_migo_globals=>kernel->s_control-refdoc = 'R09' OR
           lcl_migo_globals=>kernel->s_control-refdoc = 'R10' OR
*         ...and in case of copying a GR w/o reference from another
*            material document (refdoc is 'R02')
*            If the copy-functionality is being extended, this condition
*            has to be extended, too.                             ERP 10
           NOT lcl_migo_globals=>kernel->s_action-copy IS INITIAL
         )
         AND ls_goitem_original-shkzg_migo = '+'.
        ls_cdcom-xncsg = 'F'.
      ENDIF.
    ENDIF.
* Fill ls_cdcom with fields from Purchase Order (configuration)
    IF NOT ls_goitem_original-ebeln IS INITIAL AND
       NOT ls_goitem_original-ebelp IS INITIAL.
      CALL FUNCTION 'ME_EKKO_SINGLE_READ'
        EXPORTING
          pi_ebeln = ls_goitem_original-ebeln
        IMPORTING
          po_ekko  = ls_ekko
        EXCEPTIONS
          OTHERS   = 0.
      CALL FUNCTION 'ME_EKPO_SINGLE_READ'
        EXPORTING
          pi_ebeln = ls_goitem_original-ebeln
          pi_ebelp = ls_goitem_original-ebelp
        IMPORTING
          po_ekpo  = ls_ekpo
        EXCEPTIONS
          OTHERS   = 0.
      ls_cdcom-cuobj_conf = ls_ekpo-cuobj.
ENHANCEMENT-POINT EHP603_DETERMINE_SINGLE_01 SPOTS ES_SAPLMIGO_SHLF.

    ENDIF.
* Fill application
    ls_cdcom-kappl = 'ME'.
* create/change of batch determination selection criteria - note 522424
    ls_cdcom-objid = 'MSEG'.
    ls_cdcom-objec = ls_goitem_original-global_counter.
* Send tip
    IF i_massproc IS INITIAL.
      def_sms 'MIGO_TIP_REQUEST' 'HELP_MIGO_DELETE_LINE' space.
    ENDIF.

    DATA: l_shortage_plant TYPE c.                          "703419

    CALL METHOD lcl_migo_globals=>kernel->availability_check"562898
      EXPORTING ls_goitem = ls_goitem_original              "562898
                l_transdet = i_transdet                     "562898
      IMPORTING lt_availability = lt_available              "562898
                e_shortage_plant = l_shortage_plant         "703419
      CHANGING  ls_cdcom = ls_cdcom.                        "562898
    IF NOT ls_goitem_original-rsnum IS INITIAL.             "666463
      READ TABLE lt_available                               "666463
        INTO ls_available                                   "666463
        WITH KEY delnr = ls_goitem_original-rsnum           "666463
                 delps = ls_goitem_original-rspos.          "666463
      IF sy-subrc IS INITIAL.                               "666463
        ls_cdcom-delnr = ls_available-delnr.                "666463
        ls_cdcom-delps = ls_available-delps.                "666463
        ls_cdcom-delkz = ls_available-delkz.                "666463
      ENDIF.                                                "666463
    ENDIF.                                                  "666463
* l_shortage_plant= E means there is not enough ATP Quantity on plant
* level -> stock-/batch determination is not possible in this case.
* The corresponding error messages are stored in oref_atp_log
    IF l_shortage_plant ='E'.
*   unfortunately we have to exit here even in mass processing.
*   Otherwise the line number in the error message might not be correct
*   anymore
      CALL METHOD oref_atp_log->display.
      EXIT.
    ENDIF.

*   combination movement type and SOBKZ = K or P possible?
    SELECT SINGLE bwart INTO l_bwart                        "672905
                        FROM t156b                          "672905
                        WHERE bwart = ls_cdcom-bwart        "672905
                          AND sobkz = k.                    "672905

    IF NOT sy-subrc IS INITIAL OR i_transdet = x.           "672905
*   BF_STOCK_DETERMINATION does not return consignment or pipeline stock
*   if XNCSG = F.
      ls_cdcom-xncsg = f.                                   "672905
    ENDIF.                                                  "672905

* batch from reference document, batch is not changeable       "1032729
    IF NOT ls_goitem_original-batch_from_refdoc IS INITIAL. "1032729
      CALL METHOD lcl_migo_screenmodification=>get          "1032729
           EXPORTING i_field          = 'GOITEM-CHARG'      "1032729
                     i_global_counter =                     "1032729
                     ls_goitem_original-global_counter      "1032729
           RECEIVING r_status         = l_status_charg.     "1032729
      IF l_status_charg = lcl_migo_screenmodification=>c_visible."1032729
        ls_cdcom-nobdt = abap_true.        "no batch detmination  1032729
      ENDIF.                                                "1032729
    ENDIF.                                                  "1032729

* determine if posting is done in previous periode/ year       "1034506
* first get the periode according to the inserted BUDAT        "1034506
    CALL FUNCTION 'FI_PERIOD_DETERMINE'                     "1034506
         EXPORTING i_bukrs = ls_goitem_original-bukrs_for_stock"1034506
                   i_budat = gohead-budat                   "1034506
         IMPORTING e_monat = l_bmonat                       "1034506
                   e_gjahr = l_bgjahr.                      "1034506
                                                            "1034506
* select marv entry for BUKRS                                  "1034506
    SELECT SINGLE * FROM marv                               "1034506
                    INTO ls_marv WHERE                      "1034506
                    bukrs = ls_goitem_original-bukrs_for_stock."1034506
                                                            "1034506
* check the periode and set XRUEM, XRUEJ if necessary          "1034506
    IF sy-subrc = 0.                                        "1034506
      IF l_bgjahr NE ls_marv-lfgja OR l_bmonat NE ls_marv-lfmon."1034506
*     posting to any other periode than the actual             "1034506
        IF l_bgjahr = ls_marv-vmgja AND l_bmonat = ls_marv-vmmon."1034506
*        posting to previous periode                           "1034506
          ls_cdcom-xruem = abap_true.                       "1034506
          IF ls_marv-lfgja NE ls_marv-vmgja.                "1034506
*         previous periode is also the last year periode       "1034506
            ls_cdcom-xruej = abap_true.                     "1034506
          ENDIF.                                            "1034506
        ELSE.                                               "1034506
          IF  l_bgjahr = ls_marv-vjgja                      "1034506
          AND l_bmonat = ls_marv-vjmon.                     "1034506
*          posting to last year periode, both flags are set    "1034506
            ls_cdcom-xruem = abap_true.                     "1034506
            ls_cdcom-xruej = abap_true.                     "1034506
          ENDIF.                                            "1034506
        ENDIF.                                              "1034506
      ELSE.                                                 "1034506
*     posting periode is current periode, nothing to change    "1034506
      ENDIF.                                                "1034506
    ELSE.                                                   "1034506
*   marv entry has not been found, continue                    "1034506
    ENDIF.                                                  "1034506

* Execute
    CALL FUNCTION 'VB_COMPLETE_DETERMINATION'
      TABLES
        e_cdstock                 = lt_cdstock
        i_atpcsx                  = lt_available            "562898
      CHANGING
        x_cdcom                   = ls_cdcom
      EXCEPTIONS
        no_determination_possible = 1
        no_material               = 2
        no_plant                  = 3
        data_mismatch             = 4
        error_message             = 5
        OTHERS                    = 6.
* Message from stock determination only if not in mass processing
    IF sy-subrc <> 0 AND i_massproc = abap_false.
      MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* Nothing found = nothing more to do...
    CHECK NOT lt_cdstock IS INITIAL.

* Can the requested stock be satisfied?
    l_quantity_det = ls_cdcom-erfmg.
    LOOP AT lt_cdstock ASSIGNING <ls_cdstock>.
      l_quantity_det = l_quantity_det - <ls_cdstock>-erfmg.
    ENDLOOP.
* Requested stock cannot be satisfied                          "554870
    IF l_quantity_det > 0.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb  = 'MIGO'
          i_msgnr  = '065'
          i_nolog  = abap_true
          i_output = abap_false
        IMPORTING
          rc       = l_rc_t160m_check.
      CASE l_rc_t160m_check.
*     Warning
        WHEN 1.
*       Do not update model and send W-message
          WRITE ls_cdcom-erfmg UNIT ls_cdcom-erfme TO l_text1.
          CONCATENATE l_text1 ls_cdcom-erfme INTO l_string1
             SEPARATED BY space.
          CONDENSE l_string1.
          l_quantity_det = 0.
          WRITE l_quantity_det UNIT ls_cdcom-erfme TO l_text2.
          CONCATENATE l_text2 ls_cdcom-erfme INTO l_string2
             SEPARATED BY space.
          CONDENSE l_string2.
          MESSAGE w065(migo) WITH l_string1 ls_cdcom-matnr l_string2.
          EXIT.
*     Information                                              "554870
        WHEN 5.
*       Update model and send W-message                        "554870
          CALL METHOD update_model_det
            EXPORTING
              i_line             = i_line
              i_massproc         = i_massproc
              i_umren            = l_umren
              i_umrez            = l_umrez
              i_transdet         = i_transdet
              it_cdstock         = lt_cdstock
              is_goitem_original = ls_goitem_original
              is_cdcom           = ls_cdcom.
          WRITE ls_cdcom-erfmg UNIT ls_cdcom-erfme TO l_text1.
          CONCATENATE l_text1 ls_cdcom-erfme INTO l_string1
             SEPARATED BY space.
          CONDENSE l_string1.
          l_quantity_sum = ls_cdcom-erfmg - l_quantity_det.
          WRITE l_quantity_sum UNIT ls_cdcom-erfme TO l_text2.
          CONCATENATE l_text2 ls_cdcom-erfme INTO l_string2
             SEPARATED BY space.
          CONDENSE l_string2.
          MESSAGE w065(migo) WITH l_string1 ls_cdcom-matnr l_string2.
*     Not maintained                                           "554870
        WHEN space.
*       Update model                                           "554870
          CALL METHOD update_model_det
            EXPORTING
              i_line             = i_line
              i_massproc         = i_massproc
              i_umren            = l_umren
              i_umrez            = l_umrez
              i_transdet         = i_transdet
              it_cdstock         = lt_cdstock
              is_goitem_original = ls_goitem_original
              is_cdcom           = ls_cdcom.
        WHEN OTHERS.
          EXIT.
      ENDCASE.
* Requested stock can be satisfied                             "554870
    ELSE.
      CALL METHOD update_model_det
        EXPORTING
          i_line             = i_line
          i_massproc         = i_massproc
          i_umren            = l_umren
          i_umrez            = l_umrez
          i_transdet         = i_transdet
          it_cdstock         = lt_cdstock
          is_goitem_original = ls_goitem_original
          is_cdcom           = ls_cdcom.
    ENDIF.

  ENDMETHOD.                    "determine_single
************************************************************************
* Determine stock for all line items single
************************************************************************
  METHOD determine_all.
    DATA: lt_glc_tab       TYPE STANDARD TABLE OF migo_global_counter,
          l_global_counter TYPE migo_global_counter,
          ls_goitem        TYPE goitem,
          l_line           TYPE sytabix,
          l_lines          TYPE sytabix.
* Send tip
    def_sms 'MIGO_TIP_REQUEST' 'HELP_MIGO_DELETE_LINE' space.
* Number of (visible) lines in the model
    l_lines = lcl_migo_globals=>kernel->s_status-lines.
* Extract GLCs of all affected lines
    DO l_lines TIMES.
      CALL METHOD lcl_migo_globals=>kernel->line_get
        EXPORTING
          i_line    = sy-index
        IMPORTING
          es_goitem = ls_goitem.
      IF ls_goitem-xdetermination = abap_true AND
         ls_goitem-take_it        = abap_true.
        APPEND ls_goitem-global_counter  TO lt_glc_tab.
      ENDIF.
    ENDDO.
* Begin mass operation
    def_sms 'MODEL_CHANGE_BEGIN' space space.
    LOOP AT lt_glc_tab INTO l_global_counter.
*   Find the correct line in the model
      CALL METHOD lcl_migo_globals=>kernel->line_mapping
        EXPORTING
          i_global_counter = l_global_counter
        IMPORTING
          e_line           = l_line
        EXCEPTIONS
          not_found        = 1.
*   Maybe the line has already been deleted, e.g. if it was the
*   component of a subcontracting. In this case, it's gone in the
*   moment the header component is deleted...
      CHECK sy-subrc = 0.
*   Stock determination for the single line
      CALL METHOD determine_single
        EXPORTING
          i_line     = l_line
          i_massproc = abap_true.
    ENDLOOP.
** note 703419 start
*  IF oref_atp_log->message_exist_all( i_error_only = abap_true )
*                  = abap_true.
*    CALL METHOD oref_atp_log->display.
*  endif.
** note 703419 end
    def_sms 'MODEL_CHANGE_COMPLETE' space space.
  ENDMETHOD.                    "determine_all

************************************************************************
* Update model after stock determination
************************************************************************
  METHOD update_model_det.                                  "554870
    DATA:          l_line             TYPE sytabix,
                   ls_goitem_new      TYPE goitem.
    FIELD-SYMBOLS: <ls_cdstock>       TYPE cdstock.

* Send message
    IF i_massproc = abap_false.
      def_sms 'MODEL_CHANGE_BEGIN' space space.
    ENDIF.
* Delete the old line (recursively for all children too), but only
* if more than one line comes back
    CALL METHOD lcl_migo_globals=>kernel->line_delete
      EXPORTING
        i_line = i_line.
* Insert the new lines into the model beginning at the position of the
* original line.
    l_line = i_line.
    LOOP AT it_cdstock ASSIGNING <ls_cdstock>.
      ls_goitem_new = is_goitem_original.
*   SINGLE MOVES from <ls_cdstock>-fieldname to ls_goitem-fieldname...
      ls_goitem_new-erfmg    = <ls_cdstock>-erfmg.
      ls_goitem_new-erfme    = <ls_cdstock>-erfme.
ENHANCEMENT-POINT lmigods6_01 SPOTS es_saplmigo.
      ls_goitem_new-umrez    = i_umrez.
      ls_goitem_new-umren    = i_umren.
*   Fill transfer fields from stock determination function module back
*   to original fields.
      IF i_transdet = abap_true.
        ls_goitem_new-umcha      = <ls_cdstock>-charg.
        ls_goitem_new-umlgo      = <ls_cdstock>-lgort.
        ls_goitem_new-umbar      = <ls_cdstock>-bwtar.
        ls_goitem_new-umsok      = <ls_cdstock>-sobkz.
        ls_goitem_new-umcuobj_ch = is_cdcom-cuobj_ch.
        IF <ls_cdstock>-sobkz CA 'KMO'.
          ls_goitem_new-ummat_lifnr = <ls_cdstock>-lifnr.
        ENDIF.
      ELSE.
        ls_goitem_new-charg    = <ls_cdstock>-charg.
        ls_goitem_new-lgort    = <ls_cdstock>-lgort.
        ls_goitem_new-bwtar    = <ls_cdstock>-bwtar.
        ls_goitem_new-sobkz    = <ls_cdstock>-sobkz.
        ls_goitem_new-cuobj_ch = is_cdcom-cuobj_ch.
        IF <ls_cdstock>-sobkz CA 'KMO'.                     "442689
          IF lcl_migo_globals=>kernel->s_action-migo_mode = 'GT'."649991
            ls_goitem_new-mat_lifnr    = <ls_cdstock>-lifnr."649991
          ELSE.                                             "649991
            ls_goitem_new-lifnr    = <ls_cdstock>-lifnr.    "649991
          ENDIF.                                            "649991
        ENDIF.                                              "442689
      ENDIF.
*   The new lines need new GLCs. Exception: Only one line comes
*   back.
      CLEAR ls_goitem_new-global_counter.
*   Insert the line. If only one line is expected
      CALL METHOD lcl_migo_globals=>kernel->line_modify
        EXPORTING
          i_line            = l_line
          i_insert          = abap_true
          i_authority_check = abap_false
          i_status_delayed  = abap_false
        CHANGING
          cs_goitem         = ls_goitem_new.
      l_line = l_line + 1.
    ENDLOOP.
* Final message to the viewers
    IF i_massproc = abap_false.
      def_sms 'MODEL_CHANGE_COMPLETE' space space.
    ENDIF.
  ENDMETHOD.                    "update_model_det

*----------------------------------------------------------------------*
*     Determine INSMK according to movement type
  METHOD determine_insmk.                                   "650835
    DATA:     l_cnt02         TYPE t156m-cnt02,
              l_zustd         TYPE t156m-zustd,
              l_kzuml         TYPE dm07m-kzuml,
              ls_t156m        TYPE t156m,
              l_t156m         TYPE t156m,
              ls_t156         TYPE t156,
              ls_s156s        TYPE st156s.

    SELECT SINGLE * FROM t156 INTO ls_t156
      WHERE bwart = ls_goitem_original-bwart.

    IF ls_t156-shkzg = h.
      l_cnt02 = '01'.
    ELSE.
      l_cnt02 = '02'.
    ENDIF.

    l_kzuml = x.

    IF ls_goitem_original-xauto = l.
      l_zustd = l.
    ELSEIF ls_goitem_original-xauto = m.
      l_zustd = m.
    ELSEIF ls_goitem_original-xauto = w.
      l_zustd = w.
    ELSE.
      CLEAR l_zustd.
    ENDIF.

    CALL FUNCTION 'MB_CONTROL_MOVETYPE_GET_SINGLE'
      EXPORTING
        i_bwart              = ls_goitem_original-bwart
        i_wertu              = ls_goitem_original-wertu
        i_mengu              = ls_goitem_original-mengu
        i_sobkz              = ls_goitem_original-sobkz
        i_kzbew              = ls_goitem_original-kzbew
        i_kzzug              = ls_goitem_original-kzzug
        i_kzvbr              = ls_goitem_original-kzvbr
      IMPORTING
        e_st156s             = ls_s156s
      EXCEPTIONS
        no_entry_found       = 1
        inconsistent_entries = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    SELECT * FROM t156m INTO l_t156m
                            WHERE bustm = ls_s156s-bustm
                              AND zustd = l_zustd.
      IF l_t156m-cnt02 = l_cnt02.
        MOVE l_t156m TO ls_t156m.
      ENDIF.
*   transfer posting if two entries with identical bustm and zustd
      IF l_kzuml = x.
        CLEAR l_kzuml.
      ELSE.
        l_kzuml = x.
        EXIT.
      ENDIF.
    ENDSELECT.
    ls_cdcom-lbbsa = ls_t156m-lbbsa.                        "1000432
    CASE ls_t156m-lbbsa.
      WHEN '01'.
        CLEAR: ls_cdcom-insmk.
      WHEN '02'.
        ls_cdcom-insmk = 2.
      WHEN '07'.
        ls_cdcom-insmk = 3.
    ENDCASE.

  ENDMETHOD.                                                "650835

ENDCLASS.                    "lcl_migo_determine_stock IMPLEMENTATION