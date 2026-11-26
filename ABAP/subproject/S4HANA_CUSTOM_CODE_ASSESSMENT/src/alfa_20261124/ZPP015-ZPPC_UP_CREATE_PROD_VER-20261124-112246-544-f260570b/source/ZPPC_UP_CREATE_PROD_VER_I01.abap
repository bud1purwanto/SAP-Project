*&---------------------------------------------------------------------*
*&  Include           ZPPC_UP_CREATE_PROD_VER_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK' OR 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'GO'.
      CALL SCREEN 200.
    WHEN 'INFO'.
      PERFORM F_PROG_INFO USING V_PROG.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'UPLOAD'.
      PERFORM F_CREATE_PROD_VER.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT


*&---------------------------------------------------------------------*
*&      Module  F4_FILE  INPUT
*&---------------------------------------------------------------------*
*       text
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