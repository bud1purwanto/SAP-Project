*&---------------------------------------------------------------------*
*& Report  ZPPC_UPLOAD_QMVIEW
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPC_UPLOAD_QMVIEW.
TYPE-POOLS: ICON.

INCLUDE ZZBDCREX3.

DATA : FNAME type STRING,
*       FPATH type IBIPPARMS-PATH,
       MSG_ERROR TYPE C LENGTH 250,
       VCURSOR1 TYPE C LENGTH 40,
       VCURSOR2 TYPE C LENGTH 40,
       PSTAT LIKE MARA-PSTAT,
       MTART LIKE MARA-MTART.

DATA: BEGIN OF IT_DATA OCCURS 0,
        MATNR(18) TYPE C,
        WERKS(4)  TYPE C,
        PRFRQ(6)  TYPE C,
        QMPUR(1)  TYPE C,
        SSQSS(4)  TYPE C,
        QZGTP(4)  TYPE C,
        QSSYS(4)  TYPE C,
      END OF IT_DATA.

DATA: BEGIN OF IT_DISPLAY OCCURS 0,
          NO TYPE I,
*          MATNR(18) TYPE C,
          MESSAGE(150) TYPE C,
      END OF IT_DISPLAY.

DATA: GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
       G_EXIT_CAUSED_BY_CALLER,
       GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
       GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
       G_REPID LIKE SY-REPID,
       Y_PRINT TYPE SLIS_PRINT_ALV.

DATA:
      GT_EVENTS TYPE SLIS_T_EVENT,
      GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
      G_STATUS_SET TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
      G_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND',
      G_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
      G_TOP_OF_LIST TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
      G_END_OF_LIST TYPE SLIS_FORMNAME VALUE 'END_OF_LIST'.

DATA : GS_VARIANT LIKE DISVARIANT, G_SAVE.

INITIALIZATION.
  G_REPID = SY-REPID. "call report id
  Y_PRINT-NO_PRINT_SELINFOS = 'X'.
  Y_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT USING GS_LAYOUT. "call ALV layout for report by gs_layout
  PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
  GS_VARIANT-REPORT = G_REPID.
  G_SAVE = 'A'.


SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE text-001.

PARAMETERS: FPATH LIKE RLGRAP-FILENAME MEMORY ID pid LOWER CASE OBLIGATORY.

SELECTION-SCREEN END OF BLOCK 1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FPATH.
  CALL FUNCTION 'WS_FILENAME_GET'
      EXPORTING
           def_path         = 'C:\'
           mask             = ',*.*,*.*.'
           mode             = 'O'
      IMPORTING
          filename         = FPATH
      EXCEPTIONS
           inv_winsys       = 1
           no_batch         = 2
           selection_cancel = 3
           selection_error  = 4
           OTHERS           = 5.

START-OF-SELECTION.

  MOVE FPATH to FNAME.

*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      FILENAME            = FNAME
*      FILETYPE            = 'ASC'
*      HAS_FIELD_SEPARATOR = 'X'
*    TABLES
*      data_tab            = IT_DATA
*    EXCEPTIONS
*      conversion_error    = 1
*      invalid_table_width = 2
*      invalid_type        = 3
*      no_batch            = 4
*      unknown_error       = 5
*      file_open_error     = 6
*      file_read_error     = 7
*      OTHERS              = 8.

  IF sy-subrc <> 0.
    message i000(0k) with 'File cannot be opened'.
    stop.
  ENDIF.

perform open_group.

perform bdc_dynpro      using '/SAPDMC/SAPMLSMW' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              '/SAPDMC/LSSCREEN-PROJECT'.
perform bdc_field       using 'BDC_OKCODE'
                              '=CONT'.
perform bdc_field       using '/SAPDMC/LSSCREEN-PROJECT'
                              'TRIAS-QM'.
perform bdc_field       using '/SAPDMC/LSSCREEN-SUBPROJ'
                              'MATERIAL'.
perform bdc_field       using '/SAPDMC/LSSCREEN-OBJECT'
                              'CHANGE QM'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(07)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TOGGLE'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '07/59'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TRPI'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_060' '0210'.
perform bdc_field       using 'BDC_CURSOR'
                              '/SAPDMC/LSFSCREEN-FILENAME'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-FILENAME'
                              FPATH.
*                              'C:\Users\Subandi\Desktop\Test Upload I'
*                            & 'B GL(2).txt'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-FILETEXT'
                              'QM'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-X_FLATTAB'
                              'X'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-X_DELTAB'
                              'X'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-X_COLORDER'
                              'X'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-X_ENDOFREC'
                              'X'.
perform bdc_field       using '/SAPDMC/LSFSCREEN-X_ASCII'
                              'X'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '07/59'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SAVE'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '07/59'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TRRT'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(08)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TOGGLE'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SAVE'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TRRT'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(09)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using '/1CADMC/SAP_LSMW_READ_00000007' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              'SO_TCNTR-LOW'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_field       using 'P_CNVAMT'
                              'X'.
perform bdc_field       using 'P_CNVDAT'
                              'X'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_dynpro      using '/1CADMC/SAP_LSMW_READ_00000007' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EE'.
perform bdc_field       using 'BDC_CURSOR'
                              'SO_TCNTR-LOW'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(10)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_080' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              '/SAPDMC/LSSCREEN-FROMLINE'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using '/SAPDMC/LSSCREEN-TOLINE'
                              '10000'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(11)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using '/1CADMC/SAP_LSMW_CONV_00000007' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              'SO_TCNTR-LOW'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_dynpro      using '/1CADMC/SAP_LSMW_CONV_00000007' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EE'.
perform bdc_field       using 'BDC_CURSOR'
                              'SO_TCNTR-LOW'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(12)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_080' '0300'.
perform bdc_field       using 'BDC_CURSOR'
                              '/SAPDMC/LSSCREEN-FROMLINE'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTE'.
perform bdc_field       using '/SAPDMC/LSSCREEN-TOLINE'
                              '10000'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(13)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=PICK'.
perform bdc_dynpro      using 'SAPLSPO5' '0120'.
perform bdc_field       using 'BDC_OKCODE'
                              '=OK'.
perform bdc_field       using 'BDC_CURSOR'
                              'SPOPLI-SELFLAG(01)'.
perform bdc_dynpro      using 'RMDATIND' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              '%%%_R_P'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SPOS'.
perform bdc_field       using '%%%_R_L'
                              ''.
perform bdc_field       using 'LDS_NAME'
                              'MATERIAL_MASTER_BTCI_LOG'.
perform bdc_field       using '%%%_R_P'
                              'X'.
perform bdc_field       using '%%%_PHY'
                              'TRIAS-QM_MATERIAL_CHANGE_QM.lsmw.conv'.
perform bdc_field       using 'UC'
                              'X'.
perform bdc_field       using 'MAX_ERR'
                              '   100'.
perform bdc_field       using 'MAX_COMM'
                              '   500'.
perform bdc_field       using 'LEVEL'
                              '4'.
perform bdc_field       using 'ERF_MELD'
                              'X'.
perform bdc_field       using 'SPERR'
                              'E'.
perform bdc_field       using 'PRF_KZ'
                              'W'.
perform bdc_field       using 'FLAG_M'
                              'X'.
perform bdc_dynpro      using 'SAPLSVAR' '0281'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACKLIST'.
perform bdc_dynpro      using 'RMDATIND' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              '%%%_R_P'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_field       using 'LDS_NAME'
                              'MATERIAL_MASTER_BTCI_LOG'.
perform bdc_field       using '%%%_R_P'
                              'X'.
perform bdc_field       using '%%%_PHY'
                              'TRIAS-QM_MATERIAL_CHANGE_QM.lsmw.conv'.
perform bdc_field       using 'UC'
                              'X'.
perform bdc_field       using 'MAX_ERR'
                              '   100'.
perform bdc_field       using 'MAX_COMM'
                              '   500'.
perform bdc_field       using 'LEVEL'
                              '4'.
perform bdc_field       using 'ERF_MELD'
                              'X'.
perform bdc_field       using 'SPERR'
                              'E'.
perform bdc_field       using 'PRF_KZ'
                              'W'.
perform bdc_field       using 'FLAG_M'
                              'X'.
perform bdc_dynpro      using 'SAPLSBAL_DISPLAY' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=&F03'.
perform bdc_dynpro      using 'RMDATIND' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EE'.
perform bdc_field       using 'BDC_CURSOR'
                              'LDS_NAME'.
perform bdc_dynpro      using '/SAPDMC/SAPLLSMW_OBJ_000' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EBACK'.
perform bdc_field       using 'BDC_CURSOR'
                              'GT_STEPLIST-STEPTEXT(01)'.
perform bdc_dynpro      using '/SAPDMC/SAPMLSMW' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EBACK'.
perform bdc_field       using 'BDC_CURSOR'
                              '/SAPDMC/LSSCREEN-PROJECT'.
perform bdc_transaction using 'LSMW'.

perform close_group.

IT_DISPLAY-NO = 0.
loop at messtab.
   SELECT SINGLE T100~TEXT INTO (IT_DISPLAY-MESSAGE)
          FROM T100 WHERE SPRSL = MESSTAB-MSGSPRA
                           AND   ARBGB = MESSTAB-MSGID
                           AND   MSGNR = MESSTAB-MSGNR.
   IT_DISPLAY-NO = IT_DISPLAY-NO + 1.
   APPEND IT_DISPLAY.
endloop.


PERFORM DISPLAY.

FORM DISPLAY.
*tambahan untuk ALV
perform build_fieldcatalog.
perform comment_build using gt_list_top_of_page[].

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program = g_repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat[]
      is_print           = y_print
      i_save             = g_save
      is_variant         = gs_variant
      it_events          = gt_events[]
    tables
      t_outtab           = IT_DISPLAY
    exceptions
      program_error      = 1
      others             = 2.

if sy-subrc <> 0.
*  message 'Sorry, Report cannot be generated' type i.
endif.
ENDFORM.

form build_fieldcatalog.
  data: xfieldcat type slis_fieldcat_alv,
        n type i.

  refresh gt_fieldcat.
  n = 0.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'NO'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Nomor'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  xfieldcat-fix_column = 'X'.
  xfieldcat-emphasize = 'C110'.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MESSAGE'.
  XFIELDCAT-SELTEXT_M = 'Message'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

endform. "build_fieldcatalog

form layout_init using rs_layout type slis_layout_alv.
  rs_layout-detail_popup = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
endform.            "Layout_init

form eventtab_build using rt_events type slis_t_event.
  data : ls_event type slis_alv_event.
  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type = 0
    importing
      et_events = rt_events.

    read table rt_events with key name = slis_ev_top_of_page
                              into ls_event.

    if sy-subrc = 0.
      move g_top_of_page to ls_event-form.
      append ls_event to rt_events.
    endif.
endform.              "eventtab_build

form comment_build using lt_top_of_page type slis_t_listheader.
    data: ls_line type slis_listheader.

    clear ls_line.
    refresh lt_top_of_page.
    ls_line-typ = 'H'.
    ls_line-info = 'PT.Trias Sentosa, Tbk.'.
    append ls_line to lt_top_of_page.
    clear ls_line.
    ls_line-typ = 'A'.
    ls_line-info = 'Report Upload Material Master QM'.
    append ls_line to lt_top_of_page.
endform.

form top_of_page.
  call function 'REUSE_ALV_COMMENTARY_WRITE'
  exporting
    i_logo      = ' '
    it_list_commentary = gt_list_top_of_page.
endform.