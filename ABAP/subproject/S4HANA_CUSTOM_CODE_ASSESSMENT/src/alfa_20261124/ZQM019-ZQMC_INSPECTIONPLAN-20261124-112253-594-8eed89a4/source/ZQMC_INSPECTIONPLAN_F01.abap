*&---------------------------------------------------------------------*
*&  Include           ZQMC_INSPECTIONPLAN_F01
*&---------------------------------------------------------------------*
INCLUDE Z_PROG_INFO.

START-OF-SELECTION.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'INFO'.
      PERFORM F_PROG_INFO USING V_PROG.
    WHEN OTHERS.
      PERFORM GET_DATA.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA: FILENAME1 TYPE STRING,
         FILENAME2 TYPE STRING,
        V_FNAME(100) TYPE C,
        V_FEXT(3) TYPE C.

  MOVE FILENAME TO FILENAME1.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FILENAME1
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = IT_INSPLAN
    EXCEPTIONS
      CONVERSION_ERROR    = 1
      INVALID_TABLE_WIDTH = 2
      INVALID_TYPE        = 3
      NO_BATCH            = 4
      UNKNOWN_ERROR       = 5
      FILE_OPEN_ERROR     = 6
      FILE_READ_ERROR     = 7
      OTHERS              = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'File cannot be opened'.
    LEAVE TO SCREEN 0.
  ELSE.
    CLEAR  FILENAME2.
    FILENAME2 =  FILENAME1.
    SHIFT FILENAME2 RIGHT CIRCULAR BY 3 PLACES.
    V_FEXT = FILENAME2(3).
    IF V_FEXT EQ 'txt' OR V_FEXT EQ 'TXT'.
      PERFORM UPLOADDATA.
      PERFORM DISPLAYREPORT.
    ELSE.
      MESSAGE 'Invalid File Type' TYPE 'W'.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  CLEAR_INTERNAL_TABLES
*&---------------------------------------------------------------------*
* Subroutine to Clear Internal Tables
*----------------------------------------------------------------------*
FORM CLEAR_INTERNAL_TABLES .
  CLEAR T_MATERIALTASKALLOCATION[].
  CLEAR T_TASK[].
  CLEAR T_OPERATION[].
  CLEAR T_INSPCHARACTERISTIC[].
  CLEAR T_RETURN[].
ENDFORM.                    " CLEAR_INTERNAL_TABLES

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  DISPLAYREPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAYREPORT .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAYREPORT
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR: T_FIELDCAT. REFRESH T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_REPORT' :
*        'LINE' '' ''  '' ''  'Line'      '' ' ' '' '',
      'STAT' '' ''  '' ''  'Status'      '' ' ' '' '',
      'PLANT' '' ''  '' ''  'Plant'      '' ' ' '' '',
      'MATERIAL' '' ''  '' ''  'Material'      '' ' ' '' '',
      'LEVEL' '' ''  '' ''  'Level'      '' ' ' '' '',
      'TASK_LIST_GROUP' '' ''  '' ''  'Task List Group'      '' ' ' '' '',
      'GROUP_COUNTER' '' ''  '' ''  'Group Counter'      '' ' ' '' '',
      'TSK_DESCRIPTION' '' ''  '' ''  'Description'      '' ' ' '' '',
      'MESSAGE' '' ''  '' ''  'Message Log'      '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
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
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = 'F_USER_COMMAND'
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = T_FIELDCAT[]
      IT_EVENTS               = T_EVENTS[]
      IT_EVENT_EXIT           = T_EVENT_EXIT[]
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IS_VARIANT              = WA_VARIANTE
      IS_PRINT                = T_PRINT
      IT_SORT                 = T_SORT[]
      IT_EXCLUDING            = T_EXCLUDING[]
      I_BYPASSING_BUFFER      = 'X'
    TABLES
      T_OUTTAB                = IT_REPORT
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.

  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_ALV_FIELDCATG_ICON

*&---------------------------------------------------------------------*
*&      Form  UPLOADDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOADDATA .
  DATA : IND TYPE I.
  CLEAR IT_INSPLANH. REFRESH IT_INSPLANH.
  IT_INSPLANH[] = IT_INSPLAN[].

  SORT IT_INSPLANH BY PLANT MATERIAL  TASK_LIST_GROUP GROUP_COUNTER.
  DELETE ADJACENT DUPLICATES FROM IT_INSPLANH COMPARING PLANT MATERIAL TASK_LIST_GROUP GROUP_COUNTER tsk_description.
*task_list_usage. " STATU RESP_PLANNER_GROUP  LOSVN LOSBS KAP_ARBPL PLNME.

  PERFORM CEK_TEMPLATE. "ADD GANI
  IF IT_REPORT[] IS NOT INITIAL.
    EXIT.
  ENDIF.                    "UPLOADDATA

* Loop at internal table to load all data
  LOOP AT IT_INSPLANH.
    CLEAR : LINE, NOERR, MESSAGES, STAT.
    CLEAR  :T_MATERIALTASKALLOCATION, T_TASK, T_OPERATION,
            T_INSPCHARACTERISTIC, MSGSHD, MSGSIT, BDCDATA.
    REFRESH :T_MATERIALTASKALLOCATION, T_TASK, T_OPERATION,
             T_INSPCHARACTERISTIC, MSGSHD, MSGSIT, BDCDATA.
    CLEAR MESSAGE.
    CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3,
             MESSAGE_V4, ID, NUMBER.

    IF IT_INSPLANH-PLANT NE SPACE.
*   Moving Corresponding fields to Material internal table
      T_MATERIALTASKALLOCATION-MATERIAL = IT_INSPLANH-MATERIAL.
      T_MATERIALTASKALLOCATION-PLANT = IT_INSPLANH-PLANT.
      T_MATERIALTASKALLOCATION-VALID_FROM = IT_INSPLANH-VDATE. "sy-datum. "NEW COMPANY
      APPEND T_MATERIALTASKALLOCATION.

*   Moving Corresponding fields to task internal table
      T_TASK-VALID_FROM = IT_INSPLANH-VDATE. "sy-datum. "NEW COMPANY
      T_TASK-DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION.
      T_TASK-TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP.
      T_TASK-TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE.
      T_TASK-GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER.
      T_TASK-TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS.
      T_TASK-RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP.
      T_TASK-LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM.
      T_TASK-LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO.
      T_TASK-PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER.
      T_TASK-PLANT = IT_INSPLANH-PLANT.
      APPEND T_TASK.

*   Moving Corresponding fields to Operation internal table
      LOOP AT IT_INSPLAN WHERE PLANT = IT_INSPLANH-PLANT AND
                              MATERIAL = IT_INSPLANH-MATERIAL AND
                              TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP AND
                              GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER AND
                              TSK_DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION AND
                              TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE AND
                              TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS AND
                              RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP AND
                              LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM AND
                              LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO AND
                              PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER. " AND

        T_OPERATION-VALID_FROM = IT_INSPLAN-VDATE. "sy-datum. "NEW COMPANY
        T_OPERATION-ACTIVITY = IT_INSPLAN-OP_ACTIVITY.
        T_OPERATION-PLANT = IT_INSPLAN-PLANT.
        T_OPERATION-DENOMINATOR  = '1'.
        T_OPERATION-NOMINATOR    = '1'.
        T_OPERATION-BASE_QUANTITY = '1.000'.
        APPEND T_OPERATION.

*       Moving Corresponding fields to Inspection Characteristics internal table
        T_INSPCHARACTERISTIC-ACTIVITY = IT_INSPLAN-OP_ACTIVITY.
        T_INSPCHARACTERISTIC-INSPCHAR = IT_INSPLAN-INSPCHAR.
        T_INSPCHARACTERISTIC-VALID_FROM  = IT_INSPLAN-VDATE. "sy-datum. "NEW COMPANY
        T_INSPCHARACTERISTIC-MSTR_CHAR = IT_INSPLAN-MSTR_CHAR.
        T_INSPCHARACTERISTIC-PMSTR_CHAR = IT_INSPLAN-PLANT. "Pmstr_char. "V_PLANT
        T_INSPCHARACTERISTIC-SMPL_PROCEDURE  = IT_INSPLAN-SMPL_PROCEDURE.
        T_INSPCHARACTERISTIC-UP_TOL_LMT_IND = 'X'. " add by Irma
        T_INSPCHARACTERISTIC-LW_TOL_LMT_IND = 'X'.
        T_INSPCHARACTERISTIC-VERSION = IT_INSPLAN-VERSION.
        APPEND T_INSPCHARACTERISTIC.

      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM T_OPERATION COMPARING ALL FIELDS.
    ENDIF.
    IF ROT1 EQ 'X'.
      LOOP AT T_OPERATION.
        PERFORM CALL_BDC_QP01_NEW. "ADD GANI
      ENDLOOP.
    ELSE.
*       CEK COUNTER
      CLEAR IT_PLKO. REFRESH IT_PLKO.
      SELECT PLNNR PLNAL ZAEHL
        INTO (IT_PLKO-PLNNR, IT_PLKO-PLNAL, IT_PLKO-ZAEHL)
        FROM PLKO
        WHERE PLNTY EQ 'Q' AND LOEKZ NE 'X' AND
              PLNNR EQ IT_INSPLANH-TASK_LIST_GROUP.
        IF SY-SUBRC = 0.
          APPEND IT_PLKO.
        ENDIF.
      ENDSELECT.

      IF IT_PLKO[] IS NOT INITIAL.
        CLEAR IND.
        SORT IT_PLKO BY PLNAL.
        LOOP AT IT_PLKO.
          IND = IND + 1.
          IT_PLKO-NO = IND.
          MODIFY IT_PLKO.
        ENDLOOP.
      ENDIF.

*      CHANGE INSPECTION PLAN
      PERFORM CALL_BDC_QP02_HDR.
*      CHANGE MIC
      LOOP AT T_OPERATION.
        PERFORM CALL_BDC_QP02_PLN.
      ENDLOOP.
    ENDIF.
    PERFORM READLOG.
  ENDLOOP.
ENDFORM.                    " UPLOADDATA

*&---------------------------------------------------------------------*
*&      Form  CALL_BDC_QP02_HDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_BDC_QP02_HDR.
  DATA : ENTRY_ACT(2) TYPE C.
  CLEAR ENTRY_ACT.

  LOOP AT IT_PLKO WHERE PLNAL EQ IT_INSPLANH-GROUP_COUNTER.
    ENTRY_ACT = IT_PLKO-NO.
    EXIT.
  ENDLOOP.

  CLEAR BDCDATA.
  REFRESH BDCDATA.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '8010'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC271-PLNNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                IT_INSPLANH-MATERIAL. "'JRPAKI'.
  PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                IT_INSPLANH-PLANT."'2000'.
  PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                IT_INSPLANH-TASK_LIST_GROUP. "'PL-30'.
*  perform bdc_field       using 'RC271-STTAG'
*                                '19.11.2012'.
*  perform bdc_field       using 'RC271-PLNAL'
*                                ''.
* ADDED
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                ENTRY_ACT. "IT_INSPLANH-GROUP_COUNTER. "'1'.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLKOD-PLNAL(01)'. "'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VOUE'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                ENTRY_ACT. "IT_INSPLANH-GROUP_COUNTER. "'1'.
  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.
*END
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                '1'. "it_insplanH-RESP_PLANNER_GROUP. "'1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-VORNR(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ALD1'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                '1'. "it_insplanH-RESP_PLANNER_GROUP. "'1'.

  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VOUE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLKOD-KTEXT'.
  PERFORM BDC_FIELD       USING 'PLKOD-KTEXT'
                                IT_INSPLANH-TSK_DESCRIPTION. "'JR-PL-30'.
  PERFORM BDC_FIELD       USING 'PLKOD-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                IT_INSPLANH-TASK_LIST_USAGE. "'5'.
  PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                IT_INSPLANH-TASK_LIST_STATUS. "'4'.
  PERFORM BDC_FIELD       USING 'PLKOD-VAGRP'
                                IT_INSPLANH-RESP_PLANNER_GROUP. "'QA2'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSVN'
                                IT_INSPLANH-LOT_SIZE_FROM. "'1.000'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSBS'
                                IT_INSPLANH-LOT_SIZE_TO. "'99,999,999.000'.
  PERFORM BDC_FIELD       USING 'PLKOD-SLWBEZ'
                                IT_INSPLANH-INSPPOINT. "'Z1'.
*  perform bdc_field       using 'PLKOD-PLNME'
*                                it_insplanH-task_measure_unit. "'KG'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-ARBPL(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                IT_INSPLANH-GROUP_COUNTER. "'1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-ARBPL(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=BU'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                IT_INSPLANH-GROUP_COUNTER. "'1'.
*perform bdc_transaction using 'QP02'.
  CALL TRANSACTION 'QP02' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGSHD.
ENDFORM.                    "CALL_BDC_QP02_HDR

*&---------------------------------------------------------------------*
*&      Form  CALL_BDC_QP02_PLN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_BDC_QP02_PLN.
  DATA : TXT(20), LOP TYPE I, LOPD TYPE P DECIMALS 0, NUMC(4) TYPE C,
         ENTRY_ACT(2) TYPE C.
  CLEAR : TXT, LOP, ENTRY_ACT.

  CLEAR BDCDATA.
  REFRESH BDCDATA.

  LOOP AT IT_PLKO WHERE PLNAL EQ IT_INSPLANH-GROUP_COUNTER.
    ENTRY_ACT = IT_PLKO-NO.
    EXIT.
  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '8010'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC271-PLNNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ALUE'.
  PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                IT_INSPLANH-MATERIAL. "'JRPAKI'.
  PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                IT_INSPLANH-TASK_LIST_GROUP. "'PL-30'.
*  perform bdc_field       using 'RC271-STTAG'
*                                '19.11.2012'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                ENTRY_ACT. "IT_INSPLANH-GROUP_COUNTER. "'1'.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLKOD-PLNAL(01)'. "'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VOUE'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                ENTRY_ACT. "IT_INSPLANH-GROUP_COUNTER. "'1'.
  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-VORNR(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=QMUE'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.
  CLEAR LOP.
  LOOP AT T_INSPCHARACTERISTIC
      WHERE ACTIVITY = T_OPERATION-ACTIVITY.
    CLEAR : LOPD, NUMC.
    LOPD = T_INSPCHARACTERISTIC-INSPCHAR / 10.
    NUMC = LOPD.
    LOP  = LOP + 1.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RQPAS-ENTRY_ACT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RQPAS-ENTRY_ACT'
                                  NUMC. "t_inspcharacteristic-inspchar. "'1'.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-MKVERSION(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
*    IF LOP = 1.
    PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM(01)'
                                  T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
    PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION(01)'
                                  T_INSPCHARACTERISTIC-VERSION. "'1'.
    PERFORM BDC_FIELD       USING 'PLMKB-STICHPRVER(01)'
                                  T_INSPCHARACTERISTIC-SMPL_PROCEDURE. "'SPJR0005'.
*    ELSE.
*      perform bdc_field       using 'PLMKB-VERWMERKM(02)'
*                                    t_inspcharacteristic-mstr_char. "'PAKOTSTD'.
*      perform bdc_field       using 'PLMKB-MKVERSION(02)'
*                                    t_inspcharacteristic-Version. "'1'.
*      perform bdc_field       using 'PLMKB-STICHPRVER(02)'
*                                    t_inspcharacteristic-smpl_procedure. "'SPJR0005'.
*    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '1501'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENT1'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-QMTB_WERKS'.
    PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM'
                                  T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
    PERFORM BDC_FIELD       USING 'PLMKB-QPMK_WERKS'
                                  IT_INSPLANH-PLANT. "'2000'.
    PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION'
                                  T_INSPCHARACTERISTIC-VERSION. "'1'.
    PERFORM BDC_FIELD       USING 'PLMKB-QMTB_WERKS'
                                  ''.
  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLMKB-MKVERSION(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=QMBU'.
**  perform bdc_field       using 'RQPAS-ENTRY_ACT'
**                                '1'.
*perform bdc_transaction using 'QP02'.
  CALL TRANSACTION 'QP02' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGSIT.
ENDFORM.                    "CALL_BDC_QP02_PLN

*&---------------------------------------------------------------------*
*&      Form  READLOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READLOG .
  CLEAR: LHD, LIT, WA_MSGSHD, WA_MSGSIT, STAT.
  LHD = LINES( MSGSHD ).
  LIT = LINES( MSGSIT ).

  READ TABLE MSGSHD INDEX LHD INTO WA_MSGSHD.
  READ TABLE MSGSIT INDEX LIT INTO WA_MSGSIT.

  LINE  = LINE + 1.

*   HEADER LOG
  IF WA_MSGSHD-MSGTYP EQ 'E'.
    STAT = GCF_E1.
  ELSE.
    STAT = GCF_S1.
  ENDIF.
  IF LHD > 0.
    ID = WA_MSGSHD-MSGID.
    NUMBER =  WA_MSGSHD-MSGNR.
    MESSAGE_V1 = WA_MSGSHD-MSGV1.
    MESSAGE_V2 = WA_MSGSHD-MSGV2.
    MESSAGE_V3 = WA_MSGSHD-MSGV3.
    MESSAGE_V4 = WA_MSGSHD-MSGV4.

    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        ID         = ID
        NUMBER     = NUMBER
        LANGUAGE   = SY-LANGU
        TEXTFORMAT = 'HTM'
        MESSAGE_V1 = MESSAGE_V1
        MESSAGE_V2 = MESSAGE_V2
        MESSAGE_V3 = MESSAGE_V3
        MESSAGE_V4 = MESSAGE_V4
      IMPORTING
        MESSAGE    = MESSAGE.
  ELSE.
    IF ROT2 EQ 'X'.
      MESSAGE = 'No Changes Made  in Header Level.'.
    ENDIF.
  ENDIF.

  IF LHD > 0.
    IT_REPORT-LINE  = LINE.
    IT_REPORT-NOERR  = NOERR.
    IT_REPORT-STAT = STAT.
    IT_REPORT-MESSAGE = MESSAGE.
    IT_REPORT-LEVEL = 'Header'.
    IT_REPORT-MATERIAL = IT_INSPLANH-MATERIAL.
    IT_REPORT-PLANT = IT_INSPLANH-PLANT.
    IT_REPORT-TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP .
    IT_REPORT-GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER.
    IT_REPORT-TSK_DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION.
    IT_REPORT-TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE.
    IT_REPORT-TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS.
    IT_REPORT-RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP.
    IT_REPORT-LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM .
    IT_REPORT-LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO.
    IT_REPORT-OP_ACTIVITY = IT_INSPLANH-OP_ACTIVITY.
    IT_REPORT-PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER.
    IT_REPORT-CONTROL_KEY = IT_INSPLANH-CONTROL_KEY.
    IT_REPORT-INSPCHAR = IT_INSPLANH-INSPCHAR.
    IT_REPORT-MSTR_CHAR = IT_INSPLANH-MSTR_CHAR.
    IT_REPORT-VERSION = IT_INSPLANH-VERSION.
    IT_REPORT-SMPL_PROCEDURE = IT_INSPLANH-SMPL_PROCEDURE.
    APPEND IT_REPORT.
  ENDIF.
*ITEM LOG
  CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3,
         MESSAGE_V4, ID, NUMBER, STAT.

  IF WA_MSGSIT-MSGTYP EQ 'E'.
    STAT = GCF_E1.
  ELSE.
    STAT = GCF_S1.
  ENDIF.

  IF LIT > 0.
    ID = WA_MSGSIT-MSGID.
    NUMBER =  WA_MSGSIT-MSGNR.
    MESSAGE_V1 = WA_MSGSIT-MSGV1.
    MESSAGE_V2 = WA_MSGSIT-MSGV2.
    MESSAGE_V3 = WA_MSGSIT-MSGV3.
    MESSAGE_V4 = WA_MSGSIT-MSGV4.
    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        ID         = ID
        NUMBER     = NUMBER
        LANGUAGE   = SY-LANGU
        TEXTFORMAT = 'HTM'
        MESSAGE_V1 = MESSAGE_V1
        MESSAGE_V2 = MESSAGE_V2
        MESSAGE_V3 = MESSAGE_V3
        MESSAGE_V4 = MESSAGE_V4
      IMPORTING
        MESSAGE    = MESSAGE.
  ELSE.
    IF ROT2 EQ 'X'.
      MESSAGE = 'No Changes Made in Item Level'.
    ENDIF.
  ENDIF.
  IT_REPORT-LINE  = LINE.
  IT_REPORT-NOERR  = NOERR.
  IT_REPORT-STAT = STAT.
  IT_REPORT-MESSAGE = MESSAGE.
  IT_REPORT-LEVEL = 'Item'.
  IT_REPORT-MATERIAL = IT_INSPLANH-MATERIAL.
  IT_REPORT-PLANT = IT_INSPLANH-PLANT.
  IT_REPORT-TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP .
  IT_REPORT-GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER.
  IT_REPORT-TSK_DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION.
  IT_REPORT-TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE.
  IT_REPORT-TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS.
  IT_REPORT-RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP.
  IT_REPORT-LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM .
  IT_REPORT-LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO.
  IT_REPORT-OP_ACTIVITY = IT_INSPLANH-OP_ACTIVITY.
  IT_REPORT-PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER.
  IT_REPORT-INSPCHAR = IT_INSPLANH-INSPCHAR.
  IT_REPORT-MSTR_CHAR = IT_INSPLANH-MSTR_CHAR.
  IT_REPORT-VERSION = IT_INSPLANH-VERSION.
  IT_REPORT-SMPL_PROCEDURE = IT_INSPLANH-SMPL_PROCEDURE.
  APPEND IT_REPORT.

ENDFORM.                    " READLOG

*&---------------------------------------------------------------------*
*&      Form  CALL_BDC_QP01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_BDC_QP01_NEW. "ADD GANI

  DATA :PLNAL LIKE PLKO-PLNAL,
        PLNALT(2) TYPE C,
        CT TYPE I,
        TXT(20),
        LOP TYPE I.

  CLEAR : PLNALT, TXT, LOP.
  SELECT COUNT(*) INTO CT FROM PLKO WHERE  PLNTY EQ 'Q' AND PLNNR EQ IT_INSPLANH-TASK_LIST_GROUP.
  CT = CT + 1.
  PLNALT = CT.

  CLEAR BDCDATA.
  REFRESH BDCDATA.
*  perform bdc_transaction using 'QP01'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '8010'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC271-PLNNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ALUE'.
  PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                IT_INSPLANH-MATERIAL. "'JRPAKI'.
  PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                IT_INSPLANH-TASK_LIST_GROUP. "'PL-30'.
  PERFORM BDC_FIELD       USING 'RC271-STTAG'
                                IT_INSPLANH-VDATE. "'19.11.2012'.  "NEW COMPANY
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                '1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ANLG'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VOUE'.
*  perform bdc_field       using 'PLKOD-PLNAL'
*                                PLNALT . "''.
  PERFORM BDC_FIELD       USING 'PLKOD-KTEXT'
                                IT_INSPLANH-TSK_DESCRIPTION. "'JR-PL-30'.
  PERFORM BDC_FIELD       USING 'PLKOD-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLKOD-LOSVN'.
  PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                IT_INSPLANH-TASK_LIST_USAGE. "'5'.
  PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                IT_INSPLANH-TASK_LIST_STATUS. "'4'.
  PERFORM BDC_FIELD       USING 'PLKOD-VAGRP'
                                IT_INSPLANH-RESP_PLANNER_GROUP. "'QA2'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSVN'
                                IT_INSPLANH-LOT_SIZE_FROM. "'1'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSBS'
                                IT_INSPLANH-LOT_SIZE_TO. "'99,999,999.000'.
  PERFORM BDC_FIELD       USING 'PLKOD-SLWBEZ'
                                IT_INSPLANH-INSPPOINT. "'Z1'.
*  perform bdc_field       using 'PLKOD-PLNME'
*                                'KG'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                '1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-STEUS(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'PLPOD-ARBPL(01)'
                                IT_INSPLANH-PLANNING_WORK_CENTER. "'QA-Z01'.
  PERFORM BDC_FIELD       USING 'PLPOD-STEUS(01)'
                                IT_INSPLANH-CONTROL_KEY. "'ZQ01'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-VORNR(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=QMUE'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.
  CLEAR LOP.
  LOOP AT T_INSPCHARACTERISTIC
    WHERE ACTIVITY = T_OPERATION-ACTIVITY.
    LOP  = LOP + 1.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RQPAS-ENTRY_ACT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RQPAS-ENTRY_ACT'
                                  T_INSPCHARACTERISTIC-INSPCHAR. "'2'.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-STICHPRVER(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RQPAS-ENTRY_ACT'
                                  T_INSPCHARACTERISTIC-INSPCHAR. "'2'.
    IF LOP = 1.
      PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM(01)'
                                    T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
      PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION(01)'
                                    T_INSPCHARACTERISTIC-VERSION. "'1'.
      PERFORM BDC_FIELD       USING 'PLMKB-STICHPRVER(01)'
                                    T_INSPCHARACTERISTIC-SMPL_PROCEDURE. "'SPJR0005'.
    ELSE.
      PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM(02)'
                                    T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
      PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION(02)'
                                    T_INSPCHARACTERISTIC-VERSION. "'1'.
      PERFORM BDC_FIELD       USING 'PLMKB-STICHPRVER(02)'
                                    T_INSPCHARACTERISTIC-SMPL_PROCEDURE. "'SPJR0005'.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '1501'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENT1'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-PMETHODE'.
    PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM'
                                  T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
    PERFORM BDC_FIELD       USING 'PLMKB-QPMK_WERKS'
                                  IT_INSPLANH-PLANT. "'2000'.
    PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION'
                                  T_INSPCHARACTERISTIC-VERSION. "'1'.
    PERFORM BDC_FIELD       USING 'PLMKB-QMTB_WERKS'
                                  ''.
  ENDLOOP.
  PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-STICHPRVER(02)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=QMBU'.
  P_MODE-UPDMODE = 'S'.
  P_MODE-DISMODE = CTUMODE. "'N'.
  P_MODE-DEFSIZE = 'X'.

  CALL TRANSACTION 'QP01' USING BDCDATA
                          OPTIONS FROM P_MODE
                          MESSAGES INTO MSGSIT.

ENDFORM.                    "CALL_BDC_QP01

*&---------------------------------------------------------------------*
*&      Form  CEK_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_TEMPLATE.
  TABLES: MAPL, PLKO.
  DATA: VKTEXT LIKE PLKO-KTEXT.

  CLEAR: IT_REPORT.
  REFRESH: IT_REPORT.

  LOOP AT IT_INSPLANH.
    CLEAR: VKTEXT, IT_REPORT.

    SELECT SINGLE PLKO~KTEXT INTO VKTEXT
      FROM MAPL JOIN PLKO ON MAPL~PLNTY = PLKO~PLNTY AND MAPL~PLNNR = PLKO~PLNNR
      AND MAPL~PLNAL = PLKO~PLNAL AND MAPL~ZAEHL = PLKO~ZAEHL
      WHERE MAPL~MATNR = IT_INSPLANH-MATERIAL
      AND MAPL~WERKS = IT_INSPLANH-PLANT
      AND MAPL~PLNTY EQ 'Q'
      AND MAPL~LOEKZ EQ ''
      AND PLKO~LOEKZ EQ ''
      AND PLKO~KTEXT = IT_INSPLANH-TSK_DESCRIPTION.

    IF SY-SUBRC = 0.
      IT_REPORT-STAT = GCF_E1.
      IT_REPORT-MATERIAL = IT_INSPLANH-MATERIAL.
      IT_REPORT-PLANT = IT_INSPLANH-PLANT.
      IT_REPORT-TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP.
      IT_REPORT-GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER.
      IT_REPORT-TSK_DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION.
      IT_REPORT-MESSAGE = 'Error Description Sama'.
      APPEND IT_REPORT.
    ENDIF.
  ENDLOOP.

  IF IT_REPORT[] IS NOT INITIAL.
    EXIT.
  ENDIF.

  LOOP AT IT_INSPLANH.
    CLEAR : LINE, NOERR, MESSAGES, STAT.
    CLEAR  :T_MATERIALTASKALLOCATION, T_TASK, T_OPERATION,
            T_INSPCHARACTERISTIC, MSGSHD, MSGSIT, BDCDATA.
    REFRESH :T_MATERIALTASKALLOCATION, T_TASK, T_OPERATION,
             T_INSPCHARACTERISTIC, MSGSHD, MSGSIT, BDCDATA.
    CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3, MESSAGE_V4, ID, NUMBER.

    IF IT_INSPLANH-PLANT NE SPACE.
*   Moving Corresponding fields to Material internal table
      T_MATERIALTASKALLOCATION-MATERIAL = IT_INSPLANH-MATERIAL.
      T_MATERIALTASKALLOCATION-PLANT = IT_INSPLANH-PLANT.
      T_MATERIALTASKALLOCATION-VALID_FROM = IT_INSPLANH-VDATE. "sy-datum. "NEW COMPANY
      APPEND T_MATERIALTASKALLOCATION.

*   Moving Corresponding fields to task internal table
      T_TASK-VALID_FROM = IT_INSPLANH-VDATE. "sy-datum. "NEW COMPANY
      T_TASK-DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION.
      T_TASK-TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP.
      T_TASK-TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE.
      T_TASK-GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER.
      T_TASK-TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS.
      T_TASK-RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP.
      T_TASK-LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM.
      T_TASK-LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO.
      T_TASK-PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER.
      T_TASK-PLANT = IT_INSPLANH-PLANT.
      APPEND T_TASK.

*   Moving Corresponding fields to Operation internal table
      LOOP AT IT_INSPLAN WHERE PLANT = IT_INSPLANH-PLANT AND
                              MATERIAL = IT_INSPLANH-MATERIAL AND
                              TASK_LIST_GROUP = IT_INSPLANH-TASK_LIST_GROUP AND
                              GROUP_COUNTER = IT_INSPLANH-GROUP_COUNTER AND
                              TSK_DESCRIPTION = IT_INSPLANH-TSK_DESCRIPTION AND
                              TASK_LIST_USAGE = IT_INSPLANH-TASK_LIST_USAGE AND
                              TASK_LIST_STATUS = IT_INSPLANH-TASK_LIST_STATUS AND
                              RESP_PLANNER_GROUP = IT_INSPLANH-RESP_PLANNER_GROUP AND
                              LOT_SIZE_FROM = IT_INSPLANH-LOT_SIZE_FROM AND
                              LOT_SIZE_TO = IT_INSPLANH-LOT_SIZE_TO AND
                              PLANNING_WORK_CENTER = IT_INSPLANH-PLANNING_WORK_CENTER. " AND

        T_OPERATION-VALID_FROM = IT_INSPLAN-VDATE. "sy-datum. "NEW COMPANY
        T_OPERATION-ACTIVITY = IT_INSPLAN-OP_ACTIVITY.
        T_OPERATION-PLANT = IT_INSPLAN-PLANT.
        T_OPERATION-DENOMINATOR  = '1'.
        T_OPERATION-NOMINATOR    = '1'.
        T_OPERATION-BASE_QUANTITY = '1.000'.
        APPEND T_OPERATION.

*       Moving Corresponding fields to Inspection Characteristics internal table
        T_INSPCHARACTERISTIC-ACTIVITY = IT_INSPLAN-OP_ACTIVITY.
        T_INSPCHARACTERISTIC-INSPCHAR = IT_INSPLAN-INSPCHAR.
        T_INSPCHARACTERISTIC-VALID_FROM  = IT_INSPLAN-VDATE. "sy-datum. "NEW COMPANY
        T_INSPCHARACTERISTIC-MSTR_CHAR = IT_INSPLAN-MSTR_CHAR.
        T_INSPCHARACTERISTIC-PMSTR_CHAR = IT_INSPLAN-PLANT. "Pmstr_char. "V_PLANT
        T_INSPCHARACTERISTIC-SMPL_PROCEDURE  = IT_INSPLAN-SMPL_PROCEDURE.
        T_INSPCHARACTERISTIC-UP_TOL_LMT_IND = 'X'. " add by Irma
        T_INSPCHARACTERISTIC-LW_TOL_LMT_IND = 'X'.
        T_INSPCHARACTERISTIC-VERSION = IT_INSPLAN-VERSION.
        APPEND T_INSPCHARACTERISTIC.

      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM T_OPERATION COMPARING ALL FIELDS.
    ENDIF.
    LOOP AT T_OPERATION.
      PERFORM CALL_BDC_QP01_NEW_TESMODE. "ADD GANI
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "CEK_TEMPLATE


*&---------------------------------------------------------------------*
*&      Form  CALL_BDC_QP01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_BDC_QP01_NEW_TESMODE. "ADD GANI

  DATA :PLNAL LIKE PLKO-PLNAL,
        PLNALT(2) TYPE C,
        CT TYPE I,
        TXT(20),
        LOP TYPE I.

  CLEAR : PLNALT, TXT, LOP.
  SELECT COUNT(*) INTO CT FROM PLKO WHERE  PLNTY EQ 'Q' AND PLNNR EQ IT_INSPLANH-TASK_LIST_GROUP.
  CT = CT + 1.
  PLNALT = CT.

  CLEAR BDCDATA.
  REFRESH BDCDATA.
*  perform bdc_transaction using 'QP01'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '8010'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC271-PLNNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ALUE'.
  PERFORM BDC_FIELD       USING 'RC27M-MATNR'
                                IT_INSPLANH-MATERIAL. "'JRPAKI'.
  PERFORM BDC_FIELD       USING 'RC27M-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'RC271-PLNNR'
                                IT_INSPLANH-TASK_LIST_GROUP. "'PL-30'.
  PERFORM BDC_FIELD       USING 'RC271-STTAG'
                                IT_INSPLANH-VDATE. "'19.11.2012'.  "NEW COMPANY
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                '1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ANLG'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDA' '1200'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=VOUE'.
*  perform bdc_field       using 'PLKOD-PLNAL'
*                                PLNALT . "''.
  PERFORM BDC_FIELD       USING 'PLKOD-KTEXT'
                                IT_INSPLANH-TSK_DESCRIPTION. "'JR-PL-30'.
  PERFORM BDC_FIELD       USING 'PLKOD-WERKS'
                                IT_INSPLANH-PLANT. "'2000'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLKOD-LOSVN'.
  PERFORM BDC_FIELD       USING 'PLKOD-VERWE'
                                IT_INSPLANH-TASK_LIST_USAGE. "'5'.
  PERFORM BDC_FIELD       USING 'PLKOD-STATU'
                                IT_INSPLANH-TASK_LIST_STATUS. "'4'.
  PERFORM BDC_FIELD       USING 'PLKOD-VAGRP'
                                IT_INSPLANH-RESP_PLANNER_GROUP. "'QA2'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSVN'
                                IT_INSPLANH-LOT_SIZE_FROM. "'1'.
  PERFORM BDC_FIELD       USING 'PLKOD-LOSBS'
                                IT_INSPLANH-LOT_SIZE_TO. "'99,999,999.000'.
  PERFORM BDC_FIELD       USING 'PLKOD-SLWBEZ'
                                IT_INSPLANH-INSPPOINT. "'Z1'.
*  perform bdc_field       using 'PLKOD-PLNME'
*                                'KG'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
*  perform bdc_field       using 'RC27X-ENTRY_ACT'
*                                '1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-STEUS(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'PLPOD-ARBPL(01)'
                                IT_INSPLANH-PLANNING_WORK_CENTER. "'QA-Z01'.
  PERFORM BDC_FIELD       USING 'PLPOD-STEUS(01)'
                                IT_INSPLANH-CONTROL_KEY. "'ZQ01'.

  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RC27X-ENTRY_ACT'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_DYNPRO      USING 'SAPLCPDI' '1400'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'PLPOD-VORNR(01)'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=QMUE'.
  PERFORM BDC_FIELD       USING 'RC27X-ENTRY_ACT'
                                T_OPERATION-ACTIVITY. "'1'.
  PERFORM BDC_FIELD       USING 'RC27X-FLG_SEL(01)'
                                'X'.
  CLEAR LOP.
  LOOP AT T_INSPCHARACTERISTIC
    WHERE ACTIVITY = T_OPERATION-ACTIVITY.
    LOP  = LOP + 1.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'RQPAS-ENTRY_ACT'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RQPAS-ENTRY_ACT'
                                  T_INSPCHARACTERISTIC-INSPCHAR. "'2'.
    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-STICHPRVER(01)'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'RQPAS-ENTRY_ACT'
                                  T_INSPCHARACTERISTIC-INSPCHAR. "'2'.
    IF LOP = 1.
      PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM(01)'
                                    T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
      PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION(01)'
                                    T_INSPCHARACTERISTIC-VERSION. "'1'.
      PERFORM BDC_FIELD       USING 'PLMKB-STICHPRVER(01)'
                                    T_INSPCHARACTERISTIC-SMPL_PROCEDURE. "'SPJR0005'.
    ELSE.
      PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM(02)'
                                    T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
      PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION(02)'
                                    T_INSPCHARACTERISTIC-VERSION. "'1'.
      PERFORM BDC_FIELD       USING 'PLMKB-STICHPRVER(02)'
                                    T_INSPCHARACTERISTIC-SMPL_PROCEDURE. "'SPJR0005'.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '1501'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=ENT1'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-PMETHODE'.
    PERFORM BDC_FIELD       USING 'PLMKB-VERWMERKM'
                                  T_INSPCHARACTERISTIC-MSTR_CHAR. "'PAKOTSTD'.
    PERFORM BDC_FIELD       USING 'PLMKB-QPMK_WERKS'
                                  IT_INSPLANH-PLANT. "'2000'.
    PERFORM BDC_FIELD       USING 'PLMKB-MKVERSION'
                                  T_INSPCHARACTERISTIC-VERSION. "'1'.
    PERFORM BDC_FIELD       USING 'PLMKB-QMTB_WERKS'
                                  ''.
  ENDLOOP.
  PERFORM BDC_DYNPRO      USING 'SAPLQPAA' '0150'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'PLMKB-STICHPRVER(02)'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                  '=QMBU'.

  P_MODE-UPDMODE = 'S'.
  P_MODE-DISMODE = CTUMODE. "'N'.
  P_MODE-DEFSIZE = 'X'.

  CALL TRANSACTION 'QP01' USING BDCDATA OPTIONS FROM P_MODE
*                                    MODE CTUMODE
*                                    UPDATE 'S'
                                    MESSAGES INTO MSGSIT.
***** MESSAGE LOG

  CLEAR: LIT, WA_MSGSIT, MESSAGE.
  LIT = LINES( MSGSIT ).
  READ TABLE MSGSIT INDEX LIT INTO WA_MSGSIT.
  LINE  = LINE + 1.

  IF WA_MSGSIT-MSGTYP EQ 'E'.
    IF LIT > 0.
      ID = WA_MSGSIT-MSGID.
      NUMBER =  WA_MSGSIT-MSGNR.
      MESSAGE_V1 = WA_MSGSIT-MSGV1.
      MESSAGE_V2 = WA_MSGSIT-MSGV2.
      MESSAGE_V3 = WA_MSGSIT-MSGV3.
      MESSAGE_V4 = WA_MSGSIT-MSGV4.
      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
        EXPORTING
          ID         = ID
          NUMBER     = NUMBER
          LANGUAGE   = SY-LANGU
          TEXTFORMAT = 'HTM'
          MESSAGE_V1 = MESSAGE_V1
          MESSAGE_V2 = MESSAGE_V2
          MESSAGE_V3 = MESSAGE_V3
          MESSAGE_V4 = MESSAGE_V4
        IMPORTING
          MESSAGE    = MESSAGE.
    ENDIF.
    IT_REPORT-STAT = GCF_E1. "error
    IT_REPORT-MESSAGE = MESSAGE.
    IT_REPORT-MATERIAL = IT_INSPLANH-MATERIAL.
    IT_REPORT-PLANT = IT_INSPLANH-PLANT.
    APPEND IT_REPORT.
  ENDIF.

ENDFORM.                    "CALL_BDC_QP01