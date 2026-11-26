*-----------------------------------------------------------------------
*        Datenbank-Tabelle VBKD
*-----------------------------------------------------------------------
* Aktionsfindung
TYPE-POOLS WAKTP .

TABLES:  VBKD,
        *VBKD,
         tbmot,
         TINC,
         TVZB,
         TVZBT,
         T042Z,
         T052,
         T151,
         T151T,
         T171,
         T171T,
         t173,
         T188,
         T188T,
         T189,
         T189T,
         tvsak,
         WAKT,                          "Aktionstext
         WAKH,                          "Aktionskopf
         WAKP,                          "Aktionsposition
         WWMIT,                         "Produktkatalogtext
         TSAB,
         TSABT,
         AD01C_PRTX,                    "Text zu DP-Profil
         J_1AINFT21,                    "Text Indizierungstyp S'amerika
         J_1AFITPVT,                    "Text Steuertyp (Argentinien)
         J_1ARFZT,                      "Text Steuerbefr'grund (Arg.)
         J_1AGICDU,                     "Text                  (Arg.)
         J_1ADTYPT,                     "Text Verteilungsart   (Arg.)
         J_1ATXRELT.                    "Text Klassif. Steuern (Arg.)

DATA: BEGIN OF COMMON PART VBKDCOM.
* Alter Tabellenstand beim Ändern

DATA:    BEGIN OF YVBKD OCCURS 1.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF YVBKD.

* Aktueller Tabellenstand

DATA:    BEGIN OF XVBKD OCCURS 5.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF XVBKD.

ENHANCEMENT-POINT VBKDDATA_02 SPOTS ES_VBKDDATA STATIC INCLUDE BOUND.
* SVBKD-TABIX wird zunächst nur als Schalter für Anlegen oder
* Ändern benutzt.

DATA:   BEGIN OF SVBKD OCCURS 1,
          TABIX LIKE SY-TABIX,
        END OF SVBKD.

DATA: UPD_VBKD.                  " Für Änderungsbelege

* Hauptposition
DATA:    BEGIN OF HVBKD.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF HVBKD.
DATA:    BEGIN OF *HVBKD.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF *HVBKD.
* Kopf
DATA:    BEGIN OF KVBKD.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF KVBKD.
DATA:    BEGIN OF *KVBKD.
           INCLUDE STRUCTURE VBKDVB.
DATA:    END OF *KVBKD.

* Aktionsfindung
DATA: BEGIN OF L_WAKH.
      INCLUDE STRUCTURE WAKH.
DATA: END   OF L_WAKH.
DATA: BEGIN OF V_WAKH OCCURS 1.
      INCLUDE STRUCTURE WAKH.
DATA: LDATV TYPE D,
      LDATB TYPE D,
      ADATV TYPE D,
      ADATB TYPE D.
DATA: END   OF V_WAKH.
DATA: V_WAKTP TYPE WAKTP_PROMOHEAD WITH HEADER LINE.
DATA: L_PROMO_DATES TYPE WAKTP_PROMO_DATES.

* Produktkatalog
DATA: WMINR_KOPF.

* Finanzdokumente
DATA: FCODE_IFDH_ACTIVATED TYPE C VALUE ' '.

* Text zu DP-Profil puffern
DATA: BEGIN OF XAD01C_PRTX OCCURS 1.
      INCLUDE STRUCTURE AD01C_PRTX.
DATA: END OF XAD01C_PRTX.

ENHANCEMENT-POINT VBKDDATA_01 SPOTS ES_VBKDDATA STATIC INCLUDE BOUND .
DATA: END OF COMMON PART.
*eject