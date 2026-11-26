*&---------------------------------------------------------------------*
*& Report  ZMMR_LABELJR
*&---------------------------------------------------------------------*
*& Created by : New Company
*& Created on : 20-05-2019
*& Desc.      :
*&---------------------------------------------------------------------*
REPORT  ZMMR_LABELJR_TTE.
TABLES: MCHA.
DATA : V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF IT_AUFM OCCURS 0,
      MATNR LIKE AUFM-MATNR,
      CHARG LIKE AUFM-CHARG,
      BWART LIKE AUFM-BWART,
  END OF IT_AUFM.

DATA :
    V_TYPE      TYPE CHAR30,
    V_CODE      TYPE CHAR10,
    V_THICKNESS TYPE CHAR10,
    V_WIDTH     TYPE CHAR15,
    V_LENGTH    TYPE CHAR15,
    V_INSIDE    TYPE CHAR10,
    V_OUTSIDE   TYPE CHAR10,
    V_WEIGHT    TYPE CHAR15,
    N_WEIGHT    TYPE P DECIMALS 2,  "char15,
    V_ROLLNO    TYPE CHAR15,
    V_MATKL     TYPE CHAR15,
    V_CHARG     TYPE CHAR15,
    V_STATUS    TYPE CHAR15,
    V_ROLNO    TYPE CHAR12,
    V_LOTNO     TYPE CHAR12.
*    v_length    TYPE p DECIMALS 2.

DATA: V_PLINE(2), "change New company
      V_MYEAR(3),
      V_JRNO(3),
      V_INT TYPE I.

DATA: V_SPLIT1(2), V_SPLIT3(50).

DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZMMF_LABELJR_TTE',
      V_FUNCNAME   TYPE RS38L_FNAM.

DATA: I_SSFCOMPOP TYPE SSFCOMPOP.
DATA: I_SSFCTRLOP  TYPE SSFCTRLOP.
DATA: I_RECIPIENT          TYPE SWOTOBJID.
DATA: I_SENDER             TYPE SWOTOBJID.
DATA: I_ADDR_KEY           LIKE ADDR_KEY.
DATA: I_NAST LIKE NAST.

"Add By Stefan 23.09.2019 RTP Core
DATA: BEGIN OF IT_CORE OCCURS 0,
        COREID LIKE ZCORER-COREID,
        WERKS LIKE ZCORER-WERKS,
        TYPERTP TYPE C LENGTH 10,
        WIDTHRTP TYPE C LENGTH 3,
        BOX(1),
      END OF IT_CORE.

DATA: BEGIN OF IT_CORE_DISPLAY OCCURS 0,
        COREID LIKE ZCORER-COREID,
        WERKS LIKE ZCORER-WERKS,
      END OF IT_CORE_DISPLAY.

DATA: WA_CORE LIKE LINE OF IT_CORE,
      WA_CORE_DISPLAY LIKE LINE OF IT_CORE_DISPLAY.

*---
SELECT-OPTIONS : P_CHARG FOR MCHA-CHARG. "Source from Batch Number
PARAMETERS: P_NDLOG AS CHECKBOX.

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM PRINT_LABEL.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  DATA: V_WERKS LIKE MCHB-WERKS.  "Add by Stefan
  SELECT MATNR CHARG BWART INTO TABLE IT_AUFM FROM AUFM
    WHERE CHARG IN P_CHARG.
  IF SY-SUBRC NE 0.
    MESSAGE 'Tidak ada Stock didalam batch ini..!' TYPE 'I'.
    LEAVE PROGRAM.
  ENDIF.

  READ TABLE IT_AUFM WITH KEY BWART = '102'.
  IF SY-SUBRC = 0.
    MESSAGE 'Batch ini sudah dibatalkan...!' TYPE 'I'.
    LEAVE PROGRAM.
  ENDIF.

  READ TABLE IT_AUFM INDEX 1.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = IT_AUFM-MATNR
      I_VAL_CHARGE   = IT_AUFM-CHARG
    TABLES
      T_VAL_TAB      = V_TAB
    EXCEPTIONS
      NO_CLASS       = 01
      INTERNAL_ERROR = 02
      NO_VALUES      = 03
      NO_CHARS       = 04.

"Added by Stefan on 20.09.2019 for RTP Core
  CLEAR V_WERKS.
    SELECT SINGLE WERKS INTO V_WERKS FROM MCHB WHERE CHARG IN P_CHARG.
    IF V_WERKS = 'TTE'.
      PERFORM F_CEK_RTP_CORE USING IT_AUFM-CHARG.
    ENDIF.
  "Added by Stefan on 20.09.2019 for RTP Core

  LOOP AT V_TAB.
    IF V_TAB-ATNAM = 'ZZTYPE'.
      SPLIT V_TAB-ATWTB AT '-' INTO: V_TYPE V_SPLIT3.
    ELSEIF V_TAB-ATNAM = 'ZZWIDTH'.
      V_WIDTH = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZLENGTH'.
      V_LENGTH = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZTHICKNESS'.
*      v_int = v_tab-atflv.
*      write v_int to v_thickness decimals 0.
      V_THICKNESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZINSIDE'.
      V_INSIDE = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZOUTSIDE'.
      V_OUTSIDE = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZCONVERSIONROLLKG'.
      N_WEIGHT = V_TAB-ATFLV.
      WRITE N_WEIGHT TO V_WEIGHT DECIMALS 2.
    ELSEIF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PLINE = V_TAB-ATWRT.
      SPLIT V_TAB-ATWTB AT SPACE INTO: V_SPLIT1 V_MATKL V_SPLIT3.
    ELSEIF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PLINE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_JRNO  = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZGRADEJR'.
      V_STATUS = V_TAB-ATWRT.
    ENDIF.
  ENDLOOP.

  V_CHARG = P_CHARG-LOW.
  CONCATENATE V_PLINE V_CODE V_MYEAR V_JRNO INTO V_ROLLNO SEPARATED BY SPACE.

  "GET NO.ROLL DAN LOT JR

  SELECT SINGLE LOTNO ROLNO INTO (V_LOTNO, V_ROLNO)
    FROM ZMRTYB WHERE CHARG IN P_CHARG.

ENDFORM.                    "get_data

*&---------------------------------------------------------------------*
*&      Form  print_label
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_LABEL.

*   Get Function Module name of SmartForms
* --------------------------------------
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC = 0.
    PERFORM F_CONDENSE.
    IF P_NDLOG = 'X'.
      I_SSFCTRLOP-NO_DIALOG = 'X'.
    ELSE.
      I_SSFCTRLOP-NO_DIALOG = ''.
    ENDIF.

    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS     = I_SSFCOMPOP
        MAIL_RECIPIENT     = I_RECIPIENT
        MAIL_SENDER        = I_SENDER
        S_TYPE             = V_TYPE
        S_THICKNESS        = V_THICKNESS
        S_WIDTH            = V_WIDTH
        S_LENGTH           = V_LENGTH
        S_INSIDE           = V_INSIDE
        S_OUTSIDE          = V_OUTSIDE
        S_WEIGHT           = V_WEIGHT
        S_ROLLNO           = V_ROLLNO
        S_MATKL            = V_MATKL
        S_CHARG            = V_CHARG
        S_STATUS           = V_STATUS
        S_ROLNO            = V_ROLNO
        S_LOTNO            = V_LOTNO.
  ENDIF.

ENDFORM.                    "print_label

*&---------------------------------------------------------------------*
*&      Form  f_condense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CONDENSE.
  CONDENSE V_TYPE.
  CONDENSE V_THICKNESS.
  CONDENSE V_WIDTH.
  CONDENSE V_LENGTH.
  CONDENSE V_INSIDE.
  CONDENSE V_OUTSIDE.
  CONDENSE V_WEIGHT.
  CONDENSE V_ROLLNO.
  CONDENSE V_MATKL.
  CONDENSE V_CHARG.
  CONDENSE V_STATUS..
ENDFORM.                    "f_condense


*&---------------------------------------------------------------------*
*&      Form  F_CEK_RTP_CORE
*&---------------------------------------------------------------------*
*       Added by Carfin on 28.03.2019
*       Untuk penecekkan apakah Batch JR menggunakan Core Plastic
*----------------------------------------------------------------------*
*      -->LV_CHARG   text
*----------------------------------------------------------------------*
FORM F_CEK_RTP_CORE USING LV_CHARG.
  DATA: BEGIN OF LT_ORDERTYPE OCCURS 0,
          MBLNR LIKE MSEG-MBLNR,
          ZEILE LIKE MSEG-ZEILE,
          SMBLN LIKE MSEG-SMBLN,
          SMBLP LIKE MSEG-SMBLP,
          AUART LIKE AUFK-AUART.
  DATA: END OF LT_ORDERTYPE.
  DATA: ZSVAL LIKE STANDARD TABLE OF SVAL WITH HEADER LINE,
        LT_ZCORER LIKE STANDARD TABLE OF ZCORER WITH HEADER LINE,
        LT_MCHB LIKE STANDARD TABLE OF MCHB WITH HEADER LINE,
        WA_ZCORER LIKE LINE OF LT_ZCORER,
        WA_ZCORER2 LIKE LINE OF LT_ZCORER,
        LV_CHARG_TEMP(15) TYPE C,
        LV_MSG(125),
        LV_POPUP(1),
        LV_COREID LIKE MCH1-CHARG,
        LV_WERKS LIKE MCHB-WERKS,
        LV_MAX_SEQ LIKE ZCORER-SEQNO,
        LV_TERMINAL LIKE ZCORER-ZUSER,
        LV_IP LIKE USR41-TERMINAL,
        ANS(1).

*- Step untuk validasi memunculkan Pop Up Input Core ID
*- Step 1: Cek Grade JR, apakah OK atau NA
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZGRADEJR'.
  IF V_TAB-ATWRT <> 'NK'.
*- Step 2: Cek stok JR
    SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = LV_CHARG AND ( CLABS > 0 OR CINSM > 0 OR CEINM > 0 OR CSPEM > 0 ).
    IF SY-SUBRC = 0.
      LV_WERKS = LT_MCHB-WERKS.
    ELSE.
      EXIT.
    ENDIF.
  ELSE.
    SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = LV_CHARG.
    IF SY-SUBRC = 0.
      LV_WERKS = LT_MCHB-WERKS.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

*- Step 3: Pembatasan secara Order Type untuk JR yg menggunakan RTP Core.
  SELECT
    MSEG~MBLNR MSEG~ZEILE MSEG~SMBLN
    MSEG~SMBLP AUFK~AUART
  INTO CORRESPONDING FIELDS OF TABLE LT_ORDERTYPE
  FROM MSEG
  JOIN AUFK ON MSEG~AUFNR EQ AUFK~AUFNR
  WHERE MSEG~CHARG = LV_CHARG
  AND MSEG~BWART IN ('101','102')
  AND AUFK~AUART IN ('ZP03','ZP04','ZP05','ZP06','ZP07','ZP08'). "Added by Stefan on 20.09.2019 for RTP Core

*- Step 4: Hilangkan matdoc yg di-cancel
  LOOP AT LT_ORDERTYPE WHERE SMBLN IS NOT INITIAL.
    DELETE LT_ORDERTYPE WHERE MBLNR EQ LT_ORDERTYPE-SMBLN AND ZEILE EQ LT_ORDERTYPE-SMBLP.
    DELETE LT_ORDERTYPE WHERE MBLNR EQ LT_ORDERTYPE-MBLNR AND ZEILE EQ LT_ORDERTYPE-ZEILE.
  ENDLOOP.

  IF LT_ORDERTYPE[] IS INITIAL.
    RETURN.
  ENDIF.

*- Step 5: Cek apakah Roll sudah terikat dengan RTP Core
  SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER WHERE CHARG = LV_CHARG.
  IF LV_MAX_SEQ > 0.
    CLEAR: LT_ZCORER, WA_ZCORER, WA_ZCORER2.
    REFRESH: LT_ZCORER.

    SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE SEQNO = LV_MAX_SEQ.
    IF SY-SUBRC = 0.
*- Step 6: Cek data Master RTP Core untuk diambil status terakhirnya.
      SELECT SINGLE * INTO WA_ZCORER2 FROM ZCORER WHERE COREID = WA_ZCORER-COREID AND CHARG = 'MASTER'.
      IF SY-SUBRC = 0.
        IF WA_ZCORER2-STATUS = 'R' OR WA_ZCORER2-STATUS = 'B' OR WA_ZCORER2-STATUS = 'C' OR WA_ZCORER2-STATUS = 'I'.
*- Step 7: Ambil Batch terakhir yang terikat dr Core ID yg bersangkutan.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZCORER UP TO 1 ROWS
          FROM ZCORER
          WHERE
            COREID = WA_ZCORER2-COREID AND
            CHARG <> 'MASTER' AND
            CHARG <> ''
          ORDER BY SEQNO DESCENDING.

          READ TABLE LT_ZCORER INDEX 1.

*- Step 8: Cek apakah Batch yang akan di-print sama dengan Batch terakhir yang terikat Core ID.
          IF LT_ZCORER-CHARG = LV_CHARG.
            LV_POPUP = ''.
          ELSE.
            LV_POPUP = 'X'.
          ENDIF.
        ELSE.
          LV_POPUP = 'X'.
        ENDIF.
      ELSE.
        LV_POPUP = 'X'.
      ENDIF.
    ELSE.
      LV_POPUP = 'X'.
    ENDIF.
  ELSE.
    LV_POPUP = 'X'.
  ENDIF.

*- Step-step berikut digunakan untuk mengikatakan Core ID dengan batch.
*- Step 1: jika belum terikat dg RTP core, tampil Pop Up konfirmasi apakah Batch JR menggunakan RTP Core.
  IF LV_POPUP = 'X'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Konfirmasi Penggunaan RTP Core'
        TEXT_QUESTION         = 'Apakah Batch JR mengggunakan RTP Core?'
        TEXT_BUTTON_1         = 'Ya'
        ICON_BUTTON_1         = '@0V@'
        TEXT_BUTTON_2         = 'Tidak'
        ICON_BUTTON_2         = '@0W@'
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = ' '
      IMPORTING
        ANSWER                = ANS.

    IF ANS <> '1'.
      RETURN.
    ENDIF.

    CLEAR: ZSVAL.
    ZSVAL-TABNAME   = 'MCHB'.
    ZSVAL-FIELDNAME = 'CHARG'.
    ZSVAL-FIELDTEXT = 'Batch JR'.
    ZSVAL-FIELD_ATTR = '02'.
    ZSVAL-NOVALUEHLP = 'X'.
    ZSVAL-VALUE     = LV_CHARG.
    APPEND ZSVAL.

    CLEAR: ZSVAL.
    ZSVAL-TABNAME   = 'MCH1'.
    ZSVAL-FIELDNAME = 'CHARG'.
    ZSVAL-FIELDTEXT = 'Core ID'.
    ZSVAL-FIELD_OBL = 'X'.
    APPEND ZSVAL.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*       NO_VALUE_CHECK  = ' '
        POPUP_TITLE     = 'Masukkan nomor Core ID'
        START_COLUMN    = '5'
        START_ROW       = '5'
      IMPORTING
        RETURNCODE      = ANS
      TABLES
        FIELDS          = ZSVAL
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      EXIT.
    ENDIF.

    IF ANS = 'A' . "Jika Pop Up di-cancel
      STOP.
    ELSE.
      READ TABLE ZSVAL WITH KEY FIELDTEXT = 'Core ID'.
      CONCATENATE '%' ZSVAL-VALUE INTO LV_CHARG_TEMP.

      "Add By Jarwo 06.08.2019 Pop Up pilih ID Core
      CLEAR: IT_CORE, IT_CORE_DISPLAY.
      REFRESH: IT_CORE, IT_CORE_DISPLAY.
      SELECT COREID WERKS FROM ZCORER
        INTO CORRESPONDING FIELDS OF TABLE IT_CORE
        WHERE COREID LIKE LV_CHARG_TEMP AND
              CHARG = 'MASTER'.

      LOOP AT IT_CORE.
        IF IT_CORE-COREID(2) = 'CP'.
          IT_CORE-TYPERTP = 'Plastic Core'.
        ELSEIF IT_CORE-COREID(2) = 'CB'.
          IT_CORE-TYPERTP = 'Iron Core'.
        ELSE.
          IT_CORE-TYPERTP = 'Unknow'.
        ENDIF.

        IT_CORE-WIDTHRTP = IT_CORE-COREID+2(3).
        MODIFY IT_CORE.
      ENDLOOP.

      CALL SCREEN 100 STARTING AT 75 3.

      IF IT_CORE_DISPLAY[] IS INITIAL.
        EXIT.
      ENDIF.

      READ TABLE IT_CORE_DISPLAY INDEX 1.
      IF SY-SUBRC = 0.
        LV_CHARG_TEMP = IT_CORE_DISPLAY-COREID.
        LV_WERKS = IT_CORE_DISPLAY-WERKS.
      ENDIF.
      "Add By Jarwo 06.08.2019

*- Step 2: Cek apakah memang batch untuk RTP Core
      SELECT SINGLE CHARG INTO LV_COREID FROM MCH1 WHERE CHARG EQ LV_CHARG_TEMP.
      IF SY-SUBRC NE 0.
        CONCATENATE 'Core ID ' ZSVAL-VALUE ' bukan material RTP Core' INTO LV_MSG SEPARATED BY SPACE.
        MESSAGE LV_MSG TYPE 'I'.
        STOP.
      ENDIF.

*- Step 3: Cek apakah stok RTP Core ada
      SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = LV_COREID AND WERKS = LV_WERKS AND CLABS > 0.
      IF SY-SUBRC NE 0.
        CONCATENATE 'Core ID ' LV_COREID 'tidak memiliki Stock..!' INTO LV_MSG SEPARATED BY SPACE.
        MESSAGE LV_MSG TYPE 'I'.
        STOP.
      ELSE.
*- Step 4: Cek apakah Core ID sedang terikat dengan Batch SR / JR.
        SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER' AND WERKS = LV_WERKS AND STATUS NOT IN ('N', 'U').
        IF SY-SUBRC = 0.
          IF LT_ZCORER-STATUS = 'R' OR LT_ZCORER-STATUS = 'B'.
            CONCATENATE 'Core ID ' LV_COREID 'sedang terikat dengan Roll!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'C'.
            CONCATENATE 'Core ID ' LV_COREID 'masih berada di Customer!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'I'.
            CONCATENATE 'Core ID ' LV_COREID 'masih berstatus Inquality!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'D'.
            CONCATENATE 'Core ID ' LV_COREID 'berstatus Damage!' INTO LV_MSG SEPARATED BY SPACE.
          ENDIF.

          MESSAGE LV_MSG TYPE 'I'.
          STOP.
        ELSE.
*- Step 5: Proses Insert ke Tabel Z
          CLEAR: LT_ZCORER.
          SELECT MAX( SEQNO ) INTO LT_ZCORER-SEQNO FROM ZCORER.

          LT_ZCORER-SEQNO = LT_ZCORER-SEQNO + 1.
          LT_ZCORER-COREID = LV_COREID.
          LT_ZCORER-CHARG = LV_CHARG.
          LT_ZCORER-WERKS = LV_WERKS.
          LT_ZCORER-STATUS = 'B'.
          LT_ZCORER-ERSDA = SY-DATUM.
          LT_ZCORER-ERZET = SY-UZEIT.

          CALL FUNCTION 'TERMINAL_ID_GET'
            EXPORTING
              USERNAME             = SY-UNAME
            IMPORTING
              TERMINAL             = LV_IP
            EXCEPTIONS
              MULTIPLE_TERMINAL_ID = 1
              NO_TERMINAL_FOUND    = 2
              OTHERS               = 3.

          CONCATENATE: SY-UNAME ';' LV_IP INTO LV_TERMINAL.

          LT_ZCORER-ZUSER = LV_TERMINAL.

          MODIFY ZCORER FROM LT_ZCORER.
          COMMIT WORK.

          CLEAR: LT_ZCORER.
          SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER' AND WERKS = LV_WERKS.

          IF SY-SUBRC = 0.
            LT_ZCORER-STATUS = 'B'.
            LT_ZCORER-ERSDA = SY-DATUM.
            LT_ZCORER-ERZET = SY-UZEIT.
            LT_ZCORER-ZUSER = LV_TERMINAL.
            MODIFY ZCORER FROM LT_ZCORER.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_CEK_RTP_CORE

*&---------------------------------------------------------------------*
*&      Module  IT_CORER_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
CONTROLS: IT_CORER TYPE TABLEVIEW USING SCREEN 0100.

*----------------------------------------------------------------------*
*  MODULE IT_CORER_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE IT_CORER_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_CORE LINES IT_CORER-LINES.
ENDMODULE.                 " IT_CORER_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'PFPOPUP'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN '&ACC'.
      REFRESH: IT_CORE_DISPLAY.

      LOOP AT IT_CORE WHERE BOX = 'X'.
        CLEAR WA_CORE_DISPLAY.
        WA_CORE_DISPLAY-COREID = IT_CORE-COREID.
        WA_CORE_DISPLAY-WERKS = IT_CORE-WERKS.

        APPEND WA_CORE_DISPLAY TO IT_CORE_DISPLAY.
      ENDLOOP.
      LEAVE TO SCREEN 0.
    WHEN '&CAN'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  IT_CORER_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE IT_CORER_MARK INPUT.
  DATA: G_IT_CORER_WA2 LIKE LINE OF IT_CORE.
  IF IT_CORER-LINE_SEL_MODE = 1
  AND WA_CORE-BOX = 'X'.
    LOOP AT IT_CORE INTO G_IT_CORER_WA2
      WHERE BOX = 'X'.
      G_IT_CORER_WA2-BOX = ''.
      MODIFY IT_CORE
        FROM G_IT_CORER_WA2
        TRANSPORTING BOX.
    ENDLOOP.
  ENDIF.
  MODIFY IT_CORE
    FROM WA_CORE
    INDEX IT_CORER-CURRENT_LINE
    TRANSPORTING BOX.
ENDMODULE.                    "IT_CORER_MARK INPUT