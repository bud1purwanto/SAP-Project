*----------------------------------------------------------------------*
*   INCLUDE LMIGOGD1                                                   *
*   Encapsulation of an ALV grid to show searchresults and other
*   tables
*----------------------------------------------------------------------*

CLASS lcl_migo_griddisplay DEFINITION.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING i_id     TYPE lcl_migo_controlarea=>ty_object_id
                  i_parent TYPE REF TO cl_gui_container,
      new_data
        IMPORTING i_dref TYPE REF TO data,
      set_visible
        IMPORTING i_visible TYPE abap_bool,
      rebuild_toolbar.

  PRIVATE SECTION.
    DATA:
      poref_grid   TYPE REF TO cl_gui_alv_grid,
      p_running    TYPE abap_bool VALUE abap_false,
      p_my_id      TYPE lcl_migo_controlarea=>ty_object_id,
      p_visible    TYPE abap_bool,
      pt_fieldcat  TYPE lvc_t_fcat,
      ps_layout    TYPE lvc_s_layo,
      pt_sort      TYPE lvc_t_sort,
      ps_variant   TYPE disvariant,
      pt_excluding TYPE ui_functions,
      pt_matdocs   TYPE lcl_migo_search=>ty_t_materialdocument,
      pt_pos       TYPE lcl_migo_search=>ty_t_purchase_order,
      pt_order     TYPE lcl_migo_search=>ty_t_order,
      pt_reservation TYPE lcl_migo_search=>ty_t_reservation.
    METHODS:
      tables_build,
      toolbar_build_handler FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      menu_handler FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      click_handler FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_column,
      objects_take
        IMPORTING i_column TYPE lvc_s_col OPTIONAL.



ENDCLASS.