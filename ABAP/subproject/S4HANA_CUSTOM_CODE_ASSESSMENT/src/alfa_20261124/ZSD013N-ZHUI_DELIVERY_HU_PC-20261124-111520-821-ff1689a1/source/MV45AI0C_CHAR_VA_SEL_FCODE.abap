*----------------------------------------------------------------------*
*   INCLUDE MV45AI0C_CHAR_VA_SEL_FCODE                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHAR_VA_SEL_FCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHAR_VA_SEL_FCODE INPUT.

  CASE FCODE.
    WHEN 'CANC'.
      XMERKMAL[] = XMERKMAL_SAVE[].
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'OK  '.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                             " CHAR_VA_SEL_FCODE  INPUT









