*----------------------------------------------------------------------*
*   INCLUDE LMIGOCA1                                                   *
*   The multi-purpose control area of MIGO
*----------------------------------------------------------------------*

CLASS lcl_migo_controlarea DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    TYPES:
      ty_object_id TYPE char10.
    METHODS:
      constructor,
      set_visible
        IMPORTING i_visible TYPE abap_bool.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF pty_s_children,
        id      TYPE ty_object_id,
        object  TYPE REF TO lcl_migo_griddisplay,
      END OF pty_s_children,
      pty_t_children TYPE STANDARD TABLE OF pty_s_children
                     WITH KEY id.
    DATA:
      poref_container TYPE REF TO cl_gui_docking_container,
      poref_settings  TYPE REF TO cl_mmim_userdefaults,
      pt_children     TYPE pty_t_children,
      p_visible       TYPE abap_bool,
      p_created       TYPE abap_bool,                            "377139
      p_new_object_id TYPE ty_object_id.
    METHODS:
      state_save,
      new_result
        IMPORTING
          i_id   TYPE ty_object_id
          i_dref TYPE REF TO data,
      select_viewer
        IMPORTING
          i_id TYPE ty_object_id,
      mode_change_handler,
      set_button_status.
ENDCLASS.