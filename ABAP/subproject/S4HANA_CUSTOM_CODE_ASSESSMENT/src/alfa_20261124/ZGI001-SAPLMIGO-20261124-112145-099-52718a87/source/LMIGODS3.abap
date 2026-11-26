*----------------------------------------------------------------------*
*   INCLUDE LMIGODS3                                                   *
*   Detail tabstrip serial numbers implementation                      *
*   tableview_serial methods                                           *
*----------------------------------------------------------------------*

***********************************************************************
* Resolution of serial number line                                    *
***********************************************************************
  METHOD cursor_position_resolve.
    e_name            = 'SERIALNUMBERS'.
    e_tabix           = oref_detail->current_line.
    e_secondary_tabix = tv_goserial-top_line +
                        lcl_migo_cursor=>stepl - 1.
  ENDMETHOD.                    "cursor_position_resolve

***********************************************************************
* Tableview_serial_cursor_reset                                       *
* Find right cursor position.                                         *
***********************************************************************
  METHOD tableview_serial_cursor.
    DATA: l_lines LIKE sy-tabix.
    DATA: l_stepl LIKE sy-loopc.
    DATA: l_cursorline LIKE sy-stepl.

    CHECK lcl_migo_cursor=>oref_screenobject = me.


    DESCRIBE TABLE oref_detail->t_goserial LINES l_lines.
*   positioning in empty table control
    IF lcl_migo_cursor=>stepl > l_lines.
      tv_goserial-top_line = 1.
      EXIT.
    ENDIF.

    CHECK l_lines > 0.
    CHECK okcode = 'OK_GO'.

    l_cursorline = tv_goserial-top_line
                   + lcl_migo_cursor=>stepl - 1.
*   positioning after ENTER
    IF p_loopc = lcl_migo_cursor=>stepl.
      tv_goserial-top_line = tv_goserial-top_line + p_loopc - 1.
      CALL METHOD lcl_migo_cursor=>cursor_set
        EXPORTING
          i_oref_screenobject = me
          i_field             = 'GOSERIAL-SERIALNO'
          i_stepl             = 2.
    ELSEIF NOT lcl_migo_cursor=>value IS INITIAL
               AND p_lines <> l_cursorline.
*     do not change cursor position when position
*     on space or last position
      l_lines = lcl_migo_cursor=>stepl + 1.
      CALL METHOD lcl_migo_cursor=>cursor_set
        EXPORTING
          i_oref_screenobject = me
          i_field             = 'GOSERIAL-SERIALNO'
          i_stepl             = l_lines.
    ENDIF.
  ENDMETHOD.                    "tableview_serial_cursor

***********************************************************************
* Tableview_serial_line_set                                           *
***********************************************************************
  METHOD tableview_serial_line_set.
    DATA: ls_goserial TYPE lcl_migo_kernel=>ty_s_goserial.
    MOVE-CORRESPONDING goserial TO ls_goserial.
    MODIFY oref_detail->t_goserial FROM ls_goserial
                         INDEX tv_goserial-current_line.
    IF sy-subrc <> 0.
      APPEND ls_goserial TO oref_detail->t_goserial.
    ENDIF.
  ENDMETHOD.                    "tableview_serial_line_set

***********************************************************************
* Tableview_serial_line_get                                           *
***********************************************************************
  METHOD tableview_serial_line_get.
    DATA: ls_goserial TYPE lcl_migo_kernel=>ty_s_goserial.
    READ TABLE oref_detail->t_goserial INTO ls_goserial
                            INDEX tv_goserial-current_line.
    MOVE-CORRESPONDING ls_goserial TO goserial.
  ENDMETHOD.                    "tableview_serial_line_get

***********************************************************************
* Tableview_serial_mod_button                                         *
* Screen modify for buttons on tab 'serialnumbers'                    *
***********************************************************************
  METHOD tableview_serial_mod_button.
    DATA: ls_action TYPE lcl_migo_kernel=>ty_s_action.
ENHANCEMENT-SECTION     LMIGODS3_01 SPOTS ES_SAPLMIGO.
    MOVE lcl_migo_globals=>kernel->s_action TO ls_action.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT LMIGODS3_02 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-SECTION     LMIGODS3_03 SPOTS ES_SAPLMIGO.
    LOOP AT SCREEN.


      CASE screen-group2.
        WHEN 'PS1' OR 'PS2' OR 'PS3' OR 'PS4' OR 'PS5'.     "688602
          IF ls_action-cancel  = abap_true OR
             ls_action-display = abap_true.
            screen-input = c_mod_off.
          ELSE.
            screen-input = c_mod_on.
          ENDIF.
          MODIFY SCREEN.
        WHEN 'S1'.
          IF ls_action-cancel  = abap_true OR
             ls_action-display = abap_true.
            screen-active = c_mod_off.
          ELSE.
            screen-active = c_mod_on.
          ENDIF.
          MODIFY SCREEN.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT LMIGODS3_08 SPOTS ES_SAPLMIGO.

  ENDMETHOD.                           " TABLEVIEW_SERIAL_MOD_BUTTON

***********************************************************************
* Tableview_serial_modify                                             *
***********************************************************************
  METHOD tableview_serial_modify.

* EHP604: common variable for ADSUBCON and ADPIC MPN
    DATA: ls_goitem TYPE goitem.

ENHANCEMENT-POINT LMIGODS3_04 SPOTS ES_SAPLMIGO STATIC.

ENHANCEMENT-POINT LMIGODS3_05 SPOTS ES_SAPLMIGO.

ENHANCEMENT-SECTION     LMIGODS3_06 SPOTS ES_SAPLMIGO.
    LOOP AT SCREEN.
*     selection-button on left side: Always mod_on !
      CHECK screen-name <> 'GOSERIAL-SELECTED'.
      IF lcl_migo_globals=>kernel->s_action-cancel  = abap_true
      OR lcl_migo_globals=>kernel->s_action-display = abap_true.
        screen-input = c_mod_off.
      ELSE.
        screen-input = c_mod_on.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
END-ENHANCEMENT-SECTION.


  ENDMETHOD.                    "tableview_serial_modify

***********************************************************************
* Tableview_serial_size                                               *
***********************************************************************
  METHOD tableview_serial_size.
    DESCRIBE TABLE oref_detail->t_goserial LINES p_lines.
    IF p_lines < goitem-menge.
      p_lines = goitem-menge.
    ENDIF.
    tv_goserial-lines = p_lines.
*   Set correct TOP_LINE                                         "559233
    IF tv_goserial-top_line > p_lines AND                   "559233
       tv_goserial-top_line > goitem-menge.                 "559233
      tv_goserial-top_line = 1.                             "559233
    ENDIF.                                                  "559233
  ENDMETHOD.                    "tableview_serial_size

***********************************************************************
* Tableview_serial_table_prepare                                      *
* Remove zerolines before sending back to kernel                      *
***********************************************************************
  METHOD tableview_serial_table_prepare.
    DELETE oref_detail->t_goserial WHERE serialno IS INITIAL
* UII field is always initial when switched off or empty
                                     AND uii IS INITIAL.  "EHP603 IUID
  ENDMETHOD.                    "tableview_serial_table_prepare

***********************************************************************
* Note 400986                                                         *
*         serial_search                                               *
* Search and select of serial number arrays via call of IQ09          *
***********************************************************************
  METHOD serial_search.
    DATA:
*           internal tables needed for import from memory
            sel_tab TYPE STANDARD TABLE OF rihequi_list,
            lt_serial_selected TYPE STANDARD TABLE OF rihequi_list,
            ls_serial_selected TYPE rihequi_list,
            ls_goserial TYPE lcl_migo_kernel=>ty_s_goserial,
*           ranges needed for report RIEQUI21
            r_werks LIKE RANGE OF goitem-werks,
            rs_werks LIKE LINE OF r_werks,
            r_lgort LIKE RANGE OF goitem-lgort,
            rs_lgort LIKE LINE OF r_lgort,
            r_charg LIKE RANGE OF goitem-charg,
            rs_charg LIKE LINE OF r_charg,
            r_sobkz LIKE RANGE OF goitem-sobkz,
            rs_sobkz LIKE LINE OF r_sobkz,
            r_kunnr LIKE RANGE OF goitem-mat_kunnr,
            rs_kunnr LIKE LINE OF r_kunnr,
            r_lifnr LIKE RANGE OF goitem-mat_lifnr,
            rs_lifnr LIKE LINE OF r_lifnr,
            r_kdauf LIKE RANGE OF goitem-mat_kdauf,
            rs_kdauf LIKE LINE OF r_kdauf,
            r_kdpos LIKE RANGE OF goitem-mat_kdpos,
            rs_kdpos LIKE LINE OF r_kdpos,
            r_pspnr LIKE RANGE OF goitem-mat_pspnr,
            rs_pspnr LIKE LINE OF r_pspnr,
            r_bcharg LIKE RANGE OF goitem-charg,           "1339549
            rs_bcharg LIKE LINE OF r_bcharg,               "1339549
            r_lbbsa TYPE RANGE OF t156m-lbbsa,             "1339549
            rs_lbbsa LIKE LINE OF r_lbbsa.                 "1339549

    DATA:  ls_s156s        TYPE st156s,                    "1339549
           ls_goimseg      TYPE mseg,                      "1339549
           ls_bstch        TYPE bsinf,                     "1339549
           lv_attyp        TYPE attyp,                     "1339549
           lv_kzdzv        TYPE kzdzv.                     "1339549

ENHANCEMENT-POINT EHP604_LMIGODS3_03 SPOTS ES_SAPLMIGO STATIC .

*   Ranges for RIEQUI21 are created, but only for issues.
*   For receipts the selection screen of RIEQUI21 is presented
*   empty except for the material.
    DEFINE def_range.
      if goitem-shkzg_migo = '-'.                           "439104
        if not &3 is initial.                               "439104
          &1-sign   =  'I'.                                 "439104
          &1-option =  'EQ'.                                "439104
          &1-low    =  &3.                                  "439104
          append &1 to &2.                                  "439104
        endif.                                              "439104
      else.                                                 "439104
        if lcl_migo_globals=>kernel->s_control-action = 'A08'. "HP_685107
          &1-sign   =  'I'.                                 "HP_685107
          &1-option =  'EQ'.                                "HP_685107
          &1-low    =  &4.                                  "HP_685107
          append &1 to &2.                                  "HP_685107
        else.                                               "HP_685107
          &1-sign   =  'I'.                                 "439104
          &1-option =  'EQ'.                                "439104
          &1-low    =  ' '.                                 "439104
          append &1 to &2.                                  "439104
        endif.
      endif.                                                "439104
    END-OF-DEFINITION.
    def_range rs_werks r_werks goitem-werks goitem-umwrk.
    def_range rs_lgort r_lgort goitem-lgort goitem-umlgo.
*    def_range rs_charg r_charg goitem-charg goitem-umcha.  "1339549
    def_range rs_sobkz r_sobkz goitem-sobkz goitem-umsok.
    def_range rs_kunnr r_kunnr goitem-mat_kunnr goitem-ummat_kunnr.
    def_range rs_lifnr r_lifnr goitem-mat_lifnr goitem-ummat_lifnr.
    def_range rs_kdauf r_kdauf goitem-mat_kdauf goitem-ummat_kdauf.
    def_range rs_kdpos r_kdpos goitem-mat_kdpos goitem-ummat_kdpos.
    def_range rs_pspnr r_pspnr goitem-mat_pspnr goitem-ummat_pspnr.
    "riequi21 works fine
    "with internal pspnr

*    BEGIN OF     1339549                                   "1339549
    IF goitem-xchpf IS INITIAL AND NOT goitem-bwtty IS INITIAL
      AND goitem-charg IS INITIAL.
*     takover valuation type as batch if no batch requ. is active
      def_range rs_charg r_charg goitem-bwtar goitem-umbar.
      def_range rs_bcharg r_bcharg goitem-bwtar goitem-umbar.
    ELSE.
*      takeover batch
      def_range rs_charg r_charg goitem-charg goitem-umcha.
    ENDIF.

*    get LBBSA for SN

*    get BUSTM
    CALL FUNCTION 'MB_CONTROL_MOVETYPE_GET_SINGLE'
      EXPORTING
        i_bwart              = goitem-bwart
        i_wertu              = goitem-wertu
        i_mengu              = goitem-mengu
        i_sobkz              = goitem-sobkz
        i_kzbew              = goitem-kzbew
        i_kzzug              = goitem-kzzug
        i_kzvbr              = goitem-kzvbr
      IMPORTING
        e_st156s             = ls_s156s
      EXCEPTIONS
        no_entry_found       = 1
        inconsistent_entries = 2
        OTHERS               = 3.

     IF sy-subrc = 0.                                          "1630942
*     takeover movement data
    MOVE-CORRESPONDING goitem TO ls_goimseg.

*     Get ATTYP from material master. Call to "MATERIAL_READ" would be oversized
    SELECT SINGLE attyp FROM mara INTO lv_attyp WHERE matnr = goitem-matnr.
    IF sy-subrc <> 0.
      CLEAR lv_attyp.
    ENDIF.

*    Read batch definition
    CALL FUNCTION 'VB_BATCH_DEFINITION'
      IMPORTING
        kzdzv = lv_kzdzv.

    CALL FUNCTION 'SERIAL_CHECK_STRUCTURE_FILL'
      EXPORTING
        i_bustm        = ls_s156s-bustm
        is_mseg        = ls_goimseg
        i_kzdzv        = lv_kzdzv
        i_attyp        = lv_attyp
        i_qm_zustd     = '' "goitem-zustd
        i_xchpf        = goitem-xchpf
      IMPORTING
*       ES_BSTUP       =
        es_bstch       = ls_bstch
      EXCEPTIONS
        no_t156m_entry = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*   takeover LBBSA
    def_range rs_lbbsa r_lbbsa ls_bstch-lbbsa ls_bstch-lbbsa.


*  get allowed SN status and pre-set them

    DATA: lt_status_permitting     TYPE TABLE OF jstat,
          ls_status_permitting     TYPE jstat,
          lt_status_warning        TYPE TABLE OF jstat,
          lt_status_not_permitting TYPE TABLE OF jstat,
          ls_status_not_permitting TYPE jstat.

* code adopted from SN management
    CALL FUNCTION 'STATUS_ACT_ANALYZER_INTERN'
        EXPORTING
          activity              = ls_s156s-vrgng
        TABLES
          status_permitting     = lt_status_permitting
          status_not_permitting = lt_status_not_permitting
          status_warning        = lt_status_warning.

    APPEND LINES OF lt_status_warning TO lt_status_permitting.

    EXPORT status_permitting     FROM lt_status_permitting
           status_not_permitting FROM lt_status_not_permitting
           TO MEMORY ID 'STA     '.

* END OF 1339549                                            "1339549
  ENDIF.                                                       "1630942

ENHANCEMENT-SECTION EHP604_LMIGODS3_02 SPOTS ES_SAPLMIGO .
    SUBMIT riequi21 VIA SELECTION-SCREEN
              WITH dy_selm    = 'X'
              WITH matnr      = goitem-matnr
              WITH dy_mode    = 'X'
              WITH dy_tcode   = 'IQ09'
              WITH werk       IN r_werks                    "439104
              WITH lager      IN r_lgort
              WITH charge     IN r_charg
              WITH kunnr      IN r_kunnr
              WITH lifnr      IN r_lifnr
              WITH kdauf      IN r_kdauf
              WITH kdpos      IN r_kdpos
              WITH pspnr      IN r_pspnr
              WITH sobkz      IN r_sobkz
              WITH b_charge   IN r_bcharg                   "1339549
              WITH lbbsa      IN r_lbbsa                    "1339549
    AND RETURN.
END-ENHANCEMENT-SECTION.

    IMPORT sel_tab = lt_serial_selected FROM MEMORY ID 'RIEQUI21'.

    FREE MEMORY ID 'STA     '.                              "1339549
    FREE MEMORY ID 'RIEQUI21'.
    REFRESH lt_goserial.
    LOOP AT lt_serial_selected INTO ls_serial_selected.
      ls_goserial-serialno = ls_serial_selected-sernr.
      ls_goserial-uii = ls_serial_selected-uii.            "EHP603 IUID
      APPEND ls_goserial TO lt_goserial.
    ENDLOOP.

    CALL METHOD serial_join.
  ENDMETHOD.                    "serial_search

***********************************************************************
* Note 400986                                                         *
*         serial_join                                                 *
* The serial numbers selected by METHOD serial_select are merged with *
* the serial numbers entered manually in the table view. Afterwards   *
* the completed t_goserial is handed to the kernel                    *
***********************************************************************
  METHOD serial_join.
    DATA: goserial_size TYPE i,
          goserial_max_size TYPE i,
          l_goserial TYPE lcl_migo_kernel=>ty_s_goserial.

*   sort out double entries (entered manually and then selected again
*   selected by METHOD serial_search. Serials which were entered
*   manually are never sorted out.
    LOOP AT oref_detail->t_goserial INTO l_goserial.
      DELETE lt_goserial WHERE serialno = l_goserial-serialno.
    ENDLOOP.

    APPEND LINES OF lt_goserial TO oref_detail->t_goserial.

*   Are there too many serial numbers? If so, keep those which were
*   entered manually and delete the surplus of those selected with
*   METHOD serial_search.
    DESCRIBE TABLE oref_detail->t_goserial LINES goserial_size.
    MOVE goitem-menge TO goserial_max_size.
    IF goserial_size > goserial_max_size.
      MESSAGE i063(migo) WITH goserial_max_size.
      goserial_max_size = goserial_max_size + 1.
      DELETE oref_detail->t_goserial FROM goserial_max_size.
    ENDIF.

    CALL METHOD lcl_migo_globals=>kernel->line_modify
      EXPORTING
        i_line             = oref_detail->current_line
        i_authority_check  = abap_false
        i_dependent_tables = abap_true
        it_goserial        = oref_detail->t_goserial
      CHANGING
        cs_goitem          = goitem.
  ENDMETHOD.                    "serial_join

*----------------------------------------------------------------------*
* note 637093 (dynpro 362)                                             *
*      MODULE pbo_detail_serial_container OUTPUT                       *
*       the serialnumbers were created during a physical inventory     *
*       -> display the physical inventory-objectlist instead of        *
*          material document-objectlist.                               *
*----------------------------------------------------------------------*
  METHOD serial_show_inv.
                                                            "637093

    DATA: ls_iseg TYPE iseg.

    IF p_old_mblnr = space OR p_old_mblnr <> goitem-mblnr OR
                              p_old_mjahr <> goitem-mjahr.
      SELECT iblnr gjahr zeili mblnr mjahr zeile FROM iseg
         INTO CORRESPONDING FIELDS OF TABLE pt_iseg_buffer
           WHERE mblnr = goitem-mblnr
             AND mjahr = goitem-mjahr.
      p_old_mblnr = goitem-mblnr.
      p_old_mjahr = goitem-mjahr.
    ENDIF.

    READ TABLE pt_iseg_buffer INTO ls_iseg
                              WITH KEY mblnr = goitem-mblnr
                                       mjahr = goitem-mjahr
                                       zeile = goitem-zeile.

    CALL FUNCTION 'INVENTORY_ITEM_DISPLAY'
      EXPORTING
        iblnr              = ls_iseg-iblnr
        mjahr              = ls_iseg-gjahr
        zeili              = ls_iseg-zeili
        custom_container   = oref_serial_container
        output             = '2'
      EXCEPTIONS
        not_found          = 1
        no_custom_control  = 2
        no_output_possible = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDMETHOD.                                                "637093

***********************************************************************
* Note 688602                                                         *
*         serial_ref                                                  *
* Search and select of serial number arrays via reference document    *
* via report RIOBJK00                                                 *
***********************************************************************
  METHOD serial_ref.

    CONSTANTS:
          con_charx      TYPE xfeld VALUE 'X',
          memid_riobjk00(8) VALUE 'RIOBJK00'.       "Returned selection

*           internal tables needed for import from memory
    DATA:    ls_goserial TYPE lcl_migo_kernel=>ty_s_goserial,
             lt_tab_equi TYPE TABLE OF tab_equi,
             ls_tab_equi TYPE tab_equi,
             ls_equi TYPE equi.

*   get equi number via RIOBJK00

ENHANCEMENT-SECTION EHP6040_LMIGODS3_01 SPOTS ES_SAPLMIGO .
    SUBMIT riobjk00 VIA SELECTION-SCREEN
                    WITH matnr     = goitem-matnr
                    WITH dy_mode   = con_charx
                    AND RETURN.
END-ENHANCEMENT-SECTION.

    IMPORT da_tab_equi TO lt_tab_equi FROM
           MEMORY ID memid_riobjk00.

    FREE MEMORY ID 'RIOBJK00'.
    CLEAR ls_equi.
    REFRESH lt_goserial.


    LOOP AT lt_tab_equi INTO ls_tab_equi.

*     get serial number

      CALL FUNCTION 'SERIALNUMBER_READ'
        EXPORTING
          equnr          = ls_tab_equi-equnr
          matnr          = goitem-matnr
          uii            = ls_goserial-uii                 "EHP603 IUID
        IMPORTING
          equi           = ls_equi
        EXCEPTIONS
          equi_not_found = 1
          error_message  = 2
          OTHERS         = 3.

      IF sy-subrc = 0.
        ls_goserial-serialno = ls_equi-sernr.
        ls_goserial-uii = ls_equi-uii.                     "EHP603 IUID
        APPEND ls_goserial TO lt_goserial.
      ENDIF.
    ENDLOOP.

    CALL METHOD serial_join.


  ENDMETHOD.                    "serial_ref