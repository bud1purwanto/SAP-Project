*&---------------------------------------------------------------------*
*&  Include           ZPPI_RESLIT_ROLL_F01
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
*       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME
*                                         P_MARK_NAME.
       CLEAR P_OK.

       IF P_TC_NAME = 'TC_MAINTAIN'.
         CLEAR: tmp_maintain2.
         REFRESH: tmp_maintain2.
         tmp_maintain2[] = it_maintain[].
         DELETE tmp_maintain2 WHERE flags = ''.
         SORT tmp_maintain2 BY mblnr mjahr matnr.
         DELETE ADJACENT DUPLICATES FROM tmp_maintain2 COMPARING mblnr mjahr matnr.
         UNASSIGN <fs_tmpmaintain2>.
         LOOP AT tmp_maintain2 ASSIGNING <fs_tmpmaintain2>.

           LOOP AT it_maintain ASSIGNING <fs_maintain> WHERE mblnr = <fs_tmpmaintain2>-mblnr AND
                                                             mjahr = <fs_tmpmaintain2>-mjahr AND
                                                             matnr = <fs_tmpmaintain2>-matnr.
             DELETE it_maintain INDEX syst-tabix.
           ENDLOOP.

         ENDLOOP.
         n = 0.
         LOOP AT it_maintain ASSIGNING <fs_maintain>.
           n = n + 1.
           <fs_maintain>-nomor = n.
         ENDLOOP.
       ENDIF.

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
*&      Form  GET_DATA_MAINTAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_DATA_MAINTAIN .

   CLEAR: it_maintain, wa_maintain, n.
   REFRESH: it_maintain.

   SELECT MSEG~MBLNR AS MBLNR MSEG~MJAHR AS MJAHR MSEG~ZEILE AS ZEILE
          MSEG~MATNR AS MATNR MSEG~CHARG AS CHARG MSEG~MENGE AS MENGE
          MSEG~LGORT AS LGORT
     FROM MSEG
     INTO CORRESPONDING FIELDS OF TABLE IT_MAINTAIN
    WHERE MBLNR IN SO_MBLNR AND MJAHR IN SO_MJAHR AND WERKS = SO_PLANT-LOW AND
          VGART_MKPF = 'WE' AND BWART = 101.

   SORT it_maintain BY charg.

   n = 0.
   UNASSIGN <fs_maintain>.
   LOOP AT it_maintain ASSIGNING <fs_maintain>.

     CLEAR: VSMBLN.
     SELECT SINGLE SMBLN
       INTO VSMBLN
       FROM MSEG
      WHERE SMBLN = <fs_maintain>-mblnr AND SJAHR = <fs_maintain>-mjahr.

     IF sy-subrc = 0.
       <fs_maintain>-mblnrc = 'X'.
     ENDIF.

     CHECK <fs_maintain>-mblnrc = ''.

*     n = n + 1.
*     <fs_maintain>-nomor = n.

     CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
     REFRESH: CHAR_OF_BATCH.

     PERFORM VB_INIT.

     CALL FUNCTION 'VB_BATCH_GET_DETAIL'
       EXPORTING
         MATNR                    = <fs_maintain>-MATNR
         CHARG                    = <fs_maintain>-CHARG
         WERKS                    = SO_PLANT-LOW
         GET_CLASSIFICATION       = 'X'
*        EXISTENCE_CHECK          =
*        READ_FROM_BUFFER         =
*        NO_CLASS_INIT            = ' '
*        LOCK_BATCH               = ' '
*      IMPORTING
*        YMCHA                    =
*        CLASSNAME                =
       TABLES
         CHAR_OF_BATCH            = CHAR_OF_BATCH
       EXCEPTIONS
         NO_MATERIAL              = 1
         NO_BATCH                 = 2
         NO_PLANT                 = 3
         MATERIAL_NOT_FOUND       = 4
         PLANT_NOT_FOUND          = 5
         NO_AUTHORITY             = 6
         BATCH_NOT_EXIST          = 7
         LOCK_ON_BATCH            = 8
         OTHERS                   = 9
               .
     IF SY-SUBRC <> 0.
*Implement suitable error handling here
     ENDIF.

     READ TABLE CHAR_OF_BATCH INDEX 1.
*     CHECK SY-SUBRC = 0.
     IF sy-subrc = 0.

       SORT CHAR_OF_BATCH BY ATINN.

       PERFORM GET_ATINN USING 'ZZCODE' CHANGING V_ATINN.
       READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATINN = V_ATINN BINARY SEARCH.
       IF sy-subrc = 0.
         <fs_maintain>-film = <FS_CHAR_OF_BATCH>-ATWTB.
         CLEAR: V_ATZHL.
         SELECT SINGLE ATZHL INTO V_ATZHL
           FROM CAWNT
          WHERE ATINN = V_ATINN AND ATWTB = <fs_maintain>-film.
         IF SY-SUBRC EQ 0.
           SELECT SINGLE ATWRT INTO <fs_maintain>-filmcd
             FROM CAWN
            WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
         ENDIF.
       ENDIF.

       PERFORM GET_ATINN USING 'ZZLENGTH' CHANGING V_ATINN.
       READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATINN = V_ATINN BINARY SEARCH.
       IF sy-subrc = 0.
         <fs_maintain>-length = <FS_CHAR_OF_BATCH>-ATWTB.
         REPLACE ALL OCCURRENCES OF RIBUAN IN <fs_maintain>-length WITH SPACE.
         CONDENSE <fs_maintain>-length NO-GAPS.
       ENDIF.

       PERFORM GET_ATINN USING 'ZZCONVERSIONROLLKG' CHANGING V_ATINN.
       READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATINN = V_ATINN BINARY SEARCH.
       IF sy-subrc = 0.
         REPLACE ALL OCCURRENCES OF 'Kg/Rol' IN <FS_CHAR_OF_BATCH>-ATWTB WITH SPACE.
         REPLACE ALL OCCURRENCES OF RIBUAN IN <FS_CHAR_OF_BATCH>-ATWTB WITH SPACE.
         CONDENSE <FS_CHAR_OF_BATCH>-ATWTB NO-GAPS.
         <fs_maintain>-conv = <FS_CHAR_OF_BATCH>-ATWTB.
       ENDIF.

     ENDIF.

     SELECT SINGLE CLABS
       INTO <fs_maintain>-CLABS
       FROM MCHB
      WHERE MATNR = <fs_maintain>-MATNR AND CHARG = <fs_maintain>-CHARG.

     IF <fs_maintain>-menge <= <fs_maintain>-clabs.
       <fs_maintain>-indc = '@5B@'.
     ELSE.
       <fs_maintain>-indc = '@5C@'.
     ENDIF.

   ENDLOOP.

   DELETE it_maintain WHERE mblnrc = 'X'.

   UNASSIGN: <fs_maintain>, <fs_tmpmaintain>.
   CLEAR: tmp_maintain.
   REFRESH: tmp_maintain.
   SORT it_maintain BY mblnr mjahr zeile matnr.
   tmp_maintain[] = it_maintain[].
   SORT tmp_maintain BY mblnr mjahr matnr.
   DELETE ADJACENT DUPLICATES FROM tmp_maintain COMPARING mblnr mjahr matnr.

   LOOP AT tmp_maintain ASSIGNING <fs_tmpmaintain>.
     UNASSIGN <fs_maintain>.
     LOOP AT it_maintain ASSIGNING <fs_maintain> WHERE mblnr = <fs_tmpmaintain>-mblnr AND
                                                       mjahr = <fs_tmpmaintain>-mjahr AND
                                                       zeile = <fs_tmpmaintain>-zeile AND
                                                       matnr = <fs_tmpmaintain>-matnr.
       <fs_maintain>-hdrlvl = 'X'.
     ENDLOOP.
   ENDLOOP.

   SORT it_maintain BY mblnr mjahr matnr.

   n = 0.
   UNASSIGN <fs_maintain>.
   LOOP AT it_maintain ASSIGNING <fs_maintain>.
     n = n + 1.
     <fs_maintain>-nomor = n.
   ENDLOOP.

 ENDFORM.                    " GET_DATA_MAINTAIN

*&---------------------------------------------------------------------*
*&      Form  GET_DEC_NOTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.

  DATA: USR01_EXP LIKE USR01.

  CALL FUNCTION 'CETA_USR01_READ'
    EXPORTING
      BNAME     = SY-UNAME
    IMPORTING
      USR01_EXP = USR01_EXP
    EXCEPTIONS
      NO_ENTRY  = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  IF USR01_EXP-DCPFM EQ ''.
    RIBUAN  = '.'.
    PULUHAN = ','.
  ELSEIF USR01_EXP-DCPFM EQ 'X'.
    RIBUAN  = ','.
    PULUHAN = '.'.
  ELSEIF USR01_EXP-DCPFM EQ 'Y'.
    RIBUAN  = SPACE.
    PULUHAN = ','.
  ENDIF.

ENDFORM.                    " GET_DEC_NOTATION
*&---------------------------------------------------------------------*
*&      Form  CREATE_PROCESS_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_PROCESS_ORDER USING P_MATNR   TYPE MATNR
                                P_PLANT   TYPE WERKS_D
                                P_AUFART  TYPE AUFART
                                P_VERID   TYPE VERID
                                P_QUANT   TYPE CHAR16
                                P_TANGGAL TYPE CHAR10
                       CHANGING FLAG
                                PROC_ORD.

  REFRESH BDCDATA.
  perform bdc_dynpro      using 'SAPLCOKO' '5100'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-MATNR'.

  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTK'.
  perform bdc_field       using 'CAUFVD-MATNR'
                                P_MATNR."'JRPAKI'.
  perform bdc_field       using 'CAUFVD-WERKS'
                                P_PLANT."'2000'.
  perform bdc_field       using 'AFPOD-PWERK'
                                ''.
  perform bdc_field       using 'AUFPAR-PI_AUFART'
                                P_AUFART."'ZRR2'.
  perform bdc_field       using 'CAUFVD-AUFNR'
                                ''.

  perform bdc_dynpro      using 'SAPLCOKO' '5115'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-GSTRP'.
  perform bdc_field       using 'CAUFVD-GAMNG'
                                '1'.
  perform bdc_field       using 'CAUFVD-GMEIN'
                                'ROL'.
  perform bdc_field       using 'CAUFVD-BMENGE'
                                P_QUANT."'100'.
  perform bdc_field       using 'CAUFVD-GLTRP'
                                P_TANGGAL."SY-DATUM."'29.10.2012'.
  perform bdc_field       using 'CAUFVD-GLUZP'
                                '24:00:00'.
  perform bdc_field       using 'CAUFVD-GSTRP'
                                P_TANGGAL."SY-DATUM."'29.10.2012'.
  perform bdc_field       using 'CAUFVD-GSUZP'
                                '00:00:00'.
  perform bdc_field       using 'CAUFVD-TERKZ'
                                '5'.
  perform bdc_field       using 'CAUFVD-FHORI'
                                '000'.
  perform bdc_dynpro      using 'SAPLCOKO' '5115'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SLAP'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-GAMNG'.
  perform bdc_dynpro      using 'SAPLCOKO' '5115'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=STAK'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-PLNNR'.
  perform bdc_dynpro      using 'SAPLCOKO' '5131'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENT1'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RC62F-PROD_VERS'.
  perform bdc_field       using 'RC62F-VER_SEL'
                                'X'.
  perform bdc_field       using 'RC62F-PROD_VERS'
                                P_VERID."'0003'.
  perform bdc_field       using 'RC62F-NEW_ROUT'
                                'X'.
  perform bdc_field       using 'RC62F-PLAUF'
                                P_TANGGAL."SY-DATUM."'29.10.2012'.
  perform bdc_field       using 'RC62F-NEW_BOM'
                                'X'.
  perform bdc_field       using 'RC62F-AUFLD'
                                P_TANGGAL."SY-DATUM."'29.10.2012'.
  perform bdc_dynpro      using 'SAPLCOKO' '5115'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=FREI'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-PLNNR'.
  perform bdc_dynpro      using 'SAPLCOKO' '5115'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'BDC_CURSOR'
                                'CAUFVD-PLNNR'.

  OPT-DISMODE = 'E'. "A: show all dynpros "E: show dynpro on error only "N: do not display dynpro
  OPT-UPDMODE = 'A'. "S: synchronously "A: asynchronously "L: local
  OPT-DEFSIZE = 'X'.

*  perform bdc_transaction using 'COR1'.
  REFRESH : MESSTAB.
  CALL TRANSACTION 'COR1' USING BDCDATA OPTIONS FROM OPT
                          MESSAGES INTO MESSTAB.
  REFRESH BDCDATA.

  LOOP AT MESSTAB WHERE MSGTYP = 'S' AND MSGNR = '582'.
    CLEAR: VMESS.
    PROC_ORD = MESSTAB-MSGV1.
    CONCATENATE '@08@ - Process Order Number' MESSTAB-MSGV1 INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-prord = VMESS.
  ENDLOOP.
  IF sy-subrc ne 0.
    LS_SUBRC = 1.
    FLAG = 'X'.
  ENDIF.
  IF ls_subrc = 1.
    LOOP AT MESSTAB WHERE MSGTYP = 'E'.
      CLEAR: VMESS, L_MSTRING.
      MESSAGE ID     MESSTAB-MSGID
              TYPE   MESSTAB-MSGTYP
              NUMBER MESSTAB-MSGNR
              INTO L_MSTRING
              WITH MESSTAB-MSGV1
                   MESSTAB-MSGV2
                   MESSTAB-MSGV3
                   MESSTAB-MSGV4.
      CONCATENATE '@0A@ - Failed :' L_MSTRING INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
      IT_LOG-prord = VMESS.
      APPEND it_log.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CREATE_PROCESS_ORDER
*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  GI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GI USING P_MBLNR   TYPE MBLNR
              P_MJAHR   TYPE MJAHR
              P_MATNR   TYPE MATNR
              P_VERID   TYPE VERID
              P_POSDT   TYPE BUDAT "CHAR10  "so_posdt-low
              P_NIK     TYPE HROBJID
              P_TANGGAL TYPE CHAR10
              P_PLANT   TYPE WERKS_D "so_plant-low
              PROC_ORD  TYPE AUFNR
     CHANGING FLAG.

  CLEAR: GMHEAD_GI, GMCODE_GI, MTHEAD_GI, ITAB_GI, ERRMSG_GI, V_PROC_ORD.
  REFRESH: ITAB_GI, ERRMSG_GI.

  DO 10 TIMES.
    SELECT SINGLE AUFNR
      INTO V_PROC_ORD
      FROM AUFK
     WHERE AUFNR = PROC_ORD.
    IF sy-subrc ne 0.
      WAIT UP TO 1 SECONDS.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

  GMHEAD_GI-PSTNG_DATE    = P_POSDT.
  GMHEAD_GI-DOC_DATE      = SY-DATUM.
  GMHEAD_GI-PR_UNAME      = SY-UNAME.
  GMHEAD_GI-HEADER_TXT    = P_NIK.
  GMHEAD_GI-GR_GI_SLIP_NO = P_MBLNR.
  GMHEAD_GI-REF_DOC_NO    = 'ADJUST MAT PURCH'.
  GMCODE_GI-GM_CODE       = '03'.

  UNASSIGN <fs_maintain>.
  LOOP AT it_maintain ASSIGNING <fs_maintain> WHERE mblnr = P_MBLNR AND mjahr = P_MJAHR AND matnr = P_MATNR.

    CLEAR: C_QUANT, LENGTHAWAL, V_SGTXT, ITAB_GI.
    C_QUANT = <FS_MAINTAIN>-CLABS.
    LENGTHAWAL  = <FS_MAINTAIN>-LENGTH.
    CONCATENATE <fs_maintain>-filmcd '/' LENGTHAWAL '/' P_VERID '/' P_MATNR INTO V_SGTXT.

    ITAB_GI-PLANT     = P_PLANT.
    ITAB_GI-MATERIAL  = <fs_maintain>-MATNR. "P_MATNR.
    ITAB_GI-ENTRY_QNT = C_QUANT.
    CLEAR: ITAB_GI-ENTRY_UOM.
    SELECT SINGLE MEINS INTO ITAB_GI-ENTRY_UOM
      FROM MARA
     WHERE MATNR = ITAB_GI-MATERIAL.
    ITAB_GI-BATCH     = <fs_maintain>-CHARG. "P_CHARG.
    ITAB_GI-STGE_LOC  = <fs_maintain>-LGORT. "P_LGORT.
    ITAB_GI-MOVE_TYPE = '261'.
    ITAB_GI-ORDERID   = PROC_ORD.
    ITAB_GI-ITEM_TEXT = V_SGTXT.
    APPEND ITAB_GI.

  ENDLOOP.

*  ITAB_GI-PLANT     = P_PLANT.
*  ITAB_GI-MATERIAL  = P_MATNR.
*  ITAB_GI-ENTRY_QNT = P_QUANT.
*  CLEAR: ITAB_GI-ENTRY_UOM.
*  SELECT SINGLE MEINS INTO ITAB_GI-ENTRY_UOM
*    FROM MARA
*   WHERE MATNR = ITAB_GI-MATERIAL.
*  ITAB_GI-BATCH     = P_CHARG.
*  ITAB_GI-STGE_LOC  = P_LGORT.
*  ITAB_GI-MOVE_TYPE = '261'.
*  ITAB_GI-ORDERID   = PROC_ORD.
*  ITAB_GI-ITEM_TEXT = P_SGTXT.
*  APPEND ITAB_GI.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD_GI
      GOODSMVT_CODE         = GMCODE_GI
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD_GI
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB_GI
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG_GI.

  CLEAR: FLAG, VMESS.
  LS_SUBRC = 0.
  LOOP AT ERRMSG_GI WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    FLAG = 'X'.
    CLEAR: VMESS.
    CONCATENATE '@0A@ - Failed :' ERRMSG_GI-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-gibtch = VMESS.
    APPEND it_log.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    mblnr_gi = MTHEAD_GI+0(10).
    mjahr_gi = MTHEAD_GI+10(4).
    CONCATENATE '@08@ - No.Mat.Doc :' MTHEAD_GI+0(10) '--' 'Fiscal Year' MTHEAD_GI+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-gibtch = VMESS.
  ENDIF.

ENDFORM.                    " GI
*&---------------------------------------------------------------------*
*&      Form  CREATE_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_BATCH USING P_MATNR LIKE BAPIBATCHKEY-MATERIAL
                        P_PLANT LIKE BAPIBATCHKEY-PLANT
               CHANGING FLAG
                        BATCH_GR.

  CLEAR: RETURN2, BATCH_GR.
  REFRESH: RETURN2.
  CALL FUNCTION 'BAPI_BATCH_CREATE'
    EXPORTING
      MATERIAL                   = P_MATNR
*     BATCH                      =
      PLANT                      = P_PLANT
*     BATCHATTRIBUTES            =
*     BATCHCONTROLFIELDS         =
*     BATCHSTORAGELOCATION       =
*     INTERNALNUMBERCOM          =
*     EXTENSION1                 =
*     MATERIAL_EVG               =
    IMPORTING
      BATCH                      = BATCH_GR
*     BATCHATTRIBUTES            =
    TABLES
      RETURN                     = RETURN2
            .

  LS_SUBRC = 0.
  LOOP AT RETURN2 WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    FLAG = 'X'.
    CLEAR: VMESS.
    CONCATENATE '@0A@ - Failed :' RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-crbtch = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: sy-subrc.
  IF ls_subrc = 0.
    PERFORM BAPI_COMMIT.
    CLEAR: VMESS.
    CONCATENATE '@08@ - Batch GR :' BATCH_GR INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-crbtch = VMESS.
    CLEAR: R_BATCH.
    R_BATCH-SIGN   = 'I'.
    R_BATCH-OPTION = 'EQ'.
    R_BATCH-LOW    = BATCH_GR.
    APPEND R_BATCH.
  ENDIF.

ENDFORM.                    " CREATE_BATCH
*&---------------------------------------------------------------------*
*&      Form  SET_CHAR_BATCH_BR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CHAR_BATCH_BR USING P_MATNR   LIKE MARA-MATNR
                             P_CHARG   LIKE MCH1-CHARG
                             P_PLANT   LIKE T001W-WERKS
                             P_MTRPO   LIKE MARA-MATNR
                             P_BATCHGR LIKE MCH1-CHARG
                    CHANGING FLAG.

  CLEAR: V_MATNR.
  DO 20 TIMES.
    SELECT SINGLE MATNR
      INTO V_MATNR
      FROM MCH1
     WHERE MATNR = P_MTRPO AND CHARG = P_BATCHGR."P_CHARG.
    IF sy-subrc ne 0.
      WAIT UP TO 1 SECONDS.
    ELSE.
*      EXIT.
      CALL FUNCTION 'ENQUEUE_EMMCH1E'
         EXPORTING
              MATNR          = P_MTRPO
              CHARG          = P_BATCHGR"P_CHARG
         EXCEPTIONS
              FOREIGN_LOCK   = 2
              SYSTEM_FAILURE = 3.

      IF SY-SUBRC  NE 0.
        WAIT UP TO 1 SECONDS.
      ELSE.
        CALL FUNCTION 'DEQUEUE_EMMCH1E'
         EXPORTING
           matnr           = P_MTRPO
           charg           = P_BATCHGR"P_CHARG
           .
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
  REFRESH: CHAR_OF_BATCH.
  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      MATNR                    = P_MATNR
      CHARG                    = P_CHARG
      WERKS                    = P_PLANT
      GET_CLASSIFICATION       = 'X'
*     EXISTENCE_CHECK          =
*     READ_FROM_BUFFER         =
*     NO_CLASS_INIT            = ' '
*     LOCK_BATCH               = ' '
*   IMPORTING
*     YMCHA                    =
*     CLASSNAME                =
    TABLES
      CHAR_OF_BATCH            = CHAR_OF_BATCH
    EXCEPTIONS
      NO_MATERIAL              = 1
      NO_BATCH                 = 2
      NO_PLANT                 = 3
      MATERIAL_NOT_FOUND       = 4
      PLANT_NOT_FOUND          = 5
      NO_AUTHORITY             = 6
      BATCH_NOT_EXIST          = 7
      LOCK_ON_BATCH            = 8
      OTHERS                   = 9
            .
  IF SY-SUBRC <> 0.
*Implement suitable error handling here
  ENDIF.

  CLEAR: IT_CHAR.
  REFRESH: IT_CHAR.
  LOOP AT CHAR_OF_BATCH.
    CLEAR: IT_CHAR.
    IT_CHAR-CHARACT = CHAR_OF_BATCH-ATNAM.
    CLEAR: V_ATINN, V_ATZHL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = CHAR_OF_BATCH-ATNAM "'ZZCODE'
      IMPORTING
        OUTPUT = V_ATINN.
    SELECT SINGLE ATZHL INTO V_ATZHL
      FROM CAWNT
     WHERE ATINN = V_ATINN AND ATWTB = CHAR_OF_BATCH-ATWTB.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE ATWRT INTO IT_CHAR-VALUE_CHAR
        FROM CAWN
       WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
    ELSE.
      IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
    ENDIF.
*    IT_CHAR-VALUE_CHAR = CHAR_OF_BATCH-ATWTB.
    APPEND IT_CHAR.
  ENDLOOP.

*  CLEAR: WA_CHAR2, LS_SUBRC.
*  LOOP AT IT_CHAR INTO WA_CHAR2 WHERE CHARACT = 'ZZLENGTH'.
*    LS_SUBRC = 1.
*    WA_CHAR2-VALUE_CHAR = P_LENGTHA.
*    MODIFY IT_CHAR FROM WA_CHAR2 TRANSPORTING VALUE_CHAR.
*  ENDLOOP.
*  IF LS_SUBRC = 0.
*    IT_CHAR-CHARACT    = 'ZZLENGTH'.
*    IT_CHAR-VALUE_CHAR = P_LENGTHA.
*    APPEND IT_CHAR.
*  ENDIF.

  CLEAR: WA_CHARACT, RA_CHARACT.
  REFRESH: RA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZPRODLINE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZCODE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZLENGTH'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZWIDTH'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZTREATMENT'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZCORE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZGRADE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZMONTHYEAR'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSEQUENCENBR'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZDERIVATIVEMS'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZPOSITIONMS'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZDERIVATIVESS'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZPOSITIONSS'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZNOMORROLL'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZALIAS'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZLABEL'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZPACKING'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPLICE-1'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPLICE-2'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPLICE-3'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPECIALTOUCH-1'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPECIALTOUCH-2'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPECIALTOUCH-3'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZUNITOFMEASURE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZEXLENGTH'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZPACKINGCODE'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZNUMBEROFROLL'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSCRAP'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZEXLENGTHASAL'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZSPEED'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZNOROLLTOYOBO'.
  APPEND WA_CHARACT TO RA_CHARACT.
  CLEAR: WA_CHARACT.
  WA_CHARACT-SIGN   = 'I'.
  WA_CHARACT-OPTION = 'EQ'.
  WA_CHARACT-LOW    = 'ZZNOLOTTOYOBO'.
  APPEND WA_CHARACT TO RA_CHARACT.

  DELETE IT_CHAR WHERE CHARACT NOT IN RA_CHARACT.

  CLEAR: VCLASS, VKLART, VOBTAB, VOBJEC.

  CALL FUNCTION 'QMSP_MATERIAL_BATCH_CLASS_READ'
    EXPORTING
      I_MATNR      = P_MTRPO
      I_WERKS      = P_PLANT
      I_CHARG      = P_BATCHGR
      I_MARA_LEVEL = 'X'
    IMPORTING
      E_CLASS      = VCLASS
      E_KLART      = VKLART
      E_OBTAB      = VOBTAB
      E_OBJEC      = VOBJEC.

  CLEAR: IT_RETURN2.
  REFRESH: IT_RETURN2.
  CALL FUNCTION 'BAPI_OBJCL_CHANGE'
    EXPORTING
      OBJECTKEY          = VOBJEC
      OBJECTTABLE        = VOBTAB
      CLASSNUM           = VCLASS
      CLASSTYPE          = VKLART
    TABLES
      ALLOCVALUESNUMNEW  = IT_NUM
      ALLOCVALUESCHARNEW = IT_CHAR
      ALLOCVALUESCURRNEW = IT_CURR
      RETURN             = IT_RETURN2.
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT IT_RETURN2 WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE '@0A@ - Batch' P_BATCHGR 'Failed :' IT_RETURN2-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    LS_SUBRC = 1.
    FLAG = 'X'.
    IT_LOG-setchr = VMESS.
    IT_LOG-grbtch = '@0A@ - Failed'. "#EC NOTEXT
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    CONCATENATE '@08@ - Batch' P_BATCHGR '- Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-setchr = VMESS.
    APPEND it_log.
  ENDIF.

ENDFORM.                    " SET_CHAR_BATCH_BR
*&---------------------------------------------------------------------*
*&      Form  GR_BATCH_BR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GR_BATCH_BR USING P_MBLNR   TYPE MBLNR
                       P_MJAHR   TYPE MJAHR
                       P_MATNR   TYPE MATNR
                       P_MTRPO   TYPE MATNR
                       P_VERID   TYPE VERID
                       P_POSDT   TYPE BUDAT
                       P_NIK     TYPE HROBJID
                       P_PLANT   TYPE WERKS_D
                       PROC_ORD  TYPE AUFNR
              CHANGING FLAG.

  CLEAR: GMHEAD_GR, GMCODE_GR, MTHEAD_GR, ITAB_GR, ERRMSG_GR.
  REFRESH: ITAB_GR, ERRMSG_GR.

*  CLEAR: CHAR_OF_BATCH, WA_CHAR_OF_BATCH.
*  REFRESH: CHAR_OF_BATCH.
*  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
*    EXPORTING
*      MATNR                    = P_MATNR
*      CHARG                    = P_CHARG
*      WERKS                    = P_PLANT
*      GET_CLASSIFICATION       = 'X'
**     EXISTENCE_CHECK          =
**     READ_FROM_BUFFER         =
**     NO_CLASS_INIT            = ' '
**     LOCK_BATCH               = ' '
**   IMPORTING
**     YMCHA                    =
**     CLASSNAME                =
*    TABLES
*      CHAR_OF_BATCH            = CHAR_OF_BATCH
*    EXCEPTIONS
*      NO_MATERIAL              = 1
*      NO_BATCH                 = 2
*      NO_PLANT                 = 3
*      MATERIAL_NOT_FOUND       = 4
*      PLANT_NOT_FOUND          = 5
*      NO_AUTHORITY             = 6
*      BATCH_NOT_EXIST          = 7
*      LOCK_ON_BATCH            = 8
*      OTHERS                   = 9
*            .
*  IF SY-SUBRC <> 0.
**Implement suitable error handling here
*  ENDIF.

**  CLEAR: V_CONV.
**  V_CONV = P_CONV.
*  READ TABLE CHAR_OF_BATCH ASSIGNING <FS_CHAR_OF_BATCH> WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
*  IF SY-SUBRC EQ 0.
*    V_CONV = <FS_CHAR_OF_BATCH>-ATWTB.
*    REPLACE 'Kg/Rol' IN V_CONV WITH SPACE.
*    REPLACE ALL OCCURRENCES OF RIBUAN IN V_CONV WITH SPACE.
*    CONDENSE V_CONV NO-GAPS.
*  ENDIF.

  GMHEAD_GR-PSTNG_DATE    = P_POSDT.
  GMHEAD_GR-DOC_DATE      = SY-DATUM.
  GMHEAD_GR-PR_UNAME      = SY-UNAME.
  GMHEAD_GR-HEADER_TXT    = P_NIK.
  GMHEAD_GR-REF_DOC_NO    = 'ADJUST MAT PURCH'.
  GMHEAD_GR-GR_GI_SLIP_NO = P_MBLNR.
  GMCODE_GR-GM_CODE       = '02'.

  UNASSIGN <fs_maintain>.
  LOOP AT it_maintain ASSIGNING <fs_maintain> WHERE mblnr = P_MBLNR AND mjahr = P_MJAHR AND matnr = P_MATNR.

    CLEAR: V_CONV, LENGTHAWAL, V_SGTXT, ITAB_GI.
    V_CONV = <FS_MAINTAIN>-CONV.
    LENGTHAWAL  = <FS_MAINTAIN>-LENGTH.
    CONCATENATE <fs_maintain>-filmcd '/' LENGTHAWAL '/' P_VERID '/' P_MATNR INTO V_SGTXT.

    ITAB_GR-MVT_IND   = 'F'.
    ITAB_GR-PLANT     = P_PLANT.
    ITAB_GR-MATERIAL  = P_MTRPO. "P_MATNR.
    ITAB_GR-ENTRY_QNT = V_CONV.
    CLEAR: ITAB_GR-ENTRY_UOM.
    SELECT SINGLE MEINS INTO ITAB_GR-ENTRY_UOM
      FROM MARA
     WHERE MATNR = ITAB_GR-MATERIAL.
    ITAB_GR-BATCH     = <fs_maintain>-BTCHGR."P_CHARG.
    ITAB_GR-STGE_LOC  = <fs_maintain>-LGORT."P_LGORT.
    ITAB_GR-MOVE_TYPE = '101'.
    ITAB_GR-ORDERID   = PROC_ORD.
    ITAB_GR-ITEM_TEXT = V_SGTXT.
    APPEND ITAB_GR.

  ENDLOOP.

*  ITAB_GR-MVT_IND   = 'F'.
*  ITAB_GR-PLANT     = P_PLANT.
*  ITAB_GR-MATERIAL  = P_MATNR.
*  ITAB_GR-ENTRY_QNT = V_CONV.
*  CLEAR: ITAB_GR-ENTRY_UOM.
*  SELECT SINGLE MEINS INTO ITAB_GR-ENTRY_UOM
*    FROM MARA
*   WHERE MATNR = ITAB_GR-MATERIAL.
*  ITAB_GR-BATCH     = P_CHARG.
*  ITAB_GR-STGE_LOC  = P_LGORT.
*  ITAB_GR-MOVE_TYPE = '101'.
*  ITAB_GR-ORDERID   = PROC_ORD.
*  ITAB_GR-ITEM_TEXT = P_SGTXT.
*  APPEND ITAB_GR.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GMHEAD_GR
      GOODSMVT_CODE         = GMCODE_GR
*     TESTRUN               = ' '
    IMPORTING
      GOODSMVT_HEADRET      = MTHEAD_GR
*     MATERIALDOCUMENT      =
*     MATDOCUMENTYEAR       =
    TABLES
      GOODSMVT_ITEM         = ITAB_GR
*     GOODSMVT_SERIALNUMBER =
      RETURN                = ERRMSG_GR.
  CLEAR: FLAG, VMESS.
  LS_SUBRC = 0.
  LOOP AT ERRMSG_GR WHERE TYPE = 'E'.
    LS_SUBRC = 1.
    FLAG = 'X'.
    canc = 'X'.
    CLEAR: VMESS.
    CONCATENATE '@0A@ - Failed :' ERRMSG_GR-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    IT_LOG-grbtch = VMESS.
    APPEND IT_LOG.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    CLEAR: VMESS.
    CONCATENATE '@08@ - No.Mat.Doc :' MTHEAD_GR+0(10) '--' 'Fiscal Year' MTHEAD_GR+10(4) INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
*    IT_LOG-grbtch = VMESS.
    LOOP AT it_log WHERE mblnr = P_MBLNR AND mjahr = P_MJAHR AND matnr = P_MATNR.
      IT_LOG-grbtch = VMESS.
      MODIFY it_log.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " GR_BATCH_BR
*&---------------------------------------------------------------------*
*&      Form  TECO_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TECO_ORDER USING P_MBLNR   TYPE MBLNR
                      P_MJAHR   TYPE MJAHR
                      P_MATNR   TYPE MATNR
                      PROC_ORD  TYPE AUFNR
             CHANGING FLAG.

  CLEAR: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.
  REFRESH: TECO_RETURN, TECO_ORDERS, TECO_DEAIL_RETURN.

  TECO_ORDERS-ORDER_NUMBER = PROC_ORD.
  APPEND TECO_ORDERS.

  CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
    EXPORTING
      SCOPE_COMPL_TECH         = '1'
      WORK_PROCESS_GROUP       = 'COWORK_BAPI'
      WORK_PROCESS_MAX         = 99
    IMPORTING
      RETURN                   = TECO_RETURN
    TABLES
      ORDERS                   = TECO_ORDERS
      DETAIL_RETURN            = TECO_DEAIL_RETURN
*     APPLICATION_LOG          =
            .
  LS_SUBRC = 0.
  CLEAR: VMESS, FLAG.
  LOOP AT TECO_DEAIL_RETURN WHERE TYPE = 'E'.
    CLEAR: VMESS.
    CONCATENATE '@0A@ - Order' PROC_ORD 'Failed :' TECO_DEAIL_RETURN-MESSAGE INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    LS_SUBRC = 1.
    FLAG = 'X'.
    LOOP AT it_log WHERE mblnr = P_MBLNR AND mjahr = P_MJAHR AND matnr = P_MATNR.
      IT_LOG-teco = VMESS.
      MODIFY IT_LOG.
    ENDLOOP.
  ENDLOOP.
  CLEAR: SY-SUBRC.
  IF LS_SUBRC = 0.
    PERFORM BAPI_COMMIT.
    CLEAR: VMESS.
    CONCATENATE '@08@ - Order' PROC_ORD 'Success' INTO VMESS SEPARATED BY SPACE. "#EC NOTEXT
    LOOP AT it_log WHERE mblnr = P_MBLNR AND mjahr = P_MJAHR AND matnr = P_MATNR.
      IT_LOG-teco = VMESS.
      MODIFY IT_LOG.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " TECO_ORDER
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_7110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN_7110 .
  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'SO_POSDT-LOW'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
      EXIT.
  ENDLOOP.
  IF SO_PLANT-LOW NE ''.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME = 'SO_PLANT-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
  ENDIF.
  IF SO_MBLNR-LOW NE ''.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME = 'SO_MBLNR-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME = 'SO_MBLNR-HIGH'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
  ENDIF.
*  IF SO_MJAHR-LOW NE ''. " Diminta Jangan di Grey 04 February 2013
*    LOOP AT SCREEN.
*      CHECK flagmjahr = ''.
*      CHECK SCREEN-NAME = 'SO_MJAHR-LOW'.
*        SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*        EXIT.
*    ENDLOOP.
*  ENDIF.
  IF SO_NIK-LOW NE ''.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME = 'SO_NIK-LOW'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " MODIFY_SCREEN_7110
*&---------------------------------------------------------------------*
*&      Form  GET_ATINN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ATINN USING P_INPUT TYPE STRING
               CHANGING V_ATINN.

  CLEAR: V_ATINN.
  CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
    EXPORTING
      INPUT  = P_INPUT
    IMPORTING
      OUTPUT = V_ATINN.

ENDFORM.                    " GET_ATINN
*&---------------------------------------------------------------------*
*&      Form  VB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VB_INIT .
  CALL FUNCTION 'VB_INIT'
    EXPORTING
      INIT_RESET       = 'X'
             .
ENDFORM.                    " VB_INIT
*&---------------------------------------------------------------------*
*&      Form  BAPI_COMMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_COMMIT .
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.                    " BAPI_COMMIT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_sortcat .

  CLEAR: it_sortcat, wa_sort.
  REFRESH: it_sortcat.

  wa_sort-spos      = 1.
  wa_sort-fieldname = 'MBLNR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 2.
  wa_sort-fieldname = 'MATNR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 3.
  wa_sort-fieldname = 'CHARG'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 4.
  wa_sort-fieldname = 'PRORD'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 5.
  wa_sort-fieldname = 'GIBTCH'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 6.
  wa_sort-fieldname = 'CRBTCH'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 7.
  wa_sort-fieldname = 'SETCHR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 8.
  wa_sort-fieldname = 'GRBTCH'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 9.
  wa_sort-fieldname = 'TECO'.
  APPEND wa_sort TO it_sortcat.

ENDFORM.                    " build_sortcat
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT .

  CLEAR: LT_FIELDCATLOG.
  REFRESH: LT_FIELDCATLOG.
*fieldcatalogue for alv dialog
******  CLEAR LS_FIELDCATLOG.
******  LS_FIELDCATLOG-ROW_POS   = '1'.
******  LS_FIELDCATLOG-COL_POS   = '1'.
******  LS_FIELDCATLOG-FIELDNAME = 'NOMOR'.
******  LS_FIELDCATLOG-OUTPUTLEN = 5.
******  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
******  LS_FIELDCATLOG-SELTEXT_M = 'Nomor'. "#EC NOTEXT
******  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '2'.
  LS_FIELDCATLOG-FIELDNAME = 'MBLNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Mat.Doc GR PO'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '3'.
  LS_FIELDCATLOG-FIELDNAME = 'MATNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 18.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material Number'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '4'.
  LS_FIELDCATLOG-FIELDNAME = 'CHARG'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Batch'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '5'.
  LS_FIELDCATLOG-FIELDNAME = 'PRORD'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Create Process Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '6'.
  LS_FIELDCATLOG-FIELDNAME = 'GIBTCH'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'GI Batch'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '7'.
  LS_FIELDCATLOG-FIELDNAME = 'CRBTCH'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Create Batch Baru Utk GR'. "#EC NOTEXT
  LS_FIELDCATLOG-SELTEXT_L = 'Create Batch Baru Utk GR'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '8'.
  LS_FIELDCATLOG-FIELDNAME = 'SETCHR'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'Set Characteristic Batch Baru'. "#EC NOTEXT
  LS_FIELDCATLOG-SELTEXT_L = 'Set Characteristic Batch Baru'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '9'.
  LS_FIELDCATLOG-FIELDNAME = 'GRBTCH'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'GR Batch Baru'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '10'.
  LS_FIELDCATLOG-FIELDNAME = 'TECO'.
  LS_FIELDCATLOG-OUTPUTLEN = 150.
  LS_FIELDCATLOG-TABNAME   = 'IT_LOG'.
  LS_FIELDCATLOG-SELTEXT_M = 'TECO Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.

ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_LAYOUT .
  CLEAR: LT_LAYOUT.
  LT_LAYOUT-ZEBRA = 'X'.
  LT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  IF D_PILIH = 3.
    LT_LAYOUT-BOX_FIELDNAME = 'FLAGS'.
  ENDIF.
  LT_LAYOUT-CONFIRMATION_PROMPT = 'X'.
ENDFORM.                    " BUILD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Log Process Adjustment Material Purchase' "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT
      IT_SORT                  = IT_SORTCAT[]
      IT_FIELDCAT              = LT_FIELDCATLOG
*      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
    TABLES
      T_OUTTAB                 = IT_LOG
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " ALV
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  IF D_PILIH = 3.
    SET PF-STATUS 'STANDARD_FULLSCREEN'.
  ELSE.
    SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING 'PRINT'.
  ENDIF.
ENDFORM. "Set_pf_status
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_DISPLAY .

  CLEAR: it_displayh.
  REFRESH: it_displayh.

  SELECT MBLNR MJAHR
    FROM MSEG
    INTO CORRESPONDING FIELDS OF TABLE it_displayh
   WHERE WERKS IN S_PLANT AND BUDAT_MKPF IN S_POSDT AND MJAHR IN S_MJAHR AND MBLNR IN S_MBLNR AND BWART = '101'.
  SORT it_displayh BY mblnr mjahr.
  DELETE ADJACENT DUPLICATES FROM it_displayh COMPARING mblnr mjahr.
  UNASSIGN <fs_displayh>.
  LOOP AT it_displayh ASSIGNING <fs_displayh>.
    CLEAR: VSMBLN.
    SELECT SINGLE SMBLN
      INTO VSMBLN
      FROM MSEG
     WHERE smbln = <fs_displayh>-mblnr AND sjahr = <fs_displayh>-mjahr.
    IF sy-subrc = 0.
      <fs_displayh>-mblnrc = 'X'.
    ENDIF.
  ENDLOOP.
  DELETE it_displayh WHERE mblnrc = 'X'.

  CLEAR: it_display.
  REFRESH: it_display.
  UNASSIGN <fs_displayh>.
  LOOP AT it_displayh ASSIGNING <fs_displayh>.

    SELECT MKPF~XABLN AS MBLNR
           MKPF~BKTXT AS BKTXT
           MKPF~BUDAT AS BUDAT_MKPF
           MSEG~AUFNR AS AUFNR
           MSEG~BWART AS BWART
           MSEG~MBLNR AS MBLNR2
           MSEG~MJAHR AS MJAHR2
           MSEG~ZEILE AS ZEILE2
           MSEG~MATNR AS MATNR2
           MSEG~CHARG AS CHARG
           MSEG~MENGE AS MENGE
           MSEG~SGTXT AS SGTXT
           MSEG~LGORT AS LGORT
      FROM MSEG
      JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR AND MKPF~MJAHR = MSEG~MJAHR
      APPENDING CORRESPONDING FIELDS OF TABLE it_display
     WHERE MSEG~WERKS IN S_PLANT AND MKPF~XBLNR = 'ADJUST MAT PURCH' AND MKPF~XABLN = <fs_displayh>-MBLNR AND
           MSEG~BWART IN ('101','261').

  ENDLOOP.

  UNASSIGN: <fs_display>.
  LOOP AT it_display ASSIGNING <fs_display>.

    SELECT SINGLE MJAHR EBELN
      INTO (<fs_display>-mjahr, <fs_display>-ebeln)
      FROM MSEG
     WHERE WERKS IN S_PLANT AND BUDAT_MKPF IN S_POSDT AND MBLNR = <fs_display>-mblnr AND BWART = '101'.

    CLEAR: VSMBLN.
    SELECT SINGLE SMBLN
      INTO VSMBLN
      FROM MSEG
     WHERE smbln = <fs_display>-mblnr2 AND sjahr = <fs_display>-mjahr2.
    IF sy-subrc = 0.
      <fs_display>-indc = '@5C@'.
    ELSE.
      <fs_display>-indc = '@5B@'.
    ENDIF.

    SPLIT <fs_display>-sgtxt AT '/' INTO <fs_display>-filmcd <fs_display>-length <fs_display>-verid <fs_display>-matnr.

    PERFORM GET_ATINN USING 'ZZCODE' CHANGING V_ATINN.
    CLEAR: V_ATZHL.
    SELECT SINGLE ATZHL
      INTO V_ATZHL
      FROM CAWN
     WHERE ATINN = V_ATINN AND ATWRT = <fs_display>-filmcd.
    IF sy-subrc = 0.
      SELECT SINGLE ATWTB
        INTO <fs_display>-film
        FROM CAWNT
       WHERE ATINN = V_ATINN AND ATZHL = V_ATZHL.
    ENDIF.

  ENDLOOP.

  IF s_nik-low ne '00000000'.
    DELETE it_display WHERE bktxt ne s_nik-low.
  ENDIF.

  IF s_mblnr[] IS NOT INITIAL.
    DELETE it_display WHERE mblnr NOT IN s_mblnr.
  ENDIF.

  IF s_mjahr[] IS NOT INITIAL.
    DELETE it_display WHERE mjahr NOT IN s_mjahr.
  ENDIF.

  IF s_mblnr2[] IS NOT INITIAL.
    DELETE it_display WHERE mblnr2 NOT IN s_mblnr2.
  ENDIF.

  IF s_mjahr2[] IS NOT INITIAL.
    DELETE it_display WHERE mjahr2 NOT IN s_mjahr2.
  ENDIF.

  IF s_ebeln[] IS NOT INITIAL.
    DELETE it_display WHERE ebeln NOT IN s_ebeln.
  ENDIF.

ENDFORM.                    " GET_DATA_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT_DISPLAY .

  CLEAR: LT_FIELDCATLOG.
  REFRESH: LT_FIELDCATLOG.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '1'.
  LS_FIELDCATLOG-FIELDNAME = 'MBLNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Mat.Doc Purchase Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '2'.
  LS_FIELDCATLOG-FIELDNAME = 'EBELN'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Purchase Order Number'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '3'.
  LS_FIELDCATLOG-FIELDNAME = 'MATNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 18.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material purch.order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '4'.
  LS_FIELDCATLOG-FIELDNAME = 'AUFNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 12.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Order Number'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '5'.
  LS_FIELDCATLOG-FIELDNAME = 'BWART'.
  LS_FIELDCATLOG-OUTPUTLEN = 3.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Movement Type'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '6'.
  LS_FIELDCATLOG-FIELDNAME = 'MBLNR2'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Mat. Doc Process Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '7'.
  LS_FIELDCATLOG-FIELDNAME = 'MATNR2'.
  LS_FIELDCATLOG-OUTPUTLEN = 18.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material Proc.Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '8'.
  LS_FIELDCATLOG-FIELDNAME = 'MENGE'.
  LS_FIELDCATLOG-OUTPUTLEN = 16.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Quantity'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '9'.
  LS_FIELDCATLOG-FIELDNAME = 'CHARG'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Batch'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '10'.
  LS_FIELDCATLOG-FIELDNAME = 'FILM'.
  LS_FIELDCATLOG-OUTPUTLEN = 30.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Type Film'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
*  CLEAR LS_FIELDCATLOG.
*  LS_FIELDCATLOG-ROW_POS   = '1'.
*  LS_FIELDCATLOG-COL_POS   = '8'.
*  LS_FIELDCATLOG-FIELDNAME = 'LENGTH'.
*  LS_FIELDCATLOG-OUTPUTLEN = 30.
*  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
*  LS_FIELDCATLOG-SELTEXT_M = 'Panjang Awal'. "#EC NOTEXT
*  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
*  CLEAR LS_FIELDCATLOG.
*  LS_FIELDCATLOG-ROW_POS   = '1'.
*  LS_FIELDCATLOG-COL_POS   = '9'.
*  LS_FIELDCATLOG-FIELDNAME = 'LENGTA'.
*  LS_FIELDCATLOG-OUTPUTLEN = 30.
*  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
*  LS_FIELDCATLOG-SELTEXT_M = 'Panjang Akhir'. "#EC NOTEXT
*  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
*  CLEAR LS_FIELDCATLOG.
*  LS_FIELDCATLOG-ROW_POS   = '1'.
*  LS_FIELDCATLOG-COL_POS   = '10'.
*  LS_FIELDCATLOG-FIELDNAME = 'EXLENG'.
*  LS_FIELDCATLOG-OUTPUTLEN = 30.
*  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
*  LS_FIELDCATLOG-SELTEXT_M = 'Extra Length'. "#EC NOTEXT
*  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '11'.
  LS_FIELDCATLOG-FIELDNAME = 'LGORT'.
  LS_FIELDCATLOG-OUTPUTLEN = 4.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Sloc'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '12'.
  LS_FIELDCATLOG-FIELDNAME = 'BUDAT_MKPF'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Posting Date'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '13'.
  LS_FIELDCATLOG-FIELDNAME = 'INDC'.
  LS_FIELDCATLOG-OUTPUTLEN = 4.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Cancel Indicator'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '14'.
  LS_FIELDCATLOG-FIELDNAME = 'BKTXT'.
  LS_FIELDCATLOG-OUTPUTLEN = 8.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'NIK'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '15'.
  LS_FIELDCATLOG-FIELDNAME = 'VERID'.
  LS_FIELDCATLOG-OUTPUTLEN = 4.
  LS_FIELDCATLOG-TABNAME   = 'IT_DISPLAY'.
  LS_FIELDCATLOG-SELTEXT_M = 'Production Version'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.

ENDFORM.                    " BUILD_FIELDCAT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = 'Display Order' "#EC NOTEXT
      IS_LAYOUT                = LT_LAYOUT
*      IT_SORT                  = IT_SORTCAT[]
      IT_FIELDCAT              = LT_FIELDCATLOG
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
    TABLES
      T_OUTTAB                 = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " ALV_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING fu_ucomm LIKE sy-ucomm
                        fu_selfield TYPE slis_selfield.
  DATA: lt_hus TYPE hum_venum_t.

  CLEAR: R_BATCH.
  REFRESH: R_BATCH.
  UNASSIGN: <fs_display>.

  sy-lsind = 0.
  CASE fu_ucomm.
    WHEN 'PRINT'.
      READ TABLE it_display WITH KEY flags = 'X'.
      IF sy-subrc = 0.
        UNASSIGN: <fs_display>.
        LOOP AT it_display ASSIGNING <fs_display> WHERE flags = 'X' AND indc = '@5B@' AND BWART = '101'.
          CLEAR: R_BATCH.
          R_BATCH-SIGN   = 'I'.
          R_BATCH-OPTION = 'EQ'.
          R_BATCH-LOW    = <fs_display>-charg.
          APPEND R_BATCH.
        ENDLOOP.
        READ TABLE R_BATCH INDEX 1.
        IF sy-subrc = 0.
          SUBMIT ZMMR_LABELROL WITH  P_CHARG IN R_BATCH AND RETURN.
          CLEAR: R_BATCH.
          REFRESH: R_BATCH.
        ELSE.
          MESSAGE 'No Data Printed' TYPE 'I'. "#EC NOTEXT
          EXIT.
        ENDIF.
      ELSE.
        MESSAGE 'Please select at least one line' TYPE 'I'. "#EC NOTEXT
        EXIT.
      ENDIF.
  ENDCASE.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  CANCEL_GOODSMVT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_GOODSMVT USING MATERIALDOCUMENT MATDOCUMENTYEAR CHANGING FLAG GOODSMVT_HEADRET.

  CLEAR: GOODSMVT_HEADRET, RETURN.
  REFRESH: RETURN.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = MATERIALDOCUMENT
      MATDOCUMENTYEAR     = MATDOCUMENTYEAR
*     GOODSMVT_PSTNG_DATE =
*     GOODSMVT_PR_UNAME   =
    IMPORTING
      GOODSMVT_HEADRET    = GOODSMVT_HEADRET
    TABLES
      RETURN              = RETURN.
*     GOODSMVT_MATDOCITEM       =
  .

ENDFORM.                    " CANCEL_GOODSMVT
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT_TEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT_TEST .

  CLEAR: LT_FIELDCATLOG.
  REFRESH: LT_FIELDCATLOG.
*fieldcatalogue for alv dialog
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '1'.
  LS_FIELDCATLOG-FIELDNAME = 'MBLNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Mat.Doc Purchase Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '2'.
  LS_FIELDCATLOG-FIELDNAME = 'EBELN'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Purchase Order Number'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '3'.
  LS_FIELDCATLOG-FIELDNAME = 'MATNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 18.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material purch.order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '4'.
  LS_FIELDCATLOG-FIELDNAME = 'AUFNR'.
  LS_FIELDCATLOG-OUTPUTLEN = 12.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Order Number'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '5'.
  LS_FIELDCATLOG-FIELDNAME = 'BWART'.
  LS_FIELDCATLOG-OUTPUTLEN = 3.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Movement Type'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '6'.
  LS_FIELDCATLOG-FIELDNAME = 'MBLNR2'.
  LS_FIELDCATLOG-OUTPUTLEN = 10.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material Document Process Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  CLEAR LS_FIELDCATLOG.
  LS_FIELDCATLOG-ROW_POS   = '1'.
  LS_FIELDCATLOG-COL_POS   = '7'.
  LS_FIELDCATLOG-FIELDNAME = 'MATNR2'.
  LS_FIELDCATLOG-OUTPUTLEN = 18.
  LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
  LS_FIELDCATLOG-SELTEXT_M = 'Material Proc.Order'. "#EC NOTEXT
  APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  IF canct = 'X'.
    CLEAR LS_FIELDCATLOG.
    LS_FIELDCATLOG-ROW_POS   = '1'.
    LS_FIELDCATLOG-COL_POS   = '8'.
    LS_FIELDCATLOG-FIELDNAME = 'MENGE'.
    LS_FIELDCATLOG-OUTPUTLEN = 16.
    LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
    LS_FIELDCATLOG-SELTEXT_M = 'Quantity'. "#EC NOTEXT
    APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
    CLEAR LS_FIELDCATLOG.
    LS_FIELDCATLOG-ROW_POS   = '1'.
    LS_FIELDCATLOG-COL_POS   = '9'.
    LS_FIELDCATLOG-FIELDNAME = 'CHARG'.
    LS_FIELDCATLOG-OUTPUTLEN = 10.
    LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
    LS_FIELDCATLOG-SELTEXT_M = 'Batch'. "#EC NOTEXT
    APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
    CLEAR LS_FIELDCATLOG.
    LS_FIELDCATLOG-ROW_POS   = '1'.
    LS_FIELDCATLOG-COL_POS   = '10'.
    LS_FIELDCATLOG-FIELDNAME = 'CANCGR'.
    LS_FIELDCATLOG-OUTPUTLEN = 150.
    LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
    LS_FIELDCATLOG-SELTEXT_M = 'Cancel GR'. "#EC NOTEXT
    APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  ELSE.
    CLEAR LS_FIELDCATLOG.
    LS_FIELDCATLOG-ROW_POS   = '1'.
    LS_FIELDCATLOG-COL_POS   = '8'.
    LS_FIELDCATLOG-FIELDNAME = 'CANCGR'.
    LS_FIELDCATLOG-OUTPUTLEN = 150.
    LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
    LS_FIELDCATLOG-SELTEXT_M = 'Cancel GR'. "#EC NOTEXT
    APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
    CLEAR LS_FIELDCATLOG.
    LS_FIELDCATLOG-ROW_POS   = '1'.
    LS_FIELDCATLOG-COL_POS   = '9'.
    LS_FIELDCATLOG-FIELDNAME = 'CANCGI'.
    LS_FIELDCATLOG-OUTPUTLEN = 150.
    LS_FIELDCATLOG-TABNAME   = 'IT_TEST'.
    LS_FIELDCATLOG-SELTEXT_M = 'Cancel GI'. "#EC NOTEXT
    APPEND LS_FIELDCATLOG TO LT_FIELDCATLOG.
  ENDIF.

ENDFORM.                    " BUILD_FIELDCAT_TEST
*&---------------------------------------------------------------------*
*&      Form  ALV_TEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_TEST .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_GRID_TITLE             = I_GRID_TITLE "'Cancellation Test'
      IS_LAYOUT                = LT_LAYOUT
      IT_FIELDCAT              = LT_FIELDCATLOG
*      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
    TABLES
      T_OUTTAB                 = IT_TEST
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " ALV_TEST
*&---------------------------------------------------------------------*
*&      Form  VALIDASI_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDASI_NIK_PLANT.

  IF SO_PLANT-LOW NE ''.
    CLEAR: VWERKS.
    SELECT SINGLE WERKS
      INTO VWERKS
      FROM T001W
     WHERE WERKS = SO_PLANT-LOW.
    IF SY-SUBRC NE 0.
      MGODIS = ''.
      RSTDIS = 'X'.
      FLAG = 'X'.
      CLEAR: SO_PLANT-LOW.
      REFRESH: SO_PLANT.
      MESSAGE 'Plant salah' TYPE 'I'. "#EC NOTEXT
*      EXIT.
    ENDIF.
  ELSEIF S_PLANT-LOW NE ''.
    CLEAR: VWERKS.
    SELECT SINGLE WERKS
      INTO VWERKS
      FROM T001W
     WHERE WERKS = S_PLANT-LOW.
    IF SY-SUBRC NE 0.
      MGODIS = ''.
      RSTDIS = 'X'.
      FLAG = 'X'.
      CLEAR: S_PLANT-LOW.
      REFRESH: S_PLANT.
      MESSAGE 'Plant salah' TYPE 'I'. "#EC NOTEXT
*      EXIT.
    ENDIF.
  ENDIF.

  IF SO_NIK-LOW NE ''.
    CLEAR: VPERNR.
    SELECT SINGLE PERNR
      INTO VPERNR
      FROM PA0001
     WHERE PERNR = SO_NIK-LOW.
    IF SY-SUBRC NE 0.
      MGODIS = ''.
      RSTDIS = 'X'.
      FLAG = 'X'.
      CLEAR: SO_NIK-LOW.
      REFRESH: SO_NIK.
      MESSAGE 'NIK salah' TYPE 'I'. "#EC NOTEXT
*      EXIT.
    ENDIF.
  ELSEIF S_NIK-LOW NE ''.
    CLEAR: VPERNR.
    SELECT SINGLE PERNR
      INTO VPERNR
      FROM PA0001
     WHERE PERNR = S_NIK-LOW.
    IF SY-SUBRC NE 0.
      MGODIS = ''.
      RSTDIS = 'X'.
      FLAG = 'X'.
      CLEAR: S_NIK-LOW.
      REFRESH: S_NIK.
      MESSAGE 'NIK salah' TYPE 'I'. "#EC NOTEXT
*      EXIT.
    ENDIF.
  ENDIF.

  IF FLAG = 'X'.
    CLEAR: FLAG.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDASI_NIK
*&---------------------------------------------------------------------*
*&      Form  F4_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_NIK USING DYNFIELDS.

  DATA: BEGIN OF HELP_NIK OCCURS 0,
           PERNR TYPE PA0001-PERNR,
           ENAME TYPE PA0001-ENAME,
         END OF HELP_NIK.

*   SELECT PERNR ENAME
*     INTO TABLE HELP_NIK
*     FROM PA0001.

   SORT HELP_NIK BY PERNR ENAME.
   DELETE ADJACENT DUPLICATES FROM HELP_NIK COMPARING ALL FIELDS.

   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
       RETFIELD    = 'PERNR'
       DYNPROFIELD = DYNFIELDS
       DYNPPROG    = SY-CPROG
       DYNPNR      = SY-DYNNR
       VALUE_ORG   = 'S'
     TABLES
       VALUE_TAB   = HELP_NIK.

ENDFORM.                    " F4_NIK
*&---------------------------------------------------------------------*
*&      Form  F4_MBLNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_MBLNR USING PARAM TYPE STRING.

  DATA: BEGIN OF HELP_MBLNR OCCURS 0,
*           PLANT TYPE MSEG-WERKS,
           MBLNR TYPE MSEG-MBLNR,
*           MJAHR TYPE MSEG-MJAHR,
         END OF HELP_MBLNR.

   DATA: DYNFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE,
         DYNPROFIELD TYPE  HELP_INFO-DYNPROFLD.

   DYNFIELDS-FIELDNAME = 'SO_PLANT-LOW'.
   APPEND DYNFIELDS.

   CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
       DYNAME               = SY-CPROG
       DYNUMB               = SY-DYNNR
       TRANSLATE_TO_UPPER   = 'X'
     TABLES
       DYNPFIELDS           = DYNFIELDS
     EXCEPTIONS
       INVALID_ABAPWORKAREA = 1
       INVALID_DYNPROFIELD  = 2
       INVALID_DYNPRONAME   = 3
       INVALID_DYNPRONUMMER = 4
       INVALID_REQUEST      = 5
       NO_FIELDDESCRIPTION  = 6
       INVALID_PARAMETER    = 7
       UNDEFIND_ERROR       = 8
       DOUBLE_CONVERSION    = 9
       STEPL_NOT_FOUND      = 10
       OTHERS               = 11.

   READ TABLE DYNFIELDS WITH KEY FIELDNAME = 'SO_PLANT-LOW'.

   SO_PLANT-LOW = DYNFIELDS-FIELDVALUE.

   IF SO_PLANT-LOW NE SPACE.
     SELECT MBLNR
       INTO TABLE HELP_MBLNR
       FROM MSEG
      WHERE WERKS = SO_PLANT-LOW.
   ELSE.
     SELECT MBLNR
       INTO TABLE HELP_MBLNR
       FROM MSEG. "#EC CI_NOWHERE
   ENDIF.

   SORT HELP_MBLNR BY MBLNR.
   DELETE ADJACENT DUPLICATES FROM HELP_MBLNR COMPARING ALL FIELDS.

   IF PARAM = 'LOW'.
     DYNPROFIELD = 'SO_MBLNR-LOW'.
   ELSEIF PARAM = 'HIGH'.
     DYNPROFIELD = 'SO_MBLNR-HIGH'.
   ENDIF.

   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
       RETFIELD    = 'MBLNR'
       DYNPROFIELD = DYNPROFIELD
       DYNPPROG    = SY-CPROG
       DYNPNR      = SY-DYNNR
       VALUE_ORG   = 'S'
     TABLES
       VALUE_TAB   = HELP_MBLNR.

ENDFORM.                    " F4_MBLNR
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORTCAT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_BUILD_SORTCAT2 .

  CLEAR: it_sortcat, wa_sort.
  REFRESH: it_sortcat.

  wa_sort-spos      = 1.
  wa_sort-fieldname = 'MBLNR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 2.
  wa_sort-fieldname = 'EBELN'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 3.
  wa_sort-fieldname = 'MATNR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 4.
  wa_sort-fieldname = 'AUFNR'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 5.
  wa_sort-fieldname = 'BWART'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 6.
  wa_sort-fieldname = 'MBLNR2'.
  APPEND wa_sort TO it_sortcat.
  CLEAR: wa_sort.
  wa_sort-spos      = 7.
  wa_sort-fieldname = 'MATNR2'.
  APPEND wa_sort TO it_sortcat.

ENDFORM.                    " F_BUILD_SORTCAT2