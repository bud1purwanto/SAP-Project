*&---------------------------------------------------------------------*
*&  Include           ZPPI_UPLOAD_MASTERRECIPE_I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXECUTE'.
      IF RCR = 'X'.
        CALL SCREEN 200.
      ELSEIF RCH = 'X'.
        CALL SCREEN 400.
      ELSEIF RB3 = 'X'.
        CALL SCREEN 300.
      ENDIF.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE SY-UCOMM.
    WHEN 'UPLOAD'.
      CALL SCREEN 300.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  CASE SY-UCOMM.
    WHEN 'UPLOADC'.
      IF CSR = 'X'.
        PERFORM F_UPLOAD_CREATE_SR.
      ELSEIF CCR = 'X'.
        PERFORM F_UPLOAD_CREATE_CR.
      ELSEIF RB3 = 'X'.
        PERFORM F_DELETE_MR.
      ENDIF.

    WHEN 'BACK'.
      CLEAR P_FILE.
      LEAVE TO SCREEN 200.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT

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


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CASE SY-UCOMM.
    WHEN 'EXECUTE'.
      CALL SCREEN 500.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0400  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CASE SY-UCOMM.
    WHEN 'UPLOAD'.
      IF RB1 = 'X'.
        PERFORM F_CHANGE_RB1.
      ELSEIF RB2 = 'X'.
        PERFORM F_CHANGE_RB2.
      ENDIF.
    WHEN 'BACK'.
      LEAVE TO SCREEN 400.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_BROWSE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_BROWSE INPUT.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'C:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = ZFPATH
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

  IF ZFPATH IS INITIAL.
    MESSAGE 'File not found' TYPE 'I'.
  ELSE.

    MOVE ZFPATH TO FNAME.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME            = FNAME
        FILETYPE            = 'ASC'
        HAS_FIELD_SEPARATOR = 'X'
      TABLES
        DATA_TAB            = IT_DETAIL
      EXCEPTIONS
        CONVERSION_ERROR    = 1
        INVALID_TABLE_WIDTH = 2
        INVALID_TYPE        = 3
        NO_BATCH            = 4
        UNKNOWN_ERROR       = 5
        FILE_OPEN_ERROR     = 6
        FILE_READ_ERROR     = 7
        OTHERS              = 8.

    IF SY-SUBRC <> 0.
      MESSAGE I000(0K) WITH 'File cannot be opened'.
      STOP.
    ENDIF.

  ENDIF.
ENDMODULE.                 " F4_BROWSE  INPUT