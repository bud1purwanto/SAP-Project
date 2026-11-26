*----------------------------------------------------------------------*
*   INCLUDE LMIGOPR2                                                   *
*   Predocuments
*----------------------------------------------------------------------*

CLASS lcl_migo_predocument IMPLEMENTATION.

************************************************************************
* Register OK-codes and messasges
************************************************************************
METHOD constructor.
  DATA: lt_okcodes   TYPE lif_migo_frame~ty_t_okcodes,
        lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
        lt_sending   TYPE lif_migo_frame~ty_t_message_ids.
  lif_migo_frame~class_id = 'MIGO_PREDOCUMENT'.
  APPEND 'OK_PREDOC'  TO lt_okcodes.
  APPEND 'OK_PRE_SEL' TO lt_okcodes.

  APPEND 'KERNEL_RESET'          TO lt_receiving.
  APPEND 'NEW_DOCUMENT'          TO lt_receiving.
  APPEND 'TREE_PREDOC_SELECTED'  TO lt_receiving.

  APPEND 'MIGO_TIP_REQUEST'       TO lt_sending.
  APPEND 'TREE_PREDOC_ADD'        TO lt_sending.
  APPEND 'TREE_PREDOC_DELETE'     TO lt_sending.

  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes
      it_receiving  = lt_receiving
      it_sending    = lt_sending.
ENDMETHOD.

************************************************************************
* OK-code handling
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  CASE i_okcode.
    WHEN 'OK_PREDOC'.
      CALL METHOD predoc_save.
    WHEN 'OK_PRE_SEL'.
      CALL METHOD predoc_select.
  ENDCASE.
ENDMETHOD.

************************************************************************
* Message handling
************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: l_guid TYPE guid_22.
  FIELD-SYMBOLS: <ls_key> TYPE lcl_migo_kernel=>ty_s_refdockey.
  CASE i_message_id.
    WHEN 'KERNEL_RESET'.
      CLEAR p_last_document.
    WHEN 'NEW_DOCUMENT'.
      ASSIGN is_message-dref->* TO <ls_key>.
      p_last_document = <ls_key>.
    WHEN 'TREE_PREDOC_SELECTED'.
      l_guid = is_message-data1.
      CALL METHOD load( l_guid ).
  ENDCASE.
ENDMETHOD.


************************************************************************
* Present a popup to enter a remark, then call the kernel function
* to dump the core.
************************************************************************
METHOD predoc_save.
  DATA: l_refid   TYPE refid_d,
        l_guid    TYPE guid_22,
        l_return  TYPE c,
        ls_field  TYPE sval,
        lt_field  TYPE STANDARD TABLE OF sval,
        l_datec(10),
        l_timec(8),
        l_datlo TYPE systdatlo,
        l_timlo TYPE systtimlo,
        ls_message TYPE lif_migo_frame=>ty_s_message,
        ls_key     TYPE lcl_migo_kernel=>ty_s_refdockey,
        ls_org     TYPE mmim_predoc_org.
* Tip
  def_sms 'MIGO_TIP_REQUEST' 'HELP_OK_PREDOC' space.
* Popup to enter a short notice (to find the data later on)
  ls_field-tabname   = 'MMIM_PREDOC_ORG'.
  ls_field-fieldname = 'REFID'.
  ls_field-fieldtext = 'Park as'(119).
* Default entry depending on reference document
  CASE lcl_migo_globals=>kernel->s_control-refdoc.
   WHEN 'R01'.WRITE p_last_document-po_number         TO ls_field-value.
   WHEN 'R02'.WRITE p_last_document-mat_doc           TO ls_field-value.
   WHEN 'R03'.WRITE p_last_document-delivery_note     TO ls_field-value.
   WHEN 'R04'.WRITE p_last_document-inbound_delivery  TO ls_field-value.
   WHEN 'R05'.WRITE p_last_document-outbound_delivery TO ls_field-value.
   WHEN 'R06'.WRITE p_last_document-transport         TO ls_field-value.
   WHEN 'R07'.WRITE p_last_document-transportident    TO ls_field-value.
   WHEN 'R08'.WRITE p_last_document-order_number      TO ls_field-value.
  ENDCASE.
* Get current time
  l_datlo = sy-datlo.
  l_timlo = sy-timlo.
* No real data available --> time and date
  IF ls_field-value IS INITIAL.
    WRITE l_datlo TO l_datec.
    WRITE l_timlo TO l_timec.
    CONCATENATE l_timec ' (' l_datec ')'
                                INTO ls_field-value.
  ENDIF.
  APPEND ls_field TO lt_field.
* Flag to make the data to a template
  CLEAR ls_field.                                                "381402
  ls_field-tabname   = 'AM07M'.                                  "381402
  ls_field-fieldname = 'XSELK'.                                  "381402
  ls_field-fieldtext = 'Vorlage'(127).                           "381402
  APPEND ls_field TO lt_field.                                   "381402
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = 'Park document'(006)
    IMPORTING
      returncode      = l_return
    TABLES
      fields          = lt_field.
  CHECK l_return IS INITIAL.
  READ TABLE lt_field INTO ls_field INDEX 1.
  l_refid = ls_field-value.
  READ TABLE lt_field INTO ls_field INDEX 2.                     "381402
  IF NOT ls_field-value IS INITIAL.                              "381402
*   It's a template. Store this information in the last character
*   of the description text. Dirty, but no other chance without
*   table change.
    l_refid+39 = '_'.                                            "381402
  ENDIF.                                                         "381402
* Create GUID
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_22 = l_guid.
* Call the kernel to dump the state
  CALL METHOD lcl_migo_globals=>kernel->predocument_save
    EXPORTING
      i_guid  = l_guid.
* Update the tree
  ls_message-data1 = l_guid.
  ls_key-guid      = l_guid.
  ls_key-refid     = l_refid.
  GET REFERENCE OF ls_key INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'TREE_PREDOC_ADD'
      is_message    = ls_message.
* Create the organizational entry in the database
* Use 'SAPLMIGO' because MBPM uses this key (will change
* if more applications use the mechanism).
  ls_org-guid   = l_guid.
  ls_org-refid  = l_refid.
  ls_org-repid  = c_repid.
  ls_org-uname  = sy-uname.
  ls_org-datlo  = sy-datlo.
  ls_org-timlo  = sy-timlo.
  ls_org-saprl  = sy-saprl.
  ls_org-lines  = lcl_migo_globals=>kernel->s_status-lines.
  ls_org-action = lcl_migo_globals=>kernel->s_control-action.
  ls_org-refdoc = lcl_migo_globals=>kernel->s_control-refdoc.
  INSERT mmim_predoc_org FROM ls_org.
ENDMETHOD.

************************************************************************
* Selecting a predocument via popup
************************************************************************
METHOD predoc_select.
  DATA: ls_fc      TYPE slis_fieldcat_alv,
        lt_fc      TYPE slis_t_fieldcat_alv,
        ls_layout  TYPE slis_layout_alv,
        ls_dd07v   TYPE dd07v,
        l_value    TYPE domvalue_l,
        ls_doclist TYPE ty_s_doclist.
* Read the available data from the database org table
  SELECT * FROM mmim_predoc_org
    INTO CORRESPONDING FIELDS OF TABLE pt_doclist
    WHERE uname = sy-uname
      AND repid = c_repid.
  SORT pt_doclist BY uname datlo DESCENDING timlo DESCENDING.
* Build fieldcatalog
  CLEAR lt_fc.
  ls_fc-ref_tabname = 'MMIM_PREDOC_ORG'.
  ls_fc-fieldname = 'DATLO'.  APPEND ls_fc TO lt_fc.
  ls_fc-fieldname = 'TIMLO'.  APPEND ls_fc TO lt_fc.
  ls_fc-fieldname = 'LINES'.  APPEND ls_fc TO lt_fc.
  ls_fc-fieldname = 'REFID'.  APPEND ls_fc TO lt_fc.

  ls_layout-box_fieldname = 'SELECT'.

* Clear the field that transports the selected GUID back to here
  CLEAR p_selected_guid.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = c_repid
      i_callback_pf_status_set = 'PREDOC_ALV_STATUS'
      i_callback_user_command  = 'PREDOC_ALV_USER'
      is_layout                = ls_layout
      it_fieldcat              = lt_fc
      i_buffer_active          = 'X'                             "318150
      i_screen_start_column    = 1
      i_screen_start_line      = 3
      i_screen_end_column      = 72
      i_screen_end_line        = 16
    TABLES
      t_outtab                 = pt_doclist.
* The loading process must not be triggered within ALV_CALLBACK_USER.
* Reason: Loading a predoc sets a GUI-status, and if the ALV is still
* running, this only affects the ALV-popup.
  IF NOT p_selected_guid IS INITIAL.
    CALL METHOD load( p_selected_guid ).
  ENDIF.

ENDMETHOD.

************************************************************************
* Set status in popup
************************************************************************
METHOD alv_callback_status.
  SET TITLEBAR 'PREDOC_POPUP'.
  SET PF-STATUS 'PREDOC_STATUS' EXCLUDING ct_extab.
ENDMETHOD.

************************************************************************
* User command in the popup
************************************************************************
METHOD alv_callback_user.
  DATA: l_count TYPE i,
        ls_doclist TYPE ty_s_doclist.
* Double click marks one line for reload
  IF cf_ucomm = '&IC1'.
    LOOP AT pt_doclist INTO ls_doclist.
      IF sy-tabix = cs_selfield-tabindex.
        ls_doclist-select = x.
      ELSE.
        CLEAR ls_doclist-select.
      ENDIF.
      MODIFY pt_doclist FROM ls_doclist.
    ENDLOOP.
    cf_ucomm = 'TAKE'.
  ENDIF.
* Execution if user command
  CASE cf_ucomm.
    WHEN 'DELETE'.
      LOOP AT pt_doclist INTO ls_doclist WHERE select = x.
        DELETE pt_doclist.
        CALL METHOD delete( ls_doclist-guid ).
      ENDLOOP.
      cs_selfield-refresh = 'X'.
    WHEN 'TAKE'.
      l_count = 0.
      LOOP AT pt_doclist INTO ls_doclist WHERE select <> space.
        l_count = l_count + 1.
      ENDLOOP.
      IF l_count = 0.
        cs_selfield-exit = x.
      ELSE.
        IF l_count > 1.
         MESSAGE i014.                        "Choose only one document
        ELSE.
          READ TABLE pt_doclist INTO ls_doclist WITH KEY select = x.
          p_selected_guid = ls_doclist-guid.
          cs_selfield-exit = x.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      cs_selfield-exit = x.
  ENDCASE.
  CLEAR cf_ucomm.
ENDMETHOD.

************************************************************************
* Load a predocument into the kernel and delete it afterwards
************************************************************************
METHOD load.
  DATA: ls_org TYPE mmim_predoc_org.
  SELECT SINGLE * FROM mmim_predoc_org INTO ls_org
    WHERE guid = i_guid.
* Due to a change in the datastructures will predocuments from
* release 46A/B cannot not be loaded.
  IF ls_org-saprl = '46A' OR ls_org-saprl = '46B'.
    MESSAGE s035 WITH ls_org-saprl sy-saprl.
    EXIT.
  ENDIF.
* Is this predoc still allowed according to the customizing?
  READ TABLE lcl_migo_globals=>t_cust
       WITH KEY action = ls_org-action
                refdoc = ls_org-refdoc
       TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s025.
    EXIT.
  ENDIF.
* Read
  CALL METHOD lcl_migo_globals=>kernel->predocument_load( i_guid ).
  IF ls_org-refid+39 <> '_'.                                     "381402
*   Delete, if it is not a template
    CALL METHOD delete( i_guid ).                                "381402
  ELSE.                                                          "381402
*   If it's a template, set the date and time to the last use
    ls_org-datlo  = sy-datlo.                                    "381402
    ls_org-timlo  = sy-timlo.                                    "381402
    UPDATE mmim_predoc_org FROM ls_org.                          "381402
  ENDIF.                                                         "381402
ENDMETHOD.
************************************************************************
* Delete a predocument from the database and update the tree
************************************************************************
METHOD delete.
* Delete in the database organizational data
  DELETE FROM mmim_predoc_org WHERE guid = i_guid.
  CALL METHOD cl_mmim_datastore=>delete( i_guid ).
* BAdI: Predoc delete
  IF NOT lcl_migo_globals=>if_badi is initial.                 "552774
    CALL METHOD lcl_migo_globals=>if_badi->hold_data_delete
      EXPORTING
        i_guid = i_guid.
  ENDIF.                                                       "552774
* Send message
  def_sms 'TREE_PREDOC_DELETE' i_guid space.
ENDMETHOD.


ENDCLASS.



************************************************************************
* Forms needed for ALV callbacks
************************************************************************
FORM predoc_alv_status USING rt_extab TYPE slis_t_extab.     "#EC CALLED
  CALL METHOD oref_predocument->alv_callback_status
    CHANGING
      ct_extab = rt_extab.
ENDFORM.

FORM predoc_alv_user USING rf_ucomm    LIKE sy-ucomm         "#EC CALLED
                    rs_selfield TYPE slis_selfield.
  CALL METHOD oref_predocument->alv_callback_user
    CHANGING
      cf_ucomm    = rf_ucomm
      cs_selfield = rs_selfield.
ENDFORM.