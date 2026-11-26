*-----------------------------------------------------------------------
*        Datenbank-Tabelle VBAK
*-----------------------------------------------------------------------

TABLES:  nriv,                         " Übergabebereich Nummernvergabe
         vbak,
        *vbak,
         tcurc,
         tcuro,              "Objekttypen für auslaufende Währungen
         tskd,
         tvak,
         *tvak,                        " kopieren: Nach Auftrag
         tvakt,
         tvakz,                        " erlaubte Auftragsarten
         tvau,
         tvauk,
         tvaut,
         vbmue,                        " Merkmalsübersichten
         vbmuez,                       " Merkmalsübersichten Merkmale
         vbmuet,                       " Merkmalsübersichten Text
         t001,                         " Buchungskreis
         t001n,                        " Buchungskreis-Steuernummern
         tcsp,                         " Cross-Selling Profil
         tcspf,                        " Find. Cross-Selling Profil
         tpvsm,                        " Produktvorschlagsschema
         tvdc,                         " Lieferzeit
         tvdct,                        " Lieferzeit
         tvko,                         " Verkaufsorganisation
         tvkot,                        " Verkaufsorganisation Text
         tvsb,                         " Versandbedingung
         tvsbt,                        " Versandbedingung
         tvta,                         " Vertriebsbereich
         tvtw,                         " Vertriebsweg
         tvtwt,                        " Vertriebsweg         Text
         tvv1,                                              " Gruppe 1
         tvv2,                                              " Gruppe 2
         tvv3,                                              " Gruppe 3
         tvv4,                                              " Gruppe 4
         tvv5,                                              " Gruppe 5
         t176, t176t,                  " Bestellart           Text
         t683c,                        " Suchschema Chargenfindung
         t683u,                        " Text Kalk.schema
         t683v,                        " Find Kalk.schema
         tka00,                        " COPA
         kona,                         " Absprache
         tvgrpt,                       " Gruppenreferenzschemata
         tvgrpb,                       " Gruppenreferenzbelegart
         m_vmvaa,                      " Indextabelle Bestellnr.
         knvp.                         " Kundenstamm Partnerrollen

DATA: BEGIN OF COMMON PART vbakcom.

DATA: tuuid LIKE sysuuid-x.

* Adresse der Verkaufsorganisation
DATA: BEGIN OF tvko_sadr.
        INCLUDE STRUCTURE sadr.                             "SADR40A
DATA: END OF tvko_sadr.

* Alter Tabellenstand beim Ändern
DATA:    BEGIN OF yvbak.
        INCLUDE STRUCTURE vbak.
DATA:    END OF yvbak.
DATA:    yvbak_updkz.
DATA:    BEGIN OF ovbak.
        INCLUDE STRUCTURE vbak.
DATA:    END OF ovbak.

* Rettung von VBAK Feldern nach AG-Änderung.
DATA:    BEGIN OF xvbak.
        INCLUDE STRUCTURE vbak.
DATA:    agupda LIKE rv02p-agupd,
         weupda LIKE rv02p-weupd,
         auartupda,
         END OF xvbak.

* Aktueller Tabellenstand

DATA: upd_vbak.                        " Für Änderungsbelege

DATA: xvbak_updkz LIKE vbapd-updkz.
* Kennzeichen, dass ein Kopf angelegt wurde.
DATA: BEGIN OF svbak OCCURS 0,
        tabix LIKE sy-tabix,
      END OF svbak.

* Globalisieren der Übergabestruktur US_VBAKKOM
DATA: BEGIN OF us_vbakkom.
        INCLUDE STRUCTURE vbakkom.
DATA: END OF us_vbakkom.
DATA: BEGIN OF us_vbakkomx.
        INCLUDE STRUCTURE vbakkomx.
DATA: END OF us_vbakkomx.

* Vorschlagswerte bei Transaktionseinstieg
DATA: default_vkorg LIKE vbak-vkorg,
      default_vtweg LIKE vbak-vtweg,
      default_spart LIKE vbak-spart,
      default_vkbur LIKE vbak-vkbur,
      default_vkgrp LIKE vbak-vkgrp.

* Businessobjekt
DATA: businessobjekt LIKE nast-objtype.
DATA: ereignis LIKE swetypecou-event.

* Gruppenkontrakt
*   Hinweis auf bestehende Gruppenkontrakte darf nur einmal erfolgen
DATA: hinweis_grp_show(1) TYPE c,
      hinweis_protokoll_show(1) TYPE c.

*   Referenzierter UnterKontrakte
DATA: BEGIN OF gruko OCCURS 0.
        INCLUDE STRUCTURE rv46g_doc.
DATA: END OF gruko.
*   Blättern
DATA: gruko_tabix_zeile_1 LIKE sy-tabix,  "Tabix der ersten Zeile
      gruko_tabix_aktuell LIKE sy-tabix,  "laufender Tabix der Seite
      gruko_loopc         LIKE sy-tabix.  "Anzahl LOOP-Zeilen

* check discontinued currency ?
DATA: check_expired_currency(1) TYPE c.

* Hilfsfelder zum Merken der Benutzereingaben
* z.B. Änderungen bei der Ausgabe von W/E - Meldungen
DATA: vbakin LIKE vbak.

DATA: pricing_header(1) TYPE c.

DATA: checked_currency LIKE vbak-waerk.

DATA: currency_changed(1) TYPE c.

* run Serialprofile_check while save ?
DATA: serial_dataloss TYPE c.

* Special Payment Methods
DATA: gr_paysp TYPE REF TO cl_sls_paysp_integration.
DATA: gt_paysp_hl     TYPE cl_sls_paysp_integration=>tty_paysp_hl,
      gt_paysp_hl_old TYPE cl_sls_paysp_integration=>tty_paysp_hl.

ENHANCEMENT-POINT VBAKDATA_11 SPOTS ES_VBAKDATA STATIC INCLUDE BOUND .
DATA: END OF COMMON PART.

* Steuerermittlungregel                                       "eu-tax
CONSTANTS: flg_stceg_ag LIKE tvko-xstceg VALUE 'A',           "!
           flg_stceg_rg LIKE tvko-xstceg VALUE  'B',         "!
           flg_stceg_std LIKE tvko-xstceg VALUE 'C'.         "!


* Struktur für Messages
DATA: mess LIKE balmi,
      message_group LIKE balhdr-subobject.

*eject