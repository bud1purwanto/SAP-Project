*----------------------------------------------------------------------*
* Interface ZPPI_TIMBANG_SCRAP
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
* Description      : Timbang Scrap
*
* Application Area - PP
* ABAPer           -
* Date             -
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*

INCLUDE ZPPI_TIMBANG_SCRAP_TOP.

INCLUDE ZABAPALV.

INCLUDE ZPPI_TIMBANG_SCRAP_O01.
INCLUDE ZPPI_TIMBANG_SCRAP_I01.
INCLUDE ZPPI_TIMBANG_SCRAP_F01.
INCLUDE ZPPI_TIMBANG_SCRAP_ALV.

START-OF-SELECTION.
  CALL SCREEN 1000.
END-OF-SELECTION.