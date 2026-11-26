*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_SUB9001
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

TYPES:
  BEGIN OF T_RENUMBER.
        INCLUDE STRUCTURE ZPACK_PCL.
TYPES: OLD_HUSEQ TYPE ZPOSNR_PL,
END OF T_RENUMBER,
TT_RENUMBER TYPE T_RENUMBER OCCURS 0.

DATA T_BDCDATA TYPE BDCDATA OCCURS 0 WITH HEADER LINE.

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
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO           = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
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
*&      Form  f_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_SAVE.
  DATA LD_ERRNO LIKE SY-SUBRC.
  DATA LD_PINNR TYPE ZPINNR.

  IF ZPACK_PCH-PINNR NE '000000000000' AND ZPACK_PCH-PINST = 'A'.
    PERFORM F_UNLOCK.
  ENDIF.

  IF D_DISPMODE = C_DISP_NEW.
    PERFORM F_GETNEWID CHANGING LD_PINNR.

    ZPACK_PCH-CRNAM = SY-UNAME.
    ZPACK_PCH-CRDAT = SY-DATUM.
    ZPACK_PCH-CRTIM = SY-UZEIT.
    ZPACK_PCH-PINST = C_PINST_INACTIVE.
    ZPACK_PCH-LOEVR = C_NO.
    ZPACK_PCH-PINNR = LD_PINNR.

    PERFORM F_PROCESS_DETAILS USING ZPACK_PCH-PINNR CHANGING LD_ERRNO.

    INSERT ZPACK_PCH FROM ZPACK_PCH.
    INSERT ZPACK_PC FROM TABLE ITAB_PINS.

*    PERFORM f_lock.
    PERFORM F_UNLOCK_SONUM.
    D_DISPMODE = C_DISP_CHANGE.
    MESSAGE S398(00) WITH 'Packing instruction' LD_PINNR 'created'.

  ELSE.
    PERFORM F_PROCESS_DETAILS USING ZPACK_PCH-PINNR CHANGING LD_ERRNO.

    IF LD_ERRNO EQ 0.
      IF ZPACK_PCH-PINST NE 'A'.
        ZPACK_PCH-PINST = C_PINST_INACTIVE.
      ENDIF.

      ZPACK_PCH-AENAM = SY-UNAME.
      ZPACK_PCH-AEDAT = SY-DATUM.
      ZPACK_PCH-AETIM = SY-UZEIT.

      UPDATE ZPACK_PCH FROM ZPACK_PCH.
      DELETE FROM ZPACK_PC WHERE PINNR = ZPACK_PCH-PINNR.
      INSERT ZPACK_PC FROM TABLE ITAB_PINS.

      MESSAGE S398(00) WITH 'Packing instruction' ZPACK_PCH-PINNR
      'saved'.

    ENDIF.

  ENDIF.

ENDFORM.                    "f_save


*&---------------------------------------------------------------------*
*&      Form  f_activate
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ACTIVATE USING FUS_PINNR CHANGING FCN_ERRNO.
  DATA LD_HUSEQ TYPE ZPOSNR_PL.
  DATA LD_SEQ_PALLET TYPE N LENGTH 4.
  DATA LD_SEQ_BOX TYPE N LENGTH 2.
  DATA ITAB_PCL TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA WA_PCL TYPE ZPACK_PCL.
  DATA WA_PINS TYPE ZPACK_PC.

  PERFORM F_CHECK_USAGE USING FUS_PINNR CHANGING FCN_ERRNO.
*  BREAK-POINT.

  IF FCN_ERRNO NE 0.
    ROLLBACK WORK.
    RETURN.
  ENDIF.

  PERFORM F_LOCK CHANGING FCN_ERRNO.
  IF FCN_ERRNO NE 0.
    ROLLBACK WORK.
    RETURN.
  ENDIF.

  LD_SEQ_PALLET = 0.
  LD_SEQ_BOX = 0.

  LOOP AT ITAB_PINS INTO WA_PINS
    WHERE INILVL EQ C_LEVEL_PALLET.

    DO WA_PINS-ZMENG TIMES.
      ADD 1 TO LD_SEQ_PALLET.
      LD_SEQ_BOX = 0.

      PERFORM F_ADD_PCL
        TABLES ITAB_PCL
        USING WA_PINS LD_SEQ_PALLET LD_SEQ_BOX.

      PERFORM F_ADD_CHILDREN
        TABLES ITAB_PCL
        USING WA_PINS LD_SEQ_PALLET LD_SEQ_BOX.
    ENDDO.

  ENDLOOP.


  PERFORM F_UPDATE_PACKINGLIST TABLES ITAB_PCL.
  ZPACK_PCH-PINST = C_PINST_ACTIVE.
  UPDATE ZPACK_PCH FROM ZPACK_PCH.

  MESSAGE S398(00) WITH 'Activated.'.
ENDFORM.                    " f_activate


*&---------------------------------------------------------------------*
*&      Form  f_getnewid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_F_PINNR  text
*----------------------------------------------------------------------*
FORM F_GETNEWID  CHANGING FC_PINNR.
  DATA D_PINNR LIKE ZPACK_PCR.
  DATA S_FOUND TYPE FLAG VALUE SPACE.

  DO 3 TIMES.
    CALL FUNCTION 'ENQUEUE_EZPACK_PCR'
      EXPORTING
        MODE_ZPACK_PCR = 'X'
        _WAIT          = 'X'
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    IF SY-SUBRC EQ 0.
      S_FOUND = C_YES.
      EXIT.
    ELSE.
      WAIT UP TO 1 SECONDS.
    ENDIF.
  ENDDO.

  IF SY-SUBRC <> 0 OR S_FOUND IS INITIAL.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
    SELECT SINGLE *
      INTO D_PINNR
      FROM ZPACK_PCR .

    IF SY-SUBRC NE 0.
      FC_PINNR = 1.
      D_PINNR-PINNR = FC_PINNR.
      INSERT ZPACK_PCR FROM D_PINNR.

    ELSE.
      ADD 1 TO D_PINNR-PINNR.
      FC_PINNR = D_PINNR-PINNR.
      MODIFY ZPACK_PCR FROM D_PINNR.

    ENDIF.

    CALL FUNCTION 'DEQUEUE_EZPACK_PCR'.

  ENDIF.

ENDFORM.                    " f_getnewid


*&---------------------------------------------------------------------*
*&      Form  f_okcode_9001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_OKCODE_9001 .
  DATA LD_ERRNO TYPE I.
  DATA ITAB_PCL TYPE TT_RENUMBER WITH HEADER LINE.

  CASE SY-UCOMM.
    WHEN 'SAVE'.
      IF SY-TCODE EQ 'ZHU4FS'. "ADD NEW COMPANY
        IF ZPACK_PCH-WERKS EQ '1000' OR ZPACK_PCH-WERKS EQ '2000'.
        ELSE.
          MESSAGE 'HARUS PLANT 1000/2000' TYPE 'I'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.
      PERFORM F_CHECK_CRITERIA CHANGING ERRNO.
      IF ERRNO NE 0.
        RETURN.
      ENDIF.
      PERFORM F_SAVE.

    WHEN 'BACK'.
      PERFORM F_UNLOCK.
      PERFORM F_UNLOCK_SONUM.
      CLEAR ZPACK_PCH.
      SET SCREEN 9000.
      LEAVE SCREEN.

    WHEN 'EXIT' OR 'CANCEL'.
      PERFORM F_UNLOCK.
      PERFORM F_UNLOCK_SONUM.
      LEAVE PROGRAM.

    WHEN 'ACTIVATE'.
      PERFORM F_ACTIVATE USING ZPACK_PCH-PINNR CHANGING LD_ERRNO.

    WHEN 'CHANGE'.
      PERFORM F_SWITCH_DISPMODE.

    WHEN 'TRIM'.
      PERFORM F_LOCK CHANGING LD_ERRNO.
      CHECK LD_ERRNO EQ 0.
      PERFORM F_TRIM_PINS USING ZPACK_PCH-PINNR.
      PERFORM F_RENUMBER TABLES ITAB_PCL.
      LOOP AT ITAB_PCL.
        UPDATE ZPACK_PCL SET HUSEQ = ITAB_PCL-HUSEQ HUSEQ_P = ITAB_PCL-HUSEQ_P
          WHERE PINNR = ZPACK_PCH-PINNR AND HUSEQ = ITAB_PCL-OLD_HUSEQ.
      ENDLOOP.
      PERFORM F_UNLOCK.
      COMMIT WORK AND WAIT.
      PERFORM F_LOAD_DOC CHANGING LD_ERRNO.

    WHEN 'ADD' OR 'CTL_TAB_PINS'.
      PERFORM F_ADD_INSTRUCTION.

    WHEN OTHERS.
      PERFORM F_PROCESS_DETAILS USING ZPACK_PCH-PINNR CHANGING LD_ERRNO.

  ENDCASE.

  CLEAR SY-UCOMM.
ENDFORM.                    " f_okcode_9001


*&---------------------------------------------------------------------*
*&      Form  f_unlock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UNLOCK .
  DATA S_LOOBJ  TYPE ZTLOCK-LOOBJ.
  DATA S_HUSEQ  TYPE ZPOSNR_PL.
  DATA ITAB_PCL TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA N_INDEX  TYPE I.

  CHECK ZPACK_PCH-PINNR IS NOT INITIAL.

  CALL FUNCTION 'DEQUEUE_EZPACK_PCH'
    EXPORTING
      MODE_ZPACK_PCH = 'X'
      MODE_ZPACK_PC  = 'X'
      MANDT          = SY-MANDT
      PINNR          = ZPACK_PCH-PINNR.

  SELECT HUSEQ INTO TABLE ITAB_PCL
    FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR
      AND HUSEQ_P = '000000'.

  LOOP AT ITAB_PCL.
    N_INDEX = SY-TABIX.
    CONCATENATE 'PCL' ITAB_PCL-PINNR ITAB_PCL-HUSEQ INTO S_LOOBJ.
    CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
      EXPORTING
        LOOBJ = S_LOOBJ.

    CLEAR ITAB_PCL-COMPUTER_NAME.
    MODIFY ITAB_PCL INDEX N_INDEX.
  ENDLOOP.

  UPDATE ZPACK_PCL FROM TABLE ITAB_PCL.

  DATA:
  LD_SUBRC(2),
  LD_DESCR TYPE TEXT255,
  LT_LOG TYPE TABLE OF ZPACK_PCL_LOG WITH HEADER LINE.

  MOVE SY-SUBRC TO LD_SUBRC.
  REFRESH LT_LOG.

  LOOP AT ITAB_PCL.
    MOVE-CORRESPONDING ITAB_PCL TO LT_LOG.
    CONCATENATE '(' LD_SUBRC ') F_UNLOCK, VENUM=' ITAB_PCL-VENUM ', HUSTAT=' ITAB_PCL-HUSTAT INTO LT_LOG-DESCR.
    CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_PCL-PRSTAT INTO LT_LOG-DESCR.
    APPEND LT_LOG.
  ENDLOOP.


  IF D_ISFREESTOCK = C_NO.
    PERFORM F_UNLOCK_SONUM.
  ENDIF.

ENDFORM.                    " f_unlock


*&---------------------------------------------------------------------*
*&      Form  f_unlock_sonum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_UNLOCK_SONUM.
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.

  CONCATENATE 'SON' ZPACK_PCH-VBELN ZPACK_PCH-POSNR INTO S_LOOBJ.
  CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
    EXPORTING
      LOOBJ = S_LOOBJ.

ENDFORM.                    "f_unlock_sonum

*&---------------------------------------------------------------------*
*&      Form  f_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOCK CHANGING FCN_ERRNO .
  FCN_ERRNO = 1.

  CHECK ZPACK_PCH-PINNR IS NOT INITIAL.

  CALL FUNCTION 'ENQUEUE_EZPACK_PCH'
    EXPORTING
      MODE_ZPACK_PCH = 'X'
      MODE_ZPACK_PC  = 'X'
      MANDT          = SY-MANDT
      PINNR          = ZPACK_PCH-PINNR
      _WAIT          = 'X'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  FCN_ERRNO = SY-SUBRC.

  IF FCN_ERRNO <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ELSE.
*    DATA fcn_errno TYPE i.
    PERFORM F_LOCK_LIST CHANGING FCN_ERRNO.
    IF FCN_ERRNO NE 0.
      PERFORM F_UNLOCK.

*    ELSEIF d_isfreestock = c_no.
*      PERFORM f_lock_sonum CHANGING fcn_errno.
*      IF fcn_errno NE 0.
*        PERFORM f_unlock.
*      ENDIF.
*
    ENDIF.
  ENDIF.

ENDFORM.                    " f_lock


*&---------------------------------------------------------------------*
*&      Form  f_dispmode_9001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DISPMODE_9001 .
  FIELD-SYMBOLS <STATE> TYPE ANY.

  IF ( D_ISFREESTOCK = C_NO ).
    ASSIGN SCREEN-GROUP1 TO <STATE>.
  ELSE.
    ASSIGN SCREEN-GROUP2 TO <STATE>.
  ENDIF.

  IF D_DISPMODE = C_DISP_DISPLAY.
    LOOP AT SCREEN.
      IF <STATE> = 'HID'.
        SCREEN-INVISIBLE = '1'.
      ELSE.
        SCREEN-INVISIBLE = '0'.
      ENDIF.

      IF SCREEN-NAME(12) = 'CTLTAB_PINS_'.
        SCREEN-INPUT = '1'.
      ELSE.
        SCREEN-INPUT = '0'.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ELSE.
    LOOP AT SCREEN.
      IF D_ISFREESTOCK = C_YES.
        IF   SCREEN-NAME = 'ZPACK_PCH-WERKS'
          OR SCREEN-NAME = 'ZPACK_PCH-LGORT'.
*          OR SCREEN-NAME = 'ZPACK_PCH-ZZWIDTH'.
          SCREEN-REQUIRED = 1.
        ENDIF.

      ELSE.
        IF   SCREEN-NAME = 'ZPACK_PCH-WERKS'
          OR SCREEN-NAME = 'ZPACK_PCH-LGORT'.
*          OR SCREEN-NAME = 'ZPACK_PCH-ZZWIDTH'.
          SCREEN-REQUIRED = 0.
        ENDIF.

      ENDIF.

      CASE <STATE>.
        WHEN SPACE.
          SCREEN-INPUT = '1'.
          SCREEN-INVISIBLE = '0'.
        WHEN 'DIS'.
          SCREEN-INPUT = '0'.
          SCREEN-INVISIBLE = '0'.
        WHEN 'HID'.
          SCREEN-INPUT = '0'.
          SCREEN-INVISIBLE = '1'.
      ENDCASE.

      IF D_DISPMODE = C_DISP_CHANGE
        AND ZPACK_PCH-PINST NE C_PINST_INACTIVE
        AND SCREEN-INVISIBLE = 0.

        IF SCREEN-NAME = 'ZPACK_PCH-DESCR'
          OR SCREEN-NAME = 'ZPACK_PCH-MATNR'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCRITERIABF'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCRITERIA1'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCRITERIA2'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCRITERIAR'
*          OR SCREEN-NAME = 'ZPACK_PCH-ZZWIDTH'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCORE3'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZCORE6'
          OR SCREEN-NAME = 'ZPACK_PCH-ZZSHEET'
          OR SCREEN-NAME = 'ZPACK_PCH-WERKS'
          OR SCREEN-NAME = 'ZPACK_PCH-LGORT'
          .

          SCREEN-INPUT = 0.
        ENDIF.
      ENDIF.


      IF   SCREEN-NAME = 'ZPACK_PCH-ZZCRITERIAR' AND D_ISFREESTOCK = 'X'.
        SCREEN-INPUT = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " f_dispmode_9001


*&---------------------------------------------------------------------*
*&      Form  f_process_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_PINNR  text
*----------------------------------------------------------------------*
FORM F_PROCESS_DETAILS  USING FU_PINNR CHANGING FC_ERRNO.
  CLEAR FC_ERRNO.

  PERFORM F_PROCESS_DETAIL_LEVEL USING FU_PINNR.
  PERFORM F_CONSISTENCY_CHECK CHANGING FC_ERRNO.

ENDFORM.                    " f_process_details


*&---------------------------------------------------------------------*
*&      Form  f_set_childlevel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PINS_ZINS01  text
*      -->P_ITAB_PINS_ZINS02  text
*      -->P_ITAB_PINS_ZINS03  text
*      <--P_F_COUNT  text
*----------------------------------------------------------------------*
FORM F_SET_CHILDLEVEL  USING FU_PINNR FU_ZINS01.
  DATA D_INDEX LIKE SY-TABIX.
  DATA D_PALLET LIKE ITAB_PINS-ZINS01.
  DATA D_CHILD  LIKE ITAB_PINS-ZINS02.
  DATA WA_CHILD LIKE ITAB_PINS.

  D_PALLET = FU_ZINS01.

* loop on all children of this pallet
  LOOP AT ITAB_PINS
    WHERE ZINS01 = D_PALLET
      AND ZINS02 IS NOT INITIAL
      AND ZINS03 IS INITIAL.

    D_INDEX = SY-TABIX.
    D_CHILD = ITAB_PINS-ZINS02.
    WA_CHILD = ITAB_PINS.

*    have any grand children?
    LOOP AT ITAB_PINS
      WHERE ZINS01 = D_PALLET
        AND ZINS02 = D_CHILD
        AND ZINS03 IS NOT INITIAL.

      ITAB_PINS-INILVL = C_LEVEL_ROLL.
      ITAB_PINS-PINNR = FU_PINNR.
      IF ZPACK_PCH-ZZSHEET = C_YES.
        ITAB_PINS-MEINS = 'PAK'.
      ELSE.
        ITAB_PINS-MEINS = 'ROL'.
      ENDIF.
      MODIFY ITAB_PINS INDEX SY-TABIX.

    ENDLOOP.

*    there are grand children --> boxed pallet.
    IF SY-SUBRC EQ 0.
      ITAB_PINS = WA_CHILD.
      ITAB_PINS-PINNR = FU_PINNR.
      ITAB_PINS-INILVL = C_LEVEL_BOX.
      ITAB_PINS-MEINS = 'BOX'.
      MODIFY ITAB_PINS INDEX D_INDEX.

*    there are NO grand children --> suspended pallet.
    ELSE. "-- suspended pallet
      ITAB_PINS = WA_CHILD.
      ITAB_PINS-PINNR = FU_PINNR.
      ITAB_PINS-INILVL = C_LEVEL_ROLL.
      IF ZPACK_PCH-ZZSHEET = C_YES.
        ITAB_PINS-MEINS = 'PAK'.
      ELSE.
        ITAB_PINS-MEINS = 'ROL'.
      ENDIF.
      MODIFY ITAB_PINS INDEX D_INDEX.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " f_set_childlevel


*&---------------------------------------------------------------------*
*&      Form  f_switch_dispmode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SWITCH_DISPMODE .
  IF D_DISPMODE = C_DISP_DISPLAY.
    IF ZPACK_PCH-LOEVR IS INITIAL
      OR ZPACK_PCH-PINST = C_PINST_INACTIVE
      OR ZPACK_PCH-PINST = C_PINST_ACTIVE.

      D_DISPMODE = C_DISP_CHANGE.

    ENDIF.

  ELSE.
    D_DISPMODE = C_DISP_DISPLAY.

  ENDIF.

ENDFORM.                    " f_switch_dispmode


*&---------------------------------------------------------------------*
*&      Form  f_status_9001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_STATUS_9001 .
  DATA ITAB_DISABLE TYPE TABLE OF SY-UCOMM.

  CLEAR ITAB_DISABLE.
  REFRESH ITAB_DISABLE.

  IF ZPACK_PCH-LOEVR IS NOT INITIAL.
    APPEND 'SAVE'     TO ITAB_DISABLE.
    APPEND 'CHANGE'   TO ITAB_DISABLE.
    APPEND 'ACTIVATE' TO ITAB_DISABLE.

  ELSE.
    CASE D_DISPMODE .
      WHEN C_DISP_NEW.
        APPEND 'CHANGE'   TO ITAB_DISABLE.
        APPEND 'ACTIVATE' TO ITAB_DISABLE.
        APPEND 'TRIM'     TO ITAB_DISABLE.
        APPEND 'ADD'      TO ITAB_DISABLE.

      WHEN C_DISP_DISPLAY.
        APPEND 'SAVE'     TO ITAB_DISABLE.
        APPEND 'TRIM'     TO ITAB_DISABLE.
        APPEND 'ADD'      TO ITAB_DISABLE.

        CASE ZPACK_PCH-PINST.
          WHEN C_PINST_ACTIVE.
            APPEND 'ACTIVATE' TO ITAB_DISABLE.

          WHEN C_PINST_INPROGRESS OR C_PINST_COMPLETED.
            APPEND 'ACTIVATE' TO ITAB_DISABLE.

          WHEN OTHERS.
            IF ITAB_PINS[] IS INITIAL.
              APPEND 'ACTIVATE' TO ITAB_DISABLE.
            ENDIF.

        ENDCASE.

      WHEN C_DISP_CHANGE.
        CASE ZPACK_PCH-PINST.
          WHEN C_PINST_INACTIVE.
            IF ITAB_PINS[] IS INITIAL.
              APPEND 'TRIM' TO ITAB_DISABLE.
              APPEND 'ACTIVATE' TO ITAB_DISABLE.
            ENDIF.

          WHEN C_PINST_COMPLETED.
            APPEND 'ACTIVATE' TO ITAB_DISABLE.
            APPEND 'TRIM' TO ITAB_DISABLE.
            APPEND 'SAVE'     TO ITAB_DISABLE.

          WHEN C_PINST_ACTIVE.
            APPEND 'ACTIVATE' TO ITAB_DISABLE.

          WHEN OTHERS.
            APPEND 'ACTIVATE' TO ITAB_DISABLE.
            APPEND 'SAVE'     TO ITAB_DISABLE.

        ENDCASE.
    ENDCASE.


  ENDIF.

  IF ZPACK_PCH-WERKS IS NOT INITIAL.
    IF ZPACK_PCH-WERKS EQ '1000' OR ZPACK_PCH-WERKS EQ '2000'.
    ELSE.
      MESSAGE S001(00) WITH 'Packing instruction not in TRIAS plant'. "NEW COMPANY
      SET SCREEN 9000.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

*  APPEND 'TRIM' to itab_disable.
  SET PF-STATUS '9001' EXCLUDING ITAB_DISABLE.



  IF SY-TCODE = 'ZHU4FS'.
    SET TITLEBAR '9000A'.
  ELSE.
    SET TITLEBAR '9000'.
  ENDIF.

ENDFORM.                    " f_status_9001

*&---------------------------------------------------------------------*
*&      Form  f_add_pcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PCL  text
*      -->P_ITAB_PINS  text
*      -->P_LD_SEQ_PALLET  text
*      -->P_LD_SEQ_BOX  text
*----------------------------------------------------------------------*
FORM F_ADD_PCL  TABLES   FT_PCL STRUCTURE ZPACK_PCL
                USING    FU_PINS STRUCTURE ZPACK_PC
                         FU_SEQ_PALLET
                         FU_SEQ_BOX.

  DATA WA_PCL TYPE ZPACK_PCL.
  DATA LD_HUSEQ LIKE WA_PCL-HUSEQ.


  WA_PCL-PINNR = FU_PINS-PINNR.
  CONCATENATE FU_SEQ_PALLET FU_SEQ_BOX INTO WA_PCL-HUSEQ.

  IF FU_SEQ_BOX = 0.
    WA_PCL-HUSEQ_P = '000000'.

  ELSE.
    CONCATENATE FU_SEQ_PALLET '00' INTO WA_PCL-HUSEQ_P.
  ENDIF.

  WA_PCL-ZINS01 = FU_PINS-ZINS01.
  WA_PCL-ZINS02 = FU_PINS-ZINS02.
  WA_PCL-HUSTAT =   C_HUSTAT_OPEN.
  CLEAR WA_PCL-VENUM.
  CLEAR WA_PCL-PACKED.
  WA_PCL-MEINS  = FU_PINS-MEINS.
  CLEAR WA_PCL-PACKING_STATION.
  WA_PCL-AENAM  = SY-UNAME.
  WA_PCL-AEDAT  = SY-DATUM.
  WA_PCL-AETIM  = SY-UZEIT.

  APPEND WA_PCL TO FT_PCL.
ENDFORM.                    " f_add_pcl


*&---------------------------------------------------------------------*
*&      Form  f_add_children
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PCL  text
*      -->P_ITAB_PINS  text
*      -->P_LD_SEQ_PALLET  text
*      -->P_LD_SEQ_BOX  text
*----------------------------------------------------------------------*
FORM F_ADD_CHILDREN  TABLES FT_PCL STRUCTURE ZPACK_PCL
                  USING    FU_PINS STRUCTURE ZPACK_PC
                           FU_SEQ_PALLET
                           FU_SEQ_BOX.

  LOOP AT ITAB_PINS
    WHERE ZINS01 = FU_PINS-ZINS01
      AND INILVL = C_LEVEL_BOX.

    DO ITAB_PINS-ZMENG TIMES.
      ADD 1 TO FU_SEQ_BOX.

      PERFORM F_ADD_PCL
        TABLES FT_PCL
        USING ITAB_PINS FU_SEQ_PALLET FU_SEQ_BOX.

    ENDDO.

  ENDLOOP.

ENDFORM.                    " f_add_children


*&---------------------------------------------------------------------*
*&      Form  f_update_packinglist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PCL  text
*----------------------------------------------------------------------*
FORM F_UPDATE_PACKINGLIST
  TABLES FT_PCL STRUCTURE ZPACK_PCL.

*   DATA itab_pcl TYPE TABLE OF zpack_pcl WITH HEADER LINE.
*
*   SELECT * INTO TABLE itab_pcl FROM zpack_pcl
*     WHERE pinnr = zpack_pch-pinnr
*       AND venum = space.
*
*
*   IF sy-subrc EQ 0. "-- already used
**
*   ENDIF.
  CHECK ZPACK_PCH-PINNR IS NOT INITIAL.

  DELETE FROM ZPACK_PCL WHERE PINNR = ZPACK_PCH-PINNR.


  DATA:
  LD_SUBRC(2),
  LD_PACKED(18),
  LD_DESCR TYPE TEXT255.

  MOVE SY-SUBRC TO LD_SUBRC.
  CONCATENATE '(' LD_SUBRC ') F_UPDATE_PACKING_LIST, DELETE MULTIPLE RECORDS' INTO LD_DESCR.



  INSERT ZPACK_PCL FROM TABLE FT_PCL.
ENDFORM.                    " f_update_packinglist


*&---------------------------------------------------------------------*
*&      Form  f_save_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PROCESS_DETAIL_LEVEL USING FU_PINNR.
  DATA WA_PALLET LIKE ITAB_PINS.
  DATA D_INDEX LIKE SY-TABIX.

  LOOP AT ITAB_PINS WHERE ZINS02 IS INITIAL.
    IF ITAB_PINS-MATNR IS INITIAL.
      DELETE ITAB_PINS.
      CONTINUE.
    ENDIF.

    WA_PALLET = ITAB_PINS.
    D_INDEX = SY-TABIX.

    PERFORM F_SET_CHILDLEVEL USING FU_PINNR ITAB_PINS-ZINS01.

    ITAB_PINS = WA_PALLET.
    ITAB_PINS-PINNR = FU_PINNR.
    ITAB_PINS-INILVL = C_LEVEL_PALLET.
    ITAB_PINS-MEINS = 'UNT'.
    MODIFY ITAB_PINS INDEX D_INDEX.
  ENDLOOP.
ENDFORM.                    " f_save_details


*&---------------------------------------------------------------------*
*&      Form  f_save_canceled
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SAVE_CANCELED .
  MESSAGE S398(00)
   WITH 'Cant modify. Packing instruction has already' 'been used.'.
ENDFORM.                    " f_save_canceled


*&---------------------------------------------------------------------*
*&      Form  f_consistency_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FC_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CONSISTENCY_CHECK  CHANGING FC_ERRNO.
  FC_ERRNO = 0.

  REFRESH ITAB_MATERIAL.
  SELECT DISTINCT MARA~MATNR MARA~VHART MARA~MTART MEINS MAKTX MAGRV
    INTO TABLE ITAB_MATERIAL
    FROM MARA INNER JOIN MAKT ON MARA~MATNR = MAKT~MATNR
    FOR ALL ENTRIES IN ITAB_PINS
    WHERE MARA~MATNR = ITAB_PINS-MATNR
      AND SPRAS = SY-LANGU.

  DATA N_INDEX TYPE I.

  LOOP AT ITAB_PINS.
    N_INDEX = SY-TABIX.

    CASE ITAB_PINS-INILVL. "-- unit of measure
      WHEN C_LEVEL_PALLET.
        PERFORM F_CHECK_PALLET TABLES ITAB_MATERIAL USING ITAB_PINS
        CHANGING FC_ERRNO.

      WHEN C_LEVEL_BOX.
        PERFORM F_CHECK_BOX TABLES ITAB_MATERIAL USING ITAB_PINS
        CHANGING FC_ERRNO.

      WHEN C_LEVEL_ROLL.
        PERFORM F_CHECK_ROLL TABLES ITAB_MATERIAL USING ITAB_PINS
        CHANGING FC_ERRNO.

    ENDCASE.

    IF FC_ERRNO NE 0.
      EXIT.
    ENDIF.

    MODIFY ITAB_PINS INDEX N_INDEX.
  ENDLOOP.

ENDFORM.                    " f_consistency_check


*&---------------------------------------------------------------------*
*&      Form  f_check_pallet
*&---------------------------------------------------------------------*
*       Check pallet consistency
*----------------------------------------------------------------------*
*      -->P_ITAB_PINS  text
*      <--P_FC_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_PALLET  TABLES     FT_MATERIAL STRUCTURE ITAB_MATERIAL
                       USING    FUWA_PINS STRUCTURE ITAB_PINS
                       CHANGING FCN_ERRNO.
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.

  READ TABLE FT_MATERIAL WITH KEY MATNR = FUWA_PINS-MATNR.
  FCN_ERRNO = SY-SUBRC.

  IF FCN_ERRNO EQ 0.
    IF FT_MATERIAL-MAGRV NE 'PLT' OR
       FT_MATERIAL-MTART NE 'ZPCK'.
      FCN_ERRNO = 4.
    ENDIF.
  ENDIF.

  IF FCN_ERRNO NE 0.
    CONCATENATE
       'Material ' FUWA_PINS-MATNR ' bukan pallet (' FUWA_PINS-ZINS01 ')'
       INTO S_MESSAGE SEPARATED BY SPACE.
    MESSAGE S001(00) WITH S_MESSAGE.
  ENDIF.

ENDFORM.                    " f_check_pallet


*&---------------------------------------------------------------------*
*&      Form  f_check_box
*&---------------------------------------------------------------------*
*       Check box material consistency
*----------------------------------------------------------------------*
*      -->P_ITAB_PINS  text
*      <--P_FC_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_BOX  TABLES   FT_MATERIAL STRUCTURE ITAB_MATERIAL
                   USING    FUWA_PINS STRUCTURE ITAB_PINS
                   CHANGING FCN_ERRNO.
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.

  READ TABLE FT_MATERIAL WITH KEY MATNR = FUWA_PINS-MATNR.
  FCN_ERRNO = SY-SUBRC.

  IF FCN_ERRNO EQ 0.
    IF   FT_MATERIAL-MAGRV NE 'BOX'
      OR FT_MATERIAL-MTART NE 'ZPCK'.
      FCN_ERRNO = 4.
    ENDIF.
  ENDIF.

  IF FCN_ERRNO NE 0.
    CONCATENATE  'Material ' FUWA_PINS-MATNR ' bukan untuk box ('
      FUWA_PINS-ZINS01 '-' FUWA_PINS-ZINS02 ')'
      INTO S_MESSAGE SEPARATED BY SPACE.
    MESSAGE S001(00) WITH S_MESSAGE.
  ENDIF.

ENDFORM.                    " f_check_box
*&---------------------------------------------------------------------*
*&      Form  f_check_roll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_MATERIAL  text
*      -->P_ITAB_PINS  text
*      <--P_FC_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_ROLL  TABLES   FT_MATERIAL STRUCTURE ITAB_MATERIAL
                   USING    FUWA_PINS STRUCTURE ITAB_PINS
                   CHANGING FCN_ERRNO.
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.

  IF FUWA_PINS-MATNR EQ SPACE.
    FUWA_PINS-MATNR = ZPACK_PCH-MATNR.

  ELSEIF FUWA_PINS-MATNR NE ZPACK_PCH-MATNR.
    IF FUWA_PINS-ZINS03 IS INITIAL.
      CONCATENATE 'Material ' FUWA_PINS-MATNR ' tidak dapat dipacking ('
        FUWA_PINS-ZINS01 '-' FUWA_PINS-ZINS02 ')'
        INTO S_MESSAGE SEPARATED BY SPACE.
    ELSE.
      CONCATENATE 'Material ' FUWA_PINS-MATNR ' tidak dapat dipacking ('
        FUWA_PINS-ZINS01 '-' FUWA_PINS-ZINS02 '-' FUWA_PINS-ZINS03 ')'
        INTO S_MESSAGE SEPARATED BY SPACE.
    ENDIF.

    MESSAGE S001(00) WITH S_MESSAGE.
  ENDIF.

ENDFORM.                    " f_check_roll


*&---------------------------------------------------------------------*
*&      Form  f_check_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_MATERIAL  text
*      -->FCN_ERRNO    text
*----------------------------------------------------------------------*
FORM F_CHECK_MATNR TABLES FT_MATERIAL STRUCTURE ITAB_MATERIAL.
  DATA N_ERRNO TYPE I.
  DATA S_MESSAGE(50).
  DATA S_TEXT TYPE MAKTX.

  READ TABLE FT_MATERIAL WITH KEY MATNR = ZPACK_PCH-MATNR.
  N_ERRNO = SY-SUBRC.

  IF N_ERRNO EQ 0.
    IF FT_MATERIAL-MAGRV NE 'GEN'.
      N_ERRNO = 4.
    ENDIF.
  ENDIF.

  IF N_ERRNO NE 0.
    CONCATENATE 'Material ' ZPACK_PCH-MATNR ' tidak dapat dipacking'
      INTO S_MESSAGE SEPARATED BY SPACE.

    MESSAGE E001(00) WITH S_MESSAGE.
  ENDIF.

ENDFORM.                    "f_check_matnr


*&---------------------------------------------------------------------*
*&      Form  f_lock_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_N_ERRNO  text
*----------------------------------------------------------------------*
FORM F_LOCK_LIST  CHANGING FCN_ERRNO.
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.
  DATA S_HUSEQ TYPE ZPACK_PCL-HUSEQ.
  DATA ITAB_LOCKED TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA ITAB_PCL    TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA N_INDEX TYPE I.

  DATA:
  LD_SUBRC(2),
  LD_DESCR TYPE TEXT255,
  LT_LOG TYPE TABLE OF ZPACK_PCL_LOG WITH HEADER LINE.

  SELECT * INTO TABLE ITAB_PCL
    FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR
      AND HUSEQ_P = '000000'.

  FCN_ERRNO = 0.
  LOOP AT ITAB_PCL.
    N_INDEX = SY-TABIX.

    CONCATENATE 'PCL' ITAB_PCL-PINNR ITAB_PCL-HUSEQ INTO S_LOOBJ.

    CALL FUNCTION 'ENQUEUE_EZPACK_PCL'
      EXPORTING
        MANDT          = SY-MANDT
        LOOBJ          = S_LOOBJ
        _WAIT          = 'X'
      EXCEPTIONS
        FOREIGN_LOCK   = 1
        SYSTEM_FAILURE = 2
        OTHERS         = 3.

    FCN_ERRNO = SY-SUBRC.
    IF FCN_ERRNO EQ 0.
      APPEND ITAB_PCL TO ITAB_LOCKED.
      ITAB_PCL-COMPUTER_NAME = GS_COMPUTER_NAME.
      MODIFY ITAB_PCL INDEX N_INDEX.

    ELSE.
      LOOP AT ITAB_LOCKED.
        CONCATENATE 'PCL' ITAB_LOCKED-PINNR ITAB_LOCKED-HUSEQ INTO S_LOOBJ.

        CALL FUNCTION 'DEQUEUE_EZPACK_PCL'
          EXPORTING
            LOOBJ = S_LOOBJ.
      ENDLOOP.

      UPDATE ZPACK_PCL FROM TABLE ITAB_LOCKED.


      MOVE SY-SUBRC TO LD_SUBRC.
      REFRESH LT_LOG.

      LOOP AT ITAB_LOCKED.
        MOVE-CORRESPONDING ITAB_LOCKED TO LT_LOG.
        CONCATENATE '(' LD_SUBRC ') F_LOCK_LIST, VENUM=' ITAB_LOCKED-VENUM ', HUSTAT=' ITAB_LOCKED-HUSTAT INTO LT_LOG-DESCR.
        CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_LOCKED-PRSTAT INTO LT_LOG-DESCR.
        APPEND LT_LOG.
      ENDLOOP.


      MESSAGE E001(00) WITH 'Pallet sedang diproses.'.
      RETURN.
    ENDIF.
  ENDLOOP.

  UPDATE ZPACK_PCL FROM TABLE ITAB_PCL.
  MOVE SY-SUBRC TO LD_SUBRC.

  IF SY-SUBRC NE 0.
    MESSAGE I001(00) WITH 'Cant apply lock to HU table.'.
    FCN_ERRNO = SY-SUBRC.
  ENDIF.


  REFRESH LT_LOG.

  LOOP AT ITAB_LOCKED.
    MOVE-CORRESPONDING ITAB_LOCKED TO LT_LOG.
    CONCATENATE '(' LD_SUBRC ') F_LOCK_LIST, VENUM=' ITAB_LOCKED-VENUM ', HUSTAT=' ITAB_LOCKED-HUSTAT INTO LT_LOG-DESCR.
    CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_LOCKED-PRSTAT INTO LT_LOG-DESCR.
    APPEND LT_LOG.
  ENDLOOP.


ENDFORM.                    " f_lock_list


*&---------------------------------------------------------------------*
*&      Form  f_lock_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOCK_SONUM CHANGING FCN_ERRNO .
  DATA S_LOOBJ TYPE ZTLOCK-LOOBJ.

  CONCATENATE 'SON' ZPACK_PCH-VBELN ZPACK_PCH-POSNR INTO S_LOOBJ.
  CALL FUNCTION 'ENQUEUE_EZPACK_PCL'
    EXPORTING
      MANDT          = SY-MANDT
      LOOBJ          = S_LOOBJ
      _WAIT          = 'X'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  FCN_ERRNO = SY-SUBRC.
  IF FCN_ERRNO NE 0.
    MESSAGE E001(00) WITH 'SO Item tidak dapat di lock.'.
  ENDIF.
ENDFORM.                    " f_lock_so


*&---------------------------------------------------------------------*
*&      Form  f_trim_pins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FUS_PINNR  text
*----------------------------------------------------------------------*
FORM F_TRIM_PINS USING FUS_PINNR.
  DATA:
    BEGIN OF ITAB_FILLED OCCURS 0,
      ZINS01 TYPE NUMC2,
      COUNT  TYPE I,
    END OF ITAB_FILLED,
    ITAB_EMPTY LIKE ITAB_FILLED OCCURS 0 WITH HEADER LINE,
    WA_PCH TYPE ZPACK_PCH,
    ANS.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Remove unused pallets'
      TEXT_QUESTION         = 'Remove unused pallets?'
      TEXT_BUTTON_1         = 'Yes'
      TEXT_BUTTON_2         = 'No'
      DEFAULT_BUTTON        = '2'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = ANS
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF ANS = '2'.
    RETURN.
  ENDIF.

*  PERFORM f_backup_pins_value.

  SELECT ZINS01 COUNT( DISTINCT VENUM ) AS COUNT INTO TABLE ITAB_FILLED
    FROM ZPACK_PCL
    WHERE PINNR = FUS_PINNR
      AND HUSEQ_P = '000000'
      AND VENUM NE SPACE
    GROUP BY ZINS01.

  IF ITAB_FILLED[] IS INITIAL.
    DELETE FROM ZPACK_PCL WHERE PINNR = FUS_PINNR.


    DATA:
    LD_SUBRC(2),
    LD_PACKED(18),
    LD_DESCR TYPE TEXT255.

    MOVE SY-SUBRC TO LD_SUBRC.
    CONCATENATE '(' LD_SUBRC ') F_TRIM_PINS, DELETE MULTIPLE RECORDS' INTO LD_DESCR.


    DELETE FROM ZPACK_PC WHERE PINNR = FUS_PINNR.
    SELECT SINGLE * INTO WA_PCH FROM ZPACK_PCH WHERE PINNR = FUS_PINNR.
    WA_PCH-PINST = C_PINST_INACTIVE.
    UPDATE ZPACK_PCH FROM WA_PCH.
    RETURN.
  ENDIF.

  SELECT ZINS01 SUM( PACKED ) AS COUNT INTO
    CORRESPONDING FIELDS OF TABLE ITAB_EMPTY
    FROM ZPACK_PCL
    WHERE PINNR = FUS_PINNR
      AND HUSEQ_P = '000000'
    GROUP BY ZINS01
    HAVING SUM( PACKED ) = 0.

  DATA ITAB_PC TYPE TABLE OF ZPACK_PC WITH HEADER LINE.
  SELECT * INTO TABLE ITAB_PC FROM ZPACK_PC
    FOR ALL ENTRIES IN ITAB_FILLED
    WHERE PINNR  = FUS_PINNR
      AND ZINS01 = ITAB_FILLED-ZINS01
      AND INILVL = C_LEVEL_PALLET.

  DATA N_INDEX TYPE I.

  LOOP AT ITAB_PC.
    N_INDEX = SY-TABIX.
    READ TABLE ITAB_FILLED WITH KEY ZINS01 = ITAB_PC-ZINS01.
    IF SY-SUBRC EQ 0.
      ITAB_PC-ZMENG = ITAB_FILLED-COUNT.
      MODIFY ITAB_PC INDEX N_INDEX.
    ENDIF.
  ENDLOOP.

  LOOP AT ITAB_EMPTY.
    DELETE FROM ZPACK_PCL WHERE PINNR = FUS_PINNR
      AND ZINS01 = ITAB_EMPTY-ZINS01.


    MOVE SY-SUBRC TO LD_SUBRC.

    CONCATENATE '(' LD_SUBRC ') F_TRIM_PINS, DELETE MULTIPLE RECORDS' INTO LD_DESCR.


    DELETE FROM ZPACK_PC WHERE PINNR = FUS_PINNR
      AND ZINS01 = ITAB_EMPTY-ZINS01.
  ENDLOOP.

  MODIFY ZPACK_PC FROM TABLE ITAB_PC.

  DATA ITAB_PCL TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  SELECT * INTO TABLE ITAB_PCL FROM ZPACK_PCL
    FOR ALL ENTRIES IN ITAB_FILLED
    WHERE PINNR = FUS_PINNR
      AND ZINS01 = ITAB_FILLED-ZINS01
      AND HUSEQ_P = '000000'
      AND VENUM EQ SPACE.

  IF ITAB_PCL[] IS NOT INITIAL.
    SELECT * APPENDING TABLE ITAB_PCL FROM ZPACK_PCL
      FOR ALL ENTRIES IN ITAB_PCL
      WHERE PINNR = FUS_PINNR
        AND HUSEQ_P = ITAB_PCL-HUSEQ.

    DELETE ZPACK_PCL FROM TABLE ITAB_PCL.

    DATA:
    LT_LOG TYPE TABLE OF ZPACK_PCL_LOG WITH HEADER LINE.

    MOVE SY-SUBRC TO LD_SUBRC.
    REFRESH LT_LOG.

    LOOP AT ITAB_PCL.
      MOVE-CORRESPONDING ITAB_PCL TO LT_LOG.
      CONCATENATE '(' LD_SUBRC ') F_TRIM_PINS, DELETE 1 RECORD, VENUM=' ITAB_PCL-VENUM ', HUSTAT=' ITAB_PCL-HUSTAT INTO LT_LOG-DESCR.
      CONCATENATE LT_LOG-DESCR ', PRSTAT=' ITAB_PCL-PRSTAT INTO LT_LOG-DESCR.
      APPEND LT_LOG.
    ENDLOOP.


  ENDIF.

  DATA N_COUNT TYPE I.
  SELECT COUNT( * ) INTO N_COUNT FROM ZPACK_PCL
    WHERE PINNR = FUS_PINNR
      AND HUSTAT = C_HUSTAT_INPROGRESS
      AND HUSEQ_P = '000000'.

  IF N_COUNT EQ 0.
    SELECT SINGLE * INTO WA_PCH FROM ZPACK_PCH WHERE
      PINNR = FUS_PINNR.
    WA_PCH-PINST = C_PINST_COMPLETED.
  ELSE.
    WA_PCH-PINST = C_PINST_INPROGRESS.
  ENDIF.

  UPDATE ZPACK_PCH FROM WA_PCH.
  COMMIT WORK AND WAIT.
ENDFORM.                    "f_trim_pins


*&---------------------------------------------------------------------*
*&      Form  f_add_instruction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_INSTRUCTION .
  DATA T_ERR_TAB TYPE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
  DATA: OPT TYPE CTU_PARAMS.

  OPT-RACOMMIT = 'X'.
  OPT-NOBINPT  = 'X'.
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.

  SET PARAMETER ID 'ZPI' FIELD ZPACK_PCH-PINNR.
  SET PARAMETER ID 'TSOURCE' FIELD SY-TCODE.
  SET PARAMETER ID 'AUN'  FIELD  ZPACK_PCH-VBELN.
  SET PARAMETER ID 'ZSOIT' FIELD ZPACK_PCH-POSNR.
  SET PARAMETER ID 'PLANT' FIELD ZPACK_PCH-WERKS. " ADD NEW COMPANY
  CALL TRANSACTION 'ZHU4AD'.
  SET PARAMETER ID 'TSOURCE' FIELD SPACE.

  DATA N_ERRNO TYPE I.
  PERFORM F_LOAD_DOC CHANGING N_ERRNO.

ENDFORM.                    " f_add_instruction


*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR T_BDCDATA.
  T_BDCDATA-PROGRAM  = PROGRAM.
  T_BDCDATA-DYNPRO   = DYNPRO.
  T_BDCDATA-DYNBEGIN = 'X'.

  APPEND T_BDCDATA.

ENDFORM.                    " BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0181   text
*      -->P_0182   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

  CLEAR T_BDCDATA.
  T_BDCDATA-FNAM = FNAM.
  T_BDCDATA-FVAL = FVAL.

  APPEND T_BDCDATA.


ENDFORM.                    " BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  f_renumber
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITAB_PCL  text
*----------------------------------------------------------------------*
FORM F_RENUMBER  TABLES FT_PCL TYPE TT_RENUMBER.
  DATA S_SEQ_PALLET   TYPE ZPOSNR_PL.
  DATA S_SEQ_BOX      TYPE ZPOSNR_PL.
  DATA S_LAST_SEQ     TYPE ZPOSNR_PL.
  DATA N_PALLET_INDEX TYPE I.
  DATA N_BOX_INDEX    TYPE I.

  DATA ITAB_PALLET  TYPE TT_RENUMBER WITH HEADER LINE.
  DATA ITAB_BOX     TYPE TT_RENUMBER WITH HEADER LINE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ITAB_PALLET FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR AND HUSEQ_P = '000000'.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE ITAB_BOX FROM ZPACK_PCL
    WHERE PINNR = ZPACK_PCH-PINNR AND HUSEQ_P NE '000000'.

  S_SEQ_PALLET = 0.
  LOOP AT ITAB_PALLET.
    N_PALLET_INDEX = SY-TABIX.
    ADD 100 TO S_SEQ_PALLET.
    S_SEQ_BOX = S_SEQ_PALLET.

    LOOP AT ITAB_BOX WHERE HUSEQ_P EQ ITAB_PALLET-HUSEQ.
      N_BOX_INDEX = SY-TABIX.
      ADD 1 TO S_SEQ_BOX.
      ITAB_BOX-OLD_HUSEQ = ITAB_BOX-HUSEQ.
      ITAB_BOX-HUSEQ = S_SEQ_BOX.
      ITAB_BOX-HUSEQ_P = S_SEQ_PALLET.
      MODIFY ITAB_BOX INDEX N_BOX_INDEX.
    ENDLOOP.

    ITAB_PALLET-OLD_HUSEQ = ITAB_PALLET-HUSEQ.
    ITAB_PALLET-HUSEQ = S_SEQ_PALLET.
    CLEAR ITAB_PALLET-HUSEQ_P.
    MODIFY ITAB_PALLET INDEX N_PALLET_INDEX.
  ENDLOOP.

  REFRESH FT_PCL.
  INSERT LINES OF ITAB_PALLET INTO TABLE FT_PCL.
  INSERT LINES OF ITAB_BOX    INTO TABLE FT_PCL.
  SORT FT_PCL BY HUSEQ.
ENDFORM.                    " f_renumber


*&---------------------------------------------------------------------*
*&      Form  f_backup_pins_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FUS_PINNR  text
*----------------------------------------------------------------------*
FORM F_BACKUP_PINS_VALUE.
  DATA ITAB_PCH TYPE TABLE OF ZPACK_PCH WITH HEADER LINE.
  DATA ITAB_PCL TYPE TABLE OF ZPACK_PCL WITH HEADER LINE.
  DATA ITAB_PC  TYPE TABLE OF ZPACK_PC WITH HEADER LINE.

  SELECT * INTO TABLE ITAB_PCH FROM ZPACK_PCH.
  SELECT * INTO TABLE ITAB_PC  FROM ZPACK_PC.
  SELECT * INTO TABLE ITAB_PCL FROM ZPACK_PCL.

  DELETE FROM ZPACK_PCH2.
  DELETE FROM ZPACK_PC2.
  DELETE FROM ZPACK_PCL2.

  INSERT ZPACK_PCH2 FROM TABLE ITAB_PCH.
  INSERT ZPACK_PC2  FROM TABLE ITAB_PC.
  INSERT ZPACK_PCL2 FROM TABLE ITAB_PCL.

ENDFORM.                    " f_backup_pins_value

*&---------------------------------------------------------------------*
*&      Form  f_check_usage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FUS_PINNR  text
*      <--P_FCN_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CHECK_USAGE  USING    FUS_PINNR
                    CHANGING FCN_ERRNO.

  DATA N_COUNT TYPE I.

  SELECT COUNT( * ) INTO N_COUNT FROM ZPACK_PCL
  WHERE PINNR = FUS_PINNR AND HUSTAT NE C_HUSTAT_OPEN.

  IF N_COUNT GT 0.
    FCN_ERRNO = 4.
    MESSAGE I000(0K) WITH 'Packing instruction is already in use.'.
  ELSE.
    FCN_ERRNO = 0.
  ENDIF.

ENDFORM.                    " f_check_usage