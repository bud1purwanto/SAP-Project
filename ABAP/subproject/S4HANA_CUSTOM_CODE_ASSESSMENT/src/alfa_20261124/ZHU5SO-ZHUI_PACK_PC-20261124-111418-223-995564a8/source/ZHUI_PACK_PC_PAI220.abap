*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACK_PC_PAI220
*&---------------------------------------------------------------------*


*&spwizard: input modul for tc 'TBLPRINT'. do not change this line!
*&spwizard: mark table
MODULE TBLPRINT_MARK INPUT.
  DATA: G_TBLPRINT_WA2 LIKE LINE OF ITAB_PRINTLIST.
  IF TBLPRINT-LINE_SEL_MODE = 1
  AND ITAB_PRINTLIST-SELEC = 'X'.
    LOOP AT ITAB_PRINTLIST INTO G_TBLPRINT_WA2
      WHERE SELEC = 'X'.
      G_TBLPRINT_WA2-SELEC = ''.
      MODIFY ITAB_PRINTLIST
        FROM G_TBLPRINT_WA2
        TRANSPORTING SELEC.
    ENDLOOP.
  ENDIF.
  MODIFY ITAB_PRINTLIST
    INDEX TBLPRINT-CURRENT_LINE
    TRANSPORTING SELEC.
ENDMODULE.                    "TBLPRINT_mark INPUT

*&spwizard: input module for tc 'TBLPRINT'. do not change this line!
*&spwizard: process user command
MODULE TBLPRINT_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TBLPRINT'
                              'ITAB_PRINTLIST'
                              'SELEC'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TBLPRINT_user_command INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0220 INPUT.
  CASE SY-UCOMM.
    WHEN 'PRINT'.
      PERFORM F_HU_PRINT_MASS.

    WHEN 'SHOWALL'.
      PERFORM F_HU_PRINT_SELECTION USING V_YES.

    WHEN 'SHOWNOT'.
      PERFORM F_HU_PRINT_SELECTION USING V_NO.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0220  INPUT