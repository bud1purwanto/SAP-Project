*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR3                                                   *
*   Tree
*----------------------------------------------------------------------*

CLASS lcl_migo_tree DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    TYPES: ty_object TYPE char3,             "Identifier for PO/MD/...
           BEGIN OF ty_data,                 "Data storage structure
* Internal organization
             node   TYPE lvc_nkey,           "Node id in tree
             top    TYPE object_type,        "Searchres. or history
             type   TYPE object_type,        "PO, MatDoc, PreDoc,...
             take(1)  TYPE c,                  "Double click takes data
             dummy(1) TYPE c,                  "Dummy data line
             style  TYPE int4,               "Line style (red, green..)
* Table data
* Purchase orders
             ebeln  TYPE ebeln,
             ebelp  TYPE ebelp,
             lifnr  TYPE lifnr,
             name1  TYPE name1_gp,
             matnr  TYPE matnr,
             maktx  TYPE maktx,
             idnlf  TYPE idnlf,
             ean11  TYPE ean11,
             reswk  TYPE reswk,
             eindt  TYPE eindt,
             ernam  TYPE ernam,
             menge  TYPE bstmg,
             menge_c TYPE char16,
             meins  TYPE bstme,
             wemng  TYPE weemg,
             wemng_c TYPE char16,
* Material documents
             mblnr  TYPE mblnr,
             mjahr  TYPE mjahr,
             zeile  TYPE mblpo,
             vgart  TYPE vgart,
* Predocuments
             guid   TYPE guid_22,
             refid  TYPE refid_d,
* Orders
             aufnr  TYPE aufnr,
* Reservations
             rsnum  TYPE rsnum,
             longnum TYPE /sappspro/longnum,
           END OF ty_data,
           ty_result_table TYPE STANDARD TABLE OF ty_data.
    CONSTANTS:
      c_purchase_order    TYPE object_type VALUE '101',
      c_material_document TYPE object_type VALUE '102',
      c_predoc            TYPE object_type VALUE '103',
      c_order             TYPE object_type VALUE '104',
      c_reservation       TYPE object_type VALUE '105',
      c_history_length    TYPE i           VALUE 10.
    DATA:
      f_is_visible         TYPE c READ-ONLY,  "Is the tree visible
      f_not_creatable      TYPE c READ-ONLY.      "Error during init
    METHODS:
      constructor                             "Create the object
        IMPORTING
          i_repid  LIKE sy-repid OPTIONAL
          i_dynnr  LIKE sy-dynnr OPTIONAL
          i_notree TYPE char1    OPTIONAL,
      destroy,                                 "Cleanup
      toggle_visibility,                       "Switch on/off
      history_object_add                       "Add on object
        IMPORTING
          i_type      TYPE object_type
          i_highlight TYPE c
          i_local     TYPE c OPTIONAL
          is_data     TYPE ty_data,
      history_object_delete                    "Delete an object
        IMPORTING
          i_type      TYPE object_type
          i_local     TYPE c OPTIONAL
          is_data     TYPE ty_data,
      searchresult_add
        IMPORTING
          i_type    TYPE object_type
          it_result TYPE ty_result_table,
      status_information.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF pty_nodes,                       "Hierarchy data
        object TYPE object_type,
        node   TYPE lvc_nkey,
      END OF pty_nodes,
      BEGIN OF pty_sort,                       "Sorting info searchres.
        field_id TYPE char2,        "Short representation of fieldname
        order(1) TYPE c,
      END OF pty_sort,
      BEGIN OF pty_sortmaster,                 "Control table
        type      TYPE object_type,
        cnt       TYPE i,
        field_id  TYPE char2,
        fieldname TYPE fieldname,
        order(1)  TYPE c,
        take(1)   TYPE c,
        node      TYPE lvc_nkey,
        image     TYPE tv_image,
        list(1)   TYPE c,
      END OF pty_sortmaster.
    DATA:
      oref_docking TYPE  REF TO cl_gui_docking_container,
      oref_tree    TYPE  REF TO cl_gui_alv_tree,
      oref_toolbar TYPE  REF TO cl_gui_toolbar,
      oref_defaults TYPE REF TO cl_mmim_userdefaults,
      pt_data TYPE TABLE OF ty_data,           "AppliServer data
      pt_tree TYPE TABLE OF ty_data,           "Tree data, DO NOT USE!!!
      pt_pretable TYPE TABLE OF ty_data,       "Used if tree not running
      pt_nodes TYPE TABLE OF pty_nodes,         "Table for top nodes
      pt_search TYPE TABLE OF ty_data,         "Searchresult
      pt_sort   TYPE TABLE OF pty_sort,         "Actual sorting order
      pt_sortmaster TYPE TABLE OF pty_sortmaster, "Sort master table
      p_sorttype   TYPE object_type,            "Actual sortresult cont.
      pt_fc   TYPE lvc_t_fcat,                  "Fieldcatalog
      ps_header TYPE treev_hhdr,                "Tree header
      pt_allowed_objects TYPE TABLE OF object_type, "selectable
      p_running(1) TYPE c,                      "Tree started
      p_repid TYPE repid,                       "Assigned report
      p_dynnr TYPE dynnr.                       "Assigned screen
    DATA:
      p_node_key TYPE lvc_nkey.                                  "216027
    CONSTANTS:
      c_searchresult TYPE object_type VALUE '001',
      c_history      TYPE object_type VALUE '002',
      c_single       TYPE char1       VALUE 'L',
      c_section      TYPE char1       VALUE 'S',
      c_all          TYPE char1       VALUE 'A',
      c_icon_none    TYPE tv_image    VALUE 'BNONE',
      c_icon_close      TYPE iconname VALUE '@3X@',
      c_icon_delete     TYPE iconname VALUE '@11@',
      c_icon_favorite   TYPE iconname VALUE '@6D@',              "381402
      c_style_highlight TYPE int4 VALUE
           cl_gui_column_tree=>style_emphasized_negative,
      c_style_default TYPE int4 VALUE
           cl_gui_column_tree=>style_default,
      c_style_inactive TYPE int4 VALUE
           cl_gui_column_tree=>style_inactive,
      x TYPE c VALUE 'X'.
    METHODS:
      tree_start,
      say_goodbye,                             "Tree cannot be created
      button_bar,                              "Modify button bar
      tree_events,                             "Register events in tree
      skeleton_build,                          "Tree skeleton
      history_read,                            "Initial tree content
      add_hierarchy                            "Add a node
        IMPORTING
          i_top    TYPE object_type
          i_type   TYPE object_type
          i_dummy  TYPE c
          i_parent TYPE lvc_nkey
          i_text   TYPE lvc_value
          i_icon   TYPE tv_image OPTIONAL
        EXPORTING
          e_key    TYPE lvc_nkey,
      tree_state_save,                         "Expanded/collapsed nodes
      tree_state_load,
      toolbar_event FOR EVENT function_selected OF cl_gui_toolbar
        IMPORTING
          fcode,
      tree_object_take
        IMPORTING
          i_node TYPE lvc_nkey,
      tree_double_click FOR EVENT node_double_click OF cl_gui_alv_tree
        IMPORTING
          node_key,
      context_menu_request
              FOR EVENT node_context_menu_request OF cl_gui_alv_tree
        IMPORTING
          node_key
          menu,
      context_menu_select
              FOR EVENT node_context_menu_selected OF cl_gui_alv_tree
        IMPORTING
          node_key
          fcode,
      searchresult_update
        IMPORTING
          i_type    TYPE object_type,
      hierarchy_set,
      sortmaster_build,
      fieldcatalog_build,
      delete_history
        IMPORTING
          i_node  TYPE lvc_nkey,
      delete_history_single
        IMPORTING
          i_node  TYPE lvc_nkey,
      delete_from_buttonbar,
      determine_scope
        IMPORTING
          i_node TYPE lvc_nkey
        RETURNING
          value(e_scope) TYPE char1,
      new_searchresult_matdoc IMPORTING i_data         TYPE REF TO data,
      new_searchresult_po     IMPORTING i_data TYPE REF TO data.
ENDCLASS.