*----------------------------------------------------------------------*
*   INCLUDE LMIGODL1                                                   *
*   Dynpro locator
*----------------------------------------------------------------------*
CLASS lcl_migo_dynprolocator DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

PRIVATE SECTION.
  DATA:
    p_itemdetail_visible TYPE abap_bool,
    p_itemdetail_line    TYPE sytabix.
  METHODS:
    set_cursor_position
      IMPORTING
        i_glc       TYPE migo_global_counter
        i_fieldname TYPE migo_fieldname.

ENDCLASS.