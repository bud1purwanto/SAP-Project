*&---------------------------------------------------------------------*
*& Report  ZMMR_TRS_PLT_DV
*&
*&  Appl. Area :  MM                                                   *
*&  Created by :  Fadila                                               *
*&  Created on :  14 May 2025                                          *
*&---------------------------------------------------------------------*

REPORT  ZMMR_TRS_PLT_DV.
INCLUDE ZMM_GRN_PO_CKI_GET_CHAR_VAL.

TYPE-POOLS: SLIS.

DATA : FNAME TYPE STRING.
DATA: L_TA_MSG TYPE STANDARD TABLE OF BDCMSGCOLL WITH HEADER LINE.
DATA: COUNT TYPE I.
DATA: ROWS(50) TYPE C.

DATA: BEGIN OF IT_PALLET OCCURS 0,
        PALID(100),               "Pallet ID
        SLOCT    LIKE MCHB-LGORT, "SLOC TUJUAN
        SLOCA    LIKE MCHB-LGORT, "SLOC AWAL
        WERKS    LIKE MCHB-WERKS,  "PLANT
        MATDOC   TYPE MBLNR, "MATDOC NO.
        MATYEAR  TYPE MJAHR, "MATDOC YEAR.
        MARK(1)  TYPE C,
        KET      TYPE STRING,
        ICON(4)     TYPE C,
        STATUS(10)  TYPE C,
      END OF IT_PALLET.

DATA: BDC_DATA LIKE BDCDATA OCCURS 1000 WITH HEADER LINE,
      WA_L_TA_MSG LIKE BDCMSGCOLL,
      CHAR_OF_BATCH LIKE CLBATCH OCCURS 0 WITH HEADER LINE,
      IT_CHAR LIKE BAPI1003_ALLOC_VALUES_CHAR OCCURS 0 WITH HEADER LINE,
      IT_CHAR2 LIKE BAPI1003_ALLOC_VALUES_CHAR OCCURS 0 WITH HEADER LINE,
      IT_NUM     LIKE BAPI1003_ALLOC_VALUES_NUM  OCCURS 0 WITH HEADER LINE,
      IT_CURR    LIKE BAPI1003_ALLOC_VALUES_CURR OCCURS 0 WITH HEADER LINE,
      IT_RETURN2 LIKE BAPIRET2 OCCURS 0 WITH HEADER LINE.

DATA: MTHEAD LIKE BAPI2017_GM_HEAD_RET OCCURS 0 WITH HEADER LINE,
      GMHEAD LIKE BAPI2017_GM_HEAD_01 OCCURS 0 WITH HEADER LINE,
      GMCODE LIKE BAPI2017_GM_CODE OCCURS 0 WITH HEADER LINE,
      GMITEM LIKE BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE.

DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      IT_LAYOUT TYPE SLIS_LAYOUT_ALV,
      T_SORT TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.

DATA : MODE(1) TYPE C VALUE 'N',
       UPDATE(1) TYPE C VALUE 'S',
       V_PROGRESS_TXT TYPE STRING,
       V_PROGRESS TYPE I VALUE 0,
       V_COUNT_TXT TYPE STRING,
       V_COUNT TYPE I,
       V_TEXT TYPE STRING,
       ZDATUM(10) TYPE C,
       TEMP_MSG(132) TYPE C,
       V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZMMR_TRS_PLT_DV'.

DATA: VCLASS LIKE KLAH-CLASS,
      VKLART LIKE KLAH-KLART,
      VOBTAB LIKE TCLT-OBTAB,
      VOBJEC LIKE KSSK-OBJEK.

*Added by Dila on 10.07.2025 adanya tambahan no roll ketika GRN
DATA: V_MATGROUP LIKE EKPO-MATKL,
      V_LINE LIKE ZSEQNUM-ARBPL,
      V_LINENEW LIKE ZSEQNUM-ARBPL,
      V_GRADE LIKE CAWNT-ATWTB,
      V_TURUNAN LIKE CAWNT-ATWTB,
      V_MONYEAR LIKE CAWNT-ATWTB,
      DMON TYPE ZSEQNUM-ZMONTH,
      RMON TYPE ZSEQNUM-ZMONTH,
      CSEQ TYPE N LENGTH 3,
      CSEQN TYPE N LENGTH 4,
      DSEQ TYPE I,
      V_NOROLL TYPE CAWNT-ATWTB,
      V_NOLOT TYPE MSEG-CHARG,
      V_MATNR TYPE MARA-MATNR.

DATA : BEGIN OF ZZSEQNUM,
         ARBPL LIKE ZSEQNUM-ARBPL,
         ZMONTH LIKE ZSEQNUM-ZMONTH,
         ZSEQNO LIKE ZSEQNUM-ZSEQNO,
       END OF ZZSEQNUM.
*Added by Dila on 10.07.2025 adanya tambahan no roll ketika GRN

"-- ADDED FOR AGS BY FATHIR ON 20.11.2019  - Create internal table to contain GR Matdoc and Batch
DATA: BEGIN OF IT_AGSGRN OCCURS 0,
        MBLNR LIKE MKPF-MBLNR,
        CHARG LIKE MCH1-CHARG,
       END OF IT_AGSGRN.
DATA: IT_AGSPARAM LIKE STANDARD TABLE OF IT_AGSGRN.
"-- ADDED FOR AGS BY FATHIR ON 20.11.2019  - Create internal table to contain GR Matdoc and Batch

DATA : BEGIN OF LMSG OCCURS 0,
          MSGID  LIKE SY-MSGID,
          MSGTY  LIKE SY-MSGTY,
          MSGNO  LIKE SY-MSGNO,
          MSGV1  LIKE SY-MSGV1,
          MSGV2  LIKE SY-MSGV2,
          MSGV3  LIKE SY-MSGV3,
          MSGV4  LIKE SY-MSGV4,
          LINENO TYPE MESG-ZEILE,
        END OF LMSG.

DEFINE BDC_DYNPRO.
  CLEAR &1.
  &1-PROGRAM = &2.
  &1-DYNPRO = &3.
  &1-DYNBEGIN = 'X'.
  APPEND &1.
END-OF-DEFINITION.

DEFINE BDC_FIELD.
  CLEAR &1.
  &1-FNAM = &2.
  &1-FVAL = &3.
  APPEND &1.
END-OF-DEFINITION.


SELECTION-SCREEN BEGIN OF BLOCK B1000 WITH FRAME TITLE TEXT-100..
PARAMETERS: P_FILE   LIKE RLGRAP-FILENAME
                     OBLIGATORY
                     DEFAULT 'C:/'.
SELECTION-SCREEN END OF BLOCK B1000.

*SELECTION-SCREEN BEGIN OF BLOCK BL003 WITH FRAME TITLE TEXT-200.
*PARAMETERS: RB1 RADIOBUTTON GROUP RG1,
*            RB2 RADIOBUTTON GROUP RG1.
*SELECTION-SCREEN END OF BLOCK BL003.

SELECTION-SCREEN BEGIN OF BLOCK B1002 WITH FRAME.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.
SELECTION-SCREEN END OF BLOCK B1002.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_OPEN_FILE.

*&---------------------------------------------------------------------*
*&      Form  F4_OPEN_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_OPEN_FILE .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = P_FILE.
  IF SY-SUBRC <> 0 OR P_FILE EQ ''.

    MESSAGE 'Please insert the template' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ENDIF.
ENDFORM.                    "F4_OPEN_FILE

START-OF-SELECTION.
  PERFORM GET_DATA.
*  PERFORM VALIDATE_DATA.

  IF IT_PALLET[] IS NOT INITIAL.
    PERFORM INSERT_DATA.
    PERFORM DISPLAY_DATA.
  ELSE.
    MESSAGE 'Tidak ada data yang di-upload!' TYPE 'I'.
  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO ZDATUM SEPARATED BY '.'.

*  IF RB1 EQ 'X'.
  MOVE P_FILE TO FNAME.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                = FNAME
      HAS_FIELD_SEPARATOR     = 'X' "FILL : READ BY TAB, NO FILL : READ BY SPACE
      READ_BY_LINE            = 'X' "FILL : READ  PER ROW, NO FILL : READ PER COLUMN"
    TABLES
      DATA_TAB                = IT_PALLET
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      OTHERS                  = 17.

  IF SY-SUBRC <> 0.
*    MOVE-CORRESPONDING IT_DATA2 TO IT_DATA.
  ENDIF.
ENDFORM.                    "GET_DATA


*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_DATA.
  " Added by William at 19.02.2026 (move pallet RTP)
  DATA: IT_ZPALLETR LIKE ZPALLETR OCCURS 0 WITH HEADER LINE.
  DATA: IT_MAP_PALLET LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
  DATA: IT_ERROR_PALLET LIKE ITAB OCCURS 0 WITH HEADER LINE.
  DATA: V_PALID LIKE MCHB-CHARG.
  DATA: V_PALID_TXT(100).
  DATA: V_WERKS LIKE MCHB-WERKS.
  DATA: V_LGORT LIKE MCHB-LGORT.
  DATA: V_MATNR LIKE MARA-MATNR.
  DATA: V_MEINS LIKE MARA-MEINS.

*  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP_PALLET
*    FROM ZMAP_TYPE
*    WHERE DELETION NE 'X'
*    AND TCODE = 'ZVLMOVE1'
*    AND TYPE = 'PALLET'
*    AND OPT = 'MOVE_STLOC'.

  " Delete empty data
  LOOP AT IT_PALLET.
    IF IT_PALLET-PALID IS INITIAL.
      DELETE IT_PALLET.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE IT_PALLET LINES V_COUNT.
  V_COUNT_TXT = V_COUNT.

  LOOP AT IT_PALLET.
    ADD 1 TO V_PROGRESS .
    V_PROGRESS_TXT = V_PROGRESS.
    CONCATENATE 'PROCESSING MOVE PALLET:' V_PROGRESS_TXT 'OF' V_COUNT_TXT INTO V_TEXT SEPARATED BY SPACE.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PROGRESS
        TEXT       = V_TEXT.

*    CLEAR: IT_DISPLAY.
*    MOVE-CORRESPONDING IT_DATA TO IT_DISPLAY.

    " For Pallet ID must max 10 digits
    CLEAR: V_PALID_TXT.
    V_PALID_TXT = IT_PALLET-PALID.
    CONDENSE V_PALID_TXT NO-GAPS.
    IF STRLEN( V_PALID_TXT ) > 10.
      IT_PALLET-KET = 'Error, digit maksimum pallet ID adalah 10 digit'.
      IT_PALLET-ICON = ICON_RED_LIGHT.
      IT_PALLET-STATUS = 'FAILED'.
      MODIFY IT_PALLET.

      CLEAR: IT_ZPALLETR.
      REFRESH: IT_ZPALLETR.
      CONTINUE.
    ENDIF.

    CLEAR: IT_ZPALLETR, V_PALID, V_WERKS, V_LGORT, V_MATNR, V_MEINS.
    REFRESH: IT_ZPALLETR.

    SELECT SINGLE A~CHARG A~WERKS A~LGORT B~MATNR B~MEINS INTO (V_PALID, V_WERKS, V_LGORT, V_MATNR, V_MEINS)
      FROM MCHB AS A JOIN MARA AS B ON A~MATNR = B~MATNR
      WHERE A~CHARG = IT_PALLET-PALID AND B~MTART = 'ZRTP' AND
            B~MATKL IN ('900001','900002','900003') AND A~CLABS > 0.

    IF SY-SUBRC NE 0.
      " Cek apakah ada record di ZPALLETR
      SELECT * UP TO 1 ROWS INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
        FROM ZPALLETR
        WHERE PALID = IT_PALLET-PALID
        ORDER BY DOCNO DESCENDING.

      IF IT_ZPALLETR[] IS INITIAL.
        " Batch memang tidak ada/belum pernah di-maintain
        IT_PALLET-KET = 'Error, pallet tidak ditemukan'.
        IT_PALLET-ICON = ICON_RED_LIGHT.
        IT_PALLET-STATUS = 'FAILED'.
        MODIFY IT_PALLET.

        CLEAR: IT_ZPALLETR.
        REFRESH: IT_ZPALLETR.
        CONTINUE.
      ENDIF.

      CLEAR: IT_ZPALLETR.
      REFRESH: IT_ZPALLETR.
    ENDIF.

    IT_PALLET-WERKS = V_WERKS.
    IT_PALLET-SLOCA = V_LGORT.

    " Get data ZPALLETR
    SELECT * UP TO 1 ROWS INTO CORRESPONDING FIELDS OF TABLE IT_ZPALLETR
      FROM ZPALLETR
      WHERE PALID = V_PALID
      ORDER BY DOCNO DESCENDING.

    " Validasi 1
    " 1. Cek status pallet, harus dalam keadaan free/new atau complete
    " 1a. Cek apakah ada data pallet di ZPALLETR? Kalau gak ada berarti free/new
    " 1b. Jika ada, pastikan status terakhir antara L atau C
    " 1c. Selain itu, error sesuai status

    IF IT_ZPALLETR[] IS NOT INITIAL.
      READ TABLE IT_ZPALLETR INDEX 1.
      IF IT_ZPALLETR-STATUS NE 'L' AND IT_ZPALLETR-STATUS NE 'C'.
        IF IT_ZPALLETR-STATUS EQ 'P'.
          IT_PALLET-KET = 'Error, pallet masih digunakan untuk packing'.
        ELSEIF IT_ZPALLETR-STATUS EQ 'E'.
          IT_PALLET-KET = 'Error, pallet masih di customer'.
        ENDIF.
        IT_PALLET-ICON = ICON_RED_LIGHT.
        IT_PALLET-STATUS = 'FAILED'.
        MODIFY IT_PALLET.

        CLEAR: IT_ZPALLETR.
        REFRESH: IT_ZPALLETR.
        CONTINUE.
      ENDIF.
    ENDIF.

    " Validasi 2
    " 2. Aturan Sloc tujuan
    " 2a. Pallet jika berasal dari plant 1000, maka tujuannya adalah ke 1815
    " 2b. Pallet jika berasal dari plant 2000, maka tujuannya adalah ke 2815
    " 2c. Selain itu, pallet tidak bisa dipindah karena harus di area plant TRIAS
    " 2d. Asal pallet dan tujuan pallet tidak boleh sama

    IF V_WERKS = '1000'.
      IT_PALLET-SLOCT = '1815'. " Gudang RPMS Waru
    ELSEIF V_WERKS = '2000'.
      IT_PALLET-SLOCT = '2815'. " Gudang RPMS Krian
    ELSE.
      " Batch harus di area plant TRIAS
      IT_PALLET-KET = 'Error, pallet harus berada di area plant TRIAS'.
      IT_PALLET-ICON = ICON_RED_LIGHT.
      IT_PALLET-STATUS = 'FAILED'.
      MODIFY IT_PALLET.

      CLEAR: IT_ZPALLETR.
      REFRESH: IT_ZPALLETR.
      CONTINUE.
    ENDIF.

    IF IT_PALLET-SLOCA = IT_PALLET-SLOCT.
      " Asal dan tujuan pallet harus beda
      IT_PALLET-KET = 'Error, pallet sudah di Gudang RPMS'.
      IT_PALLET-ICON = ICON_RED_LIGHT.
      IT_PALLET-STATUS = 'FAILED'.
      MODIFY IT_PALLET.

      CLEAR: IT_ZPALLETR.
      REFRESH: IT_ZPALLETR.
      CONTINUE.
    ENDIF.

    " Validasi 3
    " 3. Sloc asal 1212 tidak diperbolehkan, karena artinya pallet masih di customer
    IF IT_PALLET-SLOCA = '1212'.
      IT_PALLET-KET = 'Error, pallet masih di customer'.
      IT_PALLET-ICON = ICON_RED_LIGHT.
      IT_PALLET-STATUS = 'FAILED'.
      MODIFY IT_PALLET.

      CLEAR: IT_ZPALLETR.
      REFRESH: IT_ZPALLETR.
      CONTINUE.
    ENDIF.

    CLEAR: MTHEAD, GMHEAD, GMCODE, GMITEM, IT_RETURN2.
    REFRESH: MTHEAD, GMHEAD, GMCODE, GMITEM, IT_RETURN2.

    " For Header and Code
    GMHEAD-PSTNG_DATE     = SY-DATUM.
    GMHEAD-DOC_DATE       = SY-DATUM.
    GMHEAD-PR_UNAME       = SY-UNAME.
    APPEND GMHEAD.
    GMCODE-GM_CODE        = '04'.   "04 - MB1B - Transfer Posting
    APPEND GMCODE.

    " Fill Item
    GMITEM-MOVE_TYPE  = '311'.
    GMITEM-MVT_IND    = ' '.
    GMITEM-PLANT      = IT_PALLET-WERKS.
    GMITEM-STGE_LOC   = IT_PALLET-SLOCA.
    GMITEM-MOVE_PLANT = IT_PALLET-WERKS.
    GMITEM-MOVE_STLOC = IT_PALLET-SLOCT.
    GMITEM-ENTRY_QNT  = '1'.
    GMITEM-MATERIAL   = V_MATNR.
    GMITEM-ENTRY_UOM  = V_MEINS.
    GMITEM-BATCH      = IT_PALLET-PALID.
    APPEND GMITEM.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GMHEAD
        GOODSMVT_CODE    = GMCODE
      IMPORTING
        GOODSMVT_HEADRET = MTHEAD
      TABLES
        GOODSMVT_ITEM    = GMITEM
        RETURN           = IT_RETURN2.

    IF IT_RETURN2[] IS INITIAL.
      COMMIT WORK AND WAIT.

      IT_PALLET-MATDOC = MTHEAD-MAT_DOC.
      IT_PALLET-MATYEAR = MTHEAD-DOC_YEAR.

      IT_PALLET-KET = 'Pallet sukses dipindah'.
      IT_PALLET-ICON = ICON_GREEN_LIGHT.
      IT_PALLET-STATUS = 'SUCCESS'.
      MODIFY IT_PALLET.

      CONTINUE.
    ELSE.
      ROLLBACK WORK.

      READ TABLE IT_RETURN2 WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0.
        IT_PALLET-KET = IT_RETURN2-MESSAGE.
        CONCATENATE 'Error,' IT_PALLET-KET INTO IT_PALLET-KET SEPARATED BY SPACE.

        IT_PALLET-ICON = ICON_RED_LIGHT.
        IT_PALLET-STATUS = 'FAILED'.
      ENDIF.

      MODIFY IT_PALLET.

      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "INSERT_DATA

*&---------------------------------------------------------------------*
*&      Form  VB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VB_INIT .
  CALL FUNCTION 'VB_INIT'
    EXPORTING
      INIT_RESET = 'X'.
ENDFORM.                    "VB_INIT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  DATA : NO TYPE N LENGTH 3 VALUE 1.

*    LIKE ZPALLETR-PALID, "Pallet ID
*        SLOCT    LIKE MCHB-LGORT, "SLOC TUJUAN
*        SLOCA    LIKE MCHB-LGORT, "SLOC AWAL
*        WERKS    LIKE MCHB-WERKS,  "PLANT
*        MATDOC   TYPE MBLNR, "MATDOC NO.
*        MATYEAR  TYPE MJAHR, "MATDOC YEAR.
*        MARK(1)  TYPE C,
*        KET      TYPE STRING,

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'ICON'.
  WA_FIELDCAT-SELTEXT_M = 'Icon'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'PALID'.
  WA_FIELDCAT-SELTEXT_M = 'Pallet ID'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'WERKS'.
  WA_FIELDCAT-SELTEXT_M = 'Plant'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'SLOCA'.
  WA_FIELDCAT-SELTEXT_M = 'Sloc Asal'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'SLOCT'.
  WA_FIELDCAT-SELTEXT_M = 'Sloc Tujuan'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'MATDOC'.
  WA_FIELDCAT-SELTEXT_M = 'Material Document'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.
  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_PALLET'.
  WA_FIELDCAT-FIELDNAME = 'KET'.
  WA_FIELDCAT-SELTEXT_M = 'Keterangan'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.


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
  IT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = IT_LAYOUT
      IT_FIELDCAT   = IT_FIELDCAT
    TABLES
      T_OUTTAB      = IT_PALLET
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.

ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_PROG_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_PROG     text
*----------------------------------------------------------------------*
FORM F_PROG_INFO USING V_PROG LIKE ZPROGINFO-PGMNA.

  DATA: BEGIN OF LINES OCCURS 50.
          INCLUDE STRUCTURE TLINE.
  DATA: END OF LINES.

  DATA: IT_PROG LIKE ZPROGINFO OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF EXCLUDE OCCURS 10,
          FUNC LIKE RSNEWLENG-FCODE,
        END OF EXCLUDE.

  DATA: HINFO LIKE HELP_INFO.

  HINFO-TITLE = 'Program Documentation'.
*  hinfo-docuid = 'DT'.
*  hinfo-DOCUOBJECT = '%_SELSCREEN_1000'.

  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

  EXCLUDE-FUNC = 'DBF4'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DPRB'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

*--- get program documentation
  SELECT * INTO TABLE IT_PROG
  FROM ZPROGINFO
  WHERE PGMNA = V_PROG.

  SORT IT_PROG BY LINE.
  IF SY-SUBRC = 0.
    LOOP AT IT_PROG.
      LINES-TDFORMAT = IT_PROG-TDFORMAT.
      LINES-TDLINE   = IT_PROG-TDLINE.
      APPEND LINES.
    ENDLOOP.
  ELSE.
    LINES-TDFORMAT = 'AS'.
    LINES-TDLINE   = 'Program Untuk Upload Transfer Pallet RTP ke Warehouse/FGS'.
    APPEND LINES.
  ENDIF.

  CALL FUNCTION 'HELP_DOCULINES_SHOW'
    EXPORTING
      CUCOL             = 10
      CUROW             = 3
      HELP_INFOS        = HINFO
      NOT_HELP          = 'X'
      CLASSIC_SAPSCRIPT = 'X'
    TABLES
      EXCLUDEFUN        = EXCLUDE
      HELPLINES         = LINES.

ENDFORM.                    "f_prog_info