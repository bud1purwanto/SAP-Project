report ZCOC_UPLOAD_KE21N
       no standard page heading line-size 255.

TYPE-POOLS: ICON.
INCLUDE ZBDCREX3.

DATA : FNAME type STRING.

*DATA : BEGIN OF IT_DETAIL OCCURS 0,
*        BUDAT(10) TYPE C,
*        PERDE(2)  TYPE C,
*        MATNR(18) TYPE C,
*        VALUE(18) TYPE C,
*       END OF IT_DETAIL.

DATA : BEGIN OF IT_DISPLAY OCCURS 0,
        DOC(15)   TYPE C,
        BUDAT(10) TYPE C,
        PERDE(2)  TYPE C,
        MATNR(18) TYPE C,
        VALUE(18) TYPE C,
        MSG(150)  TYPE C,
        ICON(4)   TYPE C,
       END OF IT_DISPLAY.

DATA: BEGIN OF IT_DETAIL OCCURS 0,
         VBUKRS(40), "ADD FOR NEW COMPANY
         MATNR(18) TYPE C,
         VALUE(18) TYPE C,
      END OF IT_DETAIL.

DATA:  IT_DETAIL2 LIKE BAPI_COPA_DATA OCCURS 0 WITH HEADER LINE,
       IT_FIELD LIKE BAPI_COPA_FIELD OCCURS 0  WITH HEADER LINE,
       IT_RETURN LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.

"add for new company
DATA: ITAB2 LIKE IT_DETAIL OCCURS 0 WITH HEADER LINE,
      VLINE TYPE I,
      VCO(8),
      VMSG(50),
      ZBUKRS(4),
      ZPLANT(4),
      VOPCN(4).
"end add for new company

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

PARAMETERS: FPATH LIKE RLGRAP-FILENAME MEMORY ID pid LOWER CASE OBLIGATORY,
            PERIO TYPE C LENGTH 7 OBLIGATORY,
            BUDAT LIKE MKPF-BUDAT OBLIGATORY.

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
      data_tab            = IT_DETAIL
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

   IT_FIELD-FIELDNAME = 'PALEDGER'. "Currency Type
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'PERIO'. "Period
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'BUDAT'. "Posting Date
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'VRGAR'. "Record Type
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'BUKRS'. "Company code
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'ARTNR'. "MATNR
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'WERKS'. "Plant
   APPEND IT_FIELD.
   IT_FIELD-FIELDNAME = 'VV044'. "Adjustment
   APPEND IT_FIELD.


*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'PALEDGER'. "Currency Type
*   IT_DETAIL2-VALUE     = 'B0'.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'PERIO'. "Period
*   IT_DETAIL2-VALUE     = PERIO.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'BUDAT'. "Posting Date
*   IT_DETAIL2-VALUE     = BUDAT.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'VRGAR'. "Record Type
*   IT_DETAIL2-VALUE     = 'F'.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'BUKRS'. "Company code
*   IT_DETAIL2-VALUE     = '9999'.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'WERKS'. "Plant
*   IT_DETAIL2-VALUE     = '2000'.
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'ARTNR'. "Material Number
*   APPEND IT_DETAIL2.
*
*   IT_DETAIL2-RECORD_ID = '1'.
*   IT_DETAIL2-FIELDNAME = 'VV044'. "Adjustment
*   APPEND IT_DETAIL2.

LOOP AT IT_DETAIL.
  CLEAR: IT_DETAIL2.
  REFRESH: IT_DETAIL2.

  PERFORM SET_INPUTDATA. " add New Company

  LOOP AT IT_DETAIL2 WHERE FIELDNAME = 'ARTNR' OR FIELDNAME = 'VV044'.
    IF IT_DETAIL2-FIELDNAME = 'ARTNR'.
      IT_DETAIL2-VALUE     = IT_DETAIL-MATNR.
      MODIFY IT_DETAIL2.
    ELSEIF IT_DETAIL2-FIELDNAME = 'VV044'.
      IT_DETAIL2-VALUE     = IT_DETAIL-VALUE.
      IT_DETAIL2-CURRENCY  = 'USD'.
      MODIFY IT_DETAIL2.
    ENDIF.
  ENDLOOP.

   CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
       EXPORTING
            OPERATINGCONCERN = VOPCN
            TESTRUN          = ' '
       TABLES
            INPUTDATA        = IT_DETAIL2
            FIELDLIST        = IT_FIELD
            RETURN           = IT_RETURN.


IF IT_RETURN[] IS INITIAL.

   CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
         IMPORTING
           RETURN        = IT_RETURN.

    IT_DISPLAY-BUDAT = BUDAT.
    IT_DISPLAY-MATNR = IT_DETAIL-MATNR.
    IT_DISPLAY-VALUE = IT_DETAIL-VALUE.
    IT_DISPLAY-MSG = 'Success'.
    IT_DISPLAY-ICON = ICON_GREEN_LIGHT.
    APPEND IT_DISPLAY.

ELSE.

  LOOP AT IT_RETURN.
    IT_DISPLAY-BUDAT = BUDAT.
    IT_DISPLAY-MATNR = IT_DETAIL-MATNR.
    IT_DISPLAY-VALUE = IT_DETAIL-VALUE.
    IT_DISPLAY-MSG = IT_RETURN-MESSAGE.
    IT_DISPLAY-ICON = ICON_RED_LIGHT.
    APPEND IT_DISPLAY.
  ENDLOOP.

ENDIF.

ENDLOOP.

*LOOP AT IT_DETAIL.
*
*      perform open_group.
*
*      perform bdc_dynpro      using 'SAPMKEI2' '0100'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'RADIOCURR2'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=NEXT'.
*      perform bdc_field       using 'CEST1-VRGAR'
*                                    'F'.
*      perform bdc_field       using 'CEST1-BUDAT'
*                                    IT_DETAIL-BUDAT."'01.02.2013'.
*      perform bdc_field       using 'CEST1-PERDE'
*                                    IT_DETAIL-PERDE."'2'.
*      perform bdc_field       using 'RADIOVAL1'
*                                    'X'.
*      perform bdc_field       using 'RADIOCURR1'
*                                    ''.
*      perform bdc_field       using 'RADIOCURR2'
*                                    'X'.
*      perform bdc_dynpro      using 'SAPMKEI2' '0200'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=ABLT'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'GT_LINES-VALUE(12)'.
*      perform bdc_field       using 'GT_LINES-VALUE(02)'
*                                    '9999'.
*      perform bdc_field       using 'GT_LINES-VALUE(12)'
*                                    IT_DETAIL-MATNR."'JRICRI'.
*      perform bdc_field       using 'GT_LINES-VALUE(13)'
*                                    '2000'.
*      perform bdc_dynpro      using 'SAPMKEI2' '0200'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=TAB2'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'GT_LINES-VALUE(03)'.
*      perform bdc_dynpro      using 'SAPMKEI2' '0200'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=P+'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'GT_LINES_VAL-VALUE(01)'.
*      perform bdc_field       using 'CEST1-FRWAE'
*                                    'USD'.
**      perform bdc_dynpro      using 'SAPMKEI2' '0200'.
**      perform bdc_field       using 'BDC_OKCODE'
**                                    '=P+'.
**      perform bdc_field       using 'BDC_CURSOR'
**                                    'GT_LINES_VAL-VALUE(01)'.
**      perform bdc_field       using 'CEST1-FRWAE'
**                                    'USD'.
*      perform bdc_dynpro      using 'SAPMKEI2' '0200'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=BUCH'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'GT_LINES_VAL-VALUE(05)'.
*      perform bdc_field       using 'CEST1-FRWAE'
*                                    'USD'.
*      perform bdc_field       using 'GT_LINES_VAL-VALUE(05)'
*                                    IT_DETAIL-VALUE."'10'.
*      perform bdc_transaction using 'KE21N'.
*
*      perform close_group.
*
*
*      LOOP AT MESSTAB.
*        SELECT SINGLE T100~TEXT INTO (IT_DISPLAY-MSG)
*          FROM T100
*          WHERE T100~SPRSL = 'EN'
*          AND T100~ARBGB = MESSTAB-MSGID
*          AND T100~MSGNR = MESSTAB-MSGNR.
*
*          IT_DISPLAY-BUDAT = IT_DETAIL-BUDAT.
*          IT_DISPLAY-PERDE = IT_DETAIL-PERDE.
*          IT_DISPLAY-MATNR = IT_DETAIL-MATNR.
*          IT_DISPLAY-VALUE = IT_DETAIL-VALUE.
*          IF MESSTAB-MSGTYP = 'E'.
*            IT_DISPLAY-ICON = ICON_RED_LIGHT.
*          ELSE.
*            IT_DISPLAY-ICON = ICON_GREEN_LIGHT.
*            IT_DISPLAY-DOC  = MESSTAB-MSGV1.
*          ENDIF.
*          APPEND IT_DISPLAY.
*      ENDLOOP.
*
*
*ENDLOOP.

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

Form build_fieldcatalog.
  data: xfieldcat type slis_fieldcat_alv,
        n type i.

  refresh gt_fieldcat.
  n = 0.

*  n = n + 1.
*  clear xfieldcat.
*  xfieldcat-fieldname = 'DOC'.
*  "xfieldcat-tabname  = 'IT_DETAILS'.
*  XFIELDCAT-SELTEXT_M = 'Document Number'.
**  xfieldcat-row_pos = 1.
*  xfieldcat-col_pos = n.
*  xfieldcat-outputlen = 20.
*  xfieldcat-fix_column = 'X'.
*  xfieldcat-emphasize = 'C110'.
*  append xfieldcat to gt_fieldcat.
*
  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'BUDAT'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Posting Date'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.
*
*    n = n + 1.
*  clear xfieldcat.
*  xfieldcat-fieldname = 'PERDE'.
*  "xfieldcat-tabname  = 'IT_DETAILS'.
*  XFIELDCAT-SELTEXT_M = 'Period'.
**  xfieldcat-row_pos = 1.
*  xfieldcat-col_pos = n.
*  xfieldcat-outputlen = 20.
*  append xfieldcat to gt_fieldcat.
*
  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MATNR'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Material Number'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.
*
*
  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'VALUE'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Value'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'MSG'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Message'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

  n = n + 1.
  clear xfieldcat.
  xfieldcat-fieldname = 'ICON'.
  "xfieldcat-tabname  = 'IT_DETAILS'.
  XFIELDCAT-SELTEXT_M = 'Status'.
*  xfieldcat-row_pos = 1.
  xfieldcat-col_pos = n.
  xfieldcat-outputlen = 20.
  append xfieldcat to gt_fieldcat.

ENDFORM.

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

*    clear ls_line.
*    refresh lt_top_of_page.
*    ls_line-typ = 'H'.
*    ls_line-info = 'PT.Trias Sentosa, Tbk.'.
*    append ls_line to lt_top_of_page.
    clear ls_line.
    ls_line-typ = 'H'." 'A'.
    ls_line-info = 'Report Adjustment to COPA'.
    append ls_line to lt_top_of_page.
endform.

form top_of_page.
  call function 'REUSE_ALV_COMMENTARY_WRITE'
  exporting
    i_logo      = ' '
    it_list_commentary = gt_list_top_of_page.
endform.

*&---------------------------------------------------------------------*
*&      Form  SET_INPUTDATA
*&---------------------------------------------------------------------*
*       text  "ADD NEW COMPANY
*----------------------------------------------------------------------*
FORM SET_INPUTDATA.
  IF IT_DETAIL-VBUKRS EQ '9999'.
    ZBUKRS = IT_DETAIL-VBUKRS.
    ZPLANT = '2000'.
    VOPCN = '8888'.
  ELSEIF IT_DETAIL-VBUKRS EQ '9701'.
    ZBUKRS = IT_DETAIL-VBUKRS.
    ZPLANT = 'TTA2'.
    VOPCN = '8888'.
  ELSEIF IT_DETAIL-VBUKRS EQ '6500'.
    ZBUKRS = IT_DETAIL-VBUKRS.
    ZPLANT = 'TTE'.
    VOPCN = '6500'.
  ENDIF.


  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'PALEDGER'. "Currency Type
  IT_DETAIL2-VALUE     = 'B0'.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'PERIO'. "Period
  IT_DETAIL2-VALUE     = PERIO.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'BUDAT'. "Posting Date
  IT_DETAIL2-VALUE     = BUDAT.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'VRGAR'. "Record Type
  IT_DETAIL2-VALUE     = 'F'.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'BUKRS'. "Company code
  IT_DETAIL2-VALUE     = ZBUKRS. "'9999'.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'WERKS'. "Plant
  IT_DETAIL2-VALUE     = ZPLANT. "'2000'.
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'ARTNR'. "Material Number
  APPEND IT_DETAIL2.

  IT_DETAIL2-RECORD_ID = '1'.
  IT_DETAIL2-FIELDNAME = 'VV044'. "Adjustment
  APPEND IT_DETAIL2.
ENDFORM.                    "SET_INPUTDATA