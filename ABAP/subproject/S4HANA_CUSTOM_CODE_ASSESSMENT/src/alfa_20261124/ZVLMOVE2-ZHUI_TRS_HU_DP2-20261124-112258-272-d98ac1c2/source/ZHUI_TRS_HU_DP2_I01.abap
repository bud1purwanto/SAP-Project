*&---------------------------------------------------------------------*
*&  Include           ZHUI_TRS_HU_DP2_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  F4_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_HELP INPUT.

  PERFORM F_GET_TYPE_SLOC.

  CLEAR : ITSLOC.
  REFRESH : ITSLOC.

  "GET DATA SLOC
  CLEAR : ITSLOC, WSLOC.
  REFRESH : ITSLOC.

  IF RW = 'X'.
    " GET DATA SLOC TUJUAN FOR WARU AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '1%'
      AND ZHU_MAPP~WERK2 = '1000'
      AND ZHU_MAPP~TYPES = TYPE.

  ELSEIF RK = 'X'.

    " GET DATA SLOC TUJUAN FOR KRIAN AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '2%'
      AND ZHU_MAPP~WERK2 = '2000'
      AND ZHU_MAPP~TYPES = TYPE.

  ELSEIF RJ = 'X'.

    " GET DATA SLOC TUJUAN FOR JAKARTA AREA
    CLEAR : ITSLOC, WSLOC.
    REFRESH ITSLOC.
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
      INTO CORRESPONDING FIELDS OF TABLE ITSLOC
      FROM ZHU_MAPP
      WHERE ZHU_MAPP~LGOR2 LIKE '3%'
      AND ZHU_MAPP~TYPES = TYPE.
  ENDIF.

  IF ITSLOC[]  IS NOT INITIAL.
    LOOP AT ITSLOC.
      SELECT SINGLE T001L~LGOBE AS DESC
        INTO ITSLOC-DESC
        FROM T001L
        WHERE T001L~LGORT = ITSLOC-SLOC.

      MODIFY ITSLOC.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        RETFIELD    = 'SLOC'
        DYNPPROG    = SY-CPROG
        DYNPNR      = SY-DYNNR
        DYNPROFIELD = 'TSLOC'
        VALUE_ORG   = 'S'
      TABLES
        VALUE_TAB   = ITSLOC.

    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.

ENDMODULE.                 " F4_HELP  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR OKCODE.
      LEAVE PROGRAM.
    WHEN 'EXE1'.
      "- putra aditya bagus
      DATA : WERKS TYPE WERKS_D.
      IF RW = 'X'.
        WERKS = '1000'.
      ELSEIF RK = 'X'.
        WERKS = '2000'.
      ELSEIF RJ = 'X'.
        WERKS = '3000'.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD WERKS.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'W'.
      ELSE.

        CLEAR OKCODE.
        PERFORM EXECUTE1.
      ENDIF.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR : OKCODE,  ITDATA.
      REFRESH ITDATA.
      LEAVE TO SCREEN 0.
    WHEN 'EXE2'.
      CLEAR OKCODE.
      REFRESH ITDATA.
      PERFORM F_TRANSFERHU.
    WHEN 'EXIT'.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR : OKCODE.
      REFRESH ITDATA.
      LEAVE TO SCREEN 0.
    WHEN 'EXE3'.
      CLEAR : OKCODE.
      REFRESH ITDATA.
      PERFORM F_TRANSFERHU.

    WHEN 'EXIT'.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR : OKCODE ,ITDATA.
      REFRESH ITDATA.
      LEAVE TO SCREEN 0.
    WHEN 'EXE4'.
      CLEAR OKCODE.
      REFRESH ITDATA.
      PERFORM F_TRANSFERHU.

    WHEN 'EXIT'.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0400  INPUT