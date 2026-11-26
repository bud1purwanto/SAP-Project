*-----------------------------------------------------------------------
*        Datenbank-Tabelle VBEP
*-----------------------------------------------------------------------

* Bestelloptimierung
TYPE-POOLS MDR1P.

TABLES:  VBEP,*VBEP,
         VBEPD,*VBEPD,
         EBAN, EBKN,                   " Bestellanforderung
         ORDPAR,                       " FAUF/PAUF/Netz/Service
         TVEP,                         " Einteilungssteuerung
         TVEPT,                        " Einteilungstypentext
         TVRO,                         " Route
         TVROT,                        " Route
         T001W,                        " Werke
         T001W_EXT,                    " Werke (eigene und fremde)
         T003O,                        " Auftragsarten PP
         T003P,                        " Auftragsartentext
         T161S,                        " Banffreigabe
         T161T,                        " Bestellartentext
         TVKWZ,                       " Verkaufsorganisation-Werke_Zuord
         TVLS,                         " Liefersperre
         TVLST,                        " Liefersperre -  Text
         TVST,                         " Versandstelle
         TVSTT,                        " Versandstellentext
         T001L.                        " Lager

*  gemeinsame Parameterleiste für Steuerung BANF/FAUF/PAUF/Netz/Service
*  n e u e r  Zustand
DATA:    BEGIN OF PARM.
        INCLUDE STRUCTURE ORDPAR.
DATA:      ESTKZ   LIKE EBAN-ESTKZ,
           BANFN   LIKE EBAN-BANFN,
           BNFPO   LIKE EBAN-BNFPO,
           EBELN   LIKE EBAN-EBELN,
           BSART   LIKE EBAN-BSART,
           PSTYP   LIKE EBAN-PSTYP,
           AKTNR   LIKE EBAN-AKTNR,
           LOEKZ   LIKE EBAN-LOEKZ,
           BSMNG   LIKE EBAN-BSMNG,
           BMEIN   LIKE EBAN-BMEIN,
           LPEIN   LIKE EBAN-LPEIN,
           LFDAT   LIKE EBAN-LFDAT,
           KOSTL   LIKE EBKN-KOSTL,
           PRCTR   LIKE EBKN-PRCTR,
           GSBER   LIKE EBKN-GSBER,
           CHARG   LIKE EBAN-CHARG,
*           BWTAR   LIKE EBAN-BWTAR,
           ATTYP   LIKE EBAN-ATTYP,
           SATNR   LIKE EBAN-SATNR,
           TXZ01   LIKE EBAN-TXZ01,
           SPRAS   LIKE EBAN-SPRAS,
           PS_PSP_PNR LIKE EBKN-PS_PSP_PNR,
           PAOBJNR LIKE EBKN-PAOBJNR,
           KUNNR   LIKE VBPA-KUNNR,
           ADRN2   LIKE VBPA-ADRNR,
           KZFME   LIKE EBAN-KZFME.
DATA:    END OF PARM.

*  gemeinsame Parameterleiste für Steuerung BANF/FAUF/PAUF
*  a l t e r  Zustand
DATA:    BEGIN OF *PARM.
        INCLUDE STRUCTURE PARM.
DATA:    END OF *PARM.

DATA:    BEGIN OF COMMON PART VBEPCOM.

* Typendeklaration
TYPES: BEGIN OF VBEPVBSTRUC.
        INCLUDE STRUCTURE VBEPVB.
TYPES: END OF VBEPVBSTRUC.

TYPES: VBEPVBTAB
            TYPE STANDARD TABLE OF VBEPVBSTRUC
            WITH DEFAULT KEY.


* Alter Tabellenstand beim Ändern

DATA:    BEGIN OF YVBEP OCCURS 1.
        INCLUDE STRUCTURE VBEPVB.
DATA:    END OF YVBEP.

* Aktueller Tabellenstand

DATA:    BEGIN OF XVBEP OCCURS 150.
        INCLUDE STRUCTURE VBEPVB.
DATA:    END OF XVBEP.

* Einteilungen der Vorlage

DATA:   BEGIN OF VVBEP OCCURS 10.
        INCLUDE STRUCTURE VBEPVB.
DATA:   END OF VVBEP.

* Aktueller Tabellenstand

DATA:    BEGIN OF XVBEPEK OCCURS 10.
        INCLUDE STRUCTURE VBEPEK.
DATA:    END OF XVBEPEK.

* Zusagedaten

DATA: XDCVBEP TYPE VBEPVBTAB.
DATA: YDCVBEP TYPE VBEPVBTAB.

* Texte für Übergabe an die Bestellanforderung

DATA: BEGIN OF EBAN_TEXT OCCURS 0.
        INCLUDE STRUCTURE TXHD.
DATA: END OF EBAN_TEXT.

* durch Plantafel-Verschiebung betroffene Positionen

DATA:    BEGIN OF ORDTAB OCCURS 1.
        INCLUDE STRUCTURE ORDCHG.
DATA:    END OF ORDTAB.

* Sicherung ORDPAR
DATA:    BEGIN OF CORDPAR.
        INCLUDE STRUCTURE ORDPAR.
DATA:    END OF CORDPAR.

* Datenänderungen der Bestellung(en)
DATA: PURCHASE_DATA LIKE PURCHASE_DATA OCCURS 0 WITH HEADER LINE.

* Index der anzuzeigenden Einteilungen, gleicher aufbau wie IVBEP1

DATA:   BEGIN OF IVBEP OCCURS 150.
        INCLUDE STRUCTURE BEZIVBEP.
*         POSNR LIKE VBEP-POSNR,
*         ABART LIKE VBEP-ABART,
*         ABRUF LIKE VBEP-ABRUF,
*         EDATU LIKE VBEP-EDATU,
*         PRGRS LIKE VBEP-PRGRS,
*         EZEIT LIKE VBEP-EZEIT,
*         ETENR LIKE VBEP-ETENR,
*         TABIX LIKE SY-TABIX,       "Tabix für Tabelle XVBEP
*         SELKZ,
*         ABRFZ TYPE F,
DATA:   END OF IVBEP.

* vollstaendiger Index für Tabelle XVBEP, gleicher Aufbau wie IVBEP

DATA:   BEGIN OF IVBEP1 OCCURS 150.
        INCLUDE STRUCTURE BEZIVBEP1.
*         POSNR LIKE VBEP-POSNR,
*         ABART LIKE VBEP-ABART,
*         ABRUF LIKE VBEP-ABRUF,
*         EDATU LIKE VBEP-EDATU,
*         PRGRS LIKE VBEP-PRGRS,
*         EZEIT LIKE VBEP-EZEIT,
*         ETENR LIKE VBEP-ETENR,
*         TABIX LIKE SY-TABIX,       "Tabix für Tabelle XVBEP
DATA:   END OF IVBEP1.

DATA:   IVBEP_KEY(36) TYPE C.          " vorläufig (mit etenr)
DATA:   IVBEP_KEY1(32) TYPE C.         " vorläufig (ohne etenr)
DATA:   IVBEP_KEY_SKIP(36) TYPE C.     " Skip zur nächsten Einteilung

* Einteilungsnummer zur Sstep-Loop-Zeile.

DATA:   BEGIN OF SVBEP OCCURS 15,
          TABIX LIKE SY-TABIX,
        END OF SVBEP.

* Globalisieren der Übergabestruktur US_VBEPKOM
DATA: BEGIN OF US_VBEPKOM.
        INCLUDE STRUCTURE VBEPKOM.
DATA: END OF US_VBEPKOM.

DATA: BEGIN OF US_VBEPKOMX.
        INCLUDE STRUCTURE VBEPKOMX.
DATA: END OF US_VBEPKOMX.

* Hilfsfelder fuer Blättern, Anzeigeumfang und Update

DATA:  IVBEP_TABIX_ZEILE_1 LIKE SY-TABIX, " Tabix der ersten Zeile
       IVBEP_TABIX_AKTUELL LIKE SY-TABIX, " laufender Tabix der Seite
       IVBEP_LOOPC         LIKE SY-TABIX, " Anzahl LOOP-Zeilen
       IVBEP_DEL_IND      LIKE SY-TABIX,  " Tabix Aufsetzen nach Löschen
       XVBEP_ALLE_GELESEN TYPE C,      " alle gelesen
       XVBEP_LOESCHEN,                 " Löschen der Einteilung
       XVBEP_LOESCHEN_BEI_ANLEGEN,     " Löschen bei Anlegen
       XVBEP_ANZAHL(4) TYPE P,         " Eint.zähler beim Einlesen
       XVBEP_WMENG_UPDATE TYPE C,      " Menge geändert oder neue
                                       " Terminierung erwünscht
       XVBEP_WMENG_GEWICHT TYPE C,     " Menge geändert und neue
                                       " Gewichtsermittlung
       XVBEP_DATEN_UEBERNEHMEN_BEST(1) " Daten in abweichende bestät.
       TYPE C,                         " Einteilungen übernehmen
       STRUKTURPFLEGE     TYPE C.      " Strukturpflege
DATA:  VBEP_PRUEFEN.                   " Für Unvollständigkeit
DATA:  UPD_VBEP.                       " Für Änderungsbelege
DATA:  VBEP_KOPIERT.

* Hilfsfeld zur Unterscheidung von Einteilungen mit
* Bestellanforderung   ->  'F'  (fremd)
* Fertigungsauftrag    ->  'E'  (eigen)
* Netzplan             ->  'E'  (eigen)
* Service              ->  'E'  (eigen)
* Planauftrag          ->  'E'  (eigen)
DATA:  BESCHAFFUNGSTYP(1).

* Hilfsfelder für Bestellanforderung
DATA: BE_POSNR LIKE EBAN-BNFPO,
      BE_LFDAT LIKE EBAN-LFDAT,
      BE_LIDAT LIKE EBAN-LFDAT.
DATA: BE_PRUEFEN_ENDE,
* Beschaffung aendern für Banfen:'F', für Montage:'E', immer:'X'
      BE_AENDERN.

data: gv_source_on_create type char1 value 'X'.

* Hilfsfelder für Obligoprüfung
DATA: OBLIGO_RELEVANT,
      OBLIGO_ERROR.

* Beleg enthält Beschaffung
DATA: BEGIN OF ENTHAELT_BESCHAFFUNG,
  BANF,
  AUFTRAG,
  PLANAUFTRAG,
  END OF ENTHAELT_BESCHAFFUNG.

* FORM BESCHAFFUNG_AENDERN is calling
DATA: CHANGE_PROCUREMENT_ACTIVE TYPE XFELD.

* Hilfsfelder für Montageabwicklung statisch
DATA: ATO_STAT_NO_CHANGE.              "Keine Änderung im
                                       "Detailbild

DATA: BEGIN OF MAIS_QUAN_CHECK_XVBEP OCCURS 0.
        INCLUDE STRUCTURE VBEPVB.
DATA: END OF MAIS_QUAN_CHECK_XVBEP.

DATA: APO_BOP_XVBEP LIKE BOP_XVBEP OCCURS 0 WITH HEADER LINE.

*---------------------------------------------------------------------*
*        Direktwerte zum Umfang                                       *
*---------------------------------------------------------------------*
DATA: XVBEP_UMFANG(1)         TYPE C,  "Umfang der Liste
      XVBEP_UMFANG_EINTEILUNG TYPE C VALUE ' ',
      XVBEP_UMFANG_MARKIERTE  TYPE C VALUE 'Y'.

* Rundung bereits erfolgt
DATA DA_RDPRF(1) TYPE C.

DATA:    END OF COMMON PART.
*eject