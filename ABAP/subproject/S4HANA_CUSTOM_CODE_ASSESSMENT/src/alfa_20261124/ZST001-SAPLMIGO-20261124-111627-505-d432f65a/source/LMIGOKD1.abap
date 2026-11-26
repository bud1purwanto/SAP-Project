*----------------------------------------------------------------------*
*   INCLUDE LMIGOKD1 Document Post / Check                             *
*----------------------------------------------------------------------*

************************************************************************
* Post the material document
************************************************************************
METHOD document_post.
  CALL METHOD document_operation
    EXPORTING
      i_simulate = abap_false
    IMPORTING
      e_ok       = e_ok.
* If immediate exit is requested after posting, this is (hopefully)
* the right position.
  IF e_ok                                             = abap_true AND
     lcl_migo_globals=>external_call_leave_after_post = abap_true.
    CALL METHOD lcl_migo_frame=>okcode_dispatch( 'OK_END' ).
  ENDIF.
ENDMETHOD.                    "document_post

************************************************************************
* Check the material document
************************************************************************
METHOD document_check.
  IF i_enqueue = abap_false.
    CALL METHOD lcl_migo_enqueue=>save( 'BEFORE_CHECK' ).
  ENDIF.

  CALL METHOD document_operation
    EXPORTING
      i_simulate   = abap_true
      i_sim_values = i_sim_values
      i_error_only = i_error_only
    IMPORTING
      e_ok         = e_ok
      et_xmseg     = et_xmseg.

  IF i_enqueue = abap_false.
    CALL METHOD lcl_migo_enqueue=>restore( 'BEFORE_CHECK' ).
  ENDIF.
ENDMETHOD.                    "document_check

************************************************************************
* Post or check the material document depending on I_SIMULATE and
* trigger the application log
************************************************************************
METHOD document_operation.
  DATA: l_no_items        TYPE abap_bool,         "no items in lt_imseg
        l_exist           TYPE abap_bool,
        l_loglevel        TYPE migo_loglevel,
        l_rc_mcha_buffer  TYPE sysubrc,
        ls_imkpf          TYPE imkpf,
        ls_emkpf          TYPE emkpf,
        ls_xmkpf          TYPE mkpf,
        ls_imseg          TYPE ty_s_imseg,
        l_take_it         TYPE i.

ENHANCEMENT-POINT lmigokd1_01 SPOTS es_saplmigo STATIC.
  DATA: ls_emseg          TYPE ty_s_emseg,
        ls_mcha_buffer    TYPE mcha,
        lt_cancel         TYPE ty_t_cancel,
        lt_imseg          TYPE ty_t_imseg,
        lt_emseg          TYPE STANDARD TABLE OF emseg,
        l_tcode           TYPE sy-tcode,
        lt_xmseg          TYPE ty_t_xmseg,
        ls_message        TYPE lif_migo_frame~ty_s_message,
        l_glc             TYPE migo_global_counter.

ENHANCEMENT-POINT document_operation_04 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT document_operation_11 SPOTS es_saplmigo STATIC.
  FIELD-SYMBOLS: <goitem>        TYPE ty_s_goitem,
                 <ls_tmp_goitem> TYPE ty_s_goitem.

* SPE ST 27.01.2005
* VL-MM Consistency
  DATA: lt_mseg           TYPE         ty_t_mseg,
        ls_mseg           LIKE LINE OF lt_mseg,
        ls_goitem2        LIKE LINE OF pt_goitem,
        lo_mat_doc        TYPE REF TO  /spe/cl_inb_mat_doc,
        ls_t001l          TYPE t001l.                       "1042626
  DATA: lt_emseg_maa      TYPE TABLE OF emseg,              "MAA2
        ls_emkpf_maa      TYPE emkpf.                       "MAA2

  CHECK s_action-create = abap_true.
* Refresh application log before beginning
  CALL METHOD oref_log->refresh.
  CALL METHOD oref_log->send_data_to_mick.
* Clear always before new check/post.
  CLEAR pt_goserial_post.
* Fill TCODE with MIGO_MODE.EACH different MIGO_MODE must create
* a t_code!!!
  CASE s_action-migo_mode.
    WHEN 'GI'. l_tcode = 'MIGO_GI'.
    WHEN 'GR'. l_tcode = 'MIGO_GR'.
    WHEN 'GO'. l_tcode = 'MIGO_GO'.
    WHEN 'GS'. l_tcode = 'MIGO_GS'.
    WHEN 'GT'. l_tcode = 'MIGO_TR'.
  ENDCASE.

* In case of transfer posting all needed UM-fields have to be filled, to
* be sure that MB_CREATE will post with the same logic as MIGO (method
* um_fields_fill, LMIGOKU3)
  IF s_action-migo_mode = 'GT' AND s_action-cancel = abap_false AND
     goitem-xtransfer_mvt = x.
    CALL METHOD um_fields_fill_for_posting.
  ENDIF.

ENHANCEMENT-POINT EHP604_DOCUMENT_OPERATION_08 SPOTS ES_SAPLMIGO.

* move STATUS (used by serialno., prod.order,...) to memory
  CALL FUNCTION 'STATUS_BUFFER_EXPORT_TO_MEMORY'
    EXPORTING
      i_memory_id = 'MIGO'.
ENHANCEMENT-POINT document_operation_05 SPOTS es_saplmigo.
* DO - ENDDO needed for exits
  DO.
ENHANCEMENT-POINT document_operation_06 SPOTS es_saplmigo.
*______Step 1: FILL ________________________________________________
    IF s_action-cancel = abap_false.

ENHANCEMENT-POINT ehp603_lmigokd1_01 SPOTS es_saplmigo.

*   Fill for MB_CREATE_GOODS_MOVEMENT
      CALL METHOD goods_movement_fill
        IMPORTING
          et_imseg = lt_imseg
          es_imkpf = ls_imkpf.
      IF lt_imseg IS INITIAL.
        l_no_items = abap_true.
        EXIT.  "from DO
      ENDIF.

* MAA2 Begin
      DATA : lv_flag_maa_active  TYPE  abap_bool,

             lv_flag_error       TYPE  abap_bool,
             lt_message_log      TYPE  bapirettab,
             ls_message_log      LIKE  LINE OF lt_message_log,

             lt_imseg_out        TYPE  ty_t_imseg,
             lt_goserial_post    TYPE  cl_mmim_maa_2=>tt_serial_numbers,
             lt_goitem_refdoc    TYPE  goitem_t,
             lt_goitem_avis      TYPE  goitem_t,            "n1569831
             lv_vlief_avis_initial         TYPE  vbeln_vl,  "n1569831 "#EC NEEDED

             ls_imseg_maa                  LIKE  LINE OF  lt_imseg.

      TYPES : l_ty_range_global_counter    TYPE  RANGE OF migo_global_counter.
      DATA : lt_range_global_counter       TYPE  l_ty_range_global_counter,
             ls_range_global_counter       LIKE  LINE OF  lt_range_global_counter.

      FIELD-SYMBOLS : <ls_goitem_maa>      LIKE  LINE OF pt_goitem,
                      <ls_goitem_maa_avis> LIKE  LINE OF pt_goitem. "n1569831

* check whether the business function multi account assignment is active
      lv_flag_maa_active = cl_ops_switch_check=>mm_sfws_maa( ).

      IF  lv_flag_maa_active = abap_true.
        LOOP AT lt_imseg                        INTO  ls_imseg_maa.
          IF  ls_imseg_maa-xstor = '1'.
            "reference doc -> save the global counters of the selected lines to be posted
            MOVE : 'I'                          TO  ls_range_global_counter-sign,
                   'EQ'                         TO  ls_range_global_counter-option,
                   ls_imseg_maa-global_counter  TO  ls_range_global_counter-low.
            APPEND  ls_range_global_counter     TO  lt_range_global_counter.
          ELSE.
            EXIT.      " posting without reference doc -> leav this LOOP.
          ENDIF.
        ENDLOOP.

        IF  NOT lt_range_global_counter[] IS INITIAL.
*         some lines of the reference dic found -> create reference table
          LOOP AT pt_goitem            ASSIGNING  <ls_goitem_maa>
            WHERE global_counter IN lt_range_global_counter.
            APPEND  <ls_goitem_maa>    TO  lt_goitem_refdoc.
          ENDLOOP.

          SORT  lt_goitem_refdoc       BY  global_counter.
        ENDIF.

*       begin ----------------------------------------------"n1569831
*       look for entries of inbound deliveries and provide table
        LOOP AT pt_goitem              ASSIGNING  <ls_goitem_maa_avis>
          WHERE  vlief_avis NE lv_vlief_avis_initial.
          APPEND  <ls_goitem_maa_avis> TO  lt_goitem_avis.
        ENDLOOP.

        IF  NOT lt_goitem_avis[] IS INITIAL.
          SORT  lt_goitem_avis         BY  vlief_avis vbelp_avis.
        ENDIF.
*       end ------------------------------------------------"n1569831

*   call without setting accounting objects
        CALL METHOD go_mmim_maa_2->maa_item_duplicator_migo
          EXPORTING
            it_imseg             = lt_imseg[]
            is_imkpf             = ls_imkpf
            it_goserial_post_in  = pt_goserial_post
            it_goitem_refdoc     = lt_goitem_refdoc
            it_goitem_avis       = lt_goitem_avis           "n1569831
          CHANGING
            ct_goserial_post_out = lt_goserial_post
            ct_imseg_out         = lt_imseg_out
            ct_message_log       = lt_message_log
            cv_flag_error        = lv_flag_error.

        IF lv_flag_error = abap_true.
*       evaluate the messages
          LOOP AT lt_message_log         INTO  ls_message_log.
            CLEAR                        ls_emseg.
            IF ls_message_log-row IS INITIAL.
              ls_emkpf_maa-msgty      = ls_message_log-type.
              ls_emkpf_maa-msgid      = ls_message_log-id.
              ls_emkpf_maa-msgno      = ls_message_log-number.
              ls_emkpf_maa-msgv1      = ls_message_log-message_v1.
              ls_emkpf_maa-msgv2      = ls_message_log-message_v2.
              ls_emkpf_maa-msgv3      = ls_message_log-message_v3.
              ls_emkpf_maa-msgv4      = ls_message_log-message_v4.
            ELSE.
*           save the data of the error message into the next table
              ls_emseg-msgty          = ls_message_log-type.
              ls_emseg-msgid          = ls_message_log-id.
              ls_emseg-msgno          = ls_message_log-number.
              ls_emseg-msgv1          = ls_message_log-message_v1.
              ls_emseg-msgv2          = ls_message_log-message_v2.
              ls_emseg-msgv3          = ls_message_log-message_v3.
              ls_emseg-msgv4          = ls_message_log-message_v4.
              ls_emseg-global_counter = ls_message_log-row.
              APPEND  ls_emseg           TO lt_emseg_maa.   "MAA2
            ENDIF.
          ENDLOOP.

          MOVE  '4'                      TO  ls_emkpf_maa-subrc.
          CLEAR                          ls_emseg.
        ELSE.
*       replace the content of input table IMSEG
          MOVE  lt_imseg_out[]           TO  lt_imseg[].
*       replace the content of the serial number table, too
          MOVE  lt_goserial_post[]       TO  pt_goserial_post[].

          CLEAR:  ls_emkpf_maa.
          REFRESH lt_emseg_maa.
        ENDIF.
      ENDIF.
* MAA2 End

ENHANCEMENT-POINT lmigoke1_02 SPOTS es_saplmigo.
    ELSE.
*   Fill for MB_CANCEL_GOODS_MOVEMENT
      CALL METHOD goods_cancel_fill
        IMPORTING
          et_cancel = lt_cancel.
      IF lt_cancel IS INITIAL.
        l_no_items = abap_true.
        EXIT.    "from DO
      ENDIF.
    ENDIF.
*______Step 2: AFTER FILL __________________________________________
    CALL METHOD serialnumbers_post.
*   Set flag XMIGO FOR MB_CREATE_GOODS_MOVEMENT or MB_CANCEL...
*   Must be set AFTER serialnumbers_post! I do not know WHY?
    CALL FUNCTION 'MB_SET_BAPI_FLAG'
      EXPORTING
        action = '3'.
*   Check if there are any messages after fill
    CALL METHOD oref_log->message_exist_all
      EXPORTING
        i_error_only = abap_true
      RECEIVING
        r_exist      = l_exist.
    IF l_exist = abap_true.
      EXIT.    "from DO
    ENDIF.
*   documentary batch data are updated by LO-BM; tell them what we are
*   about to do
    CALL METHOD doc_batch_post.
*   Check if there are any messages after fill
    CALL METHOD oref_log->message_exist_all
      EXPORTING
        i_error_only = abap_true
      RECEIVING
        r_exist      = l_exist.
    IF l_exist = abap_true.
      EXIT.    "from DO
    ENDIF.
*______Step 3: MB_CREATE/MB_CANCEL/MB_SIMULATE/MB_SIM_CANCEL_________
    IF i_simulate = abap_false.
      IF s_action-cancel = abap_false.
ENHANCEMENT-POINT lmigokd1_03 SPOTS es_saplmigo.

* SPE ST 27.01.2005
* VL-MM Consistency
        IF /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
ENHANCEMENT-SECTION     lmigokda_01 SPOTS es_saplmigo.
          IF s_action-create     = abap_true AND
             s_action-return     = abap_true AND
             s_action-migo_mode  = 'GR'      AND
             s_action-refdoctype = 'MAT'     AND            "1048427
             ps_gohead-create_delivery = abap_true.
            REFRESH lt_mseg[].
            lo_mat_doc ?= /spe/cl_class_factory=>create_class(
                         i_name = '/SPE/CL_INB_MAT_DOC ' ).
            IF NOT lo_mat_doc IS INITIAL.
              LOOP AT pt_goitem INTO ls_goitem2.
                MOVE-CORRESPONDING ls_goitem2 TO ls_mseg.
                APPEND ls_mseg TO lo_mat_doc->at_mseg.
              ENDLOOP.
              CALL METHOD /spe/cl_inb_action_info=>set_object
                EXPORTING
                  io_object = lo_mat_doc
                  i_name    = /spe/cl_inb_action_info=>c_obj_mat_doc.
            ENDIF.
          ELSE.
*         Check for storage locations with HU requirements      "1042626
            LOOP AT pt_goitem INTO ls_goitem2.
              IF ls_goitem2-werks <> ls_t001l-werks
              OR ls_goitem2-lgort <> ls_t001l-lgort.
                SELECT SINGLE * FROM t001l INTO ls_t001l
                                WHERE werks = ls_goitem2-werks
                                AND   lgort = ls_goitem2-lgort.
              ENDIF.
              IF NOT ls_t001l-xhupf IS INITIAL.
                IF lo_mat_doc IS INITIAL.
                  lo_mat_doc ?= /spe/cl_class_factory=>create_class(
                               i_name = '/SPE/CL_INB_MAT_DOC ' ).
                ENDIF.
                MOVE-CORRESPONDING ls_goitem2 TO ls_mseg.
                APPEND ls_mseg TO lo_mat_doc->at_mseg.
              ENDIF.
            ENDLOOP.
            IF NOT lo_mat_doc IS INITIAL.
              CALL METHOD /spe/cl_inb_action_info=>set_object
                EXPORTING
                  io_object = lo_mat_doc
                  i_name    = /spe/cl_inb_action_info=>c_obj_mat_doc.
            ENDIF.
          ENDIF.
END-ENHANCEMENT-SECTION.
        ENDIF.

*      MB_CREATE_GOODS_MOVEMENT
ENHANCEMENT-SECTION     document_operation_02 SPOTS es_saplmigo.

        CALL FUNCTION 'MB_CREATE_GOODS_MOVEMENT'
          EXPORTING
            ctcod   = l_tcode
            imkpf   = ls_imkpf
            xallp   = abap_true
            xallr   = abap_true
            xallb   = abap_true
          IMPORTING
            emkpf   = ls_emkpf
            es_mkpf = ls_xmkpf
          TABLES
            emseg   = lt_emseg
            imseg   = lt_imseg
            et_mseg = lt_xmseg.
END-ENHANCEMENT-SECTION.
      ELSE.


*      MB_CANCEL_GOODS_MOVEMENT
ENHANCEMENT-SECTION     document_operation_01 SPOTS es_saplmigo.

* SPE ST 27.01.2005
* VL-MM Consistency
        IF /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
          IF  s_action-create     = abap_true
          AND s_action-migo_mode  = 'GR'
          AND s_action-refdoctype = 'MAT'.
            CALL METHOD /spe/cl_inb_action_info=>set_info
              EXPORTING
                i_dialog  = /spe/cl_inb_action_info=>c_dialog_migo
                i_action1 = /spe/cl_inb_action_info=>c_act1_st
                i_action2 = /spe/cl_inb_action_info=>c_act2_bs.
*           Check for storage locations with HU requirements    "v_n_1499197
            LOOP AT pt_goitem INTO ls_goitem2.
              IF ls_goitem2-werks <> ls_t001l-werks
              OR ls_goitem2-lgort <> ls_t001l-lgort.
                SELECT SINGLE * FROM t001l INTO ls_t001l
                                WHERE werks = ls_goitem2-werks
                                AND   lgort = ls_goitem2-lgort.
              ENDIF.
              IF NOT ls_t001l-xhupf IS INITIAL.
                IF lo_mat_doc IS INITIAL.
                  lo_mat_doc ?= /spe/cl_class_factory=>create_class(
                               i_name = '/SPE/CL_INB_MAT_DOC ' ).
                ENDIF.
                MOVE-CORRESPONDING ls_goitem2 TO ls_mseg.
                APPEND ls_mseg TO lo_mat_doc->at_mseg.
              ENDIF.
            ENDLOOP.
            IF NOT lo_mat_doc IS INITIAL.
              CALL METHOD /spe/cl_inb_action_info=>set_object
                EXPORTING
                  io_object = lo_mat_doc
                  i_name    = /spe/cl_inb_action_info=>c_obj_mat_doc.
            ENDIF.                                              "^_n_1499197
          ENDIF.
        ENDIF.

        CALL FUNCTION 'MB_CANCEL_GOODS_MOVEMENT'
          EXPORTING
            tcode     = l_tcode
            budat     = ps_gohead-budat
            xallp     = abap_true
            mblnr     = ps_gohead-mblnr
            mjahr     = ps_gohead-mjahr
          IMPORTING
            emkpf     = ls_emkpf
            es_mkpf   = ls_xmkpf
          TABLES
            emseg     = lt_emseg
            imseg     = lt_imseg
            mblpo_tab = lt_cancel
            et_mseg   = lt_xmseg.
END-ENHANCEMENT-SECTION.

      ENDIF. "cancel true/false
*    Add errors from MAA-doublicator               "MAA2
      IF NOT ls_emkpf_maa IS INITIAL.
        ls_emkpf = ls_emkpf_maa.
        APPEND LINES OF lt_emseg_maa TO lt_emseg.
      ENDIF.                                                "MAA2
*    Errors => exit before mb_post call
      IF ls_emkpf-subrc <> 1.
        EXIT.  "from DO
      ENDIF.
*  Simulation mode
    ELSE.

      IF s_action-cancel = abap_false.
ENHANCEMENT-POINT lmigokd1_04 SPOTS es_saplmigo.
*    MB_SIMULATE_GOODS_MOVEMENT
ENHANCEMENT-SECTION     document_operation_03 SPOTS es_saplmigo.
        CALL FUNCTION 'MB_SIMULATE_GOODS_MOVEMENT'
          EXPORTING
            ctcod      = l_tcode
            sim_imkpf  = ls_imkpf
            xvalues    = i_sim_values
          IMPORTING
            sim_emkpf  = ls_emkpf
          TABLES
            sim_emseg  = lt_emseg
            sim_imseg  = lt_imseg
            sim_eymseg = lt_xmseg.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT lmigokd1_05 SPOTS es_saplmigo.
      ELSE.
*      MB_SIM_CANCEL_GOODS_MOVEMENT
        CALL FUNCTION 'MB_SIM_CANCEL_GOODS_MOVEMENT'
          EXPORTING
            tcode         = l_tcode
            budat         = ps_gohead-budat
            mblnr         = ps_gohead-mblnr
            mjahr         = ps_gohead-mjahr
            xvalues       = i_sim_values
          IMPORTING
            sim_emkpf     = ls_emkpf
          TABLES
            sim_emseg     = lt_emseg
            sim_imseg     = lt_imseg
            sim_mblpo_tab = lt_cancel
            sim_eymseg    = lt_xmseg.

      ENDIF.  "cancel true/false in simulation
      IF i_sim_values = abap_true.
        et_xmseg = lt_xmseg.
      ENDIF.
*    Nothing to do anymore in simulation mode
      EXIT.  "from DO
    ENDIF.   "simulation mode true/false
*_____ Step 4: MB_POST after MB_CREATE/MB_CANCEL _______________________
*_____________ (only if emkpf-subrc = 1) _______________________________
ENHANCEMENT-POINT document_operation_07 SPOTS es_saplmigo.
*  BAdI: Send XMSEG to allow BAdI to put combined data into update task
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      CALL METHOD lcl_migo_globals=>if_badi->post_document
        EXPORTING
          it_mseg = lt_xmseg
          is_mkpf = ls_xmkpf.
    ENDIF.
    CALL METHOD goods_movement_post
      IMPORTING
        es_emkpf_old = ls_emkpf.
    EXIT.   "Last EXIT from DO. Always last line before ENDDO
  ENDDO.

*______________________________________________________________________
* check whether message S007 'no take_it flagged on' must be processed:
* this is the case when the fill methods could not fill anything or
* nothing was selected;
* note the following specials:
* 1) GR to subcontract order, main position has not
* been flagged ok, some subitems have been flagged on individually;
* subitems will be filtered out in goods_movement_fill -> lt_item
* will be empty -> nothing will be done in mb_create..=> message S007
*
* 2)subcontract scenario as above, before the subitems
* are filtered out in goods_movement_fill the check on fields required
* for input generates an error message for a subitem in the log;
* in this case I want to see this error message instead of S007;
*
  IF l_no_items = abap_true.
*   set ok-flag for check mode to false (note 380334)
    e_ok = abap_false.
    IF oref_log->message_exist_all( i_error_only = abap_true )
                  = abap_true.
*   there are error messages in the log which will be
*   processed later on -> nothing to do here
    ELSEIF oref_log->message_exist_all( i_error_only = abap_false )
                     = abap_true AND i_simulate = abap_true.
*   there are just warnings in the log and we are in check
*   mode -> messages will be processed later on -> nothing
*   to do here
    ELSE.
      IF s_action-migo_mode = 'GS'.
        MESSAGE s053. "data not sufficient
      ELSE.
*       no errors, no warnings, no entries in lt_imseg ->
*       no take_it flagged on or at least no main items with
*       take_it flagged on
        MESSAGE s007. "no items with take_it
      ENDIF.
      EXIT.
    ENDIF.
  ELSE.
    e_ok = abap_true.
  ENDIF.
* The error handling method fills errors from EMKPF/EMSEG to the
* log. If there are no errors, nothing is filled into the log.
  CALL METHOD goods_movement_error_handling
    EXPORTING
      is_emkpf = ls_emkpf
      it_emseg = lt_emseg.

* Transfer any messages that are referring to selected items
* (goitem-take_it set) from oref_badi_log -> oref_log
  IF NOT lcl_migo_globals=>if_badi_item IS INITIAL AND
         oref_badi_log->message_exist_all( ) = abap_true.

    CALL METHOD oref_badi_log->messages_transfer_selected
      EXPORTING
        i_target_log = oref_log
        i_pt_goitem  = pt_goitem.

  ENDIF.

* Fill/check application log if simulation or error in MB_CREATE/CANCEL
  IF oref_log->message_exist_all( i_error_only = abap_true ) =
     abap_true OR i_simulate = abap_true.
*   Moreover get STATUS back from memory if error or xsimu=x.
    CALL FUNCTION 'STATUS_BUFFER_REFRESH'.
    CALL FUNCTION 'STATUS_BUFFER_IMPORT_FROM_MEMO'
      EXPORTING
        i_memory_id = 'MIGO'
        i_client    = sy-mandt.
*   Update loglevel in header and items
    CALL METHOD oref_log->message_exist_single
      IMPORTING
        e_loglevel = ps_gohead-loglevel.
    LOOP AT pt_goitem ASSIGNING <goitem> WHERE take_it = abap_true.
*     no messages for the components of a structured article
      CHECK <goitem>-xsttype <> c.
      CALL METHOD oref_log->message_exist_single
        EXPORTING
          i_global_counter = <goitem>-global_counter
        IMPORTING
          e_loglevel       = <goitem>-loglevel.
*       If no entry in the log, send green light
      IF <goitem>-loglevel IS INITIAL.
        <goitem>-loglevel = icon_green_light.
      ENDIF.
*     If the line is invisible, we will open it so that the
*     message can be recognized. This process operates
*     recursively until the top level line has been reached.
*     Meaning of "(3)": LOGOEVEL contains the icon and the
*     message text as quickhelp. The first three letters
*     specify the icon type.
      IF <goitem>-loglevel(3) = icon_yellow_light(3) OR
         <goitem>-loglevel(3) = icon_red_light(3).
        l_glc = <goitem>-global_counter.
        DO.
          IF l_glc IS INITIAL.
            EXIT.
          ENDIF.
          READ TABLE pt_goitem ASSIGNING <ls_tmp_goitem>
                     WITH TABLE KEY global_counter = l_glc.
*         Can't happen, but we never know...
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
*         If the line can be expanded, do it
          IF <ls_tmp_goitem>-expand = c_icon_expand.
*           Caution: Using SY-TABIX directly is only permitted because
*           I_TABIX is used "BY VALUE" (note 381320).
            IF  <ls_tmp_goitem>-xgatype IS INITIAL OR
              ( NOT <ls_tmp_goitem>-xgatype IS INITIAL AND
              oref_detail->current_line = sy-tabix ).
              CALL METHOD line_expand( i_tabix = sy-tabix ).
            ENDIF.
          ENDIF.
*         Continue with parent
          l_glc = <ls_tmp_goitem>-parent.
        ENDDO.
      ENDIF.
*     Check if there is any relevant data in batch buffer.
*     This part of coding is executed if after a call to MB_CREATE
*     we return to the dialog. In this case, automatically assigned
*     data from Mr. Batchmanager have to be loaded back into MIGO
*     for display and check reasons. Furthermore, a batch number
*     will be created only once.
      IF i_simulate = abap_true AND
         ( <goitem>-xchpf = abap_true OR <goitem>-umxchpf = abap_true ).
        READ TABLE lt_emseg INTO ls_emseg
                   WITH KEY global_counter = <goitem>-global_counter.
        IF sy-subrc = 0.
*         Batch:
          IF <goitem>-xchpf = abap_true.
            IF <goitem>-charg IS INITIAL AND
               NOT ls_emseg-e_charg IS INITIAL.
              <goitem>-charg = ls_emseg-e_charg.
            ENDIF.
            CHECK NOT <goitem>-charg IS INITIAL.
            CLEAR: ls_mcha_buffer,
                   l_rc_mcha_buffer.
            CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
              EXPORTING
                matnr            = <goitem>-matnr
                charg            = <goitem>-charg
                werks            = <goitem>-werks
                lgort            = <goitem>-lgort
                read_from_buffer = x
                read_from_db     = ' '
              IMPORTING
                batch_buffer     = ls_mcha_buffer
                rc_batch_buffer  = l_rc_mcha_buffer.
            IF l_rc_mcha_buffer IS INITIAL.
              IF <goitem>-charg IS INITIAL.
                <goitem>-charg = ls_mcha_buffer-charg.
              ENDIF.
              CALL METHOD batch_data_get
                EXPORTING
                  is_mcha_buffer = ls_mcha_buffer
                CHANGING
                  cs_goitem      = <goitem>.
            ENDIF.
          ENDIF.
*         Batch (Transfer):
          IF <goitem>-umxchpf = abap_true.
            IF <goitem>-umcha IS INITIAL AND
              NOT ls_emseg-e_umcha IS INITIAL
              OR ( NOT <goitem>-umcha IS INITIAL AND
                NOT ls_emseg-e_umcha IS INITIAL AND
                <goitem>-umcha <> ls_emseg-e_umcha ).       "748216
              <goitem>-umcha = ls_emseg-e_umcha.
            ENDIF.
            CHECK NOT <goitem>-umcha IS INITIAL.
            CLEAR: ls_mcha_buffer,
                   l_rc_mcha_buffer.
            CHECK s_action-cancel = abap_false.
            CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
              EXPORTING
                matnr            = <goitem>-ummat
                charg            = <goitem>-umcha
                werks            = <goitem>-umwrk
                lgort            = <goitem>-umlgo
                read_from_buffer = x
                read_from_db     = ' '
              IMPORTING
                batch_buffer     = ls_mcha_buffer
                rc_batch_buffer  = l_rc_mcha_buffer.
            IF l_rc_mcha_buffer IS INITIAL.
              IF <goitem>-umcha IS INITIAL.
                <goitem>-umcha = ls_mcha_buffer-charg.
              ENDIF.
              CALL METHOD batch_data_transfer_get
                EXPORTING
                  is_mcha_buffer = ls_mcha_buffer
                CHANGING
                  cs_goitem      = <goitem>.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
*   Call status derivation to have the global information for
*   loglevel.
    CALL METHOD status_derive.
*   Check if there are any messages and display log
    CALL METHOD oref_log->message_exist_all
      EXPORTING
        i_error_only = i_error_only
      RECEIVING
        r_exist      = l_exist.
ENHANCEMENT-SECTION     lmigokd1_06 SPOTS es_saplmigo.
    IF l_exist = abap_true.
*     If there are messages on header level, we will open the
*     header.
      CALL METHOD oref_log->message_exist_single
        EXPORTING
          i_global_counter = 0
        IMPORTING
          e_loglevel       = l_loglevel.
      IF NOT l_loglevel IS INITIAL.
        def_sms 'HEADER_OPEN' 'OK_GOHEAD_GENERAL' space.
      ENDIF.
*     Display log.
      CALL METHOD oref_log->display.
      e_ok = abap_false.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDIF.
ENDMETHOD.                    "document_operation
ENHANCEMENT-POINT lmigokd1_07 SPOTS es_saplmigo STATIC.