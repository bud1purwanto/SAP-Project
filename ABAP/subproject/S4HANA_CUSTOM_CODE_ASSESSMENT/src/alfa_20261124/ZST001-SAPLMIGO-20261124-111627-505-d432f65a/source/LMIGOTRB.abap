*----------------------------------------------------------------------*
*   INCLUDE LMIGOTRB                                                   *
*   New tree: Implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_newtree IMPLEMENTATION.

************************************************************************
* Register for messages, create docking container (needed to ensure
* a fixed sequence of the containers on screen).
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
        lt_sending   TYPE lif_migo_frame~ty_t_message_ids,
        l_extension TYPE i.
* Catch framework errors
  SET HANDLER cfw_error.
* Framework registration
  lif_migo_frame~class_id = 'MIGO_TREE'.
  APPEND 'MIGO_TREE_OPEN'    TO lt_receiving.
  APPEND 'MIGO_TREE_CLOSE'   TO lt_receiving.
  APPEND 'TRANSACTION_LEAVE' TO lt_receiving.
  APPEND 'MIGO_TREE_STATUS'  TO lt_sending.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING i_iref_viewer = me
              it_receiving  = lt_receiving
              it_sending    = lt_sending.

* User defaults
  CREATE OBJECT poref_settings EXPORTING i_action = 'MIGO_TREE'.
  CALL METHOD poref_settings->preset( i_element = 'DISPLAY'
                                      i_active  = abap_true ).
  CALL METHOD poref_settings->preset( i_element = 'WIDTH'
                                      i_active  = 160 ).
* Create the docking container
  l_extension = poref_settings->get( 'WIDTH' ).
  CREATE OBJECT poref_container
    EXPORTING side      = cl_gui_docking_container=>dock_at_left
              extension = l_extension.
* Call startup/hide-routine
  IF i_notree = abap_false AND
     poref_settings->get( 'DISPLAY' ) = abap_true.
    CALL METHOD tree_show.
  ELSE.
    CALL METHOD tree_hide.
  ENDIF.
ENDMETHOD.

************************************************************************
* Handler for messages
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.
METHOD lif_migo_frame~message_handler.
  CASE i_message_id.
    WHEN 'MIGO_TREE_OPEN'.
      CALL METHOD tree_show.
    WHEN 'MIGO_TREE_CLOSE'.
      CALL METHOD tree_hide.
  ENDCASE.
ENDMETHOD.

************************************************************************
* Show the tree, start it if necessary
************************************************************************
METHOD tree_show.
  CALL METHOD poref_container->set_visible( '1' ).
  CALL METHOD poref_settings->set( i_element = 'DISPLAY'
                                   i_active  = abap_true ).
  def_sms 'MIGO_TREE_STATUS' 'VISIBILITY' abap_true.
ENDMETHOD.

************************************************************************
* Hide the tree
************************************************************************
METHOD tree_hide.
  CALL METHOD poref_container->set_visible( '0' ).
  CALL METHOD poref_settings->set( i_element = 'DISPLAY'
                                   i_active  = abap_false ).
  def_sms 'MIGO_TREE_STATUS' 'VISIBILITY' abap_false.
ENDMETHOD.

************************************************************************
* Handler for CFW-errors
************************************************************************
METHOD cfw_error.
  MESSAGE e899(migo) WITH 'CNTL_ERROR' 'NEWTREE' space space.
ENDMETHOD.

ENDCLASS.