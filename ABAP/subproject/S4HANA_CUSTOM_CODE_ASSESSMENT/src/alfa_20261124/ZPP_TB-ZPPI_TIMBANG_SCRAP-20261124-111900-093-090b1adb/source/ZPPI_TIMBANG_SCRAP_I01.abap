*----------------------------------------------------------------------*
***INCLUDE ZPPI_TIMBANG_SCRAP_I01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1000 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXE'.
      IF R1 = 'X'.
        CALL SCREEN 1100.
      ELSEIF R2 = 'X'.
        CALL SCREEN 2000.
      ELSEIF R3 = 'X'.
        CALL SCREEN 3000.
      ENDIF.
    WHEN 'BACK'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1000  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_TIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_TIMBANG_MODIFY INPUT.

  IF WA_TIMBANG-GROSS <> 0.
    IF WA_TIMBANG-GROSS < WA_TIMBANG-WADAH.
      MESSAGE 'Berat Wadah tidak boleh lebih besar dari Gross Qty' TYPE 'I' DISPLAY LIKE 'E'.
*      SET CURSOR FIELD 'WA_TIMBANG-MENGE' LINE SY-LILLI.
    ELSE.
      WA_TIMBANG-MENGE = WA_TIMBANG-GROSS - WA_TIMBANG-WADAH.

      IF WA_TIMBANG-MENGE = 0.
        MESSAGE 'Quantity tidak boleh nol' TYPE 'I' DISPLAY LIKE 'E'.
*        SET CURSOR FIELD 'WA_TIMBANG-MENGE' LINE SY-LILLI.
      ENDIF.
    ENDIF.
  ENDIF.

  MODIFY IT_TIMBANG
    FROM WA_TIMBANG
    INDEX TC_TIMBANG-CURRENT_LINE.
ENDMODULE.                    "TC_TIMBANG_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_TIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_TIMBANG_MARK INPUT.
  DATA: G_TC_TIMBANG_WA2 LIKE LINE OF IT_TIMBANG.
  IF TC_TIMBANG-LINE_SEL_MODE = 1
  AND WA_TIMBANG-FLAG = 'X'.
    LOOP AT IT_TIMBANG INTO G_TC_TIMBANG_WA2
      WHERE FLAG = 'X'.
      G_TC_TIMBANG_WA2-FLAG = ''.
      MODIFY IT_TIMBANG
        FROM G_TC_TIMBANG_WA2
        TRANSPORTING FLAG.
    ENDLOOP.
  ENDIF.
  MODIFY IT_TIMBANG
    FROM WA_TIMBANG
    INDEX TC_TIMBANG-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TC_TIMBANG_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module  SLOCA_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SLOCA_HELP INPUT.

  PERFORM F_GET_RANGE_SLOC.

  IF S_PLANT <> ''.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD    = 'SLOCA'
        DYNPPROG    = SY-CPROG
        DYNPNR      = SY-DYNNR
        DYNPROFIELD = 'S_SLOCA'
        VALUE_ORG   = 'S'
      TABLES
        VALUE_TAB   = TSLOC.

    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

ENDMODULE.                 " SLOCA_HELP  INPUT

*&---------------------------------------------------------------------*
*&      Module  SMATNR_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SMATNR_HELP INPUT.

  DATA: XDYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD WITH HEADER LINE,
    DYNAME LIKE D020S-PROG.

  DYNAME = SY-REPID.

  XDYNPFIELDS-FIELDNAME = 'S_PLANT'.

  APPEND XDYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = DYNAME
      DYNUMB               = '1100'
      TRANSLATE_TO_UPPER   = 'X'
    TABLES
      DYNPFIELDS           = XDYNPFIELDS
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

  IF SY-SUBRC = 0.
    READ TABLE XDYNPFIELDS WITH KEY FIELDNAME = 'S_PLANT'.
    IF SY-SUBRC = 0.
      S_PLANT = XDYNPFIELDS-FIELDVALUE.
    ENDIF.
  ENDIF.

  IF S_PLANT IS INITIAL.
    MESSAGE 'Masukkan Plant terlebih dahulu' TYPE 'I'.
    EXIT.
  ENDIF.

  SELECT DISTINCT MARA~MATNR MAKT~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE TMATNR
    FROM MARA
         INNER JOIN MAKT ON MARA~MATNR = MAKT~MATNR
         INNER JOIN ZTMAP_FGRRECYCLE ON MARA~MATNR = ZTMAP_FGRRECYCLE~FGR_B_MATNR
    WHERE ZTMAP_FGRRECYCLE~WERKS = S_PLANT
    ORDER BY MARA~MATNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'MATNR'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'S_MATNR'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = TMATNR.

ENDMODULE.                 " SMATNR_HELP  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_LTIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_LTIMBANG_MARK INPUT.
  DATA: G_TC_LTIMBANG_WA2 LIKE LINE OF ITLOGTIMBANG.
  IF TC_LTIMBANG-LINE_SEL_MODE = 1
  AND WALOGTIMBANG-MARK = 'X'.
    LOOP AT ITLOGTIMBANG INTO G_TC_LTIMBANG_WA2
      WHERE MARK = 'X'.
      G_TC_LTIMBANG_WA2-MARK = ''.
      MODIFY ITLOGTIMBANG
        FROM G_TC_LTIMBANG_WA2
        TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY ITLOGTIMBANG
    FROM WALOGTIMBANG
    INDEX TC_LTIMBANG-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.                    "TC_LTIMBANG_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.
  CASE OK_CODE.
    WHEN 'GETTIPE'.
      CLEAR OK_CODE.
      REFRESH: ITAB_TIPE, ITAB_DIST.
      CLEAR: ITAB_TIPE, ITAB_DIST, PRSNTOTAL, PRSNORDTOTAL.

      " Validasi Net Qty tidak boleh kosong
      IF WA_TIMBANG-MENGE IS INITIAL.
        MESSAGE 'Net Qty tidak boleh kosong' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      " Validasi Start/End date
      IF S_SDATE IS INITIAL.
        MESSAGE 'Start date tidak boleh kosong..!' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      IF S_EDATE IS INITIAL.
        MESSAGE 'End date tidak boleh kosong..!' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      IF S_SDATE+4(2) <> S_EDATE+4(2).
        MESSAGE 'Start date dan End date tidak boleh beda bulan' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
      IF S_SDATE(6) < SY-DATUM(6)
        OR S_EDATE(6) < SY-DATUM(6).
        MESSAGE 'Bulan Start Date / End Date tidak boleh mundur' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.


      PERFORM F_GET_DATA_ALLOCATION.
      PERFORM F_GETTIPE.

    WHEN 'GETORD'.
      REFRESH : ITAB_DIST.
      CLEAR: ITAB_DIST, PRSNORDTOTAL, OK_CODE.

      IF WA_TIMBANG-MENGE IS INITIAL.
        MESSAGE 'Net Qty tidak boleh kosong..!' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      LOOP AT ITAB_TIPE WHERE PRSN > 0.
        EXIT.
      ENDLOOP.

      IF SY-SUBRC NE 0.
        MESSAGE 'Tidak ada Tipe Film yang Mendapat Alokasi Pembebanan. Silahkan Cek Inputan Anda!' TYPE 'I'.
        EXIT.
      ELSE.
        IF PRSNTOTAL <> 100.
          MESSAGE 'Total Persentase Alokasi Tipe Film Harus 100%. Silahkan Cek Inputan Anda!' TYPE 'I'.
          EXIT.
        ELSE.
          PERFORM F_CEKSTOCKRR CHANGING L_ERRNO.
          IF L_ERRNO <> -1.
            PERFORM F_GETORDER.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'TESTRUN'.
      CLEAR OK_CODE.
      CLEAR TOTALRR.
      LOOP AT ITAB_DIST.
        TOTALRR = TOTALRR + ITAB_DIST-MENGA.
      ENDLOOP.

      IF TOTALRR = WA_TIMBANG-MENGE.
        PERFORM F_TESTRUN.
      ELSE.
        MESSAGE 'Quantity Pembebanan Tidak Sama dengan Quantity Timbang. Silahkan Periksa Inputan Anda' TYPE 'I'.
        EXIT.
      ENDIF.
    WHEN 'EXEC'.
      CLEAR OK_CODE.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Confirmation of Execution'
          TEXT_QUESTION         = 'Apakah Anda Yakin untuk Mengeksekusi Timbang dengan data tersebut?'
          TEXT_BUTTON_1         = 'Ya'
          ICON_BUTTON_1         = 'ICON_OKAY'
          TEXT_BUTTON_2         = 'Tidak'
          ICON_BUTTON_2         = 'ICON_CANCEL'
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = ' '
        IMPORTING
          ANSWER                = MSG_ANSWER.

      IF MSG_ANSWER = '1'.
        CLEAR TOTALRR.
        LOOP AT ITAB_DIST.
          TOTALRR = TOTALRR + ITAB_DIST-MENGA.
        ENDLOOP.

        IF TOTALRR = WA_TIMBANG-MENGE.
          CLEAR : IS_TEST_RUN.

          IF IT_TIMBANG[] IS INITIAL.
            MESSAGE 'Tidak ada data.' TYPE 'I'.
          ELSE.
            PERFORM F_EXECUTE.
            IF L_ERRNO = -1.
              MESSAGE 'Data tidak tersedia.' TYPE 'I'.
            ELSE.
              PERFORM F_FIELD_CATALOG.
              PERFORM F_LAYOUT_TIMBANG.
              PERFORM F_LIST_DETAILTIMBANG.
            ENDIF.
          ENDIF.
          CLEAR: S_PLINE-LOW, ZCB_RR.
          REFRESH S_PLINE.
        ELSE.
          MESSAGE 'Quantity Pembebanan Tidak Sama dengan Quantity Timbang. Silahkan Periksa Inputan Anda' TYPE 'I'.
          EXIT.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_1200 INPUT.
  CASE OK_CODE.
    WHEN 'BACK' OR 'CANCEL'.
      CLEAR OK_CODE.
      REFRESH: ITAB_TIPE, ITAB_DIST.
      CLEAR: ITAB_TIPE, ITAB_DIST, PRSNTOTAL, PRSNORDTOTAL, ZCB_RR, SY-UCOMM.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " EXIT_9010  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.
  LOOP AT S_PLINE.
    TRANSLATE S_PLINE-LOW TO UPPER CASE.
    MODIFY S_PLINE.
  ENDLOOP.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      REFRESH IT_TIMBANG.
      CLEAR :S_PLANT, S_MATNR, S_SLOCA, S_SLOCT, S_NIKP, S_NIKPR.
      REFRESH: ITAB_TIPE, ITAB_DIST.
      CLEAR: ITAB_TIPE, ITAB_DIST, PRSNTOTAL, PRSNORDTOTAL.
      LEAVE TO SCREEN 1000.
    WHEN 'COPY'.
      CLEAR SY-UCOMM.
      PERFORM F_COPYDATA.
    WHEN 'DEL'.
      CLEAR SY-UCOMM.
      PERFORM F_DELETEDATA.
    WHEN 'EXECUTE'.
      CLEAR SY-UCOMM.

      " Validasi start and end date
      PERFORM F_CHECK_DATE CHANGING L_ERRNO.
      CHECK L_ERRNO NE -1.

      " Validasi kombinasi Plant, SLoc asal, dan Prod. Line
      " sesuai dengan tanable ZTMAP_SLOCWASTE
      PERFORM F_CHECK_PRODLINE CHANGING L_ERRNO.
      CHECK L_ERRNO NE -1.

      PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.
      PERFORM ZPRODLINE.

      IF L_ERRNO <> -1.
        PERFORM F_VALIDATE_TIMBANG CHANGING L_ERRNO.
        IF L_ERRNO <> -1.
          CALL SCREEN 1200.
        ENDIF.
      ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_TIPE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_TIPE_MODIFY INPUT.

  IF WA_TIPE-PRSN > 100.  "ADDED BY FATHIR ON 12.11.2020 - validasi % distribusi - TRDK917760
    MESSAGE 'Persentase tidak boleh lebih dari 100%' TYPE 'I'.
    CLEAR: ITAB_DIST.
    REFRESH: ITAB_DIST.
    EXIT.
  ENDIF.

  MODIFY ITAB_TIPE
    FROM WA_TIPE
    INDEX TC_TIPE-CURRENT_LINE.

  PRSNTOTAL = 0.
  LOOP AT ITAB_TIPE ASSIGNING <FS_TIPE>.
    PRSNTOTAL = PRSNTOTAL + <FS_TIPE>-PRSN.
    <FS_TIPE>-MENGE = <FS_TIPE>-PRSN / 100 * WA_TIMBANG-MENGE.
  ENDLOOP.
  CLEAR: ITAB_DIST.
  REFRESH: ITAB_DIST.

ENDMODULE.                    "TC_TIPE_MODIFY INPUT


*----------------------------------------------------------------------*
*  MODULE SUB_2000 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE SUB_2000 INPUT.
  LOOP AT L_LINE.
    IF L_LINE-LOW IS NOT INITIAL.
      TRANSLATE L_LINE-LOW TO UPPER CASE.
      MODIFY L_LINE.
    ENDIF.

  ENDLOOP.
ENDMODULE.                    "SUB_2000 INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      LEAVE TO SCREEN 0.
    WHEN 'GO'.
      CLEAR SY-UCOMM.

      PERFORM CHECK_AUTH_PLANT.
      PERFORM F_GET_LOG_TIMBANG.

      IF ITLOGTIMBANG[] IS NOT INITIAL.
        IF R_SCREEN IS NOT INITIAL.
          "Display to Screen
          PERFORM F_FIELD_CATALOG_LT.
          PERFORM F_LAYOUT_TIMBANG.
          PERFORM F_LIST_DETAIL_LTIMBANG.
        ELSEIF R_OLAP IS NOT INITIAL.
          PERFORM CONNECT_SQL.
          IF ITLOGTIMBANG[] IS NOT INITIAL.
              PERFORM INSERT_OLAP.
          ENDIF.

        ENDIF.
      ELSE.
        MESSAGE 'No Data Found' TYPE 'I'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_2000  INPUT

*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_3000 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE USER_COMMAND_3000 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      LEAVE TO SCREEN 0.
    WHEN 'GO'.
      PERFORM F_GETDATA_PRINT.


  ENDCASE.
ENDMODULE.                 " USER_COMMAND_3000  INPUT