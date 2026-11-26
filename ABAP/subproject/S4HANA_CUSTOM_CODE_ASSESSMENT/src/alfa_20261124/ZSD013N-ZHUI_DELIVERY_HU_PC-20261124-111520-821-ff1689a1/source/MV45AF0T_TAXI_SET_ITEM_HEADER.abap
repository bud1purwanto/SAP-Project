*&---------------------------------------------------------------------*
*&      Form  TAXI_SET_ITEM_HEADER
*&---------------------------------------------------------------------*
* Funktion: Kopiere die Daten des Headersubscreens für Positionsbilder
*           in unter dem in der Konstanten <C_TAXI_ITEM_HEADER_ID>
*           hinterlegten Schlüssel in das ABAP-Memory.
*----------------------------------------------------------------------*
FORM TAXI_SET_ITEM_HEADER.
  EXPORT VBAP-POSNR
         VBAP-MATNR
         VBAP-PSTYV
         VBAP-ARKTX
         TVAPT-VTEXT
      TO MEMORY ID C_TAXI_ITEM_HEADER_ID.
ENDFORM.