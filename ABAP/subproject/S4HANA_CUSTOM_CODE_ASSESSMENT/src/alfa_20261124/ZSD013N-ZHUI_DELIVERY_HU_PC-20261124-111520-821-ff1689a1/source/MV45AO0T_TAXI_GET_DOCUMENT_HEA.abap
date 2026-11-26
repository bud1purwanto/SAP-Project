*&---------------------------------------------------------------------*
*&      Module  TAXI_GET_DOCUMENT_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
* Funktion:  Wenn das Pool-globale Flag TAXI_HEADER_INITIALIZED
*            nicht gesetzt ist, bedeutet dies, dass der Subscreen
*            aus einem fremden Pool gerufen wurde und ein Rollbereichs-
*            wechsel stattgefunden hat. In diesem Fall muss der Inhalt
*            der Felder des Kopfsubscreens aus dem ABAP-Memory unter
*            dem Schlüssel TAXI_DOCUMENT_HEADER bestimmt werden.
*
MODULE TAXI_GET_DOCUMENT_HEADER OUTPUT.
  IF TAXI_HEADER_INITIALIZED IS INITIAL.

     IMPORT RV45A-TXT_VBELN
            VBAK-VBELN
            VBAK-BSTNK
            KUAGV-KUNNR
            KUAGV-NAME1
            KUAGV-ORT01
       FROM MEMORY ID C_TAXI_DOCUMENT_HEADER_ID.

* Flag wird gesetzt, da Daten nun im aktuellen Rollbereich.
     TAXI_HEADER_INITIALIZED = 'X'.

  ENDIF.

ENDMODULE.                 " TAXI_GET_DOCUMENT_HEADER  OUTPUT