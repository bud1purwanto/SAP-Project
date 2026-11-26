*----------------------------------------------------------------------*
*   INCLUDE LMIGOTP2                                                   *
*   Tips
*----------------------------------------------------------------------*

* MIGO sends an empty pop-up after changing the movement type "n563535

CLASS lcl_migo_tip IMPLEMENTATION.

************************************************************************
* Register for Messages and OK-codes
************************************************************************
METHOD constructor.
  DATA: lt_okcodes     TYPE lif_migo_frame~ty_t_okcodes,
        lt_message_ids TYPE lif_migo_frame~ty_t_message_ids.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_TIP'.
  APPEND 'MIGO_TIP_REQUEST' TO lt_message_ids.
  APPEND 'MIGO_TIP_RESET'   TO lt_message_ids.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer  = me
      it_receiving   = lt_message_ids.
  CREATE OBJECT p_oref_settings EXPORTING i_action = 'MIGO_TIPS'.
ENDMETHOD.

************************************************************************
* Message handler.
************************************************************************
METHOD lif_migo_frame~message_handler.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE i_message_id.
    WHEN 'MIGO_TIP_REQUEST'.
      p_docuobject = is_message-data1.
      CALL METHOD popup_call.
    WHEN 'MIGO_TIP_RESET'.
      CALL METHOD tips_reset.
  ENDCASE.
ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.
************************************************************************
* Show the requested tip and manipulate the user defaults according
* to the answer in the popup
************************************************************************
METHOD popup_call.
* Check whether this tip is still requested by the user
  CHECK p_oref_settings->get( p_docuobject ) = abap_false.
* Call the popup to show the help
  CALL SCREEN 1300 STARTING AT 2 6.
* MODIFY the user settings according TO the answer IN the popup.
  IF g_tip_dont_show_again = abap_true.
    CALL METHOD p_oref_settings->set( i_element = p_docuobject
                                      i_active  = abap_true ).
  ENDIF.
ENDMETHOD.

************************************************************************
* Reset all tips to unread
************************************************************************
METHOD tips_reset.
  CALL METHOD p_oref_settings->set( i_element = 'HELP_DEFAULTS_CHANGED'
                                    i_active  = abap_false ).
  CALL METHOD p_oref_settings->set( i_element = 'HELP_OK_PREDOC'
                                    i_active  = abap_false ).
  CALL METHOD p_oref_settings->set( i_element = 'HELP_OK_TAKE_VALUE'
                                    i_active  = abap_false ).
  CALL METHOD p_oref_settings->set( i_element = 'HELP_MIGO_DELETE_LINE'
                                    i_active  = abap_false ).
  CALL METHOD p_oref_settings->set( i_element = 'HELP_ERR_POS_CURSOR'
                                    i_active  = abap_false ).
  CALL METHOD p_oref_settings->set( i_element = 'HELP_MIGO_TRANS_COPY'
                                    i_active  = abap_false ).
ENDMETHOD.



************************************************************************
* PBO of popup: Create HTML control, get docu text, display
************************************************************************
METHOD pbo.
  DATA: l_header   TYPE thead,
        lt_lines   TYPE TABLE OF tline,
        lt_html    TYPE TABLE OF htmlline,
        l_url(255) TYPE c,
        l_repid    TYPE syrepid,
        l_dynnr    TYPE sydynnr.
  l_repid = sy-repid.
  l_dynnr = sy-dynnr.
  CREATE OBJECT p_oref_container
    EXPORTING
      repid                       = l_repid
      dynnr                       = l_dynnr
      container_name              = 'SUB_HTML'
    EXCEPTIONS
      others                      = 6.
  CHECK sy-subrc = 0.
  CREATE OBJECT p_oref_html
    EXPORTING
      parent             = p_oref_container
    EXCEPTIONS
      others             = 5.
  CHECK sy-subrc = 0.
* Retrieve text from database and prepare for display
  CALL FUNCTION 'DOCU_GET_FOR_F1HELP'
    EXPORTING
      id             = 'DT'
      langu          = sy-langu
      object         = p_docuobject
    IMPORTING
      head           = l_header
    TABLES
      line           = lt_lines
    EXCEPTIONS
      OTHERS         = 2.
  CHECK sy-subrc = 0.
* Convert to HTML-format
  CALL FUNCTION 'CONVERT_ITF_TO_HTML'
    EXPORTING
      i_header                 = l_header
    TABLES
      t_itf_text               = lt_lines
      t_html_text              = lt_html
    EXCEPTIONS
      OTHERS                   = 4.
  CHECK sy-subrc = 0.
* Show data in control
  CALL METHOD p_oref_html->load_data
    IMPORTING
      assigned_url      = l_url
    CHANGING
      data_table        = lt_html.
  CALL METHOD p_oref_html->show_data
    EXPORTING
      url               = l_url.

* Reset checkbox
  g_tip_dont_show_again = abap_false.
* Stati
  SET TITLEBAR  'TIP_POPUP'.
  SET PF-STATUS 'TIP_STATUS'.
ENDMETHOD.



************************************************************************
* PAI of popup: Every OKCODE will leave the popup.
* The controls are completely destroyed and will be rebuilt upon
* the next tip.
* Reason: When using the application log and starting the TIP from
* the "Position cursor" button within the popup (in this case
* the tip is transmitted from within the application log callback
* routine), the controls were gone afterwards.
************************************************************************
METHOD pai.
* Do not use SUPER->PAI here. This would cause LCL_MIGO_CURSOR
* to catch the position of the cursor on this popup.
* After returning from the tip, the application which needs
* the cursordata from the field where the cursor was before will
* have lost.
  CALL METHOD p_oref_html->free.
  CALL METHOD p_oref_container->free.
  CLEAR: p_oref_html, p_oref_container.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMETHOD.


ENDCLASS.