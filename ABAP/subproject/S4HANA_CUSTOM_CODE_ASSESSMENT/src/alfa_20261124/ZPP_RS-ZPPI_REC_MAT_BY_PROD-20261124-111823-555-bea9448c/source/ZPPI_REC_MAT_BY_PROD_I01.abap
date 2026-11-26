*----------------------------------------------------------------------*
***INCLUDE ZPPI_REC_MAT_BY_PROD_I01 .
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
        CALL SCREEN 1200.
      ELSEIF R3 = 'X'.

        "CEK MATERIAL DOKUMEN TIMBANG
        REFRESH S_MBLNR.
        IF T_MATDOC[] IS NOT INITIAL.
          LOOP AT T_MATDOC.
            CLEAR WR_MATDOC.
            WR_MATDOC-SIGN   = 'I'.
            WR_MATDOC-OPTION = 'EQ'.
            WR_MATDOC-LOW    = T_MATDOC-MATDOC.
            APPEND WR_MATDOC TO S_MBLNR.
          ENDLOOP.
        ENDIF.
        REFRESH T_MATDOC.
*        CALL SCREEN 1300.
        CALL TRANSACTION 'ZPPI_SALE'.
      ELSEIF R4 = 'X'.
        CALL SCREEN 1400.
      ELSEIF R5 = 'X'.
        CALL SCREEN 1500.
      ELSEIF R6 = 'X'.
        CALL SCREEN 1600.
      ELSEIF R7 = 'X'.
        SUBMIT ZPPI_TRANSFER_WASTE.
      ENDIF.
    WHEN 'BACK'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1000  INPUT






*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      REFRESH IT_TIMBANG.
      CLEAR :S_PLANT, S_MATNR, S_SLOCA, S_SLOCT, S_NIKP, S_NIKPR.
      LEAVE TO SCREEN 1000.
    WHEN 'COPY'.
      CLEAR SY-UCOMM.
      PERFORM F_COPYDATA.
    WHEN 'DEL'.
      CLEAR SY-UCOMM.
      PERFORM F_DELETEDATA.
    WHEN 'TESTRUN'.
      CLEAR SY-UCOMM.
      PERFORM F_TESTRUN.
    WHEN 'EXECUTE'.
      CLEAR SY-UCOMM.
      PERFORM F_EXECUTETIMBANG.
    WHEN 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1600 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN 'EXE'.
      PERFORM GET_DATA_PRINT.
      PERFORM DISPLAY_DATA_PRINT.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1600  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1500 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN 'EXE'.
      PERFORM GET_DATA.
      PERFORM DISPLAY_DATA.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1500  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1400 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN 'EXE'.
      PERFORM GET_DATA_ALL.
      PERFORM DISPLAY_ALL.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1400  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1300 INPUT.

  IF ZWERKS EQ '1000'.
    ZVSTEL = '1000'.
    ZLGORT = '1700'.
  ELSEIF ZWERKS EQ '2000'.
    ZVSTEL = '2000'.
    ZLGORT = '2700'.
  ELSEIF ZWERKS EQ '3000'.
    MESSAGE 'Delivery scrap can only be done from plant 1000 or 2000.' TYPE 'E'.
  ELSE.
    ZVSTEL = ''.
  ENDIF.

  SELECT SINGLE KNA1~NAME1
    INTO ZNAME1
    FROM KNA1
    WHERE KNA1~KUNNR = ZKUNNR.

  CASE SY-UCOMM.
    WHEN 'EXE1'.
      PERFORM UPLOAD_DATA.
      IF V_DELIVERY NE ''.
        PERFORM CHANGE_DATA.
        CLEAR : V_KOSTK.
        SELECT SINGLE VBUK~KOSTK
          INTO V_KOSTK
          FROM VBUK
          WHERE VBUK~VBELN = V_DELIVERY.
      ENDIF.
      PERFORM SAVE_DATA.
      IF V_DELIVERY NE ''.
        SET PARAMETER ID 'VL' FIELD V_DELIVERY.
        CALL TRANSACTION 'ZVL02NOG' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE 'ODO can not created.' TYPE 'I'.
      ENDIF.
**      ENDIF.
    WHEN 'BACK'.
      CALL SCREEN 1000.
  ENDCASE.
  CLEAR : SY-UCOMM.

ENDMODULE.                 " USER_COMMAND_1300  INPUT



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
*&      Module  INITIAL_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE INITIAL_LGORT INPUT.
*  CLEAR S_SLOCT.
*  IF S_PLANT = '1000'.
*    S_SLOCT = '1700'.
*  ELSEIF S_PLANT = '2000'.
*    S_SLOCT  = '2701'.
*  ELSE.
*    S_SLOCT = ''.
*  ENDIF.
*ENDMODULE.                 " INITIAL_LGORT  INPUT

**&---------------------------------------------------------------------*
**&      Module  INITIAL_LGORT  OUTPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE INITIAL_LGORT OUTPUT.
*  CLEAR S_SLOCT.
*  IF S_PLANT = '1000'.
*    S_SLOCT = '1700'.
*  ELSEIF S_PLANT = '2000'.
*    S_SLOCT  = '2701'.
*  ELSE.
*    S_SLOCT = ''.
*  ENDIF.
*ENDMODULE.                 " INITIAL_LGORT  OUTPUT
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
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      LEAVE TO SCREEN 0.
    WHEN 'GO'.
      CLEAR SY-UCOMM.
      PERFORM F_DISPLAY_LOG.
*  	WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1200  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1211  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_1211 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      CLEAR SY-UCOMM.
      LEAVE TO SCREEN 0.
    WHEN 'C_TEST'.
      CLEAR SY-UCOMM.
      PERFORM F_TEST_CTIMBANG.
    WHEN 'C_EXE'.
      CLEAR SY-UCOMM.
      PERFORM F_CANCEL_TIMBANG.
    WHEN 'S_ALL'.
      CLEAR SY-UCOMM.
      PERFORM F_SELECT_ALL.
    WHEN 'D_ALL'.
      CLEAR SY-UCOMM.
      PERFORM F_DESELECT_ALL.
    WHEN 'C_PRINT'.
      CLEAR SY-UCOMM.
      PERFORM F_PRINT.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1211  INPUT

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
*&      Module  USER_COMMAND_1700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1700 INPUT.
  IF ZWERKS_ EQ '1000'.
    ZVSTEL_ = '1000'.
    ZLGORT_ = '1700'.
  ELSEIF ZWERKS_ EQ '2000'.
    ZVSTEL_ = '2000'.
    ZLGORT_ = '2700'.
  ELSEIF ZWERKS_ EQ '3000'.
    MESSAGE 'Delivery scrap can only be done from plant 1000 or 2000.' TYPE 'E'.
  ELSE.
    ZVSTEL_ = ''.
  ENDIF.

  CLEAR : ZNAME1_.
  SELECT SINGLE KNA1~NAME1
    INTO ZNAME1_
    FROM KNA1
    WHERE KNA1~KUNNR = KNA1-KUNNR.

  CASE SY-UCOMM.
    WHEN 'EXE1'.
      IF FLAG2 = 'X'.
        PERFORM UPLOAD_RUN.
        IF V_DELIVERY NE ''.
          PERFORM CHANGE_DATA.
          CLEAR : V_KOSTK.
          SELECT SINGLE VBUK~KOSTK
            INTO V_KOSTK
            FROM VBUK
            WHERE VBUK~VBELN = V_DELIVERY.
        ENDIF.
        PERFORM SAVE_DATA_RUN.
        IF V_DELIVERY NE ''.
          SET PARAMETER ID 'VL' FIELD V_DELIVERY.
          CALL TRANSACTION 'ZVL02NOG' AND SKIP FIRST SCREEN.
        ELSE.
          MESSAGE 'ODO can not created.' TYPE 'I'.
        ENDIF.
      ELSE.
        PERFORM UPLOAD_TEST.
      ENDIF.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_1700  INPUT


*&---------------------------------------------------------------------*
*&      Module  HELP_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HELP_KUNNR INPUT.
  "-GET DATA KUNNR
  SELECT
    KNA1~KUNNR
    KNA1~NAME1
    INTO CORRESPONDING FIELDS OF TABLE IT_ZKUNNR
    FROM KNA1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'KUNNR'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'ZKUNNR'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_ZKUNNR.

ENDMODULE.                 " HELP_KUNNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  EX_1700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EX_1700 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EX_1700  INPUT


*&---------------------------------------------------------------------*
*&      Module  F4_CUST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_CUST INPUT.

  DATA : V_KUNNR TYPE HELP_INFO-DYNPROFLD.
  DATA : IT_KUNNR_ TYPE IT_KUNNR OCCURS 0 WITH HEADER LINE.
  REFRESH : IT_KUNNR_.

  "-GET DATA AUART
  SELECT
    KNA1~KUNNR
    KNA1~NAME1

    INTO CORRESPONDING FIELDS OF TABLE IT_KUNNR_
    FROM KNA1.

  SORT IT_KUNNR_ ASCENDING BY KUNNR.

  V_KUNNR = ZKUNNR_.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'AUART'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = V_KUNNR
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_KUNNR_.

  IF SY-SUBRC <> 0.
*           Implement suitable error handling here
  ENDIF.



ENDMODULE.                 " F4_CUST  INPUT