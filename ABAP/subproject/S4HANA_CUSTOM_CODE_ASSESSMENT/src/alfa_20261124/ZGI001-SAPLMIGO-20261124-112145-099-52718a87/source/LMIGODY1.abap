*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class LCL_MIGO_DETAIL_EXT_INT
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_ext_int DEFINITION
      INHERITING FROM lcl_migo_detailobject.

  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    METHODS:
      constructor,
      pbo REDEFINITION,
      pai REDEFINITION,
      cursor_position_resolve REDEFINITION,
      get_tab_visibility
        IMPORTING       is_goitem   TYPE goitem
        RETURNING VALUE(rv_visible) TYPE abap_bool.

ENDCLASS.               "LCL_MIGO_DETAIL_EXT_INT
*&  Include           LMIGODY1
*&---------------------------------------------------------------------*