*----------------------------------------------------------------------*
*   INCLUDE LMIGOTV1                                                   *
*   Tableview Viewer definitions                                       *
*----------------------------------------------------------------------*
CLASS lcl_migo_tableview DEFINITION
      INHERITING FROM lcl_migo_screenobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pbo_loop,
      pai REDEFINITION,
      pai_loop,
      cursor_position_resolve REDEFINITION.

ENHANCEMENT-POINT LMIGOTV1_01 SPOTS ES_SAPLMIGO STATIC.
  PRIVATE SECTION.
    METHODS:
      tableview_sort   IMPORTING i_sort_up     TYPE abap_bool,
      tableview_search IMPORTING i_search_next TYPE abap_bool,
      tableview_delete_not_ok,
      tableview_line_show                                        "213353
        IMPORTING i_line TYPE sytabix,                           "213353
      log_display,
      field_selection_line,
      valuecopy,
      line_expand_collapse.
* fields
    DATA:
      p_itemdetail_line    TYPE i,          "sytabix from detailitem
      p_itemdetail_visible TYPE abap_bool,  "true=itemdetail is visible
      p_ga_visible         TYPE abap_bool,  "matrix of variants
      p_displayed_lines    TYPE sy-loopc.   "displayed lines in TV
ENDCLASS.


CLASS lcl_migo_tableview_buttons DEFINITION
                                 INHERITING FROM lcl_migo_screenobject.
ENDCLASS.