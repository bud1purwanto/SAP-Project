*----------------------------------------------------------------------*
*   INCLUDE MV50STAT_DISP                                              *
*----------------------------------------------------------------------*
INCLUDE <CTLDEF>.
INCLUDE <ICON>.

* ALV type pool
TYPE-POOLS: SLIS, CNTL.

* definition of ALV view delivery header
DATA : begin of Gs_OUTTAB_header.
        include structure LEDLVSTATDISPhead.
DATA:
       ICONS(30) TYPE C,
       SYMBOLS(30) TYPE C,
       INFO(4) TYPE C,
       COLINFO TYPE LVC_T_SCOL,
       CHECKBOX,
       LIGHTS.
DATA: END OF Gs_OUTTAB_header.

DATA : Gt_OUTTAB_header like Gs_OUTTAB_header occurs 0
                                      with header line.

* definition of ALV view delivery item
DATA : begin of Gs_OUTTAB_item.
        include structure LEDLVSTATDISPITEM.
DATA:
       ICONS(30) TYPE C,
       SYMBOLS(30) TYPE C,
       INFO(4) TYPE C,
       COLINFO TYPE LVC_T_SCOL,
       CHECKBOX,
       LIGHTS,
* for ALV list sorting
       gf_itemsort like lips-posnr.
DATA: END OF Gs_OUTTAB_item.

DATA : Gt_OUTTAB_item like Gs_OUTTAB_item occurs 10
                                   with header line.

DATA : GF_SUBITEMS like charx.

DATA: GT_FIELDCAT_LVC_HEADER TYPE LVC_T_FCAT WITH HEADER LINE.
DATA: GT_FIELDCAT_LVC_ITEM TYPE LVC_T_FCAT WITH HEADER LINE.

DATA: GS_VARIANT_HEADER  TYPE DISVARIANT,
      GS_VARIANT_ITEM    TYPE DISVARIANT,
      GT_COLOR TYPE LVC_T_SCOL WITH HEADER LINE,
      GS_FUNCTION TYPE LVC_S_FUNC,
      GS_TOOLBAR  TYPE STB_BUTTON,
      GS_PRINT    TYPE LVC_S_PRNT,
      GT_index_rows TYPE lvc_t_row with header line,
      GS_LAYOUT_header   TYPE LVC_S_LAYO,
      GS_LAYOUT_item     TYPE LVC_S_LAYO,
      GT_EVENTS   TYPE CNTL_SIMPLE_EVENTS,
      GT_FCODES   TYPE UI_FUNCTIONS,
      GT_TOOLBAR_EXCLUDING TYPE UI_FUNCTIONS,
      BEGIN OF GT_EXCLUDING OCCURS 0,
        FUNCTION LIKE RSMPE-FUNC,
      END OF GT_EXCLUDING,
      gf_default.

DATA: GRID_HEADER_STATUS TYPE SCRFNAME
                      VALUE 'HEADER_STATUS_0100_GRID1',
      GRID_ITEM_STATUS TYPE SCRFNAME
                      VALUE 'ITEM_STATUS_0100_GRID2',
      G_CUSTOM_CONTAINER_01 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_CUSTOM_CONTAINER_02 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      LIN1 TYPE P,
      N1 TYPE I,
      N TYPE I.
DATA: GRID1  TYPE REF TO CL_GUI_ALV_GRID.
DATA: GRID2  TYPE REF TO CL_GUI_ALV_GRID.

CONSTANTS: GC_HEADER_LOGGRP_INB like disvariant-log_group  value '0001'.
CONSTANTS: GC_ITEM_LOGGRP_INB   like disvariant-log_group  value '0002'.
CONSTANTS: GC_HEADER_LOGGRP_OUTB like disvariant-log_group value '0003'.
CONSTANTS: GC_ITEM_LOGGRP_OUTB   like disvariant-log_group value '0004'.
CONSTANTS: GC_VAR_MAINT_USER_SPECIFIC value 'U'.
CONSTANTS: GC_SUBITEM_LOW(6) type c value '900000'.
constants: gc_enable_set_default value 'X'.                  "hp_332790

*---------------------------------------------------------------------*
*       CLASS CL_EVENT_RECV_HEAD DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS CL_EVENT_RECV_HEAD_STATUS_DISP DEFINITION.
  PUBLIC SECTION.
    DATA: UCOMM TYPE SY-UCOMM.
    METHODS:
    HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW E_COLUMN,
    handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive,
    handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
  PRIVATE SECTION.
ENDCLASS.
*---------------------------------------------------------------------*
*       CLASS CL_EVENT_RECV_ITEM DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS CL_EVENT_RECV_ITEM_STATUS_DISP DEFINITION.
  PUBLIC SECTION.
    DATA: UCOMM TYPE SY-UCOMM.
    METHODS:
    HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW E_COLUMN,
    handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive,
    handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
  PRIVATE SECTION.
ENDCLASS.

DATA: EVT_RCV_HEAD_STAT_DISP TYPE REF TO CL_EVENT_RECV_HEAD_STATUS_DISP.
DATA: EVT_RCV_ITEM_STAT_DISP TYPE REF TO CL_EVENT_RECV_ITEM_STATUS_DISP.