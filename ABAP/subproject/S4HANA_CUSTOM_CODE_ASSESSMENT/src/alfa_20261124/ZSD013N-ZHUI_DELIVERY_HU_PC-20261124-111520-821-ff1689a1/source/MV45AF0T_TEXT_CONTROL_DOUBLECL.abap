*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_DOUBLECL                             *
*----------------------------------------------------------------------*
CLASS C_EVENT_RECEIVER DEFINITION.

  public section.
  methods event_handler_dblclick
          for event dblclick of c_textedit_control.
endclass.

************************************************************************
* CLASS   c_event_receiver
* Ereignissteuerung Doppelklick auf Text im Übersichtsbild
************************************************************************
CLASS C_event_receiver implementation.
*-----------------------------------------------------------------------
* METHOD  event_handler_dblclick
*-----------------------------------------------------------------------
  method event_handler_dblclick.
     FCODE = FCODE_TEXT_CONTROL_DETAIL.
  endmethod.
ENDCLASS.

* Lokaler Event Receiver für Ereignis Doppelklick
DATA: EVENT_RECEIVER TYPE REF TO C_EVENT_RECEIVER.