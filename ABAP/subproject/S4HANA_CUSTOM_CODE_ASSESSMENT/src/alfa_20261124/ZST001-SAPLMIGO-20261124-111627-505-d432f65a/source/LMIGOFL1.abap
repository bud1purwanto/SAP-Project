*----------------------------------------------------------------------*
*   INCLUDE LMIGOFL1                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_firstline DEFINITION
      INHERITING FROM lcl_migo_screenobject.
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
*     POV-Modules to fill the values for the listboxes
      pov_action,
      pov_refdoc,
      pbo REDEFINITION,
      pai_mvt_sobkz_change,
      pai_mvt_sobkz_check,
      cursor_position_resolve REDEFINITION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF pty_s_action,
        action TYPE goaction,
        value  TYPE val_text,
        sort   TYPE i,                                           "383269
      END OF pty_s_action,
      BEGIN OF pty_s_refdoc,
        refdoc TYPE refdoc,
        value  TYPE val_text,
      END OF pty_s_refdoc.
    DATA:
*     Current valid settings of ACTION and REFDOC
      p_action TYPE goaction,
      p_refdoc TYPE refdoc,
*     The user defaults
      poref_settings TYPE REF TO cl_mmim_userdefaults,
*     Valid entries in the listboxes
      pt_action TYPE TABLE OF pty_s_action,
      pt_refdoc TYPE TABLE OF pty_s_refdoc,
*     Materialdocument has SET/GET-Parameter (hmpf), therefore special
*     treatment with respect to reaction for OK_GO necessary
      p_last_mblnr        TYPE mblnr,
      p_last_mjahr        TYPE mjahr,
      p_locked            TYPE abap_bool,
      p_firstline_log     TYPE char70,
      p_searchlist_button TYPE abap_bool.
    METHODS:
      settings_preset,
      listbox_action_set,
      listbox_refdoc_set,
      mode_change_handler,
      data_send_to_kernel
        IMPORTING
          i_action TYPE goaction
          i_refdoc TYPE refdoc,
      cursor_set.
ENDCLASS.