*&---------------------------------------------------------------------*
*&  Include           ZCOI_KE21N_SR_INCL
*&---------------------------------------------------------------------*
INCLUDE ZABAPALV.

DATA: V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZCOI_KE21N_SR'.
CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.  "for event handling

DATA: OK_CODE LIKE SY-UCOMM,
      SAVE_OK LIKE SY-UCOMM,
      DIALOG_BOX  TYPE REF TO CL_GUI_DIALOGBOX_CONTAINER,
      GRID1  TYPE REF TO CL_GUI_ALV_GRID,
      G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GS_LAYOUT TYPE LVC_S_LAYO,
      G_MAX TYPE I VALUE 10,
      GT_FIELDCAT TYPE LVC_T_FCAT,
      G_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER,
      GS_VARIANT TYPE DISVARIANT,
      LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE.

DATA: GT_STABLE TYPE LVC_S_STBL.


*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV.
  DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.

  PERFORM F_FIELD_CATALOG. "changing gt_fieldcat.
  PERFORM PREPARE_LAYOUT CHANGING GS_LAYOUT .
  PERFORM EXCLUDE_TB_FUNCTIONS CHANGING LT_EXCLUDE.

  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.

  CREATE OBJECT GRID1
    EXPORTING
      I_PARENT = DIALOG_BOX.

  SORT IT_SO BY ERROR BELNR ASCENDING.
  CALL METHOD GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
      IS_VARIANT           = GS_VARIANT
      I_SAVE               = 'A'
    CHANGING
      IT_OUTTAB            = IT_SO[]
      IT_FIELDCATALOG      = GT_FIELDCAT[].

*  CREATE OBJECT G_EVENT_RECEIVER.
*  SET HANDLER G_EVENT_RECEIVER->CATCH_DOUBLECLICK FOR GRID1.

ENDFORM.                    "display_alv


*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_01A USING 'it_so' :

   'ICONS'  '' ''  '' '' '' '' '10'  'Stts'           '' '' '' '' '' '',
   'MATNR'  '' ''  '' '' '' '' '10'  'Material'           '' '' '' '' '' '',
   'WERKS'  '' ''  '' '' '' '' '6'  'Plant'           '' '' '' '' '' '', "add new company
   'VBELN'  '' ''  '' '' '' '' '10'  'SO number'           '' '' '' '' '' '',
   'POSNR'  '' ''  '' '' '' '' '6'  'Item'           '' '' '' '' '' '',
   'KCMENG'  '' ''  '' '' '' '' '12'  'DO Qty (kg)'           '' '' '' '' '' '',
   'KCMENG2'  '' ''  '' '' '' '' '12'  'DO Qty (UOM)'           '' '' '' '' '' '',
   'VRKME'  '' ''  '' '' '' '' '4'  'So Unit'           '' '' '' '' '' '',
   'QCOPA'  '' ''  '' '' '' '' '12'  'COPA Qty'           '' '' '' '' '' '',
   'DELTA'  '' ''  '' '' '' '' '12'  'Delta'           '' '' '' '' '' '',
   'BELNR'  '' ''  '' '' '' '' '10'  'COPA type-A'           '' '' '' '' '' '',
   'BELNR2'  '' ''  '' '' '' '' '10'  'COPA type-F'           '' '' '' '' '' '',
   'REMARK'  '' ''  '' '' '' '' '35'  'Remark'           '' '' '' '' '' ''.

*  T_FIELDCAT-NO_ZERO = ''.
*  MODIFY t_fieldcat TRANSPORTING LZERO WHERE FIELDNAME = 'BELNR2'.
ENDFORM.                    " f_field_catalog


*&---------------------------------------------------------------------*
*&      Form  prepare_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM PREPARE_LAYOUT  CHANGING P_GS_LAYOUT TYPE LVC_S_LAYO.
  P_GS_LAYOUT-ZEBRA = 'X' .
*  p_gs_layout-grid_title = sy-repid.  "'Template ALV Report' .
  P_GS_LAYOUT-SMALLTITLE = 'X' .
  P_GS_LAYOUT-CWIDTH_OPT = 'X' .
  P_GS_LAYOUT-BOX_FNAME = 'BOX'.
  P_GS_LAYOUT-EDIT = ''.
  P_GS_LAYOUT-SEL_MODE = 'A'.
  P_GS_LAYOUT-INFO_FNAME = 'LINE_COLOR'.

  GS_VARIANT-REPORT = SY-REPID.

ENDFORM.                    " prepare_layout

*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " f_layout



*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_01a
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TAB     text
*      -->FU_FNAME   text
*      -->FU_TYPES   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_CTAB    text
*      -->FU_CFIELD  text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_JUST    text
*      -->FU_ICON    text
*      -->FU_ZERO    text
*      -->FU_KEY     text
*      -->FU_HOTSP   text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_01A USING FU_TAB
                                FU_FNAME
                                FU_TYPES
                                FU_REFTB
                                FU_REFLD
                                FU_CTAB
                                FU_CFIELD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_JUST
                                FU_ICON
                                FU_ZERO
                                FU_KEY
                                FU_HOTSP.

  DATA M_FIELDCAT TYPE LVC_S_FCAT .
  CLEAR: T_FIELDCAT.
  M_FIELDCAT-TABNAME       = FU_TAB.
  M_FIELDCAT-FIELDNAME     = FU_FNAME.
  M_FIELDCAT-DATATYPE       = FU_TYPES.
  M_FIELDCAT-REF_TABLE   = FU_REFTB.
  M_FIELDCAT-REF_FIELD = FU_REFLD.
  M_FIELDCAT-TABNAME      = FU_CTAB.    "cek
  M_FIELDCAT-CFIELDNAME    = FU_CFIELD.
  M_FIELDCAT-NO_OUT        = FU_NOOUT.
  M_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  M_FIELDCAT-REPTEXT     = FU_FLTXT.
  M_FIELDCAT-DO_SUM        = FU_DOSUM.
  M_FIELDCAT-JUST          = FU_JUST.
  M_FIELDCAT-ICON          = FU_ICON.
  M_FIELDCAT-NO_ZERO       = FU_ZERO.
  M_FIELDCAT-KEY       = FU_KEY.
  M_FIELDCAT-HOTSPOT       = FU_HOTSP.

  IF M_FIELDCAT-FIELDNAME = 'BELNR2'.
    M_FIELDCAT-LZERO = 'X'.
  ENDIF.
  APPEND M_FIELDCAT TO GT_FIELDCAT.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.
ENDFORM.                    " f_alv_fieldcatg_01

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      REFRESH: IT_SO, IT_LIPS, IT_COPA, IT_COPA2, WA_ZTLOG, IT_MSG.
      CLEAR: IT_SO, IT_LIPS, IT_COPA, IT_COPA2, WA_ZTLOG, IT_MSG.

      SET SCREEN 0.
    WHEN 'KE21N'.
      PERFORM SELECT_LINES.
      PERFORM RUN_KE21N.
    WHEN 'KE21N2'.
      PERFORM SELECT_LINES.
      PERFORM RUN_KE21N2.
  ENDCASE.

  CALL METHOD GRID1->REFRESH_TABLE_DISPLAY.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
  SET TITLEBAR 'MAIN_100'.

ENDMODULE.                 " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  select_lines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_LINES.
*  sort it_so by dcid.
  IT_SO-BOX = ''.
  MODIFY IT_SO TRANSPORTING BOX WHERE BOX NE ''.

  CALL METHOD GRID1->CHECK_CHANGED_DATA.

  CALL METHOD GRID1->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROW_NO[].

  LOOP AT LT_ROW_NO.
    READ TABLE IT_SO INDEX LT_ROW_NO-ROW_ID.
    IF SY-SUBRC = 0.
      IT_SO-BOX = 'X'.
      MODIFY IT_SO INDEX LT_ROW_NO-ROW_ID.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "set_lineselection


*&---------------------------------------------------------------------*
*&      Form  exclude_tb_functions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_EXCLUDE text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
ENDFORM.                               " EXCLUDE_TB_FUNCTIONS