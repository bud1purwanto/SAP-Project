*-----------------------------------------------------------------------
*        Datenbank-Tabelle VBSN
*-----------------------------------------------------------------------
TABLES:  VBSN,*VBSN,                   " Struktur Änderungsstände
         VBSND,*VBSND.                " Dynamischer Teil Änderungsstände

DATA:    BEGIN OF COMMON PART VBSNCOM.

* Alter Tabellenstand beim Ändern
DATA: BEGIN OF YVBSN OCCURS 1.
        INCLUDE STRUCTURE VBSNVB.
DATA: END OF YVBSN.

* Aktueller Tabellenstand
DATA: BEGIN OF XVBSN OCCURS 50.
        INCLUDE STRUCTURE VBSNVB.
DATA: END OF XVBSN.

* Änderungsstände der Vorlage
DATA: BEGIN OF VVBSN OCCURS 10.
        INCLUDE STRUCTURE VBSNVB.
DATA: END OF VVBSN.

* Index der anzuzeigenden Änderungsstände
* gleicher Aufbau wie IVBSN1
DATA:   BEGIN OF IVBSN OCCURS 50,
          POSNR LIKE VBSN-POSNR,
          GJKUN LIKE VBSN-GJKUN,
          LIFFZ(15)  TYPE N,
          LEDAT LIKE VBSN-LEDAT,
          AKTKZ LIKE VBSN-AKTKZ,
          AENNR LIKE VBSN-AENNR,
          TABIX LIKE SY-TABIX,         "Tabix für Tabelle XVBSN
          SELKZ,
        END OF IVBSN.

* vollstaendiger Index für Tabelle XVBSN.
* gleicher Aufbau wie IVBSN
DATA:   BEGIN OF IVBSN1 OCCURS 100,
          POSNR LIKE VBSN-POSNR,
          GJKUN LIKE VBSN-GJKUN,
          LIFFZ(15)  TYPE N,
          LEDAT LIKE VBSN-LEDAT,
          AKTKZ LIKE VBSN-AKTKZ,
          AENNR LIKE VBSN-AENNR,
          TABIX LIKE SY-TABIX,         "Tabix für Tabelle XVBSN
        END OF IVBSN1.

DATA:   IVBSN_KEY(34) TYPE C.          " vorläufig (mit AENNR)
DATA:   IVBSN_KEY1(38) TYPE C.         " vorläufig (ohne AENNR)

* Änderungsstandnummer zur Sstep-Loop-Zeile.
DATA:   BEGIN OF SVBSN OCCURS 12,
          TABIX LIKE SY-TABIX,
        END OF SVBSN.

* Hilfsfelder fuer Blättern, Anzeigeumfang und Update

DATA:   IVBSN_TABIX_ZEILE_1 LIKE SY-TABIX, "Tabix der ersten Zeile
        IVBSN_TABIX_AKTUELL LIKE SY-TABIX, "laufender Tabix der Seite
        IVBSN_LOOPC         LIKE SY-TABIX, "Anzahl LOOP-Zeilen
        XVBSN_ALLE_GELESEN  TYPE C,    "alle gelesen
        XVBSN_LOESCHEN,                "Löschen der Änderungsstände
        XVBSN_LOESCHEN_BEI_ANLEGEN,    "Löschen bei Anlegen
        XVBSN_ANZAHL(4)    TYPE P.     "Änderungszähl. beim Einlesen

DATA:   UPD_VBSN.                      " Für Änderungsbelege

DATA:   KZ_ART_VBSN,      "Kennzeichen, ob VBSN FZs oder Termine enthält
        KZ_ART_VBSN_FZ          TYPE C VALUE 'F',
        KZ_ART_VBSN_DATE        TYPE C VALUE 'D'.

* Kennzeichen, ob in der XVBSN gelöscht wurde
DATA    XVBSN_GELOESCHT.

*---------------------------------------------------------------------*
*        Direktwerte zum Umfang                                       *
*---------------------------------------------------------------------*
DATA:   XVBSN_UMFANG(1)         TYPE C,"Umfang der Liste
        XVBSN_UMFANG_AENDERUNG  TYPE C VALUE ' ',
        XVBSN_UMFANG_MARKIERTE  TYPE C VALUE 'Y'.

DATA:    END OF COMMON PART.
*eject