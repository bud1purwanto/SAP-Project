*&---------------------------------------------------------------------*
*& Report  ZMMR_UPLOAD_KTNG
*&
*&---------------------------------------------------------------------*
*& Program Report & Maintain Roll KT&G
*&
*&---------------------------------------------------------------------*

REPORT  ZMMR_UPLOAD_KTNG.

TABLES: MSKA.
INCLUDE ZABAPALV.

DATA: BEGIN OF ITAB OCCURS 0,
      VBATCHOLD LIKE MCHB-CHARG,
      VBATCHNEW LIKE MCHB-CHARG,
      VSTAT(40) TYPE C,
      VSTATUS(50),
      END OF ITAB.

DATA: BEGIN OF IT_DISPLAY2 OCCURS 0,
        BATCH(10),
        SONUM(10),
        SOITEM(6),
        CREATE_ON(10),
        NOROLL(40),
END OF IT_DISPLAY2.

DATA: BEGIN OF IT_DISPLAY3 OCCURS 0,
        BATCH(10),
        SONUM(10),
        SOITEM(6),
        CREATE_ON(10),
        NOROLL(40),
        NEWSNO(10),
        NEWSIT(6),
        VSTATUS(20),
END OF IT_DISPLAY3.

DATA: V_VBELN LIKE MSKA-VBELN,
      V_POSNR LIKE MSKA-POSNR,
      ZCUOBJ LIKE VBAP-CUOBJ,
      ZROLCHAR TYPE ATWTB,
      ZSATUAN(5) TYPE C,
      V_COUNT TYPE I,
      V_MESSAGE(50),
      VREMARKS(100),
      VCOUNTID TYPE P,
      VOLDLBL LIKE AUSP-ATWRT,
      VOLDTYPE LIKE AUSP-ATWRT,
      VOLDALIAS LIKE AUSP-ATWRT,
      VOLDTHICK LIKE AUSP-ATWRT,
      VOLDWIDTH LIKE AUSP-ATWRT,
      VOLDLENGTH LIKE AUSP-ATWRT,
      VOLDCODE LIKE ZMASTER_KTNG-CODE,
      VNEWLBL LIKE AUSP-ATWRT,
      VNEWTYPE LIKE AUSP-ATWRT,
      VNEWALIAS LIKE AUSP-ATWRT,
      VNEWTHICK LIKE AUSP-ATWRT,
      VNEWWIDTH LIKE AUSP-ATWRT,
      VNEWLENGTH LIKE AUSP-ATWRT,
      VNEWCODE LIKE ZMASTER_KTNG-CODE,
      V_DATE TYPE SY-DATUM,
      V_CUTOFF TYPE SY-DATUM VALUE '20220210'.

DATA: IT_DETAIL_KTNG LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE,
      IT_DETAIL_KTNG2 LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE,
      WA_DETAIL_KTNG LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE,
      IT_DISPLAY LIKE ITAB OCCURS 0 WITH HEADER LINE,
      IT_CHAR LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
      STRING(100) TYPE C.

RANGES: S_FDATE FOR MSKA-CHARG.
CONSTANTS :   GCF_E1(4) TYPE C VALUE '@0A@',
              GCF_S1(4) TYPE C VALUE '@08@'.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK5 WITH FRAME TITLE TEXT-003.
PARAMETER : P_OPTYP1 RADIOBUTTON GROUP GR1 USER-COMMAND AC DEFAULT 'X',
            P_OPTYP2 RADIOBUTTON GROUP GR1,
            P_OPTYP3 RADIOBUTTON GROUP GR1,
            P_OPTYP4 RADIOBUTTON GROUP GR1.
SELECTION-SCREEN END OF BLOCK BLOCK5.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
PARAMETER : P_SOURCE TYPE STRING MODIF ID B1.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS: S_SONUM FOR MSKA-VBELN MODIF ID B2,
                S_SOITEM FOR MSKA-POSNR MODIF ID B2,
                S_BATCH FOR MSKA-CHARG MODIF ID B2,
                S_ERSDA FOR MSKA-ERSDA MODIF ID B2.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS: S_ROLKTG FOR STRING MODIF ID B2 VISIBLE LENGTH 15 NO INTERVALS.
SELECTION-SCREEN END OF BLOCK BLOCK2.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
PARAMETER: P_OLDSNO TYPE MSKA-VBELN MODIF ID B3,
           P_OLDSIT TYPE MSKA-POSNR MODIF ID B3,
           P_NEWSNO TYPE MSKA-VBELN MODIF ID B3,
           P_NEWSIT TYPE MSKA-POSNR MODIF ID B3.
SELECTION-SCREEN END OF BLOCK BLOCK3.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK4 WITH FRAME TITLE TEXT-003.
PARAMETER: P_SNO TYPE MSKA-VBELN MODIF ID B4,
           P_SIT TYPE MSKA-POSNR MODIF ID B4.
SELECTION-SCREEN END OF BLOCK BLOCK4.

AT SELECTION-SCREEN OUTPUT.
  IF P_OPTYP1 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'B1' OR SCREEN-GROUP1 = 'B3' OR SCREEN-GROUP1 = 'B4'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF P_OPTYP2 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'B2' OR SCREEN-GROUP1 = 'B3' OR SCREEN-GROUP1 = 'B4'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF P_OPTYP3 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'B1' OR SCREEN-GROUP1 = 'B2' OR SCREEN-GROUP1 = 'B4'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF P_OPTYP4 = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'B1' OR SCREEN-GROUP1 = 'B2' OR SCREEN-GROUP1 = 'B3'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SOURCE.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MODE             = 'O'
      TITLE            = 'Select File'
    IMPORTING
      FILENAME         = P_SOURCE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.
  IF P_OPTYP1 = 'X'.
    IF S_SONUM[] IS INITIAL AND S_SOITEM[] IS INITIAL AND S_BATCH[] IS INITIAL AND S_ERSDA[] IS INITIAL AND S_ROLKTG[] IS INITIAL.
      MESSAGE 'Harus memasukkan parameter.' TYPE 'I'.
      EXIT.
    ELSEIF S_ROLKTG[] IS NOT INITIAL AND S_SONUM[] IS NOT INITIAL.
      MESSAGE 'Parameter Roll KT&G tidak boleh ditambahkan parameter lain' TYPE 'I'.
      EXIT.
    ELSEIF S_ROLKTG[] IS NOT INITIAL AND S_SOITEM[] IS NOT INITIAL.
      MESSAGE 'Parameter Roll KT&G tidak boleh ditambahkan parameter lain' TYPE 'I'.
      EXIT.
    ELSEIF S_ROLKTG[] IS NOT INITIAL AND S_BATCH[] IS NOT INITIAL.
      MESSAGE 'Parameter Roll KT&G tidak boleh ditambahkan parameter lain' TYPE 'I'.
      EXIT.
    ELSEIF S_ROLKTG[] IS NOT INITIAL AND S_ERSDA[] IS NOT INITIAL.
      MESSAGE 'Parameter Roll KT&G tidak boleh ditambahkan parameter lain' TYPE 'I'.
      EXIT.
    ENDIF.

    IF S_ROLKTG[] IS NOT INITIAL.
      LOOP AT S_ROLKTG.
        SPLIT S_ROLKTG-LOW AT '-' INTO IT_DETAIL_KTNG2-KTNGCODE IT_DETAIL_KTNG2-COMPANY
                                       IT_DETAIL_KTNG2-JRDATE IT_DETAIL_KTNG2-JRNUMB IT_DETAIL_KTNG2-MIDROLL
                                       IT_DETAIL_KTNG2-SLITT_MCHN IT_DETAIL_KTNG2-TS IT_DETAIL_KTNG2-PS.
        IT_DETAIL_KTNG2-NOROLL = S_ROLKTG-LOW.
        APPEND IT_DETAIL_KTNG2.
      ENDLOOP.
      PERFORM GET_DATA_BATCH.
      CLEAR: IT_DETAIL_KTNG2.
      REFRESH: IT_DETAIL_KTNG2.
    ELSE.
      LOOP AT S_BATCH.
        PERFORM INPUT_FORMAT USING S_BATCH-LOW CHANGING S_BATCH-LOW.
        IF S_BATCH-HIGH <> ''.
          PERFORM INPUT_FORMAT USING S_BATCH-HIGH CHANGING S_BATCH-HIGH.
        ENDIF.
        MODIFY S_BATCH.
      ENDLOOP.
      LOOP AT S_ERSDA.
        CONCATENATE S_ERSDA-LOW+6(2) S_ERSDA-LOW+4(2) S_ERSDA-LOW+0(4) INTO S_FDATE-LOW SEPARATED BY '.'.
        S_FDATE-SIGN = 'I'.
        S_FDATE-OPTION = 'EQ'.
        IF S_ERSDA-HIGH <> '00000000'.
          CONCATENATE S_ERSDA-HIGH+6(2) S_ERSDA-HIGH+4(2) S_ERSDA-HIGH+0(4) INTO S_FDATE-HIGH SEPARATED BY '.'.
          S_FDATE-OPTION = 'BT'.
        ENDIF.
        APPEND S_FDATE.
      ENDLOOP.
      PERFORM GET_DATA.
    ENDIF.

    IF IT_DISPLAY2[] IS NOT INITIAL.
      SORT IT_DISPLAY2 ASCENDING BY BATCH.
      PERFORM DISPLAY_DATA2.
    ELSE.
      MESSAGE 'Data Not Found!' TYPE 'I'.
    ENDIF.

  ELSEIF P_OPTYP2 = 'X'.
    IF P_SOURCE IS INITIAL.
      EXIT.
    ENDIF.

    PERFORM UPLOAD_DATA.
    PERFORM CHANGE_DATA.
    PERFORM DISPLAY_DATA.

  ELSEIF P_OPTYP3 = 'X'.
    IF P_OLDSNO IS INITIAL OR P_OLDSIT IS INITIAL OR P_NEWSNO IS INITIAL OR P_NEWSIT IS INITIAL.
      MESSAGE 'Harus memasukkan semua parameter.' TYPE 'I'.
      EXIT.
    ELSEIF P_OLDSNO = P_NEWSNO AND P_OLDSIT = P_NEWSIT.
      MESSAGE 'Parameter SO/Item sama.' TYPE 'I'.
      EXIT.
    ENDIF.

    PERFORM SOTOSO_KTNG.

  ELSEIF P_OPTYP4 = 'X'.

    IF P_SNO IS INITIAL OR P_SIT IS INITIAL.
      MESSAGE 'Harus memasukkan semua parameter.' TYPE 'I'.
      EXIT.
    ENDIF.

    PERFORM SOTOFREE_KTNG.

  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  CHANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHANGE_DATA.

  LOOP AT ITAB.
    CLEAR: IT_DETAIL_KTNG.
    REFRESH: IT_DETAIL_KTNG.

    SELECT SINGLE * FROM ZDETAIL_KTNG INTO IT_DETAIL_KTNG
      WHERE BATCH EQ ITAB-VBATCHOLD AND DELETION = ''.

    IF SY-SUBRC NE 0.
      IT_DISPLAY-VSTAT     = GCF_E1.
      IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
      IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
      IT_DISPLAY-VSTATUS = 'Gagal, Batch tidak ditemukan.'.
      APPEND IT_DISPLAY.
    ELSE.

      SELECT SINGLE * FROM ZDETAIL_KTNG INTO IT_DETAIL_KTNG
      WHERE BATCH EQ ITAB-VBATCHNEW AND DELETION = ''.

      IF SY-SUBRC = 0.
        IT_DISPLAY-VSTAT     = GCF_E1.
        IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
        IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
        IT_DISPLAY-VSTATUS = 'Gagal, Batch baru sudah pernah dicetak.'.
        APPEND IT_DISPLAY.

      ELSE.

        CONCATENATE 'CHANGEBATCH OF' SY-UNAME 'AT' SY-DATUM '|' SY-UZEIT '|' SY-TCODE INTO VREMARKS SEPARATED BY SPACE.

        UPDATE ZDETAIL_KTNG
           SET DELETION = 'X' REMARKS = VREMARKS
         WHERE BATCH = ITAB-VBATCHOLD
           AND DELETION = ''
           AND REMARKS = ''.

        IF SY-SUBRC EQ 0.
          COMMIT WORK.
          IT_DISPLAY-VSTAT     = GCF_S1.
          IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
          IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
          IT_DISPLAY-VSTATUS = 'Sukses update batch'.

          SELECT MAX( ID ) FROM ZDETAIL_KTNG INTO WA_DETAIL_KTNG-ID.

          APPEND IT_DETAIL_KTNG.
          LOOP AT IT_DETAIL_KTNG.
            WA_DETAIL_KTNG-ID = WA_DETAIL_KTNG-ID + 1.
            IT_DETAIL_KTNG-ID = WA_DETAIL_KTNG-ID.
            IT_DETAIL_KTNG-BATCH = ITAB-VBATCHNEW.
            IT_DETAIL_KTNG-REMARKS  = ''.
            IT_DETAIL_KTNG-DELETION = ''.
            MODIFY IT_DETAIL_KTNG.
          ENDLOOP.

          INSERT ZDETAIL_KTNG FROM IT_DETAIL_KTNG.
          IF SY-SUBRC EQ 0.
            COMMIT WORK.
            IT_DISPLAY-VSTAT     = GCF_S1.
            IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
            IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
            IT_DISPLAY-VSTATUS = 'Sukses update batch'.
          ELSE.
            IT_DISPLAY-VSTAT     = GCF_E1.
            IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
            IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
            IT_DISPLAY-VSTATUS = 'Error, Gagal update batch'.
          ENDIF.

        ELSE.
          IT_DISPLAY-VSTAT     = GCF_E1.
          IT_DISPLAY-VBATCHOLD = ITAB-VBATCHOLD.
          IT_DISPLAY-VBATCHNEW = ITAB-VBATCHNEW.
          IT_DISPLAY-VSTATUS = 'Error, Gagal update batch'.
        ENDIF.
        APPEND IT_DISPLAY.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    "CHANGE_DATA

**&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = P_SOURCE
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB.
ENDFORM.                    "UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  CLEAR: IT_DETAIL_KTNG, IT_DISPLAY2.
  REFRESH: IT_DETAIL_KTNG, IT_DISPLAY2.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG FROM ZDETAIL_KTNG
    WHERE SONUM IN S_SONUM
      AND SOITEM IN S_SOITEM
      AND BATCH IN S_BATCH
      AND CREATE_ON IN S_FDATE
      AND DELETION EQ ''
    ORDER BY SONUM SOITEM CREATE_ON ASCENDING.

  LOOP AT IT_DETAIL_KTNG.
    MOVE-CORRESPONDING IT_DETAIL_KTNG TO IT_DISPLAY2.

    " Added by William at 09.02.2022
    PERFORM DATE_INPUT_FORMAT USING IT_DETAIL_KTNG-CREATE_ON CHANGING V_DATE.
    IF V_DATE LT V_CUTOFF.
      CONCATENATE IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-COMPANY IT_DETAIL_KTNG-JRDATE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
      IT_DETAIL_KTNG-SLITT_MCHN IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DISPLAY2-NOROLL SEPARATED BY '-'.
    ELSE.
      IT_DISPLAY2-NOROLL = IT_DETAIL_KTNG-NOROLL.
    ENDIF.
    " End added by William at 09.02.2022

    APPEND IT_DISPLAY2.
    CLEAR IT_DISPLAY2.
  ENDLOOP.

*  IF IT_DISPLAY2[] IS NOT INITIAL.
*    SORT IT_DISPLAY2 ASCENDING BY BATCH.
*    PERFORM DISPLAY_DATA2.
*  ELSE.
*    MESSAGE 'Data Not Found!' TYPE 'I'.
*  ENDIF.

ENDFORM.                    "GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA2.
  PERFORM F_FIELD_CATALOG2.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL2.
ENDFORM.                    "DISPLAY_DATA2

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL.
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = D_REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = T_FIELDCAT[]
      IT_EVENTS          = T_EVENTS[]
      IT_EVENT_EXIT      = T_EVENT_EXIT[]
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
      IS_VARIANT         = WA_VARIANTE
      IS_PRINT           = T_PRINT
      IT_SORT            = T_SORT[]
      IT_EXCLUDING       = T_EXCLUDING[]
      I_BYPASSING_BUFFER = 'X'
    TABLES
      T_OUTTAB           = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.                    "F_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL2.
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = D_REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = T_FIELDCAT[]
      IT_EVENTS          = T_EVENTS[]
      IT_EVENT_EXIT      = T_EVENT_EXIT[]
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
      IS_VARIANT         = WA_VARIANTE
      IS_PRINT           = T_PRINT
      IT_SORT            = T_SORT[]
      IT_EXCLUDING       = T_EXCLUDING[]
      I_BYPASSING_BUFFER = 'X'
    TABLES
      T_OUTTAB           = IT_DISPLAY2
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.                    "F_LIST_DETAIL2

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT.
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
ENDFORM.                    "F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG.
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_DISPLAY' :
          'VSTAT' '' '' '' 7 'Status' '' '' '' '',
          'VBATCHOLD' '' '' '' 10 'Batch Lama' '' '' '' '',
          'VBATCHNEW' '' '' '' 10 'Batch Baru' '' '' '' '',
          'VSTATUS' '' '' '' 50 'Message' '' '' '' ''.
ENDFORM.                    " F_FIELD_CATALOG

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG2.
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_DISPLAY2' :
           'BATCH' '' '' '' 10 'Batch' '' '' '' '',
           'SONUM' '' '' '' 10 'SO Number' '' '' '' '',
           'SOITEM' '' '' '' 10 'SO Item' '' '' '' '',
           'CREATE_ON' '' '' '' 10 'Create On' '' '' '' '',
           'NOROLL' '' '' '' 30 'Nomor Roll KT&G' '' '' '' ''.
ENDFORM.                    "F_FIELD_CATALOG2

*&---------------------------------------------------------------------*
*&      Form  INPUT_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM INPUT_FORMAT USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "INPUT_FORMAT

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM OUTPUT_FORMAT USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "OUTPUT_FORMAT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_BATCH.
  CLEAR: IT_DETAIL_KTNG, IT_DISPLAY2.
  REFRESH: IT_DETAIL_KTNG, IT_DISPLAY2.
  LOOP AT IT_DETAIL_KTNG2.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF IT_DETAIL_KTNG FROM ZDETAIL_KTNG
      WHERE NOROLL EQ IT_DETAIL_KTNG2-NOROLL
        AND DELETION = ''.
    IF SY-SUBRC NE 0.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF IT_DETAIL_KTNG FROM ZDETAIL_KTNG
        WHERE KTNGCODE EQ IT_DETAIL_KTNG2-KTNGCODE
          AND COMPANY EQ IT_DETAIL_KTNG2-COMPANY
          AND JRDATE EQ IT_DETAIL_KTNG2-JRDATE
          AND JRNUMB EQ IT_DETAIL_KTNG2-JRNUMB
          AND MIDROLL EQ IT_DETAIL_KTNG2-MIDROLL
          AND SLITT_MCHN EQ IT_DETAIL_KTNG2-SLITT_MCHN
          AND TS EQ IT_DETAIL_KTNG2-TS
          AND PS EQ IT_DETAIL_KTNG2-PS
          AND DELETION = ''.
      IF SY-SUBRC = 0.
        APPEND IT_DETAIL_KTNG.
      ENDIF.
    ELSE.
      APPEND IT_DETAIL_KTNG.
    ENDIF.
  ENDLOOP.

  LOOP AT IT_DETAIL_KTNG.
    MOVE-CORRESPONDING IT_DETAIL_KTNG TO IT_DISPLAY2.

    " Added by William at 09.02.2022
    PERFORM DATE_INPUT_FORMAT USING IT_DETAIL_KTNG-CREATE_ON CHANGING V_DATE.
    IF V_DATE LT V_CUTOFF.
      CONCATENATE IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-COMPANY IT_DETAIL_KTNG-JRDATE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
      IT_DETAIL_KTNG-SLITT_MCHN IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DISPLAY2-NOROLL SEPARATED BY '-'.
    ELSE.
      IT_DISPLAY2-NOROLL = IT_DETAIL_KTNG-NOROLL.
    ENDIF.
    " End added by William at 09.02.2022

    APPEND IT_DISPLAY2.
    CLEAR IT_DISPLAY2.
  ENDLOOP.

*  IF IT_DISPLAY2[] IS NOT INITIAL.
*    SORT IT_DISPLAY2 ASCENDING BY BATCH.
*    PERFORM DISPLAY_DATA2.
*  ELSE.
*    MESSAGE 'Data Not Found!' TYPE 'I'.
*  ENDIF.

ENDFORM.                    " GET_DATA_BATCH
*&---------------------------------------------------------------------*
*&      Form  SOTOSO_KTNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SOTOSO_KTNG .

  CLEAR: IT_DETAIL_KTNG, IT_DETAIL_KTNG2, IT_DISPLAY3.
  REFRESH: IT_DETAIL_KTNG, IT_DETAIL_KTNG2, IT_DISPLAY3.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG FROM ZDETAIL_KTNG
    WHERE SONUM EQ P_OLDSNO
      AND SOITEM EQ P_OLDSIT
      AND DELETION = ''
    ORDER BY CREATE_ON ASCENDING.
  IF SY-SUBRC = 0.
    PERFORM CEK_TOTAL_DATA USING P_OLDSNO P_OLDSIT.
  ENDIF.

  LOOP AT IT_DETAIL_KTNG.
    MOVE-CORRESPONDING IT_DETAIL_KTNG TO IT_DISPLAY3.
    CONCATENATE IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-COMPANY IT_DETAIL_KTNG-JRDATE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
    IT_DETAIL_KTNG-SLITT_MCHN IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DISPLAY3-NOROLL SEPARATED BY '-'.
    IT_DISPLAY3-NEWSNO = P_NEWSNO.
    IT_DISPLAY3-NEWSIT = P_NEWSIT.
    APPEND IT_DISPLAY3.
    CLEAR IT_DISPLAY3.
  ENDLOOP.

  IF IT_DISPLAY3[] IS NOT INITIAL.
    " Added by William at 09.02.2022
    PERFORM GET_SO_CHAR USING P_OLDSNO P_OLDSIT CHANGING VOLDLBL VOLDTYPE VOLDWIDTH VOLDCODE.
    PERFORM GET_SO_CHAR USING P_NEWSNO P_NEWSIT CHANGING VNEWLBL VNEWTYPE VNEWWIDTH VNEWCODE.
    " End added by William at 09.02.2022

    PERFORM VALIDASI_SOTOSO USING P_NEWSNO P_NEWSIT.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG2 FROM ZDETAIL_KTNG
      WHERE SONUM EQ P_NEWSNO
        AND SOITEM EQ P_NEWSIT
        AND DELETION = ''
      ORDER BY CREATE_ON ASCENDING.

    IF SY-SUBRC = 0.

      "Check SO baru / SO tujuan sudah pernah ada
      REFRESH: IT_CHAR.
      CLEAR: ZROLCHAR, ZSATUAN, V_COUNT, ZCUOBJ.
      SELECT SINGLE VBAP~CUOBJ INTO ZCUOBJ FROM VBAP WHERE VBAP~VBELN = P_NEWSNO AND VBAP~POSNR = P_NEWSIT.

      " Modified by William at 09.02.2022
      PERFORM GET_CONFIGURATION USING ZCUOBJ.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZROLCHAR ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZROLCHAR WITH ' '.

      SELECT COUNT(*) INTO V_COUNT FROM ZDETAIL_KTNG
        WHERE SONUM = P_NEWSNO AND SOITEM = P_NEWSIT AND DELETION = ''.

      IF V_COUNT < ZROLCHAR.
        PERFORM OUTPUT_FORMAT USING P_NEWSNO CHANGING P_NEWSNO.
        PERFORM OUTPUT_FORMAT USING P_NEWSNO CHANGING P_NEWSNO.
        CONCATENATE 'No Roll KT&G utk SO' P_NEWSNO '/' P_NEWSNO 'belum terpenuhi.' INTO V_MESSAGE SEPARATED BY ' '.
        MESSAGE V_MESSAGE TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ELSE.
        LOOP AT IT_DETAIL_KTNG2.
          CONCATENATE 'DELETESO OF' SY-UNAME 'AT' SY-DATUM '|' SY-UZEIT '|' SY-TCODE INTO VREMARKS SEPARATED BY SPACE.
          UPDATE ZDETAIL_KTNG SET DELETION = 'X' REMARKS = VREMARKS
           WHERE BATCH = IT_DETAIL_KTNG2-BATCH
             AND SONUM = IT_DETAIL_KTNG2-SONUM
             AND SOITEM = IT_DISPLAY3-SOITEM
             AND DELETION = ''
             AND REMARKS = ''.
          IF SY-SUBRC = 0.
            COMMIT WORK.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.
    PERFORM EXEC_SOTOSO.
    PERFORM DISPLAY_CHANGE_SO.
  ELSE.
    MESSAGE 'Data Not Found!' TYPE 'I'.
    EXIT.
  ENDIF.

ENDFORM.                    " SOTOSO_KTNG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CHANGE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CHANGE_SO .
  PERFORM F_FIELD_CATALOG3.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL3.
ENDFORM.                    " DISPLAY_CHANGE_SO
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG3 .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_DISPLAY3' :
           'CREATE_ON' '' '' '' 10 'Create On' '' '' '' '',
           'BATCH' '' '' '' 10 'Batch' '' '' '' '',
           'NOROLL' '' '' '' 30 'Nomor Roll KT&G' '' '' '' '',
           'SONUM' '' '' '' 10 'Old SO Number' '' '' '' '',
           'SOITEM' '' '' '' 10 'Old SO Item' '' '' '' '',
           'NEWSNO' '' '' '' 10 'New SO Number' '' '' '' '',
           'NEWSIT' '' '' '' 10 'New SO Item' '' '' '' '',
           'VSTATUS' '' '' '' 20 'Status' '' '' '' ''.
ENDFORM.                    " F_FIELD_CATALOG3
*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL3 .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = D_REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = T_FIELDCAT[]
      IT_EVENTS          = T_EVENTS[]
      IT_EVENT_EXIT      = T_EVENT_EXIT[]
      I_DEFAULT          = 'X'
      I_SAVE             = 'A'
      IS_VARIANT         = WA_VARIANTE
      IS_PRINT           = T_PRINT
      IT_SORT            = T_SORT[]
      IT_EXCLUDING       = T_EXCLUDING[]
      I_BYPASSING_BUFFER = 'X'
    TABLES
      T_OUTTAB           = IT_DISPLAY3
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.                    " F_LIST_DETAIL3

*&---------------------------------------------------------------------*
*&      Form  EXEC_SOTOSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_SOTOSO.

  LOOP AT IT_DISPLAY3.
    CLEAR: IT_DETAIL_KTNG, WA_DETAIL_KTNG-ID.
    REFRESH: IT_DETAIL_KTNG.

    SELECT * FROM ZDETAIL_KTNG INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG
      WHERE BATCH = IT_DISPLAY3-BATCH AND DELETION EQ ''.

    " Added by William at 09.02.2022
    READ TABLE IT_DETAIL_KTNG INDEX 1.
    PERFORM UPDATE_NOROLL_SOTOSO.
    IT_DISPLAY3-NOROLL = IT_DETAIL_KTNG-NOROLL.

    CONCATENATE 'SOTOSO OF' SY-UNAME 'AT' SY-DATUM '|' SY-UZEIT '|' SY-TCODE INTO VREMARKS SEPARATED BY SPACE.

    UPDATE ZDETAIL_KTNG SET DELETION = 'X' REMARKS = VREMARKS
     WHERE BATCH = IT_DISPLAY3-BATCH
       AND SONUM = IT_DISPLAY3-SONUM
       AND SOITEM = IT_DISPLAY3-SOITEM
       AND DELETION = ''
       AND REMARKS = ''.

    IF SY-SUBRC EQ 0.
      COMMIT WORK.
      IT_DISPLAY3-VSTATUS = 'Sukses Diupdate'.
      MODIFY IT_DISPLAY3.

      SELECT MAX( ID ) FROM ZDETAIL_KTNG INTO WA_DETAIL_KTNG-ID.

      LOOP AT IT_DETAIL_KTNG.
        WA_DETAIL_KTNG-ID = WA_DETAIL_KTNG-ID + 1.
        IT_DETAIL_KTNG-ID = WA_DETAIL_KTNG-ID.
        IT_DETAIL_KTNG-SONUM = IT_DISPLAY3-NEWSNO.
        IT_DETAIL_KTNG-SOITEM = IT_DISPLAY3-NEWSIT.
        MODIFY IT_DETAIL_KTNG.
      ENDLOOP.

      INSERT ZDETAIL_KTNG FROM IT_DETAIL_KTNG.
      IF SY-SUBRC EQ 0.
        COMMIT WORK.
        IT_DISPLAY3-VSTATUS = 'Sukses Diupdate'.
        MODIFY IT_DISPLAY3.
      ELSE.
        IT_DISPLAY3-VSTATUS = 'Gagal Diupdate'.
        MODIFY IT_DISPLAY3.
      ENDIF.
    ELSE.
      IT_DISPLAY3-VSTATUS = 'Gagal Diupdate'.
      MODIFY IT_DISPLAY3.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " EXEC_SOTOSO
*&---------------------------------------------------------------------*
*&      Form  SOTOFREE_KTNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SOTOFREE_KTNG .

  CLEAR: IT_DETAIL_KTNG, IT_DISPLAY3.
  REFRESH: IT_DETAIL_KTNG, IT_DISPLAY3.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG FROM ZDETAIL_KTNG
    WHERE SONUM EQ P_SNO
      AND SOITEM EQ P_SIT
      AND DELETION = ''
    ORDER BY CREATE_ON ASCENDING.
  IF SY-SUBRC = 0.
    PERFORM CEK_TOTAL_DATA USING P_SNO P_SIT.
  ENDIF.

  LOOP AT IT_DETAIL_KTNG.
    MOVE-CORRESPONDING IT_DETAIL_KTNG TO IT_DISPLAY3.
    CONCATENATE IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-COMPANY IT_DETAIL_KTNG-JRDATE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
    IT_DETAIL_KTNG-SLITT_MCHN IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DISPLAY3-NOROLL SEPARATED BY '-'.
    IT_DISPLAY3-NEWSNO = P_NEWSNO.
    IT_DISPLAY3-NEWSIT = P_NEWSIT.
    APPEND IT_DISPLAY3.
    CLEAR IT_DISPLAY3.
  ENDLOOP.

  IF IT_DISPLAY3[] IS NOT INITIAL.
    " Added by William at 09.02.2022
    PERFORM GET_SO_CHAR USING P_SNO P_SIT CHANGING VNEWLBL VOLDTYPE VOLDWIDTH VNEWCODE.
    " End added by William at 09.02.2022

    PERFORM VALIDASI_SOTOFREE.
    PERFORM EXEC_SOTOFREE.
    PERFORM DISPLAY_CHANGE_SO.
  ELSE.
    MESSAGE 'Data Not Found!' TYPE 'I'.
  ENDIF.

ENDFORM.                    " SOTOFREE_KTNG
*&---------------------------------------------------------------------*
*&      Form  EXEC_SOTOFREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXEC_SOTOFREE .

  LOOP AT IT_DISPLAY3.
    CLEAR: IT_DETAIL_KTNG.
    REFRESH: IT_DETAIL_KTNG.

    SELECT * FROM ZDETAIL_KTNG INTO CORRESPONDING FIELDS OF TABLE IT_DETAIL_KTNG
      WHERE BATCH = IT_DISPLAY3-BATCH AND DELETION EQ ''.

    " Added by William at 09.02.2022
    READ TABLE IT_DETAIL_KTNG INDEX 1.
    PERFORM UPDATE_NOROLL_SOTOFREE.
    IT_DISPLAY3-NOROLL = IT_DETAIL_KTNG-NOROLL.

    CONCATENATE 'SOTOFREE OF' SY-UNAME 'AT' SY-DATUM '|' SY-UZEIT '|' SY-TCODE INTO VREMARKS SEPARATED BY SPACE.

    UPDATE ZDETAIL_KTNG SET DELETION = 'X' REMARKS = VREMARKS
                            NOROLL = IT_DISPLAY3-NOROLL " Added by William at 09.02.2022
     WHERE BATCH = IT_DISPLAY3-BATCH
       AND SONUM = IT_DISPLAY3-SONUM
       AND SOITEM = IT_DISPLAY3-SOITEM
       AND DELETION = ''
       AND REMARKS = ''.

    IF SY-SUBRC EQ 0.
      COMMIT WORK.
      IT_DISPLAY3-VSTATUS = 'Sukses Diupdate'.
      MODIFY IT_DISPLAY3.
    ELSE.
      IT_DISPLAY3-VSTATUS = 'Gagal Diupdate'.
      MODIFY IT_DISPLAY3.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " EXEC_SOTOFREE
*&---------------------------------------------------------------------*
*&      Form  CEK_TOTAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_OLDSNO  text
*      -->P_P_OLDSIT  text
*----------------------------------------------------------------------*
FORM CEK_TOTAL_DATA  USING    P_SONUM
                              P_SOITEM.

  "Check SO baru / SO tujuan sudah pernah ada
  REFRESH: IT_CHAR.
  CLEAR: ZROLCHAR, ZSATUAN, V_COUNT, ZCUOBJ, V_MESSAGE.
  SELECT SINGLE VBAP~CUOBJ INTO ZCUOBJ FROM VBAP WHERE VBAP~VBELN = P_SONUM AND VBAP~POSNR = P_SOITEM.

  " Modified by William at 09.02.2022
  PERFORM GET_CONFIGURATION USING ZCUOBJ.

  READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNUMBEROFROLL'.
  SPLIT IT_CHAR-ATWTB AT SPACE INTO ZROLCHAR ZSATUAN.
  REPLACE ALL OCCURRENCES OF ',' IN ZROLCHAR WITH ' '.

  SELECT COUNT(*) INTO V_COUNT FROM ZDETAIL_KTNG
    WHERE SONUM = P_SONUM
    AND SOITEM = P_SOITEM
    AND DELETION = ''
    .

  IF V_COUNT < ZROLCHAR.
    PERFORM OUTPUT_FORMAT USING P_SONUM CHANGING P_SONUM.
    PERFORM OUTPUT_FORMAT USING P_SOITEM CHANGING P_SOITEM.
    CONCATENATE 'No Roll KT&G utk SO' P_SONUM '/' P_SOITEM 'belum terpenuhi.' INTO V_MESSAGE SEPARATED BY ' '.
    MESSAGE V_MESSAGE TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " CEK_TOTAL_DATA
*&---------------------------------------------------------------------*
*&      Form  VALIDASI_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDASI_SOTOSO USING    P_SONUM
                              P_SOITEM.

  CLEAR: V_MESSAGE.

  LOOP AT IT_DISPLAY3.
    CLEAR: V_VBELN, V_POSNR.

    SELECT SINGLE VBELN POSNR FROM MSKA INTO (V_VBELN, V_POSNR)
      WHERE CHARG = IT_DISPLAY3-BATCH
      AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

    IF V_VBELN NE P_SONUM.
      CONCATENATE 'Batch' IT_DISPLAY3-BATCH 'tidak terikat dgn SO/Item tujuan.' INTO V_MESSAGE SEPARATED BY ' '.
      MESSAGE V_MESSAGE TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ELSE.
      IF V_POSNR NE P_SOITEM.
        CONCATENATE 'Batch' IT_DISPLAY3-BATCH 'tidak terikat dgn SO/Item tujuan.' INTO V_MESSAGE SEPARATED BY ' '.
        MESSAGE V_MESSAGE TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " VALIDASI_SO
*&---------------------------------------------------------------------*
*&      Form  VALIDASI_SOTOFREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDASI_SOTOFREE .

  CLEAR: V_MESSAGE.

  LOOP AT IT_DISPLAY3.
    CLEAR: V_VBELN, V_POSNR.

    SELECT SINGLE VBELN POSNR FROM MSKA INTO (V_VBELN, V_POSNR)
      WHERE CHARG = IT_DISPLAY3-BATCH
      AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

    IF V_VBELN NE ''.
      CONCATENATE 'Batch' IT_DISPLAY3-BATCH 'sedang terikat dengan SO/Item.' INTO V_MESSAGE SEPARATED BY ' '.
      MESSAGE V_MESSAGE TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ELSE.
      IF V_POSNR NE ''.
        CONCATENATE 'Batch' IT_DISPLAY3-BATCH 'sedang terikat dengan SO/Item.' INTO V_MESSAGE SEPARATED BY ' '.
        MESSAGE V_MESSAGE TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " VALIDASI_SOTOFREE

*&---------------------------------------------------------------------*
*&      Form  UPDATE_NOROLL_SOTOSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_NOROLL_SOTOSO.
* get kode label
  IF VOLDLBL <> VNEWLBL.
    PERFORM UPDATE_NEW_NOROLL.
  ENDIF.
ENDFORM.                    "UPDATE_NOROLL_SOTOSO

*&---------------------------------------------------------------------*
*&      Form  UPDATE_NOROLL_SOTOFREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPDATE_NOROLL_SOTOFREE.
* get kode label
  PERFORM UPDATE_NEW_NOROLL.
ENDFORM.                    "UPDATE_NOROLL_SOTOFREE

*&---------------------------------------------------------------------*
*&      Form  UPDATE_NEW_NOROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VNEWLBL    text
*----------------------------------------------------------------------*
FORM UPDATE_NEW_NOROLL.
* concatenate kode baru
  IF VNEWLBL = 'A131' OR VNEWLBL = 'A138' OR VNEWLBL = 'A139'.
    PERFORM NOROLL_A131.
  ELSEIF VNEWLBL = 'A149'.
    PERFORM NOROLL_A149.
  ENDIF.
ENDFORM.                    "UPDATE_NEW_NOROLL

*&---------------------------------------------------------------------*
*&      Form  NOROLL_A131
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NOROLL_A131.
  CONCATENATE IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-COMPANY IT_DETAIL_KTNG-JRDATE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
  IT_DETAIL_KTNG-SLITT_MCHN IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DETAIL_KTNG-NOROLL SEPARATED BY '-'.
ENDFORM.                    "NOROLL_A131

*&---------------------------------------------------------------------*
*&      Form  NOROLL_A149
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NOROLL_A149.
  DATA: V_PRODDATE(6),
        V_LINE(1).

  " Modified by William at 14.02.2022
  IF IT_DETAIL_KTNG-NOROLL IS INITIAL.
    PERFORM GET_PROD_DATA USING IT_DETAIL_KTNG-BATCH CHANGING V_PRODDATE V_LINE.

    PERFORM CEK_KTNGCODE USING IT_DETAIL_KTNG-KTNGCODE CHANGING IT_DETAIL_KTNG-KTNGCODE.

    " Added by William at 08.03.2022
    PERFORM INPUT_FORMAT USING IT_DETAIL_KTNG-JRNUMB CHANGING IT_DETAIL_KTNG-JRNUMB.
    PERFORM INPUT_FORMAT USING IT_DETAIL_KTNG-TS CHANGING IT_DETAIL_KTNG-TS.
    " End added by William at 08.03.2022

    CONCATENATE 'L' IT_DETAIL_KTNG-KTNGCODE '48' V_PRODDATE '00' V_LINE IT_DETAIL_KTNG-JRNUMB IT_DETAIL_KTNG-MIDROLL
                IT_DETAIL_KTNG-TS IT_DETAIL_KTNG-PS INTO IT_DETAIL_KTNG-NOROLL.

    MODIFY IT_DETAIL_KTNG TRANSPORTING KTNGCODE NOROLL WHERE BATCH = IT_DETAIL_KTNG-BATCH.
  ENDIF.
  " End modified by William at 14.02.2022

ENDFORM.                    "NOROLL_A149

*&---------------------------------------------------------------------*
*&      Form  GET_PROD_DATE
*&---------------------------------------------------------------------*
*       Added by William at 09.02.2022
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_PROD_DATA USING BATCH CHANGING PRODDATE LINE.
  DATA: V_MATNR LIKE MCH1-MATNR,
        V_CHARG LIKE MCH1-CHARG,
        V_POSTDATE TYPE SY-DATUM,
        V_TAB TYPE API_VALI OCCURS 0 WITH HEADER LINE.

  CLEAR: V_MATNR, V_CHARG, V_POSTDATE, V_TAB.
  REFRESH: V_TAB.

  V_CHARG = BATCH.

  SELECT SINGLE MATNR INTO V_MATNR
    FROM MCHA
    WHERE CHARG = V_CHARG.

  " Production Date
  CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
    EXPORTING
      MATNR = V_MATNR
      CHARG = V_CHARG
    IMPORTING
      PDATE = V_POSTDATE.

  CONCATENATE V_POSTDATE+2(2) V_POSTDATE+4(2) V_POSTDATE+6(2) INTO PRODDATE.
  CONDENSE PRODDATE NO-GAPS.

  " Line Production
  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = V_MATNR
      I_VAL_CHARGE   = V_CHARG
    TABLES
      T_VAL_TAB      = V_TAB
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOMORROLL'.  " Revised by William at 08.03.2022
  IF SY-SUBRC EQ 0.
    LINE = V_TAB-ATWRT(1).
  ENDIF.

ENDFORM.                    " GET_PROD_DATE

*&---------------------------------------------------------------------*
*&      Form  GET_CONFIGURATION
*&---------------------------------------------------------------------*
*       Added by William at 09.02.2022
*----------------------------------------------------------------------*
FORM GET_CONFIGURATION USING INSTANCE.
  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = INSTANCE
    TABLES
      CONFIGURATION       = IT_CHAR
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.
ENDFORM.                    "GET_CONFIGURATION

*&---------------------------------------------------------------------*
*&      Form  GET_SO_CHAR
*&---------------------------------------------------------------------*
*       Added by William at 09.02.2022
*----------------------------------------------------------------------*
*      -->P_SONUM    text
*      -->P_SOITEM   text
*      <--P_LABEL    text
*----------------------------------------------------------------------*
FORM GET_SO_CHAR  USING     P_SONUM
                            P_SOITEM
                  CHANGING  P_LABEL
                            P_TYPE
                            P_WIDTH
                            P_CODE.

  DATA: V_TYPE LIKE AUSP-ATWRT.
  DATA: V_THICK LIKE AUSP-ATWRT.

  CLEAR: IT_CHAR, ZCUOBJ, V_TYPE, V_THICK.
  REFRESH: IT_CHAR.

  SELECT SINGLE VBAP~CUOBJ INTO ZCUOBJ FROM VBAP WHERE VBAP~VBELN = P_SONUM AND VBAP~POSNR = P_SOITEM.

  PERFORM GET_CONFIGURATION USING ZCUOBJ.

  READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZLABEL'.
  IF SY-SUBRC EQ 0.
    P_LABEL = IT_CHAR-ATWRT.
  ENDIF.
  CLEAR: IT_CHAR.

  READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTYPE'.
  IF SY-SUBRC EQ 0.
    P_TYPE = IT_CHAR-ATWRT.
    READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC EQ 0.
      SPLIT IT_CHAR-ATWRT AT '-' INTO V_TYPE V_THICK.
      P_TYPE = V_TYPE.
    ENDIF.
  ENDIF.
  CLEAR: IT_CHAR.

  READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH'.
  IF SY-SUBRC EQ 0.
    P_WIDTH = IT_CHAR-ATWRT.
  ENDIF.
  CLEAR: IT_CHAR.

  SELECT SINGLE CODE INTO P_CODE
    FROM ZMASTER_KTNG
    WHERE TYPE = P_TYPE
    AND WIDTH = P_WIDTH.

ENDFORM.                    "GET_SO_CHAR

*&---------------------------------------------------------------------*
*&      Form  DATE_INPUT_FORMAT
*&---------------------------------------------------------------------*
*       Added by William at 09.02.2022
*----------------------------------------------------------------------*
*      -->INPUT      text
*      -->OUTPUT     text
*----------------------------------------------------------------------*
FORM DATE_INPUT_FORMAT USING INPUT CHANGING OUTPUT.
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      DATE_EXTERNAL = INPUT
    IMPORTING
      DATE_INTERNAL = OUTPUT
            .
ENDFORM.                    "DATE_INPUT_FORMAT
*&---------------------------------------------------------------------*
*&      Form  CEK_KTNGCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DETAIL_KTNG_KTNGCODE  text
*      <--P_IT_DETAIL_KTNG_KTNGCODE  text
*----------------------------------------------------------------------*
FORM CEK_KTNGCODE  USING    P_OLD_CODE
                   CHANGING P_NEW_CODE.

  IF STRLEN( P_OLD_CODE ) < 10.
    P_NEW_CODE = VNEWCODE.
  ELSE.
    P_NEW_CODE = P_OLD_CODE.
  ENDIF.

ENDFORM.                    " CEK_KTNGCODE