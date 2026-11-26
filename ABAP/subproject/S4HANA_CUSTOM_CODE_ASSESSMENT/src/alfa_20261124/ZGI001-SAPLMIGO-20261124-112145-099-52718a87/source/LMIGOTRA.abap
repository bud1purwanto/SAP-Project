*----------------------------------------------------------------------*
*   INCLUDE LMIGOTRA                                                   *
*   New tree: Definitions
*----------------------------------------------------------------------*

************************************************************************
* Main tree class. Maintains docking container and tree. Communicates
* with the outside world.
************************************************************************
CLASS lcl_migo_newtree DEFINITION.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor
        IMPORTING i_notree TYPE abap_bool.

  PRIVATE SECTION.
    DATA:
      poref_container TYPE REF TO cl_gui_docking_container,
      poref_tree      TYPE REF TO cl_gui_alv_tree,
      poref_settings  TYPE REF TO cl_mmim_userdefaults.
    METHODS:
      tree_show,
      tree_hide,
      cfw_error FOR EVENT flush_error OF cl_gui_cfw.
ENDCLASS.


************************************************************************
* Node class. Base for all nodes in the tree
************************************************************************
CLASS lcl_migo_newtree_node DEFINITION.

  PUBLIC SECTION.
    TYPES:
      ty_t_children TYPE STANDARD TABLE OF
                         REF TO lcl_migo_newtree_node.
    DATA:
      node     TYPE lvc_nkey      READ-ONLY,
      text     TYPE lvc_value     READ-ONLY,
      children TYPE ty_t_children READ-ONLY.
    METHODS:
      insert
        IMPORTING
          i_parent TYPE REF TO lcl_migo_newtree_node
          i_text   TYPE lvc_value.
ENDCLASS.