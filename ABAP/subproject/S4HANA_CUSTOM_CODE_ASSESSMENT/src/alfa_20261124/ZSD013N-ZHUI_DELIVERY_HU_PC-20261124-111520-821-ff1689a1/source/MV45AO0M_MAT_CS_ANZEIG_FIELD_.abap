*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_CS_ANZEIG_FIELD_                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MAT_CS_ANZEIG_FIELD_SELECTION  OUTPUT
*&---------------------------------------------------------------------*
MODULE MAT_CS_ANZEIG_FIELD_SELECTION OUTPUT.

  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'MATS_CS_OV-KWMENG' OR
          SCREEN-NAME = 'MATS_CS_OV-LSTACS'.
    IF NOT MAT_CS_LISTE-POSNR IS INITIAL.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " MAT_CS_ANZEIG_FIELD_SELECTION  OUTPUT












