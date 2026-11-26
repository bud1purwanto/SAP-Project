*----------------------------------------------------------------------*
*   INCLUDE MV45AO0C_CHAR_VA_SEL_FIELD_SE                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHAR_VA_SEL_FIELD_SELECTION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHAR_VA_SEL_FIELD_SELECTION OUTPUT.

* LOOP AT SCREEN.
*   CHECK SCREEN-NAME = 'MATS_CS_OV-KWMENG' OR
*         SCREEN-NAME = 'MATS_CS_OV-LSTACS'.
*   IF MAT_CS_LISTE-UEPOS IS INITIAL.
*     SCREEN-INPUT = 0.
*     MODIFY SCREEN.
*   ENDIF.
* ENDLOOP.

ENDMODULE.                 " CHAR_VA_SEL_FIELD_SELECTION  OUTPUT