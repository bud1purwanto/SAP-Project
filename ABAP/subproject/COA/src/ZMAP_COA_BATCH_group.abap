*&---------------------------------------------------------------------*
*& Report     :  ZMAP_COA_BATCH                                        *
*& Appl. Area :  QM / SD                                               *
*& Description:  Mapping Kolom Batch List COA per Group + Customer     *
*&               (TCode ZQM001 > Batch List)                           *
*& Tabel      :  ZMAP_COA_GRP_COL  (kolom per group)                   *
*&               ZMAP_COA_GRP_CST  (customer per group)                *
*& Default    :  DOM-G (DO ZDLF / lainnya), EXP-G (DO ZELF)            *
*& Tanpa selection screen: langsung masuk layar maintenance           *
*&---------------------------------------------------------------------*
REPORT ZMAP_COA_BATCH.

TABLES: SSCRFIELDS.

TYPE-POOLS: SLIS, ICON.

CONSTANTS: GC_DOM_G  TYPE ZMAP_COA_GRP_COL-COA_GRP VALUE 'DOM-G',
           GC_EXP_G  TYPE ZMAP_COA_GRP_COL-COA_GRP VALUE 'EXP-G',
           GC_MAXCOL TYPE I VALUE 14.

*----------------------------------------------------------------------*
* Types
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_GRP,
         SORTKEY  TYPE C LENGTH 1,
         COA_GRP  TYPE ZMAP_COA_GRP_COL-COA_GRP,
         N_COL    TYPE I,
         N_CUST   TYPE I,
         INFO     TYPE C LENGTH 40,
         ROWCOLOR TYPE C LENGTH 4,
       END OF TY_GRP.

TYPES: BEGIN OF TY_COL,
         SEQ_NO      TYPE ZMAP_COA_GRP_COL-SEQ_NO,
         FIELD_NAME  TYPE ZMAP_COA_GRP_COL-FIELD_NAME,
         FIELD_LABEL TYPE ZMAP_COA_GRP_COL-FIELD_LABEL,
         COL_SIZE    TYPE ZMAP_COA_GRP_COL-COL_SIZE,
         ACTIVE      TYPE ZMAP_COA_GRP_COL-ACTIVE,
       END OF TY_COL.

TYPES: BEGIN OF TY_CST,
         KUNNR TYPE KNA1-KUNNR,
         NAME1 TYPE KNA1-NAME1,
         STRAS TYPE KNA1-STRAS,
         ORT01 TYPE KNA1-ORT01,
         LAND1 TYPE KNA1-LAND1,
       END OF TY_CST.

TYPES: BEGIN OF TY_KNA1,
         KUNNR TYPE KNA1-KUNNR,
         NAME1 TYPE KNA1-NAME1,
         STRAS TYPE KNA1-STRAS,
         ORT01 TYPE KNA1-ORT01,
         LAND1 TYPE KNA1-LAND1,
       END OF TY_KNA1.

TYPES: BEGIN OF TY_FIELD,
         FIELD_NAME  TYPE ZMAP_COA_GRP_COL-FIELD_NAME,
         FIELD_LABEL TYPE ZMAP_COA_GRP_COL-FIELD_LABEL,
         CATEGORY    TYPE C LENGTH 20,
         COL_SIZE    TYPE ZMAP_COA_GRP_COL-COL_SIZE,
       END OF TY_FIELD.

TYPES: BEGIN OF TY_PICK_FLD,
         SEL         TYPE C LENGTH 1,
         FIELD_NAME  TYPE ZMAP_COA_GRP_COL-FIELD_NAME,
         FIELD_LABEL TYPE ZMAP_COA_GRP_COL-FIELD_LABEL,
         CATEGORY    TYPE C LENGTH 20,
         COL_SIZE    TYPE ZMAP_COA_GRP_COL-COL_SIZE,
       END OF TY_PICK_FLD.

TYPES: BEGIN OF TY_PICK_CST,
         SEL   TYPE C LENGTH 1,
         KUNNR TYPE KNA1-KUNNR,
         NAME1 TYPE KNA1-NAME1,
         STRAS TYPE KNA1-STRAS,
         ORT01 TYPE KNA1-ORT01,
         LAND1 TYPE KNA1-LAND1,
       END OF TY_PICK_CST.

TYPES: BEGIN OF TY_PICK_GRP,
         COA_GRP TYPE ZMAP_COA_GRP_COL-COA_GRP,
         INFO    TYPE C LENGTH 40,
       END OF TY_PICK_GRP.

TYPES: TY_T_COL_DB TYPE STANDARD TABLE OF ZMAP_COA_GRP_COL
                   WITH DEFAULT KEY,
       TY_T_CST_DB TYPE STANDARD TABLE OF ZMAP_COA_GRP_CST
                   WITH DEFAULT KEY.

*----------------------------------------------------------------------*
* Global Data
*----------------------------------------------------------------------*
DATA: GT_COL_DB  TYPE TY_T_COL_DB,
      GT_CST_DB  TYPE TY_T_CST_DB,
      GT_COL_ALL TYPE TY_T_COL_DB,
      GT_CST_ALL TYPE TY_T_CST_DB,
      GT_GRP     TYPE STANDARD TABLE OF TY_GRP,
      GT_COL_V   TYPE STANDARD TABLE OF TY_COL,
      GT_CST_V   TYPE STANDARD TABLE OF TY_CST,
      GT_FIELD   TYPE STANDARD TABLE OF TY_FIELD,
      GT_KNA1    TYPE HASHED TABLE OF TY_KNA1 WITH UNIQUE KEY KUNNR.

DATA: GV_GRP    TYPE ZMAP_COA_GRP_COL-COA_GRP,
      GV_DIRTY  TYPE C LENGTH 1,
      GV_RO     TYPE C LENGTH 1,
      GV_LOCKED TYPE C LENGTH 1,
      GV_LOCKBY TYPE SY-UNAME.

CLASS LCL_HANDLER DEFINITION DEFERRED.

DATA: GO_DOCK    TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      GO_SPL1    TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_SPL2    TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      GO_GRID_G  TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID_C  TYPE REF TO CL_GUI_ALV_GRID,
      GO_GRID_K  TYPE REF TO CL_GUI_ALV_GRID,
      GO_HANDLER TYPE REF TO LCL_HANDLER.

*----------------------------------------------------------------------*
* Selection Screen 9000 : layar maintenance (container ALV)
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 9000 TITLE T9000.
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN COMMENT /1(79) GV_HINT.
SELECTION-SCREEN END OF SCREEN 9000.

*----------------------------------------------------------------------*
* Event handler
*----------------------------------------------------------------------*
CLASS LCL_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      ON_TOOLBAR FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE SENDER,
      ON_UCOMM FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM SENDER,
      ON_HOTSPOT FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID,
      ON_DBLCLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW,
      ON_CHANGED_FIN FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
        IMPORTING E_MODIFIED.
ENDCLASS.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  T9000  = 'Mapping Batch List COA per Group'.
  SSCRFIELDS-FUNCTXT_01 = 'Simpan'.
  SSCRFIELDS-FUNCTXT_02 = 'Muat ulang'.
  PERFORM INIT_FIELD_DICTIONARY.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  IF SY-DYNNR = '9000'.
    PERFORM PBO_9000.
  ENDIF.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
  IF SY-DYNNR = '9000'.
    CASE SSCRFIELDS-UCOMM.
      WHEN 'FC01'.
        PERFORM SAVE_ALL.
      WHEN 'FC02'.
        PERFORM RELOAD_ALL.
    ENDCASE.
  ENDIF.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM LOCK_TABLES.
  PERFORM LOAD_DATA.
  PERFORM RUN_MAINTENANCE.
  PERFORM FREE_CONTROLS.
  PERFORM UNLOCK_TABLES.

*----------------------------------------------------------------------*
* Handler implementation
*----------------------------------------------------------------------*
CLASS LCL_HANDLER IMPLEMENTATION.
  METHOD ON_TOOLBAR.
    DATA LS_BTN TYPE STB_BUTTON.
    IF GV_RO = 'X'.
      RETURN.
    ENDIF.
    DEFINE _BTN.
      CLEAR LS_BTN.
      LS_BTN-FUNCTION  = &1.
      LS_BTN-ICON      = &2.
      LS_BTN-TEXT      = &3.
      LS_BTN-QUICKINFO = &4.
      APPEND LS_BTN TO E_OBJECT->MT_TOOLBAR.
    END-OF-DEFINITION.
    CLEAR LS_BTN.
    LS_BTN-BUTN_TYPE = 3.
    APPEND LS_BTN TO E_OBJECT->MT_TOOLBAR.
    IF SENDER = GO_GRID_G.
      _BTN 'G_ADD' ICON_CREATE      'Baru'   'Buat group baru'.
      _BTN 'G_CPY' ICON_COPY_OBJECT 'Copy'   'Copy group terpilih'.
      _BTN 'G_REN' ICON_CHANGE      'Rename' 'Ganti nama group'.
      _BTN 'G_DEL' ICON_DELETE      ''       'Hapus group'.
    ELSEIF SENDER = GO_GRID_C.
      _BTN 'C_ADD' ICON_INSERT_ROW  'Tambah kolom' 'Pilih field'.
      _BTN 'C_UP'  ICON_PREVIOUS_VALUE ''    'Geser ke atas'.
      _BTN 'C_DN'  ICON_NEXT_VALUE  ''       'Geser ke bawah'.
      _BTN 'C_DEL' ICON_DELETE_ROW  ''       'Hapus kolom'.
    ELSEIF SENDER = GO_GRID_K.
      _BTN 'K_ADD' ICON_INSERT_ROW  'Assign customer' 'Customer belum punya group'.
      _BTN 'K_MOV' ICON_TRANSFER    'Pindah group' 'Pindah ke group lain'.
      _BTN 'K_DEL' ICON_DELETE_ROW  ''       'Lepas dari group'.
    ENDIF.
  ENDMETHOD.

  METHOD ON_UCOMM.
    CASE E_UCOMM.
      WHEN 'G_ADD'. PERFORM GROUP_ADD USING SPACE.
      WHEN 'G_CPY'. PERFORM GROUP_ADD USING 'X'.
      WHEN 'G_REN'. PERFORM GROUP_RENAME.
      WHEN 'G_DEL'. PERFORM GROUP_DELETE.
      WHEN 'C_ADD'. PERFORM COL_ADD.
      WHEN 'C_UP'.  PERFORM COL_MOVE USING -1.
      WHEN 'C_DN'.  PERFORM COL_MOVE USING 1.
      WHEN 'C_DEL'. PERFORM COL_DELETE.
      WHEN 'K_ADD'. PERFORM CST_ASSIGN.
      WHEN 'K_MOV'. PERFORM CST_MOVE.
      WHEN 'K_DEL'. PERFORM CST_DELETE.
    ENDCASE.
  ENDMETHOD.

  METHOD ON_HOTSPOT.
    PERFORM GROUP_PICK USING E_ROW_ID-INDEX.
  ENDMETHOD.

  METHOD ON_DBLCLICK.
    PERFORM GROUP_PICK USING E_ROW-INDEX.
  ENDMETHOD.

  METHOD ON_CHANGED_FIN.
    IF E_MODIFIED = 'X'.
      GV_DIRTY = 'X'.
      PERFORM SYNC_COL_VIEW.
      PERFORM REFRESH_GROUPS.
      PERFORM SET_TITLES.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&      Form  INIT_FIELD_DICTIONARY
*&---------------------------------------------------------------------*
FORM INIT_FIELD_DICTIONARY.
  DATA LS_F TYPE TY_FIELD.
  REFRESH GT_FIELD.
  DEFINE _ADD_F.
    CLEAR LS_F.
    LS_F-FIELD_NAME  = &1.
    LS_F-FIELD_LABEL = &2.
    LS_F-CATEGORY    = &3.
    LS_F-COL_SIZE    = &4.
    APPEND LS_F TO GT_FIELD.
  END-OF-DEFINITION.
  _ADD_F 'DO_NUMBER'          'DO Number'               'Delivery'     'M'.
  _ADD_F 'PO_NUMBER'          'PO Number'               'Order'        'L'.
  _ADD_F 'HU_NUMBER'          'HU Number'               'Handling'     'M'.
  _ADD_F 'NO_PALET'           'No Palet'                'Packaging'    'M'.
  _ADD_F 'TYPE'               'Type'                    'Material'     'S'.
  _ADD_F 'ROLL_NUMBER'        'Roll Number'             'Identifier'   'L'.
  _ADD_F 'BATCH_NUMBER'       'Batch Number'            'Identifier'   'M'.
  _ADD_F 'WIDTH'              'Width'                   'Dimension'    'M'.
  _ADD_F 'LENGTH'             'Length'                  'Dimension'    'M'.
  _ADD_F 'WEIGHT_PER_ROL'     'Weight Per Roll'         'Dimension'    'M'.
  _ADD_F 'JOINT'              'Joint'                   'Spec'         'S'.
  _ADD_F 'TOTAL_ROLL'         'Total Roll'              'Quantity'     'M'.
  _ADD_F 'TOTAL_WEIGHT_PALET' 'Total Weight Per Pallet' 'Quantity'     'M'.
  _ADD_F 'GG_PART_NUMBER'     'GG Part Number (OPR)'    'Customer Mat' 'L'.
  _ADD_F 'EXPIRED_DATE'       'Expired Date'            'Date'         'M'.
  _ADD_F 'PRODUCTION_DATE'    'Production Date'         'Date'         'M'.
  _ADD_F 'LENGTH_OF_SPLICE'   'Length Of Splice'        'Spec'         'M'.
  _ADD_F 'NUMBER_OF_JOINT'    'Number of Joint (Splice)' 'Spec'        'S'.
  _ADD_F 'CORE'               'Core'                    'Dimension'    'M'.
ENDFORM.                    "INIT_FIELD_DICTIONARY

*&---------------------------------------------------------------------*
*&      Form  LOCK_TABLES
*&---------------------------------------------------------------------*
FORM LOCK_TABLES.
  CLEAR: GV_RO, GV_LOCKED, GV_LOCKBY.
  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      MODE_RSTABLE   = 'E'
      TABNAME        = 'ZMAP_COA_GRP_COL'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    GV_RO = 'X'.
    GV_LOCKBY = SY-MSGV1.
    RETURN.
  ENDIF.
  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      MODE_RSTABLE   = 'E'
      TABNAME        = 'ZMAP_COA_GRP_CST'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    GV_RO = 'X'.
    GV_LOCKBY = SY-MSGV1.
    CALL FUNCTION 'DEQUEUE_E_TABLE'
      EXPORTING
        MODE_RSTABLE = 'E'
        TABNAME      = 'ZMAP_COA_GRP_COL'.
    RETURN.
  ENDIF.
  GV_LOCKED = 'X'.
ENDFORM.                    "LOCK_TABLES

*&---------------------------------------------------------------------*
*&      Form  UNLOCK_TABLES
*&---------------------------------------------------------------------*
FORM UNLOCK_TABLES.
  IF GV_LOCKED <> 'X'.
    RETURN.
  ENDIF.
  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      MODE_RSTABLE = 'E'
      TABNAME      = 'ZMAP_COA_GRP_COL'.
  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      MODE_RSTABLE = 'E'
      TABNAME      = 'ZMAP_COA_GRP_CST'.
  CLEAR GV_LOCKED.
ENDFORM.                    "UNLOCK_TABLES

*&---------------------------------------------------------------------*
*&      Form  LOAD_DATA
*&---------------------------------------------------------------------*
FORM LOAD_DATA.
  DATA: LS_COL TYPE ZMAP_COA_GRP_COL,
        LS_CST TYPE ZMAP_COA_GRP_CST.

  SELECT * FROM ZMAP_COA_GRP_COL INTO TABLE GT_COL_DB.
  SELECT * FROM ZMAP_COA_GRP_CST INTO TABLE GT_CST_DB.
  GT_COL_ALL = GT_COL_DB.
  GT_CST_ALL = GT_CST_DB.
  SORT GT_COL_ALL BY COA_GRP SEQ_NO FIELD_NAME.

  REFRESH GT_GRP.
  PERFORM ENSURE_GROUP USING GC_DOM_G.
  PERFORM ENSURE_GROUP USING GC_EXP_G.
  LOOP AT GT_COL_ALL INTO LS_COL.
    PERFORM ENSURE_GROUP USING LS_COL-COA_GRP.
  ENDLOOP.
  LOOP AT GT_CST_ALL INTO LS_CST.
    PERFORM ENSURE_GROUP USING LS_CST-COA_GRP.
  ENDLOOP.

  PERFORM READ_KNA1_FOR_ASSIGNED.
  CLEAR GV_DIRTY.
ENDFORM.                    "LOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  ENSURE_GROUP
*&---------------------------------------------------------------------*
FORM ENSURE_GROUP USING PV_GRP TYPE ZMAP_COA_GRP_COL-COA_GRP.
  DATA LS_GRP TYPE TY_GRP.
  READ TABLE GT_GRP TRANSPORTING NO FIELDS
    WITH KEY COA_GRP = PV_GRP.
  IF SY-SUBRC = 0 OR PV_GRP IS INITIAL.
    RETURN.
  ENDIF.
  LS_GRP-COA_GRP = PV_GRP.
  CASE PV_GRP.
    WHEN GC_DOM_G.
      LS_GRP-SORTKEY = '0'.
      LS_GRP-INFO    = 'Default domestik (DO ZDLF)'.
    WHEN GC_EXP_G.
      LS_GRP-SORTKEY = '1'.
      LS_GRP-INFO    = 'Default export (DO ZELF)'.
    WHEN OTHERS.
      LS_GRP-SORTKEY = '2'.
  ENDCASE.
  APPEND LS_GRP TO GT_GRP.
  SORT GT_GRP BY SORTKEY COA_GRP.
ENDFORM.                    "ENSURE_GROUP

*&---------------------------------------------------------------------*
*&      Form  READ_KNA1_FOR_ASSIGNED
*&---------------------------------------------------------------------*
FORM READ_KNA1_FOR_ASSIGNED.
  DATA: LT_KEY  TYPE STANDARD TABLE OF ZMAP_COA_GRP_CST,
        LT_KNA1 TYPE STANDARD TABLE OF TY_KNA1.
  LT_KEY = GT_CST_ALL.
  SORT LT_KEY BY KUNNR.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING KUNNR.
  IF LT_KEY IS INITIAL.
    RETURN.
  ENDIF.
  SELECT KUNNR NAME1 STRAS ORT01 LAND1 FROM KNA1
    INTO TABLE LT_KNA1
    FOR ALL ENTRIES IN LT_KEY
    WHERE KUNNR = LT_KEY-KUNNR.
  PERFORM CACHE_KNA1 USING LT_KNA1.
ENDFORM.                    "READ_KNA1_FOR_ASSIGNED

*&---------------------------------------------------------------------*
*&      Form  CACHE_KNA1
*&---------------------------------------------------------------------*
FORM CACHE_KNA1 USING PT_KNA1 TYPE STANDARD TABLE.
  DATA LS_K TYPE TY_KNA1.
  LOOP AT PT_KNA1 INTO LS_K.
    INSERT LS_K INTO TABLE GT_KNA1.
  ENDLOOP.
ENDFORM.                    "CACHE_KNA1

*&---------------------------------------------------------------------*
*&      Form  RUN_MAINTENANCE
*&---------------------------------------------------------------------*
FORM RUN_MAINTENANCE.
  DATA LV_ANS TYPE C LENGTH 1.
  DATA LS_GRP TYPE TY_GRP.

  IF GV_GRP IS INITIAL.
    READ TABLE GT_GRP INTO LS_GRP INDEX 1.
    GV_GRP = LS_GRP-COA_GRP.
  ENDIF.
  PERFORM BUILD_VIEWS.

  DO.
    CALL SELECTION-SCREEN 9000.
    IF GO_GRID_C IS BOUND.
      GO_GRID_C->CHECK_CHANGED_DATA( ).
      PERFORM SYNC_COL_VIEW.
    ENDIF.
    IF GV_DIRTY <> 'X' OR GV_RO = 'X'.
      EXIT.
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Perubahan belum disimpan'
        TEXT_QUESTION         = 'Simpan perubahan sebelum keluar?'
        TEXT_BUTTON_1         = 'Simpan'
        ICON_BUTTON_1         = 'ICON_SYSTEM_SAVE'
        TEXT_BUTTON_2         = 'Buang'
        ICON_BUTTON_2         = 'ICON_DELETE'
        DEFAULT_BUTTON        = '1'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = LV_ANS
      EXCEPTIONS
        OTHERS                = 1.
    CASE LV_ANS.
      WHEN '1'.
        PERFORM SAVE_ALL.
        IF GV_DIRTY <> 'X'.
          EXIT.
        ENDIF.
      WHEN '2'.
        EXIT.
      WHEN OTHERS.
        " kembali ke layar maintenance
    ENDCASE.
  ENDDO.
ENDFORM.                    "RUN_MAINTENANCE

*&---------------------------------------------------------------------*
*&      Form  PBO_9000
*&---------------------------------------------------------------------*
FORM PBO_9000.
  DATA LT_EXCL TYPE STANDARD TABLE OF SY-UCOMM.

  APPEND 'ONLI' TO LT_EXCL.
  APPEND 'PRIN' TO LT_EXCL.
  APPEND 'SPOS' TO LT_EXCL.
  APPEND 'GET'  TO LT_EXCL.
  APPEND 'VDEL' TO LT_EXCL.
  APPEND 'VSHO' TO LT_EXCL.
  APPEND 'LVUV' TO LT_EXCL.
  IF GV_RO = 'X'.
    APPEND 'FC01' TO LT_EXCL.
  ENDIF.
  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      P_STATUS  = '%_00'
      P_PROGRAM = 'RSSYSTDB'
    TABLES
      P_EXCLUDE = LT_EXCL.

  IF GV_RO = 'X'.
    CONCATENATE 'Mode tampilan: data sedang diedit oleh' GV_LOCKBY
      INTO GV_HINT SEPARATED BY SPACE.
  ELSE.
    GV_HINT = 'Klik nama group untuk lihat kolom & customer. Simpan di toolbar.'.
  ENDIF.

  IF GO_DOCK IS INITIAL.
    PERFORM CREATE_CONTROLS.
  ENDIF.
ENDFORM.                    "PBO_9000

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTROLS
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS.
  DATA: LO_C_LEFT  TYPE REF TO CL_GUI_CONTAINER,
        LO_C_RIGHT TYPE REF TO CL_GUI_CONTAINER,
        LO_C_TOP   TYPE REF TO CL_GUI_CONTAINER,
        LO_C_BOT   TYPE REF TO CL_GUI_CONTAINER,
        LT_FCAT    TYPE LVC_T_FCAT,
        LS_LAYO    TYPE LVC_S_LAYO,
        LT_EXCL    TYPE UI_FUNCTIONS,
        LT_DROP    TYPE LVC_T_DROP,
        LS_DROP    TYPE LVC_S_DROP.

  CREATE OBJECT GO_DOCK
    EXPORTING
      REPID = SY-REPID
      DYNNR = '9000'
      SIDE  = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM
      RATIO = 92
    EXCEPTIONS
      OTHERS = 1.
  IF SY-SUBRC <> 0.
    MESSAGE 'Container tidak bisa dibuat' TYPE 'E'.
  ENDIF.

  CREATE OBJECT GO_SPL1
    EXPORTING
      PARENT  = GO_DOCK
      ROWS    = 1
      COLUMNS = 2.
  GO_SPL1->SET_COLUMN_WIDTH( ID = 1 WIDTH = 30 ).
  LO_C_LEFT  = GO_SPL1->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_C_RIGHT = GO_SPL1->GET_CONTAINER( ROW = 1 COLUMN = 2 ).

  CREATE OBJECT GO_SPL2
    EXPORTING
      PARENT  = LO_C_RIGHT
      ROWS    = 2
      COLUMNS = 1.
  GO_SPL2->SET_ROW_HEIGHT( ID = 1 HEIGHT = 50 ).
  LO_C_TOP = GO_SPL2->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  LO_C_BOT = GO_SPL2->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  CREATE OBJECT GO_HANDLER.
  PERFORM TOOLBAR_EXCLUDES CHANGING LT_EXCL.

*-- Grid Group
  CREATE OBJECT GO_GRID_G EXPORTING I_PARENT = LO_C_LEFT.
  PERFORM FCAT_GROUP CHANGING LT_FCAT.
  CLEAR LS_LAYO.
  LS_LAYO-GRID_TITLE = 'Group'.
  LS_LAYO-INFO_FNAME = 'ROWCOLOR'.
  LS_LAYO-SEL_MODE   = 'B'.
  LS_LAYO-NO_ROWMARK = 'X'.
  SET HANDLER GO_HANDLER->ON_TOOLBAR  FOR GO_GRID_G.
  SET HANDLER GO_HANDLER->ON_UCOMM    FOR GO_GRID_G.
  SET HANDLER GO_HANDLER->ON_HOTSPOT  FOR GO_GRID_G.
  SET HANDLER GO_HANDLER->ON_DBLCLICK FOR GO_GRID_G.
  GO_GRID_G->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING IS_LAYOUT            = LS_LAYO
              IT_TOOLBAR_EXCLUDING = LT_EXCL
    CHANGING  IT_OUTTAB            = GT_GRP
              IT_FIELDCATALOG      = LT_FCAT ).
  GO_GRID_G->SET_TOOLBAR_INTERACTIVE( ).

*-- Grid Kolom
  CREATE OBJECT GO_GRID_C EXPORTING I_PARENT = LO_C_TOP.
  PERFORM FCAT_COLUMN CHANGING LT_FCAT.
  CLEAR LS_LAYO.
  LS_LAYO-SEL_MODE = 'A'.
  CLEAR LS_DROP.
  LS_DROP-HANDLE = 1.
  LS_DROP-VALUE = 'S'. APPEND LS_DROP TO LT_DROP.
  LS_DROP-VALUE = 'M'. APPEND LS_DROP TO LT_DROP.
  LS_DROP-VALUE = 'L'. APPEND LS_DROP TO LT_DROP.
  GO_GRID_C->SET_DROP_DOWN_TABLE( IT_DROP_DOWN = LT_DROP ).
  SET HANDLER GO_HANDLER->ON_TOOLBAR     FOR GO_GRID_C.
  SET HANDLER GO_HANDLER->ON_UCOMM       FOR GO_GRID_C.
  SET HANDLER GO_HANDLER->ON_CHANGED_FIN FOR GO_GRID_C.
  GO_GRID_C->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING IS_LAYOUT            = LS_LAYO
              IT_TOOLBAR_EXCLUDING = LT_EXCL
    CHANGING  IT_OUTTAB            = GT_COL_V
              IT_FIELDCATALOG      = LT_FCAT ).
  GO_GRID_C->REGISTER_EDIT_EVENT(
    I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
  GO_GRID_C->REGISTER_EDIT_EVENT(
    I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER ).
  IF GV_RO = 'X'.
    GO_GRID_C->SET_READY_FOR_INPUT( I_READY_FOR_INPUT = 0 ).
  ELSE.
    GO_GRID_C->SET_READY_FOR_INPUT( I_READY_FOR_INPUT = 1 ).
  ENDIF.
  GO_GRID_C->SET_TOOLBAR_INTERACTIVE( ).

*-- Grid Customer
  CREATE OBJECT GO_GRID_K EXPORTING I_PARENT = LO_C_BOT.
  PERFORM FCAT_CUSTOMER CHANGING LT_FCAT.
  CLEAR LS_LAYO.
  LS_LAYO-SEL_MODE = 'A'.
  SET HANDLER GO_HANDLER->ON_TOOLBAR FOR GO_GRID_K.
  SET HANDLER GO_HANDLER->ON_UCOMM   FOR GO_GRID_K.
  GO_GRID_K->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING IS_LAYOUT            = LS_LAYO
              IT_TOOLBAR_EXCLUDING = LT_EXCL
    CHANGING  IT_OUTTAB            = GT_CST_V
              IT_FIELDCATALOG      = LT_FCAT ).
  GO_GRID_K->SET_TOOLBAR_INTERACTIVE( ).

  PERFORM SET_TITLES.
ENDFORM.                    "CREATE_CONTROLS

*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_EXCLUDES
*&---------------------------------------------------------------------*
FORM TOOLBAR_EXCLUDES CHANGING PT_EXCL TYPE UI_FUNCTIONS.
  REFRESH PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW     TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW   TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW   TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW   TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW     TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY         TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_CUT          TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE        TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO         TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_GRAPH            TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_INFO             TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT            TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_VIEWS            TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_DETAIL           TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_CHECK            TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_REFRESH          TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_SUM              TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_SUBTOT           TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_MB_SUM              TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_MB_SUBTOT           TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_MB_VIEW             TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_MB_VARIANT          TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_SORT             TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_SORT_ASC         TO PT_EXCL.
  APPEND CL_GUI_ALV_GRID=>MC_FC_SORT_DSC         TO PT_EXCL.
ENDFORM.                    "TOOLBAR_EXCLUDES

*&---------------------------------------------------------------------*
*&      Form  FCAT_GROUP
*&---------------------------------------------------------------------*
FORM FCAT_GROUP CHANGING PT_FCAT TYPE LVC_T_FCAT.
  DATA LS_FC TYPE LVC_S_FCAT.
  REFRESH PT_FCAT.
  DEFINE _FC.
    CLEAR LS_FC.
    LS_FC-FIELDNAME = &1.
    LS_FC-SCRTEXT_M = &2.
    LS_FC-COLTEXT   = &2.
    LS_FC-OUTPUTLEN = &3.
    APPEND LS_FC TO PT_FCAT.
  END-OF-DEFINITION.
  _FC 'COA_GRP' 'Group'      12.
  _FC 'N_COL'   'Kolom'       5.
  _FC 'N_CUST'  'Customer'    7.
  _FC 'INFO'    'Keterangan' 24.
  READ TABLE PT_FCAT INTO LS_FC WITH KEY FIELDNAME = 'COA_GRP'.
  LS_FC-HOTSPOT  = 'X'.
  LS_FC-EMPHASIZE = 'C300'.
  MODIFY PT_FCAT FROM LS_FC INDEX SY-TABIX.
ENDFORM.                    "FCAT_GROUP

*&---------------------------------------------------------------------*
*&      Form  FCAT_COLUMN
*&---------------------------------------------------------------------*
FORM FCAT_COLUMN CHANGING PT_FCAT TYPE LVC_T_FCAT.
  DATA LS_FC TYPE LVC_S_FCAT.
  REFRESH PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'SEQ_NO'.
  LS_FC-COLTEXT   = 'Urutan'.
  LS_FC-OUTPUTLEN = 6.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'FIELD_NAME'.
  LS_FC-COLTEXT   = 'Field'.
  LS_FC-OUTPUTLEN = 20.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'FIELD_LABEL'.
  LS_FC-COLTEXT   = 'Label di Batch List'.
  LS_FC-OUTPUTLEN = 30.
  LS_FC-EDIT      = 'X'.
  LS_FC-LOWERCASE = 'X'.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME  = 'COL_SIZE'.
  LS_FC-COLTEXT    = 'Size'.
  LS_FC-OUTPUTLEN  = 5.
  LS_FC-EDIT       = 'X'.
  LS_FC-DRDN_HNDL  = 1.
  LS_FC-DRDN_ALIAS = SPACE.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'ACTIVE'.
  LS_FC-COLTEXT   = 'Aktif'.
  LS_FC-OUTPUTLEN = 5.
  LS_FC-CHECKBOX  = 'X'.
  LS_FC-EDIT      = 'X'.
  APPEND LS_FC TO PT_FCAT.
ENDFORM.                    "FCAT_COLUMN

*&---------------------------------------------------------------------*
*&      Form  FCAT_CUSTOMER
*&---------------------------------------------------------------------*
FORM FCAT_CUSTOMER CHANGING PT_FCAT TYPE LVC_T_FCAT.
  DATA LS_FC TYPE LVC_S_FCAT.
  REFRESH PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'KUNNR'.
  LS_FC-REF_TABLE = 'KNA1'.
  LS_FC-REF_FIELD = 'KUNNR'.
  LS_FC-COLTEXT   = 'Customer'.
  LS_FC-OUTPUTLEN = 11.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'NAME1'.
  LS_FC-COLTEXT   = 'Nama'.
  LS_FC-OUTPUTLEN = 35.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'STRAS'.
  LS_FC-COLTEXT   = 'Alamat'.
  LS_FC-OUTPUTLEN = 35.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'ORT01'.
  LS_FC-COLTEXT   = 'Kota'.
  LS_FC-OUTPUTLEN = 20.
  APPEND LS_FC TO PT_FCAT.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'LAND1'.
  LS_FC-COLTEXT   = 'Negara'.
  LS_FC-OUTPUTLEN = 6.
  APPEND LS_FC TO PT_FCAT.
ENDFORM.                    "FCAT_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  BUILD_VIEWS  (isi grid kolom & customer dari group aktif)
*&---------------------------------------------------------------------*
FORM BUILD_VIEWS.
  DATA: LS_COL  TYPE ZMAP_COA_GRP_COL,
        LS_CST  TYPE ZMAP_COA_GRP_CST,
        LS_V    TYPE TY_COL,
        LS_K    TYPE TY_CST,
        LS_KNA1 TYPE TY_KNA1.

  REFRESH: GT_COL_V, GT_CST_V.
  LOOP AT GT_COL_ALL INTO LS_COL WHERE COA_GRP = GV_GRP.
    MOVE-CORRESPONDING LS_COL TO LS_V.
    APPEND LS_V TO GT_COL_V.
  ENDLOOP.
  SORT GT_COL_V BY SEQ_NO.

  LOOP AT GT_CST_ALL INTO LS_CST WHERE COA_GRP = GV_GRP.
    CLEAR LS_K.
    LS_K-KUNNR = LS_CST-KUNNR.
    READ TABLE GT_KNA1 INTO LS_KNA1 WITH TABLE KEY KUNNR = LS_CST-KUNNR.
    IF SY-SUBRC = 0.
      LS_K-NAME1 = LS_KNA1-NAME1.
      LS_K-STRAS = LS_KNA1-STRAS.
      LS_K-ORT01 = LS_KNA1-ORT01.
      LS_K-LAND1 = LS_KNA1-LAND1.
    ENDIF.
    APPEND LS_K TO GT_CST_V.
  ENDLOOP.
  SORT GT_CST_V BY NAME1 KUNNR.

  PERFORM REFRESH_GROUPS.
ENDFORM.                    "BUILD_VIEWS

*&---------------------------------------------------------------------*
*&      Form  REFRESH_GROUPS  (hitung jumlah & warna group aktif)
*&---------------------------------------------------------------------*
FORM REFRESH_GROUPS.
  DATA: LS_COL TYPE ZMAP_COA_GRP_COL,
        LS_CST TYPE ZMAP_COA_GRP_CST.
  FIELD-SYMBOLS <G> TYPE TY_GRP.

  LOOP AT GT_GRP ASSIGNING <G>.
    CLEAR: <G>-N_COL, <G>-N_CUST, <G>-ROWCOLOR.
    LOOP AT GT_COL_ALL INTO LS_COL
      WHERE COA_GRP = <G>-COA_GRP AND ACTIVE = 'X'.
      <G>-N_COL = <G>-N_COL + 1.
    ENDLOOP.
    LOOP AT GT_CST_ALL INTO LS_CST WHERE COA_GRP = <G>-COA_GRP.
      <G>-N_CUST = <G>-N_CUST + 1.
    ENDLOOP.
    IF <G>-COA_GRP = GV_GRP.
      <G>-ROWCOLOR = 'C510'.
    ENDIF.
  ENDLOOP.
  PERFORM REFRESH_GRID USING GO_GRID_G.
ENDFORM.                    "REFRESH_GROUPS

*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID
*&---------------------------------------------------------------------*
FORM REFRESH_GRID USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA LS_STBL TYPE LVC_S_STBL.
  IF PO_GRID IS BOUND.
    LS_STBL-ROW = 'X'.
    LS_STBL-COL = 'X'.
    PO_GRID->REFRESH_TABLE_DISPLAY( IS_STABLE = LS_STBL ).
  ENDIF.
ENDFORM.                    "REFRESH_GRID

*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALL
*&---------------------------------------------------------------------*
FORM REFRESH_ALL.
  PERFORM BUILD_VIEWS.
  PERFORM REFRESH_GRID USING GO_GRID_C.
  PERFORM REFRESH_GRID USING GO_GRID_K.
  PERFORM SET_TITLES.
ENDFORM.                    "REFRESH_ALL

*&---------------------------------------------------------------------*
*&      Form  SET_TITLES
*&---------------------------------------------------------------------*
FORM SET_TITLES.
  DATA: LV_T   TYPE LVC_TITLE,
        LV_N   TYPE I,
        LV_NC  TYPE C LENGTH 6,
        LV_MAX TYPE C LENGTH 6,
        LS_V   TYPE TY_COL.

  CLEAR LV_N.
  LOOP AT GT_COL_V INTO LS_V WHERE ACTIVE = 'X'.
    LV_N = LV_N + 1.
  ENDLOOP.
  WRITE LV_N TO LV_NC LEFT-JUSTIFIED.
  WRITE GC_MAXCOL TO LV_MAX LEFT-JUSTIFIED.
  CONCATENATE 'Kolom' GV_GRP '-' LV_NC 'aktif (maks' LV_MAX ')'
    INTO LV_T SEPARATED BY SPACE.
  IF GO_GRID_C IS BOUND.
    GO_GRID_C->SET_GRIDTITLE( LV_T ).
  ENDIF.

  DESCRIBE TABLE GT_CST_V LINES LV_N.
  WRITE LV_N TO LV_NC LEFT-JUSTIFIED.
  CONCATENATE 'Customer di' GV_GRP '-' LV_NC 'customer'
    INTO LV_T SEPARATED BY SPACE.
  IF GO_GRID_K IS BOUND.
    GO_GRID_K->SET_GRIDTITLE( LV_T ).
  ENDIF.
ENDFORM.                    "SET_TITLES

*&---------------------------------------------------------------------*
*&      Form  SYNC_COL_VIEW  (grid kolom -> GT_COL_ALL)
*&---------------------------------------------------------------------*
FORM SYNC_COL_VIEW.
  DATA: LS_V   TYPE TY_COL,
        LS_COL TYPE ZMAP_COA_GRP_COL,
        LV_IDX TYPE I.
  FIELD-SYMBOLS <V> TYPE TY_COL.

  IF GV_GRP IS INITIAL.
    RETURN.
  ENDIF.
  LOOP AT GT_COL_V ASSIGNING <V>.
    LV_IDX = SY-TABIX.
    <V>-SEQ_NO = LV_IDX.
    TRANSLATE <V>-COL_SIZE TO UPPER CASE.
    IF <V>-COL_SIZE <> 'S' AND <V>-COL_SIZE <> 'M'
       AND <V>-COL_SIZE <> 'L'.
      <V>-COL_SIZE = 'M'.
    ENDIF.
  ENDLOOP.
  DELETE GT_COL_ALL WHERE COA_GRP = GV_GRP.
  LOOP AT GT_COL_V INTO LS_V.
    CLEAR LS_COL.
    MOVE-CORRESPONDING LS_V TO LS_COL.
    LS_COL-COA_GRP = GV_GRP.
    APPEND LS_COL TO GT_COL_ALL.
  ENDLOOP.
ENDFORM.                    "SYNC_COL_VIEW

*&---------------------------------------------------------------------*
*&      Form  COMMIT_GRID_INPUT
*&---------------------------------------------------------------------*
FORM COMMIT_GRID_INPUT.
  IF GO_GRID_C IS BOUND.
    GO_GRID_C->CHECK_CHANGED_DATA( ).
  ENDIF.
  PERFORM SYNC_COL_VIEW.
ENDFORM.                    "COMMIT_GRID_INPUT

*&---------------------------------------------------------------------*
*&      Form  GROUP_PICK
*&---------------------------------------------------------------------*
FORM GROUP_PICK USING PV_INDEX TYPE ANY.
  DATA LS_GRP TYPE TY_GRP.
  READ TABLE GT_GRP INTO LS_GRP INDEX PV_INDEX.
  IF SY-SUBRC <> 0 OR LS_GRP-COA_GRP = GV_GRP.
    RETURN.
  ENDIF.
  PERFORM COMMIT_GRID_INPUT.
  GV_GRP = LS_GRP-COA_GRP.
  PERFORM REFRESH_ALL.
ENDFORM.                    "GROUP_PICK

*&---------------------------------------------------------------------*
*&      Form  ASK_GROUP_NAME
*&---------------------------------------------------------------------*
FORM ASK_GROUP_NAME USING    PV_TITLE TYPE ANY
                             PV_DEFAULT TYPE ANY
                    CHANGING PV_NEW TYPE ZMAP_COA_GRP_COL-COA_GRP.
  DATA: LT_FLD TYPE STANDARD TABLE OF SVAL,
        LS_FLD TYPE SVAL,
        LV_RC  TYPE C LENGTH 1.

  CLEAR PV_NEW.
  LS_FLD-TABNAME   = 'ZMAP_COA_GRP_COL'.
  LS_FLD-FIELDNAME = 'COA_GRP'.
  LS_FLD-FIELDTEXT = 'Nama group'.
  LS_FLD-FIELD_OBL = 'X'.
  LS_FLD-VALUE     = PV_DEFAULT.
  APPEND LS_FLD TO LT_FLD.
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = PV_TITLE
    IMPORTING
      RETURNCODE      = LV_RC
    TABLES
      FIELDS          = LT_FLD
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0 OR LV_RC = 'A'.
    RETURN.
  ENDIF.
  READ TABLE LT_FLD INTO LS_FLD INDEX 1.
  PV_NEW = LS_FLD-VALUE.
  TRANSLATE PV_NEW TO UPPER CASE.
  CONDENSE PV_NEW NO-GAPS.
  IF PV_NEW IS INITIAL.
    RETURN.
  ENDIF.
  READ TABLE GT_GRP TRANSPORTING NO FIELDS WITH KEY COA_GRP = PV_NEW.
  IF SY-SUBRC = 0.
    MESSAGE 'Nama group sudah ada' TYPE 'S' DISPLAY LIKE 'E'.
    CLEAR PV_NEW.
  ENDIF.
ENDFORM.                    "ASK_GROUP_NAME

*&---------------------------------------------------------------------*
*&      Form  GROUP_ADD  (PV_COPY = 'X' : copy kolom dari group aktif)
*&---------------------------------------------------------------------*
FORM GROUP_ADD USING PV_COPY TYPE C.
  DATA: LV_NEW   TYPE ZMAP_COA_GRP_COL-COA_GRP,
        LV_TITLE TYPE C LENGTH 60,
        LS_COL   TYPE ZMAP_COA_GRP_COL,
        LT_COPY  TYPE TY_T_COL_DB.

  PERFORM COMMIT_GRID_INPUT.
  IF PV_COPY = 'X'.
    CONCATENATE 'Copy kolom dari' GV_GRP 'ke group baru'
      INTO LV_TITLE SEPARATED BY SPACE.
  ELSE.
    LV_TITLE = 'Buat group baru'.
  ENDIF.
  PERFORM ASK_GROUP_NAME USING LV_TITLE SPACE CHANGING LV_NEW.
  IF LV_NEW IS INITIAL.
    RETURN.
  ENDIF.

  IF PV_COPY = 'X'.
    LOOP AT GT_COL_ALL INTO LS_COL WHERE COA_GRP = GV_GRP.
      LS_COL-COA_GRP = LV_NEW.
      APPEND LS_COL TO LT_COPY.
    ENDLOOP.
    APPEND LINES OF LT_COPY TO GT_COL_ALL.
  ENDIF.
  PERFORM ENSURE_GROUP USING LV_NEW.
  GV_GRP = LV_NEW.
  GV_DIRTY = 'X'.
  PERFORM REFRESH_ALL.
  IF PV_COPY = 'X'.
    MESSAGE 'Group dibuat dari copy. Assign customer lalu Simpan' TYPE 'S'.
  ELSE.
    MESSAGE 'Group dibuat. Tambah kolom & assign customer lalu Simpan'
      TYPE 'S'.
  ENDIF.
ENDFORM.                    "GROUP_ADD

*&---------------------------------------------------------------------*
*&      Form  GROUP_RENAME
*&---------------------------------------------------------------------*
FORM GROUP_RENAME.
  DATA LV_NEW TYPE ZMAP_COA_GRP_COL-COA_GRP.
  FIELD-SYMBOLS: <C> TYPE ZMAP_COA_GRP_COL,
                 <K> TYPE ZMAP_COA_GRP_CST,
                 <G> TYPE TY_GRP.

  IF GV_GRP = GC_DOM_G OR GV_GRP = GC_EXP_G.
    MESSAGE 'Group default tidak bisa di-rename' TYPE 'S'
      DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  PERFORM COMMIT_GRID_INPUT.
  PERFORM ASK_GROUP_NAME USING 'Ganti nama group' GV_GRP
                         CHANGING LV_NEW.
  IF LV_NEW IS INITIAL.
    RETURN.
  ENDIF.
  LOOP AT GT_COL_ALL ASSIGNING <C> WHERE COA_GRP = GV_GRP.
    <C>-COA_GRP = LV_NEW.
  ENDLOOP.
  LOOP AT GT_CST_ALL ASSIGNING <K> WHERE COA_GRP = GV_GRP.
    <K>-COA_GRP = LV_NEW.
  ENDLOOP.
  LOOP AT GT_GRP ASSIGNING <G> WHERE COA_GRP = GV_GRP.
    <G>-COA_GRP = LV_NEW.
  ENDLOOP.
  SORT GT_GRP BY SORTKEY COA_GRP.
  GV_GRP = LV_NEW.
  GV_DIRTY = 'X'.
  PERFORM REFRESH_ALL.
ENDFORM.                    "GROUP_RENAME

*&---------------------------------------------------------------------*
*&      Form  GROUP_DELETE
*&---------------------------------------------------------------------*
FORM GROUP_DELETE.
  DATA: LV_ANS  TYPE C LENGTH 1,
        LV_TXT  TYPE C LENGTH 200,
        LV_N    TYPE C LENGTH 6,
        LS_GRP  TYPE TY_GRP.

  IF GV_GRP = GC_DOM_G OR GV_GRP = GC_EXP_G.
    MESSAGE 'Group default tidak bisa dihapus' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  PERFORM COMMIT_GRID_INPUT.
  READ TABLE GT_GRP INTO LS_GRP WITH KEY COA_GRP = GV_GRP.
  WRITE LS_GRP-N_CUST TO LV_N LEFT-JUSTIFIED.
  CONCATENATE 'Hapus group' GV_GRP '?' LV_N
    'customer di group ini akan kembali ke group default.'
    INTO LV_TXT SEPARATED BY SPACE.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Hapus group'
      TEXT_QUESTION         = LV_TXT
      TEXT_BUTTON_1         = 'Hapus'
      TEXT_BUTTON_2         = 'Batal'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = LV_ANS
    EXCEPTIONS
      OTHERS                = 1.
  IF LV_ANS <> '1'.
    RETURN.
  ENDIF.
  DELETE GT_COL_ALL WHERE COA_GRP = GV_GRP.
  DELETE GT_CST_ALL WHERE COA_GRP = GV_GRP.
  DELETE GT_GRP WHERE COA_GRP = GV_GRP.
  READ TABLE GT_GRP INTO LS_GRP INDEX 1.
  GV_GRP = LS_GRP-COA_GRP.
  GV_DIRTY = 'X'.
  PERFORM REFRESH_ALL.
ENDFORM.                    "GROUP_DELETE

*&---------------------------------------------------------------------*
*&      Form  COUNT_ACTIVE_VIEW
*&---------------------------------------------------------------------*
FORM COUNT_ACTIVE_VIEW CHANGING PV_N TYPE I.
  DATA LS_V TYPE TY_COL.
  CLEAR PV_N.
  LOOP AT GT_COL_V INTO LS_V WHERE ACTIVE = 'X'.
    PV_N = PV_N + 1.
  ENDLOOP.
ENDFORM.                    "COUNT_ACTIVE_VIEW

*&---------------------------------------------------------------------*
*&      Form  COL_ADD
*&---------------------------------------------------------------------*
FORM COL_ADD.
  DATA: LT_PICK  TYPE STANDARD TABLE OF TY_PICK_FLD,
        LS_PICK  TYPE TY_PICK_FLD,
        LS_F     TYPE TY_FIELD,
        LS_V     TYPE TY_COL,
        LT_FC    TYPE LVC_T_FCAT,
        LS_FC    TYPE LVC_S_FCAT,
        LV_OK    TYPE C LENGTH 1,
        LV_TITLE TYPE LVC_TITLE,
        LV_N     TYPE I,
        LV_SKIP  TYPE I.

  PERFORM COMMIT_GRID_INPUT.
  LOOP AT GT_FIELD INTO LS_F.
    READ TABLE GT_COL_V TRANSPORTING NO FIELDS
      WITH KEY FIELD_NAME = LS_F-FIELD_NAME.
    IF SY-SUBRC = 0.
      CONTINUE.
    ENDIF.
    CLEAR LS_PICK.
    MOVE-CORRESPONDING LS_F TO LS_PICK.
    APPEND LS_PICK TO LT_PICK.
  ENDLOOP.
  IF LT_PICK IS INITIAL.
    MESSAGE 'Semua field sudah ada di group ini' TYPE 'S'.
    RETURN.
  ENDIF.

  DEFINE _PFC.
    CLEAR LS_FC.
    LS_FC-FIELDNAME = &1.
    LS_FC-COLTEXT   = &2.
    LS_FC-OUTPUTLEN = &3.
    APPEND LS_FC TO LT_FC.
  END-OF-DEFINITION.
  _PFC 'SEL'         'Pilih'         5.
  _PFC 'FIELD_NAME'  'Field'        20.
  _PFC 'FIELD_LABEL' 'Label'        25.
  _PFC 'CATEGORY'    'Kategori'     14.
  _PFC 'COL_SIZE'    'Size'          4.

  LV_TITLE = 'Pilih kolom yang ditambahkan (centang Pilih)'.
  PERFORM POPUP_GRID_PICK USING LV_TITLE LT_FC
                          CHANGING LT_PICK LV_OK.
  IF LV_OK IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM COUNT_ACTIVE_VIEW CHANGING LV_N.
  LOOP AT LT_PICK INTO LS_PICK WHERE SEL = 'X'.
    IF LV_N >= GC_MAXCOL.
      LV_SKIP = LV_SKIP + 1.
      CONTINUE.
    ENDIF.
    CLEAR LS_V.
    LS_V-FIELD_NAME  = LS_PICK-FIELD_NAME.
    LS_V-FIELD_LABEL = LS_PICK-FIELD_LABEL.
    LS_V-COL_SIZE    = LS_PICK-COL_SIZE.
    LS_V-ACTIVE      = 'X'.
    APPEND LS_V TO GT_COL_V.
    LV_N = LV_N + 1.
    GV_DIRTY = 'X'.
  ENDLOOP.
  PERFORM SYNC_COL_VIEW.
  PERFORM REFRESH_ALL.
  IF LV_SKIP > 0.
    MESSAGE 'Sebagian kolom tidak ditambahkan: maksimal 14 kolom aktif'
      TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.                    "COL_ADD

*&---------------------------------------------------------------------*
*&      Form  COL_MOVE  (PV_DIR = -1 naik, 1 turun)
*&---------------------------------------------------------------------*
FORM COL_MOVE USING PV_DIR TYPE I.
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROW  TYPE LVC_S_ROW,
        LV_FROM TYPE I,
        LV_TO   TYPE I,
        LV_MAX  TYPE I,
        LS_A    TYPE TY_COL,
        LS_B    TYPE TY_COL.

  PERFORM COMMIT_GRID_INPUT.
  GO_GRID_C->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = LT_ROWS ).
  IF LINES( LT_ROWS ) <> 1.
    MESSAGE 'Pilih satu baris kolom yang mau digeser' TYPE 'S'
      DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  READ TABLE LT_ROWS INTO LS_ROW INDEX 1.
  LV_FROM = LS_ROW-INDEX.
  LV_TO   = LV_FROM + PV_DIR.
  DESCRIBE TABLE GT_COL_V LINES LV_MAX.
  IF LV_TO < 1 OR LV_TO > LV_MAX.
    RETURN.
  ENDIF.
  READ TABLE GT_COL_V INTO LS_A INDEX LV_FROM.
  READ TABLE GT_COL_V INTO LS_B INDEX LV_TO.
  MODIFY GT_COL_V FROM LS_B INDEX LV_FROM.
  MODIFY GT_COL_V FROM LS_A INDEX LV_TO.
  GV_DIRTY = 'X'.
  PERFORM SYNC_COL_VIEW.
  PERFORM REFRESH_ALL.
  REFRESH LT_ROWS.
  LS_ROW-INDEX = LV_TO.
  APPEND LS_ROW TO LT_ROWS.
  GO_GRID_C->SET_SELECTED_ROWS( IT_INDEX_ROWS = LT_ROWS ).
ENDFORM.                    "COL_MOVE

*&---------------------------------------------------------------------*
*&      Form  COL_DELETE
*&---------------------------------------------------------------------*
FORM COL_DELETE.
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROW  TYPE LVC_S_ROW.

  PERFORM COMMIT_GRID_INPUT.
  GO_GRID_C->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = LT_ROWS ).
  IF LT_ROWS IS INITIAL.
    MESSAGE 'Pilih baris kolom yang mau dihapus' TYPE 'S'
      DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SORT LT_ROWS BY INDEX DESCENDING.
  LOOP AT LT_ROWS INTO LS_ROW.
    DELETE GT_COL_V INDEX LS_ROW-INDEX.
  ENDLOOP.
  GV_DIRTY = 'X'.
  PERFORM SYNC_COL_VIEW.
  PERFORM REFRESH_ALL.
ENDFORM.                    "COL_DELETE

*&---------------------------------------------------------------------*
*&      Form  CST_ASSIGN
*&  Tampilkan semua customer KNA1 (tidak ditandai hapus) yang belum
*&  punya group, user centang -> masuk ke group aktif.
*&---------------------------------------------------------------------*
FORM CST_ASSIGN.
  DATA: LT_KNA1  TYPE STANDARD TABLE OF TY_KNA1,
        LS_KNA1  TYPE TY_KNA1,
        LT_USED  TYPE HASHED TABLE OF KNA1-KUNNR
                 WITH UNIQUE KEY TABLE_LINE,
        LS_CST   TYPE ZMAP_COA_GRP_CST,
        LT_PICK  TYPE STANDARD TABLE OF TY_PICK_CST,
        LS_PICK  TYPE TY_PICK_CST,
        LT_FC    TYPE LVC_T_FCAT,
        LS_FC    TYPE LVC_S_FCAT,
        LV_OK    TYPE C LENGTH 1,
        LV_NEW   TYPE I,
        LV_NTXT  TYPE C LENGTH 6,
        LV_TXT   TYPE C LENGTH 120,
        LV_TITLE TYPE LVC_TITLE.

  PERFORM COMMIT_GRID_INPUT.
  LOOP AT GT_CST_ALL INTO LS_CST.
    INSERT LS_CST-KUNNR INTO TABLE LT_USED.
  ENDLOOP.

  SELECT KUNNR NAME1 STRAS ORT01 LAND1 FROM KNA1 INTO TABLE LT_KNA1
    WHERE LOEVM = SPACE.
  SORT LT_KNA1 BY NAME1 KUNNR.
  LOOP AT LT_KNA1 INTO LS_KNA1.
    READ TABLE LT_USED TRANSPORTING NO FIELDS
      WITH TABLE KEY TABLE_LINE = LS_KNA1-KUNNR.
    IF SY-SUBRC = 0.
      CONTINUE.
    ENDIF.
    CLEAR LS_PICK.
    MOVE-CORRESPONDING LS_KNA1 TO LS_PICK.
    APPEND LS_PICK TO LT_PICK.
  ENDLOOP.
  IF LT_PICK IS INITIAL.
    MESSAGE 'Semua customer sudah punya group' TYPE 'S'.
    RETURN.
  ENDIF.

  DEFINE _PFC.
    CLEAR LS_FC.
    LS_FC-FIELDNAME = &1.
    LS_FC-COLTEXT   = &2.
    LS_FC-OUTPUTLEN = &3.
    APPEND LS_FC TO LT_FC.
  END-OF-DEFINITION.
  _PFC 'SEL'   'Pilih'     5.
  _PFC 'KUNNR' 'Customer' 11.
  _PFC 'NAME1' 'Nama'     35.
  _PFC 'STRAS' 'Alamat'   35.
  _PFC 'ORT01' 'Kota'     20.
  _PFC 'LAND1' 'Negara'    6.

  CONCATENATE 'Customer belum punya group - centang Pilih untuk' GV_GRP
    INTO LV_TITLE SEPARATED BY SPACE.
  PERFORM POPUP_GRID_PICK USING LV_TITLE LT_FC
                          CHANGING LT_PICK LV_OK.
  IF LV_OK IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_PICK INTO LS_PICK WHERE SEL = 'X'.
    CLEAR: LS_CST, LS_KNA1.
    LS_CST-KUNNR   = LS_PICK-KUNNR.
    LS_CST-COA_GRP = GV_GRP.
    APPEND LS_CST TO GT_CST_ALL.
    MOVE-CORRESPONDING LS_PICK TO LS_KNA1.
    INSERT LS_KNA1 INTO TABLE GT_KNA1.
    LV_NEW = LV_NEW + 1.
  ENDLOOP.
  IF LV_NEW > 0.
    GV_DIRTY = 'X'.
    PERFORM REFRESH_ALL.
    WRITE LV_NEW TO LV_NTXT LEFT-JUSTIFIED.
    CONCATENATE LV_NTXT 'customer di-assign ke' GV_GRP
      INTO LV_TXT SEPARATED BY SPACE.
    MESSAGE LV_TXT TYPE 'S'.
  ENDIF.
ENDFORM.                    "CST_ASSIGN

*&---------------------------------------------------------------------*
*&      Form  POPUP_GRID_PICK
*&  Popup ALV Grid dengan kolom checkbox SEL (editable). Toolbar ALV
*&  standar: cari, filter, sort. PV_OK = 'X' bila user tekan Lanjut.
*&---------------------------------------------------------------------*
FORM POPUP_GRID_PICK USING    PV_TITLE TYPE LVC_TITLE
                              PT_FC    TYPE LVC_T_FCAT
                     CHANGING PT_DATA  TYPE STANDARD TABLE
                              PV_OK    TYPE C.
  DATA: LT_FC   TYPE LVC_T_FCAT,
        LS_LAYO TYPE LVC_S_LAYO,
        LS_GLAY TYPE LVC_S_GLAY,
        LS_EXIT TYPE SLIS_EXIT_BY_USER.
  FIELD-SYMBOLS <FC> TYPE LVC_S_FCAT.

  CLEAR PV_OK.
  LT_FC = PT_FC.
  LOOP AT LT_FC ASSIGNING <FC>.
    IF <FC>-FIELDNAME = 'SEL'.
      <FC>-CHECKBOX = 'X'.
      <FC>-EDIT     = 'X'.
    ENDIF.
  ENDLOOP.
  LS_LAYO-ZEBRA      = 'X'.
  LS_LAYO-GRID_TITLE = PV_TITLE.
  LS_LAYO-NO_ROWMARK = 'X'.
  LS_LAYO-CWIDTH_OPT = 'X'.
  LS_GLAY-EDT_CLL_CB = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM    = SY-REPID
      I_GRID_TITLE          = PV_TITLE
      I_GRID_SETTINGS       = LS_GLAY
      IS_LAYOUT_LVC         = LS_LAYO
      IT_FIELDCAT_LVC       = LT_FC
      I_SCREEN_START_COLUMN = 2
      I_SCREEN_START_LINE   = 2
      I_SCREEN_END_COLUMN   = 150
      I_SCREEN_END_LINE     = 30
    IMPORTING
      ES_EXIT_CAUSED_BY_USER = LS_EXIT
    TABLES
      T_OUTTAB              = PT_DATA
    EXCEPTIONS
      OTHERS                = 1.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.
  IF LS_EXIT-CANCEL = 'X' OR LS_EXIT-EXIT = 'X' OR LS_EXIT-BACK = 'X'.
    RETURN.
  ENDIF.
  PV_OK = 'X'.
ENDFORM.                    "POPUP_GRID_PICK

*&---------------------------------------------------------------------*
*&      Form  CST_SELECTED
*&---------------------------------------------------------------------*
FORM CST_SELECTED CHANGING PT_KUNNR TYPE STANDARD TABLE.
  DATA: LT_ROWS TYPE LVC_T_ROW,
        LS_ROW  TYPE LVC_S_ROW,
        LS_K    TYPE TY_CST.
  REFRESH PT_KUNNR.
  GO_GRID_K->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = LT_ROWS ).
  LOOP AT LT_ROWS INTO LS_ROW.
    READ TABLE GT_CST_V INTO LS_K INDEX LS_ROW-INDEX.
    IF SY-SUBRC = 0.
      APPEND LS_K-KUNNR TO PT_KUNNR.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "CST_SELECTED

*&---------------------------------------------------------------------*
*&      Form  CST_MOVE
*&---------------------------------------------------------------------*
FORM CST_MOVE.
  DATA: LT_KUNNR TYPE STANDARD TABLE OF KNA1-KUNNR,
        LV_KUNNR TYPE KNA1-KUNNR,
        LT_PICK  TYPE STANDARD TABLE OF TY_PICK_GRP,
        LS_PICK  TYPE TY_PICK_GRP,
        LS_GRP   TYPE TY_GRP,
        LT_FC    TYPE SLIS_T_FIELDCAT_ALV,
        LS_FC    TYPE SLIS_FIELDCAT_ALV,
        LS_SEL   TYPE SLIS_SELFIELD,
        LV_EXIT  TYPE C LENGTH 1.
  FIELD-SYMBOLS <K> TYPE ZMAP_COA_GRP_CST.

  PERFORM CST_SELECTED CHANGING LT_KUNNR.
  IF LT_KUNNR IS INITIAL.
    MESSAGE 'Pilih customer yang mau dipindah' TYPE 'S'
      DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  LOOP AT GT_GRP INTO LS_GRP WHERE COA_GRP <> GV_GRP.
    LS_PICK-COA_GRP = LS_GRP-COA_GRP.
    LS_PICK-INFO    = LS_GRP-INFO.
    APPEND LS_PICK TO LT_PICK.
  ENDLOOP.
  CLEAR LS_FC.
  LS_FC-FIELDNAME = 'COA_GRP'.
  LS_FC-SELTEXT_M = 'Group'.
  LS_FC-OUTPUTLEN = 20.
  LS_FC-TABNAME   = 'LT_PICK'.
  APPEND LS_FC TO LT_FC.
  LS_FC-FIELDNAME = 'INFO'.
  LS_FC-SELTEXT_M = 'Keterangan'.
  LS_FC-OUTPUTLEN = 30.
  APPEND LS_FC TO LT_FC.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      I_TITLE               = 'Pindah ke group'
      I_TABNAME             = 'LT_PICK'
      IT_FIELDCAT           = LT_FC
      I_SCREEN_START_COLUMN = 20
      I_SCREEN_START_LINE   = 5
      I_SCREEN_END_COLUMN   = 75
      I_SCREEN_END_LINE     = 20
    IMPORTING
      ES_SELFIELD           = LS_SEL
      E_EXIT                = LV_EXIT
    TABLES
      T_OUTTAB              = LT_PICK
    EXCEPTIONS
      OTHERS                = 1.
  IF SY-SUBRC <> 0 OR LV_EXIT = 'X' OR LS_SEL-TABINDEX = 0.
    RETURN.
  ENDIF.
  READ TABLE LT_PICK INTO LS_PICK INDEX LS_SEL-TABINDEX.
  LOOP AT LT_KUNNR INTO LV_KUNNR.
    LOOP AT GT_CST_ALL ASSIGNING <K> WHERE KUNNR = LV_KUNNR.
      <K>-COA_GRP = LS_PICK-COA_GRP.
    ENDLOOP.
  ENDLOOP.
  GV_DIRTY = 'X'.
  PERFORM REFRESH_ALL.
ENDFORM.                    "CST_MOVE

*&---------------------------------------------------------------------*
*&      Form  CST_DELETE
*&---------------------------------------------------------------------*
FORM CST_DELETE.
  DATA: LT_KUNNR TYPE STANDARD TABLE OF KNA1-KUNNR,
        LV_KUNNR TYPE KNA1-KUNNR.

  PERFORM CST_SELECTED CHANGING LT_KUNNR.
  IF LT_KUNNR IS INITIAL.
    MESSAGE 'Pilih customer yang mau dilepas' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  LOOP AT LT_KUNNR INTO LV_KUNNR.
    DELETE GT_CST_ALL WHERE KUNNR = LV_KUNNR.
  ENDLOOP.
  GV_DIRTY = 'X'.
  PERFORM REFRESH_ALL.
  MESSAGE 'Customer dilepas, akan memakai group default' TYPE 'S'.
ENDFORM.                    "CST_DELETE

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_ALL
*&---------------------------------------------------------------------*
FORM VALIDATE_ALL CHANGING PV_OK TYPE C.
  DATA: LS_GRP TYPE TY_GRP,
        LV_TXT TYPE C LENGTH 120.
  PV_OK = 'X'.
  PERFORM REFRESH_GROUPS.
  LOOP AT GT_GRP INTO LS_GRP.
    IF LS_GRP-N_COL = 0.
      CONCATENATE 'Group' LS_GRP-COA_GRP
        'belum punya kolom aktif. Tambah kolom atau hapus group.'
        INTO LV_TXT SEPARATED BY SPACE.
      CLEAR PV_OK.
    ELSEIF LS_GRP-N_COL > GC_MAXCOL.
      CONCATENATE 'Group' LS_GRP-COA_GRP
        'punya lebih dari 14 kolom aktif.'
        INTO LV_TXT SEPARATED BY SPACE.
      CLEAR PV_OK.
    ENDIF.
    IF PV_OK IS INITIAL.
      GV_GRP = LS_GRP-COA_GRP.
      PERFORM REFRESH_ALL.
      MESSAGE LV_TXT TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "VALIDATE_ALL

*&---------------------------------------------------------------------*
*&      Form  SAVE_ALL
*&---------------------------------------------------------------------*
FORM SAVE_ALL.
  DATA: LV_OK   TYPE C LENGTH 1,
        LT_COL  TYPE TY_T_COL_DB,
        LT_CST  TYPE TY_T_CST_DB,
        LS_COL  TYPE ZMAP_COA_GRP_COL,
        LS_ODC  TYPE ZMAP_COA_GRP_COL,
        LS_CST  TYPE ZMAP_COA_GRP_CST,
        LS_ODK  TYPE ZMAP_COA_GRP_CST,
        LV_FAIL TYPE C LENGTH 1.

  IF GV_RO = 'X'.
    MESSAGE 'Mode tampilan, tidak bisa simpan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  PERFORM COMMIT_GRID_INPUT.
  PERFORM VALIDATE_ALL CHANGING LV_OK.
  IF LV_OK IS INITIAL.
    RETURN.
  ENDIF.

*-- Kolom: pertahankan stempel perubahan jika baris tidak berubah
  LOOP AT GT_COL_ALL INTO LS_COL.
    READ TABLE GT_COL_DB INTO LS_ODC
      WITH KEY COA_GRP = LS_COL-COA_GRP FIELD_NAME = LS_COL-FIELD_NAME.
    IF SY-SUBRC = 0 AND LS_ODC-FIELD_LABEL = LS_COL-FIELD_LABEL
       AND LS_ODC-SEQ_NO = LS_COL-SEQ_NO
       AND LS_ODC-COL_SIZE = LS_COL-COL_SIZE
       AND LS_ODC-ACTIVE = LS_COL-ACTIVE.
      LS_COL-AENAM = LS_ODC-AENAM.
      LS_COL-AEDAT = LS_ODC-AEDAT.
      LS_COL-AEZET = LS_ODC-AEZET.
    ELSE.
      LS_COL-AENAM = SY-UNAME.
      LS_COL-AEDAT = SY-DATUM.
      LS_COL-AEZET = SY-UZEIT.
    ENDIF.
    LS_COL-MANDT = SY-MANDT.
    APPEND LS_COL TO LT_COL.
  ENDLOOP.

  LOOP AT GT_CST_ALL INTO LS_CST.
    READ TABLE GT_CST_DB INTO LS_ODK WITH KEY KUNNR = LS_CST-KUNNR.
    IF SY-SUBRC = 0 AND LS_ODK-COA_GRP = LS_CST-COA_GRP.
      LS_CST-AENAM = LS_ODK-AENAM.
      LS_CST-AEDAT = LS_ODK-AEDAT.
      LS_CST-AEZET = LS_ODK-AEZET.
    ELSE.
      LS_CST-AENAM = SY-UNAME.
      LS_CST-AEDAT = SY-DATUM.
      LS_CST-AEZET = SY-UZEIT.
    ENDIF.
    LS_CST-MANDT = SY-MANDT.
    APPEND LS_CST TO LT_CST.
  ENDLOOP.

*-- Hapus baris DB yang tidak ada lagi
  LOOP AT GT_COL_DB INTO LS_ODC.
    READ TABLE LT_COL TRANSPORTING NO FIELDS
      WITH KEY COA_GRP = LS_ODC-COA_GRP FIELD_NAME = LS_ODC-FIELD_NAME.
    IF SY-SUBRC <> 0.
      DELETE ZMAP_COA_GRP_COL FROM LS_ODC.
    ENDIF.
  ENDLOOP.
  LOOP AT GT_CST_DB INTO LS_ODK.
    READ TABLE LT_CST TRANSPORTING NO FIELDS
      WITH KEY KUNNR = LS_ODK-KUNNR.
    IF SY-SUBRC <> 0.
      DELETE ZMAP_COA_GRP_CST FROM LS_ODK.
    ENDIF.
  ENDLOOP.

  IF LT_COL IS NOT INITIAL.
    MODIFY ZMAP_COA_GRP_COL FROM TABLE LT_COL.
    IF SY-SUBRC <> 0.
      LV_FAIL = 'X'.
    ENDIF.
  ENDIF.
  IF LT_CST IS NOT INITIAL.
    MODIFY ZMAP_COA_GRP_CST FROM TABLE LT_CST.
    IF SY-SUBRC <> 0.
      LV_FAIL = 'X'.
    ENDIF.
  ENDIF.

  IF LV_FAIL = 'X'.
    ROLLBACK WORK.
    MESSAGE 'Gagal menyimpan, data tidak berubah' TYPE 'S'
      DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  COMMIT WORK AND WAIT.

  GT_COL_DB = LT_COL.
  GT_CST_DB = LT_CST.
  GT_COL_ALL = LT_COL.
  GT_CST_ALL = LT_CST.
  CLEAR GV_DIRTY.
  PERFORM REFRESH_ALL.
  MESSAGE 'Data tersimpan' TYPE 'S'.
ENDFORM.                    "SAVE_ALL

*&---------------------------------------------------------------------*
*&      Form  RELOAD_ALL
*&---------------------------------------------------------------------*
FORM RELOAD_ALL.
  DATA LV_ANS TYPE C LENGTH 1.
  DATA LS_GRP TYPE TY_GRP.
  PERFORM COMMIT_GRID_INPUT.
  IF GV_DIRTY = 'X'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Muat ulang'
        TEXT_QUESTION         = 'Perubahan yang belum disimpan akan dibuang. Lanjut?'
        TEXT_BUTTON_1         = 'Ya'
        TEXT_BUTTON_2         = 'Tidak'
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = SPACE
      IMPORTING
        ANSWER                = LV_ANS
      EXCEPTIONS
        OTHERS                = 1.
    IF LV_ANS <> '1'.
      RETURN.
    ENDIF.
  ENDIF.
  PERFORM LOAD_DATA.
  READ TABLE GT_GRP TRANSPORTING NO FIELDS WITH KEY COA_GRP = GV_GRP.
  IF SY-SUBRC <> 0.
    READ TABLE GT_GRP INTO LS_GRP INDEX 1.
    GV_GRP = LS_GRP-COA_GRP.
  ENDIF.
  PERFORM REFRESH_ALL.
  MESSAGE 'Data dimuat ulang dari database' TYPE 'S'.
ENDFORM.                    "RELOAD_ALL

*&---------------------------------------------------------------------*
*&      Form  FREE_CONTROLS
*&---------------------------------------------------------------------*
FORM FREE_CONTROLS.
  IF GO_GRID_G IS BOUND. GO_GRID_G->FREE( ). ENDIF.
  IF GO_GRID_C IS BOUND. GO_GRID_C->FREE( ). ENDIF.
  IF GO_GRID_K IS BOUND. GO_GRID_K->FREE( ). ENDIF.
  IF GO_SPL2 IS BOUND. GO_SPL2->FREE( ). ENDIF.
  IF GO_SPL1 IS BOUND. GO_SPL1->FREE( ). ENDIF.
  IF GO_DOCK IS BOUND. GO_DOCK->FREE( ). ENDIF.
  CLEAR: GO_GRID_G, GO_GRID_C, GO_GRID_K, GO_SPL1, GO_SPL2, GO_DOCK,
         GO_HANDLER, GV_GRP.
  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.                    "FREE_CONTROLS
