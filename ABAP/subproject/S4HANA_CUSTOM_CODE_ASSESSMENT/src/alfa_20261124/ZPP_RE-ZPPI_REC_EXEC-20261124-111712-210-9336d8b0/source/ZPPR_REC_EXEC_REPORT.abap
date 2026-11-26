*&---------------------------------------------------------------------*
*& Report  ZPPR_REC_EXEC_REPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPR_REC_EXEC_REPORT.

TABLES: MSEG, AUFK, MKPF, ZERROR_LOG.

DATA: BEGIN OF IT_DISPLAY OCCURS 0,
        AUFNR LIKE AUFK-AUFNR,
        MATNR LIKE MARA-MATNR,
        BWART LIKE MSEG-BWART,
        BUDAT LIKE MKPF-BUDAT,
        BLDAT LIKE MKPF-BLDAT,
        CPUDT LIKE MKPF-CPUDT,
        CPUTM LIKE MKPF-CPUTM,
        USNAM TYPE C LENGTH 13,
        WERKS LIKE MSEG-WERKS,
        LGORT LIKE MSEG-LGORT,
        MENGE LIKE MSEG-MENGE,
        MEINS LIKE MSEG-MEINS,
        WEMPF TYPE WEMPF,
        LINE  TYPE ZSPR_LINE,
        FILM  TYPE ZZFILM,
        TGL   TYPE DATS,
        MBLNR LIKE MSEG-MBLNR,
        MJAHR LIKE MSEG-MJAHR,
        SMBLN LIKE MSEG-SMBLN,
        ABLAD TYPE MSEG-ABLAD,
        SGTXT TYPE MSEG-SGTXT,
        BKTXT TYPE MKPF-BKTXT,
        GRUND TYPE MSEG-GRUND,
    VTERMINAL TYPE C LENGTH 30,
      END OF IT_DISPLAY.

DATA: IT_DISPLAY2 LIKE IT_DISPLAY OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS: <FS_DISPLAY2> LIKE LINE OF IT_DISPLAY2.

TYPES: BEGIN OF TYPE_CHAR,
     VALUE_CHAR TYPE ATWRT,
     DESCRIPTION TYPE ATWTB,
END OF TYPE_CHAR.

DATA ITAB_CHAR TYPE STANDARD TABLE OF TYPE_CHAR WITH HEADER LINE.
DATA IT_RETVAL TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.
DATA IT_VALS TYPE TABLE OF BAPICHARACTVALUESDESCR WITH HEADER LINE.
DATA D_RETVAL TYPE STANDARD TABLE OF BAPIRET2 WITH HEADER LINE.

TYPE-POOLS: SLIS.
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
      G_END_OF_LIST TYPE SLIS_FORMNAME VALUE 'END_OF_LIST',
      DBTYPE TYPE DBCON_DBMS..

DATA : GS_VARIANT LIKE DISVARIANT, G_SAVE.


SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS :   ZAUFNR FOR MSEG-AUFNR,
                   ZPOSDT FOR MKPF-BUDAT DEFAULT SY-DATUM,
                   ZBWART FOR MSEG-BWART,
                   ZUSNAM FOR MSEG-USNAM_MKPF NO INTERVALS NO-EXTENSION,
                   ZMATNR FOR MSEG-MATNR,
                   ZPLANT FOR MSEG-WERKS,
                   ZLGORT FOR MSEG-LGORT,
                   ZWEMPF FOR MSEG-WEMPF NO INTERVALS,
                   ZMBLNR FOR MSEG-MBLNR,
                   ZMJAHR FOR MSEG-MJAHR,
                   ZFILM  FOR ZERROR_LOG-FILM NO INTERVALS NO-EXTENSION,
                   ZLINE  FOR ZERROR_LOG-LINE NO INTERVALS NO-EXTENSION.

SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: S_CONN LIKE MSEG-SGTXT   MODIF ID CON.
SELECTION-SCREEN END OF BLOCK BLOCK2.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
PARAMETERS : RB1 TYPE C RADIOBUTTON GROUP A USER-COMMAND AC DEFAULT 'X',
             RB2 TYPE C RADIOBUTTON GROUP A.
SELECTION-SCREEN END OF BLOCK BLOCK3.

*--- Bagus 8 jan 13
AT SELECTION-SCREEN OUTPUT.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'RB2'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

   IF RB1 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'CON'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF RB2 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'CON'.
        SCREEN-INPUT = 1.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
**  ---------------  ***

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZBWART-LOW.
  PERFORM GET_BWART.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZBWART-HIGH.
  PERFORM GET_BWART.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZFILM-LOW.
  PERFORM GET_FILM.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZLINE-LOW.
  PERFORM GET_LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZWEMPF-LOW.
  PERFORM GET_ZWEMPF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR ZLGORT-LOW.
  PERFORM GET_SO_LGORT.

INITIALIZATION.
  G_REPID = SY-REPID. "call report id
  Y_PRINT-NO_PRINT_SELINFOS = 'X'.
  Y_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT USING GS_LAYOUT. "call ALV layout for report by gs_layout
*  perform eventtab_build using gt_events[]. "NEW COMPANY
  GS_VARIANT-REPORT = G_REPID.
  G_SAVE = 'A'.

START-OF-SELECTION.
  IF ZPOSDT[] IS INITIAL.
    MESSAGE 'Masukan parameter posting date...!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF ZPLANT[] IS INITIAL.
    MESSAGE 'Masukan parameter plant...!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF RB2 = 'X' .
    IF S_CONN IS INITIAL.
      MESSAGE 'Masukan DBCO Connection name...!' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      SELECT SINGLE DBMS FROM DBCON INTO DBTYPE WHERE CON_NAME = S_CONN.
      IF SY-SUBRC NE 0.
        MESSAGE 'DBCO Connection not found..!!' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.

  PERFORM GET_DETAIL.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY.
*tambahan untuk ALV
  PERFORM BUILD_FIELDCATALOG.
*perform comment_build using gt_list_top_of_page[]. "NEW COMPANY

**call function that construct our ALV Report
** Function Grid ALV

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = G_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
      IS_PRINT                 = Y_PRINT
      I_SAVE                   = G_SAVE
      IS_VARIANT               = GS_VARIANT
      IT_EVENTS                = GT_EVENTS[]
    TABLES
      T_OUTTAB                 = IT_DISPLAY2
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
*  message 'Sorry, Report cannot be generated' type i.
  ENDIF.

ENDFORM.                    "DISPLAY

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN  'PRINT'.
      UNASSIGN <FS_DISPLAY2>.
      READ TABLE IT_DISPLAY2 ASSIGNING <FS_DISPLAY2> INDEX FU_SELFIELD-TABINDEX.
      IF SY-SUBRC = 0.
        SUBMIT ZMMF_SCARP WITH MBLNR = <FS_DISPLAY2>-MBLNR
                          WITH MJAHR = <FS_DISPLAY2>-MJAHR
                          AND RETURN.
      ENDIF.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

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
*
  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'VTERMINAL'.
  XFIELDCAT-SELTEXT_M = 'Terminal'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'MATNR'.
  XFIELDCAT-SELTEXT_M = 'Material Number'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.
*
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
  XFIELDCAT-FIELDNAME = 'MBLNR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Material Doc.'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'SMBLN'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Reference Mat Doc.'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'MJAHR'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Year'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'GRUND'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Asal'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'LINE'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Line'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME = 'FILM'.
*  xfieldcat-tabname = 'it_details'.
*  xfieldcat-row_pos = 1.
  XFIELDCAT-COL_POS = N.
  XFIELDCAT-SELTEXT_M = 'Film'.
  XFIELDCAT-OUTPUTLEN = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

ENDFORM. "build_fieldcatalog

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

  CLEAR LS_LINE.
  REFRESH LT_TOP_OF_PAGE.
  LS_LINE-TYP = 'H'.
  LS_LINE-INFO = 'PT.Trias Sentosa, Tbk.'.
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
*&      Form  GET_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DETAIL.

  IF ZBWART-LOW EQ ' ' AND ZBWART-HIGH EQ ' '.

    SELECT MSEG~AUFNR MSEG~MATNR MSEG~BWART MKPF~BUDAT MKPF~BLDAT MKPF~CPUDT MKPF~CPUTM MKPF~BKTXT MSEG~WERKS
           MSEG~LGORT MSEG~MENGE MSEG~MEINS MSEG~WEMPF MSEG~ABLAD MSEG~MBLNR MSEG~MJAHR MSEG~SMBLN MSEG~SGTXT
           MSEG~GRUND
     INTO CORRESPONDING FIELDS OF TABLE IT_DISPLAY
     FROM MSEG
     JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
     JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
    WHERE MSEG~AUFNR IN ZAUFNR
    AND   MSEG~BUDAT_MKPF IN ZPOSDT
    AND   MSEG~BWART IN ('101', '102', '261', '262')
*   AND   MSEG~USNAM_MKPF IN ZUSNAM
    AND   MSEG~MATNR IN ZMATNR
    AND   MSEG~WERKS IN ZPLANT
    AND   MSEG~LGORT IN ZLGORT
    AND   MSEG~WEMPF IN ZWEMPF
    AND   MSEG~MBLNR IN ZMBLNR
    AND   MSEG~MJAHR IN ZMJAHR
    AND   AUFK~AUART IN ('ZR01', 'ZR02').

    IF ZUSNAM IS NOT INITIAL.
      LOOP AT IT_DISPLAY WHERE BKTXT+12(13) = ZUSNAM-LOW.
        IT_DISPLAY-USNAM = IT_DISPLAY-BKTXT+12(13).
*       IT_DISPLAY-FILM = IT_DISPLAY-SGTXT+0(3).
*       IT_DISPLAY-LINE = IT_DISPLAY-SGTXT+4(1).
*       IT_DISPLAY-VTERMINAL = IT_DISPLAY-SGTXT+6(30).
        SPLIT IT_DISPLAY-SGTXT AT '/' INTO IT_DISPLAY-FILM IT_DISPLAY-LINE IT_DISPLAY-VTERMINAL. " add new company
        APPEND IT_DISPLAY TO IT_DISPLAY2.
      ENDLOOP.
    ELSE.
      LOOP AT IT_DISPLAY.
        IT_DISPLAY-USNAM = IT_DISPLAY-BKTXT+12(13).
*       IT_DISPLAY-FILM = IT_DISPLAY-SGTXT+0(3).
*       IT_DISPLAY-LINE = IT_DISPLAY-SGTXT+4(1).
*       IT_DISPLAY-VTERMINAL = IT_DISPLAY-SGTXT+6(30).
        SPLIT IT_DISPLAY-SGTXT AT '/' INTO IT_DISPLAY-FILM IT_DISPLAY-LINE IT_DISPLAY-VTERMINAL. " add new company
        APPEND IT_DISPLAY TO IT_DISPLAY2.
      ENDLOOP.
    ENDIF.

    IF ZFILM-LOW IS NOT INITIAL AND ZLINE-LOW IS INITIAL.
      LOOP AT IT_DISPLAY2 WHERE FILM NE ZFILM-LOW.
        DELETE IT_DISPLAY2.
      ENDLOOP.
    ELSEIF ZFILM-LOW IS INITIAL AND ZLINE-LOW IS NOT INITIAL.
      LOOP AT IT_DISPLAY2 WHERE LINE NE ZLINE-LOW.
        DELETE IT_DISPLAY2.
      ENDLOOP.
    ELSEIF ZFILM-LOW IS NOT INITIAL AND ZLINE-LOW IS NOT INITIAL.
      LOOP AT IT_DISPLAY2 WHERE FILM NE ZFILM-LOW AND LINE NE ZLINE-LOW.
        DELETE IT_DISPLAY2.
      ENDLOOP.
    ENDIF.

    PERFORM SCREEN_OR_OLAPS.
    PERFORM DISPLAY.

  ELSEIF ZBWART-LOW EQ '101'  OR ZBWART-LOW EQ '102' OR ZBWART-LOW EQ '261' OR ZBWART-LOW EQ '262' OR ZBWART-LOW EQ ' '.
    IF ZBWART-HIGH EQ '101' OR ZBWART-HIGH EQ '102' OR ZBWART-HIGH EQ'261' OR ZBWART-HIGH EQ '262' OR ZBWART-HIGH EQ ' '.

      SELECT MSEG~AUFNR MSEG~MATNR MSEG~BWART MKPF~BUDAT MKPF~BLDAT MKPF~CPUDT MKPF~CPUTM MKPF~BKTXT MSEG~WERKS
             MSEG~LGORT MSEG~MENGE MSEG~MEINS MSEG~WEMPF MSEG~ABLAD MSEG~MBLNR MSEG~MJAHR MSEG~SMBLN MSEG~SGTXT
             MSEG~GRUND
       INTO CORRESPONDING FIELDS OF TABLE IT_DISPLAY
       FROM MSEG
       JOIN MKPF ON MKPF~MBLNR = MSEG~MBLNR
       JOIN AUFK ON AUFK~AUFNR = MSEG~AUFNR
      WHERE MSEG~AUFNR IN ZAUFNR
      AND   MSEG~BUDAT_MKPF IN ZPOSDT
      AND   MSEG~BWART IN ZBWART
*   AND   MSEG~USNAM_MKPF IN ZUSNAM
      AND   MSEG~MATNR IN ZMATNR
      AND   MSEG~WERKS IN ZPLANT
      AND   MSEG~LGORT IN ZLGORT
      AND   MSEG~WEMPF IN ZWEMPF
      AND   MSEG~MBLNR IN ZMBLNR
      AND   MSEG~MJAHR IN ZMJAHR
      AND   AUFK~AUART IN ('ZR01', 'ZR02').

      IF ZUSNAM IS NOT INITIAL.
        LOOP AT IT_DISPLAY WHERE BKTXT+12(13) = ZUSNAM-LOW.
          IT_DISPLAY-USNAM = IT_DISPLAY-BKTXT+12(13).
          IT_DISPLAY-FILM = IT_DISPLAY-SGTXT+0(3).
          IT_DISPLAY-LINE = IT_DISPLAY-SGTXT+4(1).
          IT_DISPLAY-VTERMINAL = IT_DISPLAY-SGTXT+6(30).
          APPEND IT_DISPLAY TO IT_DISPLAY2.
        ENDLOOP.
      ELSE.
        LOOP AT IT_DISPLAY.
          IT_DISPLAY-USNAM = IT_DISPLAY-BKTXT+12(13).
          IT_DISPLAY-FILM = IT_DISPLAY-SGTXT+0(3).
          IT_DISPLAY-LINE = IT_DISPLAY-SGTXT+4(1).
          IT_DISPLAY-VTERMINAL = IT_DISPLAY-SGTXT+6(30).
          APPEND IT_DISPLAY TO IT_DISPLAY2.
        ENDLOOP.
      ENDIF.

      IF ZFILM-LOW IS NOT INITIAL AND ZLINE-LOW IS INITIAL.
        LOOP AT IT_DISPLAY2 WHERE FILM NE ZFILM-LOW.
          DELETE IT_DISPLAY2.
        ENDLOOP.
      ELSEIF ZFILM-LOW IS INITIAL AND ZLINE-LOW IS NOT INITIAL.
        LOOP AT IT_DISPLAY2 WHERE LINE NE ZLINE-LOW.
          DELETE IT_DISPLAY2.
        ENDLOOP.
      ELSEIF ZFILM-LOW IS NOT INITIAL AND ZLINE-LOW IS NOT INITIAL.
        LOOP AT IT_DISPLAY2 WHERE FILM NE ZFILM-LOW AND LINE NE ZLINE-LOW.
          DELETE IT_DISPLAY2.
        ENDLOOP.
      ENDIF.

      PERFORM SCREEN_OR_OLAPS.

      IF RB2 NE 'X'.
        PERFORM DISPLAY.
      ENDIF.
    ELSE.

      MESSAGE 'Please Input Movement Type 101, 102, 261, 262' TYPE 'S'.

    ENDIF.
  ELSE.

    MESSAGE 'Please Input Movement Type 101, 102, 261, 262' TYPE 'S'.

  ENDIF.

ENDFORM.                    "GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  SCREEN_OR_OLAPS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SCREEN_OR_OLAPS.

  IF RB2 EQ 'X'.
    AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
    IF SY-SUBRC NE 0.
      MESSAGE I000(0K) WITH 'No Authorization to process data OLAP'.
      RETURN.
    ENDIF.

   EXEC SQL.
    SET CONNECTION :S_CONN
   ENDEXEC.

    EXEC SQL.
      CONNECT TO :S_CONN
    ENDEXEC.

    EXEC SQL.
      DELETE FROM XMP_PP_RECYCLE
    ENDEXEC.

    LOOP AT IT_DISPLAY2.
      EXEC SQL.

        INSERT INTO XMP_PP_RECYCLE(COL001,COL002,COL003,COL004,COL005,COL006,COL007,COL008,COL009,COL010,COL011,COL012
                            ,COL013,COL014,COL015,COL016,COL017,COL018,COL019,COL020)
        VALUES(:IT_DISPLAY2-AUFNR,:IT_DISPLAY2-BUDAT,:IT_DISPLAY2-BLDAT,:IT_DISPLAY2-BWART,:IT_DISPLAY2-CPUDT,:IT_DISPLAY2-CPUTM,:IT_DISPLAY2-USNAM,:IT_DISPLAY2-VTERMINAL,:IT_DISPLAY2-MATNR,:IT_DISPLAY2-WERKS,:IT_DISPLAY2-LGORT,
               :IT_DISPLAY2-MENGE,:IT_DISPLAY2-MEINS,:IT_DISPLAY2-WEMPF,:IT_DISPLAY2-MBLNR,:IT_DISPLAY2-SMBLN,:IT_DISPLAY2-MJAHR,:IT_DISPLAY2-GRUND,:IT_DISPLAY2-LINE,:IT_DISPLAY2-FILM)
      ENDEXEC.
    ENDLOOP.

    MESSAGE 'Penyimpanan Data ke SQL sukses!!!' TYPE 'I'.

  ENDIF.

ENDFORM.                    "SCREEN_OR_OLAPS

*&---------------------------------------------------------------------*
*&      Form  GET_BWART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_BWART.
  DATA: BEGIN OF IT_DETAIL OCCURS 0,
          BWART TYPE MSEG-BWART,
          DESC  TYPE MAKT-MAKTX,
        END OF IT_DETAIL.

  IT_DETAIL-BWART = '101'.
  IT_DETAIL-DESC  = 'GR Goods Receipt'.
  APPEND IT_DETAIL.
  IT_DETAIL-BWART = '102'.
  IT_DETAIL-DESC  = 'GR for PO Reversal'.
  APPEND IT_DETAIL.
  IT_DETAIL-BWART = '261'.
  IT_DETAIL-DESC  = 'GR for Order'.
  APPEND IT_DETAIL.
  IT_DETAIL-BWART = '262'.
  IT_DETAIL-DESC  = 'RE for Order'.
  APPEND IT_DETAIL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'BWART'
      WINDOW_TITLE = 'MvT Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = SY-REPID
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'BWART'
    TABLES
      VALUE_TAB    = IT_DETAIL.

ENDFORM.                    "GET_BWART

*&---------------------------------------------------------------------*
*&      Form  GET_FILM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FILM.
  CLEAR: IT_VALS, D_RETVAL, ITAB_CHAR, IT_RETVAL.
  REFRESH: IT_VALS, D_RETVAL, ITAB_CHAR, IT_RETVAL.


  CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      CHARACTNAME        = 'ZZCODE'
    TABLES
      CHARACTVALUESDESCR = IT_VALS
      RETURN             = D_RETVAL.

  LOOP AT IT_VALS.
    MOVE-CORRESPONDING IT_VALS TO ITAB_CHAR.
    APPEND ITAB_CHAR.
  ENDLOOP.

  SORT ITAB_CHAR.

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


ENDFORM.                    "GET_FILM


*&---------------------------------------------------------------------*
*&      Form  GET_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LINE.
  CLEAR: IT_VALS, D_RETVAL, ITAB_CHAR, IT_RETVAL.
  REFRESH: IT_VALS, D_RETVAL, ITAB_CHAR, IT_RETVAL.

  CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      CHARACTNAME        = 'ZZPRODLINE'
    TABLES
      CHARACTVALUESDESCR = IT_VALS
      RETURN             = D_RETVAL.

  LOOP AT IT_VALS.
    MOVE-CORRESPONDING IT_VALS TO ITAB_CHAR.
    APPEND ITAB_CHAR.
  ENDLOOP.

  SORT ITAB_CHAR.

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



ENDFORM.                    "GET_LINE

*&---------------------------------------------------------------------*
*&      Form  GET_ZWEMPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ZWEMPF.

  DATA: BEGIN OF IT_DETAIL2 OCCURS 0,
            WERKS TYPE CRHD-WERKS,
            ARBPL TYPE CRHD-ARBPL,
        END OF IT_DETAIL2.

  DATA: DYNFIELDS TYPE TABLE OF DYNPREAD WITH HEADER LINE.

  DYNFIELDS-FIELDNAME = 'ZPLANT-LOW'.
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


  READ TABLE DYNFIELDS WITH KEY FIELDNAME = 'ZPLANT-LOW'.
  ZPLANT-LOW = DYNFIELDS-FIELDVALUE.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
    FROM ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = ZPLANT-LOW.

  SORT IT_DETAIL2 BY WERKS ARBPL.
  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ARBPL'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = SY-REPID
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ARBPL'
    TABLES
      VALUE_TAB    = IT_DETAIL2.

ENDFORM.                    "GET_ZWEMPF

*&---------------------------------------------------------------------*
*&      Form  GET_SO_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SO_LGORT.

  DATA: BEGIN OF IT_DETAIL OCCURS 0,
            WERKS TYPE CRHD-WERKS,
            ARBPL TYPE CRHD-ARBPL,
            LGORT TYPE LGORT_D,
*          ZRRLGORT TYPE LGORT_D,
        END OF IT_DETAIL.

  DATA: DYNFIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE,
        IT_DETAIL2 LIKE IT_DETAIL OCCURS 0 WITH HEADER LINE.

  DYNFIELDS-FIELDNAME = 'ZPLANT-LOW'.
  APPEND DYNFIELDS.
  DYNFIELDS-FIELDNAME = 'ZWEMPF-LOW'.
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

  READ TABLE DYNFIELDS WITH KEY FIELDNAME = 'ZPLANT-LOW'.
  ZPLANT-LOW = DYNFIELDS-FIELDVALUE.
  READ TABLE DYNFIELDS WITH KEY FIELDNAME = 'ZWEMPF-LOW'.
  ZWEMPF-LOW = DYNFIELDS-FIELDVALUE.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~LGORT_RCYL AS LGORT
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL
    FROM  ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = ZPLANT-LOW.
*       AND   ZTMAP_SLOCREC~ARBPL = ZWEMPF-LOW.

  SELECT ZTMAP_SLOCREC~WERKS ZTMAP_SLOCREC~ARBPL ZTMAP_SLOCREC~ZRRLGORT AS LGORT
    INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL2
    FROM  ZTMAP_SLOCREC
    WHERE ZTMAP_SLOCREC~WERKS = ZPLANT-LOW.

  APPEND LINES OF IT_DETAIL TO IT_DETAIL2.

  SORT IT_DETAIL2 BY WERKS ARBPL LGORT.
  DELETE ADJACENT DUPLICATES FROM IT_DETAIL2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'ZRRLGORT'
      WINDOW_TITLE = 'Resource Help List'
      VALUE_ORG    = 'S'
      DYNPPROG     = SY-REPID
      DYNPNR       = SY-DYNNR
      DYNPROFIELD  = 'ZRRLGORT'
    TABLES
      VALUE_TAB    = IT_DETAIL2.

ENDFORM.                    "GET_SO_LGORT