*----------------------------------------------------------------------*
*   INCLUDE IDOCDATA                                                   *
*----------------------------------------------------------------------*

DATA: BEGIN OF COMMON PART IDOCCOM.

DATA: BEGIN OF IDOC_EDIDC.
        INCLUDE STRUCTURE EDIDC.
DATA: END OF IDOC_EDIDC.

DATA: BEGIN OF IDOC_CONTROL OCCURS 3.
        INCLUDE STRUCTURE EDIDC.
DATA: END OF IDOC_CONTROL.

DATA: BEGIN OF IDOC_STATUS OCCURS 3.
        INCLUDE STRUCTURE BDIDOCSTAT.
DATA: END OF IDOC_STATUS.

DATA: BEGIN OF RETURN_VARIABLES OCCURS 3.
        INCLUDE STRUCTURE BDWFRETVAR.
DATA: END OF RETURN_VARIABLES.

DATA: BEGIN OF SERIALIZATION_INFO OCCURS 3.
        INCLUDE STRUCTURE BDI_SER.
DATA: END OF SERIALIZATION_INFO.

DATA: IDOC_NUMBER LIKE EDIDC-DOCNUM.

CONSTANTS: DA_IDOC_IN_SDTEXT(9) VALUE 'SDEDITEXT'.

TYPE-POOLS LV70T.

* Tabelle der nicht hinzugefügten Texte (kommt zurück von RV_TEXT_COPY)
data: text_error type  lv70t_ty_error_table.
* interne Tabelle um die Posguid aus dem Memory zu importieren und
* das Feld Posguid der Struktur Vbapd zu füllen.
DATA: BEGIN OF XPOSGUID OCCURS 0,
        POSEX LIKE VBAPVB-POSEX,
        POSGUID LIKE VBAPVB-POSGUID,
      END OF XPOSGUID.

DATA: END   OF COMMON PART IDOCCOM.