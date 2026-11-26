*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_DAT9001
*&---------------------------------------------------------------------*

*&spwizard: declaration of tablecontrol 'CTLTAB_PINS' itself
CONTROLS: CTLTAB_PINS TYPE TABLEVIEW USING SCREEN 9001.

*&spwizard: lines of tablecontrol 'CTLTAB_PINS'
DATA:     G_CTLTAB_PINS_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.