*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*        Datenbanktabellen
*-----------------------------------------------------------------------

TABLES:  T001K,                        " Bewertungsmodifikationskonst.
         T001L,                        " Lagerorte
         T063D,                        " Alternative Dynpros bei MB01
         T158B,                        " Bewegungsarten
         TCOBF,                        " Felder im Kontierungsblock
         TCURM.                        " Customizing für Bewertung

TABLES:  COBL_MB,                      " geschützte Felder zu COBL
         MARV,                         " Materialverwaltung
         MAKT,                         " Materialkurztext
         MDCP,                         " Kommunikationstab. DISPSATZ
*14884 SW
         MSFCV,                        " Chargenprüfung
*14884 SW
         MTCOM,                        " Kommunikationstab. MatStamm
         MTCOR,                        " Returncode MatStamm lesen
         MTPER,                        " Returncode MatStamm / Perioden
         SBEFU.                        " Kommunikationstab. Stücklisten



ENHANCEMENT-POINT FM07MCOM_01 SPOTS ES_FM07MCOM STATIC INCLUDE BOUND.
DATA:    BEGIN OF COMMON PART FM07MCOM.

*-----------------------------------------------------------------------
*       Datenfelder fuer die Programme SAPMM07*
*
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*       Teil 5 :  Field-Symbols
*
*-----------------------------------------------------------------------

*eject
*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------
*------- Dummystruktur für Funktionsbausteine
DATA: BEGIN OF DUMMY OCCURS 0.
DATA:   DUMMY.
DATA: END OF DUMMY.

*------- Belegkopf der Reservierung
DATA: BEGIN OF XRKPF OCCURS 0.
        INCLUDE STRUCTURE RKPF.
DATA: END OF XRKPF.

*------- Belegzeilen der Reservierung
DATA: BEGIN OF XRESB OCCURS 0.
        INCLUDE STRUCTURE RESB.
DATA: END OF XRESB.

*------- Neue Belegzeilen der Reservierung beim Ändern
DATA: BEGIN OF XRESBN OCCURS 0.
        INCLUDE STRUCTURE RESBN.
DATA: END OF XRESBN.

*------- Stücklisten
DATA: BEGIN OF XSTPOX OCCURS 0.
        INCLUDE STRUCTURE STPOX.
DATA: END OF XSTPOX.

DATA: BEGIN OF XMATCAT OCCURS 0.
        INCLUDE STRUCTURE CSCMAT.
DATA: END OF XMATCAT.
*------- Tabelle der Feldauswahl für Kontierungsblock
DATA: BEGIN OF XCOBF OCCURS 0.
        INCLUDE STRUCTURE TCOBF.
DATA: END OF XCOBF.
*eject
*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------

DATA: BEGIN OF XMTCOR.
        INCLUDE STRUCTURE MTCOR.
DATA: END OF XMTCOR.

DATA: BEGIN OF XMTCOM.                                              "kaz
        INCLUDE STRUCTURE MTCOM.                                    "kaz
DATA: END OF XMTCOM.                                                "kaz

DATA: BEGIN OF XMTPER.
        INCLUDE STRUCTURE MTPER.
DATA: END OF XMTPER.

*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------

DATA:    H_KONTO    LIKE DM07M-KONTO.  " Hilfsfeld Konto f. Reserv.
DATA:    TITEL      LIKE T185V-CTITEL, " Return-Code
         RC         LIKE SY-SUBRC,     " Return-Code
         RCI        LIKE SY-SUBRC,     " Return-Code     " PPF Rel. 4.6
         FW(4)      TYPE C,            " Hilfsfeld
         HW(2)      TYPE C,            " Hilfsfeld
         VW(1)      TYPE C,            " Hilfsfeld
         KREUZ      TYPE C,            " Listzustand: alles markiert
         TABIX      LIKE SY-TABIX,     " Tabellenindex
         XINDEX     LIKE SY-INDEX,     " Schleifenindex
         SICHT      LIKE T063O-SICHT,  " Art der Darstellung bei MB01
         WERT       TYPE F,            " Wert
         MENGE      TYPE F,            " Menge
         BPMNG      TYPE F,            " Menge
         DIFML      TYPE F,            " Differenzmenge in LME
         DIFMA      TYPE F,            " Differenzmenge in AME
         DIFMB      TYPE F,            " Differenzmenge in BPME
         OK-CODE    LIKE SY-UCOMM,     " OK-Code
         MESSAGE_TEXT(60) TYPE  C,     " Hilfsfeld Nachrichten
         KEINE_EINGABE,                " Hilfsfeld für Dynpromodif
         MSGVS LIKE T160M-MSGVS VALUE '00'. "Version für Fehlermeldung
*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------
CONSTANTS:    MOD_ON(1)  VALUE '1',          " Schalter -> an
              MOD_OFF(1) VALUE '0'.          " Schalter -> aus

CONSTANTS:    NEUNER(13) TYPE C VALUE '9999999999999',
              NULLEN(15) TYPE C VALUE '000000000000000'.
DATA:         CONFIRM(1) TYPE C.

*------- Flag auf X, wenn Fortschreibung erfolgt ----------------------*
DATA:    UPD_UM07R  TYPE C,             " Update Reserv.
         UPD_RKPF   TYPE C,             " RKPF geändert ?
         UPD_RESB   TYPE C,             " RESB geändert ?
         NEW_RESB   TYPE C.             " Neue Pos. in RESB ?
*------- Flag auf X, wenn Routine von diesen Programmen aufgerufen ----*
DATA:    INVENTUR,
         RESERVIERUNG.
*------  Flag auf X, wenn die Inventur Shared-Sperre verwendet  -------*
DATA:    INV_SHARED(1) TYPE C.
*------- Hilfsfelder für Aufruf Funktionsbaustein SCROLLING_IN_TABLE --*
DATA:    ANZAHL  LIKE SY-TABIX,
         START   LIKE SY-TABIX,
         ENDE    LIKE SY-TABIX.

*-----------------------------------------------------------------------
*       Teil 5 :  Field-Symbols
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 6 :  Includes
*-----------------------------------------------------------------------
INCLUDE MM07MABC.

DATA:    END OF COMMON PART.
*eject.