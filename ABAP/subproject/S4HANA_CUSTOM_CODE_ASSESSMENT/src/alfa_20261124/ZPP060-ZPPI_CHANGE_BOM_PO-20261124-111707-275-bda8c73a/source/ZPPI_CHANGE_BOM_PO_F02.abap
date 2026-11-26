*&---------------------------------------------------------------------*
*&  Include           ZPPI_CHANGE_BOM_PO_F02
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                          P_TABLE_NAME
                          P_MARK_NAME
                 CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: L_OK              TYPE SY-UCOMM,
         L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.

     WHEN 'DELE'.                      "delete row
       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME.
       CLEAR P_OK.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME   .
       CLEAR P_OK.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                           P_TABLE_NAME
                                           P_MARK_NAME .
       CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_INSERT_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE L_SELLINE.
   IF SY-SUBRC <> 0.                   " append line to table
     L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
     IF L_SELLINE > <LINES>.
       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
     ELSE.
       <TC>-TOP_LINE = 1.
     ENDIF.
   ELSE.                               " insert line into table
     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE L_LINE.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_DELETE_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       DELETE <TABLE> INDEX SYST-TABIX.
       IF SY-SUBRC = 0.
         <TC>-LINES = <TC>-LINES - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                       P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TC_NEW_TOP_LINE     TYPE I.
   DATA L_TC_NAME             LIKE FELD-NAME.
   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
   ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
   IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
     L_TC_NEW_TOP_LINE = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         ENTRY_ACT             = <TC>-TOP_LINE
         ENTRY_FROM            = 1
         ENTRY_TO              = <TC>-LINES
         LAST_PAGE_FULL        = 'X'
         LOOPS                 = <LINES>
         OK_CODE               = P_OK
         OVERLAPPING           = 'X'
       IMPORTING
         ENTRY_NEW             = L_TC_NEW_TOP_LINE
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO           = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS                = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD L_TC_FIELD_NAME
              AREA  L_TC_NAME.

   IF SYST-SUBRC = 0.
     IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                P_TABLE_NAME
                                P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                  P_TABLE_NAME
                                  P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = SPACE.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  F_EXPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_EXPORT .
   DATA : P_FILE TYPE STRING. "LIKE RLGRAP-FILENAME .
   DATA: L_FOLDER TYPE STRING,
         COMPUTER_NAME TYPE STRING.

   CLEAR : WA_EXCEL,TA_EXCEL,P_ANSWER.
   REFRESH : TA_EXCEL.


   CHECK T_CEKLIST IS NOT INITIAL.
*   PERFORM F_CHOOSE CHANGING P_ANSWER.
*   CHECK P_ANSWER NE 'A'.

   ITAB[] = T_CEKLIST[].
   SORT ITAB BY AUFNRID CHARGID.
   DELETE ADJACENT DUPLICATES FROM ITAB COMPARING AUFNRID CHARGID.
*   SORT ITAB BY AUFNRID CHARGID ASCENDING CHARGID.  "- change 5 feb13
   SORT ITAB BY NOSEQID AUFNRID CHARGID ASCENDING NOSEQID.
   SORT T_CEKLIST BY AUFNRID CHARGID BKTXTID STLKN ASCENDING STLKN.

   LOOP AT ITAB.
     NUM = 0.

     LOOP AT T_CEKLIST INTO W_CEKLIST WHERE AUFNRID = ITAB-AUFNRID
                                      AND   CHARGID = ITAB-CHARGID.
       MOVE-CORRESPONDING W_CEKLIST TO WA_EXCEL.
       WA_EXCEL-LGORT_A = W_CEKLIST-LGORT_P.
*     IF P_ANSWER = '2'.
*       REPLACE ALL OCCURRENCES OF '.' IN WA_EXCEL-MENGE_GR WITH ','.
*       REPLACE ALL OCCURRENCES OF '.' IN WA_EXCEL-MENGE_A WITH ','.
*     ENDIF.

       PERFORM F_GET_MATGROUP USING W_CEKLIST-MATNR_A CHANGING MATKL CEK.
       IF CEK = ''.
         NUM = NUM + 1.

         IF NUM = 1.
           WA_EXCEL-ZZNOMORROLL = W_CEKLIST-BKTXTID.
           READ TABLE T_CEKLIST INTO W_CEKLIST WITH KEY IGI     = 'X'
                                                        AUFNRID = W_CEKLIST-AUFNRID.
           IF SY-SUBRC = 0.
             WA_EXCEL-IGI = W_CEKLIST-IGI.
           ENDIF.
         ELSE.
           CLEAR : WA_EXCEL-IGI,WA_EXCEL-NOSEQID,WA_EXCEL-ZZNOMORROLL.
         ENDIF.

         WA_EXCEL-MEINS = W_CEKLIST-MEINS_P.

         CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
           EXPORTING
             INPUT    = WA_EXCEL-MEINS
           IMPORTING
             OUTPUT   = WA_EXCEL-MEINS.

         CLEAR : WA_EXCEL-MATKL.
         APPEND WA_EXCEL TO TA_EXCEL.
       ENDIF.

     ENDLOOP.

   ENDLOOP.

   CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
     EXPORTING
       WINDOW_TITLE    = 'Select Folder Path'
       INITIAL_FOLDER  = 'D:\'
     CHANGING
       SELECTED_FOLDER = L_FOLDER.

   CALL FUNCTION 'POC_GET_COMPUTER_NAME'
     IMPORTING
       EX_COMPUTER_NAME = COMPUTER_NAME
     EXCEPTIONS
       GUI_ERROR        = 1
       OTHERS           = 2.

*   IF P_ANSWER = '1'.
*     CONCATENATE L_FOLDER '\' SY-DATUM '-' COMPUTER_NAME '.TXT' INTO P_FILE.
*   ELSEIF P_ANSWER = '2'.
   CONCATENATE L_FOLDER '\' SY-DATUM '-' SY-UZEIT '-' COMPUTER_NAME '.XLS' INTO P_FILE.
*   ENDIF.


   INT_HEAD-FILED1 = 'Indicator Gi'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'No Sequence JR'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'No JR'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Order Number'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Batch JR'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Type Film'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Quantity GR'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Material GI'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Description'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Quantity GI'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Uom GI'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   INT_HEAD-FILED1 = 'Batch GI'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.


   INT_HEAD-FILED1 = 'Sloc GI'.
   APPEND INT_HEAD.
   CLEAR INT_HEAD.

   CALL FUNCTION 'GUI_DOWNLOAD'
     EXPORTING
       FILENAME                = P_FILE
       FILETYPE                = 'ASC'
       WRITE_FIELD_SEPARATOR   = 'X'
       CONFIRM_OVERWRITE       = 'X'
       SHOW_TRANSFER_STATUS    = 'X'
     TABLES
       DATA_TAB                = TA_EXCEL
       FIELDNAMES              = INT_HEAD
     EXCEPTIONS
       FILE_WRITE_ERROR        = 1
       NO_BATCH                = 2
       GUI_REFUSE_FILETRANSFER = 3
       INVALID_TYPE            = 4
       NO_AUTHORITY            = 5
       UNKNOWN_ERROR           = 6
       HEADER_NOT_ALLOWED      = 7
       SEPARATOR_NOT_ALLOWED   = 8
       FILESIZE_NOT_ALLOWED    = 9
       HEADER_TOO_LONG         = 10
       DP_ERROR_CREATE         = 11
       DP_ERROR_SEND           = 12
       DP_ERROR_WRITE          = 13
       UNKNOWN_DP_ERROR        = 14
       ACCESS_DENIED           = 15
       DP_OUT_OF_MEMORY        = 16
       DISK_FULL               = 17
       DP_TIMEOUT              = 18
       FILE_NOT_FOUND          = 19
       DATAPROVIDER_EXCEPTION  = 20
       CONTROL_FLUSH_ERROR     = 21
       OTHERS                  = 22.

   IF SY-SUBRC <> 0.
     MESSAGE I003.
     RETURN.
   ENDIF.
   CLEAR : OK_CODE.
 ENDFORM.                    " F_EXPORT

*&---------------------------------------------------------------------*
*&      Form  F_IMPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_IMPORT .
   DATA: FNAME TYPE STRING,
         FPATH TYPE IBIPPARMS-PATH,
         MATNR_GR TYPE MSEG-MATNR,
         MENGE_GR TYPE MSEG-MENGE,
         CHARGID  TYPE MSEG-CHARG.

   CALL FUNCTION 'F4_FILENAME'
     EXPORTING
       PROGRAM_NAME  = SY-CPROG
       DYNPRO_NUMBER = SY-DYNNR
       FIELD_NAME    = ' '
     IMPORTING
       FILE_NAME     = FPATH.


   CALL FUNCTION 'GUI_UPLOAD'
     EXPORTING
       FILENAME            = FNAME
       FILETYPE            = 'ASC'
       HAS_FIELD_SEPARATOR = 'X'
     TABLES
       DATA_TAB            = TA_EXCEL.
   IF SY-SUBRC NE 0.
     CLEAR : OK_CODE.
     MESSAGE I004.
     RETURN.
   ENDIF.


   DELETE TA_EXCEL INDEX 1.
   DELETE TA_EXCEL WHERE AUFNRID = ''.
   SORT TA_EXCEL BY AUFNRID CHARGID.

   TA_ITEM[] = T_CEKLIST[].
   SORT TA_ITEM BY AUFNRID CHARGID.
   DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNRID CHARGID.

   LOOP AT TA_ITEM INTO WA_ITEM .
     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
       EXPORTING
         INPUT  = WA_ITEM-CHARGID
       IMPORTING
         OUTPUT = CHARGID.

*1)  cek no order sama batch jumbo roll yang di upload =  di table control
     READ TABLE TA_EXCEL INTO WA_EXCEL WITH KEY  AUFNRID = WA_ITEM-AUFNRID
                                                CHARGID = WA_ITEM-CHARGID . "CHARGID.
     "- ga ada delete aja
     IF SY-SUBRC NE 0.
       DELETE T_CEKLIST WHERE AUFNRID = WA_ITEM-AUFNRID AND  CHARGID = WA_ITEM-CHARGID.
       EXIT.
     ENDIF.

*2)   kalo ada delete di list tabele control ambil data yang penting buat output format
     READ TABLE T_CEKLIST INTO W_CEKLIST WITH KEY AUFNR = WA_ITEM-AUFNRID
                                                  CHARG_JR = WA_ITEM-CHARGID.
     MATNR_GR         = W_CEKLIST-MATNR.
     MENGE_GR         = W_CEKLIST-MENGE_GR.
     BKTXTID          = W_CEKLIST-BKTXTID.
     WERKS            = W_CEKLIST-WERKS.
     ZZLINE           = W_CEKLIST-ZZLINE.
     ZZCODE           = W_CEKLIST-ZZCODE.
     ZZLENGTH         = W_CEKLIST-ZZLENGTH.
     ZZWIDTH          = W_CEKLIST-ZZWIDTH.
     ZZCOATING_WEIGHT = W_CEKLIST-ZZCOATING_WEIGHT.

     DELETE T_CEKLIST WHERE AUFNRID = WA_ITEM-AUFNR AND  CHARGID = WA_ITEM-CHARGID.

*3)   isi dengan data upload dan output sesuai format
     NUM = 0.
     LOOP AT TA_EXCEL INTO WA_EXCEL WHERE AUFNRID = WA_ITEM-AUFNRID  "=> excel
                                     AND  CHARGID = WA_ITEM-CHARGID. "CHARGID.
       REPLACE ALL OCCURRENCES OF ',' IN WA_EXCEL-MENGE_GR WITH '.'.
       REPLACE ALL OCCURRENCES OF ',' IN WA_EXCEL-MENGE_A WITH '.'.
       NUM =  NUM + 1.
       MOVE-CORRESPONDING WA_EXCEL TO W_CEKLIST.
       IF NUM = 1.
         W_CEKLIST-AUFNR    = WA_ITEM-AUFNRID.
         W_CEKLIST-CHARG_JR = WA_ITEM-CHARGID.
         W_CEKLIST-MENGE_GR = MENGE_GR.
         W_CEKLIST-MATNR    = MATNR_GR.
       ELSE.
         CLEAR : W_CEKLIST-AUFNR, W_CEKLIST-CHARG_JR, W_CEKLIST-MENGE_GR,
                 W_CEKLIST-MATNR.
       ENDIF.
       W_CEKLIST-WERKS            = WERKS.
       W_CEKLIST-BKTXT_JR         = W_CEKLIST-BKTXTID = BKTXTID.
       W_CEKLIST-FLAG             = 'O'.
       W_CEKLIST-ZZLINE           = ZZLINE.
       W_CEKLIST-ZZCODE           = ZZCODE.
       W_CEKLIST-ZZLENGTH         = ZZLENGTH.
       W_CEKLIST-ZZWIDTH          = ZZWIDTH.
       W_CEKLIST-ZZCOATING_WEIGHT = ZZCOATING_WEIGHT.

*       PERFORM CEK_RAWMAT USING W_CEKLIST-MATNR_A WERKS WA_ITEM-AUFNRID BKTXTID
*                 CHANGING W_CEKLIST-LGORT_A MENGE  W_CEKLIST-CHARG_A  ERRNO.
*       IF MENGE = 0. "-> ga ada stock
*         W_CEKLIST-MENGE_A = 0.
*       ENDIF.
       PERFORM GET_MAKTX USING W_CEKLIST-MATNR_A CHANGING W_CEKLIST-MAKTX_A ERRNO.

       APPEND W_CEKLIST TO T_CEKLIST.
     ENDLOOP.  "=> excel

   ENDLOOP.




   CLEAR : OK_CODE.
 ENDFORM .                    " F_IMPORT
 " CLICK  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_ADD_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_ADD_FIELD .
   CHECK CODE = 'P'.

   IF COUNT_CLICK = 1.
     TA_ORI[] = T_CEKLIST[].
     DELETE T_CEKLIST WHERE CHARGID NE CHARGID.
     DELETE T_CEKLIST WHERE AUFNRID NE AUFNRID.

     DESCRIBE TABLE T_CEKLIST LINES LINE.
     IF LINE = 0.
       T_CEKLIST[] = TA_ORI[].
       CLEAR : OK_CODE,TA_ORI.
       MESSAGE I001.
       RETURN.
     ENDIF.
   ENDIF.

*   DO LINE TIMES.
   CLEAR : W_CEKLIST.
   W_CEKLIST-AUFNRID = AUFNRID.
   W_CEKLIST-CHARGID = CHARGID.
   W_CEKLIST-BKTXTID = BKTXTID.
   APPEND W_CEKLIST TO T_CEKLIST.
*   ENDDO.
 ENDFORM.                    " F_ADD_FIELD
*&---------------------------------------------------------------------*
*&      Module  KLIK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE KLIK INPUT.
   OK_CODE = SY-UCOMM.
   IF OK_CODE = 'PICK'.
     GET CURSOR FIELD W_CEKLIST-AUFNR LINE TC1-CURRENT_LINE.
     READ TABLE T_CEKLIST INTO W_CEKLIST INDEX TC1-CURRENT_LINE.
     COUNT_CLICK      = COUNT_CLICK + 1.
     AUFNRID          = W_CEKLIST-AUFNRID.
     CHARGID          = W_CEKLIST-CHARGID.
     BKTXTID          = W_CEKLIST-BKTXTID.
     WERKS            = W_CEKLIST-WERKS.
     ZZCODE           = W_CEKLIST-ZZCODE.
     ZZLINE           = W_CEKLIST-ZZLINE.
     ZZLENGTH         = W_CEKLIST-ZZLENGTH.
     ZZWIDTH          = W_CEKLIST-ZZWIDTH.
     ZZCOATING_WEIGHT = W_CEKLIST-ZZCOATING_WEIGHT.
     CODE = 'P'.
   ENDIF.
 ENDMODULE.                 " KLIK  INPUT
*&---------------------------------------------------------------------*
*&      Form  INSERT_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INSERT_LINE .

   DELETE T_CEKLIST WHERE MATNR_A = V_NO.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR              = 'Konfirmasi'
       TEXT_QUESTION         = 'Ubah Data ?'
       TEXT_BUTTON_1         = 'Ya'
       TEXT_BUTTON_2         = 'Tidak'
       DEFAULT_BUTTON        = '1'
       DISPLAY_CANCEL_BUTTON = 'X'
     IMPORTING
       ANSWER                = P_ANSWER.

   IF P_ANSWER EQ '1'.
     PERFORM F_NEW_LIST.
     CLEAR : AUFNRID,CHARGID,BKTXTID,TA_ORI,WA_ORI,CODE,WERKS,ERRNO,BKTXTID,MENGE,CHARG,
             COUNT_CLICK.
   ELSEIF P_ANSWER  EQ '2'.
     T_CEKLIST[] = TA_ORI[].
     CLEAR : AUFNRID,CHARGID,BKTXTID,TA_ORI,WA_ORI,CODE,WERKS,ERRNO,BKTXTID,MENGE,CHARG,
             COUNT_CLICK.
   ENDIF.

 ENDFORM.                    " INSERT_LINE
*&---------------------------------------------------------------------*
*&      Module  CEK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CEK_MATNR INPUT.
   IF W_CEKLIST-FLAG NE 'O'.  "=> inputan baru
     "- material mau di hapus ?
     IF W_CEKLIST-MATNR_A = '' AND W_CEKLIST-MAKTX_A NE ''.
       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           TITLEBAR              = 'Konfirmasi'
           TEXT_QUESTION         = 'Hapus Material ?'
           TEXT_BUTTON_1         = 'Ya'
           TEXT_BUTTON_2         = 'Tidak'
           DEFAULT_BUTTON        = '1'
           DISPLAY_CANCEL_BUTTON = ''
         IMPORTING
           ANSWER                = P_ANSWER.
       IF P_ANSWER = 1.
         CLEAR : W_CEKLIST.
         RETURN.
       ENDIF.
     ENDIF.

     PERFORM GET_MAKTX USING W_CEKLIST-MATNR_A CHANGING W_CEKLIST-MAKTX_A ERRNO.
     IF ERRNO NE 0.
       MESSAGE E005 WITH 'Material'.
     ENDIF.

     READ TABLE T_CEKLIST INTO W_CEKLIST WITH KEY MATNR_A = W_CEKLIST-MATNR_A.
     IF SY-SUBRC = 0.
       MESSAGE I006 WITH 'Material'.
       CLEAR : W_CEKLIST.
     ELSE.
       W_CEKLIST-AUFNRID          = AUFNRID.
       W_CEKLIST-CHARGID          = CHARGID.
       W_CEKLIST-BKTXTID          = BKTXTID.
       W_CEKLIST-FLAG             = 'N'.
       W_CEKLIST-ZZCODE           = ZZCODE.
       W_CEKLIST-ZZLINE           = ZZLINE.
       W_CEKLIST-ZZLENGTH         = ZZLENGTH.
       W_CEKLIST-ZZWIDTH          = ZZWIDTH.
       W_CEKLIST-ZZCOATING_WEIGHT = ZZCOATING_WEIGHT.

       PERFORM CEK_RAWMAT USING W_CEKLIST-MATNR_A WERKS AUFNRID BKTXTID
                 CHANGING W_CEKLIST-LGORT_A MENGE  CHARG  ERRNO.
       IF MENGE = 0.
         MESSAGE I005(OK) WITH 'Material'.
         CLEAR : W_CEKLIST.
       ENDIF.


     ENDIF.


   ELSE. "=> inputan lama.

     W_CEKLIST-FLAG = 'O'.
     IF W_CEKLIST-MATNR_A = V_NO.
       MESSAGE W007(OK) WITH 'Material'.
       READ TABLE T_CEKLIST INTO W_CEKLIST INDEX TC1-CURRENT_LINE.
     ENDIF.

   ENDIF.

 ENDMODULE.                 " CEK_MATNR  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_NEW_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_NEW_LIST .
   DATA : MATNR_GR TYPE MSEG-MATNR,
          MENGE_GR TYPE MSEG-MENGE.

   DELETE T_CEKLIST WHERE MATNR_A EQ V_NO.
   READ TABLE TA_ORI INTO WA_ORI WITH KEY AUFNR  = AUFNRID
                                        CHARG_JR = CHARGID.
   MATNR_GR = WA_ORI-MATNR.
   MENGE_GR = WA_ORI-MENGE_GR.

   DELETE TA_ORI WHERE AUFNRID = AUFNRID AND CHARGID = CHARGID.

* gabungin data yang di change sama material baru
   LOOP AT T_CEKLIST INTO W_CEKLIST.
     MOVE-CORRESPONDING W_CEKLIST TO WA_ORI.
     IF SY-TABIX = 1.
       WA_ORI-AUFNR    = W_CEKLIST-AUFNRID.
       WA_ORI-CHARG_JR = W_CEKLIST-CHARGID.
       WA_ORI-BKTXT_JR = WA_ORI-BKTXTID = BKTXTID.
     ELSE.
       CLEAR : WA_ORI-AUFNR, WA_ORI-AUFNR, WA_ORI-CHARG_JR, WA_ORI-MENGE_GR.
     ENDIF.

     APPEND WA_ORI TO TA_ORI.
   ENDLOOP.

   T_CEKLIST[] = TA_ORI[].

 ENDFORM.                    " F_NEW_LIST
*&---------------------------------------------------------------------*
*&      Form  F_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_SAVE .
   DATA: IT_RET LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
         TA_GOODSMVT_HEADER TYPE BAPI2017_GM_HEAD_01 OCCURS 1 WITH HEADER LINE,
         TA_GOODSMVT_CODE TYPE BAPI2017_GM_CODE OCCURS 1 WITH HEADER LINE,
         TA_GOODSMVT_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         WA_GOODSMVT_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

   DATA: GOODSMVT_HEADRET TYPE BAPI2017_GM_HEAD_RET,
         MATERIALDOCUMENT TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.

   DATA : Z531 TYPE ST_531 OCCURS 0 WITH HEADER LINE.

   DATA : SELISIH     TYPE MENGE_D,
          TOT_QTY_ACT TYPE MENGE_D,
          TOT_QTY_ACT2 TYPE MENGE_D,
          TOT_QTY_NONBATCH TYPE MENGE_D,
          LENGTH      TYPE MENGE_D,
          WIDTH       TYPE MENGE_D,
          COATING1    TYPE STRING,
          COATING2    TYPE STRING,
          COATING     TYPE MENGE_D,
          QTY_COATING TYPE MENGE_D,
          V_AUART     TYPE AUFK-AUART,
          SGTXT       TYPE MSEG-SGTXT,
          TEXT_QUESTION TYPE STRING.

   DATA : TQTY TYPE STRING.

   IF LOCATION NE ''.
     MOVE QTY_JR TO TQTY.
     CONCATENATE 'Akan melakukan goods issue Jumbo Roll Sebanyak' TQTY
                 'Menggunakan File' LOCATION INTO TEXT_QUESTION SEPARATED BY SPACE.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR              = 'Konfirmasi'
         TEXT_QUESTION         = TEXT_QUESTION
         TEXT_BUTTON_1         = 'Ya'
         TEXT_BUTTON_2         = 'Tidak'
         DEFAULT_BUTTON        = '1'
         DISPLAY_CANCEL_BUTTON = ''
       IMPORTING
         ANSWER                = P_ANSWER.

     CHECK P_ANSWER EQ 1.
   ENDIF.

   CLEAR : TA_MESSAGE, WA_MESSAGE, TA_ERROR, WA_ERROR,ERRNO,LOCATION,CODE,QTY_JR,
           T_BACK,Z531.
   REFRESH : TA_MESSAGE,TA_ERROR,T_BACK,Z531.

** cancel dulu raw mat yang udah di gi
   TA_ORI[] = TA_ITEM[] = T_CEKLIST[].
   DELETE T_CEKLIST WHERE MENGE_A  = 0.
   IF T_CEKLIST IS INITIAL.
     T_CEKLIST[] = TA_ITEM[].
     MESSAGE I000(OK) WITH 'Tidak ada Data yang di GI / Qty 0 semua'.
     RETURN.
   ENDIF.

   DESCRIBE TABLE T_CANCEL LINES LINE.
   IF LINE > 0.
     PERFORM F_CANCEL_MATDOC CHANGING ERRNO.
*     PERFORM F_CANCEL_MIGO CHANGING ERRNO.
     ERRNO = 0. "-> ref1
   ENDIF.


   IF ERRNO NE 1.  "-> kalo gagal cancel langsung keluar
     ITAB[] = TA_ITEM[] =  T_CEKLIST[].

     SORT ITAB BY AUFNRID CHARGID.
     DELETE ADJACENT DUPLICATES FROM ITAB COMPARING AUFNRID CHARGID.

     DESCRIBE TABLE ITAB LINES LINE.
     NUM = 0.
     LOOP AT ITAB.
       NUM =  NUM + 1.
       CLEAR : TA_GOODSMVT_HEADER,TA_GOODSMVT_CODE,TA_GOODSMVT_ITEM,
               WA_GOODSMVT_ITEM,IT_RET,SELISIH,LENGTH,WIDTH,COATING1,COATING2,
               COATING, QTY_COATING,V_AUART.
       REFRESH : TA_GOODSMVT_HEADER,TA_GOODSMVT_CODE,TA_GOODSMVT_ITEM.

*       PERFORM F_CANCEL_562 USING ITAB-AUFNRID ITAB-BKTXTID ITAB-CHARGID ITAB-WERKS CHANGING ERRNO.  "-> new req
*       CHECK ERRNO NE '2'.

       "->
       CLEAR : ERRNO.
       READ TABLE T_CANCEL WITH KEY AUFNR = ITAB-AUFNRID
                                    CHARG = ITAB-CHARGID
                                    FLAG  = 'X'.
       IF SY-SUBRC = 0.
         WA_MESSAGE-MSGID = 'ZMM'.
         WA_MESSAGE-MSGTY = 'E' .
         WA_MESSAGE-MSGNO = '002'.
         CONCATENATE 'Order.' ITAB-AUFNRID 'Jumbo Roll' ITAB-CHARGID
                      INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

         CONCATENATE ITAB-MATNR 'gagal di Cancel 262 / 532 / 312' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
         WA_MESSAGE-MSGV4 = WA_MESSAGE-MSGV3 = SPACE.
         APPEND WA_MESSAGE TO TA_MESSAGE.
         ERRNO = '1'.
       ENDIF.

       CHECK ERRNO = '0'.

       V_PERCENT  = ( SY-TABIX / LINE ) * 100.
       CONCATENATE 'Proses Gi 261 roll ' ITAB-CHARGID 'Order' ITAB-AUFNRID
                    INTO VTEXT SEPARATED BY SPACE.
       CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
           PERCENTAGE = V_PERCENT
           TEXT       = VTEXT.

       SELECT SINGLE AUART INTO V_AUART
         FROM AUFK
         WHERE AUFNR = ITAB-AUFNRID.

       TA_GOODSMVT_HEADER-HEADER_TXT     = ITAB-BKTXTID.
       TA_GOODSMVT_HEADER-PSTNG_DATE     = SY-DATUM.
       TA_GOODSMVT_HEADER-DOC_DATE       = SY-DATUM.
       TA_GOODSMVT_HEADER-GR_GI_SLIP_NO  = ITAB-BKTXTID.
       TA_GOODSMVT_CODE-GM_CODE          = '03'.

       "-> cari p x l x w / 1 jeti
       REPLACE ALL OCCURRENCES OF ',' IN ITAB-ZZLENGTH  WITH ''.
       MOVE ITAB-ZZLENGTH TO ZZLENGTH.
       REPLACE ALL OCCURRENCES OF ',' IN ITAB-ZZWIDTH  WITH ''.
       MOVE ITAB-ZZWIDTH TO WIDTH.
       SPLIT ITAB-ZZCOATING_WEIGHT AT '' INTO COATING1 COATING2.
       REPLACE ALL OCCURRENCES OF ',' IN COATING1  WITH ''.
       MOVE COATING1 TO COATING.
       QTY_COATING = ( ZZLENGTH * WIDTH * COATING ) / 1000000.

       TOT_QTY_ACT2 = TOT_QTY_NONBATCH = TOT_QTY_ACT = 0.
       LOOP AT TA_ITEM INTO WA_ITEM WHERE AUFNRID = ITAB-AUFNRID
                                    AND   CHARGID = ITAB-CHARGID.

         "-> 18 jan 2013
         PERFORM GET_BWART_ALL USING ITAB-AUFNRID  CHANGING BWART1 BWART2.

         CLEAR : SGTXT,MBLNR.
         IF WA_ITEM-MATKL+0(1) = '3'.
           SELECT MBLNR SGTXT INTO (SGTXT,MBLNR)
             FROM MSEG
             WHERE AUFNR = WA_ITEM-AUFNRID
             AND   CHARG = WA_ITEM-CHARGID
             AND   MATNR = WA_ITEM-MATNR_A
             AND   BWART = BWART1 " '261'
             ORDER BY MBLNR ASCENDING.
*             %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.
           ENDSELECT.
         ENDIF.

         "-> Total qty actual gi 261
         TOT_QTY_ACT  = TOT_QTY_ACT + WA_ITEM-MENGE_A.
         "-> total qty actual gi 261 non batch
         IF WA_ITEM-CHARG_A = ''.
           TOT_QTY_NONBATCH = TOT_QTY_NONBATCH + WA_ITEM-MENGE_A.
         ENDIF.

         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
             INPUT  = WA_ITEM-CHARG_A
           IMPORTING
             OUTPUT = WA_ITEM-CHARG_A.

         TRANSLATE WA_ITEM-MATNR_A TO UPPER CASE.

*         CASE V_AUART.
*           WHEN 'ZTR1' OR 'ZTR2' OR 'ZTR3' OR 'ZTR4' OR 'ZTR5' OR 'ZTR6'.
*             WA_GOODSMVT_ITEM-MOVE_TYPE   = '901'.
*           WHEN OTHERS.
         WA_GOODSMVT_ITEM-MOVE_TYPE   =  BWART1. "'261'.
*         ENDCASE.

         WA_GOODSMVT_ITEM-PLANT         = ITAB-WERKS.
         WA_GOODSMVT_ITEM-BATCH         = WA_ITEM-CHARG_A.
         WA_GOODSMVT_ITEM-MATERIAL      = WA_ITEM-MATNR_A.
         WA_GOODSMVT_ITEM-STGE_LOC      = WA_ITEM-LGORT_A.
         WA_GOODSMVT_ITEM-ORDERID       = WA_ITEM-AUFNRID.
         WA_GOODSMVT_ITEM-ENTRY_QNT     = WA_ITEM-MENGE_A.
         WA_GOODSMVT_ITEM-ENTRY_UOM     = WA_ITEM-MEINS.
*         WA_GOODSMVT_ITEM-ITEM_TEXT    = SGTXT.
         PERFORM F_GET_MATGROUP USING WA_ITEM-MATNR_A CHANGING MATKL CEK.
         IF CEK = ''.
           APPEND WA_GOODSMVT_ITEM TO TA_GOODSMVT_ITEM.
           TOT_QTY_ACT2  = TOT_QTY_ACT2 + WA_ITEM-MENGE_A.

*-- Added for Exlam by Fathir on 01.04.2019 - Reducing Qty of Mixing Material for Exlam Order Type ONLY
           IF V_AUART = 'ZP12' OR V_AUART = 'ZTR7'.
             SELECT SINGLE MTART INTO V_MTART
             FROM MARA
             WHERE MATNR = WA_ITEM-MATNR_A
               AND MTART = 'ZRAW'.

             IF SY-SUBRC NE 0.
               TOT_QTY_ACT2 = TOT_QTY_ACT2 - WA_ITEM-MENGE_A.
             ENDIF.
           ENDIF.
*-- Added for Exlam by Fathir on 01.04.2019 - Reducing Qty of Mixing Material for Exlam Order Type ONLY

         ENDIF.
       ENDLOOP.

       IF COATING < 0.
         COATING = 0.
       ENDIF.

       IF COATING = 0.
         SELISIH =  TOT_QTY_ACT - ITAB-MENGE_GR.
       ELSE.
         SELISIH = ( TOT_QTY_ACT - ITAB-MENGE_GR ) - ( TOT_QTY_NONBATCH - QTY_COATING ).
       ENDIF.

       "- create 531
*       IF ( V_AUART = 'ZP03' OR V_AUART = 'ZP04' OR V_AUART = 'ZP05' OR V_AUART = 'ZP06'
*          OR V_AUART = 'ZP07' OR V_AUART = 'ZP08' OR V_AUART = 'ZP09' ) .
       IF ( V_AUART = 'ZP07' OR V_AUART = 'ZP08' OR V_AUART  = 'ZTR4'
            OR V_AUART  = 'ZP12' OR V_AUART  = 'ZTR7').     "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
         PERFORM F_GET_531 USING '1' ITAB-ZZLINE ITAB-WERKS ITAB-ZZCODE ITAB-AUFNRID ITAB-BKTXTID
          CHANGING Z531.

         IF Z531-MATNR = ''.
           WA_MESSAGE-MSGID = 'ZMM'.
           WA_MESSAGE-MSGTY = 'E' .
           WA_MESSAGE-MSGNO = '018'.
           CONCATENATE 'Order.' ITAB-AUFNR 'Jumbo Roll' ITAB-CHARGID
                       'Tidak ada Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
           WA_MESSAGE-MSGV2 = 'Kemungkinan belum di maintain'.
           WA_MESSAGE-MSGV3 = 'di table material rr / karakteristik batch'.
           WA_MESSAGE-MSGV4 = SPACE.
           APPEND WA_MESSAGE TO TA_MESSAGE.
           RETURN.
         ENDIF.

         CLEAR : SELISIH.
         SELISIH = Z531-QTY2  + TOT_QTY_ACT2  - Z531-QTY1.
         IF SELISIH < 0.
           SELISIH = 0.
         ENDIF.

         WA_GOODSMVT_ITEM-MOVE_TYPE   = '531'.
         WA_GOODSMVT_ITEM-BATCH       = Z531-CHARG.
         WA_GOODSMVT_ITEM-PLANT       = Z531-WERKS.
         WA_GOODSMVT_ITEM-MATERIAL    = Z531-MATNR.
         WA_GOODSMVT_ITEM-STGE_LOC    = Z531-LGORT.
         WA_GOODSMVT_ITEM-ORDERID     = Z531-AUFNR.
         WA_GOODSMVT_ITEM-ENTRY_QNT   = SELISIH.
         WA_GOODSMVT_ITEM-ENTRY_UOM   = WA_ITEM-MEINS.
         IF SELISIH > 0 .
           APPEND WA_GOODSMVT_ITEM TO TA_GOODSMVT_ITEM.
         ENDIF.

       ELSEIF ( V_AUART = 'ZP01' OR V_AUART = 'ZP02' OR V_AUART = 'ZP10' OR V_AUART = 'ZP11'
                OR V_AUART = 'ZTR1' OR V_AUART = 'ZTR3'
                " Added by William at 24.07.2022 (OPP7 CPP1)
                OR V_AUART = 'ZP13' OR V_AUART = 'ZP15' OR V_AUART = 'ZP17'
                OR V_AUART = 'ZTR8' OR V_AUART = 'ZTR9' OR V_AUART = 'ZTRA' OR V_AUART = 'ZTRB' OR V_AUART = 'ZTRC' ).
                " End added by William at 24.07.2022 (OPP7 CPP1)
         PERFORM F_GET_531 USING '2' ITAB-ZZLINE ITAB-WERKS ITAB-ZZCODE ITAB-AUFNRID ''
          CHANGING Z531.
         IF Z531-MATNR = ''.
           WA_MESSAGE-MSGID = 'ZMM'.
           WA_MESSAGE-MSGTY = 'E' .
           WA_MESSAGE-MSGNO = '018'.
           CONCATENATE 'Order.' ITAB-AUFNR 'Jumbo Roll' ITAB-CHARGID
                       'Tidak ada Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
           WA_MESSAGE-MSGV2 = 'Kemungkinan belum di maintain'.
           WA_MESSAGE-MSGV3 = 'di table material rr / karakteristik batch'.
           WA_MESSAGE-MSGV4 = SPACE.
           APPEND WA_MESSAGE TO TA_MESSAGE.
           RETURN.
         ENDIF.


         CLEAR : SELISIH.
         SELISIH = TOT_QTY_ACT2  - ITAB-MENGE_GR.
         IF SELISIH < 0.
           SELISIH = 0.
         ENDIF.

         WA_GOODSMVT_ITEM-MOVE_TYPE   = '531'.
         WA_GOODSMVT_ITEM-BATCH       = Z531-CHARG.
         WA_GOODSMVT_ITEM-PLANT       = Z531-WERKS.
         WA_GOODSMVT_ITEM-MATERIAL    = Z531-MATNR.
         WA_GOODSMVT_ITEM-STGE_LOC    = Z531-LGORT.
         WA_GOODSMVT_ITEM-ORDERID     = Z531-AUFNR.
         WA_GOODSMVT_ITEM-ENTRY_QNT   = SELISIH.
         WA_GOODSMVT_ITEM-ENTRY_UOM   = WA_ITEM-MEINS.
*         WA_GOODSMVT_ITEM-ITEM_TEXT   = SGTXT.
         IF SELISIH > 0.
           APPEND WA_GOODSMVT_ITEM TO TA_GOODSMVT_ITEM.
         ENDIF.

       ENDIF. "- v_auart
       "-> end 531

       CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
         EXPORTING
           GOODSMVT_HEADER  = TA_GOODSMVT_HEADER
           GOODSMVT_CODE    = TA_GOODSMVT_CODE
         IMPORTING
           GOODSMVT_HEADRET = GOODSMVT_HEADRET
           MATERIALDOCUMENT = MATERIALDOCUMENT
         TABLES
           GOODSMVT_ITEM    = TA_GOODSMVT_ITEM
           RETURN           = IT_RET.

       IF MATERIALDOCUMENT NE V_NO.
         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT = V_YES.

         WA_MESSAGE-MSGID = 'ZMM'.
         WA_MESSAGE-MSGTY = 'S' .
         WA_MESSAGE-MSGNO = '002'.
         CONCATENATE 'Order.' ITAB-AUFNRID 'Jumbo Roll' ITAB-CHARGID
                      INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
         CONCATENATE 'MatDoc' MATERIALDOCUMENT INTO WA_MESSAGE-MSGV2
                     SEPARATED BY SPACE.
         WA_MESSAGE-MSGV4 = WA_MESSAGE-MSGV3 = SPACE.
         APPEND WA_MESSAGE TO TA_MESSAGE.

         "-> prcess raw recycle 311 aja
*         IF ( V_AUART = 'ZP03' OR V_AUART = 'ZP04' OR V_AUART = 'ZP05' OR V_AUART = 'ZP06'
*            OR V_AUART = 'ZP07' OR V_AUART = 'ZP08' OR V_AUART = 'ZP09' ) .
*           PERFORM F_CANCEL_MAT_RR USING ITAB-ZZCODE ITAB-ZZLINE ITAB-BKTXTID
*                 ITAB-AUFNRID NUM SELISIH ITAB-WERKS ITAB-CHARGID '2' CHANGING ERRNO.

         IF ( V_AUART = 'ZP01' OR V_AUART = 'ZP02' OR V_AUART = 'ZP10' OR V_AUART = 'ZP11' OR V_AUART = 'ZP07' OR V_AUART = 'ZP08'
                  OR V_AUART = 'ZTR1' OR V_AUART = 'ZTR3' OR V_AUART = 'ZTR4'
                  OR V_AUART = 'ZP12' OR V_AUART = 'ZTR7'       "ADDED EXLAM 21.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                  " Added by William at 24.07.2022 (OPP7 CPP1)
                  OR V_AUART = 'ZP13' OR V_AUART = 'ZP15' OR V_AUART = 'ZP17'
                  OR V_AUART = 'ZTR8' OR V_AUART = 'ZTR9' OR V_AUART = 'ZTRA' OR V_AUART = 'ZTRB' OR V_AUART = 'ZTRC' ).
                  " End added by William at 24.07.2022 (OPP7 CPP1)
           IF SELISIH > 0.
             PERFORM F_CANCEL_MAT_RR USING ITAB-ZZCODE ITAB-ZZLINE ITAB-BKTXTID
                   ITAB-AUFNRID NUM SELISIH ITAB-WERKS ITAB-CHARGID '2' CHANGING ERRNO.
           ENDIF.
         ENDIF.


       ELSE.

         PERFORM F_CANCEL_MATDOC_3 USING ITAB-BKTXTID ITAB-AUFNRID.

         WA_MESSAGE-MSGID = 'ZMM'.
         WA_MESSAGE-MSGTY = 'E' .
         WA_MESSAGE-MSGNO = '002'.
         CONCATENATE 'Order.' ITAB-AUFNRID 'Jumbo Roll' ITAB-CHARGID
                      INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

         CONCATENATE ITAB-MATNR 'gagal di GI' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
         WA_MESSAGE-MSGV4 = WA_MESSAGE-MSGV3 = SPACE.
         APPEND WA_MESSAGE TO TA_MESSAGE.


       ENDIF.

       LOOP AT IT_RET.
         WA_ERROR-MSGID    = IT_RET-ID.
         WA_ERROR-MSGTY    = IT_RET-TYPE .
         WA_ERROR-MSGNO    = IT_RET-NUMBER.
         WA_ERROR-MSGV1    = IT_RET-MESSAGE_V1.
         WA_ERROR-MSGV2    = IT_RET-MESSAGE_V2.
         WA_ERROR-MSGV3    = IT_RET-MESSAGE_V3.
         WA_ERROR-MSGV4    = IT_RET-MESSAGE_V4.
         WA_MESSAGE-LINENO = SY-TABIX.
         APPEND WA_ERROR TO TA_ERROR.
       ENDLOOP.

     ENDLOOP.

   ENDIF. "-> errno ne 1

   IF ITAB[] IS NOT INITIAL AND TA_ERROR[] IS INITIAL.
     PERFORM INSERT_SQL.
   ENDIF.

   IF TA_MESSAGE[] IS NOT INITIAL.
     CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
       TABLES
         I_MESSAGE_TAB = TA_MESSAGE.
   ENDIF.

   IF TA_ERROR[] IS NOT INITIAL.
     CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
       TABLES
         I_MESSAGE_TAB = TA_ERROR.
   ENDIF.

** display data yang udah di gi &  gr
   PERFORM F_DISPLAY.
*   SUBMIT  ZPPI_CHANGE_BOM_PO VIA SELECTION-SCREEN.
 ENDFORM.                    " F_SAVE
*&---------------------------------------------------------------------*
*&      Form  CEK_RAWMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MATNR  text
*      -->P_WERKS  text
*      <--P_LGORT  text
*      <--P_LABST  text
*      <--P_CHARG  text
*----------------------------------------------------------------------*
 FORM CEK_RAWMAT  USING    P_MATNR
                           P_WERKS
                           P_AUFNR
                           P_BKTXT
                  CHANGING P_LGORT
                           P_LABST
                           P_CHARG
                           P_ERRNO.

   CLEAR : P_LGORT, P_LABST, P_CHARG ,P_ERRNO,MBLNR,MJAHR, ZEILE.

*  cek sloc sama stock
   SELECT LGORT LABST INTO (P_LGORT,P_LABST)
     FROM MARD
     WHERE MATNR = P_MATNR
     AND   WERKS = P_WERKS
     AND   LABST NE 0.
   ENDSELECT.

   CHECK CODE NE 'P'.
   SELECT SINGLE CHARG INTO P_CHARG
     FROM MCHB
     WHERE MATNR = P_MATNR
     AND   WERKS = P_WERKS
     AND   LGORT = P_LGORT.

* cek udah di gi apa belom
   SELECT MSEG~MBLNR MSEG~MJAHR MSEG~ZEILE  INTO (MBLNR,MJAHR,ZEILE)
     FROM MKPF
     JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR
     WHERE MSEG~AUFNR = P_AUFNR
     AND   MKPF~BKTXT = P_BKTXT
     AND   MSEG~MBLNR = MBLNR
     AND   MSEG~BWART = '261'
  ORDER BY MSEG~MBLNR ASCENDING.
*   %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.
   ENDSELECT.
   IF SY-SUBRC NE 0.
     SY-SUBRC = 1. " belom di gi

   ELSE.

     SELECT SINGLE ZEILE INTO ZEILE
       FROM MSEG
       WHERE SMBLN = MBLNR
       AND   SJAHR = MJAHR
       AND   SMBLP = ZEILE
       AND   BWART = '262'.
*       %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
     IF SY-SUBRC NE 0.
       P_ERRNO = 2 . " udah di gi
       T_CANCEL-MBLNR = MBLNR.
       T_CANCEL-MJAHR = MJAHR.
       APPEND T_CANCEL.
     ENDIF.

   ENDIF.

 ENDFORM.                    " CEK_RAWMAT
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_MATDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_CANCEL_MATDOC CHANGING P_ERRNO.
   DATA : MATDOC TYPE BAPI2017_GM_HEAD_02-MAT_DOC,
          YEAR   TYPE BAPI2017_GM_HEAD_02-DOC_YEAR,
          LI_RETURN   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
          LWA_HEADRET TYPE BAPI2017_GM_HEAD_RET,
          LWA_RETURN  TYPE BAPIRET2.
   DATA : RESULT TYPE MSEG-MBLNR,
          AUART TYPE AUFK-AUART.

   SORT T_CANCEL BY CHARG.
   DELETE ADJACENT DUPLICATES FROM T_CANCEL COMPARING CHARG.

   DESCRIBE TABLE T_CANCEL LINES LINE.
   LOOP AT T_CANCEL.
     CLEAR : AUART.
     SELECT SINGLE AUART INTO AUART
       FROM AUFK
       WHERE AUFNR = T_CANCEL-AUFNR.

*  REF1
*     PERFORM F_CANCEL_MAT_RR USING T_CANCEL-ZZCODE T_CANCEL-ZZLINE T_CANCEL-BKTXT
*           T_CANCEL-AUFNR '' '' T_CANCEL-WERKS T_CANCEL-CHARG '1' CHANGING ERRNO.

     "-> cancel 312 rawrec material via cancel matdoc.
     IF ( AUART = 'ZP01' OR AUART = 'ZP02' OR AUART = 'ZP10' OR AUART = 'ZP11'
          OR AUART = 'ZP07' OR AUART = 'ZP08'                                     "ADDED BY FATHIR 24.01.2019 - CANCEL 311 FOR THERMAL
          OR AUART = 'ZTR1' OR AUART = 'ZTR3' OR AUART = 'ZTR4'
          OR AUART = 'ZP12' OR AUART = 'ZTR7'                                   "ADDED EXLAM 21.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
          " Added by William at 24.07.2022 (OPP7 CPP1)
          OR AUART = 'ZP13' OR AUART = 'ZP15' OR AUART = 'ZP17'
          OR AUART = 'ZTR8' OR AUART = 'ZTR9' OR AUART = 'ZTRA' OR AUART = 'ZTRB' OR AUART = 'ZTRC' ).
          " End added by William at 24.07.2022 (OPP7 CPP1)
       PERFORM F_CANCEL_MAT_RR_2 USING T_CANCEL-BKTXT T_CANCEL-AUFNR CHANGING ERRNO. "->ref3
     ENDIF.

     "-> ref3
     IF ERRNO = '1'. "-> gagal 312
       T_CANCEL-FLAG = 'X'.
       MODIFY T_CANCEL.
     ENDIF.


     "-> jika sukses cancel 312 baru bisa 262 + 512
     CHECK ERRNO NE '1'. "-> ref3
     "- 18 jan 13
     PERFORM GET_BWART_ALL USING T_CANCEL-AUFNR  CHANGING BWART1 BWART2.

     CLEAR : MBLNR.
     SELECT SINGLE MBLNR INTO MBLNR
      FROM MSEG
      WHERE SMBLN = T_CANCEL-MBLNR
      AND   SMBLP = T_CANCEL-ZEILE
      AND   SJAHR = T_CANCEL-MJAHR
      AND   BWART = BWART2. "'262'.
     CHECK MBLNR = ''.  "->di cancel



     CLEAR : MATDOC,YEAR,LI_RETURN,LWA_HEADRET,LWA_RETURN.

     V_PERCENT  =  ( SY-TABIX / LINE ) * 100.
     CONCATENATE 'Proses Cancel 262 roll ' T_CANCEL-CHARG 'Order' T_CANCEL-AUFNR
        'Matdoc' T_CANCEL-MBLNR INTO VTEXT SEPARATED BY SPACE.

     CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
         PERCENTAGE = V_PERCENT
         TEXT       = VTEXT.

     MOVE T_CANCEL-MBLNR TO MATDOC.
     MOVE T_CANCEL-MJAHR TO YEAR.

     CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
       EXPORTING
         MATERIALDOCUMENT = MATDOC
         MATDOCUMENTYEAR  = YEAR
       IMPORTING
         GOODSMVT_HEADRET = LWA_HEADRET
       TABLES
         RETURN           = LI_RETURN.

     IF LI_RETURN IS INITIAL.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT = V_YES.

       CLEAR : RESULT.
       WHILE RESULT = ''.
         SELECT SINGLE MBLNR INTO RESULT
           FROM MSEG
           WHERE MBLNR = LWA_HEADRET-MAT_DOC
           AND   MJAHR = LWA_HEADRET-DOC_YEAR.
       ENDWHILE.

       T_BACK-AUFNR = T_CANCEL-AUFNR.
       T_BACK-BKTXT = T_CANCEL-BKTXT.
       T_BACK-MBLNR = LWA_HEADRET-MAT_DOC.
       T_BACK-MJAHR = LWA_HEADRET-DOC_YEAR.
       T_BACK-BWART = BWART1. "'261'.
       APPEND T_BACK.

     ELSE.
       "-> jika gagal cancel 312 di cancel lagi biar seperti kondisi semula.
       PERFORM F_CANCEL_MATDOC_3 USING T_CANCEL-BKTXT T_CANCEL-AUFNR.

       T_CANCEL-FLAG  = 'X'.
       MODIFY T_CANCEL.
       LOOP AT LI_RETURN.
         WA_ERROR-MSGID    = LI_RETURN-ID.
         WA_ERROR-MSGTY    = LI_RETURN-TYPE .
         WA_ERROR-MSGNO    = LI_RETURN-NUMBER.
         WA_ERROR-MSGV1    = LI_RETURN-MESSAGE_V1.
         WA_ERROR-MSGV2    = LI_RETURN-MESSAGE_V2.
         WA_ERROR-MSGV3    = LI_RETURN-MESSAGE_V3.
         WA_ERROR-MSGV4    = LI_RETURN-MESSAGE_V4.
         WA_MESSAGE-LINENO = SY-TABIX.
         APPEND WA_ERROR TO TA_ERROR.
       ENDLOOP.
       P_ERRNO = 1.
       ROLLBACK WORK.
     ENDIF.
   ENDLOOP.


 ENDFORM.                    " F_CANCEL_MATDOC
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_MAT_RR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WERKS  text
*      -->P_ZZCODE  text
*      -->P_ZZLINE  text
*      -->P_BKTXT  text
*      -->P_UAFNR  text
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
 FORM F_CANCEL_MAT_RR  USING    P_ZZCODE
                                P_ZZLINE
                                P_BKTXT
                                P_AUFNR
                                P_NUM
                                P_MENGE
                                P_WERKS
                                P_CHARGID
                                P_TIPE
                       CHANGING P_ERRNO.

   DATA: TA_RET LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
         PA_RET LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
         TA_HEADER TYPE BAPI2017_GM_HEAD_01 OCCURS 1 WITH HEADER LINE,
         PA_HEADER TYPE BAPI2017_GM_HEAD_01 OCCURS 1 WITH HEADER LINE,
         TA_CODE TYPE BAPI2017_GM_CODE OCCURS 1 WITH HEADER LINE,
         PA_CODE TYPE BAPI2017_GM_CODE OCCURS 1 WITH HEADER LINE,
         TA_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         WA_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
         PA_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
         WP_ITEM TYPE BAPI2017_GM_ITEM_CREATE.

   DATA: MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
         MATDOC2 TYPE BAPI2017_GM_HEAD_RET-MAT_DOC.

   DATA : BEGIN OF T_CANCEL_RR OCCURS 0 ,
          WERKS TYPE MSEG-WERKS,
          LGORT TYPE MSEG-LGORT,
          MATNR TYPE MSEG-MATNR,
          BWART TYPE MSEG-BWART,
          CHARG TYPE MSEG-CHARG,
          MBLNR TYPE MSEG-MBLNR,
          MJAHR TYPE MSEG-MJAHR,
          ZEILE TYPE MSEG-ZEILE,
          MENGE TYPE MSEG-MENGE,
          MEINS TYPE MSEG-MEINS,
         END OF T_CANCEL_RR.

   DATA : T_CEK1 LIKE T_CANCEL_RR OCCURS 0 WITH HEADER LINE,
          T_CEK2 LIKE T_CANCEL_RR OCCURS 0 WITH HEADER LINE.

   DATA : ZRRLGORT TYPE ZTMAP_SLOCRR-ZRRLGORT,
          ZWCLGORT TYPE LGORT_D,
          ZWPLGORT TYPE LGORT_D,
          ZNALGORT TYPE LGORT_D,
          ZZNUMBER TYPE  ZTMAP_SLOCRR-ZZNUMBER ,
          P_MATNR TYPE MSEG-MATNR,
          BWART TYPE MSEG-BWART,
          TMENGE TYPE STRING,
          FLAG_ERROR.

   TMENGE = P_MENGE.
*531 = ZWPLGORT
*532 = ZWPLGORT
*311 = ZRRLGORT
*312 = ZRRLGORT

   SELECT ZZNUMBER ZRRLGORT ZWCLGORT ZWPLGORT ZNALGORT
     INTO (ZZNUMBER,ZRRLGORT,ZWCLGORT,ZWPLGORT,ZNALGORT)
     FROM ZTMAP_SLOCRR
     WHERE ZLINE = P_ZZLINE
     ORDER BY ZTMAP_SLOCRR~ZZNUMBER DESCENDING.
   ENDSELECT.

   SELECT SINGLE RAR_A_MATNR INTO P_MATNR
     FROM ZTMAP_MATRECYCLE
     WHERE WERKS = P_WERKS
     AND   FILMT = P_ZZCODE.
   IF P_MATNR = ''.
     WA_MESSAGE-MSGID = 'ZMM'.
     WA_MESSAGE-MSGTY = 'E' .
     WA_MESSAGE-MSGNO = '018'.
     CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
                 'Tidak ada Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
     WA_MESSAGE-MSGV2 = 'Kemungkinan belum di maintain'.
     WA_MESSAGE-MSGV3 = 'di table material rr / karakteristik batch'.
     WA_MESSAGE-MSGV4 =  SPACE.
     APPEND WA_MESSAGE TO TA_MESSAGE.
     RETURN.
   ENDIF.

   SELECT MSEG~WERKS MSEG~LGORT MSEG~MATNR MSEG~BWART
          MSEG~CHARG MSEG~MBLNR MSEG~MJAHR MSEG~ZEILE
          MSEG~MENGE MSEG~MEINS
     FROM MSEG
     JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
     INTO TABLE T_CANCEL_RR
*     WHERE AUFNR = P_AUFNR
     WHERE  BKTXT = P_BKTXT
     AND   BWART EQ '311' "IN ('531','311')
     ORDER BY MSEG~MBLNR ASCENDING.
*     %_HINTS ORACLE 'INDEX("MSEG" "MSEG~BOM")'.


**-- new case
   LOOP AT T_CANCEL_RR.
     SELECT SINGLE MATKL INTO MATKL                         "B00503
        FROM MARA
        WHERE MATNR =  T_CANCEL_RR-MATNR
        AND   MATKL = 'B00503'.
     IF SY-SUBRC NE 0.
       DELETE T_CANCEL_RR WHERE MBLNR = T_CANCEL_RR-MBLNR
                          AND   MJAHR = T_CANCEL_RR-MJAHR
                          AND   ZEILE = T_CANCEL_RR-ZEILE.
       CONTINUE.
     ENDIF.
   ENDLOOP.
**  4 jan 12

   SORT T_CANCEL_RR BY MBLNR DESCENDING ZEILE ASCENDING.     "MODIFIED BY FATHIR 24.01.2019 - SORTING BY SLOC AND MATDOC ITEM
   T_CEK2[] = T_CEK1[] = T_CANCEL_RR[].
   DELETE ADJACENT DUPLICATES FROM T_CANCEL_RR COMPARING BWART.
   LOOP AT T_CANCEL_RR.
     T_CEK2[] = T_CEK1[].
     DELETE T_CEK2 WHERE BWART NE T_CANCEL_RR-BWART.
     SORT T_CEK2 BY MBLNR DESCENDING.
     READ TABLE T_CEK2 INDEX 1.
     T_CANCEL_RR-MBLNR = T_CEK2-MBLNR.
     T_CANCEL_RR-MJAHR = T_CEK2-MJAHR.
     T_CANCEL_RR-ZEILE = T_CEK2-ZEILE.
     T_CANCEL_RR-MENGE = T_CEK2-MENGE.
     MODIFY T_CANCEL_RR.
   ENDLOOP.

*   READ TABLE T_CANCEL_RR WITH KEY BWART = '531'.
*   IF SY-SUBRC NE 0.
*     "->CREATE 531
*     T_CANCEL_RR-MBLNR = '9999999'.
*     T_CANCEL_RR-MJAHR = '1901'.
*     T_CANCEL_RR-ZEILE = '1234'.
*     T_CANCEL_RR-MATNR = P_MATNR.
*     T_CANCEL_RR-WERKS = P_WERKS.
*     T_CANCEL_RR-BWART = '531'.
*     T_CANCEL_RR-LGORT = ZWPLGORT. "ZRRLGORT.
*
*     SELECT SINGLE CHARG INTO T_CANCEL_RR-CHARG
*       FROM MCHB
*       WHERE MATNR = P_MATNR
*       AND   WERKS = P_WERKS
*       AND   LGORT = ZRRLGORT.
*
*     APPEND T_CANCEL_RR.
*   ENDIF.

   READ TABLE T_CANCEL_RR WITH KEY BWART = '311'.
   IF SY-SUBRC NE 0.
     "- CREATE 311.
     T_CANCEL_RR-MBLNR = '9999999'.
     T_CANCEL_RR-MJAHR = '1901'.
     T_CANCEL_RR-ZEILE = '1234'.
     T_CANCEL_RR-MATNR = P_MATNR.
     T_CANCEL_RR-WERKS = P_WERKS.
     T_CANCEL_RR-BWART = '311'.
     T_CANCEL_RR-LGORT = ZWPLGORT.

     SELECT SINGLE CHARG INTO T_CANCEL_RR-CHARG
       FROM MCHB
       WHERE MATNR = P_MATNR
       AND   WERKS = P_WERKS
       AND   LGORT = ZRRLGORT.

     APPEND T_CANCEL_RR.
   ENDIF.


   LOOP AT T_CANCEL_RR.
     CLEAR : TA_RET,PA_RET,TA_HEADER,PA_HEADER,TA_CODE,PA_CODE,TA_ITEM,WA_ITEM,PA_ITEM,WP_ITEM,
             MATDOC,MATDOC2,FLAG_ERROR.
     REFRESH : TA_RET,PA_RET,TA_HEADER,PA_HEADER,TA_CODE,PA_CODE,TA_ITEM,PA_ITEM.

     CASE T_CANCEL_RR-BWART.
*       WHEN '531'.
*         BWART = '532'.
       WHEN '311'.
         BWART = '312'.
     ENDCASE.

     "-> cek udah di cancel apa belom..
*     SELECT SINGLE ZEILE INTO ZEILE
*       FROM MSEG
*       WHERE SMBLN = T_CANCEL_RR-MBLNR
*       AND   SMBLP = T_CANCEL_RR-ZEILE
*       AND   SJAHR = T_CANCEL_RR-MJAHR
*       AND   BWART = BWART.
*     %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
*     SELECT SINGLE MBLNR INTO MBLNR  "disable karena param XBLNR tidak ada waluenya
*       FROM MKPF
*       WHERE XBLNR = T_CANCEL_RR-MBLNR.

*1)  kalo belom di cancel.. cancel dulu
     IF T_CANCEL_RR-MJAHR NE '1901' AND P_TIPE NE '2' .  "-> cancel
       CONCATENATE 'Proses Cancel' BWART 'Order' P_AUFNR 'Roll' P_CHARGID
                   'RawRec' T_CANCEL_RR-MATNR INTO VTEXT SEPARATED BY SPACE.
       CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
         EXPORTING
           PERCENTAGE = V_PERCENT
           TEXT       = VTEXT.

       TA_HEADER-HEADER_TXT = P_BKTXT.
       TA_HEADER-PSTNG_DATE = SY-DATUM.
       TA_HEADER-DOC_DATE   = SY-DATUM.
       TA_HEADER-REF_DOC_NO    = T_CANCEL_RR-MBLNR.
       TA_CODE-GM_CODE      = '06'.

       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
           INPUT  = T_CANCEL_RR-CHARG
         IMPORTING
           OUTPUT = T_CANCEL_RR-CHARG.

       TRANSLATE T_CANCEL_RR-MATNR TO UPPER CASE.

       WA_ITEM-MOVE_TYPE          = BWART.
       WA_ITEM-PLANT              = T_CANCEL_RR-WERKS.
       WA_ITEM-BATCH              = T_CANCEL_RR-CHARG.
       WA_ITEM-MATERIAL           = T_CANCEL_RR-MATNR.
       WA_ITEM-STGE_LOC           = T_CANCEL_RR-LGORT.
       WA_ITEM-MOVE_STLOC         = T_CANCEL_RR-LGORT.
       WA_ITEM-ENTRY_QNT          = T_CANCEL_RR-MENGE.
       WA_ITEM-ENTRY_UOM          = T_CANCEL_RR-MEINS.
*       WA_ITEM-ORDERID            = P_AUFNR.
       WA_ITEM-MATDOC_TR_CANCEL   = T_CANCEL_RR-MBLNR.
       WA_ITEM-MATITEM_TR_CANCEL  = T_CANCEL_RR-ZEILE.
       WA_ITEM-MATYEAR_TR_CANCEL  = T_CANCEL_RR-MJAHR.
       APPEND WA_ITEM TO TA_ITEM.

       CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
         EXPORTING
           GOODSMVT_HEADER  = TA_HEADER
           GOODSMVT_CODE    = TA_CODE
         IMPORTING
           MATERIALDOCUMENT = MATDOC
         TABLES
           GOODSMVT_ITEM    = TA_ITEM
           RETURN           = TA_RET.

       IF MATDOC = ''.
         P_ERRNO = 1. "-> gagal cancel 312
         LOOP AT TA_RET.
           WA_ERROR-MSGID = TA_RET-ID.
           WA_ERROR-MSGTY = TA_RET-TYPE .
           WA_ERROR-MSGNO = TA_RET-NUMBER.
           WA_ERROR-MSGV1 = TA_RET-MESSAGE_V1.
           WA_ERROR-MSGV2 = TA_RET-MESSAGE_V2.
           WA_ERROR-MSGV3 = TA_RET-MESSAGE_V3.
           WA_ERROR-MSGV4 = TA_RET-MESSAGE_V4.
           WA_MESSAGE-LINENO = SY-TABIX.
           APPEND WA_ERROR TO TA_ERROR.
         ENDLOOP.

         WA_MESSAGE-MSGID = 'ZMM'.
         WA_MESSAGE-MSGTY = 'E' .
         WA_MESSAGE-MSGNO = '002'.
         CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
                     'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

         CONCATENATE T_CANCEL_RR-MATNR BWART 'gagal di cancel' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
         CONCATENATE 'Quantity' TMENGE INTO WA_MESSAGE-MSGV3 SEPARATED BY SPACE.
         WA_MESSAGE-MSGV4 =  SPACE.
         APPEND WA_MESSAGE TO TA_MESSAGE.
*
*         FLAG_ERROR = V_YES.
       ELSE.
         P_ERRNO = 2. "-> success  312
*         WA_MESSAGE-MSGID = 'ZMM'.
*         WA_MESSAGE-MSGTY = 'S' .
*         WA_MESSAGE-MSGNO = '002'.
*         CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
*                     'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
*
*         CONCATENATE T_CANCEL_RR-MATNR BWART 'sukses di cancel' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
*         CONCATENATE 'Material Document' MATDOC INTO WA_MESSAGE-MSGV3
*                    SEPARATED BY SPACE.
*         APPEND WA_MESSAGE TO TA_MESSAGE.


         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT = V_YES.

       ENDIF.

     ENDIF.  "-> cancel




*2) gi 531 / 361 material rr
*     CHECK FLAG_ERROR = V_NO.
     CHECK P_TIPE = '2'.

     CONCATENATE 'Proses GI' T_CANCEL_RR-BWART 'Order' P_AUFNR 'Roll' P_CHARGID
                 'RawRec' T_CANCEL_RR-MATNR INTO VTEXT SEPARATED BY SPACE.
     CALL FUNCTION 'BUFFER_REFRESH_ALL'.

     CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
         PERCENTAGE = V_PERCENT
         TEXT       = VTEXT.

     PA_HEADER-HEADER_TXT     = P_BKTXT.
     PA_HEADER-PSTNG_DATE     = SY-DATUM.
     PA_HEADER-DOC_DATE       = SY-DATUM.
     PA_HEADER-GR_GI_SLIP_NO  = P_BKTXT.

     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
       EXPORTING
         INPUT  = T_CANCEL_RR-CHARG
       IMPORTING
         OUTPUT = T_CANCEL_RR-CHARG.

     TRANSLATE T_CANCEL_RR-MATNR TO UPPER CASE.

*     IF T_CANCEL_RR-BWART  = '531'.
*       PA_CODE-GM_CODE     = '03'.
*       WP_ITEM-STGE_LOC    = T_CANCEL_RR-LGORT.
*     ELSE.
     PA_CODE-GM_CODE     = '04'.
     WP_ITEM-MOVE_STLOC  = ZRRLGORT.
     WP_ITEM-MOVE_MAT    = T_CANCEL_RR-MATNR.
     WP_ITEM-MOVE_PLANT  = T_CANCEL_RR-WERKS.
     WP_ITEM-MOVE_BATCH  = T_CANCEL_RR-CHARG.
*     ENDIF.

     WP_ITEM-MOVE_TYPE   = T_CANCEL_RR-BWART.
     WP_ITEM-PLANT       = T_CANCEL_RR-WERKS.
     WP_ITEM-BATCH       = T_CANCEL_RR-CHARG.
     WP_ITEM-MATERIAL    = T_CANCEL_RR-MATNR.
*     WP_ITEM-ORDERID     = P_AUFNR.
     IF P_MENGE = ''.
       P_MENGE = T_CANCEL_RR-MENGE.
       WP_ITEM-STGE_LOC    = T_CANCEL_RR-LGORT.
     ELSE.
       WP_ITEM-STGE_LOC    = ZWPLGORT.
     ENDIF.
     WP_ITEM-ENTRY_QNT   = P_MENGE.
     WP_ITEM-ENTRY_UOM   = T_CANCEL_RR-MEINS.
     APPEND WP_ITEM TO PA_ITEM.

     CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
       EXPORTING
         GOODSMVT_HEADER  = PA_HEADER
         GOODSMVT_CODE    = PA_CODE
       IMPORTING
         MATERIALDOCUMENT = MATDOC2
       TABLES
         GOODSMVT_ITEM    = PA_ITEM
         RETURN           = PA_RET.


     IF MATDOC2 NE V_NO.
       P_ERRNO = '3' . "-> 311 ok
*       WA_MESSAGE-MSGID = 'ZMM'.
*       WA_MESSAGE-MSGTY = 'S' .
*       WA_MESSAGE-MSGNO = '002'.
*       CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
*                   'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.
*
*       CONCATENATE T_CANCEL_RR-MATNR T_CANCEL_RR-BWART 'Sukses' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
*       CONCATENATE 'Material Document' MATDOC2 INTO WA_MESSAGE-MSGV3
*                   SEPARATED BY SPACE.
*       APPEND WA_MESSAGE TO TA_MESSAGE.

       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT = V_YES.


     ELSE.
       P_ERRNO = '4'. "-> 311  gagal
*       WA_MESSAGE-MSGID = 'ZMM'.
*       WA_MESSAGE-MSGTY = 'E' .
*       WA_MESSAGE-MSGNO = '002'.
*       CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
*                   'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

*       CONCATENATE T_CANCEL_RR-MATNR T_CANCEL_RR-BWART 'gagal di gi' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
*       CONCATENATE 'Quantity' TMENGE INTO WA_MESSAGE-MSGV3 SEPARATED BY SPACE.
*       APPEND WA_MESSAGE TO TA_MESSAGE.


*       LOOP AT PA_RET.
*         WA_ERROR-MSGID = PA_RET-ID.
*         WA_ERROR-MSGTY = PA_RET-TYPE .
*         WA_ERROR-MSGNO = PA_RET-NUMBER.
*         WA_ERROR-MSGV1 = PA_RET-MESSAGE_V1.
*         WA_ERROR-MSGV2 = PA_RET-MESSAGE_V2.
*         WA_ERROR-MSGV3 = PA_RET-MESSAGE_V3.
*         WA_ERROR-MSGV4 = PA_RET-MESSAGE_V4.
*         WA_MESSAGE-LINENO = SY-TABIX.
*         APPEND WA_ERROR TO TA_ERROR.
*       ENDLOOP.

     ENDIF.


   ENDLOOP.
 ENDFORM.                    " F_CANCEL_MAT_RR
*&---------------------------------------------------------------------*
*&      Form  F_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VLOCK  text
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
 FORM F_LOCK  USING    P_VLOCK
              CHANGING P_ERRNO.

   CALL FUNCTION 'ENQUEUE_EZGR'
     EXPORTING
       MODE_ZTLOCK    = 'E'
       MANDT          = SY-MANDT
       LOOBJ          = P_VLOCK
     EXCEPTIONS
       FOREIGN_LOCK   = 1
       SYSTEM_FAILURE = 2
       OTHERS         = 3.
   IF SY-SUBRC <> 0.
     P_ERRNO = 1.
   ENDIF.
 ENDFORM.                    " F_LOCK
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VLOCK  text
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
 FORM F_UNLOCK  USING    P_VLOCK
                CHANGING P_ERRNO.

   CALL FUNCTION 'ENQUEUE_EZGR'
     EXPORTING
       MODE_ZTLOCK    = 'E'
       MANDT          = SY-MANDT
       LOOBJ          = P_VLOCK
     EXCEPTIONS
       FOREIGN_LOCK   = 1
       SYSTEM_FAILURE = 2
       OTHERS         = 3.

 ENDFORM.                    " F_UNLOCK
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_MIGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
 FORM F_CANCEL_MIGO  CHANGING P_ERRNO.
   DATA : MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
          LI_RETURN   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
          T_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
          W_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
          T_CODE TYPE BAPI2017_GM_CODE OCCURS 1 WITH HEADER LINE,
          T_HEADER TYPE BAPI2017_GM_HEAD_01 OCCURS 1 WITH HEADER LINE,
          T_CANCEL_ITEM LIKE T_CANCEL OCCURS 0 WITH HEADER LINE,
          V_AUART TYPE AUFK-AUART,
          V_BWART TYPE MSEG-BWART.

   DATA : V_MBLNR TYPE MSEG-MBLNR,
          V_MJAHR TYPE MSEG-MJAHR,
          V_ZEILE TYPE MSEG-ZEILE,
          V_WERKS TYPE MSEG-WERKS,
          V_CHARG TYPE MSEG-CHARG,
          V_MATNR TYPE MSEG-MATNR,
          V_LGORT TYPE MSEG-LGORT,
          V_MENGE TYPE MSEG-MENGE,
          C_MBLNR TYPE MSEG-MBLNR,
          T_MENGE TYPE STRING.

   SORT T_CANCEL BY AUFNR CHARG MATNR MENGE.
   DELETE ADJACENT DUPLICATES FROM T_CANCEL COMPARING AUFNR CHARG MATNR ZEILE.
   T_CANCEL_ITEM[] = T_CANCEL[].
   DELETE ADJACENT DUPLICATES FROM T_CANCEL COMPARING AUFNR CHARG.


   DESCRIBE TABLE T_CANCEL_ITEM LINES LINE.
   LOOP AT T_CANCEL.
     CLEAR : ERRNO.
     "-> cancel 311
     PERFORM F_CANCEL_MAT_RR USING T_CANCEL-ZZCODE T_CANCEL-ZZLINE T_CANCEL-BKTXT
           T_CANCEL-AUFNR '' '' T_CANCEL-WERKS T_CANCEL-CHARG '1' CHANGING ERRNO.

     IF ERRNO = '1'.
       T_CANCEL-FLAG = 'X'.
       MODIFY T_CANCEL.
       "-> jika sukses cancel 312 baru bisa 262 + 512
       CHECK ERRNO NE '1'.
     ENDIF.

     CLEAR : MBLNR,V_AUART, V_BWART.

     SELECT SINGLE AUART INTO V_AUART
        FROM AUFK
        WHERE AUFNR = T_CANCEL-AUFNR.

     CASE V_AUART.
         	WHEN 'ZTR01' OR 'ZTR02'.
         V_BWART = '902'.
         	WHEN OTHERS.
         V_BWART = '262'.
     ENDCASE.

     SELECT MBLNR INTO MBLNR
      FROM MSEG
      WHERE SMBLN = T_CANCEL-MBLNR
      AND   SMBLP = T_CANCEL-ZEILE
      AND   SJAHR = T_CANCEL-MJAHR
      AND   MATNR = T_CANCEL-MATNR
      AND   BWART = V_BWART.
*     %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
     ENDSELECT.
     CHECK MBLNR = ''.

     CLEAR : LI_RETURN,T_ITEM,W_ITEM,T_CODE,T_HEADER,MATDOC.

     V_PERCENT  =  ( SY-TABIX / LINE ) * 100.
     CONCATENATE 'Proses Cancel 262 roll ' T_CANCEL-CHARG 'Order' T_CANCEL-AUFNR
        'Matdoc' T_CANCEL-MBLNR INTO VTEXT SEPARATED BY SPACE.

     CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
         PERCENTAGE = V_PERCENT
         TEXT       = VTEXT.

     T_HEADER-HEADER_TXT = T_CANCEL-BKTXT.
     T_HEADER-PSTNG_DATE = SY-DATUM.
     T_HEADER-DOC_DATE   = SY-DATUM.

     T_CODE-GM_CODE      = '06'.

     LOOP AT T_CANCEL_ITEM WHERE AUFNR = T_CANCEL-AUFNR
                           AND   CHARG = T_CANCEL-CHARG.
       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
           INPUT  = T_CANCEL-CHARG
         IMPORTING
           OUTPUT = T_CANCEL-CHARG.

       TRANSLATE T_CANCEL-MATNR TO UPPER CASE.

       W_ITEM-MOVE_TYPE          = V_BWART. "'262'.
       W_ITEM-PLANT              = T_CANCEL_ITEM-WERKS.
       W_ITEM-BATCH              = T_CANCEL_ITEM-CHARG.
       W_ITEM-MATERIAL           = T_CANCEL_ITEM-MATNR.
       W_ITEM-STGE_LOC           = T_CANCEL_ITEM-LGORT.
       W_ITEM-ENTRY_QNT          = T_CANCEL_ITEM-MENGE.
       W_ITEM-ORDERID            = T_CANCEL_ITEM-AUFNR.
       W_ITEM-MATDOC_TR_CANCEL   = T_CANCEL_ITEM-MBLNR.
       W_ITEM-MATITEM_TR_CANCEL  = T_CANCEL_ITEM-ZEILE.
       W_ITEM-MATYEAR_TR_CANCEL  = T_CANCEL_ITEM-MJAHR.
       APPEND W_ITEM TO T_ITEM.
     ENDLOOP.

**  cari 532 kalo ada
     CLEAR : V_MBLNR,V_MJAHR,V_ZEILE,V_WERKS,V_CHARG,
             V_MATNR,V_LGORT,V_MENGE,C_MBLNR.

     SELECT AUFM~MBLNR AUFM~MJAHR AUFM~ZEILE
            AUFM~WERKS AUFM~CHARG AUFM~MATNR
            AUFM~LGORT AUFM~MENGE
     INTO   (V_MBLNR,V_MJAHR,V_ZEILE,V_WERKS,
             V_CHARG,V_MATNR,V_LGORT,V_MENGE)
     FROM AUFM
     JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
     WHERE AUFM~AUFNR  = T_CANCEL-AUFNR
     AND   MKPF~BKTXT  = T_CANCEL-BKTXT
     AND   BWART       = '531'
     AND   AUFM~WERKS  = T_CANCEL-WERKS
     ORDER BY AUFM~MBLNR ASCENDING.
*     %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z03")'.
     ENDSELECT.

     IF V_MBLNR NE ''.
       CLEAR : C_MBLNR.
       SELECT SINGLE MBLNR INTO C_MBLNR
         FROM MSEG
         WHERE SMBLN = V_MBLNR
         AND   SMBLP = V_ZEILE
         AND   SJAHR = V_MJAHR
         AND   BWART = '532'.
*     %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.

       IF C_MBLNR NE ''.
         W_ITEM-MOVE_TYPE          = '532'.
         W_ITEM-PLANT              = V_WERKS.
         W_ITEM-BATCH              = V_CHARG.
         W_ITEM-MATERIAL           = V_MATNR.
         W_ITEM-STGE_LOC           = V_LGORT.
         W_ITEM-ENTRY_QNT          = V_MENGE.
         W_ITEM-ORDERID            = T_CANCEL-AUFNR.
         W_ITEM-MATDOC_TR_CANCEL   = V_MBLNR.
         W_ITEM-MATITEM_TR_CANCEL  = V_ZEILE.
         W_ITEM-MATYEAR_TR_CANCEL  = V_MJAHR.
         APPEND W_ITEM TO T_ITEM.
       ENDIF.
     ENDIF.
** END 531

     CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
       EXPORTING
         GOODSMVT_HEADER  = T_HEADER
         GOODSMVT_CODE    = T_CODE
       IMPORTING
         MATERIALDOCUMENT = MATDOC
       TABLES
         GOODSMVT_ITEM    = T_ITEM
         RETURN           = LI_RETURN.

     IF MATDOC NE V_NO.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT = V_YES.
     ELSE.
       "-> jika gagal cancel 262 + 512 , 312 yang di mbst
       T_CANCEL-FLAG = 'X'.
       MODIFY T_CANCEL.

       "-> create 311 lagi
       PERFORM F_CANCEL_MAT_RR USING T_CANCEL-ZZCODE T_CANCEL-ZZLINE T_CANCEL-BKTXT
             T_CANCEL-AUFNR '' '' T_CANCEL-WERKS T_CANCEL-CHARG '2' CHANGING ERRNO .

       LOOP AT LI_RETURN.
         WA_ERROR-MSGID    = LI_RETURN-ID.
         WA_ERROR-MSGTY    = LI_RETURN-TYPE .
         WA_ERROR-MSGNO    = LI_RETURN-NUMBER.
         WA_ERROR-MSGV1    = LI_RETURN-MESSAGE_V1.
         WA_ERROR-MSGV2    = LI_RETURN-MESSAGE_V2.
         WA_ERROR-MSGV3    = LI_RETURN-MESSAGE_V3.
         WA_ERROR-MSGV4    = LI_RETURN-MESSAGE_V4.
         WA_MESSAGE-LINENO = SY-TABIX.
         APPEND WA_ERROR TO TA_ERROR.
       ENDLOOP.
       P_ERRNO = 1.
       ROLLBACK WORK.
       RETURN.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " F_CANCEL_MIGO
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_DISPLAY .
   CLEAR : ITAB,TA_ITEM,WA_ITEM,TA_ITEM_JR,WA_ITEM_JR,TA_ITEM_GI,WA_ITEM_GI,TA_BOM,WA_BOM,
           TA_EXCEL,WA_EXCEL,CODE,ZZCODE,ZZLINE,COUNT_CLICK,
           ZZLENGTH,ZZWIDTH,ZZCOATING_WEIGHT,T_CANCEL,LOCATION,QTY_JR.
   REFRESH : ITAB,TA_ITEM,TA_ITEM_JR,TA_ITEM_GI,TA_BOM,TA_EXCEL,T_CANCEL.

   SORT T_CEKLIST BY CHARGID AUFNRID.
   DELETE ADJACENT DUPLICATES FROM T_CEKLIST COMPARING CHARGID AUFNRID.

   PERFORM GETZ_DATA USING 'X'.

   PERFORM ALV.
   LEAVE SCREEN.
 ENDFORM.                    " F_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_562
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM F_CANCEL_562 USING P_AUFNR P_BKTXT P_CHARGID P_WERKS CHANGING P_ERRNO.
   DATA : MATDOC TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
          LI_RETURN   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
          T_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
          W_ITEM TYPE BAPI2017_GM_ITEM_CREATE,
          T_CODE TYPE BAPI2017_GM_CODE OCCURS 1 WITH HEADER LINE,
          T_HEADER TYPE BAPI2017_GM_HEAD_01 OCCURS 1 WITH HEADER LINE.
   DATA : V_MBLNR TYPE MSEG-MBLNR,
          V_MJAHR TYPE MSEG-MJAHR,
          V_ZEILE TYPE MSEG-ZEILE,
          V_WERKS TYPE MSEG-WERKS,
          V_CHARG TYPE MSEG-CHARG,
          V_MATNR TYPE MSEG-MATNR,
          V_LGORT TYPE MSEG-LGORT,
          V_MENGE TYPE MSEG-MENGE,
          C_MBLNR TYPE MSEG-MBLNR,
          T_MENGE TYPE STRING.

   CLEAR : V_MBLNR,V_MJAHR,V_ZEILE,V_WERKS,V_CHARG,
           V_MATNR,V_LGORT,V_MENGE,C_MBLNR.

   CONCATENATE 'Proses Cancel 532 roll ' P_CHARGID 'Order' P_AUFNR
                INTO VTEXT SEPARATED BY SPACE.
   CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
     EXPORTING
       PERCENTAGE = V_PERCENT
       TEXT       = VTEXT.

   SELECT AUFM~MBLNR AUFM~MJAHR AUFM~ZEILE
          AUFM~WERKS AUFM~CHARG AUFM~MATNR
          AUFM~LGORT AUFM~MENGE
   INTO   (V_MBLNR,V_MJAHR,V_ZEILE,V_WERKS,
           V_CHARG,V_MATNR,V_LGORT,V_MENGE)
   FROM AUFM
   JOIN MKPF ON AUFM~MBLNR = MKPF~MBLNR
   WHERE AUFM~AUFNR  = P_AUFNR
   AND   MKPF~BKTXT  = P_BKTXT
   AND   BWART       = '531'
   AND   AUFM~WERKS  = P_WERKS
   ORDER BY AUFM~MBLNR ASCENDING.
*   %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z03")'.
   ENDSELECT.

   IF V_MBLNR NE ''.
     SELECT SINGLE MBLNR INTO C_MBLNR
       FROM MSEG
       WHERE SMBLN = V_MBLNR
       AND   SMBLP = V_ZEILE
       AND   SJAHR = V_MJAHR
       AND   BWART = '532'.
*   %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
   ELSE.
     P_ERRNO = 0.
     RETURN.
   ENDIF.

   CHECK C_MBLNR = ''.

   T_HEADER-HEADER_TXT = T_CANCEL-BKTXT.
   T_HEADER-PSTNG_DATE = SY-DATUM.
   T_HEADER-DOC_DATE   = SY-DATUM.

   T_CODE-GM_CODE      = '06'.

   W_ITEM-MOVE_TYPE   = '532'.
   W_ITEM-PLANT       = V_WERKS.
   W_ITEM-BATCH       = V_CHARG.
   W_ITEM-MATERIAL    = V_MATNR.
   W_ITEM-STGE_LOC    = V_LGORT.
   W_ITEM-ENTRY_QNT   = V_MENGE.
   W_ITEM-ORDERID     = P_AUFNR.
   APPEND W_ITEM TO T_ITEM.


   CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
     EXPORTING
       GOODSMVT_HEADER  = T_HEADER
       GOODSMVT_CODE    = T_CODE
     IMPORTING
       MATERIALDOCUMENT = MATDOC
     TABLES
       GOODSMVT_ITEM    = T_ITEM
       RETURN           = LI_RETURN.

   T_MENGE = V_MENGE.
   IF MATDOC NE ''.
     WA_MESSAGE-MSGID = 'ZMM'.
     WA_MESSAGE-MSGTY = 'S' .
     WA_MESSAGE-MSGNO = '002'.
     CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
                 'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

     CONCATENATE V_MATNR '532 sukses di cancel' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
     CONCATENATE 'Material Document' MATDOC INTO WA_MESSAGE-MSGV3
                SEPARATED BY SPACE.
     APPEND WA_MESSAGE TO TA_MESSAGE.

     CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
       EXPORTING
         WAIT = V_YES.
   ELSE.

     WA_MESSAGE-MSGID = 'ZMM'.
     WA_MESSAGE-MSGTY = 'E' .
     WA_MESSAGE-MSGNO = '002'.
     CONCATENATE 'Order.' P_AUFNR 'Jumbo Roll' P_CHARGID
                 'Material RR ' INTO WA_MESSAGE-MSGV1 SEPARATED BY SPACE.

     CONCATENATE V_MATNR '532 gagal di cancel' INTO WA_MESSAGE-MSGV2 SEPARATED BY SPACE.
     CONCATENATE 'Quantity' T_MENGE INTO WA_MESSAGE-MSGV3 SEPARATED BY SPACE.
     APPEND WA_MESSAGE TO TA_MESSAGE.
     P_ERRNO = '2'.
   ENDIF.


 ENDFORM.                    " F_CANCEL_562
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_MAT_RR_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZZCODE  text
*      -->P_ZZLINE  text
*      -->P_BKTXT  text
*      -->P_AUFNR  text
*      -->P_WERKS  text
*      -->P_CHARG  text
*      <--P_ERRNO  text
*----------------------------------------------------------------------*
 FORM F_CANCEL_MAT_RR_2  USING   P_BKTXT
                                 P_AUFNR
                         CHANGING P_ERRNO.

   DATA : MATDOC TYPE BAPI2017_GM_HEAD_02-MAT_DOC,
          YEAR   TYPE BAPI2017_GM_HEAD_02-DOC_YEAR,
          RETURN   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
          HEADRET TYPE BAPI2017_GM_HEAD_RET.
   DATA : RESULT TYPE MSEG-MBLNR,
          XABLN TYPE MKPF-XABLN,
          MATNR TYPE MARA-MATNR.

   SELECT MSEG~MBLNR MSEG~MJAHR MSEG~ZEILE MKPF~XABLN MSEG~MATNR INTO (MBLNR,MJAHR,ZEILE,XABLN,MATNR)
     FROM MSEG
     JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
*     WHERE AUFNR = P_AUFNR
     WHERE  BKTXT = P_BKTXT
     AND    BWART EQ '311'
     ORDER BY MSEG~MBLNR ASCENDING.
   ENDSELECT.

   IF SY-SUBRC  NE 0 .
     P_ERRNO = '0'.
     RETURN .
   ENDIF.

** - new case 4 jan 12
   SELECT SINGLE MATKL INTO MATKL                           "B00503
     FROM MARA
     WHERE MATNR =  MATNR
     AND   MATKL = 'B00503'.
   IF SY-SUBRC NE 0.
     P_ERRNO = '0'.
     RETURN .
   ENDIF.
*   -----

   SELECT SINGLE MSEG~MBLNR INTO MBLNR
     FROM MSEG
     WHERE SMBLN = MBLNR
     AND   SJAHR = MJAHR
     AND   SMBLP = ZEILE
     AND   BWART = '312'.
   CHECK SY-SUBRC NE 0.

   MOVE MBLNR TO MATDOC.
   MOVE MJAHR TO YEAR.

   CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
     EXPORTING
       MATERIALDOCUMENT = MATDOC
       MATDOCUMENTYEAR  = YEAR
     IMPORTING
       GOODSMVT_HEADRET = HEADRET
     TABLES
       RETURN           = RETURN.

   IF HEADRET IS NOT INITIAL.
     CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
       EXPORTING
         WAIT = V_YES.

     CLEAR : RESULT.
     WHILE RESULT = ''.
       SELECT SINGLE MBLNR INTO RESULT
         FROM MSEG
         WHERE MBLNR = HEADRET-MAT_DOC
         AND   MJAHR = HEADRET-DOC_YEAR.
     ENDWHILE.
     P_ERRNO = '2'.

     T_BACK-AUFNR = P_AUFNR.
     T_BACK-BKTXT = P_BKTXT.
     T_BACK-MBLNR = HEADRET-MAT_DOC.
     T_BACK-MJAHR = HEADRET-DOC_YEAR.
     T_BACK-BWART = '311'.
     APPEND T_BACK.
   ELSE.
     LOOP AT RETURN.
       WA_ERROR-MSGID    = RETURN-ID.
       WA_ERROR-MSGTY    = RETURN-TYPE .
       WA_ERROR-MSGNO    = RETURN-NUMBER.
       WA_ERROR-MSGV1    = RETURN-MESSAGE_V1.
       WA_ERROR-MSGV2    = RETURN-MESSAGE_V2.
       WA_ERROR-MSGV3    = RETURN-MESSAGE_V3.
       WA_ERROR-MSGV4    = RETURN-MESSAGE_V4.
       APPEND WA_ERROR TO TA_ERROR.
     ENDLOOP.

     P_ERRNO = '1'.
     ROLLBACK WORK.
   ENDIF.


 ENDFORM.                    " F_CANCEL_MAT_RR_2
*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_MATDOC_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BKTXT  text
*      -->P_AUFNR  text
*----------------------------------------------------------------------*
 FORM F_CANCEL_MATDOC_3  USING    P_BKTXT
                                  P_AUFNR.
   DATA : MATDOC TYPE BAPI2017_GM_HEAD_02-MAT_DOC,
          YEAR   TYPE BAPI2017_GM_HEAD_02-DOC_YEAR,
          RETURN   LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE,
          HEADRET TYPE BAPI2017_GM_HEAD_RET.
   DATA : RESULT TYPE MSEG-MBLNR.

   SORT T_BACK BY BWART ASCENDING.
   LOOP AT T_BACK WHERE AUFNR = P_AUFNR
                  AND   BKTXT = P_BKTXT.

     MOVE T_BACK-MBLNR TO MATDOC.
     MOVE T_BACK-MJAHR TO YEAR.

     CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
       EXPORTING
         MATERIALDOCUMENT = MATDOC
         MATDOCUMENTYEAR  = YEAR
       IMPORTING
         GOODSMVT_HEADRET = HEADRET
       TABLES
         RETURN           = RETURN.

     IF HEADRET IS NOT INITIAL.
       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         EXPORTING
           WAIT = V_YES.

       CLEAR : RESULT.
       WHILE RESULT = ''.
         SELECT SINGLE MBLNR INTO RESULT
           FROM MSEG
           WHERE MBLNR = HEADRET-MAT_DOC
           AND   MJAHR = HEADRET-DOC_YEAR.
       ENDWHILE.

       DELETE T_BACK WHERE AUFNR = P_AUFNR AND BKTXT = P_BKTXT.

     ELSE.
       LOOP AT RETURN.
         WA_ERROR-MSGID    = RETURN-ID.
         WA_ERROR-MSGTY    = RETURN-TYPE .
         WA_ERROR-MSGNO    = RETURN-NUMBER.
         WA_ERROR-MSGV1    = RETURN-MESSAGE_V1.
         WA_ERROR-MSGV2    = RETURN-MESSAGE_V2.
         WA_ERROR-MSGV3    = RETURN-MESSAGE_V3.
         WA_ERROR-MSGV4    = RETURN-MESSAGE_V4.
         APPEND WA_ERROR TO TA_ERROR.
       ENDLOOP.
       ROLLBACK WORK.
     ENDIF.

   ENDLOOP.
 ENDFORM.                    " F_CANCEL_MATDOC_3



*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL.
*&---------------------------------------------------------------------*
*       insert into SQL for Admin Entries NON SAP Program
*----------------------------------------------------------------------*
 FORM INSERT_SQL.
   DATA : BEGIN OF IT_MATKL OCCURS 0,
            MATKL LIKE MARA-MATKL,
          END OF IT_MATKL.

   RANGES:  R_AUFNR FOR AUFK-AUFNR,
            R_CHARG FOR MCHB-CHARG,
            R_BKTXT FOR MKPF-BKTXT,
            R_MTART FOR MARA-MTART,
            R_MATKL FOR MARA-MATKL.

   CLEAR   : R_AUFNR,R_CHARG,R_BKTXT,R_MTART,R_MATKL.
   REFRESH : R_AUFNR,R_CHARG,R_BKTXT,R_MTART,R_MATKL.

   LOOP AT ITAB WHERE AUFNRID IS NOT INITIAL.
     R_AUFNR-SIGN = 'I'.
     R_AUFNR-OPTION = 'EQ'.
     R_AUFNR-LOW = ITAB-AUFNRID.
     APPEND R_AUFNR.
     CLEAR R_AUFNR.

     R_CHARG-SIGN = 'I'.
     R_CHARG-OPTION = 'EQ'.
     R_CHARG-LOW = ITAB-CHARGID.
     APPEND R_CHARG.
     CLEAR R_CHARG.

     R_BKTXT-SIGN = 'I'.
     R_BKTXT-OPTION = 'EQ'.
     R_BKTXT-LOW = ITAB-BKTXT_JR.
     APPEND R_BKTXT.
     CLEAR R_BKTXT.
   ENDLOOP.

   R_MTART-SIGN = 'I'.
   R_MTART-OPTION = 'EQ'.
   R_MTART-LOW = 'ZRAW'.
   APPEND R_MTART.
   CLEAR R_MTART.

   R_MTART-SIGN = 'I'.
   R_MTART-OPTION = 'EQ'.
   R_MTART-LOW = 'ZFGS'.
   APPEND R_MTART.
   CLEAR R_MTART.

   SELECT DISTINCT MATKL
     INTO TABLE IT_MATKL
     FROM MARA
     WHERE MTART = 'ZRAW'.

   LOOP AT IT_MATKL.
     R_MATKL-SIGN = 'I'.
     R_MATKL-OPTION = 'EQ'.
     R_MATKL-LOW = IT_MATKL-MATKL.
     APPEND R_MATKL.
     CLEAR R_MATKL.
   ENDLOOP.

   R_MATKL-SIGN = 'I'.
   R_MATKL-OPTION = 'EQ'.
   R_MATKL-LOW = 'B00501'.
   APPEND R_MATKL.
   CLEAR R_MATKL.

   SUBMIT ZTPPI_CHANGE_BOM_PO WITH S_AUFNR IN R_AUFNR
                              WITH S_CHARG IN R_CHARG AND RETURN.

   SUBMIT ZTMMR_STOCK_RM WITH S_MTART IN R_MTART WITH S_MATKL IN R_MATKL AND RETURN.

   SUBMIT ZTPPR_PRO_MOVEMENT WITH S_BKTXT IN R_BKTXT AND RETURN.

   CLEAR   : R_AUFNR,R_CHARG,R_BKTXT,R_MTART,R_MATKL.
   REFRESH : R_AUFNR,R_CHARG,R_BKTXT,R_MTART,R_MATKL.

 ENDFORM.                    "TO_PROGRAM