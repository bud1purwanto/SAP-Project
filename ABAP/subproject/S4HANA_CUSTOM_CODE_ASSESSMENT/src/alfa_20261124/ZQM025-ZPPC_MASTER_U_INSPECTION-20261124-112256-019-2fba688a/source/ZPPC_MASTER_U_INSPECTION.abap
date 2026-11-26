*&---------------------------------------------------------------------*
*& Report  ZPPC_MASTER_U_INSPECTION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPC_MASTER_U_INSPECTION.

DATA: OK_CODE LIKE SY-UCOMM,
      RB1(1) TYPE C,
      RB2(1) TYPE C.

INCLUDE ZPPI_MASTER_U_INSPECTION_O01                       .  " PBO-Modules
INCLUDE ZPPI_MASTER_U_INSPECTION_I01                       .  " PAI-Modules
INCLUDE ZPPI_MASTER_U_INSPECTION_F01                       .  " FORM-Routines


START-OF-SELECTION.

  CALL SCREEN 100.