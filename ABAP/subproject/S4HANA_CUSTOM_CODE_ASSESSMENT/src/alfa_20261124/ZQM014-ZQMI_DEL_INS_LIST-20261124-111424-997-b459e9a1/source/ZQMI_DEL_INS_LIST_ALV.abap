*&---------------------------------------------------------------------*
*&  Include           ZQM_DELIVERY_INSPECTION_ALV
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_LIST.
  REFRESH : T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_LIST' :
         'VBELN'   ''  ''  '' 20   'Delivery Order'  ''   '' '' '',
         'PRUEFLOS'     ''  ''  '' 20   'Inspection Lot' ''   ''  '' '',
         'ENSTEHDAT'     ''  ''  '' 25   'Inspection Lot Creation'   ''   ''  '' '',
         'VNAME'     ''  ''  '' 20   'Inspector'   ''   ''  '' '',
         'VCODE'     ''  ''  '' 20   'Usage Decision'  ''   ''  '' ''.
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
  clear wa_layout.
  wa_layout-zebra = 'X'.
  wa_layout-confirmation_prompt = 'X'.
  wa_layout-subtotals_text = 'Sub Total'.
  wa_layout-totals_text = 'Total'.
*  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
*  WA_LAYOUT-BOX_TABNAME = 'T_HEADER'.
*  WA_LAYOUT-EXPAND_FIELDNAME = 'EXPAND'.
*  wa_layout-expand_all = 'X'.
  wa_layout-cell_merge = 'X'.
  wa_layout-colwidth_optimize = 'X'.
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

  d_repid = sy-repid.
  t_print-no_print_listinfos = 'X'.
  SORT IT_LIST BY NO.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program       = d_repid
      i_callback_user_command  = 'F_USER_COMMAND'
      i_callback_pf_status_set = 'F_GUI_STATUS'
      is_layout                = wa_layout
      it_fieldcat              = t_fieldcat[]
      it_events                = t_events[]
      it_event_exit            = t_event_exit[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = wa_variante
      is_print                 = t_print
      it_sort                  = t_sort[]
      it_excluding             = t_excluding[]
      i_bypassing_buffer       = 'X'
    tables
      t_outtab                 = IT_LIST
    exceptions
      program_error            = 1
      others                   = 2.

ENDFORM.                    " F_LIST_DETAIL



*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'LSTATUS'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA : WA_RESULT LIKE LINE OF IT_LIST.

  SY-LSIND = 0.
  CLEAR LS_REF1.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  CLEAR FU_UCOMM.
  FU_UCOMM = SY-UCOMM.
  CASE FU_UCOMM.
    WHEN 'LBACK'.
      R1 = 'X'.
      R = ''.
      R2 = ''.
      LEAVE TO TRANSACTION 'ZQM014'.
      CLEAR FU_UCOMM.
    WHEN 'REF'.
      PERFORM DISPLAY_DATA.
      CLEAR FU_UCOMM.
    WHEN 'LIS'.
      R1 = 'X'.
      CLEAR R2.
      PERFORM DISPLAY_DATA.
      CLEAR FU_UCOMM.
    WHEN '&EXEC'.
      R2 = 'X'.
      CLEAR: R1, R.
*        tampilkan semua data yang tidak dieksekusi
*        karena sudah masuk ke ZTABEL
      CLEAR :IT_ZTDELINSP_I[], IT_INSLOT[]. REFRESH: IT_ZTDELINSP_I[], IT_INSLOT[], FIELDS[].
      CLEAR: WA_ZTDELINSP_I, WA_INSLOT.
            SELECT *
              FROM ZTDELINSP_I
              INTO CORRESPONDING FIELDS OF TABLE IT_ZTDELINSP_I
              WHERE PRUEFLOS NE '000000000000'.
            IF SY-SUBRC = 0.
              LOOP AT IT_ZTDELINSP_I WHERE PRUEFLOS NE '000000000000'.
                CLEAR WA_INSLOT.
                MOVE IT_ZTDELINSP_I-PRUEFLOS TO WA_INSLOT-INSLOT.
                APPEND  WA_INSLOT TO  IT_INSLOT.
              ENDLOOP.
            ENDIF.

            CLEAR CTR.
            DESCRIBE TABLE IT_INSLOT LINES CTR.
            IF CTR > 0.
              FIELDS-TABNAME = 'ZTDELINSP_I'.
              FIELDS-FIELDNAME = 'INSLOTPROCTXT'.
              APPEND FIELDS.

              CALL FUNCTION 'POPUP_TO_SHOW_DB_DATA_IN_TABLE'
                EXPORTING
                  TITLE_TEXT              = 'Last Processed Inspection Lot'
                TABLES
                  FIELDS                  = FIELDS
                  VALUETAB                = IT_INSLOT
*               EXCEPTIONS
*                 FIELD_NOT_IN_DDIC       = 1
*                 OTHERS                  = 2
                        .
              IF SY-SUBRC <> 0.
* Implement suitable error handling here
              ENDIF.

            ENDIF.
      PERFORM DISPLAY_DATA.
      CLEAR FU_UCOMM.
    WHEN '&DWL'.
      PERFORM DWL_PDA.
      CLEAR FU_UCOMM.
    WHEN '&DWLE'.
      PERFORM DWL_EXCEL.
      CLEAR FU_UCOMM.
    WHEN '&F03' OR '&F15' OR '&F12' OR 'YES'.
*      LEAVE TO TRANSACTION 'ZQM014'.
      LEAVE TO SCREEN '1000'.
      CLEAR FU_UCOMM.
      CLEAR R2.
  ENDCASE.

**  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  REFRESH_DATA
*&---------------------------------------------------------------------*
FORM REFRESH_DATA.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LIST_DATA
*&---------------------------------------------------------------------*
FORM LIST_DATA.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXECUTION_DATA
*&---------------------------------------------------------------------*
FORM EXECUTION_DATA.
*  SUBMIT ZQM_DEL_INSPECTION AND RETURN.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DWL_DATA_TOPDA
*&---------------------------------------------------------------------*
FORM DWL_PDA.
 DATA:BEGIN OF it_download OCCURS 0,
        data TYPE string,
      END OF it_download,
      F_NAME TYPE STRING.

 CLASS cl_abap_char_utilities DEFINITION LOAD.
 CONSTANTS:
 con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

  CLEAR : F_NAME, P_FILE, IT_DOWNLOAD[].
  REFRESH : IT_DOWNLOAD[].

  READ TABLE IT_LIST INDEX 1.
  IF SY-SUBRC = 0.
      CLEAR IT_DOWNLOAD.
      LOOP AT IT_LIST.
        CLEAR CTR.
        CONCATENATE IT_LIST-VBELN
                    IT_LIST-PRUEFLOS
                    IT_LIST-ENSTEHDAT
                    IT_LIST-VNAME
                    IT_LIST-VCODE
        INTO it_download-data
        SEPARATED BY con_tab.
        APPEND it_download.
        CLEAR  it_download.
      ENDLOOP.
  ENDIF.

    CALL FUNCTION 'WS_FILENAME_GET'
       EXPORTING
            DEF_FILENAME     = ' '
            DEF_PATH         = 'C:\'
            MASK             = ',*.txt.'
            MODE             = 'S'
            TITLE            = TEXT-011
       IMPORTING
            FILENAME         = P_FILE
       EXCEPTIONS
            INV_WINSYS       = 01
            NO_BATCH         = 02
            SELECTION_CANCEL = 03
            SELECTION_ERROR  = 04.


  MOVE P_FILE TO F_NAME.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*        BIN_FILESIZE                    = '#'
      FILENAME                        = F_NAME"'C:\tmp\test1.txt'
     FILETYPE                        = 'ASC'
    TABLES
      DATA_TAB                        = it_download.
  IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DWL_DATA_TOEXCEL
*&---------------------------------------------------------------------*
FORM DWL_EXCEL.
  TABLES RLGRAP.
  DATA:  DEF_PATH LIKE RLGRAP-FILENAME.
  DATA: TMP_FILENAME LIKE RLGRAP-FILENAME.
  DATA V_FILENAME TYPE STRING.

  DATA : BEGIN OF IT_FIELDNAMES OCCURS 0,
           FIELD(30),
         END OF IT_FIELDNAMES.


    CLEAR : P_FILE.

**fill header
    IT_FIELDNAMES-FIELD = 'No.'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.

    IT_FIELDNAMES-FIELD = 'Delivery Order'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.

    IT_FIELDNAMES-FIELD = 'Inspection Lot'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.

    IT_FIELDNAMES-FIELD = 'Inspection Lot Creation'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.

    IT_FIELDNAMES-FIELD = 'Inspector'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.

    IT_FIELDNAMES-FIELD = 'Usage Decision'.
    APPEND IT_FIELDNAMES.
    CLEAR  IT_FIELDNAMES.


    CALL FUNCTION 'WS_FILENAME_GET'
       EXPORTING
            DEF_FILENAME     = RLGRAP-FILENAME
            DEF_PATH         = DEF_PATH
            MASK             = ',*.xls.'
            MODE             = 'S'
            TITLE            = TEXT-011
       IMPORTING
            FILENAME         = TMP_FILENAME
       EXCEPTIONS
            INV_WINSYS       = 01
            NO_BATCH         = 02
            SELECTION_CANCEL = 03
            SELECTION_ERROR  = 04.
     IF SY-SUBRC = 0.
        RLGRAP-FILENAME = TMP_FILENAME.
      ELSE.
        EXIT.
      ENDIF.

  V_FILENAME = RLGRAP-FILENAME.
  IF V_FILENAME CS '.xls'.
  ELSE.
    CONCATENATE V_FILENAME '.xls'INTO V_FILENAME.
  ENDIF.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME              = V_FILENAME
      FILETYPE              = 'ASC'
*     MODE                  = ' '
      write_field_separator = 'X'
      CONFIRM_OVERWRITE     = 'X'
      SHOW_TRANSFER_STATUS  = 'X'
*      WK1_N_SIZE            = 30
*      WK1_T_SIZE            = 30
    TABLES
      DATA_TAB              = IT_LIST
      FIELDNAMES            = IT_FIELDNAMES.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'Download error'.
    STOP.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON1 USING FU_TYPES
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
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon1