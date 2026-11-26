*---------------------------------------------------------------------*
*                                                                     *
*       Tabellen und Felder zur Textverarbeitung                      *
*                                                                     *
*---------------------------------------------------------------------*

TABLES:  THEAD,                        "Textheader
         TLINE.                        "Textline

TABLES:  TVCOM,                        "Kommunikationsblock
         TTXID,                        "Text-Id's
         TTXIT,                        "Texte zu Text-Id's
         TTXOB,                        "zulaessige Textobjekte
         TTXOT,                        "Texte zu den Textobjekten
         T002,                         "Textschluessel
         T002T.                        "Texte zu Textschluessel

DATA: BEGIN OF COMMON PART THEADCOM.

*---------------------------------------------------------------------*
*       Direktwerte                                                   *
*---------------------------------------------------------------------*

DATA:    EINRUECK_ZEICHEN(3) VALUE '...'.   "Einrueckzeichen zur
                                            "Hervorhebung von Texten,
                                            "die in mehreren Sprachen
                                            "existieren
*---------------------------------------------------------------------*
*       Merker für AUFTRAG/LIEFERSCHEIN/FAKTURA                       *
*---------------------------------------------------------------------*
DATA:   ACT_ALF(1) TYPE C VALUE '?'.
*---------------------------------------------------------------------*
*       Merker für aktuelle Textgruppe                                *
*---------------------------------------------------------------------*
DATA:   ACT_TXTGR LIKE TTXER-TXTGR.
*---------------------------------------------------------------------*
*       Merker für aktuelle Anzeigesprache                            *
*---------------------------------------------------------------------*
DATA:   ACT_DISPL(1) TYPE C.


*---------------------------------------------------------------------*
*       MEMORY-Id fuer Textanzeige                                    *
*---------------------------------------------------------------------*
DATA:   MEMID(30) TYPE C VALUE 'TEXT_DISPLAY_MODE'.

*---------------------------------------------------------------------*
*       Struktur für Inline - Textverarbeitung                        *
*---------------------------------------------------------------------*
DATA:   BEGIN OF TLINETAB OCCURS 10.   "Zeilen Langtext
         INCLUDE STRUCTURE TLINE.
DATA:   END OF TLINETAB.

DATA:   BEGIN OF TINLINETAB OCCURS 10. "Inline-Zeilen Langtext
         INCLUDE STRUCTURE TLINE.
DATA:   END OF TINLINETAB.

DATA:   BEGIN OF XTHEAD OCCURS 50.    "aktueller Tabellenstand
          INCLUDE STRUCTURE THEADVB.
DATA:   END OF XTHEAD.

DATA:   BEGIN OF YTHEAD.              "voriger Tabellenkopf XTHEAD
          INCLUDE STRUCTURE THEADVB.
DATA:   END OF YTHEAD.

DATA:   BEGIN OF ITHEAD OCCURS 15,    "Indextabelle für Anzeige
          TDOBJECT LIKE THEAD-TDOBJECT,
          TDNAME   LIKE THEAD-TDNAME,
          TDID     LIKE THEAD-TDID,
          TDSPRAS  LIKE THEAD-TDSPRAS,
          TABIX LIKE SY-TABIX,        "Index für XTHEAD
          SELKZ,
          LFDTX    LIKE TTXER-LFDTX,
        END OF ITHEAD.
* Die Tabelle ITHEAD kann nicht mit BINARY SEARCH gelesen werden,
* da eine neu angelegte Textzeile eine Sprache enthalten kann,
* die nicht der Sortierreihenfolge entspricht.

DATA:   BEGIN OF STHEAD OCCURS 15,     "XTHEAD-TABIX zur
          TABIX LIKE SY-TABIX,         "Sstep-Loop-Zeile
        END OF STHEAD.

* Hilfsfelder für Blaettern
DATA:   ITHEAD_TABIX_ZEILE_1 LIKE SY-TABIX, "Tabix der ersten Zeile
        ITHEAD_TABIX_AKTUELL LIKE SY-TABIX, "laufender Tabix der Seite
        ITHEAD_LOOPC         LIKE SY-TABIX, "Anzahl LOOP-Zeilen
        ITHEAD_DEL_IND       LIKE SY-TABIX. "Aufsetzen nach Loeschen

* Hilfsfelder zur Verwaltung XTHEAD
DATA:   XTHEAD_TDNAME_GEFUNDEN,             "TDNAME in XTHEAD gefunden
        XTHEAD_TDNAME LIKE THEAD-TDNAME,    "TDNAME in XTHEAD fuer die
                                            "Form ITHEAD_AUFBAUEN_ALLE
        XTHEAD_LOESCHEN.                    "Löschen des Textes

DATA:   BEGIN OF XTHEAD_KEY,
          TDOBJECT LIKE THEAD-TDOBJECT,
          TDNAME   LIKE THEAD-TDNAME,
          TDID     LIKE THEAD-TDID,
          TDSPRAS  LIKE THEAD-TDSPRAS,
        END OF XTHEAD_KEY.

DATA:   BEGIN OF XTHEAD_KEY_ALT,
          TDOBJECT LIKE THEAD-TDOBJECT,
          TDNAME   LIKE THEAD-TDNAME,
          TDID     LIKE THEAD-TDID,
        END OF XTHEAD_KEY_ALT.

* Hilfstext-Workarea
DATA:   BEGIN OF HTEXT,
          TDOBJECT LIKE THEAD-TDOBJECT,
          TDNAME   LIKE THEAD-TDNAME,
          TDID     LIKE THEAD-TDID,
          TDSPRAS  LIKE THEAD-TDSPRAS,
        END OF HTEXT.

DATA:   HTDLINESIZE LIKE THEAD-TDLINESIZE.
DATA:   HTDTEXT     LIKE TTXIT-TDTEXT.
DATA:   HTXPFL      LIKE TTXER-TXPFL.
DATA:   HLFDTX      LIKE TTXER-LFDTX.

* Hilfsstrukturen für Funktionsbausteine
DATA:   BEGIN OF REFTEXT OCCURS 25.    "REFTEXT wird mit Textkoepfen
         INCLUDE STRUCTURE THEAD.      "gefundener Texte gefuellt
DATA:   END OF REFTEXT.

DATA:   TXT_ENTRIES LIKE SY-TFILL.     "Anzahl gefundener Texte

DATA:   TXTFUNCTION(1) TYPE C.         "Aenderungsfunktion bei Texten


* Dummyname für das Anlegen von Texten
DATA:   DUMMY-NAME LIKE THEAD-TDNAME.

* Steuerungsfeld für Aufruf des Text-Editors
DATA:   TXTSCREEN(1) TYPE C.

* Hilfsstruktur zur Aufnahme mehrerer Inline-Textzeilen
DATA:   BEGIN OF LTEXT,
          ZEILE0(80) TYPE C,
          ZEILE1(80) TYPE C,
          ZEILE2(80) TYPE C,
          ZEILE3(80) TYPE C,
          ZEILE4(80) TYPE C,
          ZEILE5(80) TYPE C,
          ZEILE6(80) TYPE C,
          ZEILE7(80) TYPE C,
          ZEILE8(80) TYPE C,
          ZEILE9(80) TYPE C,
        END OF LTEXT.

* Festwerte für Aufruf des Text-Editors
DATA:   TDLINESIZE_MIN LIKE THEAD-TDLINESIZE.
DATA:   TDLINESIZE_STD LIKE THEAD-TDLINESIZE.

* Steuerungsfeld zur Bearbeitung des Fehlerprotokolls
DATA:   TXTFEHLER(1) TYPE C VALUE ' '.

* Hilfsfelder für Blaettern
DATA:   XTHEAD_TABIX_ZEILE_1 LIKE SY-TABIX, "Tabix der ersten Zeile
        XTHEAD_TABIX_AKTUELL LIKE SY-TABIX, "laufender Tabix der Seite
        XTHEAD_LOOPC         LIKE SY-TABIX, "Anzahl LOOP-Zeilen
        XTHEAD_DEL_IND       LIKE SY-TABIX. "Aufsetzen nach Loeschen

* Hilfsfelder zur Bildschirmverwaltung
DATA:   ANZ_LTEXT_ZEILEN LIKE SY-STEPL,     "Anzahl Langtextzeilen
        GRUNDSPRAS       LIKE SY-LANGU,     "Grundsprache
        LANGTEXT(72) TYPE C.                "Langtextzeile Sapscript

DATA:   LANGTEXT_FELDLAENGE(2) TYPE P.      "Feldlaenge Langtextzeile

DATA:   TEXT_SPRACHE_FEHLT(1) VALUE 'N'.    "= J , falls in RTEXT-SPRAS
                                            "      die Sprache fehlt
DATA:   TEXT_SPRACHE_IND LIKE SY-TABIX.     "Aufsetzen nach fehlender
                                            "Sprache
DATA:   BEGIN OF CURSOR,
          FELD(30),
          ZEILE LIKE SY-STEPL,
        END OF CURSOR.

DATA:   MAX_LFDTX LIKE TTXER-LFDTX.         "zum Abmischen der Reihen-
                                            "folge bei 2 Textgruppen

DATA:   ANZAHL_SPRACHEN LIKE SY-TABIX.      "in Tabelle T002

* CATALOG - Struktur ( zur Pruefzwecken ! )
DATA: CATALOG LIKE TCATALOG OCCURS 0 WITH HEADER LINE,
      MEMORY_ID(30) VALUE 'SAPLSTXD'.

DEFINE *.
  IMPORT CATALOG FROM MEMORY ID MEMORY_ID.
END-OF-DEFINITION.

* Protokolltabelle
DATA: BEGIN OF XPROT OCCURS 0.
        INCLUDE STRUCTURE THEADPROT.
DATA: END OF XPROT.

DATA: END OF COMMON PART.