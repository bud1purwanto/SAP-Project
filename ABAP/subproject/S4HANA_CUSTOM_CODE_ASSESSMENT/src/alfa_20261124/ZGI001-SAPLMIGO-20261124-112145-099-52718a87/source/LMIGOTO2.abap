*----------------------------------------------------------------------*
*   INCLUDE LMIGOTO2                                                   *
*   Global toggler implementation
*----------------------------------------------------------------------*

CLASS lcl_migo_toggler IMPLEMENTATION.

************************************************************************
* Constructor
************************************************************************
METHOD constructor.
  DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes,
        lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids,
        lt_sending     TYPE lif_migo_frame=>ty_t_message_ids.
  FIELD-SYMBOLS: <l_dynnr> TYPE sydynnr.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = i_name.
* Copy importings to memory
  p_active_dyn            = i_active_dyn.
  p_inactive_dyn          = i_inactive_dyn.
  p_okcode_open           = i_okcode_open.
  p_okcode_close          = i_okcode_close.
  p_current_dyn           = i_global_current.
  p_subscreen             = i_global_subscreen.
  p_message_open          = i_message_open.
  ASSIGN (p_subscreen) TO <l_dynnr>.
  <l_dynnr>               = i_subscreen_dyn.
  CONCATENATE i_name '_STATUS' INTO p_message_id.
  APPEND p_okcode_open  TO lt_okcodes.
  APPEND p_okcode_close TO lt_okcodes.
  IF NOT p_message_open IS INITIAL.
    APPEND i_message_open TO lt_receiving.
  ENDIF.
  APPEND p_message_id TO lt_sending.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer  = me
      it_okcodes     = lt_okcodes
      it_receiving   = lt_receiving
      it_sending     = lt_sending.
  CREATE OBJECT poref_settings TYPE cl_mmim_userdefaults
    EXPORTING
      i_action = i_name.
  CALL METHOD poref_settings->preset( i_element = 'VISIBILITY'
                                      i_active  = abap_true ).
  p_visible = poref_settings->get( 'VISIBILITY' ).
  CALL METHOD visibility_set.
ENDMETHOD.

************************************************************************
* Choose the appropriate subscreen to be included,
* save the state into defaults and send a message
************************************************************************
METHOD visibility_set.
  FIELD-SYMBOLS: <l_dynnr> TYPE sydynnr.
  CALL METHOD poref_settings->set( i_element = 'VISIBILITY'
                                  i_active  = p_visible ).
  def_sms p_message_id 'VISIBILITY' p_visible.
  ASSIGN (p_current_dyn) TO <l_dynnr>.
  CASE p_visible.
    WHEN abap_true.  <l_dynnr> = p_active_dyn.
    WHEN abap_false. <l_dynnr> = p_inactive_dyn.
  ENDCASE.
ENDMETHOD.

************************************************************************
* IF migo_mode is changed (transfer<-->normal mode and vice versa) the
* toggler subscreens have to changed accordingly
************************************************************************
METHOD screen_set.
  p_active_dyn    = i_active_dyn.
  p_inactive_dyn  = i_inactive_dyn.
  p_subscreen     = i_subscreen.
* Set correct toggler subscreen (301 or 303)
* This method is only used for switching between the regular detail
* screen and the transfer detail screen. Therefore it is ok to hardcode
* g_detail_current_dyn.
* The constructor sets g_detail_current_dyn to 301 per default. That
* means if the detail starts in transfer mode, have to set
* g_detail_current_dyn here.
  CASE p_visible.
    WHEN abap_true.   g_detail_current_dyn = p_active_dyn.
    WHEN abap_false.  g_detail_current_dyn = p_inactive_dyn.
  ENDCASE.
ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  CASE i_okcode.
    WHEN p_okcode_open.  p_visible = abap_true.
    WHEN p_okcode_close. p_visible = abap_false.
  ENDCASE.
  CALL METHOD visibility_set.
ENDMETHOD.

************************************************************************
* Message handler
************************************************************************
METHOD lif_migo_frame~message_handler.
  p_visible = abap_true.
  CALL METHOD visibility_set.
ENDMETHOD.

ENDCLASS.