*----------------------------------------------------------------------*
* Include           ZPPI_REC_EXEC_F01
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Include funcion definition
*
* Application Area - PP
* ABAPer           - Anthony W
* Date             - Sept 17, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*----------------------------------------------------------------------*

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
*&      Form  PREPARATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM PREPARATION.
   DATA: NOMOR TYPE I, VMAKTR TYPE MAKTX, VMEINS LIKE MARA-MEINS.
   CLEAR: IT_RECYCLE01, SY-TABIX, VMATNR, VMAKTX,VMEINS,VARBPL,MSG_ERROR, VOBJID, VLGORT, VLGORT2.
   REFRESH: IT_RECYCLE01.

   SELECT SINGLE CRHD~ARBPL INTO (VARBPL)
     FROM CRHD
     WHERE CRHD~WERKS = ZPLANT
     AND   CRHD~ARBPL = ZRESOURCE.

   SELECT SINGLE ZTMAP_SLOCREC~ZRRLGORT INTO (VLGORT)
      FROM  ZTMAP_SLOCREC
      WHERE ZTMAP_SLOCREC~WERKS = ZPLANT
      AND   ZTMAP_SLOCREC~ARBPL = ZRESOURCE.

   SELECT SINGLE ZTMAP_SLOCREC~LGORT_RCYL INTO (VLGORT2)
     FROM  ZTMAP_SLOCREC
     WHERE ZTMAP_SLOCREC~WERKS = ZPLANT
     AND   ZTMAP_SLOCREC~ARBPL = ZRESOURCE.


   IF VARBPL IS INITIAL.
     CONCATENATE 'Resource' ZRESOURCE 'does not exists in plant' ZPLANT INTO MSG_ERROR SEPARATED BY SPACE.
     MESSAGE MSG_ERROR TYPE 'I'.
   ELSE.

     SELECT SINGLE HRP1001~OBJID INTO (VOBJID)
        FROM HRP1001
        JOIN CRHD ON CRHD~HROID = HRP1001~SOBID
        WHERE WERKS = ZPLANT
        AND   ARBPL = ZRESOURCE
        AND   SCLAS = 'A'
        AND   HRP1001~OBJID = ZOPERATOR.

     IF VOBJID IS INITIAL.
       CONCATENATE 'NIK' ZOPERATOR 'does not exists in Resource' ZRESOURCE INTO MSG_ERROR SEPARATED BY SPACE.
       MESSAGE MSG_ERROR TYPE 'I'.
     ELSE.

       SELECT SINGLE MARC~MATNR INTO (VMATNR)
         FROM MARC
         WHERE MARC~MATNR = ZMATNR
         AND   MARC~WERKS = ZPLANT.

       IF VMATNR IS NOT INITIAL.
         CLEAR VMATNR.

         SELECT SINGLE MARA~MATNR INTO (VMATNR)
            FROM MARA
*            WHERE MARA~MATKL = 'B00501'
            WHERE MARA~MATKL IN ('B00501','B00507')
            AND   MARA~MATNR = ZMATNR.

         IF VMATNR IS INITIAL.
           CONCATENATE 'Material' ZMATNR 'does not exists in Mat.Group Recycle' INTO MSG_ERROR SEPARATED BY SPACE.
           MESSAGE  MSG_ERROR TYPE 'I'.
         ELSE.
           SELECT ZTMAP_RECYCLE~RAR_A_MATNR AS MATRR INTO CORRESPONDING FIELDS OF TABLE IT_RECYCLE01
            FROM ZTMAP_RECYCLE
            WHERE ZTMAP_RECYCLE~FGR_A_MATNR = ZMATNR
            AND   ZTMAP_RECYCLE~WERKS = ZPLANT.

           IF IT_RECYCLE01[] IS INITIAL.
             CONCATENATE 'Raw Recycle' ZMATNR 'does not exists' INTO MSG_ERROR SEPARATED BY SPACE.
             MESSAGE MSG_ERROR  TYPE 'I'.
           ELSE.
             SORT IT_RECYCLE01 BY MATRR.
             DELETE ADJACENT DUPLICATES FROM IT_RECYCLE01 COMPARING MATRR.

             SELECT SINGLE MARA~MEINS MAKT~MATNR MAKT~MAKTX INTO (VMEINS, VMATNR, VMAKTX)
               FROM MAKT
               JOIN MARA ON MARA~MATNR = MAKT~MATNR
               WHERE MAKT~MATNR = ZMATNR
               AND   MAKT~SPRAS = 'EN'.

             LOOP AT IT_RECYCLE01.
               IT_RECYCLE01-NOMOR = SY-TABIX.
               IT_RECYCLE01-MEINS = VMEINS.
               SELECT SINGLE MAKT~MAKTX INTO (IT_RECYCLE01-MAKTR)
                  FROM MAKT
                  WHERE MAKT~MATNR = IT_RECYCLE01-MATRR
                  AND   MAKT~SPRAS = 'EN'.
               IT_RECYCLE01-WERKS = ZPLANT.
               IT_RECYCLE01-MATNR = VMATNR.
               IT_RECYCLE01-MAKTX = VMAKTX.
               IT_RECYCLE01-LGORT = VLGORT.
               IT_RECYCLE01-LGORT2 = VLGORT2.
               MODIFY IT_RECYCLE01.
             ENDLOOP.

             CLEAR : IT_MAP_SLOCREC, WA_MAP_SLOCREC, WA_VRM_LGORT_GR.
             REFRESH : IT_MAP_SLOCREC, GT_VRM_LGORT_GR.

             SELECT DISTINCT * FROM ZTMAP_SLOCREC
               INTO CORRESPONDING FIELDS OF TABLE IT_MAP_SLOCREC
                WHERE WERKS = ZPLANT
                      AND ARBPL = ZRESOURCE.

             IF IT_MAP_SLOCREC[] IS NOT INITIAL.
                LOOP AT IT_MAP_SLOCREC INTO WA_MAP_SLOCREC.
                    WA_VRM_LGORT_GR-KEY = WA_MAP_SLOCREC-LGORT_RCYL.
                    WA_VRM_LGORT_GR-TEXT = WA_MAP_SLOCREC-LGORT_RCYL.
                    APPEND WA_VRM_LGORT_GR TO GT_VRM_LGORT_GR.

                    CLEAR : WA_VRM_LGORT_GR.
                ENDLOOP.

                IF GT_VRM_LGORT_GR[] IS NOT INITIAL.
                  CALL FUNCTION 'VRM_SET_VALUES'
                    EXPORTING
                      id     = 'WA_RECYCLE01-LGORT2'
                      values = GT_VRM_LGORT_GR.
                ENDIF.
             ENDIF.
           ENDIF.
         ENDIF.
       ELSE.
         CONCATENATE 'Material' ZMATNR 'does not exists in plant' ZPLANT INTO MSG_ERROR SEPARATED BY SPACE.
         MESSAGE MSG_ERROR TYPE 'I'.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    "PREPARATION

*&---------------------------------------------------------------------*
*&      Form  EXECUTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM EXECUTION.

   CLEAR:   ZRETURN, IT_RETURN, IT_RETURN2, IT_ORDER,IT_RET, MATDOC, MATYEAR, ZORDERDATA, THEADER, TITEM, WA_DISPLAY, IT_DISPLAY,
            VMATNR, MSG_ERROR, VARBPL, VTERMINAL, VALIDATION.
   REFRESH: IT_RETURN, IT_RETURN2, IT_ORDER, IT_RET, ZORDERDATA, THEADER, TITEM, IT_DISPLAY.

   LOOP AT IT_RECYCLE01 WHERE FLAGS EQ 'X'.
     IF IT_RECYCLE01-QUANT IS NOT INITIAL AND IT_RECYCLE01-GRUND IS NOT INITIAL AND IT_RECYCLE01-LGORT IS NOT INITIAL
        AND IT_RECYCLE01-LGORT2 IS NOT INITIAL AND IT_RECYCLE01-FILM IS NOT INITIAL AND IT_RECYCLE01-LINE IS NOT INITIAL AND IT_RECYCLE01-TGL IS NOT INITIAL.
       VALIDATION = 'X'.
     ELSE.
       VALIDATION = 'Y'.
       EXIT.
     ENDIF.
   ENDLOOP.

   IF VALIDATION EQ 'Y'.
     MESSAGE 'Masih ada data yang belum diisi' TYPE 'I'.
   ELSE.
     IF ZPLANT = '1000'.
       VORDER_TYPE = 'ZR01'.
     ELSEIF ZPLANT = '2000'.
       VORDER_TYPE = 'ZR02'.
     ELSEIF ZPLANT = 'TTA2'.
       VORDER_TYPE = 'ZR02'. " ADD NEW COMPANY
*     ELSEIF ZPLANT = 'TTE2'.
*       VORDER_TYPE = 'ZR02'. " ADD NEW COMPANY
     ENDIF.

     CALL FUNCTION 'POC_GET_COMPUTER_NAME'
       IMPORTING
         EX_COMPUTER_NAME = VTERMINAL
       EXCEPTIONS
         GUI_ERROR        = 1.


     SELECT SINGLE CRHD~ARBPL INTO (VARBPL)
       FROM CRHD
       WHERE CRHD~WERKS = ZPLANT
       AND   CRHD~ARBPL = ZRESOURCE.

     IF VARBPL IS INITIAL.
       CONCATENATE 'Resource' ZRESOURCE 'does not exists in plant' ZPLANT INTO MSG_ERROR SEPARATED BY SPACE.
       MESSAGE MSG_ERROR TYPE 'I'.
     ELSE.

       SELECT SINGLE MARA~MATNR INTO (VMATNR)
         FROM MARA
*         WHERE MARA~MATKL = 'B00501'
         WHERE MARA~MATKL IN ('B00501','B00507')
         AND   MARA~MATNR = ZMATNR.

       IF VMATNR EQ SPACE.
         CONCATENATE 'Material' ZMATNR 'does not exists in Mat.Group Recycle' INTO MSG_ERROR SEPARATED BY SPACE.
         MESSAGE  MSG_ERROR TYPE 'I'.
       ELSE.

         VTOTAL = 0.
         LOOP AT IT_RECYCLE01 WHERE FLAGS = 'X'.
           VTOTAL = VTOTAL + IT_RECYCLE01-QUANT.
         ENDLOOP.

         IF VTOTAL = 0.
           MESSAGE 'Please Select Raw Material Recycle before Execution' TYPE 'S'.
         ELSEIF VTOTAL NE ZQTY.
           MESSAGE 'Quantity Raw Recycle <> Quantity Order' TYPE 'I'.
         ELSE.

           READ TABLE IT_RECYCLE01 INDEX 1.
           ZORDERDATA-MATERIAL           = IT_RECYCLE01-MATNR.
           ZORDERDATA-ORDER_TYPE         = VORDER_TYPE.
           ZORDERDATA-PLANT              = IT_RECYCLE01-WERKS.
           ZORDERDATA-QUANTITY           = ZQTY.
           ZORDERDATA-QUANTITY_UOM       = IT_RECYCLE01-MEINS.
           ZORDERDATA-BASIC_START_DATE   = ZPOSDATE.
           ZORDERDATA-BASIC_END_DATE     = ZPOSDATE.
*    ZORDERDATA-PROD_VERSION       = IT_RECYCLE01-PROD_VERSION.
           ZORDERDATA-GOODS_RECIPIENT    = ZRESOURCE.
           APPEND ZORDERDATA.

           CLEAR: ZRETURN, ZORDER_NUMBER, VBKTXT.

           CALL FUNCTION 'BAPI_PROCORD_CREATE'
             EXPORTING
               ORDERDATA    = ZORDERDATA
             IMPORTING
               RETURN       = ZRETURN
               ORDER_NUMBER = ZORDER_NUMBER.

           IF  ZRETURN IS INITIAL.
*      WAIT UP TO 1 SECONDS.

******Add By Will 28 Des 2012
             DO 20 TIMES.
               CALL FUNCTION 'ENQUEUE_ESORDER'
                 EXPORTING
                   AUFNR          = ZORDER_NUMBER
                 EXCEPTIONS
                   FOREIGN_LOCK   = 2
                   SYSTEM_FAILURE = 3.

               IF SY-SUBRC  NE 0.
                 WAIT UP TO 1 SECONDS.
               ELSE.
                 CALL FUNCTION 'DEQUEUE_ESORDER'
                   EXPORTING
                     AUFNR = ZORDER_NUMBER.
                 EXIT.
               ENDIF.
             ENDDO.
******End Add By Will 28 Des 2012

             IT_ORDER-ZORDER_NUMBER = ZORDER_NUMBER.
             APPEND IT_ORDER.
             CONCATENATE ZORDER_NUMBER ZOPERATOR INTO VBKTXT.
             CALL FUNCTION 'BAPI_PROCORD_RELEASE'
               EXPORTING
                 RELEASE_CONTROL    = '1'
                 WORK_PROCESS_GROUP = 'COWORK_BAPI'
                 WORK_PROCESS_MAX   = 99
               TABLES
                 ORDERS             = IT_ORDER
                 DETAIL_RETURN      = IT_RETURN2.

             CALL FUNCTION 'DEQUEUE_ALL'.

*        IF ZPLANT = '1000'.
*          CONCATENATE 'W' SY-DATUM '/' IT_RECYCLE01-FILM '/' IT_RECYCLE01-LINE INTO VITTEM_TEXT.
*        ELSEIF ZPLANT = '2000'.
*          CONCATENATE 'K' SY-DATUM '/' IT_RECYCLE01-FILM '/' IT_RECYCLE01-LINE INTO VITTEM_TEXT.
*        ENDIF.

             LOOP AT IT_RECYCLE01 WHERE FLAGS = 'X'.
               CONCATENATE IT_RECYCLE01-FILM '/' IT_RECYCLE01-LINE '/' VTERMINAL INTO VITTEM_TEXT.
               EXIT.
             ENDLOOP.

*        GR Process Order
             THEADER-PSTNG_DATE = ZPOSDATE.
             THEADER-DOC_DATE   = ZPOSDATE.
             THEADER-HEADER_TXT = VBKTXT.


             TITEM-MATERIAL  = IT_RECYCLE01-MATNR.
             TITEM-PLANT     = IT_RECYCLE01-WERKS.
             TITEM-STGE_LOC  = IT_RECYCLE01-LGORT2.
             TITEM-MOVE_TYPE = '101'.
             TITEM-ENTRY_QNT = ZQTY.
             TITEM-ENTRY_UOM = IT_RECYCLE01-MEINS.
             TITEM-ORDERID   = ZORDER_NUMBER.
             TITEM-GR_RCPT   = ZRESOURCE.
             TITEM-MVT_IND   = 'F'.
             TITEM-ITEM_TEXT = VITTEM_TEXT.
             TITEM-MOVE_REAS = IT_RECYCLE01-GRUND.
             TITEM-UNLOAD_PT = IT_RECYCLE01-TGL.
             APPEND TITEM.

             CALL FUNCTION 'BAPI_GOODSMVT_CREATE' " GR Process Order
                EXPORTING
                  GOODSMVT_HEADER         = THEADER
                  GOODSMVT_CODE           = '02'
                  TESTRUN                 = ' '
*           GOODSMVT_REF_EWM        =
                IMPORTING
*           GOODSMVT_HEADRET        =
                  MATERIALDOCUMENT        = MATDOC
                  MATDOCUMENTYEAR         = MATYEAR
                TABLES
                  GOODSMVT_ITEM           = TITEM
*           GOODSMVT_SERIALNUMBER   =
                  RETURN                  = IT_RET.
*           GOODSMVT_SERV_PART_DATA =
*           EXTENSIONIN             =

             IF IT_RET[] IS INITIAL.

               IT_DISPLAY-AUFNR    = ZORDER_NUMBER.
               IT_DISPLAY-BUDAT    = SY-DATUM.
               IT_DISPLAY-BLDAT    = SY-DATUM.
               IT_DISPLAY-BWART    = '101'.
               IT_DISPLAY-CPUDT    = SY-DATUM.
               IT_DISPLAY-CPUTM    = SY-UZEIT.
               IT_DISPLAY-USNAM    = ZOPERATOR.
               IT_DISPLAY-MATNR    = IT_RECYCLE01-MATNR.
               IT_DISPLAY-MATRR    = IT_RECYCLE01-MATRR.
               IT_DISPLAY-WERKS    = IT_RECYCLE01-WERKS.
               IT_DISPLAY-LGORT    = IT_RECYCLE01-LGORT2.
               IT_DISPLAY-MENGE    = ZQTY.
               IT_DISPLAY-MEINS    = IT_RECYCLE01-MEINS.
               IT_DISPLAY-WEMPF    = ZRESOURCE.
               IT_DISPLAY-GRUND    = IT_RECYCLE01-GRUND.
               IT_DISPLAY-MBLNR    = MATDOC.
               IT_DISPLAY-MJAHR    = MATYEAR.
               IT_DISPLAY-LINE     = IT_RECYCLE01-LINE.
               IT_DISPLAY-FILM     = IT_RECYCLE01-FILM.
               IT_DISPLAY-MSG_TYPE = 'S'.
               IT_DISPLAY-MSG_DESC = 'Success'.
               IT_DISPLAY-ICON     = ICON_GREEN_LIGHT.
               IT_DISPLAY-TGL      = IT_RECYCLE01-TGL.
               IT_DISPLAY-MATNR2   = IT_RECYCLE01-MATNR.
               IT_DISPLAY-VTERMINAL = VTERMINAL.
               APPEND IT_DISPLAY.

               CLEAR: IT_RETURN. REFRESH: IT_RETURN.
               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                 EXPORTING
                   WAIT   = 'X'
                 IMPORTING
                   RETURN = IT_RETURN.


*        GI Process Order
               CLEAR : MATDOC, MATYEAR, IT_RET, IT_RETURN, THEADER, TITEM. REFRESH: IT_RET, IT_RETURN, THEADER, TITEM.
               THEADER-PSTNG_DATE = ZPOSDATE.
               THEADER-DOC_DATE   = ZPOSDATE.
               THEADER-HEADER_TXT = VBKTXT.


               LOOP AT IT_RECYCLE01 WHERE FLAGS = 'X'.
                 CLEAR VITTEM_TEXT.
                 CONCATENATE IT_RECYCLE01-FILM '/' IT_RECYCLE01-LINE '/' VTERMINAL INTO VITTEM_TEXT.
                 TITEM-MATERIAL  = IT_RECYCLE01-MATRR.
                 TITEM-PLANT     = IT_RECYCLE01-WERKS.
                 TITEM-STGE_LOC  = IT_RECYCLE01-LGORT.
                 TITEM-MOVE_TYPE = '261'.
                 TITEM-ENTRY_QNT = IT_RECYCLE01-QUANT.
                 TITEM-ENTRY_UOM = IT_RECYCLE01-MEINS.
                 TITEM-ORDERID   = ZORDER_NUMBER.
                 TITEM-GR_RCPT   = ZRESOURCE.
                 TITEM-ITEM_TEXT = VITTEM_TEXT.
*          TITEM-MOVE_REAS = IT_RECYCLE01-GRUND.
                 TITEM-UNLOAD_PT = IT_RECYCLE01-TGL.
                 APPEND TITEM.
               ENDLOOP.

               CALL FUNCTION 'BAPI_GOODSMVT_CREATE' " GI Process Order
                 EXPORTING
                   GOODSMVT_HEADER         = THEADER
                   GOODSMVT_CODE           = '06'
                   TESTRUN                 = ' '
*           GOODSMVT_REF_EWM        =
                 IMPORTING
*           GOODSMVT_HEADRET        =
                   MATERIALDOCUMENT        = MATDOC
                   MATDOCUMENTYEAR         = MATYEAR
                 TABLES
                   GOODSMVT_ITEM           = TITEM
*           GOODSMVT_SERIALNUMBER   =
                   RETURN                  = IT_RET.
*           GOODSMVT_SERV_PART_DATA =
*           EXTENSIONIN             =

               IF IT_RET[] IS INITIAL.
                 LOOP AT IT_RECYCLE01 WHERE FLAGS = 'X'.
                   IT_DISPLAY-AUFNR    = ZORDER_NUMBER.
                   IT_DISPLAY-BUDAT    = SY-DATUM.
                   IT_DISPLAY-BLDAT    = SY-DATUM.
                   IT_DISPLAY-BWART    = '261'.
                   IT_DISPLAY-CPUDT    = SY-DATUM.
                   IT_DISPLAY-CPUTM    = SY-UZEIT.
                   IT_DISPLAY-USNAM    = ZOPERATOR.
                   IT_DISPLAY-MATNR    = IT_RECYCLE01-MATNR.
                   IT_DISPLAY-MATRR    = IT_RECYCLE01-MATRR.
                   IT_DISPLAY-WERKS    = ZPLANT.
                   IT_DISPLAY-LGORT    = IT_RECYCLE01-LGORT.
                   IT_DISPLAY-MENGE    = IT_RECYCLE01-QUANT.
                   IT_DISPLAY-MEINS    = IT_RECYCLE01-MEINS.
                   IT_DISPLAY-WEMPF    = ZRESOURCE.
*        IT_DISPLAY-GRUND    = IT_RECYCLE01-GRUND.
                   IT_DISPLAY-MBLNR    = MATDOC.
                   IT_DISPLAY-MJAHR    = MATYEAR.
                   IT_DISPLAY-LINE     = IT_RECYCLE01-LINE.
                   IT_DISPLAY-FILM     = IT_RECYCLE01-FILM.
                   IT_DISPLAY-MSG_TYPE = 'S'.
                   IT_DISPLAY-MSG_DESC = 'Success'.
                   IT_DISPLAY-ICON     = ICON_GREEN_LIGHT.
                   IT_DISPLAY-TGL      = IT_RECYCLE01-TGL.
                   IT_DISPLAY-MATNR2   = IT_RECYCLE01-MATRR.
                   IT_DISPLAY-VTERMINAL = VTERMINAL.
                   APPEND IT_DISPLAY.
                 ENDLOOP.

                 CLEAR: IT_RETURN. REFRESH: IT_RETURN.
                 CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                   EXPORTING
                     WAIT   = 'X'
                   IMPORTING
                     RETURN = IT_RETURN.

                 CLEAR: IT_RETURN2. REFRESH: IT_RETURN2.
                 CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
                   EXPORTING
                     SCOPE_COMPL_TECH   = '1'
                     WORK_PROCESS_GROUP = 'COWORK_BAPI'
                     WORK_PROCESS_MAX   = 99
                   TABLES
                     ORDERS             = IT_ORDER
                     DETAIL_RETURN      = IT_RETURN2.

                 CALL FUNCTION 'DEQUEUE_ALL'.
               ELSE.

                 LOOP AT IT_RECYCLE01 WHERE FLAGS = 'X'.
                   IT_DISPLAY-AUFNR    = ZORDER_NUMBER.
                   IT_DISPLAY-BUDAT    = SY-DATUM.
                   IT_DISPLAY-BLDAT    = SY-DATUM.
                   IT_DISPLAY-BWART    = '261'.
                   IT_DISPLAY-CPUDT    = SY-DATUM.
                   IT_DISPLAY-CPUTM    = SY-UZEIT.
                   IT_DISPLAY-USNAM    = ZOPERATOR.
                   IT_DISPLAY-MATNR    = IT_RECYCLE01-MATNR.
                   IT_DISPLAY-MATRR    = IT_RECYCLE01-MATRR.
                   IT_DISPLAY-WERKS    = ZPLANT.
                   IT_DISPLAY-LGORT    = IT_RECYCLE01-LGORT.
                   IT_DISPLAY-MENGE    = IT_RECYCLE01-QUANT.
                   IT_DISPLAY-MEINS    = IT_RECYCLE01-MEINS.
                   IT_DISPLAY-WEMPF    = ZRESOURCE.
*            IT_DISPLAY-GRUND    = IT_RECYCLE01-GRUND.
                   IT_DISPLAY-MBLNR    = MATDOC.
                   IT_DISPLAY-MJAHR    = MATYEAR.
                   IT_DISPLAY-LINE     = IT_RECYCLE01-LINE.
                   IT_DISPLAY-FILM     = IT_RECYCLE01-FILM.
                   LOOP AT IT_RET WHERE TYPE = 'E'.
                     IT_DISPLAY-MSG_TYPE = IT_RET-TYPE.
                     IT_DISPLAY-MSG_DESC = IT_RET-MESSAGE.
                   ENDLOOP.
                   IT_DISPLAY-ICON     = ICON_RED_LIGHT.
                   IT_DISPLAY-TGL      = IT_RECYCLE01-TGL.
                   IT_DISPLAY-MATNR2   = IT_RECYCLE01-MATRR.
                   IT_DISPLAY-VTERMINAL = VTERMINAL.
                   APPEND IT_DISPLAY.
                 ENDLOOP.

                 LOOP AT IT_DISPLAY INTO WA_DISPLAY WHERE MSG_TYPE = 'E'.
                   INSERT ZERROR_LOG FROM WA_DISPLAY.
                 ENDLOOP.
                 CALL FUNCTION 'DEQUEUE_ALL'.

               ENDIF.

             ELSE.

               LOOP AT IT_RET WHERE TYPE = 'E'.
                 IT_DISPLAY-AUFNR    = ZORDER_NUMBER.
                 IT_DISPLAY-BUDAT    = SY-DATUM.
                 IT_DISPLAY-BLDAT    = SY-DATUM.
                 IT_DISPLAY-BWART    = '101'.
                 IT_DISPLAY-CPUDT    = SY-DATUM.
                 IT_DISPLAY-CPUTM    = SY-UZEIT.
                 IT_DISPLAY-USNAM    = ZOPERATOR.
                 IT_DISPLAY-MATNR    = IT_RECYCLE01-MATNR.
                 IT_DISPLAY-MATRR    = IT_RECYCLE01-MATRR.
                 IT_DISPLAY-WERKS    = IT_RECYCLE01-WERKS.
                 IT_DISPLAY-LGORT    = IT_RECYCLE01-LGORT2.
                 IT_DISPLAY-MENGE    = ZQTY.
                 IT_DISPLAY-MEINS    = IT_RECYCLE01-MEINS.
                 IT_DISPLAY-WEMPF    = ZRESOURCE.
                 IT_DISPLAY-GRUND    = IT_RECYCLE01-GRUND.
                 IT_DISPLAY-MBLNR    = MATDOC.
                 IT_DISPLAY-MJAHR    = MATYEAR.
                 IT_DISPLAY-LINE     = IT_RECYCLE01-LINE.
                 IT_DISPLAY-FILM     = IT_RECYCLE01-FILM.
                 IT_DISPLAY-MSG_TYPE = IT_RET-TYPE.
                 IT_DISPLAY-MSG_DESC = IT_RET-MESSAGE.
                 IT_DISPLAY-ICON     = ICON_RED_LIGHT.
                 IT_DISPLAY-TGL      = IT_RECYCLE01-TGL.
                 IT_DISPLAY-MATNR2   = IT_RECYCLE01-MATRR.
                 IT_DISPLAY-VTERMINAL = VTERMINAL.
                 APPEND IT_DISPLAY.
               ENDLOOP.

               CLEAR: IT_RETURN2. REFRESH: IT_RETURN2.
               CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
                 EXPORTING
                   SCOPE_COMPL_TECH   = '1'
                   WORK_PROCESS_GROUP = 'COWORK_BAPI'
                   WORK_PROCESS_MAX   = 99
                 TABLES
                   ORDERS             = IT_ORDER
                   DETAIL_RETURN      = IT_RETURN2.

               CALL FUNCTION 'DEQUEUE_ALL'.

*         LOOP AT IT_DISPLAY INTO WA_DISPLAY WHERE MSG_TYPE = 'E'.
*           INSERT ZERROR_LOG FROM WA_DISPLAY.
*         ENDLOOP.
             ENDIF.

           ELSEIF ZRETURN IS NOT INITIAL.

             MESSAGE ZRETURN-MESSAGE TYPE 'I'.

           ENDIF.

           CLEAR: FLAG.
           IF ZRETURN-MESSAGE IS INITIAL OR VMATNR IS NOT INITIAL.

             UNASSIGN <FS_DISPLAY>.
             LOOP AT IT_DISPLAY ASSIGNING <FS_DISPLAY> WHERE MSG_TYPE NE 'S'.
               FLAG = 'X'.
             ENDLOOP.
             IF FLAG = ''.
               UNASSIGN <FS_DISPLAY>.
               READ TABLE IT_DISPLAY ASSIGNING <FS_DISPLAY> WITH KEY BWART = '101'.
               IF SY-SUBRC = 0.
                 SUBMIT ZMMF_SCARP WITH MBLNR = <FS_DISPLAY>-MBLNR
                                   WITH MJAHR = <FS_DISPLAY>-MJAHR
                                   AND RETURN.
               ENDIF.
             ENDIF.

             IF IT_DISPLAY[] IS NOT INITIAL.
               PERFORM INSERT_SQL.
             ENDIF.

             PERFORM DISPLAY.
             CLEAR: IT_RECYCLE01. REFRESH: IT_RECYCLE01.

           ENDIF.
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.

 ENDFORM.                    "EXECUTION

*&---------------------------------------------------------------------*
*&      Form  LOAD_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM LOAD_ERROR.
   CLEAR: IT_ERROR01, IT_DISPLAY, VMAKTX, VMAKTR, SY-TABIX, VOBJID.
   REFRESH: IT_ERROR01, IT_DISPLAY.

   SELECT SINGLE HRP1001~OBJID INTO (VOBJID)
       FROM HRP1001
       JOIN CRHD ON CRHD~HROID = HRP1001~SOBID
       WHERE WERKS IN SO_PLNT2
       AND   ARBPL IN SO_RES2
       AND   SCLAS = 'A'
       AND   HRP1001~OBJID = ZNIK.

   IF SO_LGORT-LOW IS NOT INITIAL.
     SELECT SINGLE ZTMAP_SLOCREC~ZRRLGORT INTO (VLGORT)
        FROM  ZTMAP_SLOCREC
        WHERE ZTMAP_SLOCREC~WERKS = SO_PLNT2-LOW
        AND   ZTMAP_SLOCREC~ARBPL = SO_RES2-LOW
        AND   ZTMAP_SLOCREC~ZRRLGORT = SO_LGORT-LOW.

   ENDIF.

   IF VOBJID IS INITIAL.
     CONCATENATE 'NIK' ZNIK 'does not exists in Resource' SO_RES2-LOW INTO MSG_ERROR SEPARATED BY SPACE.
     MESSAGE MSG_ERROR TYPE 'I'.

   ELSEIF VLGORT IS INITIAL AND SO_LGORT-LOW IS NOT INITIAL.
     CONCATENATE 'SLoc GI' SO_LGORT-LOW 'does not exists in Plant' SO_PLNT2-LOW 'and Resource' SO_RES2-LOW INTO MSG_ERROR SEPARATED BY SPACE.
     MESSAGE MSG_ERROR TYPE 'I'.
   ELSE.

     SELECT ZERROR_LOG~MATNR AS MATNR ZERROR_LOG~MATRR AS MATRR ZERROR_LOG~MENGE AS QUANT ZERROR_LOG~MEINS AS MEINS
            ZERROR_LOG~WERKS AS WERKS ZERROR_LOG~LGORT AS LGORT ZERROR_LOG~FILM  AS FILM
            ZERROR_LOG~LINE  AS LINE  ZERROR_LOG~TGL   AS TGL   ZERROR_LOG~AUFNR AS AUFNR ZERROR_LOG~WEMPF AS WEMPF
            ZERROR_LOG~BWART AS BWART
       FROM ZERROR_LOG INTO CORRESPONDING FIELDS OF TABLE IT_ERROR01
       WHERE ZERROR_LOG~WERKS IN SO_PLNT2
       AND   ZERROR_LOG~WEMPF IN SO_RES2
*    AND   ZERROR_LOG~BUDAT IN SO_PSDT2
       AND   ZERROR_LOG~BLDAT IN SO_BLDAT
       AND   ZERROR_LOG~MATNR IN SO_MTNR2
       AND   ZERROR_LOG~LGORT IN SO_LGORT
       AND   ZERROR_LOG~AUFNR IN ZAUFNR.

     SORT IT_ERROR01 ASCENDING BY AUFNR.

     LOOP AT IT_ERROR01.
       IT_ERROR01-NOMOR = SY-TABIX.

       SELECT SINGLE MAKT~MAKTX INTO (IT_ERROR01-MAKTX)
         FROM MAKT
         WHERE MAKT~MATNR = IT_ERROR01-MATNR
         AND   MAKT~SPRAS = 'EN'.

       IF IT_ERROR01-MATRR IS NOT INITIAL.
         SELECT SINGLE MAKT~MAKTX INTO (IT_ERROR01-MAKTR)
           FROM MAKT
           WHERE MAKT~MATNR = IT_ERROR01-MATRR
           AND   MAKT~SPRAS = 'EN'.
       ENDIF.

       SELECT SINGLE MARD~LABST INTO (IT_ERROR01-LABST)
         FROM MARD
         WHERE MARD~WERKS = IT_ERROR01-WERKS
         AND   MARD~MATNR = IT_ERROR01-MATRR
         AND   MARD~LGORT = IT_ERROR01-LGORT.
       IF IT_ERROR01-QUANT < IT_ERROR01-LABST.
         IT_ERROR01-STAT = ICON_GREEN_LIGHT.
       ELSE.
         IT_ERROR01-STAT = ICON_RED_LIGHT.
       ENDIF.
       MODIFY IT_ERROR01.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    "LOAD_ERROR

*&---------------------------------------------------------------------*
*&      Form  EXECUTION_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM EXECUTION_ERROR.
   CLEAR: TITEM, IT_DISPLAY, IT_ERROR02, MSG_ERROR, ZORDER_NUMBER, VTERMINAL. REFRESH: TITEM, IT_DISPLAY, IT_ERROR02.

   CALL FUNCTION 'POC_GET_COMPUTER_NAME'
     IMPORTING
       EX_COMPUTER_NAME = VTERMINAL
     EXCEPTIONS
       GUI_ERROR        = 1.

   LOOP AT IT_ERROR01 WHERE FLAGS = 'X'.
     MSG_ERROR = 'X'.
     EXIT.
   ENDLOOP.

   IF MSG_ERROR IS INITIAL.
     MESSAGE 'Please Select Order Number' TYPE 'S'.
   ELSE.

     IT_ERROR02[] = IT_ERROR01[].

     LOOP AT IT_ERROR02 WHERE FLAGS NE 'X'.
       DELETE IT_ERROR02.
     ENDLOOP.

     SORT IT_ERROR02 BY AUFNR.
     DELETE ADJACENT DUPLICATES FROM IT_ERROR02 COMPARING AUFNR FLAGS.

     LOOP AT IT_ERROR02 WHERE FLAGS = 'X'.

       CLEAR : MATDOC, MATYEAR, IT_RET, IT_RETURN, THEADER, TITEM, VBKTXT, ZORDER_NUMBER. REFRESH: IT_RET, IT_RETURN, THEADER, TITEM.
       CONCATENATE IT_ERROR02-AUFNR ZNIK INTO VBKTXT.
       THEADER-PSTNG_DATE = SY-DATUM.
       THEADER-DOC_DATE   = SY-DATUM.
       THEADER-HEADER_TXT = VBKTXT.


       LOOP AT IT_ERROR01 WHERE AUFNR = IT_ERROR02-AUFNR.

         ZORDER_NUMBER = IT_ERROR01-AUFNR.
         CLEAR VITTEM_TEXT.
         CONCATENATE IT_ERROR01-FILM '/' IT_ERROR01-LINE '/' VTERMINAL INTO VITTEM_TEXT.
         TITEM-MATERIAL  = IT_ERROR01-MATRR.
         TITEM-PLANT     = IT_ERROR01-WERKS.
         TITEM-STGE_LOC  = IT_ERROR01-LGORT.
         TITEM-MOVE_TYPE = '261'.
         TITEM-ENTRY_QNT = IT_ERROR01-QUANT.
         TITEM-ENTRY_UOM = IT_ERROR01-MEINS.
         TITEM-ORDERID   = IT_ERROR01-AUFNR.
         TITEM-GR_RCPT   = IT_ERROR01-WEMPF.
         TITEM-ITEM_TEXT = VITTEM_TEXT.
         TITEM-UNLOAD_PT = IT_ERROR01-TGL.
         APPEND TITEM.

       ENDLOOP.


       CALL FUNCTION 'BAPI_GOODSMVT_CREATE' " GI Process Order
         EXPORTING
           GOODSMVT_HEADER         = THEADER
           GOODSMVT_CODE           = '06'
           TESTRUN                 = ' '
*           GOODSMVT_REF_EWM        =
         IMPORTING
*           GOODSMVT_HEADRET        =
           MATERIALDOCUMENT        = MATDOC
           MATDOCUMENTYEAR         = MATYEAR
         TABLES
           GOODSMVT_ITEM           = TITEM
*           GOODSMVT_SERIALNUMBER   =
           RETURN                  = IT_RET.
*           GOODSMVT_SERV_PART_DATA =
*           EXTENSIONIN             =

       IF IT_RET[] IS INITIAL.
         LOOP AT IT_ERROR01 WHERE  AUFNR = ZORDER_NUMBER.
           IT_DISPLAY-AUFNR    = IT_ERROR01-AUFNR.
           IT_DISPLAY-BUDAT    = SY-DATUM.
           IT_DISPLAY-BLDAT    = SY-DATUM.
           IT_DISPLAY-BWART    = '261'.
           IT_DISPLAY-CPUDT    = SY-DATUM.
           IT_DISPLAY-CPUTM    = SY-UZEIT.
           IT_DISPLAY-USNAM    = ZNIK.
*        IT_DISPLAY-MATNR    = IT_ERROR02-MATNR.
*        IT_DISPLAY-MATRR    = IT_ERROR02-MATRR.
           IT_DISPLAY-WERKS    = IT_ERROR01-WERKS.
           IT_DISPLAY-LGORT    = IT_ERROR01-LGORT.
           IT_DISPLAY-MENGE    = IT_ERROR01-QUANT.
           IT_DISPLAY-MEINS    = IT_ERROR01-MEINS.
           IT_DISPLAY-WEMPF    = IT_ERROR01-WEMPF.
           IT_DISPLAY-MBLNR    = MATDOC.
           IT_DISPLAY-MJAHR    = MATYEAR.
           IT_DISPLAY-LINE     = IT_ERROR01-LINE.
           IT_DISPLAY-FILM     = IT_ERROR01-FILM.
           IT_DISPLAY-MSG_TYPE = 'S'.
           IT_DISPLAY-MSG_DESC = 'Success'.
           IT_DISPLAY-ICON     = ICON_GREEN_LIGHT.
           IT_DISPLAY-TGL      = IT_ERROR01-TGL.
           IT_DISPLAY-MATNR2   = IT_ERROR01-MATRR.
           IT_DISPLAY-VTERMINAL = VTERMINAL.
           APPEND IT_DISPLAY.
         ENDLOOP.

         CLEAR: IT_RETURN. REFRESH: IT_RETURN.
         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT   = 'X'
           IMPORTING
             RETURN = IT_RETURN.

         CLEAR: IT_RETURN2,IT_ORDER. REFRESH: IT_RETURN2, IT_ORDER.

         IT_ORDER-ZORDER_NUMBER = ZORDER_NUMBER.
         APPEND IT_ORDER.
         CLEAR ZORDER_NUMBER.

         CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
           EXPORTING
             SCOPE_COMPL_TECH   = '1'
             WORK_PROCESS_GROUP = 'COWORK_BAPI'
             WORK_PROCESS_MAX   = 99
           TABLES
             ORDERS             = IT_ORDER
             DETAIL_RETURN      = IT_RETURN2.

         DELETE FROM ZERROR_LOG WHERE AUFNR = IT_ORDER-ZORDER_NUMBER.

         CALL FUNCTION 'DEQUEUE_ALL'.
       ELSE.

         LOOP AT IT_ERROR01 WHERE AUFNR = ZORDER_NUMBER.
           IT_DISPLAY-AUFNR    = IT_ERROR01-AUFNR.
           IT_DISPLAY-BUDAT    = SY-DATUM.
           IT_DISPLAY-BLDAT    = SY-DATUM.
           IT_DISPLAY-BWART    = '261'.
           IT_DISPLAY-CPUDT    = SY-DATUM.
           IT_DISPLAY-CPUTM    = SY-UZEIT.
           IT_DISPLAY-USNAM    = ZNIK.
*            IT_DISPLAY-MATNR    = IT_ERROR02-MATRR.
           IT_DISPLAY-WERKS    = IT_ERROR01-WERKS.
           IT_DISPLAY-LGORT    = IT_ERROR01-LGORT.
           IT_DISPLAY-MENGE    = IT_ERROR01-QUANT.
           IT_DISPLAY-MEINS    = IT_ERROR01-MEINS.
           IT_DISPLAY-WEMPF    = IT_ERROR01-WEMPF.
           IT_DISPLAY-MBLNR    = MATDOC.
           IT_DISPLAY-MJAHR    = MATYEAR.
           IT_DISPLAY-LINE     = IT_ERROR01-LINE.
           IT_DISPLAY-FILM     = IT_ERROR01-FILM.
           LOOP AT IT_RET WHERE TYPE = 'E'.
             IT_DISPLAY-MSG_TYPE = IT_RET-TYPE.
             IT_DISPLAY-MSG_DESC = IT_RET-MESSAGE.
           ENDLOOP.
           IT_DISPLAY-ICON     = ICON_RED_LIGHT.
           IT_DISPLAY-TGL      = IT_ERROR01-TGL.
           IT_DISPLAY-MATNR2   = IT_ERROR01-MATRR.
           IT_DISPLAY-VTERMINAL = VTERMINAL.
           APPEND IT_DISPLAY.
         ENDLOOP.

         CALL FUNCTION 'DEQUEUE_ALL'.
       ENDIF.

     ENDLOOP.

     IF IT_DISPLAY[] IS NOT INITIAL.
       PERFORM INSERT_SQL.
     ENDIF.

     PERFORM DISPLAY.
     PERFORM LOAD_ERROR.

   ENDIF.
*ENDIF.

 ENDFORM.                    "EXECUTION_ERROR

*&---------------------------------------------------------------------*
*&      Form  TESTRUN_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM TESTRUN_ERROR.
   CLEAR: TITEM, IT_DISPLAY, MSG_ERROR, IT_ERROR02, ZORDER_NUMBER, VTERMINAL. REFRESH: TITEM, IT_DISPLAY, IT_ERROR02.

   CALL FUNCTION 'POC_GET_COMPUTER_NAME'
     IMPORTING
       EX_COMPUTER_NAME = VTERMINAL
     EXCEPTIONS
       GUI_ERROR        = 1.

   LOOP AT IT_ERROR01 WHERE FLAGS = 'X'.
     MSG_ERROR = 'X'.
     EXIT.
   ENDLOOP.

   IF MSG_ERROR IS INITIAL.
     MESSAGE 'Please Select Order Number' TYPE 'S'.
   ELSE.
     IT_ERROR02[] = IT_ERROR01[].

     LOOP AT IT_ERROR02 WHERE FLAGS NE 'X'.
       DELETE IT_ERROR02.
     ENDLOOP.

     SORT IT_ERROR02 BY AUFNR.
     DELETE ADJACENT DUPLICATES FROM IT_ERROR02 COMPARING AUFNR FLAGS.

     LOOP AT IT_ERROR02 WHERE FLAGS = 'X'.

       CLEAR : MATDOC, MATYEAR, IT_RET, IT_RETURN, THEADER, TITEM, VBKTXT, ZORDER_NUMBER. REFRESH: IT_RET, IT_RETURN, THEADER, TITEM.
       CONCATENATE IT_ERROR02-AUFNR ZNIK INTO VBKTXT.
       THEADER-PSTNG_DATE = SY-DATUM.
       THEADER-DOC_DATE   = SY-DATUM.
       THEADER-HEADER_TXT = VBKTXT.


       LOOP AT IT_ERROR01 WHERE AUFNR = IT_ERROR02-AUFNR.

         ZORDER_NUMBER = IT_ERROR01-AUFNR.
         CLEAR VITTEM_TEXT.
         CONCATENATE IT_ERROR01-FILM '/' IT_ERROR01-LINE '/' VTERMINAL INTO VITTEM_TEXT.
         TITEM-MATERIAL  = IT_ERROR01-MATRR.
         TITEM-PLANT     = IT_ERROR01-WERKS.
         TITEM-STGE_LOC  = IT_ERROR01-LGORT.
         TITEM-MOVE_TYPE = '261'.
         TITEM-ENTRY_QNT = IT_ERROR01-QUANT.
         TITEM-ENTRY_UOM = IT_ERROR01-MEINS.
         TITEM-ORDERID   = IT_ERROR01-AUFNR.
         TITEM-GR_RCPT   = IT_ERROR01-WEMPF.
         TITEM-ITEM_TEXT = VITTEM_TEXT.
         TITEM-UNLOAD_PT = IT_ERROR01-TGL.
         APPEND TITEM.

       ENDLOOP.


       CALL FUNCTION 'BAPI_GOODSMVT_CREATE' " GI Process Order
         EXPORTING
           GOODSMVT_HEADER         = THEADER
           GOODSMVT_CODE           = '06'
           TESTRUN                 = 'X'
*           GOODSMVT_REF_EWM        =
         IMPORTING
*           GOODSMVT_HEADRET        =
           MATERIALDOCUMENT        = MATDOC
           MATDOCUMENTYEAR         = MATYEAR
         TABLES
           GOODSMVT_ITEM           = TITEM
*           GOODSMVT_SERIALNUMBER   =
           RETURN                  = IT_RET.
*           GOODSMVT_SERV_PART_DATA =
*           EXTENSIONIN             =

       IF IT_RET[] IS INITIAL.
         LOOP AT IT_ERROR01 WHERE  AUFNR = ZORDER_NUMBER.
           IT_DISPLAY-AUFNR    = IT_ERROR01-AUFNR.
           IT_DISPLAY-BUDAT    = SY-DATUM.
           IT_DISPLAY-BLDAT    = SY-DATUM.
           IT_DISPLAY-BWART    = '261'.
           IT_DISPLAY-CPUDT    = SY-DATUM.
           IT_DISPLAY-CPUTM    = SY-UZEIT.
           IT_DISPLAY-USNAM    = ZNIK.
*        IT_DISPLAY-MATNR    = IT_ERROR02-MATRR.
           IT_DISPLAY-WERKS    = IT_ERROR01-WERKS.
           IT_DISPLAY-LGORT    = IT_ERROR01-LGORT.
           IT_DISPLAY-MENGE    = IT_ERROR01-QUANT.
           IT_DISPLAY-MEINS    = IT_ERROR01-MEINS.
           IT_DISPLAY-WEMPF    = IT_ERROR01-WEMPF.
           IT_DISPLAY-MBLNR    = MATDOC.
           IT_DISPLAY-MJAHR    = MATYEAR.
           IT_DISPLAY-LINE     = IT_ERROR01-LINE.
           IT_DISPLAY-FILM     = IT_ERROR01-FILM.
           IT_DISPLAY-MSG_TYPE = 'S'.
           IT_DISPLAY-MSG_DESC = 'Success'.
           IT_DISPLAY-ICON     = ICON_GREEN_LIGHT.
           IT_DISPLAY-TGL      = IT_ERROR01-TGL.
           IT_DISPLAY-MATNR2   = IT_ERROR01-MATRR.
           IT_DISPLAY-VTERMINAL = VTERMINAL.
           APPEND IT_DISPLAY.
         ENDLOOP.

         CALL FUNCTION 'DEQUEUE_ALL'.

       ELSE.

         LOOP AT IT_ERROR01 WHERE  AUFNR = ZORDER_NUMBER.
           IT_DISPLAY-AUFNR    = IT_ERROR01-AUFNR.
           IT_DISPLAY-BUDAT    = SY-DATUM.
           IT_DISPLAY-BLDAT    = SY-DATUM.
           IT_DISPLAY-BWART    = '261'.
           IT_DISPLAY-CPUDT    = SY-DATUM.
           IT_DISPLAY-CPUTM    = SY-UZEIT.
           IT_DISPLAY-USNAM    = ZNIK.
*            IT_DISPLAY-MATNR    = IT_ERROR02-MATNR.
*            IT_DISPLAY-MATRR    = IT_ERROR02-MATRR.
           IT_DISPLAY-WERKS    = IT_ERROR01-WERKS.
           IT_DISPLAY-LGORT    = IT_ERROR01-LGORT.
           IT_DISPLAY-MENGE    = IT_ERROR01-QUANT.
           IT_DISPLAY-MEINS    = IT_ERROR01-MEINS.
           IT_DISPLAY-WEMPF    = IT_ERROR01-WEMPF.
           IT_DISPLAY-MBLNR    = MATDOC.
           IT_DISPLAY-MJAHR    = MATYEAR.
           IT_DISPLAY-LINE     = IT_ERROR01-LINE.
           IT_DISPLAY-FILM     = IT_ERROR01-FILM.
           LOOP AT IT_RET WHERE TYPE = 'E'.
             IT_DISPLAY-MSG_TYPE = IT_RET-TYPE.
             IT_DISPLAY-MSG_DESC = IT_RET-MESSAGE.
           ENDLOOP.
           IT_DISPLAY-ICON     = ICON_RED_LIGHT.
           IT_DISPLAY-TGL      = IT_ERROR01-TGL.
           IT_DISPLAY-MATNR2   = IT_ERROR01-MATRR.
           IT_DISPLAY-VTERMINAL = VTERMINAL.
           APPEND IT_DISPLAY.
         ENDLOOP.
         CALL FUNCTION 'DEQUEUE_ALL'.
       ENDIF.

     ENDLOOP.

     PERFORM DISPLAY.
     PERFORM LOAD_ERROR.
*         SORT IT_ERROR01 BY NOMOR.

   ENDIF.

 ENDFORM.                    "TESTRUN_ERROR

*&---------------------------------------------------------------------*
*&      Form  LOAD_CANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM LOAD_CANCEL.
   CLEAR: IT_CANCEL01, IT_CANCEL02, VARBPL.
   REFRESH: IT_CANCEL01, IT_CANCEL02.

   IF SO_RES-LOW IS NOT INITIAL.
     SELECT SINGLE ZTMAP_SLOCREC~ARBPL INTO (VARBPL)
        FROM  ZTMAP_SLOCREC
        WHERE ZTMAP_SLOCREC~WERKS = SO_PLANT-LOW
        AND   ZTMAP_SLOCREC~ARBPL = SO_RES-LOW.

   ENDIF.

   IF SO_RES-LOW IS NOT INITIAL AND VARBPL IS INITIAL.
     CONCATENATE 'Resource' SO_RES-LOW 'does not exists in plant' SO_PLANT-LOW INTO MSG_ERROR SEPARATED BY SPACE.
     MESSAGE MSG_ERROR TYPE 'I'.

   ELSE.
*  IF SO_MATNR IS NOT INITIAL.
     SELECT MSEG~AUFNR AUFK~OBJNR
       INTO CORRESPONDING FIELDS OF TABLE IT_CANCEL02
       FROM MSEG
       JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
       JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
       WHERE MSEG~WERKS IN SO_PLANT
       AND   MSEG~MATNR IN SO_MATNR
       AND   MSEG~AUFNR IN SO_AUFNR
       AND   MSEG~WEMPF IN SO_RES
       AND   MKPF~BUDAT IN SO_POSDT
       AND   AUFK~AUART IN ('ZR01', 'ZR02').

     SORT IT_CANCEL02 BY AUFNR.
     DELETE ADJACENT DUPLICATES FROM IT_CANCEL02 COMPARING AUFNR.

     LOOP AT IT_CANCEL02.

       SELECT MSEG~AUFNR MSEG~MATNR MSEG~BWART MKPF~BUDAT MSEG~WERKS MSEG~MENGE AS QUANT
              MSEG~WEMPF AS RESOURCE MSEG~MEINS MKPF~BKTXT MSEG~ABLAD  MSEG~MBLNR MSEG~LGORT
         INTO (IT_CANCEL01-AUFNR, IT_CANCEL01-MATNR, IT_CANCEL01-BWART, IT_CANCEL01-BUDAT, IT_CANCEL01-WERKS, IT_CANCEL01-QUANT,
               IT_CANCEL01-RESOURCE, IT_CANCEL01-MEINS, IT_CANCEL01-BKTXT, IT_CANCEL01-ABLAD, IT_CANCEL01-MBLNR, IT_CANCEL01-LGORT)
         FROM MSEG
         JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
          WHERE MSEG~WERKS IN SO_PLANT
          AND   MSEG~AUFNR = IT_CANCEL02-AUFNR
          AND   MSEG~WEMPF IN SO_RES
*         AND   MKPF~BUDAT IN SO_POSDT
          AND   MSEG~BWART IN ('101', '102', '261', '262').

         IT_CANCEL01-OBJNR = IT_CANCEL02-OBJNR.
         APPEND IT_CANCEL01.
       ENDSELECT.
     ENDLOOP.

     CLEAR: IT_CANCEL02. REFRESH: IT_CANCEL02.

*  ELSE.
*
*      SELECT MSEG~AUFNR MSEG~MATNR MSEG~BWART MKPF~BUDAT MSEG~WERKS MSEG~MENGE AS QUANT
*             MSEG~WEMPF AS RESOURCE MSEG~MEINS MKPF~BKTXT MSEG~ABLAD  MSEG~MBLNR AUFK~OBJNR
*        INTO CORRESPONDING FIELDS OF TABLE IT_CANCEL01
*        FROM MSEG
*        JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
*        JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
*       WHERE MSEG~WERKS IN SO_PLANT
*       AND   MSEG~MATNR IN SO_MATNR
*       AND   MSEG~AUFNR IN SO_AUFNR
*       AND   MSEG~WEMPF IN SO_RES
*       AND   MKPF~BUDAT IN SO_POSDT
*       AND   MSEG~BWART IN ('101', '102', '261', '262')
*       AND   AUFK~AUART IN ('ZR01', 'ZR02').
*
*  ENDIF.

     IT_CANCEL02[] = IT_CANCEL01[].
     SORT IT_CANCEL01 DESCENDING BY AUFNR MBLNR.
     DELETE ADJACENT DUPLICATES FROM IT_CANCEL01 COMPARING AUFNR.

     LOOP AT IT_CANCEL01.
       CLEAR : VCOUNT, VCOUNT2.
       LOOP AT IT_CANCEL02 WHERE AUFNR = IT_CANCEL01-AUFNR.
         IF IT_CANCEL02-BWART = '101'.
           VCOUNT = VCOUNT + 1.
         ELSEIF IT_CANCEL02-BWART = '102'.
           VCOUNT = VCOUNT - 1.
         ELSEIF IT_CANCEL02-BWART = '261'.
           VCOUNT2 = VCOUNT2 + 1.
         ELSEIF IT_CANCEL02-BWART = '262'.
           VCOUNT2 = VCOUNT2 - 1.
         ENDIF.
       ENDLOOP.
       IF VCOUNT < 1 OR VCOUNT2 < 1.
         DELETE IT_CANCEL01.
       ENDIF.
     ENDLOOP.

     LOOP AT IT_CANCEL01.

       IT_CANCEL01-UNAME = IT_CANCEL01-BKTXT+12(13).
       SELECT SINGLE MAKT~MAKTX INTO (IT_CANCEL01-MAKTX)
         FROM MAKT
         WHERE MAKT~MATNR = IT_CANCEL01-MATNR
         AND   MAKT~SPRAS = 'EN'.

       MOVE IT_CANCEL01-ABLAD TO IT_CANCEL01-TGL.

       CALL FUNCTION 'STATUS_TEXT_EDIT'
         EXPORTING
           CLIENT      = SY-MANDT
           OBJNR       = IT_CANCEL01-OBJNR
           SPRAS       = SY-LANGU
           ONLY_ACTIVE = 'X'
         IMPORTING
           LINE        = IT_CANCEL01-STTXT.

       IF IT_CANCEL01-STTXT+0(4) EQ 'CLSD'.     " FIND ORDER STATUS (CLOSED).
         DELETE IT_CANCEL01 WHERE AUFNR = IT_CANCEL01-AUFNR. "DELETE, IF ORDERSTATUS EQUAL CLOSED.
       ELSEIF IT_CANCEL01-STTXT+0(4) EQ 'REL '.
         IT_CANCEL01-STTXT = 'RELEASE'.
       ELSEIF IT_CANCEL01-STTXT+0(4) EQ 'TECO'.
         IT_CANCEL01-STTXT = 'TECO'.
       ENDIF.
       MODIFY IT_CANCEL01.

     ENDLOOP.

     SORT IT_CANCEL01 ASCENDING BY AUFNR.

   ENDIF.

 ENDFORM.                    "LOAD_CANCEL

*&---------------------------------------------------------------------*
*&      Form  REVOKE_TECO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM REVOKE_TECO.

   LOOP AT IT_CANCEL01 WHERE FLAGS = 'X'.
     PERFORM OPEN_GROUP.

     PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5110'.
     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                   'CAUFVD-AUFNR'.
     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '/00'.
     PERFORM BDC_FIELD       USING 'CAUFVD-AUFNR'
                                   IT_CANCEL01-AUFNR.          "AUFNR
*      perform bdc_field       using 'R62CLORD-FLG_COMPL'
*                                    'X'.
     PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '=TABR'.
     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                   'CAUFVD-GAMNG'.
     PERFORM BDC_DYNPRO      USING 'SAPLCOKO' '5115'.
     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '=BU'.
     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                   'CAUFVD-GAMNG'.
     PERFORM BDC_TRANSACTION USING 'COR2'.

     PERFORM CLOSE_GROUP.


   ENDLOOP.

   COMMIT WORK.

   LOOP AT IT_CANCEL01 WHERE FLAGS = 'X'.
     CALL FUNCTION 'STATUS_TEXT_EDIT'
       EXPORTING
         CLIENT      = SY-MANDT
         OBJNR       = IT_CANCEL01-OBJNR
         SPRAS       = SY-LANGU
         ONLY_ACTIVE = 'X'
       IMPORTING
         LINE        = IT_CANCEL01-STTXT.

     IF IT_CANCEL01-STTXT+0(4) EQ 'REL '.
       IT_CANCEL01-STTXT = 'RELEASE'.
     ELSEIF IT_CANCEL01-STTXT+0(4) EQ 'TECO'.
       IT_CANCEL01-STTXT = 'TECO'.
     ENDIF.
     MODIFY IT_CANCEL01.
   ENDLOOP.

   IF IT_CANCEL01[] IS NOT INITIAL.
     LOOP AT IT_CANCEL01  WHERE FLAGS = 'X'.
       MOVE-CORRESPONDING IT_CANCEL01 TO IT_DISPLAY.
       APPEND IT_DISPLAY.
     ENDLOOP.
     PERFORM INSERT_SQL.
   ENDIF.

 ENDFORM.                    "REVOKE_TECO

*&---------------------------------------------------------------------*
*&      Form  CANCEL_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM CANCEL_POSTING.
   CLEAR: IT_DISPLAY, IT_ORDER, MSG_ERROR,IT_CANCEL02, IT_CANCEL03, IT_CANCELGR, IT_MARD.
   REFRESH: IT_DISPLAY, IT_ORDER, IT_CANCEL02, IT_CANCEL03, IT_CANCELGR, IT_MARD.


   VDISPLAY = 'C'.

   LOOP AT IT_CANCEL01 WHERE FLAGS = 'X'.
     SELECT MSEG~AUFNR MSEG~MATNR MSEG~BWART MSEG~MENGE AS QUANT MSEG~MEINS MSEG~MBLNR MSEG~LGORT MSEG~WERKS
     INTO CORRESPONDING FIELDS OF TABLE IT_CANCEL02
     FROM MSEG
     JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
     WHERE MSEG~AUFNR = IT_CANCEL01-AUFNR
     AND   MSEG~SMBLN EQ SPACE
     AND   MSEG~BWART IN ('101', '261')
     AND   AUFK~AUART IN ('ZR01', 'ZR02').
   ENDLOOP.

   IT_CANCEL03[] = IT_CANCEL02[].
   SORT IT_CANCEL02 BY MBLNR.
   DELETE ADJACENT DUPLICATES FROM IT_CANCEL02 COMPARING MBLNR.

   LOOP AT IT_CANCEL02.
     SELECT SINGLE MSEG~MBLNR INTO (VMBLNR) " CHECK MATERIAL DOC CANCELLED OR NOT
       FROM MSEG
      WHERE MSEG~SMBLN = IT_CANCEL02-MBLNR.

     IF VMBLNR NE SPACE.
       CLEAR VMBLNR.
       DELETE IT_CANCEL02 WHERE MBLNR = IT_CANCEL02-MBLNR.
     ENDIF.
   ENDLOOP.

*   "Get stock GRN FG Recycle. Add by IT-FANY (28.10.2026)
   DATA : V_DEFICIT TYPE STRING.
   IT_CANCELGR[] = IT_CANCEL02[].
   DELETE IT_CANCELGR WHERE BWART NE '101'.

   IF IT_CANCELGR[] IS NOT INITIAL.
     SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MARD FROM MARD
       FOR ALL ENTRIES IN IT_CANCELGR
        WHERE MARD~MATNR = IT_CANCELGR-MATNR
          AND MARD~WERKS = IT_CANCELGR-WERKS
          AND MARD~LGORT = IT_CANCELGR-LGORT.

          LOOP AT IT_CANCELGR.
              CLEAR : MSG_ERROR, IT_MARD, V_DEFICIT.
              READ TABLE IT_MARD WITH KEY MATNR = IT_CANCELGR-MATNR LGORT = IT_CANCELGR-LGORT WERKS = IT_CANCELGR-WERKS.
              IF SY-SUBRC NE 0.
                  CONCATENATE 'Tidak ada stock' IT_CANCELGR-MATNR 'di SLoc'IT_MARD-LGORT '. Gagal cancel.' INTO MSG_ERROR SEPARATED BY SPACE.
                  MESSAGE MSG_ERROR TYPE 'I'.
                  EXIT.
              ELSEIF IT_CANCELGR-QUANT > IT_MARD-LABST.
                  V_DEFICIT = IT_CANCELGR-QUANT - IT_MARD-LABST.
                  CONCATENATE 'Terdapat kekurangan stock' IT_CANCELGR-MATNR 'sebesar'  V_DEFICIT' Kg di Sloc' IT_MARD-LGORT '. Gagal cancel.' INTO MSG_ERROR SEPARATED BY SPACE.
                  MESSAGE MSG_ERROR TYPE 'I'.
                  EXIT.
              ENDIF.
      ENDLOOP.
   ENDIF.

   IF MSG_ERROR IS NOT INITIAL.
      EXIT.
   ENDIF.

   CLEAR : MSG_ERROR.
   LOOP AT IT_CANCEL01 WHERE FLAGS = 'X'.
     IF IT_CANCEL01-STTXT EQ 'TECO'.
       CONCATENATE 'Please Revoke TECO Order' IT_CANCEL01-AUFNR INTO MSG_ERROR SEPARATED BY SPACE.
       MESSAGE MSG_ERROR TYPE 'S'.
     ELSE.
       IT_ORDER-ZORDER_NUMBER = IT_CANCEL01-AUFNR.
       APPEND IT_ORDER.

       LOOP AT IT_CANCEL02 WHERE AUFNR = IT_CANCEL01-AUFNR.

         CLEAR IT_HEADERRET.
         CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
           EXPORTING
             MATERIALDOCUMENT    = IT_CANCEL02-MBLNR
             MATDOCUMENTYEAR     = SY-DATUM+0(4)
             GOODSMVT_PSTNG_DATE = SY-DATUM
           IMPORTING
             GOODSMVT_HEADRET    = IT_HEADERRET
           TABLES
             RETURN              = IT_RETURN.

         CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
           EXPORTING
             WAIT   = 'X'
           IMPORTING
             RETURN = IT_RETURN.

         IF IT_CANCEL02-BWART = '101'.
           IT_DISPLAY-AUFNR = IT_CANCEL02-AUFNR.
           IT_DISPLAY-MATNR = IT_CANCEL02-MATNR.
           IT_DISPLAY-BWART = '102'.
           IT_DISPLAY-MENGE = IT_CANCEL02-QUANT.
           IT_DISPLAY-MEINS = IT_CANCEL02-MEINS.
           IT_DISPLAY-MBLNR = IT_HEADERRET-MAT_DOC.
           IT_DISPLAY-WEMPF = IT_CANCEL02-MBLNR. " REFERENCE MATDOC
           APPEND IT_DISPLAY.

         ELSEIF IT_CANCEL02-BWART = '261'.
           LOOP AT IT_CANCEL03 WHERE MBLNR = IT_CANCEL02-MBLNR.
             IT_DISPLAY-AUFNR = IT_CANCEL03-AUFNR.
             IT_DISPLAY-MATNR = IT_CANCEL03-MATNR.
             IT_DISPLAY-BWART = '262'.
             IT_DISPLAY-MENGE = IT_CANCEL03-QUANT.
             IT_DISPLAY-MEINS = IT_CANCEL03-MEINS.
             IT_DISPLAY-MBLNR = IT_HEADERRET-MAT_DOC.
             IT_DISPLAY-WEMPF = IT_CANCEL03-MBLNR. " REFERENCE MATDOC
             APPEND IT_DISPLAY.
           ENDLOOP.
         ENDIF.
*         IF IT_CANCEL02-BWART = '101'.

*          perform open_group.
*          perform bdc_dynpro      using 'SAPMM07M' '0460'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RM07M-MBLNR'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '/00'.
*          perform bdc_field       using 'RM07M-MBLNR'
*                                        IT_CANCEL02-MBLNR.
*          perform bdc_dynpro      using 'SAPMM07M' '0321'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'MKPF-BUDAT'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=BU'.
*          perform bdc_transaction using 'MBST'.
*          perform close_group.

*                LOOP AT MESSTAB.
*                   IT_DISPLAY-AUFNR = IT_CANCEL02-AUFNR.
*                   IT_DISPLAY-MATNR = IT_CANCEL02-MATNR.
*                   IT_DISPLAY-BWART = '102'.
*                   IT_DISPLAY-MENGE = IT_CANCEL02-QUANT.
*                   IT_DISPLAY-MEINS = IT_CANCEL02-MEINS.
*                   IT_DISPLAY-MBLNR = MESSTAB-MSGV1.
*                   IT_DISPLAY-WEMPF = IT_CANCEL02-MBLNR. " REFERENCE MATDOC
*                   APPEND IT_DISPLAY.
*                ENDLOOP.


*         ELSEIF IT_CANCEL02-BWART = '261'.

*          perform open_group.
*          perform bdc_dynpro      using 'SAPMM07M' '0460'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RM07M-MBLNR'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '/00'.
*          perform bdc_field       using 'RM07M-MBLNR'
*                                        IT_CANCEL02-MBLNR.
*          perform bdc_dynpro      using 'SAPMM07M' '0421'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RM07M-XSELK(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=BU'.
*          perform bdc_dynpro      using 'SAPLKACB' '0002'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'COBL-AUFNR'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=ENTE'.
*          perform bdc_dynpro      using 'SAPLKACB' '0002'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'COBL-AUFNR'.
*          perform bdc_dynpro      using 'SAPLKACB' '0002'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'COBL-AUFNR'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=ENTE'.
*          perform bdc_transaction using 'MBST'.
*          perform close_group.
*
*               LOOP AT MESSTAB.
*                 LOOP AT IT_CANCEL03 WHERE MBLNR = IT_CANCEL02-MBLNR.
*                   IT_DISPLAY-AUFNR = IT_CANCEL03-AUFNR.
*                   IT_DISPLAY-MATNR = IT_CANCEL03-MATNR.
*                   IT_DISPLAY-BWART = '262'.
*                   IT_DISPLAY-MENGE = IT_CANCEL03-QUANT.
*                   IT_DISPLAY-MEINS = IT_CANCEL03-MEINS.
*                   IT_DISPLAY-MBLNR = MESSTAB-MSGV1.
*                   IT_DISPLAY-WEMPF = IT_CANCEL03-MBLNR. " REFERENCE MATDOC
*                   APPEND IT_DISPLAY.
*                 ENDLOOP.
*                ENDLOOP.

*         ENDIF.

       ENDLOOP.
     ENDIF.
   ENDLOOP.

   IF MSG_ERROR IS INITIAL.
     CALL FUNCTION 'BAPI_PROCORD_COMPLETE_TECH'
       EXPORTING
         SCOPE_COMPL_TECH   = '1'
         WORK_PROCESS_GROUP = 'COWORK_BAPI'
         WORK_PROCESS_MAX   = 99
       TABLES
         ORDERS             = IT_ORDER
         DETAIL_RETURN      = IT_RETURN2.
     CALL FUNCTION 'DEQUEUE_ALL'.

     IF IT_DISPLAY[] IS NOT INITIAL.
       PERFORM INSERT_SQL.
     ENDIF.

     PERFORM DISPLAY.
     PERFORM LOAD_CANCEL.
   ENDIF.

 ENDFORM.                    "CANCEL_POSTING


*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM DISPLAY.

*initialization.
   G_REPID = SY-REPID. "call report id
   Y_PRINT-NO_PRINT_SELINFOS = 'X'.
   Y_PRINT-NO_PRINT_LISTINFOS = 'X'.
   PERFORM LAYOUT_INIT USING GS_LAYOUT. "call ALV layout for report by gs_layout
   PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
   GS_VARIANT-REPORT = G_REPID.
   G_SAVE = 'A'.

*tambahan untuk ALV
   IF VDISPLAY = 'C'.
     PERFORM BUILD_FIELDCATALOG3. " CANCEL POSTING LAYOUT
     CLEAR VDISPLAY .
   ELSE.
     PERFORM BUILD_FIELDCATALOG.
   ENDIF.
   PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].

**call function that construct our ALV Report
** Function Grid ALV

   CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
       I_CALLBACK_PROGRAM = G_REPID
       IS_LAYOUT          = GS_LAYOUT
       IT_FIELDCAT        = GT_FIELDCAT[]
       IS_PRINT           = Y_PRINT
       I_SAVE             = G_SAVE
       IS_VARIANT         = GS_VARIANT
       IT_EVENTS          = GT_EVENTS[]
     TABLES
       T_OUTTAB           = IT_DISPLAY
     EXCEPTIONS
       PROGRAM_ERROR      = 1
       OTHERS             = 2.
   IF SY-SUBRC <> 0.
*  message 'Sorry, Report cannot be generated' type i.
   ENDIF.

   CLEAR: IT_DISPLAY. REFRESH: IT_DISPLAY.

 ENDFORM.                    "DISPLAY

*&---------------------------------------------------------------------*
*&      Form  build_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_FIELDCATALOG.
   DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV,
         N TYPE I.

   REFRESH GT_FIELDCAT.
   N = 0.
   N = N + 1.

   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'AUFNR'.
   "xfieldcat-tabname   = 'IT_DETAILS'.
   XFIELDCAT-SELTEXT_M = 'Order Number'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   XFIELDCAT-FIX_COLUMN = 'X'.
   XFIELDCAT-EMPHASIZE = 'C110'.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'BUDAT'.
   XFIELDCAT-SELTEXT_M = 'Posting Date'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'BLDAT'.
   XFIELDCAT-SELTEXT_M = 'Doc. Date'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'BWART'.
   XFIELDCAT-SELTEXT_M = 'MvT'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'CPUDT'.
   XFIELDCAT-SELTEXT_M = 'Entry Date'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'CPUTM'.
   XFIELDCAT-SELTEXT_M = 'Entry Time'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'USNAM'.
   XFIELDCAT-SELTEXT_M = 'NIK'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'VTERMINAL'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Terminal'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MATNR2'.
   XFIELDCAT-SELTEXT_M = 'Material Number'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.


   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'WERKS'.
   XFIELDCAT-SELTEXT_M = 'Plant'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'LGORT'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Sloc'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MENGE'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Quantity'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MEINS'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'UoM'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'WEMPF'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Resource'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'LINE'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Line'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'FILM'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Film'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MBLNR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Material Doc.'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MJAHR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Year'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MSG_TYPE'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Type'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MSG_DESC'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Message Desc'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*
   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'ICON'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Indicator'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.
*

 ENDFORM. "build_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  build_fieldcatalog3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM BUILD_FIELDCATALOG3.
   DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV,
         N TYPE I.

   REFRESH GT_FIELDCAT.
   N = 0.
   N = N + 1.

   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'AUFNR'.
   "xfieldcat-tabname   = 'IT_DETAILS'.
   XFIELDCAT-SELTEXT_M = 'Order Number'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-OUTPUTLEN = 20.
   XFIELDCAT-FIX_COLUMN = 'X'.
   XFIELDCAT-EMPHASIZE = 'C110'.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MATNR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Material Number'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'BWART'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'MvT'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MENGE'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Quantity'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MEINS'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'UoM'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'MBLNR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Material Doc.'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

   N = N + 1.
   CLEAR XFIELDCAT.
   XFIELDCAT-FIELDNAME = 'WEMPF'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
   XFIELDCAT-COL_POS = N.
   XFIELDCAT-SELTEXT_M = 'Reference MatDoc'.
   XFIELDCAT-OUTPUTLEN = 20.
   APPEND XFIELDCAT TO GT_FIELDCAT.

 ENDFORM. "build_fieldcatalog3


*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
 FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
   RS_LAYOUT-DETAIL_POPUP = 'X'.
   RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
   RS_LAYOUT-ZEBRA             = 'X'.
 ENDFORM.            "Layout_init

*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
 FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
   DATA : LS_EVENT TYPE SLIS_ALV_EVENT.
   CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
     EXPORTING
       I_LIST_TYPE = 0
     IMPORTING
       ET_EVENTS   = RT_EVENTS.

   READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                             INTO LS_EVENT.

   IF SY-SUBRC = 0.
     MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
     APPEND LS_EVENT TO RT_EVENTS.
   ENDIF.
 ENDFORM.              "eventtab_build

*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
 FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
   DATA: LS_LINE TYPE SLIS_LISTHEADER.

   IF ZPLANT IS INITIAL.

     IF IT_ERROR01 IS NOT INITIAL.
       LOOP AT IT_ERROR01.
        ZPLANT = IT_ERROR01-WERKS.
       ENDLOOP.
     ENDIF.

     IF IT_CANCEL01 IS NOT INITIAL.
       LOOP AT IT_CANCEL01.
        ZPLANT = IT_CANCEL01-WERKS.
       ENDLOOP.
     ENDIF.

   ENDIF.

   CLEAR LS_LINE.
   REFRESH LT_TOP_OF_PAGE.
   LS_LINE-TYP = 'H'.
   "---------------------- ADD NEW COMPANY
  IF ZPLANT EQ '1000' OR ZPLANT EQ '2000'.
    LS_LINE-INFO = 'PT.Trias Sentosa, Tbk.'.
  ELSEIF ZPLANT EQ 'TTA2'.
    LS_LINE-INFO = 'PT. Trias Toyobo Astria'.
*  ELSEIF ZPLANT EQ 'TTE2'.
*    LS_LINE-INFO = 'PT. Toyobo Trias Ecosyar'.
  ENDIF.
  "---------------------- END NEW COMPANY
   APPEND LS_LINE TO LT_TOP_OF_PAGE.
   CLEAR LS_LINE.
   LS_LINE-TYP = 'A'.
   LS_LINE-INFO = 'Report Recycle Execution'.
   APPEND LS_LINE TO LT_TOP_OF_PAGE.
 ENDFORM.                    "comment_build

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM TOP_OF_PAGE.
   CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
     EXPORTING
       I_LOGO             = ' '
       IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
 ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUES_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0513   text
*      <--P_D_CHARVAL  text
*----------------------------------------------------------------------*
 FORM F_GET_VALUES_REQUEST  USING    VALUE(P_0513)
                            CHANGING P_D_CHARVAL.

   TYPES: BEGIN OF TYPE_CHAR,
          VALUE_CHAR TYPE ATWRT,
          DESCRIPTION TYPE ATWTB,
     END OF TYPE_CHAR.

*  DATA t_char TYPE STANDARD TABLE OF zcuvtab WITH HEADER LINE.
   DATA ITAB_CHAR TYPE STANDARD TABLE OF TYPE_CHAR WITH HEADER LINE.
   DATA IT_RETVAL TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.
   DATA IT_VALS TYPE TABLE OF BAPICHARACTVALUESDESCR WITH HEADER LINE.
   DATA D_RETVAL TYPE STANDARD TABLE OF BAPIRET2 WITH HEADER LINE.

   CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
     EXPORTING
       CHARACTNAME             = P_0513
*   KEYDATE                   = SY-DATUM
*   LANGUAGE                  =
* IMPORTING
*   CHARACTDETAIL             =
     TABLES
*   CHARACTDESCR              =
*   CHARACTVALUESNUM          =
*   CHARACTVALUESCHAR         =
*   CHARACTVALUESCURR         =
      CHARACTVALUESDESCR        = IT_VALS
*   CHARACTREFERENCES         =
*   CHARACTRESTRICTIONS       =
       RETURN                    = D_RETVAL.

   LOOP AT IT_VALS.
     MOVE-CORRESPONDING IT_VALS TO ITAB_CHAR.
     APPEND ITAB_CHAR.
   ENDLOOP.

   SORT ITAB_CHAR.
*   DELETE ADJACENT DUPLICATES FROM itab_char COMPARING atwrt.

   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
       RETFIELD        = 'VALUE_CHAR'
       DYNPPROG        = SY-REPID
       DYNPNR          = SY-DYNNR
       DYNPROFIELD     = 'VALUE_CHAR'
       VALUE_ORG       = 'S'
     TABLES
       VALUE_TAB       = ITAB_CHAR
       RETURN_TAB      = IT_RETVAL
     EXCEPTIONS
       PARAMETER_ERROR = 1
       NO_VALUES_FOUND = 2
       OTHERS          = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSEIF IT_RETVAL[] IS NOT INITIAL.
     READ TABLE IT_RETVAL INDEX 1.
     P_D_CHARVAL = IT_RETVAL-FIELDVAL.
   ENDIF.


 ENDFORM.                    " F_GET_VALUES_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_GET_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_CHARVAL  text
*----------------------------------------------------------------------*
 FORM F_GET_LGORT CHANGING P_D_CHARVAL.

   DATA: BEGIN OF IT_DETAIL OCCURS 0,
         WERKS      TYPE WERKS_D,
         ARBPL      TYPE ARBPL,
         LGORT_RCYL TYPE LGORT_D,
   END OF IT_DETAIL.

   SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~LGORT_RCYL
          INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL
          FROM  ZTMAP_SLOCREC
          WHERE ZTMAP_SLOCREC~WERKS = ZPLANT
          AND   ZTMAP_SLOCREC~ARBPL = ZRESOURCE.

   DATA IT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.


   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
       RETFIELD        = 'LGORT'
       DYNPPROG        = SY-REPID
       DYNPNR          = SY-DYNNR
       DYNPROFIELD     = 'LGORT'
       VALUE_ORG       = 'S'
     TABLES
       VALUE_TAB       = IT_DETAIL
       RETURN_TAB      = IT_RETURN
     EXCEPTIONS
       PARAMETER_ERROR = 1
       NO_VALUES_FOUND = 2
       OTHERS          = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSEIF IT_RETURN[] IS NOT INITIAL.
     READ TABLE IT_RETURN INDEX 1.
     P_D_CHARVAL = IT_RETURN-FIELDVAL.
   ENDIF.

 ENDFORM.                    "F_GET_LGORT

*&---------------------------------------------------------------------*
*&      Form  F_GET_LGORT_GI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_CHARVAL  text
*----------------------------------------------------------------------*
 FORM F_GET_LGORT_GI CHANGING P_D_CHARVAL.

   DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
*       zline      type ZTMAP_SLOCRR-zline,
*       zdesc      type ZTMAP_SLOCRR-zdesc,
        WERKS      TYPE WERKS_D,
        ARBPL      TYPE ARBPL,
        ZRRLGORT   TYPE LGORT_D,
   END OF IT_DETAIL2.
   DATA IT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.

   SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~ZRRLGORT
     INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
     FROM  ZTMAP_SLOCREC
     WHERE ZTMAP_SLOCREC~WERKS = ZPLANT
     AND   ZTMAP_SLOCREC~ARBPL = ZRESOURCE.

   DELETE ADJACENT DUPLICATES FROM IT_DETAIL2 COMPARING ALL FIELDS.

   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
     EXPORTING
       RETFIELD        = 'zrrlgort'
       DYNPPROG        = SY-REPID
       DYNPNR          = SY-DYNNR
       DYNPROFIELD     = 'zrrlgort'
       VALUE_ORG       = 'S'
     TABLES
       VALUE_TAB       = IT_DETAIL2
       RETURN_TAB      = IT_RETURN
     EXCEPTIONS
       PARAMETER_ERROR = 1
       NO_VALUES_FOUND = 2
       OTHERS          = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSEIF IT_RETURN[] IS NOT INITIAL.
     READ TABLE IT_RETURN INDEX 1.
     P_D_CHARVAL = IT_RETURN-FIELDVAL.
   ENDIF.

 ENDFORM.                    "F_GET_LGORT_GI


*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL
*&---------------------------------------------------------------------*
*       insert into SQL for Admin Entries NON SAP Program
*----------------------------------------------------------------------*
 FORM INSERT_SQL.
   RANGES:  R_AUFNR FOR AUFK-AUFNR,
            R_MTART FOR MARA-MTART,
            R_MATKL FOR MARA-MATKL.
   CLEAR: R_AUFNR, R_MTART, R_MATKL.
   REFRESH: R_AUFNR, R_MTART, R_MATKL.

   LOOP AT IT_DISPLAY WHERE AUFNR IS NOT INITIAL.
     R_AUFNR-SIGN = 'I'.
     R_AUFNR-OPTION = 'EQ'.
     R_AUFNR-LOW = IT_DISPLAY-AUFNR.
     APPEND R_AUFNR.
     CLEAR R_AUFNR.
   ENDLOOP.

   R_MTART-SIGN = 'I'.
   R_MTART-OPTION = 'EQ'.
   R_MTART-LOW = 'ZFGS'.
   APPEND R_MTART.
   CLEAR R_MTART.

   R_MATKL-SIGN = 'I'.
   R_MATKL-OPTION = 'EQ'.
   R_MATKL-LOW = 'B00503'.
   APPEND R_MATKL.
   CLEAR R_MATKL.

   R_MATKL-SIGN = 'I'.
   R_MATKL-OPTION = 'EQ'.
   R_MATKL-LOW = 'B00508'.
   APPEND R_MATKL.
   CLEAR R_MATKL.

   SUBMIT ZTPPR_REC_EXEC_REPORT WITH ZAUFNR IN R_AUFNR AND RETURN.

   SUBMIT ZTPPR_LOG_ERROR WITH S_AUFNR IN R_AUFNR AND RETURN.

   SUBMIT ZTMMR_STOCK_RM WITH S_MTART IN R_MTART WITH S_MATKL IN R_MATKL AND RETURN.

*   SUBMIT ZTPPR_PRO_MOVEMENT WITH S_AUFNR IN R_AUFNR AND RETURN.

   CLEAR: R_AUFNR, R_MTART, R_MATKL.
   REFRESH: R_AUFNR, R_MTART, R_MATKL.

 ENDFORM.                    "TO_PROGRAM