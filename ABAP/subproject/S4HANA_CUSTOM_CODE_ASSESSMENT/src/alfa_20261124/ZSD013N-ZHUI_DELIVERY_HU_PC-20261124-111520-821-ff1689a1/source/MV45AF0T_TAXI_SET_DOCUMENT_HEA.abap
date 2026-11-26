*&---------------------------------------------------------------------*
*&      Form  TAXI_SET_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*
* Funktion: Kopiere die Daten des Headersubscreens für Kopfbilder
*           in unter dem in der Konstanten <C_TAXI_DOCUMENT_HEADER_ID>
*           hinterlegten Schlüssel in das ABAP-Memory.
*
FORM TAXI_SET_DOCUMENT_HEADER.
  EXPORT RV45A-TXT_VBELN
         VBAK-VBELN
         VBAK-BSTNK
         KUAGV-KUNNR
         KUAGV-NAME1
         KUAGV-ORT01
      TO MEMORY ID C_TAXI_DOCUMENT_HEADER_ID.
ENDFORM.