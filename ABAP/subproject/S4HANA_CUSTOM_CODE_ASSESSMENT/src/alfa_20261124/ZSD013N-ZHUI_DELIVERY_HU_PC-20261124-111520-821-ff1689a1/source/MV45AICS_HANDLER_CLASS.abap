*&---------------------------------------------------------------------*
*&  Include           MV45AICS_HANDLER_CLASS
*&---------------------------------------------------------------------*


CLASS cl_event_receiver_cs DEFINITION.

  PUBLIC SECTION.
    DATA: ucomm TYPE sy-ucomm.
    DATA: selfield TYPE slis_selfield.
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.

  PRIVATE SECTION.
ENDCLASS.                    "CL_EVENT_RECEIVER_CS DEFINITION
*----------------------------------------------------------------------*
*       CLASS CL_EVENT_RECEIVER_CS IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_event_receiver_cs IMPLEMENTATION.
  METHOD handle_double_click.
    PERFORM cs_read_from_alv.
    fcode = 'ENT1'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
ENDCLASS.                    "CL_EVENT_RECEIVER_CS IMPLEMENTATION