*----------------------------------------------------------------------*
*   INCLUDE MV45AI0M_MAT_CS_ANZEIG_FCODE                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MAT_CS_ANZEIG_FCODE  INPUT
*&---------------------------------------------------------------------*
MODULE MAT_CS_ANZEIG_FCODE INPUT.

  CASE FCODE.
    WHEN 'TAKE'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'CANC'.
      LOOP AT MAT_CS_LISTE WHERE POSNR EQ POSNR_LOW.
        CLEAR MAT_CS_LISTE-KWMENG.
        MODIFY MAT_CS_LISTE.
      ENDLOOP.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                             " MAT_CS_ANZEIG_FCODE  INPUT






