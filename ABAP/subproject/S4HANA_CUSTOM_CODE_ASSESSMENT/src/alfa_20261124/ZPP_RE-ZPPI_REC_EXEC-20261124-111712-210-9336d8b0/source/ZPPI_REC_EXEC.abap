*----------------------------------------------------------------------*
* Module Pool       ZPPI_REC_EXEC
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Recycle Execution Program
*
* Application Area - PP
* ABAPer           - Anthony W
* Date             - Sept 17, 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*----------------------------------------------------------------------*

INCLUDE ZPPI_REC_EXEC_TOP                       .  " global Data

INCLUDE ZPPI_REC_EXEC_O01                       .  " PBO-Modules
INCLUDE ZPPI_REC_EXEC_I01                       .  " PAI-Modules
INCLUDE ZPPI_REC_EXEC_F01                       .  " FORM-Routines


START-OF-SELECTION.
  CALL SCREEN 7000.
  INCLUDE ZBDCREX4.