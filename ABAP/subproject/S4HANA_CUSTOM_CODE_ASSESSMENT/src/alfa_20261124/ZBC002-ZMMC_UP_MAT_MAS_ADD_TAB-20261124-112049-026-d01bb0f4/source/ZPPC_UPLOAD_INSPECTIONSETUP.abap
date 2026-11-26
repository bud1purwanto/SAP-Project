*&---------------------------------------------------------------------*
*& Report  ZPPC_UPLOAD_INSPECTIONSETUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPC_UPLOAD_INSPECTIONSETUP.

TYPE-POOLS: ICON.

INCLUDE ZZBDCREX3.

DATA : FNAME type STRING,
*       FPATH type IBIPPARMS-PATH,
       MSG_ERROR TYPE C LENGTH 250.

DATA: BEGIN OF IT_DATA OCCURS 0,
          WERKS1(4) TYPE C,
          MATNR(18) TYPE C,
          MTART(4) TYPE C,
          APA(1)   TYPE C,
          ART(8)   TYPE C,
      END OF IT_DATA.

DATA: BEGIN OF IT_DISPLAY OCCURS 0,
          WERKS(15) TYPE C,
          MATNR(18) TYPE C,
          MTART(4) TYPE C,
          ART(8)   TYPE C,
          MESSAGE(150) TYPE C,
          ICON(4)  TYPE C,
      END OF IT_DISPLAY.

DATA: IT_DATA2 LIKE IT_DATA OCCURS 0 WITH HEADER LINE.

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

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FNAME
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      data_tab            = IT_DATA
    EXCEPTIONS
      conversion_error    = 1
      invalid_table_width = 2
      invalid_type        = 3
      no_batch            = 4
      unknown_error       = 5
      file_open_error     = 6
      file_read_error     = 7
      OTHERS              = 8.

  IF sy-subrc <> 0.
    message i000(0k) with 'File cannot be opened'.
    stop.
  ENDIF.

IT_DATA2[] = IT_DATA[].
SORT IT_DATA2 ASCENDING BY WERKS1 ART.
DELETE ADJACENT DUPLICATES FROM IT_DATA2 COMPARING WERKS1 ART.

LOOP AT IT_DATA2.

    perform open_group.

  IF IT_DATA2-MATNR IS INITIAL.

    perform bdc_dynpro      using 'RQMQMM00' '1000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'G_MTART-LOW'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=MOD4'.
    perform bdc_field       using 'G_WERKS-LOW'
                                  IT_DATA2-WERKS1."'2000'.
*    perform bdc_field       using 'G_WERKS-HIGH'
*                                  IT_DATA2-WERKS2."'2000'.
*    perform bdc_field       using 'G_MATNR-LOW'
*                                  IT_DATA-MATNR.
    perform bdc_field       using 'G_MTART-LOW'
                                  IT_DATA2-MTART."'zraw'.
  ELSE.

    perform bdc_dynpro      using 'RQMQMM00' '1000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'G_MTART-LOW'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=%002'.
    perform bdc_field       using 'G_WERKS-LOW'
                                  IT_DATA2-WERKS1."'2000'.
*    perform bdc_field       using 'G_WERKS-HIGH'
*                                  IT_DATA2-WERKS2."'2000'.
*    perform bdc_field       using 'G_MATNR-LOW'
*                                  IT_DATA-MATNR.
    perform bdc_field       using 'G_MTART-LOW'
                                  IT_DATA2-MTART."'zraw'.

  LOOP AT IT_DATA WHERE WERKS1 = IT_DATA2-WERKS1 AND ART = IT_DATA2-ART.
    perform bdc_dynpro      using 'SAPLALDB' '3000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'RSCSEL_255-SLOW_I(01)'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=LINS'.
    perform bdc_field       using 'RSCSEL_255-SLOW_I(01)'
                                  IT_DATA-MATNR.
  ENDLOOP.

    perform bdc_dynpro      using 'SAPLALDB' '3000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'RSCSEL_255-SLOW_I(01)'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=ACPT'.

    perform bdc_dynpro      using 'RQMQMM00' '1000'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'G_MTART-LOW'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=MOD4'.

  ENDIF.

perform bdc_dynpro      using 'RQMQMM00' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_field       using 'BDC_CURSOR'
                              'G_ART4'.
perform bdc_field       using 'G_ART4'
                              IT_DATA2-ART."'Z0B'.

perform bdc_dynpro      using 'SAPLQPLS' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'RMQAM-APA(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=WEIT'.
perform bdc_field       using 'RMQAM-APA(01)'
                              IT_DATA2-APA."'X'.

perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=&ALL'.

perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BEAR'.

*perform bdc_dynpro      using 'SAPLSLVC_FULLSCREEN' '0500'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=&ALL'.
*
*perform bdc_dynpro      using 'SAPLSLVC_FULLSCREEN' '0500'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=BEAR'.
*
*perform bdc_dynpro      using 'SAPLSLVC_FULLSCREEN' '0500'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=&F03'.
*
perform bdc_dynpro      using 'RQMQMM00' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              'G_WERKS-LOW'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EE'.

perform bdc_transaction using 'QA08'.

perform close_group.

  LOOP AT IT_DATA WHERE WERKS1 = IT_DATA2-WERKS1 AND ART = IT_DATA2-ART.
    LOOP AT MESSTAB WHERE MSGTYP = 'S' AND MSGNR EQ '234'.
      IT_DISPLAY-WERKS = IT_DATA-WERKS1.
      IT_DISPLAY-MATNR = IT_DATA-MATNR.
      IT_DISPLAY-MTART = IT_DATA-MTART.
      IT_DISPLAY-ART   = IT_DATA-ART.
             SELECT SINGLE T100~TEXT INTO (IT_DISPLAY-MESSAGE)
              FROM T100 WHERE SPRSL = MESSTAB-MSGSPRA
                               AND   ARBGB = MESSTAB-MSGID
                               AND   MSGNR = MESSTAB-MSGNR.
      IT_DISPLAY-ICON    = ICON_GREEN_LIGHT.
      APPEND IT_DISPLAY.
    ENDLOOP.
  ENDLOOP.

  LOOP AT IT_DATA WHERE WERKS1 = IT_DATA2-WERKS1 AND ART = IT_DATA2-ART.
    LOOP AT MESSTAB WHERE MSGTYP = 'E'.
      IT_DISPLAY-WERKS = IT_DATA-WERKS1.
      IT_DISPLAY-MATNR = IT_DATA-MATNR.
      IT_DISPLAY-MTART = IT_DATA-MTART.
      IT_DISPLAY-ART   = IT_DATA-ART.
             SELECT SINGLE T100~TEXT INTO (IT_DISPLAY-MESSAGE)
              FROM T100 WHERE SPRSL = MESSTAB-MSGSPRA
                               AND   ARBGB = MESSTAB-MSGID
                               AND   MSGNR = MESSTAB-MSGNR.
      IT_DISPLAY-ICON    = ICON_RED_LIGHT.
      APPEND IT_DISPLAY.
    ENDLOOP.
   ENDLOOP.

ENDLOOP.

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
  xfieldcat-fieldname = 'WERKS'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Plant'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  xfieldcat-fix_column = 'X'.
  xfieldcat-emphasize = 'C110'.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MATNR'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Material Number'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  xfieldcat-fix_column = 'X'.
  xfieldcat-emphasize = 'C110'.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MTART'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Material Type'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'ART'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Inspection Type'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MESSAGE'.
  XFIELDCAT-SELTEXT_M = 'Message'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'ICON'.
  XFIELDCAT-SELTEXT_M = 'Indicator'.
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
    ls_line-info = 'Report Upload Inspection Setup'.
    append ls_line to lt_top_of_page.
endform.

form top_of_page.
  call function 'REUSE_ALV_COMMENTARY_WRITE'
  exporting
    i_logo      = ' '
    it_list_commentary = gt_list_top_of_page.
endform.