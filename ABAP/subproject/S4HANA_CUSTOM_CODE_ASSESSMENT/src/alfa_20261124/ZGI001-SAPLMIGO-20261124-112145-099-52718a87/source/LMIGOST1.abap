*----------------------------------------------------------------------*
*   INCLUDE LMIGOST1                                                   *
*   GUI status
*----------------------------------------------------------------------*
CLASS lcl_migo_status DEFINITION.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor.

PRIVATE SECTION.
  TYPES:
    ty_t_excluding TYPE STANDARD TABLE OF gui_code.
  DATA:
    p_tree_visible   TYPE abap_bool,
    pt_excluding     TYPE ty_t_excluding,
    p_detail_visible TYPE abap_bool,                         "#EC NEEDED
    p_detail_line    TYPE sytabix.                           "#EC NEEDED

  METHODS:
    status_set,
    popup_to_confirm
      IMPORTING
        i_title TYPE char50
      RETURNING
        value(e_success) TYPE abap_bool.



ENDCLASS.