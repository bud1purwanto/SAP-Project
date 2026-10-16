*----------------------------------------------------------------------*
* Report  ZPPI_SR_PROCESS
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Description      : Program Slitting Process - Batch Defined
*                    Enhancement
* Application Area - PP
* ABAPer           - William
* Date             - August, 06 2012
*----------------------------------------------------------------------*
* Amendment History                                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*----------------------------------------------------------------------*

INCLUDE ZPPI_SR_PROCESS_TOP                     .    " global Data

* INCLUDE ZPPI_SR_PROCESS_O01                     .  " PBO-Modules
* INCLUDE ZPPI_SR_PROCESS_I01                     .  " PAI-Modules
INCLUDE ZPPI_SR_PROCESS_F01                     .  " FORM-Routines

*******************
START-OF-SELECTION.
*******************
  CLEAR: FLAG.
  PERFORM VALIDASI_ORDER_TYPE CHANGING FLAG.
  IF FLAG EQ SPACE.
    PERFORM READ_ORDER.
    PERFORM DISPLAY_ORIGINAL_ORDER.
  ENDIF.
*****************
END-OF-SELECTION.
*****************