PROGRAM sapmv50a MESSAGE-ID vl LINE-SIZE 132.

*---------------------------------------------------------------------*
*        Verbuchungssteuerung                                         *
*---------------------------------------------------------------------*
DATA: komplett_protokollieren(1) VALUE ' ',
      verbuchung_im_dialog(1)    VALUE 'X'.

DATA:   BEGIN OF xt156n OCCURS 200.                                 "v_SIT
        INCLUDE STRUCTURE t156n.
DATA:   END OF xt156n.

DATA:   BEGIN OF zvbfa OCCURS 0.
        INCLUDE STRUCTURE vbfa.
DATA:   END OF zvbfa.                                               "^_SIT
*---------------------------------------------------------------------*
* M ERP Integration II - UI Extension
DATA: gr_tm_delivery TYPE REF TO cl_tm_delivery.

*        Interne Tabellen zum Vertriebsbeleg                          *
*---------------------------------------------------------------------*
INCLUDE copylisa.                      "Datenteil für Kopierroutinen
INCLUDE copylifs.                "Datenteil für Kopierrout. Lieferung
INCLUDE vblkdata.                      "Lieferung Kopf
INCLUDE vblpdata.                      "Lieferung Position
INCLUDE vbakdata.                      "Auftrag Kopf
INCLUDE vbapdata.                      "Auftrag Position
ENHANCEMENT-POINT MV50ATOP_01 SPOTS ES_SAPMV50A STATIC.
INCLUDE vbepdata.                      "Auftrag Einteilung
INCLUDE vbbddata.                      "Vertriebsbeleg Bedarfe
INCLUDE vbkddata.                "Vertriebsbeleg Kaufmännische Daten
INCLUDE vbpadata.                      "Vertriebsbeleg Partner
INCLUDE vbfadata.                      "Vertriebsbeleg Fluss
INCLUDE vtfadata.                      "Shipment flow
INCLUDE vbupdata.                      "Status Position
INCLUDE vbukdata.                      "Status Kopf
INCLUDE vbuvdata.                                           "
INCLUDE theaddat.                      "Texte
INCLUDE vl04data.                      "VL04 Sammelgang
INCLUDE sadrdata.                      "Adressen
INCLUDE avbbddat.                      "alte Bedarfe
INCLUDE vl07data.                      "VL07 WE auf Lieferung
INCLUDE pripdata.                      "Preisfindung Lieferung
INCLUDE i56idova.                      "status external shipment planing
INCLUDE tabcdat1.                      "Table control
INCLUDE incltaxi.                      "Tab strip processing (1)
INCLUDE mv50atst.                      "Tab strip processing (2)
INCLUDE mv50adia.                      "Global data f. dialog processing

* Nachrichten
TABLES: tnapr.
INCLUDE vmsgpart.                      "Nachrichten Partner
INCLUDE nastdata.                "Nachrichtenvorschlag aus Kundenstamm
INCLUDE messdata.                      "Nachrichtenstatus
INCLUDE <cntain>.                 "Macro for Workflow
INCLUDE mv50stat_disp.
INCLUDE shp_macro.

DATA:  BEGIN OF kot OCCURS 50.
        INCLUDE STRUCTURE konv.
DATA:    updkz,
         selkz,
       END OF kot.

TABLES: emkpf.

* Include for deadline maintenance
INCLUDE lv51tdtx.

*-----------------------------------------------------------------------
*        Datenbank-Tabellen
*-----------------------------------------------------------------------
INCLUDE ekkodata.
*-----------------------------------------------------------------------
*        Datenbank-Views
*-----------------------------------------------------------------------

TABLES:  mtcom,                        " Komm.Block Materialview
         maapv,                        " Komm.Block materialview
         maepv,                        " Komm.Block materialview
         vbco6,                        " Komm.Block Belegfluss
         vtcom,                        " Komm.Block Kundenview
         kuagv,                        " Kundenview Auftraggeber
         kuwev,                        " Kundenview Warenempfaenger
         kurgv,                        " Kundenview Regulierer
         kupav,                        " Kundenview Partner
         knvv,                         " Kunde IV
         knvi,
         mt06a,                                             "n_1304489
         vbstt,                        " Tab. der Statusbez.
         tmgw2.                        " Strukturtypen Stücklisten
*eject

*-----------------------------------------------------------------------
*        Type Pools
*-----------------------------------------------------------------------

TYPE-POOLS: slis,                      "Listviewer Tool
            vlggt,                     "Allgemeine Lieferungs-Typen
            lv70t,                     "Text processing
            v50b,                      "Feldsteuerung
            lv09a,                     "Partner processing
            shlp,                      "Search helps
            vse, vsep.                 "Packing

*-----------------------------------------------------------------------
*        ATAB-Tabellen
*-----------------------------------------------------------------------
TABLES:  tlgrt,                        " Texte zu Ladegruppe
         tpar,                         " Partnertabelle
         tpaer,                        " erlaubte Partner
         tpart,                        " Texte zu TPAR
         sadr,                         " Adressen
         tqcom,                        " System-Kommunikation
         tspa,                         " Sparten
         tspat,                        " Sparten Text
         tstc,                         " Transaktionen
         ttgrt,                        " Texte zu Transportgruppe
         ttsgt,                        " Transportsperre
         tvcpl,                        " Kopieren
         tvepz,                        " Einteilungszuordnung
         tvkbt,                        " Sales office text
         tvkgr,                        " Verkäufergruppe
         tvkov,                        " Umschlüsselung VTWEG
         tvla,                         " Ladestellen
         tvlat,                        " Texte zu Ladestellen
         t30b,                         " Tore
         t30bt,                        " Texte zu Toren
         t30c,                         " Bereitstellungszonen
         t30ct,                        " Texte zu Bereitstellungszonen
         tvlg,                         " Gewichtsgruppen der Lieferung
         tvlgt,                        " Texte zu Gewichtsgruppen
         tvlsp,                        " Liefersperre / Lieferart
         tvsakt,                       " Text Sond.abwickl.kz.
         tvty,                         " Transporttyp
         tvtyt,                        " Transporttyp-text
         t005t,                        " Ländertexte
         t100,                         " Fehlertexte
         t142t,                        " Text Raumbedingung
         t143t,                        " Text Temperaturbedingung
         t156n,                        " Bewegungsart fuer VL07
         t173t,                        " Text shipment type
         t180 ,                        " Steuerung Transaktionsstart
         t184 ,                        " Positionstypenfindung
         t185 ,                        " Bildsteuerung
         t185f,                        " Funktionscodes
         t185v,                        " Verarbeitungsinformationen
         t459a,                        " Bedarfsübergabe
         t377,                         " Serialnummernvorgänge
         t476,                         " Konfiguration
         t685,                         " Konditionen
         t685t,                        " Texte zu Konditionsschl,
         t691l,                        " Texte zu Absicherungsformen
         t300t,                        " Texte zur Lagernummer
         t301t,                        " Texte zum Lagertyp
         vblb,                         " delivery schedule (50A)
         t157e,                        " Text reason for movements
         valwt,                        " Bezeichnung Routenfahrplan
         tvpod,                        " POD Daten
         tvpodvb,                      " POD Daten der Lieferung
         tvpodgt.                      " POD Texte

*-----------------------------------------------------------------------
*        Strukturen
*-----------------------------------------------------------------------
TABLES: fin1_param.

*EJECT

*-----------------------------------------------------------------------
*        E/A-Felder
*-----------------------------------------------------------------------

TABLES:  rv02p,                        " E/A-Felder
         lv50c.                        " Kopier-Work-Area
DATA: inri_rcode LIKE inri-returncode. " Returncode Nummernvergabe
*EJECT

*-----------------------------------------------------------------------
*        Definitionen für das Lieferavis
*-----------------------------------------------------------------------
DATA: BEGIN OF xuekes OCCURS 10.
        INCLUDE STRUCTURE uekes.
DATA: END OF xuekes.
DATA: BEGIN OF xekesu OCCURS 10.                            "713023
        INCLUDE STRUCTURE ekesu.                            "713023
DATA: END OF xekesu.                                        "713023

DATA: BEGIN OF xekes_conv_qty OCCURS 10.                    "457360
        INCLUDE STRUCTURE ekes_conv_qty.                    "457360
DATA: END OF xekes_conv_qty.                                "457360

DATA: BEGIN OF ckomdlgn OCCURS 10.
        INCLUDE STRUCTURE komdlgn.
DATA: END OF ckomdlgn.

*- common-part für WUEB -----------------------------------------------*
INCLUDE fm06lu02.

* Hilfsworkareas fuer int. Tabellen ohne Kopfzeilen
DATA: gs_analyse TYPE vlikp_s_analyse.
DATA: gs_splitprot TYPE vlikp_s_splitprot.

*-----------------------------------------------------------------------
*        Hilfs- und Rechenfelder
*-----------------------------------------------------------------------
DATA:   selline(2) TYPE p.             " selektierte Zeilennummer
DATA:   sqlrc.                         " SQL-Returncode
DATA:   text(100).
DATA:   bildtext  LIKE dv70a-btext.
DATA:   save_ilips_tabix LIKE sy-tabix.
DATA:   save_ilips_posnr LIKE lips-posnr.
DATA:   p-highposnr LIKE lips-posnr.   "Hoechste Positionsnummer
DATA:   gefunden     TYPE c.           "Feld fuer Exit aus LOOP
DATA:   varinf(32)   TYPE c.           "Feld fuer Fehlermeldungen
DATA:   mmbever LIKE t136-vernu  VALUE '13'."Versionsnr. MMBE Bestände
DATA:   lin  TYPE p.                   "Zeilenmerker fuer table control
DATA:   gl_mpnpf LIKE tmppf.           "material parts number profile
DATA:   header_dynnr LIKE sy-dynnr.    "dynnr fuer include screen


* lines deleted                                               "n_614627

DATA: BEGIN OF kvi OCCURS 10.
        INCLUDE STRUCTURE knvi.
DATA: END OF kvi.

DATA: BEGIN OF sel_chargen OCCURS 1.
        INCLUDE STRUCTURE batch.
DATA: END OF sel_chargen.

DATA: gt_correlated TYPE TABLE OF sytabix.                  "n_638127

*---------------------------------------------------------------------*
*        MV50ACOM  Allgemeine Felder Versand                          *
*---------------------------------------------------------------------*
INCLUDE mv50acom.
* eject

*---------------------------------------------------------------------*
*        Direktwerte                                                  *
*---------------------------------------------------------------------*
INCLUDE rvdirekt.
INCLUDE v50j_const.
INCLUDE rv50adef.

*-----------------------------------------------------------------------
*        FIELD-SYMBOLS
*-----------------------------------------------------------------------

FIELD-SYMBOLS: <f1>,
               <f2>,
               <para1>,
               <para2>.


*eject

*-----------------------------------------------------------------------
*        Strukturen
*-----------------------------------------------------------------------
DATA: BEGIN OF enqid,
        tabnam(5),
      END OF enqid.

*-Flags ----------------------------------------------------------------
DATA:  BEGIN OF flag,
         no,                           " keine FAW in Loop
         cua,                          " CUA ist initialisiert
         leave,
         dloss,                        " Test QVH
       END OF flag.

DATA: fehler(1) TYPE c.                " blank: keine Fehlerbearbeitung
"
*-----------------------------------------------------------------------
*        Einzelfelder / Konstanten
*-----------------------------------------------------------------------

DATA: init_cua(1).                     " Flag: CUA initialisiert
DATA: language LIKE sy-langu.          " Sprachschluessel
DATA: dyflg(1).                        " Neues Dynpro.
DATA: para3(1),                        " Parameter # 3 und 4 fuer
      para4(1).                        " SET_TITLE(CUA)
DATA: hil-posnr LIKE vbap-posnr,       " Hilfsfeld f. Positionsnr.
      hil-feld(30),                    " Name bei Cursor-Selektion
      hil-linie(3),
      hil-konum(10).                   " Konditionennumerierung
* DS  HIL-KONUM like konv-??????????????????
DATA: cursor-pos.
DATA: dynhex(4) TYPE x VALUE '64'.     " Dynpronummer Hex
DATA: i(4) TYPE p.                     " Zaehler
DATA: c1.

*-Literale fuer die Verarbeitung ---------------------------------------
DATA: modul-pool(8) VALUE 'SAPxxxxx',  " vollst.Bez. des AG/PG/MP/DB
      enter(4)      VALUE 'ENT2'.      " Standardwert für FCODE auf
*                                           Anforderungsbildern

DATA: xobjky     LIKE nast-objky.      " Objektkey für Nachrichtenstatus
DATA: xobjky_pos LIKE nast-objky.
DATA: xobjky_to  LIKE nast-objky.

* Programmname für Message-Handling
DATA: programmname LIKE progstruc VALUE 'SAPMV50A'.
DATA: kopfprogramm LIKE progstruc VALUE 'SAPFV50K'.

*-----------------------------------------------------------------------
*        Test-Ecke
*-----------------------------------------------------------------------
DATA: vtext183l(20),
      lf_modus,                        "Lieferschein Bearbeitungsmodus
      on            VALUE 'X',
      off           VALUE ' '.


ENHANCEMENT-POINT MV50ATOP_10 SPOTS ES_SAPMV50A STATIC.
*---------------------------------------------------------------------*
*        U S E R E X I T                                              **
*---------------------------------------------------------------------*
INCLUDE mv50atzz.                      " Data definitions in MV50ATOP

ENHANCEMENT-POINT MV50ATOP_03 SPOTS ES_SAPMV50A STATIC.

ENHANCEMENT-POINT MV50ATOP_02 SPOTS ES_SAPMV50A STATIC.
*---------------------------------------------------------------------*
*        B U S I N E S S   A D D - I N S                              **
*---------------------------------------------------------------------*
CLASS cl_exithandler DEFINITION LOAD.   "Vorwärtsdeklaration (ULa, 4.6c)

*eject.
ENHANCEMENT-POINT MV50ATOP_11 SPOTS ES_SAPMV50A STATIC.