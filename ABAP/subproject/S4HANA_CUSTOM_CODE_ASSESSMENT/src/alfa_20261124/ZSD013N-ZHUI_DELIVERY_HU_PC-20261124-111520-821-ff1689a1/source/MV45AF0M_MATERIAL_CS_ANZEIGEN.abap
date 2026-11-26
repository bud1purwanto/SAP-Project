*&---------------------------------------------------------------------*
*&      Form  MATERIAL_CS_ANZEIGEN
*&---------------------------------------------------------------------*
FORM MATERIAL_CS_ANZEIGEN TABLES T_MAT_CS_LISTE STRUCTURE MATS_CS_OV.

  LOCAL: FCODE.

  DATA: Y2 TYPE I.
  DATA: DA_LINES LIKE SY-TFILL.

  REFRESH MAT_CS_LISTE.
  CLEAR   MAT_CS_LISTE.
  MAT_CS_LISTE[] = T_MAT_CS_LISTE[].

  DESCRIBE TABLE MAT_CS_LISTE LINES DA_LINES.
  IF DA_LINES LT 10.
    Y2 = 8 + DA_LINES.
  ELSE.
    Y2 = 18.
  ENDIF.

  TCTRL_MAT_CS_ANZEIG_LIN1 = 1.
  CALL SCREEN 0810 STARTING AT 13 5
                   ENDING   AT 82 Y2.

  REFRESH T_MAT_CS_LISTE.
  CLEAR   T_MAT_CS_LISTE.
  T_MAT_CS_LISTE[] = MAT_CS_LISTE[].

ENDFORM.                               " MATERIAL_CS_ANZEIGEN