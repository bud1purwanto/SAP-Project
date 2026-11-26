*&---------------------------------------------------------------------*
*&  Include           ZPPI_PO_RAW_RECYCLE_I01
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODUL FOR TC 'TABCCTL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TABCCTL_MARK INPUT.
  DATA: G_TABCCTL_WA2 LIKE LINE OF ITDATA.
  IF TABCCTL-LINE_SEL_MODE = 1
  AND WADATA-MARK = 'X'.
    LOOP AT ITDATA INTO G_TABCCTL_WA2
      WHERE MARK = 'X'.
      G_TABCCTL_WA2-MARK = ''.
      MODIFY ITDATA
        FROM G_TABCCTL_WA2
        TRANSPORTING MARK SLOCGR.
    ENDLOOP.
  ENDIF.
  MODIFY ITDATA
    FROM WADATA
    INDEX TABCCTL-CURRENT_LINE.
ENDMODULE.                    "TABCCTL_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TCORDER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TCORDER_MODIFY INPUT.
  MODIFY ITORDER
    FROM WA_ORDER
    INDEX TCORDER-CURRENT_LINE.
ENDMODULE.                    "TCORDER_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TCORDER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TCORDER_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TCORDER'
                              'ITORDER'
                              ' '
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TCORDER_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'GO'.
      CLEAR OK_CODE.
      IF RAD1 = 'X'.
        CALL SCREEN 110.
      ELSEIF RAD2 = 'X'.
        CALL SCREEN 120.
      ENDIF.
    WHEN 'BACK'.
      CLEAR OK_CODE.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0110 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      CLEAR OK_CODE.
      PERFORM CLEAR_DATA.
      LEAVE TO SCREEN 100.

    WHEN 'EXE'.
      CLEAR OK_CODE.
      PERFORM F_GET_DATA.

    WHEN 'CREATE'.
      CLEAR OK_CODE.
      PERFORM F_CREATE_PRO.

    WHEN 'TECO'.
      CLEAR OK_CODE.
      PERFORM F_TECO.

    WHEN 'POSTING'.
      CLEAR OK_CODE.
      PERFORM F_POSTINGGIGR.

    WHEN 'CANCEL'.
      CLEAR OK_CODE.
      PERFORM F_CANCEL_GRGI.

    WHEN 'S_ALL'.
      CLEAR OK_CODE.
      PERFORM F_SALL.

    WHEN 'D_ALL'.
      CLEAR OK_CODE.
      PERFORM F_DALL.

    WHEN 'EXIT'.
      CLEAR OK_CODE.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.
  CASE OK_CODE.
    WHEN 'BACK'.
      CLEAR OK_CODE.
      PERFORM CLEAR_DATA.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      CLEAR OK_CODE.
      LEAVE PROGRAM.
    WHEN 'EXEO'.
      CLEAR OK_CODE.
      PERFORM F_GET_DATAORDER.

    WHEN 'RTECO'.
      CLEAR : SY-UCOMM,OK_CODE.
      PERFORM F_RTECO.

    WHEN 'RALV'.
      CLEAR : SY-UCOMM,OK_CODE.
      PERFORM F_DISPLAYDATA.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0120  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABCCTL_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCCTL_MODIFY INPUT.
  IF WADATA-SLOCGR IS NOT INITIAL.
    SELECT SINGLE T001L~LGOBE
      INTO WADATA-DESC
      FROM T001L
      WHERE T001L~LGORT = WADATA-SLOCGR.
  ENDIF.

  IF WADATA-CLABS > WADATA-CCLABS.
    MESSAGE 'Quantity yang diinput melebihi quantity stock!' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

  MODIFY ITDATA
  FROM WADATA
  INDEX TABCCTL-CURRENT_LINE.

ENDMODULE.                 " TABCCTL_MODIFY  INPUT

*&---------------------------------------------------------------------*
*&      Module  TCORDER_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCORDER_MARK INPUT.
  DATA: G_TCORDER_WA2 LIKE LINE OF ITORDER.
  IF TCORDER-LINE_SEL_MODE = 1
  AND WA_ORDER-MARK = 'X'.
    LOOP AT ITORDER INTO G_TCORDER_WA2
      WHERE MARK = 'X'.
      G_TCORDER_WA2-MARK = ''.
      MODIFY ITORDER
        FROM G_TCORDER_WA2
        TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY ITORDER
    FROM WA_ORDER
    INDEX TCORDER-CURRENT_LINE.
ENDMODULE.                 " TCORDER_MARK  INPUT