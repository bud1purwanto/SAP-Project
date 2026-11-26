
***********************************************************************
*                                                                     *
* PBO Module zur Ablaufsteuerung - Versand                            *
*     Module alphabetisch geordnet; hier beginnend mit "T"            *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       MODULE TRANSAKTION_INIT                                       *
*---------------------------------------------------------------------*
*       Initialwerte auf Anforderungsbild setzen.                     *
*---------------------------------------------------------------------*
MODULE TRANSAKTION_INIT OUTPUT.

  GS_MHPAR-GLOMD = GC_GLOMD-DIALOG.
  PERFORM TRANSAKTION_INIT USING SY-TCODE.

* SPE100 MP 23.02.2005 Set indicator for dialog processing
  V50AGL-DIALOG = CHARX.

ENDMODULE.
*eject.

*---------------------------------------------------------------------*
*       MODULE TRANSAKTMENU_INIT                                      *
*---------------------------------------------------------------------*
*       Initialwerte für VL00                                         *
*---------------------------------------------------------------------*
MODULE TRANSAKTMENU_INIT OUTPUT.

  PERFORM TRANSAKTMENU_INIT.

ENDMODULE.
*eject.

*&---------------------------------------------------------------------*
*&      Module  TAXI_INITIALIZE_CARRIERSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       Initialization of the tabstrip control
*----------------------------------------------------------------------*
MODULE TAXI_INITIALIZE_CARRIERSCREEN OUTPUT.

  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.
  PERFORM TAXI_CHANGE_SUBSCREEN.

ENDMODULE.                 " TAXI_INITIALIZE_CARRIERSCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TRACKING_SUBSCREEN_SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE TRACKING_SUBSCREEN_SET_DATA OUTPUT.

  PERFORM TRACKING_SUBSCREEN_SET_DATA.

ENDMODULE.                 " TRACKING_SUBSCREEN_SET_DATA  OUTPUT