*&---------------------------------------------------------------------*
*&  Include           ZQMC_INSPECTIONPLAN_TOP
*&---------------------------------------------------------------------*
DATA : BEGIN OF IT_INSPLAN OCCURS 0,
        material(40),
        plant(4),
        TASK_LIST_GROUP(8),
        GROUP_COUNTER(10),
        tsk_description(40),
        task_list_usage(3),
        task_list_status(3),
        RESP_PLANNER_GROUP(3),
        lot_size_from(16),
        lot_size_to(16),
        op_activity(4),
        planning_work_center(8),
        control_key(4),
        inspchar(4),
        mstr_char(8),
        Version(6),
        smpl_procedure(8),
        vdate(10),  "add new company
        insppoint(3),  "add inspection plan
       END OF IT_INSPLAN.
DATA : it_insplanH LIKE LINE OF it_insplan OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF IT_PLKO OCCURS 0,
        NO TYPE I,
        PLNNR LIKE PLKO-PLNNR,
        PLNAL LIKE PLKO-PLNAL,
        ZAEHL LIKE PLKO-ZAEHL,
       END OF IT_PLKO.

DATA: BEGIN OF IT_REPORT OCCURS 0.
        INCLUDE STRUCTURE IT_INSPLAN.
DATA :  LINE TYPE I,
        NOERR TYPE I,
        STAT(40) TYPE C,
        MESSAGE(100),
        LEVEL(10),
      END OF IT_REPORT.

* Type Pool Used for ALV Log Display
TYPE-POOLS : slis.

* Data Declarations for import internal table parameters to BAPI
DATA : t_task TYPE TABLE OF bapi1191_tsk_c WITH HEADER LINE,
       t_materialtaskallocation TYPE TABLE OF bapi1191_mtk_c  WITH HEADER LINE,
*      t_inspcharacteristic TYPE TABLE OF bapi1191_cha_c  WITH HEADER LINE,
       t_operation TYPE TABLE OF bapi1191_opr_c  WITH HEADER LINE,
       t_return TYPE TABLE OF bapiret2 WITH HEADER LINE.

DATA : BEGIN OF t_inspcharacteristic OCCURS 0,
        VERSION(6).
        INCLUDE STRUCTURE bapi1191_cha_c.
DATA : END OF t_inspcharacteristic .
DATA : v_group TYPE bapi1191_tsk_c-task_list_group,
        v_grpcounter TYPE bapi1191_tsk_c-group_counter,
        v_file TYPE localfile,
        v_row TYPE n,
        v_plant LIKE t_task-plant,
        v_lines TYPE i,
        v_per TYPE p,
        v_txt(50) TYPE c.

* Declare Internal table for Message Header for ALV Display
DATA: BEGIN OF it_loghead  OCCURS 0,
        material LIKE bapi1191_mtk_c-material,
        plant LIKE bapi1191_tsk_c-plant,
        msgtype LIKE bapiret2-type,
        msg(100) TYPE c,
        expand TYPE c,
END OF it_loghead .

* Declare Internal table for Message Details for ALV Display
DATA: BEGIN OF it_logdetail OCCURS 0,
        material LIKE bapi1191_mtk_c-material,
        plant LIKE bapi1191_tsk_c-plant,
        msgtype LIKE bapiret2-type,
        msg(100) TYPE c,
      END OF it_logdetail.

DATA : V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZQMC_INSPECTIONPLAN'.
* Data for listviewer
DATA: D_REPID      LIKE SY-REPID,
      T_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      WA_KEYINFO   TYPE SLIS_KEYINFO_ALV,
      T_COLOR      TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE,
      WA_LAYOUT    TYPE SLIS_LAYOUT_ALV,
      T_PRINT      TYPE SLIS_PRINT_ALV,
      T_SORT       TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE,
      T_EXCLUDING  TYPE SLIS_T_EXTAB WITH HEADER LINE,
      T_EVENTS     TYPE SLIS_T_EVENT WITH HEADER LINE,
      T_EVENT_EXIT TYPE SLIS_T_EVENT_EXIT WITH HEADER LINE,
      T_LIST_TOP   TYPE SLIS_T_LISTHEADER,

* Variants
      WA_VARIANTE        LIKE DISVARIANT,
      WA_DEF_VARIANTE    LIKE DISVARIANT,
      D_VARIANT_EXIT(1) TYPE C.

CONSTANTS:
  GCF_E1(4) TYPE C VALUE '@0A@',
  GCF_S1(4) TYPE C VALUE '@08@'.
DATA : STAT(4) TYPE C.

DATA: BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE,     "BDC Data
      MESSTAB TYPE SORTED TABLE OF BDCMSGCOLL WITH HEADER LINE
      WITH NON-UNIQUE DEFAULT KEY,  "Message
      MESSTAB2 TYPE SORTED TABLE OF BDCMSGCOLL WITH HEADER LINE
      WITH NON-UNIQUE DEFAULT KEY,
      MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      MSGSHD  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      MSGSIT  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
      WA_MSGSHD LIKE LINE OF MSGSHD,
      WA_MSGSIT LIKE LINE OF MSGSIT.

DATA : LHD TYPE I,
       LIT TYPE I.
DATA : LINE TYPE I,
       NOERR TYPE I,
       MESSAGES(100),
       MESSAGE LIKE BAPIRET2-MESSAGE,
       MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
       MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
       MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
       MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
       ID LIKE  BAPIRET2-ID,
       NUMBER LIKE  BAPIRET2-NUMBER.

DATA: P_MODE TYPE CTU_PARAMS.
*********
SELECTION-SCREEN BEGIN OF BLOCK B1001 WITH FRAME TITLE TEXT-100.
PARAMETERS: FILENAME LIKE RLGRAP-FILENAME
                     LOWER CASE OBLIGATORY
                     DEFAULT 'C:/'.
SELECTION-SCREEN END OF BLOCK B1001.

*OPTION TYPE
SELECTION-SCREEN BEGIN OF BLOCK B1002 WITH FRAME TITLE TEXT-120.
PARAMETERS : ROT1 RADIOBUTTON GROUP ROT DEFAULT 'X',
             ROT2 RADIOBUTTON GROUP ROT.
SELECTION-SCREEN END OF BLOCK B1002.

SELECTION-SCREEN BEGIN OF BLOCK B1003 WITH FRAME TITLE TEXT-150.
PARAMETERS: CTUMODE LIKE CTU_PARAMS-DISMODE DEFAULT 'N'.
SELECTION-SCREEN END OF BLOCK B1003.

SELECTION-SCREEN BEGIN OF BLOCK B1004 WITH FRAME.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.
SELECTION-SCREEN END OF BLOCK B1004.

LOAD-OF-PROGRAM.
  INFO = 'Program Information'.

*************************Get file name*********************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILENAME.
*POPUP TO SELECT FILE NAME
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'C:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = FILENAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

*************************Get file name*********************************