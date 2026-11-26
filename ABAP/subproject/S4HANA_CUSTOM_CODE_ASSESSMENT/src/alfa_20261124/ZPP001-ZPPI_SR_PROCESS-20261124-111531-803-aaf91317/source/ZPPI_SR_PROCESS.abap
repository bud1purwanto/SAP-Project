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
  CLEAR: flag.
  PERFORM validasi_order_type CHANGING flag.
  IF flag eq space.
    PERFORM read_order.
    PERFORM display_original_order.
  ENDIF.
*****************
END-OF-SELECTION.
*****************