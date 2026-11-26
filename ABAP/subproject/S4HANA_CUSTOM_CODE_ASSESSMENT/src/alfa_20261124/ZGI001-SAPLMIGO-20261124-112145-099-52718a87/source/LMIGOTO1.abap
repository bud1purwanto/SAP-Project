*----------------------------------------------------------------------*
*   INCLUDE LMIGOTO1                                                   *
*   Common toggler
*----------------------------------------------------------------------*

CLASS lcl_migo_toggler DEFINITION
      INHERITING FROM lcl_migo_screenobject.

PUBLIC SECTION.
  INTERFACES:
    lif_migo_frame.
  METHODS:
    constructor
      IMPORTING
        i_name             TYPE char30
        i_active_dyn       TYPE sydynnr
        i_inactive_dyn     TYPE sydynnr
        i_subscreen_dyn    TYPE sydynnr
        i_okcode_open      TYPE syucomm
        i_okcode_close     TYPE syucomm
        i_message_open     TYPE lif_migo_frame~ty_message_id OPTIONAL
        i_global_current   TYPE char40
        i_global_subscreen TYPE char40,
    screen_set
      IMPORTING
        i_active_dyn       TYPE sydynnr
        i_inactive_dyn     TYPE sydynnr
        i_subscreen_dyn    TYPE sydynnr
        i_subscreen        TYPE char40.

PRIVATE SECTION.
  DATA:
    p_visible        TYPE abap_bool,
    poref_settings   TYPE REF TO cl_mmim_userdefaults,
    p_message_id     TYPE lif_migo_frame=>ty_message_id,
    p_message_open   TYPE lif_migo_frame=>ty_message_id,
    p_active_dyn     TYPE sydynnr,
    p_inactive_dyn   TYPE sydynnr,
    p_okcode_open    TYPE syucomm,
    p_okcode_close   TYPE syucomm,
    p_current_dyn    TYPE char40,
    p_subscreen      TYPE char40.
  METHODS:
    visibility_set.

ENDCLASS.