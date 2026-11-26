*&---------------------------------------------------------------------*
*&      Module  TAXI_GET_ITEM_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
* Funktion:  Wenn das Pool-globale Flag TAXI_HEADER_INITIALIZED
*            nicht gesetzt ist, bedeutet dies, dass der Subscreen
*            aus einem fremden Pool gerufen wurde und ein Rollbereichs-
*            wechsel stattgefunden hat. In diesem Fall muss der Inhalt
*            der Felder des Kopfsubscreens aus dem ABAP-Memory unter
*            dem Schlüssel TAXI_ITEM_HEADER bestimmt werden.
*
MODULE TAXI_GET_ITEM_HEADER OUTPUT.
  IF TAXI_HEADER_INITIALIZED IS INITIAL.

     IMPORT VBAP-POSNR
            VBAP-MATNR
            VBAP-PSTYV
            VBAP-ARKTX
            TVAPT-VTEXT
       FROM MEMORY ID C_TAXI_ITEM_HEADER_ID.

* Flag wird gesetzt, da Daten nun im aktuellen Rollbereich.
     TAXI_HEADER_INITIALIZED = 'X'.

  ENDIF.

ENDMODULE.                 " TAXI_GET_ITEM_HEADER  OUTPUT