*----------------------------------------------------------------------*
* Interface ZPPI_REC_MAT_BY_PROD
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : Timbang dan Jual Scrap
*
* Application Area - PP
* ABAPer           - Rimbun Gracia Siahaan -> timbang
* ABAPer           - Fina Oktavia Manurung -> sale
* Date             - August 13, 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*

INCLUDE ZPPI_REC_MAT_BY_PROD_TOP.
INCLUDE ZABAPALV.
INCLUDE ZPPI_REC_MAT_BY_PROD_O01.
INCLUDE ZPPI_REC_MAT_BY_PROD_I01.
INCLUDE ZPPI_REC_MAT_BY_PROD_F01.
INCLUDE ZPPI_REC_MAT_BY_PROD_ALV.

START-OF-SELECTION.
  CALL SCREEN 1000.
END-OF-SELECTION.