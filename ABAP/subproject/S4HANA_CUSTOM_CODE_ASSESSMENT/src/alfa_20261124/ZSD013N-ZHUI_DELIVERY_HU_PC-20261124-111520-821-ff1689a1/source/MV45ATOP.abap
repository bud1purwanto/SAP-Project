PROGRAM sapmv45a MESSAGE-ID v1 NO STANDARD PAGE HEADING.

*---------------------------------------------------------------------*
*        Interne Tabellen zum Vertriebsbeleg                          *
*---------------------------------------------------------------------*
TABLES: rtext.
INCLUDE copydata.
INCLUDE konvdata.
INCLUDE maradata.
INCLUDE theaddat.
INCLUDE aposdata.
INCLUDE vbakdata.
INCLUDE vbapdata.
INCLUDE vblbdata.
INCLUDE vbbddata.
INCLUDE avbbddat.
INCLUDE vedadata.
INCLUDE vbepdata.
INCLUDE vbsndata.
INCLUDE vbkddata.
INCLUDE vbpadata.
INCLUDE sadrdata.
INCLUDE vbuvdata.
* Fakturierungsplan
INCLUDE fpladata.
INCLUDE fpltdata.

* Belegfluß
INCLUDE vbfadata.
INCLUDE vbupdata.
INCLUDE vbukdata.
TABLES:  vbstt.                        " Texte zum Status
* Nachrichten
TABLES: tnapr.
INCLUDE vmsgpart.
INCLUDE nastdata.
INCLUDE messdata.
INCLUDE idocdata.

* Text im Übersichtsbild
INCLUDE mv45atop_header_text_data.

* Kennzeichen, ob Text Formatierungen enthält
DATA: gv_formatierung TYPE c.

* Statuspflege im Übersichtsbild
INCLUDE mv45atop_status_overview_data.

* Ausfuhrgenehmigung
INCLUDE vbexdata.

* Table-Controls
INCLUDE tabcdata.
ENHANCEMENT-POINT MV45ATOP_11 SPOTS ES_MV45ATOP STATIC .

* Tabstrip-Controls
INCLUDE incltaxi.
INCLUDE tbstdata.


* BAPI Datenbereiche
INCLUDE bapidata.                      "Common-Bereich  für BAPI


*-----------------------------------------------------------------------
*        Datenbank-Tabellen
*-----------------------------------------------------------------------

TABLES:  knvd,                         " Kundenvertriebsdaten
         knvv,                         " Kundenstamm Vertriebsdaten
         knmt,                         " Kunde-Material-Info
         sadr.                         " Adressen
*-----------------------------------------------------------------------
*        Datenbank-Views
*-----------------------------------------------------------------------

TABLES:  vbco6,                        " Komm.Block Anzeigen
         vtcom,                        " Komm.Block Kundenview
         kuagv,                        " Kundenview Auftraggeber
         kuwev,                        " Kundenview Warenempfaenger
         kurgv,                        " Kundenview Regulierer
         kupav,                        " Kundenview Partner
         vakpa,                        " Aufträge zu Partnerrollen
         vakpa_ref,                    " View für Referenzbelege
         vapma.                        " Materialview



*eject

*-----------------------------------------------------------------------
*        ATAB-Tabellen
*-----------------------------------------------------------------------
TABLES:  ad01c_prof,                   " DP Profil
         akkp,                         " Finanzdokumentstamm - Kopfdaten
         tcurv,                        " Kurstypen für Währungsumrechnun
         tfacd,                        " Fabrikkalenderdefinitionen
         tgsbt, *tgsbt,                " Geschäftsbereiche
         tkkaa,                        " Abgrenzungsschlüssel
         tkkad,                        " Abgrenzungsschlüssel Text
         tspa,                         " Sparten
         tspat,                        " Sparten Text
         ttxd,                         " Struktur Steuerstandortcode
         tvbur,                        " Verkaufsbüro
         tvkbt,                        " Verkaufsbüro Text
         tvgrps,                       " Gruppenreferenzbed.: Schema
         tvkgr,                        " Verkäufergruppe
         tvgrt,                        " Verkäufergruppe
         tvkbz,                        " Verkaufsbüro
         tvbvk,                        " Verkäufergruppen
         tvkov,                        " Sparten je Verkaufsorg.
         tvkos,                        " Vertriebswege je Verkaufsorg.
         tvasp,                        " Auftragssperre
         tvast,                        " Auftragssperre Text
         tvfk,                         " Fakturaarten
         tvkt,                         " Kontengruppe Debitoren
         tvktt,                        " Kontengruppe Debitoren Texte
         tvlv,                         " Abrufe Verwendungskennzeichen
         tvlvt,                        " Verwendungskennzeichen: Texte
         tvuvf,                        " Fehlerprotokoll
         tvv1t,                        " Gruppe
         tvv2t,                        " Gruppe
         tvv3t,                        " Gruppe
         tvv4t,                        " Gruppe
         tvv5t,                        " Gruppe
         tvm1t,                        " Gruppe
         tvm2t,                        " Gruppe
         tvm3t,                        " Gruppe
         tvm4t,                        " Gruppe
         tvm5t,                        " Gruppe
         t005,                         " Länder
         t005t,                        " Länderbezeichnung
         t005u,                        " Regionenbezeichnung
         t040,                         " mahnschlüssel
         t040a,                        " Mahnschlüssel Texte
         t040s,                        " Mahnsperre
         t040t,                        " Mahnsperre Texte
         t459a,                        " Bedarfsübergabe
         t459k,                        " Bedarfsübergabe
         t459w,                        " Bedarfsübergabe
         t681z,                        " Nachrichten Applikationsdaten
         t134,                         " Materialarten
         t156b,                        " Bewegungsarten
         t173t,                        " Routen: Verk. Versandart: Texte
         tvsakt,                       " Sonderabwicklungskennzeichen:Te
         tvtyt,                        " Versandhilfsmittelarten: Bezei
         t683,                         " Kalkulationsschemata
         t683t,                        " Kalkulationsschemata: Texte
         t023, t023t,                  " Warengruppe
         t691l,                        " Bezeichnung Absicherungsform
         t691m,                        " Absicherungsschema
         t691n,                        " Bezeichnung Absicherungsschema
         klah, swor,                   " Warengruppenhierarchie
         tvkgg, tvkggt,                " Kundenattribute10-15
         t377,                         " Serialnummernprofil
         t180 ,                        " Steuerung Transaktionsstart
         wsoh,                         " Sortiments-Bausteine R/3 Retail
         tvstat.                       " Status im Übersichtsbild
*eject
*-----------------------------------------------------------------------
*        ATAB-Tabellen
*-----------------------------------------------------------------------
DATA: list_status(4).                  " Status für Listprocessing
*eject
*-----------------------------------------------------------------------
*        Types
*-----------------------------------------------------------------------
TYPE-POOLS: v21a,                      " Zahlungskarten
            lv09a,                     " Partner
            lv70t,                     " Texte
            vsep.                      " Handling Units
*eject

* Später weg

TABLES:  d020s,                        " Dynpro
         t185 ,                        " Struktur
         t185f,                        " Funktionscodes
         t185v,                        " Verarbeitungsinformationen
         tstc,                         " Transaktionen
         tstct,                        " Texte zu TSTC
         tvcpa,                        " kopieren
         tpar,                         " Partnertabelle
         tpaer,                        " erlaubte Partner
         tpart.                        " Texte zu TPAR

TABLES:  komk,                         "Preisfindung Kommunikations-Kopf
         komp.                         "Preisfindung Kommunikations-Pos
*EJECT

*-----------------------------------------------------------------------
*        allgemeine Felder
*-----------------------------------------------------------------------

INCLUDE mv45acom.
TABLES:  rv02p.                        " E/A-Felder
DATA: inri_rcode LIKE inri-returncode. " Returncode Nummernvergabe

*-----------------------------------------------------------------------
*        Sortimentsbaustein
*-----------------------------------------------------------------------
DATA: BEGIN OF xwsop OCCURS 100,
        sposi LIKE wsop-sposi,
        datuv LIKE wsop-datuv,
        datub LIKE wsop-datub,
        arktx LIKE vbap-arktx.
DATA: END OF xwsop.

*-----------------------------------------------------------------------
*        Daten für Auftragsanlage via Container
*-----------------------------------------------------------------------
DATA: BEGIN OF i_vbakkom.
        INCLUDE STRUCTURE vbakkom.
DATA: END OF i_vbakkom.
DATA: BEGIN OF i_vbakkomx.
        INCLUDE STRUCTURE vbakkomx.
DATA: END OF i_vbakkomx.
DATA: BEGIN OF ix_vbapkom OCCURS 0.
        INCLUDE STRUCTURE vbapkom.
DATA: END OF ix_vbapkom.
DATA: BEGIN OF ix_vbapkomx OCCURS 0.
        INCLUDE STRUCTURE vbapkomx.
DATA: END OF ix_vbapkomx.
DATA: BEGIN OF ix_vbpakom OCCURS 0.
        INCLUDE STRUCTURE vbpakom.
DATA: END OF ix_vbpakom.
DATA: BEGIN OF ix_vbepkom OCCURS 0.
        INCLUDE STRUCTURE vbepkom.
DATA: END OF ix_vbepkom.
DATA: BEGIN OF ix_vbepkomx OCCURS 0.
        INCLUDE STRUCTURE vbepkomx.
DATA: END OF ix_vbepkomx.
DATA: BEGIN OF ix_konvkom OCCURS 0.
        INCLUDE STRUCTURE konvkom.
DATA: END OF ix_konvkom.
DATA: BEGIN OF ix_konvkomx OCCURS 0.
        INCLUDE STRUCTURE konvkomx.
DATA: END OF ix_konvkomx.
DATA: BEGIN OF ix_komfkzm OCCURS 0.
        INCLUDE STRUCTURE komfkzm.
DATA: END OF ix_komfkzm.
DATA: BEGIN OF sales_cfgs_ref OCCURS 0.
        INCLUDE STRUCTURE cuxe1cucfg.
DATA: END OF sales_cfgs_ref.
DATA: BEGIN OF sales_cfgs_inst OCCURS 0.
        INCLUDE STRUCTURE cuxe1cuins.
DATA: END OF sales_cfgs_inst.
DATA: BEGIN OF sales_cfgs_part_of OCCURS 0.
        INCLUDE STRUCTURE cuxe1cuprt.
DATA: END OF sales_cfgs_part_of.
DATA: BEGIN OF sales_cfgs_value OCCURS 0.
        INCLUDE STRUCTURE cuxe1cuval.
DATA: END OF sales_cfgs_value.
DATA: BEGIN OF sales_cfgs_blob OCCURS 0.
        INCLUDE STRUCTURE cuxe1cublb.
DATA: END OF sales_cfgs_blob.
DATA: BEGIN OF i_vbakkom_ref.
        INCLUDE STRUCTURE vbakkom_ref.
DATA: END OF i_vbakkom_ref.
* Attributtabelle für Objektreferenzen auf Positionsebene
DATA: BEGIN OF i_attr_tab OCCURS 0.
        INCLUDE STRUCTURE brelattr.
DATA: END OF i_attr_tab.
* Tabelle der Belegadressen im ZAV Format
DATA: BEGIN OF partneraddresses OCCURS 0.
        INCLUDE STRUCTURE bapiaddr1.
DATA: END OF partneraddresses.
* synchronous update
DATA: synchronous(1) TYPE c.
* internal item number
DATA: i_posnr(1)      TYPE c.
* message type for the dialogue BAPI
data: message_type(1) type c.
*EJECT

*-----------------------------------------------------------------------
*        Tabelle nicht aktiver FCODES
*-----------------------------------------------------------------------
DATA: BEGIN OF cua_exclude OCCURS 25,
        function(20),
        message(3),
      END OF cua_exclude.

* Unterscheidung des fixen vom variablen Teil der Tabelle cua_exclude
* siehe form exclude_function_trtyp
DATA: cua_excl_fix_tabix  LIKE sy-tabix.

* Nicht aktiv bei Anzeige
DATA: BEGIN OF cua_exclu_anzeige,
        f01(20) VALUE 'EIAN',
        f02(20) VALUE 'EILE',
        f03(20) VALUE 'EILO',
        f04(20) VALUE 'LOES',
        f05(20) VALUE 'POAN',
        f06(20) VALUE 'POLE',
        f07(20) VALUE 'POLO',
        f08(20) VALUE 'RANF',
        f09(20) VALUE 'RANG',
        f10(20) VALUE 'RAUF',
        f11(20) VALUE 'RKON',
        f12(20) VALUE 'SERL',
        f13(20) VALUE 'SFSP',
        f14(20) VALUE 'SLPR',
        f15(20) VALUE 'SWLD',
        f16(20) VALUE 'SWRK',
        f17(20) VALUE 'TEAN',
        f18(20) VALUE 'TELO',
        f19(20) VALUE 'UMAT',
        f20(20) VALUE 'RBES',
        f21(20) VALUE 'SLSP',
        f22(20) VALUE 'SICH',
        f23(20) VALUE 'KONB',
        f24(20) VALUE 'ANZE',
        f25(20) VALUE 'TEEN',
        f26(20) VALUE 'PORE',
        f27(20) VALUE 'BVFP',
        f28(20) VALUE 'LGKO',
        f29(20) VALUE 'STEF',
        f30(20) VALUE 'STAB',
        f31(20) VALUE 'SDES',
        f32(20) VALUE 'BUTA',
        f33(20) VALUE 'BTAB',
        f34(20) VALUE 'PABV',
        f35(20) VALUE 'PABN',
        f36(20) VALUE 'LSKO',
        f37(20) VALUE 'CHFD',
        f38(20) VALUE 'APPL',
        f39(20) VALUE 'APHC',
        f40(20) VALUE 'S\PORE',
        f41(20) VALUE 'S\CHFD',
        f42(20) VALUE 'S\POLE',
        f43(20) VALUE 'PABG',
        f44(20) VALUE 'BABS',
        f45(20) VALUE 'UAPV',
        f46(20) VALUE 'PVMV',
        f47(20) VALUE 'COPY',
        f48(20) VALUE 'POTE'.

ENHANCEMENT-POINT MV45ATOP_02 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT MV45ATOP_01 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT MV45ATOP_09 SPOTS ES_MV45ATOP STATIC .
DATA:
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_anzeige.
* Nicht aktiv bei Anlegen
DATA: BEGIN OF cua_exclu_anlegen,
        f01(20) VALUE 'LOES',
        f02(20) VALUE 'IAEN',
        f03(20) VALUE 'IFLU',
        f04(20) VALUE 'ILIF',
        f05(20) VALUE 'DRCK',
        f06(20) VALUE 'ANLE',
        f07(20) VALUE 'LIST',
        f08(20) VALUE 'NARC',
        f09(20) VALUE 'PABV',
        f11(20) VALUE 'LYSE',
        f12(20) VALUE 'STAT',
        f13(20) VALUE 'S\IFLU',
        f14(20) VALUE 'POSR',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_anlegen.
* Nicht aktiv bei Ändern
DATA: BEGIN OF cua_exclu_aendern,
        f01(20) VALUE 'AEND',
        f02(20) VALUE 'AEND',
        f03(20) VALUE 'UAPV',
        f04(20) VALUE 'PVMV',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_aendern.
* Nicht aktiv bei Call Dialog
DATA: BEGIN OF cua_exclu_dialog,
        f01(20) VALUE 'AEND',
        f02(20) VALUE 'ANLE',
        f03(20) VALUE 'ANZE',
        f04(20) VALUE 'BELO',
        f05(20) VALUE 'EIBA',
        f06(20) VALUE 'FAUF',
        f07(20) VALUE 'FAU1',
        f08(20) VALUE 'FFAK',
        f09(20) VALUE 'FFA1',
        f10(20) VALUE 'FLIF',
        f11(20) VALUE 'FLI1',
        f12(20) VALUE 'SICH',
        f13(20) VALUE 'KDOK',
        f14(20) VALUE 'PDOC',
        f15(20) VALUE 'PDOK',
        f16(20) VALUE 'POTO',
        f17(20) VALUE 'PKAL',
*       f18(20) value 'ABBA',
*       f19(20) value 'BABA',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_dialog.

* Nicht aktiv bei RFC
DATA: BEGIN OF cua_exclu_rfc,
        f01(20) VALUE 'FFA1',
        f02(20) VALUE 'FLI1',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_rfc.

* Nicht aktiv bei Call Transaction
DATA: BEGIN OF cua_exclu_call,
        f01(20) VALUE 'ANLE',
        f02(20) VALUE 'ANZE',
        f03(20) VALUE 'FLI1',
        f04(20) VALUE 'FFA1',
        f05(20) VALUE 'FAU1',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_call.

* Payment Service Provider
DATA: BEGIN OF cua_exclu_paysp,
        f01(20) VALUE 'POAN',
        f02(20) VALUE 'POLO',
        f03(20) VALUE 'SFSP',
        f04(20) VALUE 'SLPR',
        f05(20) VALUE 'SWLD',
        f06(20) VALUE 'SWRK',
        f07(20) VALUE 'UMAT',
        f08(20) VALUE 'KONB',
        f09(20) VALUE 'PORE',
        f10(20) VALUE 'BVFP',
        f11(20) VALUE 'COPY',
        f12(20) VALUE 'RIBS',
        f13(20) VALUE 'SLSP',
        f14(20) VALUE 'CHFD',
        f15(20) VALUE 'POTE',
        f16(20) VALUE 'APHC',
        f17(20) VALUE 'APPL',
        f18(20) VALUE 'DKON',
        f19(20) VALUE 'KRPL',
        f99(20) VALUE '9999',          " Kennzeichen Loop-Ende
      END OF cua_exclu_paysp.


* BAdI
DATA: gs_cust_tab TYPE sales_cust_tab_page.

* New Screen BAdI
DATA: go_screenbadi_cus_h      TYPE REF TO badi_sls_head_scr_cus,
      gs_screenbadi_cus_h      TYPE sales_cust_tab_page,
      gt_screenbadi_cus_h      TYPE sales_cust_tab_page_t,
      go_screenbadi_cus_i      TYPE REF TO badi_sls_item_scr_cus,
      gs_screenbadi_cus_i      TYPE sales_cust_tab_page,
      gt_screenbadi_cus_i      TYPE sales_cust_tab_page_t,
      go_screenbadi_int_h  TYPE REF TO badi_sls_head_scr_int,
      gs_screenbadi_int_h  TYPE tds_head_scr_int,
      gt_screenbadi_int_h  TYPE tdt_head_scr_int,
      go_screenbadi_int_i  TYPE REF TO badi_sls_item_scr_int,
      gs_screenbadi_int_i  TYPE tds_item_scr_int,
      gt_screenbadi_int_i  TYPE tdt_item_scr_int.

CONSTANTS: cv_badi_max_tabs_cus TYPE i VALUE '5',
           cv_badi_max_tabs_int TYPE i VALUE '5'.

***

*-----------------------------------------------------------------------
*        Hilfs- und Rechenfelder
*-----------------------------------------------------------------------
DATA: dynnr      LIKE sy-dynnr.
DATA: xobjky     LIKE nast-objky.      " Objektkey für Nachrichtenstatus
DATA: xobjky_pos LIKE nast-objky.      " Objektkey für Nachrichtenstatus
DATA: xobjky_to  LIKE nast-objky.      " Objektkey für Nachrichtenstatus
DATA: cua_text(80)      TYPE c.        " CUA-Text
DATA: propos            TYPE c.        " Vorschlag erfolgt
DATA  titel2(5)         TYPE c.        " Definition für Dynpo 700
DATA: dynpro_sub(4)     TYPE c.        " Dynpro des Subscreens
DATA: dynpro_ehs(4) TYPE c VALUE '2000'. "Dynpro für EH&S-Subscreen
DATA: dynpro_buttons(4) TYPE c.        " Dynpro Buttonleiste auf Übers.
DATA: id(4)             TYPE c.        " ID für Top of Page
DATA: alekz       LIKE tvap-alekz.     " ALE-Relevanz
DATA: mmflag      LIKE tvap-alekz.     " vom MM bestätigt
DATA: wgru_1_txt  LIKE swor-kschl,     " Text WG-Hierarchie Dynpro 451
      wgru_2_txt  LIKE swor-kschl.     " Text WG-Hierarchie Dynpro 451
DATA: tvkggt_txt1 LIKE tvkggt-vtext,   " Text Kundenattribut_11    451
      tvkggt_txt2 LIKE tvkggt-vtext,   " Text Kundenattribut_12    451
      tvkggt_txt3 LIKE tvkggt-vtext,   " Text Kundenattribut_13    451
      tvkggt_txt4 LIKE tvkggt-vtext,   " Text Kundenattribut_14    451
      tvkggt_txt5 LIKE tvkggt-vtext.   " Text Kundenattribut_15    451
DATA: BEGIN OF na_vbkd.
        INCLUDE STRUCTURE vbkd.
DATA: END OF na_vbkd.
DATA: orgdaten_vorbelegt.    " Flag: Orgdaten im Einstieg vorbelegt ?
DATA: leave_without_check(1) TYPE c.   " Flag Ende ohne Prüfung
DATA: force_update.          " from rescheduling. See note 644789


*---------------------------------------------------------------------*
*        POV-Hilfsfelder                                              *
*---------------------------------------------------------------------*
DATA: BEGIN OF t_dynpread OCCURS 0.
        INCLUDE STRUCTURE dynpread.
DATA: END   OF t_dynpread.
DATA: da_dynpprog    LIKE sy-repid,
      da_dynpnr      LIKE sy-dynnr,
      da_stepl       LIKE help_info-stepl,
      da_dynprofield LIKE help_info-dynprofld.
DATA: da_tabname   LIKE dd03v-tabname,
      da_fieldname LIKE dd03v-fieldname.
DATA: da_display LIKE ddrefstruc-bool.
DATA: help_f(10) TYPE c.
DATA: da_trtyp LIKE t185f-trtyp.
DATA: help_tabix LIKE sy-tabix.
DATA: BEGIN OF help_vbap.
        INCLUDE STRUCTURE vbap.
DATA: END OF help_vbap.
DATA: BEGIN OF help_vbep.
        INCLUDE STRUCTURE vbep.
DATA: END OF help_vbep.
* Aktionsfindung
DATA: BEGIN OF help_vbkd.
        INCLUDE STRUCTURE vbkd.
DATA: END OF help_vbkd.
DATA: f4_wakh TYPE waktp_promohead WITH HEADER LINE.
* fields of exchange rate values
DATA: da_kurstyp LIKE vbak-kurst,
      da_kursdatum LIKE vbkd-kursk_dat.

*EJECT

*---------------------------------------------------------------------*
*        Direktwerte                                                  *
*---------------------------------------------------------------------*

INCLUDE rvdirekt.

* ... weitere Konstanten
INCLUDE v70t_text_constants.

*-Flags ----------------------------------------------------------------

* SD-Monitor-Flaggen
DATA:  BEGIN OF xsdctrlflag.
        INCLUDE STRUCTURE sdctrlflag.
DATA:  END   OF xsdctrlflag.

DATA:  BEGIN OF flag,
         no,                           " keine FAW in Loop
         cua,                          " CUA ist initialisiert
         leave,
       END OF flag.

* Unvollständigkeitsdialog aktiv
DATA: incompletion_active.

* Feldauswahl VA90/DP90 Folgebeleg
DATA: gsv_screen_input TYPE i VALUE 2.

* Kreditfreigabe
DATA: no_rv_delivery_init.

* BADI_SD_TO_FM
DATA: inst_badi_sd_to_fm   TYPE REF TO if_ex_badi_sd_to_fm,
      active_badi_sd_to_fm TYPE xfeld.

*BADI_SD_DPBP
DATA: inst_badi_sd_dpbp   TYPE REF TO if_ex_badi_sd_dpbp,
      active_badi_sd_dpbp TYPE xfeld.

* BADI_SD_DMC_ORDER
DATA: l_sd_dmc_order_exit TYPE REF TO if_ex_badi_sd_dmc_order.
DATA: dmc_active TYPE xfeld.
DATA: dmc_cflag.

* BADI_SD_DSD_ORDER
DATA: l_sd_dsd_order_exit TYPE REF TO if_ex_badi_sd_dsd_order.
DATA: dsd_active TYPE xfeld.

*-----------------------------------------------------------------------
*        Einzelfelder / Konstanten
*-----------------------------------------------------------------------

* EDI Direktwerte
CONSTANTS:
       beleg_gebucht LIKE teds1-status VALUE '53',

*- Direktwerte für Workflow_Result
       c_wf_result_error LIKE bdwfap_par-result VALUE '99999',
       c_wf_result_ok    LIKE bdwfap_par-result VALUE '0',
*- Direktwerte für Return_variables
       pid(15) VALUE 'Processed_IDOCs',
       cob(15) VALUE 'Created_Objects',
       aot(16) VALUE 'Appl_Object_Type',
       ape(15) VALUE 'Appl_Object',
       apo(15) VALUE 'Appl_Objects'.

*-Literale fuer die Verarbeitung ---------------------------------------
DATA: modul-pool(40) VALUE  'SAPxxxxx'." vollst.Bez. des AG/PG/MP/DB
*-Literale für wiederholten CALL DIALOG      --------------------------
DATA: call_dialog_folge(1) TYPE c.
DATA: flag_leave_screen    TYPE c.
DATA: t176t-vtext_k LIKE t176t-vtext.
DATA: t176t-vtext_e LIKE t176t-vtext.
*-Feld für Produkthierarchietext
DATA: ph_vtext LIKE prodh_disp-vtext.
DATA: BEGIN OF xdisp_t179 OCCURS 0.
        INCLUDE STRUCTURE prodh_disp.
DATA: END   OF xdisp_t179.

*-Feld für Cursor/Dynpro
DATA: cursorfield(40),
      gl_fcode(20).

DATA  display_mode.

* IS2ERP ECC-DIMP / IS-OIL start
INCLUDE mv45aiis.

*  Tablecontrol für TC-Subscreen 4.0
*   Equipmentleistung
CONTROLS  tctrl_u_erf_cem_equ  TYPE TABLEVIEW USING SCREEN 4985.
*   Material-Verkauf/-Rückkauf
CONTROLS  tctrl_u_erf_cem_mav  TYPE TABLEVIEW USING SCREEN 4988.

* Table control for dynpro SAPMV45A 8350
CONTROLS: gv_tc_header_interest TYPE TABLEVIEW USING SCREEN 8350.
DATA: dummy_field_empty_tc TYPE c,
      selkz TYPE c.

* Data declaration of screen SAPMV45A 924 (IS-OIL)
DATA: BEGIN OF oidfoe OCCURS 15,       "Table for Sales Area
           vkorg LIKE knvv-vkorg,     "defaulting
           vtweg LIKE knvv-vtweg,
           spart LIKE knvv-spart,
      END OF oidfoe.
DATA: oid_index     TYPE i.            "General index

* IS2ERP ECC-DIMP / IS-OIL end

ENHANCEMENT-POINT MV45ATOP_04 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT MV45ATOP_03 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT MV45ATOP_12 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT MV45ATOP_05 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT MV45ATOP_06 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT MV45ATOP_07 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT MV45ATOP_08 SPOTS ES_SAPMV45A STATIC .

*VA03 display from archive / START
* flag for display from archive
DATA: gv_asuc type c,
      gv_vbak_special_archiving type c.

* data gv_erdat type dats.
* ranges gv_erdat_sel for gv_erdat.
DATA: BEGIN OF gv_erdat_sel OCCURS 1,
         sign(1) VALUE 'I',
         option(2),
         low  TYPE erdat_arc,
         high TYPE erdat_arc,
      END   OF gv_erdat_sel.
*VA03 display from archive / END

*SAPMP Returns Processing Pop UP-Data:
DATA  ok_code_chcr(4).

*---------------------------------------------------------------------*
*        U S E R E X I T                                              **
*---------------------------------------------------------------------*
INCLUDE mv45atzz.                      " Data definitions in MV45ATOP

ENHANCEMENT-POINT MV45ATOP_10 SPOTS ES_SAPMV45A STATIC.
*eject.

* Advanced Returns related data definitions
INCLUDE msrdata.



*---------------------------------------------------------------------*
*        customer search                                                *
*---------------------------------------------------------------------*
DATA: in_search_term(30),
      row_table            TYPE lvc_t_row,
      gs_row_table         LIKE LINE OF row_table,
      g_container          TYPE scrfname VALUE 'BCALV_GRID',
      gv_kunnr_from_search TYPE kunnr,
      gv_right_click       TYPE xfeld,
      gv_set_kunnr         TYPE xfeld,
      g_custom_container   TYPE REF TO cl_gui_custom_container,
      g_layout1            TYPE lvc_s_layo,
      oref                 TYPE REF TO cx_root,
      text                 TYPE string,
      gv_search_term_old   TYPE tdd_kunag_search_term,
      gt_sold_to_party     TYPE tdt_search_customer,
      gs_sold_to_party     LIKE LINE OF gt_sold_to_party,
      grid1                TYPE REF TO cl_gui_alv_grid,
      search_mode          TYPE c,
      gv_search_mode_old   TYPE c.

TABLES: tds_kunag_search_term.