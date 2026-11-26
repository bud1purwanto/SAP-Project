*&---------------------------------------------------------------------*
*&  Include           ZHUI_TRS_HU_DV_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  F4_FILE  INPUT
*&---------------------------------------------------------------------*
*       Upload file BDC
*----------------------------------------------------------------------*
MODULE F4_FILE INPUT.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = FPATH.
  IF SY-SUBRC <> 0 OR FPATH EQ ''.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    LEAVE PROGRAM.
  ENDIF.

  MOVE FPATH TO P_FILE.
ENDMODULE.                 " F4_FILE  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_HELP  INPUT
*&---------------------------------------------------------------------*
*       Input Help for Storage Location
*----------------------------------------------------------------------*
MODULE F4_HELP INPUT.

  DATA : BEGIN OF ITSLOC OCCURS 0,
            SLOC  TYPE ZHU_MAPP-LGOR1,
            DESC  TYPE T001L-LGOBE,
         END OF ITSLOC.

  IF P1 = 'X'.  " Plant 1000
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
           T001L~LGOBE AS DESC
            INTO CORRESPONDING FIELDS OF TABLE ITSLOC
            FROM ZHU_MAPP
            JOIN  T001L ON ZHU_MAPP~LGOR2  =  T001L~LGORT
            WHERE ZHU_MAPP~LGOR2 LIKE '1%'
            AND ZHU_MAPP~TYPES = '1'.

  ELSEIF P2 = 'X'.  "PLANT 2000
    SELECT DISTINCT ZHU_MAPP~LGOR2 AS SLOC
          T001L~LGOBE AS DESC
          INTO CORRESPONDING FIELDS OF TABLE ITSLOC
          FROM ZHU_MAPP
          JOIN  T001L ON ZHU_MAPP~LGOR2  =  T001L~LGORT
          WHERE ZHU_MAPP~LGOR2 LIKE '2%'
          AND ZHU_MAPP~TYPES ='1'.

  ENDIF.

  DATA : V_DYNINDEX TYPE SY-STEPL.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL = V_DYNINDEX.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'SLOC'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'WADATA-SLOCT '
      STEPL       = V_DYNINDEX
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = ITSLOC.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.                 " F4_HELP  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TCHU'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TCHU_MARK INPUT.
  DATA: G_TCHU_WA2 LIKE LINE OF ITDATA.
  IF TCHU-LINE_SEL_MODE = 1 AND
    WADATA-MARK = 'X'.
    LOOP AT ITDATA INTO G_TCHU_WA2
      WHERE MARK = 'X'.
      G_TCHU_WA2-MARK = ''.
      MODIFY ITDATA
        FROM G_TCHU_WA2
        TRANSPORTING MARK SLOCT.
    ENDLOOP.
  ENDIF.
  MODIFY ITDATA
    FROM WADATA
    INDEX TCHU-CURRENT_LINE.
ENDMODULE.                    "TCHU_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA : WERKS TYPE WERKS_D.

  IF P1 = 'X'.
    WERKS = '1000'.
  ELSEIF P2 = 'X'.
    WERKS = '2000'.
  ENDIF.

  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR OKCODE.
      LEAVE TO SCREEN 0.
    WHEN 'GDTA'.
      CLEAR OKCODE.
*     -- ditambahkeun bap (26 des 12)
      AUTHORITY-CHECK OBJECT 'Z_WERKS' ID 'ZWERKS' FIELD WERKS.
      IF SY-SUBRC NE 0.
        MESSAGE 'No Authorization to process data' TYPE 'W'.
        RETURN.
      ENDIF.
*      --
      PERFORM F_DATA_RETRIEVAL.
    WHEN 'TRNS'.
      CLEAR OKCODE.
      PERFORM F_GETDATATRANSFER.
    WHEN 'S_ALL'.
      CLEAR OKCODE.
      PERFORM F_SELECT_ALL.
    WHEN 'D_ALL'.
      CLEAR OKCODE.
      PERFORM F_DESELECT_ALL.
    WHEN 'CLEAR'.
      CLEAR OKCODE.
      PERFORM F_CLEARDATA.
    WHEN 'SCA'.
      CLEAR OKCODE.
      PERFORM F_SORT_ASC.
    WHEN 'SDC'.
      CLEAR OKCODE.
      PERFORM F_SORT_DSC.
    WHEN 'FIND'.
      CLEAR OKCODE.
      PERFORM F_FIND_HU.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.
  CASE OKCODE.
    WHEN 'BACK'.
      CLEAR OKCODE.
      LEAVE TO SCREEN 0.
    WHEN 'EXE'.
      CLEAR OKCODE.
      PERFORM F_UPLOAD_DATA.
      P_FILE = FPATH.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT