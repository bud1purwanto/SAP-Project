PROGRAM sapmm07m MESSAGE-ID m7.
*-----------------------------------------------------------------------
*        Tabellen
*-----------------------------------------------------------------------

TABLES:  t000,                         " Mandant
         t001,                         " Buchungskreise
         t001u,                        " Buchungskreisverrechnung
         t030b,                        " Buchungsschluessel
         t148t,                        " Texte Sonderbestand
         t156c,                        " Bestandsarten
         t157d,                        " Grund der Bewegung
         t157e,                        " Text dazu
         t158n,                        " nächste Transaktion
         t158v,                        " Vorgangsarten
         t158w,                        " Vorgangsartentext
         t159p,                        " Mehrfachdruck
         t162k,                        " Feldauswahl Kontierung Einkauf
         t300t,                        " Text Lagernummer
         t301t,                        " Text Lagertyp
         t333t,                        " Text Bewegungsart LVS
         t340d,                        " Zentrale Steuerung LVS
         t043,                         " Sachbearbeiter / Toleranzgruppe
         t043i,                     " Toleranzgruppe / Inventurdifferenz
         accit_mb,                     " Kontierungsfelder
         ekko,                         " Bestellkopf
         ekpo,                         " Bestellposition
         bbefu,                        " Bestelldaten Umlagerbestellung
         ebefu,                        " Bestelldaten
         mcha,                         " Chargendaten
         mch1,                         " Chargendaten
         m_mbmps,                      " Matchcode Stornobelege
         m_mat1n,                      " Matchcode EAN-Nr.
*        m_vmvmb,                      " Matchcode Transportident.  "470
*        m_vmvma,                      " Matchcode Lieferscheinnummer
         lagp,                         " Lagerplätze LVS
         ltbp,                         " Transportbedarfsposition LVS
         qmsp,                         " Spezifiaktionen
         usr05,                        " vorübergehend
         m_mebex,                      " Matchcode WE-Belege zu XBLNR
         lfa1,                         " Lieferantenstamm A-Segment
         lfm1,                         " Lieferantenstamm EKORG-Daten
         marc,                         " Materialstamm Werkssegment
         msku,                         " Sonderbestände beim Kunden
         mslb,                         " Sonderbestände beim Lieferanten
         mstb,                         "SIT
         mste,                         "SIT
         mstq,                         "SIT
         prdkz,                        " Periodenkennzeichen MHD
         prdkzt.                       " Texte zum Periodenkennz. MHD

*-----------------------------------------------------------------------
*        COMMON DATA
*-----------------------------------------------------------------------

INCLUDE mm07mcom.
INCLUDE mm07mcwl.
INCLUDE mm07mcms.
INCLUDE mm07mcws.
INCLUDE mm07mcbu.
INCLUDE mm07mcfu.
INCLUDE fm07mcom.
INCLUDE mm07icom.
INCLUDE mm07icmb.
INCLUDE fm06ec07.
INCLUDE fm06lu02.
INCLUDE rm07msel.
INCLUDE vmsgpart.
INCLUDE coblincl.
INCLUDE ppcowe01.
INCLUDE mm07mdcl.
INCLUDE rm07debg.
INCLUDE mm07mass. " for handling assertions (keeping record of tables)

TYPE-POOLS: ck.

*------- Typ für Sammelartikel-WE's
TYPES: BEGIN OF t_sawe,
          ebeln LIKE mseg-ebeln,
          uebpo LIKE fuss-uebpo,
          lfbnr LIKE mseg-lfbnr,
          wesbs LIKE ebefu-wesbs,
          bpwes LIKE ebefu-bpwes,
          wemng LIKE ebefu-wemng,
          bpwem LIKE ebefu-bpwem,
          wewrt LIKE ebefu-wewrt,
          wewwr LIKE ebefu-wewwr,
          remng LIKE ebefu-remng,
          bprem LIKE ebefu-bprem,
          rewrt LIKE ebefu-rewrt,
          rewwr LIKE ebefu-rewwr,
          arewr LIKE ebefu-arewr,
          areww LIKE ebefu-areww,
       END OF t_sawe.
TYPES: t_it_sawe TYPE STANDARD TABLE OF t_sawe
                      WITH DEFAULT KEY.

*                                                   * begin note 356129
*------- Typ für Retail Kopf-Zeilenstruktur              "note 328675
* TYPES: BEGIN OF T_RSTRUCT,                             "note 328675
*           MATNR      LIKE MSEG-MATNR ,                 "note 328675
*           BSTME      LIKE MSEG-BSTME ,                 "note 328675
*           ERFME      LIKE MSEG-ERFME ,                 "note 328675
*           MATNRVOR   LIKE MSEG-MATNR ,                 "note 328675
*           BSTMEVOR   LIKE MSEG-BSTME ,                 "note 328675
*           ERFMEVOR   LIKE MSEG-ERFME ,                 "note 328675
*           XAUTO      LIKE MSEG-XAUTO ,                 "note 328675
*           UPTYP      LIKE DM07M-UPTYP,                 "note 328675
*           UPVOR      LIKE DM07M-UPVOR,                 "note 328675
*           ATTYP      LIKE VM07M-ATTYP,                 "note 328675
*        END OF T_RSTRUCT.                               "note 328675
* TYPES: T_IT_RSTRUCT                                    "note 328675
*        TYPE STANDARD TABLE OF T_RSTRUCT                "note 328675
*                      WITH DEFAULT KEY.                 "note 328675
*
*------- Typ für Retail XYMSEG                           "note 328675
* TYPES: BEGIN OF T_XYMSEG,                              "note 328675
*              MATNR  LIKE MSEG-MATNR ,                  "note 328675
*              BSTME  LIKE MSEG-BSTME ,                  "note 328675
*              ERFME  LIKE MSEG-ERFME ,                  "note 328675
*              XAUTO  LIKE MSEG-XAUTO ,                  "note 328675
*              EBELN  LIKE MSEG-EBELN ,                  "note 328675
*              EBELP  LIKE MSEG-EBELP ,                  "note 328675
*              LFBNR  LIKE MSEG-LFBNR ,                  "note 328675
*              ZEILE  LIKE MSEG-ZEILE ,                  "note 328675
*              URZEI  LIKE MSEG-URZEI ,                  "note 328675
*              ERFMG  LIKE MSEG-ERFMG ,                  "note 328675
*              KZOK   TYPE C          ,                  "note 328675
*        END OF T_XYMSEG.                                "note 328675
* TYPES: T_IT_XYMSEG                                     "note 328675
*        TYPE STANDARD TABLE OF T_XYMSEG                 "note 328675
*                      WITH DEFAULT KEY.                 "note 328675
*                                                   * end   note 356129

* Typdeklarationen für Umlagerung mit ProdME        "Begin of ALRK115218
TYPES:
BEGIN OF meinh_typ,
  seg_index TYPE i,
  zeilu LIKE mseg-zeile,
  meinh LIKE marm-meinh,
END   OF meinh_typ,
BEGIN OF ws_meng_typ,
  altmg   LIKE mseg-erfmg,
  meinh LIKE mseg-erfme,
END OF   ws_meng_typ,
BEGIN OF seg_typ,
  matnr      LIKE mseg-matnr,
  werks      LIKE mseg-werks,
  lgort      LIKE mseg-lgort,
  charg      LIKE mseg-charg,
  sobkz      LIKE mseg-sobkz,
  kdauf      LIKE mseg-kdauf,
  kdpos      LIKE mseg-kdpos,
  lifnr      LIKE mseg-lifnr,
  ps_psp_pnr LIKE mseg-ps_psp_pnr,
  kunnr      LIKE mseg-kunnr.
ENHANCEMENT-POINT mm07mtop_05 SPOTS es_sapmm07m STATIC.
TYPES:
  lbbsa      LIKE vm07m-lbbsa,
END   OF seg_typ. "End SW Stahl                     "End of ALRK115218

* Type for subcontractor-components
TYPES: BEGIN OF ty_s_xmdvw.
INCLUDE TYPE mdvw.
TYPES: global_counter TYPE goitem-global_counter.
* Feld 'charg' schon in struktur MDVW enthalten.
*           TYPES: charg          TYPE mseg-charg.        " SC-batch
*TYPES: bwtar          TYPE mseg-bwtar.                       "1356935
TYPES: bstme          TYPE mseg-bstme.                      "509418
TYPES: serial_glc     TYPE dm07m-imseg_original.
        INCLUDE STRUCTURE document_structure.
*        COBL is not needed here as it will be copied directly
*        from lt_gocomp in MIGO case.
*        Do not extend other fields to XMDVW here to copy from
*        GOCOMP as they will come as SPACE from ME_READ_COMPONENTS,
*        which is not initial for numerical fields! Use instead
*        manual moves in Form LOHNBEARBEITUNG (see gocomp-cobl)
TYPES: END   OF ty_s_xmdvw.

*eject
*-----------------------------------------------------------------------
*       Datenfelder fuer das Programm SAPMM07M und zugehoerige
*       INCLUDEs

*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*       Teil 3 :  Einzelfelder  ( variabel )
*       Teil 4 :  Konstanten
*       Teil 5 :  Field-Symbols

*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*       Teil 1 :  Tabellen      ( BEGIN OF ... OCCURS )
*-----------------------------------------------------------------------

*------- Tabelle der vorläufigen Positionen (im Selektionsmodus)
DATA:    BEGIN OF COMMON PART mm07mwbu.

DATA: BEGIN OF zmseg OCCURS 0.
        INCLUDE STRUCTURE mseg.
DATA: END OF zmseg.

DATA: BEGIN OF zvm07m OCCURS 0.
        INCLUDE STRUCTURE vm07m.
DATA: END OF zvm07m.

DATA: BEGIN OF zdm07m OCCURS 0.
        INCLUDE STRUCTURE dm07m.
DATA: END OF zdm07m.

DATA:     END OF COMMON PART mm07mwbu.

DATA: BEGIN OF zeklb OCCURS 0.
        INCLUDE STRUCTURE seklb.
DATA: END OF zeklb.

DATA: BEGIN OF zzcxcm OCCURS 0.
        INCLUDE STRUCTURE zcxcm.
DATA: END OF zzcxcm.

DATA: BEGIN OF xchvw OCCURS 0.
        INCLUDE STRUCTURE chvw.
DATA: END OF xchvw.

DATA: BEGIN OF xaufm OCCURS 0.
        INCLUDE STRUCTURE aufm.
DATA: END OF xaufm.

*------- Tabelle zum Zwischenspeichern der Daten
DATA: BEGIN OF old OCCURS 0.
        INCLUDE STRUCTURE mseg.
DATA:   maktx LIKE dm07m-maktx,
        xhell,
        xselk,
        xselp.
DATA: END OF old.

*------- Tabelle der Bewegungsarten
DATA: BEGIN OF bwart OCCURS 0,
        btext(40) TYPE c,
        bwart LIKE t156t-bwart,
      END OF bwart.

*------- Ursprünglicher Bildinhalt beim Warenausgang/Umbuchung
DATA: BEGIN OF bild OCCURS 0,
        zeile LIKE mseg-zeile,
        erfmg LIKE mseg-erfmg,
        erfme LIKE mseg-erfme,
        matnr LIKE mseg-matnr,
        charg LIKE mseg-charg,
        lgort LIKE mseg-charg,
        werks LIKE mseg-werks,
        rspos LIKE mseg-rspos,
        kzear LIKE mseg-kzear,
        xauto LIKE mseg-xauto,
        urzei LIKE mseg-urzei,
        sgtxt LIKE mseg-sgtxt.                              "676968
ENHANCEMENT-POINT mm07mtop_01 SPOTS es_sapmm07m STATIC.
DATA:
END OF bild.


*------- Ursprünglicher Bildinhalt beim Wareneingang
DATA: BEGIN OF biwe OCCURS 0,
        zeile LIKE mseg-zeile,
        erfmg LIKE mseg-erfmg,
        erfme LIKE mseg-erfme,
        menge LIKE mseg-menge,
        meins LIKE mseg-meins,
        matnr LIKE mseg-matnr,
        werks LIKE mseg-werks,
        lgort LIKE mseg-lgort,
        charg LIKE mseg-charg,
        insmk LIKE mseg-insmk,
        elikz LIKE mseg-elikz,
        xhell LIKE rm07m-xhell,
        dimng LIKE dm07m-bdmng,
        mhdat TYPE vfdat,
        hsdat_input TYPE vfdat,
        vfdat_input TYPE vfdat,
        idnlf       TYPE idnlf,
        ean11_bme   TYPE ean11_bme,
        lsmng LIKE mseg-lsmng,
        lsmeh LIKE mseg-lsmeh,
        xauto LIKE mseg-xauto,
        urzei LIKE mseg-urzei.
ENHANCEMENT-POINT MM07MTOP_08 SPOTS ES_SAPMM07M STATIC .

  DATA: elikz_input TYPE elikz,
      END OF biwe.

*------- Tabelle mit Lohnbearbeiter-Komponenten
DATA: xmdvw TYPE STANDARD TABLE OF ty_s_xmdvw WITH HEADER LINE.


*------- Tabelle der Belegpositionen für die NAST-Sätze existieren ----*
DATA: BEGIN OF nasttab OCCURS 0,
        key(18) TYPE c,
      END OF nasttab.

DATA: BEGIN OF xeksel OCCURS 0.
        INCLUDE STRUCTURE eksel.
DATA: END OF xeksel.

*------- Tabelle und Feldleisten fuer Verfuegbarkeitsblock
DATA: BEGIN OF vtext OCCURS 0,
        segmn(4)  VALUE  ' ',          "Name Praefix
        binde(1)  VALUE  '-',          "Bindestrich
        feldn(5)  VALUE  ' ',          "Name Suffix
        texta(20) VALUE ' ',           "Text des Feldes
        menge LIKE mseg-menge,         "Mng aus Mengensperrtabelle
      END OF vtext.

*------ Tabellen für die Statistikfortschreibung ----------------------*
DATA: BEGIN OF xmcmseg OCCURS 0.
        INCLUDE STRUCTURE mcmseg.
DATA: END OF xmcmseg.

DATA: BEGIN OF xmcbest OCCURS 0.
        INCLUDE STRUCTURE mcbest.
DATA: END OF xmcbest.

DATA: BEGIN OF xmcmres OCCURS 0.
        INCLUDE STRUCTURE smres.
DATA: END OF xmcmres.

DATA: BEGIN OF xmcmbew OCCURS 0,
        matnr     LIKE mbew-matnr,
        bwkey     LIKE mbew-bwkey,
        salk3     LIKE mbew-salk3,
        salk3_old LIKE mbew-salk3,
        lbkum_old LIKE mbew-lbkum,
        lbkum     LIKE mbew-lbkum,
      END OF xmcmbew.

DATA: BEGIN OF xmcwmhd OCCURS 0.      "Lagercontrolling Header
        INCLUDE STRUCTURE mcwmhdb.
DATA: END OF xmcwmhd.

DATA: BEGIN OF xmcwmit OCCURS 0.      "Lagercontrolling Item
        INCLUDE STRUCTURE mcwmitb.
DATA: END OF xmcwmit.

DATA: BEGIN OF xmcbest_key,
        mandt LIKE mseg-mandt,
        matnr LIKE mseg-matnr,
        werks LIKE mseg-werks,
        lgort LIKE mseg-lgort,
        charg LIKE mseg-charg,
        sobkz LIKE mseg-sobkz,
        lifnr LIKE mseg-lifnr,
        kunnr LIKE mseg-kunnr,
        pspnr LIKE mspr-pspnr,
        vbeln LIKE mska-vbeln,
        posnr LIKE mska-posnr,
      END OF xmcbest_key.

DATA: BEGIN OF mc_mara.
        INCLUDE STRUCTURE mara.
DATA: END OF mc_mara.

DATA: BEGIN OF mc_marc.
        INCLUDE STRUCTURE marc.
DATA: END OF mc_marc.

*------- Tabelle der betroffenen Buchungskreise
DATA: BEGIN OF bukrs OCCURS 0,
        bukrs LIKE t001-bukrs,
        xumbw LIKE t156w-xumbw,
        umbuk LIKE t001-bukrs,
        ktopl LIKE t001-ktopl,
        periv LIKE t001-periv,
        xruem LIKE mseg-xruem,
        waers LIKE mseg-waers,
        gjahr LIKE mseg-gjahr,
        monat LIKE vm07m-monat,
        belnr LIKE bkpf-belnr,
        summe_s LIKE rm07m-summe_s,
        summe_h LIKE rm07m-summe_h,
        saldo LIKE rm07m-saldo,
      END OF bukrs.

* MAA EhP4 -Start                                           "MAA EhP4
* global table type definition for JFMIP
types : stype_bukrs          like line of bukrs,
        stab_bukrs           type  standard table of stype_bukrs.
* MAA EhP4 -End                                             "MAA EhP4

*------- F-Beleg Zeilenzuordnung
DATA: BEGIN OF yfbuz OCCURS 0,
        zeile LIKE mseg-zeile,
        bukrs LIKE mseg-bukrs,
        xumbw LIKE t156w-xumbw,
        buzid LIKE bseg-buzid,
        monat LIKE vm07m-monat,
        shkzg LIKE bseg-shkzg,
        dmbtr LIKE bseg-dmbtr,
        bualt LIKE bseg-bualt,
        awewr LIKE vm07m-awewr,
        aweww LIKE vm07m-aweww,
        stunr LIKE ekbz-stunr,
        zaehk LIKE ekbz-zaehk,
        xauto LIKE zcxcb-xauto,
        bnbtr LIKE mseg-bnbtr,
        ktosl LIKE bseg-ktosl,
        hkont LIKE bseg-hkont,
        gsber LIKE bseg-gsber,
        prctr LIKE bseg-prctr,
        lbbtr LIKE zcxcm-lbbtr,
      END OF yfbuz.

* MAA EhP4 -Start                                           "MAA EhP4
* global table type definition for JFMIP
types : stype_yfbuz          like  line of yfbuz,
        stab_yfbuz           type  standard table of stype_yfbuz.
* MAA EhP4 -End                                             "MAA EhP4

*-------- Tabelle der vorläufigen Belegnummern -----------------------*
DATA: BEGIN OF belnr OCCURS 0,
        belty TYPE c,
        vbeln LIKE bkpf-belnr,
        belnr LIKE bkpf-belnr,
      END OF belnr.

*------  Übergabetabelle an QSS  --------------------------------------*
DATA: BEGIN OF xmbqssz OCCURS 0.
        INCLUDE STRUCTURE mbqssz.
DATA: END OF xmbqssz.

*------ EXCL ( Tabelle für CUA-PF-STATUS  )  --------------------------*
DATA: BEGIN OF excl OCCURS 0,
        funktion(4),
      END OF excl.

*------  Tabellen für Suche nach Bestellungen -------------------------*
DATA: BEGIN OF xmat1n OCCURS 0.       "Materialien zur EAN-Nr.
        INCLUDE STRUCTURE m_mat1n.
DATA: END OF xmat1n.

DATA: BEGIN OF xvmvmb OCCURS 0.       "Transportident.Lieferavis
        INCLUDE STRUCTURE shp_view_trai.                    "470
DATA: END OF xvmvmb.

DATA: BEGIN OF xvmvga OCCURS 0.       "LS-Nummer für Grob-WE
        INCLUDE STRUCTURE shp_idx_rogr.                     "470
DATA: END OF xvmvga.

DATA: BEGIN OF slcomp OCCURS 0.       "Leergut-Stücklisten-
        INCLUDE STRUCTURE stpob.       "komponenten
DATA: END OF slcomp.

DATA: BEGIN OF xvepwe OCCURS 0.
        INCLUDE STRUCTURE vepwe.
DATA: END OF xvepwe.

DATA: BEGIN OF xwueb OCCURS 0.
        INCLUDE STRUCTURE wueb.
DATA: END OF xwueb.

DATA: BEGIN OF xmebex OCCURS 0.
        INCLUDE STRUCTURE m_mebex.
DATA: END OF xmebex.

DATA: tfbefu_cr TYPE ck_table_prices_goods_receipt.
DATA: tfbefu_cr_line TYPE ck_t_prices_goods_receipt.
DATA: BEGIN OF xfbefu_cr OCCURS 0.
        INCLUDE STRUCTURE tfbefu_cr_line.
DATA: END   OF xfbefu_cr.

* Foreign trade: item table from MIGO
DATA: gt_ftrade TYPE HASHED TABLE OF ftkey
                WITH UNIQUE KEY exnum expos.

* Tabellendefinitionen für Umlagerung mit ProdME   "Begin of ALRK115218
DATA: seg_tab  TYPE seg_typ OCCURS 0 WITH HEADER LINE,
      meinh_abw TYPE meinh_typ OCCURS 0 WITH HEADER LINE,
      BEGIN OF umseg OCCURS 0,
          matnr LIKE mseg-matnr,
          werks LIKE mseg-werks,
          lgort LIKE mseg-lgort,
          charg LIKE mseg-charg,
          sobkz LIKE mseg-sobkz,
          kdauf LIKE mseg-kdauf,
          kdpos LIKE mseg-kdpos,
          lifnr LIKE mseg-lifnr,
          ps_psp_pnr LIKE mseg-ps_psp_pnr,
          kunnr LIKE mseg-kunnr.
ENHANCEMENT-POINT mm07mtop_06 SPOTS es_sapmm07m STATIC.
DATA:
          zeile LIKE mseg-zeile,
          lbbsa LIKE vm07m-lbbsa,
          menge LIKE mseg-menge,
          erfme LIKE mseg-erfme,
          erfmg LIKE mseg-erfmg,
          ummat LIKE mseg-ummat,
          umcha LIKE mseg-umcha,
          umwrk LIKE mseg-umwrk,
          ws_meng_tab TYPE ws_meng_typ OCCURS 0,
      END OF umseg,
      transf_qty TYPE ws_meng_typ OCCURS 0 WITH HEADER LINE,
      rest_qty TYPE ws_meng_typ OCCURS 0 WITH HEADER LINE.
"End of ALRK115218

*** Daten für Berechnung und Prüfung Mindesthaltbarkeitsdatum **********
DATA: xprdkzt LIKE prdkzt OCCURS 0 WITH HEADER LINE.
***   ^^^^^^^ Texte zu Periodenkennzeichen MHD *************************
DATA: BEGIN OF prev_expd,
*** Daten der letzten fehlerfrei abgearbeiteten Belegposition **********
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
        zeile LIKE mseg-zeile,
        hsdat LIKE mcha-hsdat,
        vfdat LIKE mcha-vfdat.
DATA: END OF prev_expd.
DATA: BEGIN OF akt_expd,
*** Daten der gerade bearbeiteten Belegposition ************************
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
        zeile LIKE mseg-zeile,
        hsdat LIKE mcha-hsdat,
        vfdat_input LIKE mcha-vfdat,
        vfdat_calc LIKE mcha-vfdat.
DATA: END OF akt_expd.
*** END MHD ************************************************************

*-----------------------------------------------------------------------
*       Teil 2 :  Strukturen    ( BEGIN OF ... )
*-----------------------------------------------------------------------
*------ PF-Status wird zusammengesetzt aus T158 und T063 --------------*
DATA: BEGIN OF pfsta,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kzvar LIKE t158-kzvar,         "Bewegungsartenkennung
        pfst1(2)   TYPE c,             "Funktionscodeabhängigkeit
        pfst2(1)   TYPE c,             "frei wählbar
      END OF pfsta.

*------ Neuer PF-Status                                  --------------*
DATA: BEGIN OF new_pfsta,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kzvar LIKE t158-kzvar,         "Bewegungsartenkennung
        pfst1(2)   TYPE c,             "Funktionscodeabhängigkeit
        pfst2(1)   TYPE c,             "frei wählbar
      END OF new_pfsta.

*------ Alter PF-Status                                  --------------*
DATA: BEGIN OF old_pfsta,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kzvar LIKE t158-kzvar,         "Bewegungsartenkennung
        pfst1(2)   TYPE c,             "Funktionscodeabhängigkeit
        pfst2(1)   TYPE c,             "frei wählbar
      END OF old_pfsta.

*------ Bildtitel zusammengesetzt aus T158 und T063      --------------*
DATA: BEGIN OF tit,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kztit LIKE t158-kztit,         "Titelvariante
        kzvar LIKE t063-kztit,
      END OF tit.

*------ Neuer Titel                                      --------------*
DATA: BEGIN OF new_tit,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kztit LIKE t158-kztit,         "Titelvariante
        kzvar LIKE t063-kztit,
      END OF new_tit.

*------ Alter Titel                                      --------------*
DATA: BEGIN OF old_tit,
        trtyp LIKE t158-trtyp,         "Transaktionstyp
        kztit LIKE t158-kztit,         "Titelvariante
        kzvar LIKE t063-kztit,
      END OF old_tit.

*------ Textzusammenstellung füü Felder in Verfügbarkeits-Dialogfenster*
DATA: BEGIN OF texta,
        segmn(4) VALUE  ' ',           "Name Praefix
        binde(1) VALUE  '-',           "Bindestrich
        feldn(5) VALUE  ' ',           "Name Suffix
      END OF texta.

*------ Feldname                           ----------------------------*
DATA: BEGIN OF feldn,
        praef    VALUE 'X',            "Praefix
        segmn(4) VALUE ' ',            "Segmentname
        binde    VALUE '-',            "Bindestrich
        feldn(5) VALUE ' ',            "Feldname
      END OF feldn.

*---- Hilfsstruktur zum Merken von DM07M-Daten
DATA: BEGIN OF dm07m_merken,
        bdart LIKE dm07m-bdart,
        xprms TYPE xprms,
        xlort LIKE dm07m-xlort,
        xchar LIKE dm07m-xchar,
        anbwa LIKE dm07m-anbwa,
        bwtor TYPE bwtar,
        xstbw TYPE xstbw,
        mblmg LIKE dm07m-mblmg,
        mblbm LIKE dm07m-mblbm,
        rshkz LIKE dm07m-rshkz,
        bdmng LIKE dm07m-bdmng,
        enmng LIKE dm07m-enmng,
        wamng LIKE dm07m-wamng,
        wemng LIKE dm07m-wemng,
        bsmng LIKE dm07m-bsmng,
        bstme LIKE mseg-bstme,
        knttp LIKE dm07m-knttp,
        wawrt LIKE dm07m-wawrt,
        wewrt LIKE dm07m-wewrt,
        enwrt LIKE dm07m-enwrt,
        exwrt LIKE dm07m-exwrt,
        umrez LIKE dm07m-umrez,
        umren LIKE dm07m-umren,
        bpumz LIKE dm07m-bpumz,
        bpumn LIKE dm07m-bpumn,
        konto LIKE dm07m-konto,
        kzgru TYPE kzgru,
        grtxt TYPE grtxt,
        zeilo LIKE dm07m-zeild,
        kanba TYPE char1,
        vfmng TYPE vfmng,
        equmg TYPE menge_d,
        berkz LIKE mseg-berkz,
        prvbe TYPE prvbe,
        uptyp TYPE uptyp,
        upvor TYPE upvor,
        urzei LIKE mseg-urzei,
        mekor TYPE mekor,
        kzech TYPE kzech,
        umkzbws TYPE kzbws,
        urerfmg TYPE erfmg,
        urvermg TYPE erfmg,
        cuobj TYPE cuobj,
        stdpd TYPE stdpd,
        kzchf LIKE dm07m-kzchf,
        insmk_original LIKE dm07m-insmk_original,
        uebpo LIKE dm07m-uebpo,                             "484376
        setkzbws TYPE setkzbws,                             "560226
        kzear_inp LIKE dm07m-kzear_inp,                     "624975
        cuobj_refdoc LIKE dm07m-cuobj_refdoc,               "630576
        ucuob LIKE dm07m-ucuob.                             "639409
ENHANCEMENT-POINT MM07MTOP_16 SPOTS ES_SAPMM07M STATIC .
DATA:                                                         "RZ1447388
      END OF dm07m_merken.

*---- Hilfsstruktur zum Merken von VM07M-Daten
DATA: BEGIN OF vm07m_merken,
        xstor     LIKE  vm07m-xstor,
        pstyp     LIKE  vm07m-pstyp,
        webre     LIKE  vm07m-webre,
        vbtyp     LIKE  vm07m-vbtyp,
        awewr     LIKE  vm07m-awewr,
        bdter     LIKE  vm07m-bdter,
        bwaer     LIKE  vm07m-bwaer,
        xnebe     LIKE  vm07m-xnebe,
        bumrz     LIKE  vm07m-bumrz,
        bumrn     LIKE  vm07m-bumrn,
        kzear_old LIKE  vm07m-kzear_old,
        retpo     LIKE  vm07m-retpo,
        xkzbew    LIKE  vm07m-xkzbew,
        vbeln     LIKE  vm07m-vbeln,
        vbelp     LIKE  vm07m-vbelp,
        xhead     LIKE  vm07m-xhead,
        line_count LIKE vm07m-line_count,                   "544663
      END OF vm07m_merken.

*---- Hilfsstruktur zum Merken von MSEG-Daten
DATA: BEGIN OF mseg_merken.
        INCLUDE STRUCTURE mseg.
DATA: END OF mseg_merken.

*---- Hilfsstruktur zum Merken der Kopfzeile bei Stückliste
DATA: BEGIN OF sl_kopf,
        lfbnr LIKE  ekbe-lfbnr,
        ebeln LIKE  ekpo-ebeln,
        ebelp LIKE  ekpo-ebelp,
        zeile LIKE  mseg-zeile,
        yzeile LIKE mseg-zeile,
*        WERTMAESSIG TYPE C,
      END OF sl_kopf.
*---- Hilfsstruktur zum Merken der Kopfzeile bei Sammelartikel
DATA: BEGIN OF sammat,
        lfbnr LIKE  ekbe-lfbnr,
        ebeln LIKE  ekpo-ebeln,
        ebelp LIKE  ekpo-ebelp,
        zeile LIKE  mseg-zeile,
      END OF sammat.                                       "note 328675
ENHANCEMENT-POINT mm07mtop_02 SPOTS es_sapmm07m STATIC.
*                                                   * Begin note 356129
*---- structure for the collection of Retail-structures    "note 328675
*DATA: IT_RSTRUCT TYPE T_IT_RSTRUCT.                       "note 328675
*---- a temporary duplicated structure of ymseg or xmseg   "note 328675
*DATA: IT_XYMSEG  TYPE T_IT_XYMSEG.                        "note 328675
*                                                   * end   note 356129
DATA:                                                      "note 328675
*---- Workarea für komplexe Struktur Umlagerung mit ProdME  "ALRK115218
      ws_meng_wa TYPE ws_meng_typ.                          "ALRK115218
*---- Allgemeiner Struktur für Aufruf der Form LAGERORT_PRUEFEN
DATA: xt001l LIKE t001l,                                    "HUM
      ut001l LIKE t001l.       "Umlagerort                          "HUM

*eject
*-----------------------------------------------------------------------
*       Teil 3 :  Einzelfelder
*-----------------------------------------------------------------------

*------ Daten für Lagerverwaltungssystem   ----------------------------*
DATA: lvs_tbnum  LIKE ltbk-tbnum,      " TB-Nummer
      lvs_mailk  LIKE t333m-mailk,     " Mail-Versenden
      lvs_tbpos  LIKE ltbp-tbpos.      " TB-Position

*------ Steuerflags                                        ------------*
DATA: xaktiv     TYPE c,               " Mind. eine Eingabe
      xbcode     TYPE c,               " BCODE aus OLD setzen
      xpaus      TYPE c,               " Position auslassen
      xpf02      TYPE c,               " Kennzeichen f. Pick
      xkont      TYPE i,               " Wechsel der Kontier.
      xkzbw      TYPE c,               " KzBwa ist relevant
      xfausw     TYPE c,               " Feldauswahl
      xinit      TYPE c,               " Hilfsfeld Res.Suche
      xsele_ombi LIKE t158-xsele,      " Position mark. vor.
      xsele      TYPE c,               " Kennz. Übern.+Detail
      xsuch      TYPE c,               " suchen (bis F4 aktiv)
      zwueb      TYPE c,               " Daten aus WUEB füll.
      xsplit     TYPE c.               " Chargensplit in Lieferung

* function : suggest serial numbers from PO MM 11/2006      "EhP604
* this flag will be set during a GR posting when the
* related delivery is missing
data : g_flag_message_m7352  type  abap_bool.

*------ Alle sonstigen Daten                               ------------*
DATA: abbrechen  TYPE c,               " Kennz. Abbrechen
      anzma       LIKE mseg-weanz,     " Anz.WE-Schein man.
      aufsetzen   LIKE mseg-zeile,     " erste Zeile auf Bild
      aufsetzen_1 LIKE mseg-zeile,     " erste Zeile auf Bild
      druck      TYPE c,               " Mind. 1 Pos. drucken
      erstes_mal TYPE c,               " Kennz. fuer PF-Stat.
      fbelnr     LIKE bkpf-belnr,
      hlp_mtart  LIKE smard-mtart,
      index_a    LIKE sy-index,
      index_b    LIKE sy-index,
      index_f    LIKE sy-index,
      index_l    LIKE sy-index,
      index_k    LIKE sy-index,
      index_m    LIKE sy-index,
      index_v    LIKE sy-index,
      index_z    LIKE sy-index,
      index_y    LIKE sy-index,
      index_x    LIKE sy-index,
      index_inv  LIKE sy-index,        " Zeilennr. aut.Invbel
      insmk      LIKE mseg-insmk,
      loop_count LIKE sy-index,
      mcbest_flg,
      next_fausw LIKE dm07m-fausw,     " nächste Feldauswahl
      next_kzgru TYPE kzgru,           " nächster Grund Bew.
      next_btext LIKE dm07m-btext,     " nächster BewArtText
      next_xpbed LIKE vm07m-xpbed,     " nächster PBED-Abbau
      next_xstbw TYPE xstbw,           " nächstes Stornokz.
      next_sobfi LIKE vm07m-sobfi,
      next_soblo LIKE vm07m-soblo,
      next_sobvo LIKE vm07m-sobvo,
      next_umsof LIKE dm07m-umsof,
      next_umsol LIKE dm07m-umsol,
      next_umsov LIKE dm07m-umsov,
      next_umsok LIKE mseg-umsok,
      next_umkzbws LIKE mseg-kzbws,
      next_xkzbew TYPE c,
      numkr      LIKE t003m-numkr,     " Nummernkreis
      old_bwartwa LIKE rm07m-bwart,    "gem. WA-Bewegungsart
      old_bwartwe LIKE rm07m-bwart,    "gem. WE-Bewegungsart
      old_btext  LIKE dm07m-btext,     "nächster BewArtText
      old_xkzbew TYPE c VALUE ' ',     "WA-Pos. im WE-Beleg
      old_fausw  LIKE dm07m-fausw,     "Feldauswahl
      old_kzgru  TYPE kzgru,           "nächster Grund Bew.
      old_sobfi  LIKE vm07m-sobfi,
      old_soblo  LIKE vm07m-soblo,
      old_sobvo  LIKE vm07m-sobvo,
      old_umsof  LIKE dm07m-umsof,
      old_umsol  LIKE dm07m-umsol,
      old_umsov  LIKE dm07m-umsov,
      old_umsok  LIKE mseg-umsok,
      old_umkzbws  LIKE mseg-kzbws,
      old_dynnr  LIKE sy-dynnr,
      old_fcode  LIKE t063f-fcode,
      old_menge  LIKE mseg-menge,
      old_sobkz  LIKE mseg-sobkz,
      old_lgort  LIKE mseg-lgort,
      old_werks  LIKE mseg-werks,
      old_spart  LIKE vm07m-spart,     "default Sparte              "HUM
      posnn      LIKE vbfa-posnn,      " Hilfsfeld für SD
      pstyp      LIKE vm07m-pstyp,     " Hilfsfeld für LB
      qss_testen_gerufen,
      shkzg      LIKE mseg-shkzg,      " Merkfeld S/H-Kennz.
      storno     LIKE index_l,         " Zähler für MBST
      wanzm      LIKE mseg-weanz,      " Merkf. Anz.We-Schein
      upd_ean11  TYPE c,               " mind. 1 neue EAN
      upd_rw     TYPE c,               " mind. 1 RW-relevant
      upd_xlifo  TYPE c,               " mind. 1 Liforelevanz
      awtyp LIKE acchd-awtyp VALUE 'MKPF ',
      awsys LIKE acchd-awsys,
      awref LIKE acchd-awref,
      aworg LIKE acchd-aworg,
      kanba TYPE xfeld,                "Kanbanrelevanz
      xersy TYPE xersy,                "ERS-Verfahren
      xoarc TYPE xoarc,                "optisch. Archiv.
      pos_not_valid,
      lfsnr_input TYPE c,
      matnum    LIKE mseg-matnr,       "Hilfsfeld fuer Serialnr.
      ummatnum  LIKE mseg-matnr,       "Hilfsfeld fuer Serialnr.
      charge    LIKE mseg-charg,       "Hilfsfeld fuer Serialnr.
      xord_check TYPE c.               "AFFW for order checked   "534257
ENHANCEMENT-POINT mm07mtop_15 SPOTS es_sapmm07m STATIC.

DATA: g_assert    TYPE REF TO lcl_sapmm07m_assertions.

*   Cat-Ford Release 2: Redirection of scheduling agreements
*   User CMD - Transport AC0K049219
*   Flag if additional actions in update task along statistical GR
*   are necessary
data: g_f_redirsa_necessary type xfeld.

* Hilfsfelder für Sonderbestand E und Q wegen Kontierungsblock
DATA: kdauf LIKE mseg-kdauf,
      kdpos LIKE mseg-kdpos,
      kdein LIKE mseg-kdein,
      pspnr LIKE mseg-ps_psp_pnr,
      kzbws LIKE mseg-kzbws.

ENHANCEMENT-POINT mm07mtop_07 SPOTS es_sapmm07m STATIC.
* &001 begin: Fehler bei zulässigen Inventurtoleranz
DATA: maxbt       LIKE t043i-maxbt,    " Max. Diff.betrag
*HW548001
      xtoleranz   TYPE i,              " Toleranz überschritten
*HW548001
      xtolmerke   TYPE c,              " Toleranz pruefen.
      index_i     LIKE sy-index.       " Merkindex
* &001 end

* data for partner profit center and business area "201778
DATA: pprctr_save LIKE cobl-pprctr,
      pargb_save  LIKE cobl-pargb.

DATA: gv_cfb_no_check  TYPE flag,     " CFB: kein weiterer check des MHDs
      gv_cfb_rc        TYPE sy-subrc, " CFB: MHD uebernehmen = 0, nicht = 2
      gv_flg_bbd_btch  TYPE flag.     " CFB: MHD nach neuen Methode in Batchstamm

*----------------------------------------------------------------------*
*   Hilfsfelder für Nachrichtensteuerung                               *
*----------------------------------------------------------------------*
DATA: x_upd,                           " Kz Nachrichten geändert
      xobjky LIKE nast-objky,          " Key für Nachrichten
      first TYPE c.                    " Kz Posidialogstruktur
*----------------------------------------------------------------------*
*   Hilfsfelder für Unterscheidung Lieferavis/Grob-WE/Bestellung suchen*
*----------------------------------------------------------------------*
DATA: x_avis,                          " Kz Avis
      x_grobwe.                        " Kz Grob-WE
*DATA: H_LIEFK LIKE RM07M-VLIEF.                     "note 136483
DATA: h_vemng LIKE vepwe-vemng.
DATA: h_vemeh LIKE vepwe-vemeh.                             "note 388707
DATA: h_charg LIKE vepwe-charg.                             "note 388707

DATA: xbesttyp LIKE t163d-ibtyp.
DATA: h_gwelf  LIKE rm07m-gwelf.
DATA: lief1    LIKE am07m-lifnr.
DATA: vlief    LIKE rm07m-vlief,
      vbelp    LIKE rm07m-vbelp.

DATA: h_urzei  LIKE mseg-zeile.

DATA: reswk    LIKE am07m-reswk.

*----------------------------------------------------------------------*
*   Hilfsfelder für Sammelartikel                                      *
*----------------------------------------------------------------------*
DATA: matrix_kopf LIKE mseg-zeile.

*----------------------------------------------------------------------*
*   Hilfsfelder für cross docking Anbindung an WE                      *
*----------------------------------------------------------------------*
DATA: cd_ebeln LIKE ekpo-ebeln VALUE space,
      cd_ebelp LIKE ekpo-ebelp VALUE 0,
      cd_vorgang_aktiv TYPE c  VALUE space.  " mind. eine Pos. verteilt
DATA: vas_vorgang_aktiv TYPE c VALUE space.  " mind. eine VAS-Pos.
DATA: vas_mara LIKE mara.

*----------------------------------------------------------------------*
* Hilfsfelder fuer KAYAK Add-On
*----------------------------------------------------------------------*
DATA: gv_flag_kayak_active TYPE char1 VALUE ''.

*-----------------------------------------------------------------------
*       Teil 4 :  Konstanten
*-----------------------------------------------------------------------
CONSTANTS: maxibuz   LIKE   sy-index VALUE '999',
           bwart_303 LIKE   t156-bwart VALUE '303', "ALRK014884 SW
           ibtyp_avis   LIKE t163d-ibtyp VALUE '2',
           ibtyp_grobwe LIKE t163d-ibtyp VALUE '3',
           c_vbtyp_lief LIKE likp-vbtyp  VALUE 'J', " Lieferung
           c_vbtyp_avis LIKE likp-vbtyp  VALUE '7', " Avis
           c_vbtyp_grob LIKE likp-vbtyp  VALUE 'g', " Grob-WE
           c_attyp_sama LIKE mara-attyp  VALUE '01', " ArtTyp Sammelart.
           c_attyp_vari LIKE mara-attyp  VALUE '02'.   " ArtTyp Variante

*-----------------------------------------------------------------------
*       Teil 5 :  Schnittstellen
*-----------------------------------------------------------------------
*........Nummernvergabe LVS.............................................
CONSTANTS: con_quantzaehler      LIKE inri-object  VALUE 'LVS_LQNUM',
           con_transportbedarf   LIKE inri-object  VALUE 'LVS_TBNUM',
           con_umbuchungsnummer  LIKE inri-object  VALUE 'LVS_UBNUM'.

DATA: nummernkreis          LIKE inri-nrrangenr              ,
      subobjekt             LIKE inri-subobject              ,
      nv-returncode         LIKE inri-returncode             .

*........Konstanten LVS.................................................
CONSTANTS: con_tagesdatum         TYPE c  VALUE ' ',
           con_belegdatum         TYPE c  VALUE '1',
           con_buchungsdatum      TYPE c  VALUE '2',
           con_tcode_lt06(4)      TYPE c  VALUE 'LT06'.

DATA:      folgekz                TYPE c.         " Kennz. Call-Status

*........Schnittstelle Nachrichtenfindung...............................
DATA: mail_aktiv  VALUE 'X',
      mail_updat  VALUE ' ',
      msg_objky   LIKE nast-objky,
      msg_objky_to LIKE nast-objky,
      msg_objtyp  LIKE tojtb-name VALUE 'MSEG'.
ENHANCEMENT-POINT mm07mtop_03 SPOTS es_sapmm07m STATIC.
*-----------------------------------------------------------------------
*       Teil 6 :  Field-Symbols
*-----------------------------------------------------------------------
INCLUDE mm07mfsy.
*-----------------------------------------------------------------------
*       Teil 7 :  Type-Pools
*-----------------------------------------------------------------------
TYPE-POOLS level.
TYPE-POOLS slis.                                            "208382
* Macros
DEFINE if_first.
  if ( not mbval is initial and xwert is initial )
       or mbval is initial or not xower is initial.
  END-OF-DEFINITION.
  DEFINE end_first.
  endif.
END-OF-DEFINITION.
DEFINE check_first.
  check  ( not mbval is initial and xwert is initial )
       or mbval is initial or not xower is initial.
END-OF-DEFINITION.
DEFINE if_secon.
  if  ( ( not mbval is initial and not xwert is initial )
       or mbval is initial ) and xower is initial.
  END-OF-DEFINITION.
  DEFINE end_secon.
  endif.
END-OF-DEFINITION.
DEFINE check_secon.
  check ( ( not mbval is initial and not xwert is initial )
       or mbval is initial ) and xower is initial.
END-OF-DEFINITION.

ENHANCEMENT-POINT MM07MTOP_09 SPOTS ES_SAPMM07M STATIC .

*-----------------------------------------------------------------------
*       Teil 8 :  BAdIs
*-----------------------------------------------------------------------
*BADI declaration for India
CLASS: cl_ex_mb_cin_mm07mfb7 DEFINITION LOAD.
DATA: mb_grpopup TYPE REF TO if_ex_mb_cin_mm07mfb7.
TABLES: t005.
CLASS: cl_ex_mb_cin_mm07mfb7_qty DEFINITION LOAD.
DATA: mb_grqty TYPE REF TO if_ex_mb_cin_mm07mfb7_qty.
*End of BADI declaration
ENHANCEMENT-POINT mm07mtop_04 SPOTS es_sapmm07m STATIC.
* BAdI MB_QUAN_CHECK_BADI: declaration and reference to exithandler
CLASS: cl_ex_mb_quan_check_badi DEFINITION LOAD.
DATA:  if_badi_quan_check TYPE REF TO if_ex_mb_quan_check_badi.

* Badi Class and pointers for CRP calculation (JVA)            "JVA_CRP
CLASS: cl_ex_badi_jva_mm07m DEFINITION LOAD.                   "JVA-CRP
DATA:  if_exit_jv_crp     TYPE REF TO if_ex_badi_jva_mm07m.    "JVA-CRP
DATA:  if_exit_jv_erz     TYPE REF TO if_ex_badi_jva_mm07m.    "JVA-CRP
DATA:  if_exit_jv_ers     TYPE REF TO if_ex_badi_jva_mm07m.    "JVA-CRP

* Class for cross-system movements. Explicit declaration necessary
* to access the constants.
CLASS cl_mmim_cross_system DEFINITION LOAD.                 "sdp462

* BAdI MB_CHECK_LINE_BADI: declaration and reference to exithandler
CLASS: cl_ex_mb_check_line_badi DEFINITION LOAD.
DATA:  if_mb_check_line_badi TYPE REF TO if_ex_mb_check_line_badi.

* BADI MB_DOCUMENT_BADI_SAP: reference to exithandler          "ERP 2005
* from basis 6.20 on, there is no need anymore to declare the
* class beforehand.
DATA: if_mb_document_badi_sap TYPE REF TO if_ex_mb_document_badi_sap.

* BADI MB_STOR_LOC_BADI_GTS: reference to exithandler          "ERP 2005
DATA: if_mb_stor_loc_badi_gts TYPE REF TO if_ex_mb_stor_loc_badi_gts.