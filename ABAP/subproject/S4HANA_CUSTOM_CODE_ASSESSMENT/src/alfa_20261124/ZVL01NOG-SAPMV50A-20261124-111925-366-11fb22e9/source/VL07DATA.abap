*-----------------------------------------------------------------------
*        Daten für Wareneingang auf Lieferung
*-----------------------------------------------------------------------

TABLES: MSEG, *MSEG,
        T158.
DATA: BEGIN OF COMMON PART VL07COM.

DATA: BEGIN OF XMSEG OCCURS 20.
        INCLUDE STRUCTURE MSEG.
DATA: END OF XMSEG.


* Tabelle der Einkaufsbelegpositionen
DATA: BEGIN OF XEKPO OCCURS 1.
        INCLUDE STRUCTURE EKPO.
DATA: END OF XEKPO.
* Tabellen der Einkaofsbelegpostionen - Lieferplaneinteilungen
DATA: BEGIN OF XEKET OCCURS 1.
        INCLUDE STRUCTURE EKET.
DATA: END OF XEKET.

DATA: END OF COMMON PART.
*eject