*&---------------------------------------------------------------------*
*&  Include           ZPPI_GCHART_PR_JRF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GANTCHART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GANTCHART .
  DATA : IEDD TYPE AFRU-IEDD,
         ISDD TYPE AFRU-ISDD,
         IEDZ TYPE AFRU-IEDZ,
         ISDZ TYPE AFRU-ISDZ,
         FSEDZ TYPE AFVV-FSEDZ,
         FSEDD TYPE AFVV-FSEDD,
         FSAVZ TYPE AFVV-FSAVZ,
         FSAVD TYPE AFVV-FSAVD,
         NUM TYPE I,
         COL TYPE STRING,
         ZNOTOK TYPE P DECIMALS 1,
         ZOK TYPE P DECIMALS 1.

  CLEAR : ITEM. REFRESH : ITEM.
  TA_ITEM2[] = TA_ITEM[].
  DELETE ADJACENT DUPLICATES FROM TA_ITEM COMPARING AUFNR.
  DELETE TA_ITEM2 WHERE WEMNG = 0.

  LOOP AT TA_ITEM INTO WA_ITEM.

    CLEAR : FSEDD,FSAVD,FSEDZ,FSAVZ,IEDD,ISDD,IEDZ,ISDZ,ZOK,ZNOTOK.
    LOOP AT TA_ITEM2 INTO WA_ITEM2 WHERE AUFNR = WA_ITEM-AUFNR.
      IF FSEDD = '00000000'.
        FSEDD = WA_ITEM2-FSEDD.
      ENDIF.
      IF FSAVD = '00000000'.
        FSAVD = WA_ITEM2-FSAVD.
      ENDIF.
      IF FSEDZ = '000000'.
        FSEDZ = WA_ITEM2-FSEDZ.
      ENDIF.
      IF FSAVZ = '000000'.
        FSAVZ = WA_ITEM2-FSAVZ.
      ENDIF.
      IF WA_ITEM2-FSEDD > FSEDD.
        FSEDD = WA_ITEM2-FSEDD.
      ENDIF.
      IF WA_ITEM2-FSAVD < FSAVD.
        FSAVD = WA_ITEM2-FSAVD.
      ENDIF.
      IF WA_ITEM-FSEDZ > FSEDZ.
        FSEDZ = WA_ITEM-FSEDZ.
      ENDIF.
      IF WA_ITEM-FSAVZ < FSAVZ.
        FSAVZ = WA_ITEM-FSAVZ.
      ENDIF.
      IF WA_ITEM2-ZZGRADE = 'OK'.
        ZOK = WA_ITEM2-WEMNG.
      ELSEIF WA_ITEM2-ZZGRADE = 'NOT OK'.
        ZNOTOK = WA_ITEM2-WEMNG.
      ENDIF.
    ENDLOOP.

    ITEMNO = ITEMNO + 1.

**** 1) PLANNING
    PERFORM CONVERT USING WA_ITEM-AUFNR WA_ITEM-ZLINE WA_ITEM-ZZCODE WA_ITEM-ZWIDTH WA_ITEM-ZLENGTH
                          WA_ITEM-GAMNG '1' WA_ITEM-ZCUSTM  CHANGING ITEM-ITEXT.
    APPEND ITEM.

    CLEAR : DDIFF, ZDIFF, ZFSEDZ, ZFSAVZ, TDIFF, CNUM.
    IF ZOK = 0 AND ZNOTOK = 0.
      DATE  = WA_ITEM-FSEDD - WA_ITEM-FSAVD. "(schedule finish date - schedule start date  )
      TIME  = WA_ITEM-FSEDZ - WA_ITEM-FSAVZ. " ( schedule finish time - schedule start time )
      PERFORM COUNT_TIME USING WA_ITEM-FSAVZ WA_ITEM-FSEDZ WA_ITEM-FSAVD WA_ITEM-FSEDD CHANGING ZDIFF.
      IF WA_ITEM-AUART NE 'ZP90'.
        PERFORM FILL_ELEM USING '' WA_ITEM-FSAVD WA_ITEM-FSAVZ ZDIFF 'M' 'RED' '20' 'C'.
      ELSE.
        PERFORM FILL_ELEM USING '' WA_ITEM-FSAVD WA_ITEM-FSAVZ ZDIFF 'M' 'BLUE' '20' 'C'.
      ENDIF.
    ELSE.
      DATE  = FSEDD - FSAVD. "(schedule finish date - schedule start date  )
      TIME  = FSEDZ - FSAVZ. " ( schedule finish time - schedule start time )
      PERFORM COUNT_TIME USING FSAVZ FSEDZ FSAVD FSEDD CHANGING ZDIFF.
      IF WA_ITEM-AUART NE 'ZP90'.
        PERFORM FILL_ELEM USING '' FSAVD FSAVZ ZDIFF 'M' 'RED' '20' 'C'.
      ELSE.
        PERFORM FILL_ELEM USING '' FSAVD FSAVZ ZDIFF 'M' 'BLUE' '20' 'C'.
      ENDIF.
    ENDIF.

**** 2) ACTUAL OK
    IF ZOK > '0.0'.
      ITEMNO = ITEMNO + 1.
      PERFORM CONVERT USING WA_ITEM-AUFNR WA_ITEM-ZLINE WA_ITEM-ZZCODE WA_ITEM-ZWIDTH WA_ITEM-ZLENGTH
                            ZOK '2' WA_ITEM-ZCUSTM  CHANGING ITEM-ITEXT.
      APPEND ITEM.
      LOOP AT TA_ITEM2 INTO WA_ITEM2 WHERE AUFNR = WA_ITEM2-AUFNR
                                     AND   ZZGRADE = 'OK'.
        COL = 'GREEN'.
        " calculate time actual
        CLEAR : DDIFF, ZDIFF, ZFSEDZ, ZFSAVZ, TDIFF, CNUM.
        DATE  = WA_ITEM2-IEDD - WA_ITEM2-ISDD. "(actual finish date - actual start date  )
        TIME  = WA_ITEM2-IEDZ - WA_ITEM2-ISDZ. " ( actual finish time - actual start time )
        PERFORM COUNT_TIME USING WA_ITEM2-ISDZ WA_ITEM2-IEDZ WA_ITEM2-ISDD WA_ITEM2-IEDD CHANGING ZDIFF.
        PERFORM FILL_ELEM USING '' WA_ITEM2-ISDD WA_ITEM2-ISDZ ZDIFF 'M' COL '20' 'C'.
      ENDLOOP.
    ENDIF.


**** 2) ACTUAL NOT OK
    IF ZNOTOK   > '0.0'.
      ITEMNO = ITEMNO + 1.
      PERFORM CONVERT USING WA_ITEM-AUFNR WA_ITEM-ZLINE WA_ITEM-ZZCODE WA_ITEM-ZWIDTH WA_ITEM-ZLENGTH
                            ZNOTOK '3' WA_ITEM-ZCUSTM CHANGING ITEM-ITEXT.
      APPEND ITEM.
      LOOP AT TA_ITEM2 INTO WA_ITEM2 WHERE AUFNR = WA_ITEM2-AUFNR
                                     AND   ZZGRADE = 'NOT OK'.

        COL = 'YELLOW'.
        " calculate time actual
        CLEAR : DDIFF, ZDIFF, ZFSEDZ, ZFSAVZ, TDIFF, CNUM.
        DATE  = WA_ITEM2-IEDD - WA_ITEM2-ISDD. "(actual finish date - actual start date  )
        TIME  = WA_ITEM2-IEDZ - WA_ITEM2-ISDZ. " ( actual finish time - actual start time )
        PERFORM COUNT_TIME USING WA_ITEM2-ISDZ WA_ITEM2-IEDZ WA_ITEM2-ISDD WA_ITEM2-IEDD CHANGING ZDIFF.
        PERFORM FILL_ELEM USING '' WA_ITEM2-ISDD WA_ITEM2-ISDZ ZDIFF 'M' COL '20' 'C'.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


  CALL FUNCTION 'GRAPH_GANTT'
   EXPORTING
   COMMAND_OK            = 'X'
*   CONFIRM               = ' '
*   DFEL                  = ' '
*   DFMS                  = ' '
*   GLENGTH               = ' '
      HGRID                 = 'X'
      LEGEND                = 'Legend'
      MODIF                 = 'ON'
      NOTXT                 = SPACE
*   NO_EL_POPUP           = ' '
*   NO_EX_POPUP           = ' '
*   NO_IT_POPUP           = ' '
*   NO_MS_POPUP           = ' '
*   NO_SORT               = ' '
*   PWDID                 = ' '
*   SET_FOCUS             = 'x'
*   SO_CONTENTS           = ' '
   SO_RECEIVER           = 'X'
*   SO_SEND               = ' '
*   SO_TITLE              = ' '
*   STAT                  = ' '
*   SUPER                 = ' '
*   TIMER                 = 0
*   TLENGTH               = ' '
*   TLINE                 =
*   TMBEG                 =
*   TMEND                 =
*   TMVIEW                =
      TTEXT                 = 'Line Type  Width Length  Qty Customer  PO No.'
      TTITLE                = 'Gantt Chart Production Order Jumbo Roll'
      TUNIT                 = 'H'
      VGRID                 = 'X'
      WHEADER               = 'Gantt Chart Production Order Jumbo Roll'
*   WINID                 = ' '
* IMPORTING
*   AKT_SVIEW             =
*   AKT_TMBEG             =
*   AKT_TMEND             =
*   AKT_TUNIT             =
*   CUA_ID                =
*   G_TYP                 =
*   M_TYP                 =
*   RBUFF                 =
*   RWNID                 =
    TABLES
      ELEM                  = ELEM
      ITEM                  = ITEM
      LGEL                  = LGEL
      LGMS                  = LGMS
      MIST                  = MIST
      MSGT                  = MSGT
    EXCEPTIONS
      INV_ELEM_BAKGR        = 1
      INV_ELEM_BORDR        = 2
      INV_ELEM_FORGR        = 3
      INV_ELEM_PLACE        = 4
      INV_ITEM_UCOLOR       = 5
      INV_MIST_COLOR        = 6
      INV_MIST_FORM         = 7
      INV_MIST_POS          = 8
      INV_MIST_SIZE         = 9
      OTHERS                = 10.

ENDFORM.                    " GANTCHART

*&---------------------------------------------------------------------*
*&      Form  FILL_ELEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TEXT       text
*      -->DBEG       text
*      -->TBEG       text
*      -->DUR        text
*      -->UNIT       text
*      -->COL        text
*      -->SIZE       text
*      -->POS        text
*----------------------------------------------------------------------*
FORM FILL_ELEM USING TEXT DBEG TBEG DUR UNIT COL SIZE POS.
  ELEM-ITEMNO = ITEMNO.
  ELEM-TXT = TEXT.
  D = DBEG.
  T = TBEG.
  ELEM-TBEG = T.
  ELEM-BEG =  ( D - DATE_NULL ) * 86400 + T.
  CASE UNIT.
    WHEN 'S'.
      ELEM-DUR = DUR.
    WHEN 'M'.
      ELEM-DUR = DUR * 60.
    WHEN 'H'.
      ELEM-DUR = DUR * 60 * 60.
    WHEN 'D'.
      ELEM-DUR = DUR * 60 * 60 * 24.
    WHEN 'W'.
      ELEM-DUR = DUR * 60 * 60 * 24 * 7.
    WHEN 'N'.
      ELEM-DUR = DUR * 60 * 60 * 24 * 30.
    WHEN 'Q'.
      ELEM-DUR = DUR * 60 * 60 * 24 * 90.
    WHEN 'Y'.
      ELEM-DUR = DUR * 60 * 60 * 24 * 365.
  ENDCASE.
  ELEM-BAKGR = COL.
* ELEM-PLACE = POS.
  ELEM-HEIGH = SIZE.
  CASE POS.
    WHEN 'U'.
      ELEM-PLACE = 'ABOVE'.
    WHEN 'O'.
      ELEM-PLACE = 'OVER'.
    WHEN 'C'.
      ELEM-PLACE = 'CENTER'.
    WHEN 'L'.
      ELEM-PLACE = 'BELOW'.
  ENDCASE.
  APPEND ELEM.
ENDFORM.                    "FILL_ELEM

*&---------------------------------------------------------------------*
*&      Form  COUNT_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ZTIME1     text
*      -->ZDATE1     text
*      -->ZZDIFF     text
*----------------------------------------------------------------------*
FORM COUNT_TIME USING  ZTIME1 ZTIME2 ZDATE1 ZDATE2  CHANGING ZZDIFF.
  CALL FUNCTION 'DELTA_TIME_DAY_HOUR'
    EXPORTING
      T1      = ZTIME1
      T2      = ZTIME2
      D1      = ZDATE1
      D2      = ZDATE2
    IMPORTING
      MINUTES = ZZDIFF.
ENDFORM.                    "COUNT_TIME
*&---------------------------------------------------------------------*
*&      Form  REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REPORT .
  DESCRIBE TABLE TA_ITEM LINES LINE.
  IF LINE = 0.
    MESSAGE 'No data' TYPE 'I'.
    RETURN.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " REPORT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR : TA_ITEM, WA_ITEM,TA_ITEM2,WA_ITEM2,MBLNR,MJAHR,ZEILE,V_CHARG.
  REFRESH : TA_ITEM,TA_ITEM2.
  SELECT AUFK~AUFNR   AS AUFNR
         AUFK~ZLINE   AS ZLINE
         AUFK~ZCODE   AS ZCODE
         AUFK~ZWIDTH  AS ZWIDTH
         AUFK~ZLENGTH AS ZLENGTH
         AUFK~WERKS   AS WERKS
         AUFK~ZCUSTM  AS ZCUSTM
         AFKO~GAMNG   AS GAMNG
         AFKO~PLNBEZ  AS PLNBEZ
         AUFK~AUART   AS AUART
         AUFK~OBJNR   AS OBJNR
  FROM AUFK
  JOIN AFKO ON AUFK~AUFNR = AFKO~AUFNR
  INTO CORRESPONDING FIELDS OF TABLE TA_ITEM
  WHERE AUFK~ZLINE IN ZLINE
  AND   AUFK~AUTYP = '40'
  AND   AUFK~AUART IN ('ZP01', 'ZP02', 'ZP03', 'ZP04', 'ZP05', 'ZP06', 'ZP07', 'ZP08', 'ZP09', 'ZP11','ZP10'
                       ,'ZP90','ZTR1', 'ZTR2','ZTR3','ZTR4','ZTR5','ZTR6')
  AND   AUFK~AUFNR IN S_AUFNR
  AND   AFKO~GSTRS IN TANGGAL. "AUFK~ERDAT IN TANGGAL.


  LOOP AT TA_ITEM INTO WA_ITEM.

      SELECT STAT INTO WA_ITEM-STAT
        FROM JEST
        WHERE OBJNR = WA_ITEM-OBJNR
        AND   INACT = ' '
        AND   STAT = 'I0045'.
      ENDSELECT.

    " BATCH
    SELECT AUFM~CHARG MBLNR MJAHR ZEILE INTO (WA_ITEM-CHARG,MBLNR,MJAHR,ZEILE)
      FROM AUFM
      WHERE AUFM~AUFNR = WA_ITEM-AUFNR
      AND   AUFM~BWART = '101'
      AND   AUFM~WERKS = WA_ITEM-WERKS
      %_HINTS ORACLE 'INDEX("AUFM" "AUFM~Z03")'.

      IF SY-SUBRC = 0 .
        SELECT SINGLE MSEG~CHARG INTO V_CHARG
          FROM MSEG
          WHERE SMBLN = MBLNR
          AND   SJAHR = MJAHR
          AND   SMBLP = ZEILE
          AND   BWART = '102'.
*        %_HINTS ORACLE 'INDEX("MSEG" "MSEG~S")'.
        IF V_CHARG NE ''.
          SGTXT = WA_ITEM-CHARG = ''.
        ELSE.
          CLEAR : SGTXT.
          SELECT SINGLE MSEG~SGTXT INTO SGTXT
            FROM MSEG
            WHERE MBLNR = MBLNR
            AND   MJAHR = MJAHR
            AND   ZEILE = ZEILE
            AND   BWART = '101'.
          SPLIT SGTXT AT '-' INTO WA_ITEM-ZZLENGTH  DUMMY.
        ENDIF.
      ENDIF.
      CLEAR : V_CHARG.


      CHECK WA_ITEM-CHARG NE ''.
      CALL FUNCTION 'VB_INIT'.
      CLEAR : TA_BATCH. REFRESH : TA_BATCH.
      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          MATNR              = WA_ITEM-PLNBEZ
          CHARG              = WA_ITEM-CHARG
          WERKS              = WA_ITEM-WERKS
          GET_CLASSIFICATION = 'X'
        TABLES
          CHAR_OF_BATCH      = TA_BATCH.

      READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZWIDTH'.
      IF SY-SUBRC = 0.
        WA_ITEM-ZZWIDTH = WA_BATCH-ATWTB .
      ENDIF.
      READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZGRADEJR'.
      IF SY-SUBRC = 0.
        TRANSLATE WA_BATCH-ATWTB TO UPPER CASE.
        WA_ITEM-ZZGRADE = WA_BATCH-ATWTB .
      ENDIF.
*      READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTH' .
*      IF SY-SUBRC = 0.
*        WA_ITEM-ZZLENGTH = WA_BATCH-ATWTB .
*      ENDIF.
*      IF WA_ITEM-ZZLENGTH = ''.
*        READ TABLE TA_BATCH INTO WA_BATCH WITH KEY ATNAM = 'ZZLENGTHSHT'.
*        IF SY-SUBRC = 0.
*          WA_ITEM-ZZLENGTH = WA_BATCH-ATWTB .
*        ENDIF.
*      ENDIF.

      SELECT  AFVV~FSAVD AFVV~FSAVZ AFVV~SSEDD AFVV~SSEDZ
                    AFRU~ISDD AFRU~ISDZ AFRU~IEDD AFRU~IEDZ AFRU~STZHL
         INTO (WA_ITEM-FSAVD, WA_ITEM-FSAVZ, WA_ITEM-FSEDD, WA_ITEM-FSEDZ ,
               WA_ITEM-ISDD,WA_ITEM-ISDZ, WA_ITEM-IEDD, WA_ITEM-IEDZ ,WA_ITEM-STZHL )
         FROM AFKO
         JOIN AFVV ON AFKO~AUFPL = AFVV~AUFPL
         JOIN AFVC ON AFKO~AUFPL = AFVC~AUFPL
         JOIN AFRU ON AFRU~RUECK = AFVC~RUECK
         WHERE AFKO~AUFNR = WA_ITEM-AUFNR
         AND  AFRU~LTXA1 = MBLNR.
      ENDSELECT.

      MOVE-CORRESPONDING WA_ITEM TO WA_ITEM2.
      APPEND WA_ITEM2 TO TA_ITEM2.
    ENDSELECT.

    IF SY-SUBRC NE 0.
      SELECT  SINGLE AFVV~FSAVD AFVV~FSAVZ AFVV~SSEDD AFVV~SSEDZ
         INTO (WA_ITEM-FSAVD, WA_ITEM-FSAVZ, WA_ITEM-FSEDD, WA_ITEM-FSEDZ)
         FROM AFKO
         JOIN AFVV ON AFKO~AUFPL = AFVV~AUFPL
         WHERE AFKO~AUFNR = WA_ITEM-AUFNR.

      MOVE-CORRESPONDING WA_ITEM TO WA_ITEM2.
      APPEND WA_ITEM2 TO TA_ITEM2.
    ENDIF.
  ENDLOOP.

  TA_ITEM[] = TA_ITEM2[].
  SORT TA_ITEM BY AUFNR.


  LOOP AT TA_ITEM INTO WA_ITEM.
    CLEAR : ZZWIDTH, ZZLENGTH,CHARG,OK,NOTOK.

    LOOP AT TA_ITEM2 INTO WA_ITEM2 WHERE AUFNR = WA_ITEM-AUFNR.
      ZZLENGTH = ZZLENGTH + WA_ITEM2-ZZLENGTH.
      IF WA_ITEM2-ZZGRADE = 'OK'.
        OK = OK + WA_ITEM2-ZZLENGTH.
      ELSEIF WA_ITEM2-ZZGRADE = 'NOT OK'.
        NOTOK = NOTOK + WA_ITEM2-ZZLENGTH.
      ENDIF.
    ENDLOOP.


    IF WA_ITEM-ZZGRADE = 'OK'.
      WA_ITEM-WEMNG = ( OK / ( WA_ITEM-ZLENGTH * WA_ITEM-GAMNG ) ) * WA_ITEM-GAMNG.
    ELSEIF WA_ITEM-ZZGRADE = 'NOT OK'.
      WA_ITEM-WEMNG = ( NOTOK / ( WA_ITEM-ZLENGTH * WA_ITEM-GAMNG ) ) * WA_ITEM-GAMNG.
    ELSEIF WA_ITEM-ZZGRADE = ''.
      WA_ITEM-WEMNG = 0.
    ENDIF.

    SELECT SINGLE CAWNT~ATWTB INTO WA_ITEM-ZZCODE
       FROM CAWNT
       JOIN CAWN ON CAWNT~ATZHL = CAWN~ATZHL
       AND  CAWN~ATINN = CAWNT~ATINN
       WHERE CAWN~ATWRT = WA_ITEM-ZCODE.

    WA_ITEM-ZZLENGTH = ZZLENGTH.

    IF WA_ITEM-AUART NE 'ZP90'.
       IF WA_ITEM-WEMNG = 0 AND WA_ITEM-STAT NE ''.
          WA_ITEM-FLAG = 'X'.
       ENDIF.
    ENDIF.
    MODIFY TA_ITEM FROM WA_ITEM.

  ENDLOOP.

  DELETE TA_ITEM WHERE FLAG = 'X'.

ENDFORM.                    " GET_DATA

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
*  T_PRINT-NO_PRINT_LISTINFOS = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
*     IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
*     I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = TA_ITEM
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.


ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  REFRESH FT_EXTAB.
  CLEAR FT_EXTAB.

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&RFRESH'.
      PERFORM GET_DATA.
      FU_SELFIELD-REFRESH = 'X'.
      PERFORM F_LIST_DETAIL.
    WHEN '&EXIT'. "CANCEL
      LEAVE PROGRAM.
    WHEN '&UP'.
      SUBMIT ZPPI_UP_DL_PO_JR VIA SELECTION-SCREEN.
    WHEN '&BACK'.
      SUBMIT ZPPI_GCHART_PR_JR VIA SELECTION-SCREEN.
    WHEN '&GRAP'.
      TA_ORI[] = TA_ITEM2[] = TA_ITEM[].
      PERFORM GANTCHART.
      TA_ITEM2[] = TA_ITEM[] = TA_ORI[] .
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
*  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-BOX_TABNAME = 'T_HEADER'.
  WA_LAYOUT-EXPAND_FIELDNAME = 'EXPAND'.
  WA_LAYOUT-EXPAND_ALL = 'X'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'TA_ITEM' :
   'AUFNR'  '' ''  '' '10' 'ORDER NUMBER'   '' ' ' '' '' ,
   'ZLINE'  '' ''  '' '15' 'LINE'   '' ' ' '' '' ,
   'ZCODE'  '' ''  '' '20' 'TYPE'   '' ' ' '' '' ,
   'ZWIDTH'  '' ''  '' '20' 'WIDTH'   '' ' ' '' '' ,
*   'ZZWIDTH'  '' ''  '' '20' 'WIDTH ACTUAL'   '' ' ' '' '' ,
   'ZLENGTH'  '' ''  '' '20' 'LENGTH '   '' ' ' '' '' ,
*   'ZZENGTH'  '' ''  '' '20' 'LENGTH ACTUAL'   '' ' ' '' '' ,
   'GAMNG'  '' ''  '' '13' 'QTY PLAN'   '' ' ' '' '' ,
   'WEMNG'  '' ''  '' '13' 'QTY ACTUAL'   '' ' ' '' '' ,
   'FSAVD'  '' ''  '' '20' 'SCHEDULE START DATE'   '' ' ' '' '' ,
   'FSAVZ'  '' ''  '' '20' 'SCHEDULE START TIME'   '' ' ' '' '' ,
   'FSEDD'  '' ''  '' '20' 'SCHEDULE FINISH DATE'   '' ' ' '' '' ,
   'FSEDZ'  '' ''  '' '20' 'SCHEDULE FINISH TIME'   '' ' ' '' '' ,
   'ISDD'  '' ''  '' '20' 'ACTUAL START DATE'   '' ' ' '' '' ,
   'ISDZ'  '' ''  '' '20' 'ACTUAL START TIME'   '' ' ' '' '' ,
   'IEDD'  '' ''  '' '20' 'ACTUAL FINISH DATE'   '' ' ' '' '' ,
   'IEDZ'  '' ''  '' '20' 'ACTUAL FINISH TIME'   '' ' ' '' '' ,
   'ZZGRADE'  '' ''  '' '20' 'STATUS'   '' ' ' '' '' .

ENDFORM.                    " F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  CONVERT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AUFNR  text
*      -->P_LINE  text
*      -->P_ZCODE  text
*      -->P_WIDTH  text
*      -->P_LENGTH  text
*      -->P_QTY  text
*      <--P_TEXT  text
*----------------------------------------------------------------------*
FORM CONVERT  USING    P_AUFNR
                       P_VLINE
                       P_ZCODE
                       P_WIDTH
                       P_LENGTH
                       P_QTY
                       P_CODE
                       P_ZCUSTM
              CHANGING P_TEXT.
  DATA ZQTY TYPE P DECIMALS 1.
  CLEAR : WIDTH,LENGTH,QTY,ZQTY.
  MOVE P_WIDTH TO WIDTH.
  MOVE P_LENGTH TO LENGTH.
  MOVE P_QTY TO ZQTY.
  MOVE ZQTY TO QTY.


  IF P_AUFNR = ''.
    AUFNR = SPACE .
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = P_AUFNR
      IMPORTING
        OUTPUT = AUFNR.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_VLINE
    IMPORTING
      OUTPUT = VLINE.
  IF VLINE = ''.
    VLINE = 0.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_ZCODE
    IMPORTING
      OUTPUT = ZCODE.
  IF ZCODE = ''.
    ZCODE = 0.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = WIDTH
    IMPORTING
      OUTPUT = WIDTH.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = LENGTH
    IMPORTING
      OUTPUT = LENGTH.
  .
*  IF AUFNR NE ''.
  IF P_CODE = 1.
    CONCATENATE 'P>' VLINE ZCODE WIDTH LENGTH QTY P_ZCUSTM AUFNR INTO P_TEXT SEPARATED BY SPACE.
  ELSEIF P_CODE = 2.
    CONCATENATE 'AO>' VLINE ZCODE WIDTH LENGTH QTY P_ZCUSTM AUFNR INTO P_TEXT SEPARATED BY SPACE.
  ELSE.
    CONCATENATE 'AN>' VLINE ZCODE WIDTH LENGTH QTY P_ZCUSTM AUFNR INTO P_TEXT SEPARATED BY SPACE..
  ENDIF.


ENDFORM.                    " CONVERT
*&---------------------------------------------------------------------*
*&      Form  F4_ZLINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_ZLINE .
  SELECT ZLINE FROM AUFK INTO TABLE IT_ZLINE.
  SORT IT_ZLINE BY ZLINE.
  DELETE ADJACENT DUPLICATES FROM IT_ZLINE COMPARING ALL FIELDS.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZLINE'
      DYNPPROG        = SY-CPROG  "Program
      DYNPNR          = SY-DYNNR  "Dynpro number
      DYNPROFIELD     = 'ZLINE'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IT_ZLINE
      RETURN_TAB      = IT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.                    " F4_ZLINE